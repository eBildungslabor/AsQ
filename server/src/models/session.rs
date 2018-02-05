use base64;
use chrono::prelude::*;
use rand;
use rand::Rng;

use models::{Id, Presenter};


#[derive(Debug, Serialize, Deserialize)]
pub struct Session {
    pub token: Id,
    pub owner: Id,
    #[serde(rename = "createdAt")]
    pub created_at: DateTime<Utc>,
}

impl Session {
    pub fn new(owner: Presenter) -> Self {
        let mut rng = rand::thread_rng();
        let mut bytes = [0u8; 32];
        rng.fill_bytes(&mut bytes);
        let token = base64::encode(&bytes);
        Session {
            token: Id(token),
            owner: owner.email_address,
            created_at: Utc::now(),
        }
    }

    pub fn search_parameter(token: Id) -> Self {
        Session {
            token: token,
            owner: Id(String::new()),
            created_at: Utc::now(),
        }
    }
}
