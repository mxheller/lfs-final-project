#![feature(proc_macro_hygiene, decl_macro)]
#![feature(str_strip)]

#[macro_use]
extern crate rocket;

use rocket_contrib::json::Json;
use serde::Deserialize;
use std::io::{Cursor, Write};

pub type TypeName = String;

#[derive(Debug)]
pub struct Type {
    name: TypeName,
    variants: Vec<Variant>,
}

#[derive(Debug)]
pub enum Variant {
    Unit { name: String },
    Complex { name: String, fields: Vec<Field> },
}

#[derive(Debug)]
pub struct Field {
    name: String,
    type_name: TypeName,
}

impl Type {
    fn write_forge_definition(&self, mut out: impl Write) -> std::io::Result<()> {
        writeln!(out, "one sig {} extends Type {{}}", self.name)
    }

    fn write_forge_constraints(&self, mut out: impl Write) -> std::io::Result<()> {
        writeln!(out, "fact abstract{} {{", self.name)?;
        writeln!(
            out,
            "    {}.variants = {}",
            self.name,
            self.variants
                .iter()
                .map(|v| v.name())
                .collect::<Vec<_>>()
                .join(" + ")
        )?;
        for variant in self.variants.iter() {
            variant.write_forge_constraints(&mut out)?;
        }
        writeln!(out, "}}")
    }

    fn write_forge_spec(&self, mut out: impl Write) -> std::io::Result<()> {
        self.write_forge_definition(&mut out)?;
        for variant in self.variants.iter() {
            variant.write_forge_definition(&mut out)?;
        }
        self.write_forge_constraints(&mut out)
    }
}

impl Variant {
    fn name(&self) -> &str {
        match self {
            Self::Unit { name } => name,
            Self::Complex { name, .. } => name,
        }
    }

    fn write_forge_definition(&self, mut out: impl Write) -> std::io::Result<()> {
        writeln!(out, "one sig {} extends Variant {{}}", self.name())
    }

    fn write_forge_constraints(&self, mut out: impl Write) -> std::io::Result<()> {
        write!(&mut out, "    ")?;
        match self {
            Self::Unit { name } => writeln!(out, "no {}.fields", name),
            Self::Complex { name, fields } => {
                let fields = fields
                    .iter()
                    .enumerate()
                    .map(|(idx, field)| field.forge_repr(idx))
                    .collect::<Vec<_>>()
                    .join(" + ");
                writeln!(out, "{}.fields = {}", name, fields)
            }
        }
    }
}

impl Field {
    fn forge_repr(&self, field_num: usize) -> String {
        format!("{}->{}", field_num, self.type_name)
    }
}

peg::parser! {
    grammar pyret_parser() for str {
        pub rule datas() -> Vec<Type>
            = d:data() ** whitespace() { d }
        pub rule data() -> Type
            = "data" whitespace() name:name() ":" whitespace()
                variants:variants() whitespace()
              "end" { Type{ name, variants } }
        rule name() -> TypeName
            = n:$(['a'..='z'|'A'..='Z'|'0'..='9'|'-']+) { n.into() }
        rule variants() -> Vec<Variant>
            = v:variant() ** whitespace() { v }
        rule variant() -> Variant
            = "|" whitespace() name:name() fields:fields() {
                Variant::Complex{ name, fields }
            } /
              "|" whitespace() name:name() {
                  Variant::Unit { name }
            }
        rule fields() -> Vec<Field>
            = "(" f:field() ** (whitespace() "," whitespace()) ")" { f }
        rule field() -> Field
            = name:name() whitespace() "::" whitespace() type_name:name() {
                Field { name, type_name }
            }
        rule whitespace() = quiet!{[' ' | '\n' | '\t']*}
    }
}

#[derive(Deserialize)]
struct Definitions {
    instructor: String,
    student: String,
}

#[post("/parse", data = "<definitions>")]
fn parse(definitions: Json<Definitions>) -> Result<String, String> {
    let mut cur = Cursor::new(Vec::new());
    let mut parse = |definition| -> Result<(), String> {
        let parsed: Vec<Type> = pyret_parser::datas(definition).map_err(|e| format!("{}", e))?;
        for data in parsed {
            dbg!(&data);
            data.write_forge_spec(&mut cur).unwrap();
        }
        Ok(())
    };
    parse(&definitions.instructor)?;
    parse(&definitions.student)?;
    Ok(String::from_utf8(cur.into_inner()).unwrap())
}

fn main() {
    rocket::ignite().mount("/", routes![parse]).launch();
}
