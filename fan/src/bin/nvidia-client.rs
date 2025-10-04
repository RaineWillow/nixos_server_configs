use clap::Parser;
use fan::protocol::Request;
use nvml_wrapper::enum_wrappers::device::TemperatureSensor;
use nvml_wrapper::Nvml;
use std::io;
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use std::time::Duration;
use tokio::net::UdpSocket;
use tracing::{error, info, Level};
use tracing_subscriber::FmtSubscriber;

async fn run(args: &Args) -> Result<(), MainError> {
    // Set up logger
    let subscriber = FmtSubscriber::builder()
        .with_max_level(args.verbosity)
        .finish();
    tracing::subscriber::set_global_default(subscriber)?;
    let nvml = Nvml::init().map_err(MainError::NvmlInit)?;
    // Get the first `Device` (GPU) in the system
    let device = nvml.device_by_index(0).map_err(MainError::NvmlDevice)?;
    // Main loop
    let socket = UdpSocket::bind(SocketAddr::new(IpAddr::V4(Ipv4Addr::UNSPECIFIED), 0))
        .await
        .map_err(MainError::BindSocket)?;
    socket
        .connect(args.server)
        .await
        .map_err(MainError::ConnectSocket)?;
    loop {
        // Get device temperature
        let temperature = device
            .temperature(TemperatureSensor::Gpu)
            .map(f64::from)
            .map_err(MainError::NvmlTemperature)?;
        // Send the request
        let request = Request::ReportTemperature {
            profile: "nvidia",
            temperature,
        };
        let packet = serde_json::to_vec(&request)?;
        socket.send(&packet).await.map_err(MainError::SendRequest)?;
        info!("Sent {temperature}c to server");
        tokio::time::sleep(Duration::from_secs(args.interval)).await;
    }
}
/// CLI args
#[derive(Parser)]
struct Args {
    /// Log level
    #[clap(short, long, default_value_t=Level::INFO)]
    verbosity: Level,
    /// Seconds to wait between measurements
    #[clap(short, long, default_value_t = 1)]
    interval: u64,
    /// Server to send temperatures to
    server: SocketAddr,
}

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
    #[error("Error initializing NVML: {0}")]
    NvmlInit(nvml_wrapper::error::NvmlError),
    #[error("Error getting NVML device: {0}")]
    NvmlDevice(nvml_wrapper::error::NvmlError),
    #[error("Error getting NVML temperature: {0}")]
    NvmlTemperature(nvml_wrapper::error::NvmlError),
    #[error("Error binding UDP socket: {0}")]
    BindSocket(io::Error),
    #[error("Error connecting UDP socket: {0}")]
    ConnectSocket(io::Error),
    #[error("Error serializing request: {0}")]
    SerializeRequest(#[from] serde_json::Error),
    #[error("Error sending on UDP socket: {0}")]
    SendRequest(io::Error),
}
