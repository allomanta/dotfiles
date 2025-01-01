use std::time::Duration;

use serde::{Serialize, Serializer};

#[derive(Debug, Clone, Serialize)]
pub struct State {
    #[serde(serialize_with = "whole_number")]
    pub percentage: f64,
    #[serde(serialize_with = "whole_number")]
    pub wattage: f64,
    #[serde(flatten)]
    pub status: PowerStatus,
}

#[derive(Debug, Clone, Serialize)]
#[serde(tag = "status", rename_all = "PascalCase")]
pub enum PowerStatus {
    Discharging {
        #[serde(serialize_with = "human_duration")]
        time_to_empty: Duration,
    },
    Charging {
        #[serde(serialize_with = "human_duration")]
        time_to_full: Duration,
    },
    FullyCharged,
    // AC connected but not charging into battery because it's already
    // above some threshold, i.e. the battery is not expect to go empty.
    NotCharging,
    Unknown,
}

fn human_duration<S>(duration: &Duration, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    let secs = duration.as_secs();

    if secs >= 3600 {
        let hours = secs / 3600;
        let mins = secs / 60 - hours * 60;

        return serializer.serialize_str(&format!("{}h {}m", hours, mins));
    }

    if secs >= 60 {
        return serializer.serialize_str(&format!("{}m", secs / 60));
    }

    serializer.serialize_str(&format!("{}s", secs))
}

fn whole_number<S>(number: &f64, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serializer.serialize_u64(number.round() as u64)
}
