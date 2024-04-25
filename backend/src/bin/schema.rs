use backend::graphql_api;
use std::fs::File;
use std::io::Write;

fn main() {
    let schema = graphql_api::schema();

    let res = schema.as_schema_language();

    match File::create("../graphql-schema/schema.gql").and_then(|mut f| f.write_all(res.as_bytes()))
    {
        Ok(_) => println!("Successfully wrote schema to file"),
        Err(err) => {
            println!("Failed to write schema to file: {}", err);
            std::process::exit(127);
        }
    }
}
