use server::capabilities::{Capability, Save, Search};
use server::capabilities::sqlite::SQLite;
use server::models::{Id, Question};

use super::{setup_db, teardown_db};


#[test]
fn can_create_and_retrieve_questions() {
    let db_name = "can_create_and_retrieve_questions.db";
    let db = setup_db(db_name);

    capability!(TestCap for SQLite,
                composing { Save<Question>,   Question, String },
                          { Search<Question>, Question, String });

    fn run_test<DB: TestCap>(db: &DB) {
        let presentation = Id("testpresentation".to_string());
        let question_text = "asking a question".to_string();

        let question = Question::new(presentation, question_text);
        let question = db.perform(Save(question)).unwrap();
        let expected_text = question.text.clone();

        let found = db.perform(Search(question)).unwrap();

        assert_eq!(found.text, expected_text);
    }

    run_test(&db);

    teardown_db(db_name, db);
}
