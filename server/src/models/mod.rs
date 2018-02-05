mod answer;
mod audience;
mod presentation;
mod presenter;
mod question;
mod session;

use std::cmp::PartialEq;

pub use models::answer::Answer;
pub use models::audience::Audience;
pub use models::presentation::Presentation;
pub use models::presenter::Presenter;
pub use models::question::Question;
pub use models::session::Session;


/// A simple type used for identifiers, so we can more clearly demark relations in our models.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Id(pub String);

impl PartialEq for Id {
    fn eq(&self, other: &Self) -> bool {
        self.0 == other.0 && self.0.len() > 0
    }
}
