use std::{
    collections::HashSet,
    io::{Cursor, Write},
};
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
pub fn parse(instructor: &str, student: &str) -> Result<String, JsValue> {
    let mut cur = Cursor::new(Vec::new());
    let mut parse = |definition, category| -> Result<Vec<Type>, String> {
        dbg!(definition);
        let types: Vec<Type> = pyret_parser::datas(definition).map_err(|e| format!("{}", e))?;
        for t in types.iter() {
            t.write_forge_spec(category, &mut cur).unwrap();
        }
        Ok(types)
    };

    // Parse instructor and student types
    let instructor = parse(instructor, Category::Instructor)?;
    let student = parse(student, Category::Student)?;

    // Make a set of instructor and student type names
    let instructor_types: HashSet<_> = instructor.iter().map(|t| &t.name).collect();
    let student_types: HashSet<_> = student.iter().map(|t| &t.name).collect();

    // Find builtin types referenced
    let builtins = instructor
        .iter()
        .flat_map(Type::referenced_types)
        .filter(|t| !instructor_types.contains(t))
        .chain(
            student
                .iter()
                .flat_map(Type::referenced_types)
                .filter(|t| !student_types.contains(t)),
        )
        .collect::<HashSet<_>>();

    // Write builtins to spec
    for builtin in builtins {
        writeln!(&mut cur, "one sig {} extends BuiltinType {{}}", builtin).unwrap();
    }

    Ok(String::from_utf8(cur.into_inner()).unwrap())
}

pub type TypeName = String;

#[derive(Clone, Copy)]
enum Category {
    Instructor,
    Student,
}

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
    fn referenced_types(&self) -> impl Iterator<Item = &TypeName> {
        self.variants
            .iter()
            .flat_map(|v| v.field_types().into_iter())
    }

    fn write_forge_definition(
        &self,
        category: Category,
        mut out: impl Write,
    ) -> std::io::Result<()> {
        match category {
            Category::Instructor => {
                writeln!(out, "one sig {} extends InstructorType {{}}", self.name)
            }
            Category::Student => writeln!(out, "one sig {} extends StudentType {{}}", self.name),
        }
    }

    fn write_forge_constraints(&self, mut out: impl Write) -> std::io::Result<()> {
        writeln!(out, "fact {}Constraints {{", self.name)?;
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

    fn write_forge_spec(&self, category: Category, mut out: impl Write) -> std::io::Result<()> {
        self.write_forge_definition(category, &mut out)?;
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

    #[inline]
    fn field_types(&self) -> Vec<&TypeName> {
        match self {
            Self::Unit { .. } => Vec::new(),
            Self::Complex { fields, .. } => fields.iter().map(|f| &f.type_name).collect(),
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
            = d:data() * { d }
        pub rule data() -> Type
            = whitespace() "data" whitespace() name:type_name() ":" whitespace()
                variants:variants() whitespace()
              "end" whitespace() { Type{ name, variants } }
        rule name() -> String
            = n:$(['a'..='z'|'A'..='Z'|'0'..='9'|'-']+) { n.into() }
        rule type_name() -> TypeName
            = n:name() { format!("T{}", n) }
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
            = name:name() whitespace() "::" whitespace() type_name:type_name() {
                Field { name, type_name }
            }
        rule whitespace() = quiet!{[' ' | '\n' | '\t']*}
    }
}
