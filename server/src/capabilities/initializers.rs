use capabilities::{Capability, CreateTable};
use capabilities::sqlite::SQLite;
use models::Question;


capability!(CreateAllTables for SQLite,
            composing { CreateTable<Question>, (), String });

/// Run `create table` operations for every table in the database.
pub fn init_sqlite_tables<DB>(db: &DB) -> Result<(), String>
    where DB: CreateAllTables
{
    db.perform(CreateTable::new())?;
    Ok(())
}
