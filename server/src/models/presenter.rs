use chrono::prelude::*;
use password_hash::scrypt::{ScryptParams, scrypt_simple};

use models::Id;


#[derive(Debug, Serialize, Deserialize)]
pub struct Presenter {
    #[serde(rename = "emailAddress")]
    pub email_address: Id,
    #[serde(rename = "passwordHash")]
    pub password_hash: String,
    #[serde(rename = "joinDate")]
    pub join_date: DateTime<Utc>,
}

impl Presenter {
    /// Construct a new `Presenter`, which is effectively a user account.
    pub fn new(email: String, password: String) -> Presenter {
        let params = ScryptParams::new(14, 8, 1);
        let pwd_hash = scrypt_simple(&password, &params).unwrap();
        Presenter {
            email_address: Id(email),
            password_hash: pwd_hash,
            join_date: Utc::now(),
        }
    }
}
