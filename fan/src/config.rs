use serde::Deserialize;
use std::collections::HashMap;

/// Schema of config.toml
pub type ServerConfig = HashMap<String, FanProfile>;
/// Fan profile
#[derive(Deserialize)]
pub struct FanProfile {
    /// Fans the profile controls
    pub fan: Vec<Fan>,
    /// Fan curve to follow
    pub curve: Vec<SetPoint>,
}
/// Fan config
#[derive(Deserialize)]
pub struct Fan {
    /// Which hwmon (e.g. 1=hwmon1)
    pub hwmon: u16,
    /// Which fan (e.g. 2=pwm2)
    pub fan: u16,
}
/// Curve setpoint
#[derive(Deserialize)]
pub struct SetPoint {
    /// Temperature to trigger at
    pub temperature: f64,
    /// Fan speed (0-255)
    pub speed: u8,
}
