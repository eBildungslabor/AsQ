mod answer;
mod audience;
mod presentation;
mod presenter;
mod question;

pub use models::answer::Answer;
pub use models::audience::Audience;
pub use models::presentation::Presentation;
pub use models::presenter::Presenter;
pub use models::question::Question;


/// A simple type used for identifiers, so we can more clearly demark relations in our models.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Id(pub String);
