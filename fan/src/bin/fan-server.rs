use clap::Parser;
use fan::config::{FanProfile, ServerConfig, SetPoint};
use fan::protocol::{ReportTemperatureError, ReportTemperatureResponse, Request};
use libmedium::sensors::async_sensors::pwm::AsyncWriteablePwmSensor;
use libmedium::units::{Pwm, PwmEnable};
use libmedium::{parse_hwmons_async, ParsingError};
use std::cmp::Ordering;
use std::collections::HashMap;
use std::fs;
use std::io::{self, Cursor, Write};
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::path::PathBuf;
use tokio::net::UdpSocket;
use tracing::{error, info, span, Level};
use tracing_subscriber::FmtSubscriber;

/// Struct containing the state of each profile
struct State<T> {
    curve: Vec<SetPoint>,
    fans: Vec<T>,
}

/// Actual main function to catch errors
async fn run(args: &Args) -> Result<(), MainError> {
    // Set up logger
    let subscriber = FmtSubscriber::builder()
        .with_max_level(args.verbosity)
        .finish();
    tracing::subscriber::set_global_default(subscriber)?;
    // Load the config file
    let config: ServerConfig = {
        let config_data = fs::read(&args.config).map_err(MainError::LoadConfig)?;
        toml::from_slice(&config_data)?
    };
    // List out hwmons
    let hwmons = parse_hwmons_async().await?;
    // Now that we have hwmons, we want to get handles for each of the relevant hwmons in the
    // config
    let mut state: HashMap<_, _> = config
        .into_iter()
        .map(|(name, FanProfile { fan, mut curve })| {
            let fans = fan
                .into_iter()
                .map(|f| match hwmons.hwmon_by_index(f.hwmon) {
                    Some(hwmon) => match hwmon.writeable_pwms().get(&f.fan) {
                        Some(pwm) => Ok(pwm),
                        None => Err(MainError::FanNotFound {
                            hwmon: f.hwmon,
                            fan: f.fan,
                        }),
                    },
                    None => Err(MainError::HwmonNotFound(f.hwmon)),
                })
                .collect::<Result<Vec<_>, MainError>>()?;
            // Sort the curve by temperature, ascending
            curve.sort_by(|a, b| {
                a.temperature
                    .partial_cmp(&b.temperature)
                    .unwrap_or(Ordering::Equal)
            });
            Ok((name, State { curve, fans }))
        })
        .collect::<Result<HashMap<_, _>, MainError>>()?;
    // Start listening over UDP
    let sock = UdpSocket::bind(SocketAddr::new(args.listen, args.port))
        .await
        .map_err(MainError::Bind)?;
    // Create a buffer for reading packets
    let mut rx_buf = [0u8; 65536];
    // Listen to, and handle requests
    loop {
        // This seems non-fatal so handle it nonfatally
        match sock.recv_from(&mut rx_buf).await {
            Ok((len, addr)) => {
                let request = serde_json::from_slice(&rx_buf[..len])?;
                info!("Received packet from {}: {:?}", addr, request);
                match request {
                    Request::ReportTemperature {
                        profile,
                        temperature,
                    } => {
                        let response = match state.get(profile) {
                            Some(state) => {
                                // Iterate backwards over set points
                                let mut max_speed = 255;
                                let mut max_temp = temperature;
                                let mut min_speed = 0;
                                let mut min_temp = temperature;
                                for point in &state.curve {
                                    // The first temperature point we are higher than
                                    if temperature >= point.temperature {
                                        // We now know we want to interpolate against that set
                                        // point
                                        min_temp = point.temperature;
                                        min_speed = point.speed;
                                    }
                                    // We know this point was higher than ours, so set the max set
                                    // point accordingly
                                    max_temp = point.temperature;
                                    max_speed = point.speed
                                }
                                // By the end of this, we know our maximum and minimum points for
                                // lerping
                                // First, calculate the position in the range
                                const EPSILON: f64 = 0.001;
                                let position = if (max_temp - min_temp) < EPSILON {
                                    0.5
                                } else {
                                    (temperature - min_temp) / (max_temp - min_temp)
                                };
                                // This gets us our target speed
                                let speed = if max_speed == min_speed {
                                    min_speed
                                } else {
                                    let min = f64::from(min_speed);
                                    let max = f64::from(max_speed);
                                    (min + position * (max - min)).clamp(0.0, 256.0).round() as u8
                                };
                                // Set the speed
                                for fan in &state.fans {
                                    fan.write_enable(PwmEnable::ManualControl)
                                        .await
                                        .map_err(MainError::PwmWriteEnable)?;
                                    fan.write_pwm(Pwm::from_u8(speed))
                                        .await
                                        .map_err(MainError::PwmWrite)?;
                                }
                                ReportTemperatureResponse::Success
                            }
                            None => ReportTemperatureResponse::Failure {
                                err: ReportTemperatureError::ProfileDoesNotExist,
                            },
                        };
                        // Serialize and send the response
                        match serde_json::to_vec(&response) {
                            Ok(response) => {
                                if let Err(err) = sock.send_to(&response, addr).await {
                                    error!("Error responding to client: {err}");
                                }
                            }
                            Err(err) => {
                                error!("Error serializing response: {err}");
                            }
                        }
                    }
                }
            }
            Err(err) => {
                error!("Error receiving packet: {err}");
            }
        }
    }
}

/// CLI args
#[derive(Parser)]
struct Args {
    /// Log level
    #[clap(short, long, default_value_t=Level::INFO)]
    verbosity: Level,
    /// Listen address
    #[arg(short, long, default_value_t = IpAddr::V4(Ipv4Addr::new(0,0,0,0)))]
    listen: IpAddr,
    /// Listen port
    #[arg(short, long, default_value_t = 26232)]
    port: u16,
    /// Path to config.toml
    #[arg(default_value = "config.toml")]
    config: PathBuf,
}

/// Just runs run() and logs an error
#[tokio::main(flavor = "current_thread")]
async fn main() {
    let args = Args::parse();
    if let Err(err) = run(&args).await {
        error!("Error in main: {err}");
    }
}

/// Error in the main function
#[derive(Debug, thiserror::Error)]
enum MainError {
    #[error("Error setting up logger: {0}")]
    Tracing(#[from] tracing::subscriber::SetGlobalDefaultError),
    #[error("Error loading config: {0}")]
    LoadConfig(io::Error),
    #[error("Error parsing config: {0}")]
    ParseConfig(#[from] toml::de::Error),
    #[error("Error parsing hwmons: {0}")]
    ParseHwmons(#[from] ParsingError),
    #[error("Hwmon not found: {0}")]
    HwmonNotFound(u16),
    #[error("Fan not found: hwmon={hwmon}, fan={fan}")]
    FanNotFound { hwmon: u16, fan: u16 },
    #[error("Error binding to port: {0}")]
    Bind(io::Error),
    #[error("Error deserializing request: {0}")]
    Deserialize(#[from] serde_json::Error),
    #[error("Error writing enable for pwm: {0}")]
    PwmWriteEnable(libmedium::sensors::Error),
    #[error("Error writing to pwm: {0}")]
    PwmWrite(libmedium::sensors::Error),
}
