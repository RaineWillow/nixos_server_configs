use serde::{Deserialize, Serialize};

/// Request from the client
#[derive(Debug, Deserialize, Serialize)]
#[serde(tag = "type")]
pub enum Request<'a> {
    /// Reports the temperature for the device at a specific profile
    #[serde(rename = "report")]
    ReportTemperature { profile: &'a str, temperature: f64 },
}

#[derive(Deserialize, Serialize)]
pub enum ReportTemperatureError {
    ProfileDoesNotExist,
}
#[derive(Deserialize, Serialize)]
#[serde(tag = "type")]
pub enum ReportTemperatureResponse {
    Success,
    Failure { err: ReportTemperatureError },
}
