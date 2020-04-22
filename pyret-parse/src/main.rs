#![feature(str_strip)]
use std::{
    fs::File,
    io::{Read, Write},
    str::FromStr,
};

#[derive(Debug)]
pub enum TypeError {
    MissingHeader,
    MalformedHeader(String),
    MalformedVariant(String),
    MalformedField(String),
}

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
    fn parse(mut lines: impl Iterator<Item = impl AsRef<str>>) -> Result<Type, TypeError> {
        let name = Self::parse_name(lines.next().ok_or(TypeError::MissingHeader)?)?;
        let mut variants = Vec::new();
        for line in lines {
            if let Some(variant) = Variant::parse(line)? {
                variants.push(variant);
            }
        }
        Ok(Self { name, variants })
    }

    fn parse_name(header: impl AsRef<str>) -> Result<TypeName, TypeError> {
        let header = header
            .as_ref()
            .strip_suffix(':')
            .ok_or(TypeError::MalformedHeader(header.as_ref().to_string()))?;
        match words!(header) {
            ["data", name] => Ok(name.trim().to_string()),
            _ => Err(TypeError::MalformedHeader(header.to_string())),
        }
    }

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
    fn parse(s: impl AsRef<str>) -> Result<Option<Self>, TypeError> {
        let s = s.as_ref().trim();
        match s.split('|').collect::<Vec<_>>().as_slice() {
            [_, variant] => match variant.split('(').collect::<Vec<_>>().as_slice() {
                [name, rest] => {
                    let fields = rest
                        .strip_suffix(')')
                        .ok_or(TypeError::MalformedVariant(s.to_string()))?;
                    let mut parsed = Vec::new();
                    for field in fields.split(',') {
                        parsed.push(field.parse()?);
                    }
                    Ok(Some(Variant::Complex {
                        name: name.trim().to_string(),
                        fields: parsed,
                    }))
                }
                [name] => Ok(Some(Variant::Unit {
                    name: name.trim().to_string(),
                })),
                _ => Err(TypeError::MalformedVariant(s.to_string())),
            },
            ["end"] => Ok(None),
            _ => Err(TypeError::MalformedVariant(s.to_string())),
        }
    }

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

impl FromStr for Field {
    type Err = TypeError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match words!(s.trim()) {
            [field_name, "::", field_type] => Ok(Self {
                name: field_name.to_string(),
                type_name: field_type.to_string(),
            }),
            _ => Err(TypeError::MalformedField(s.to_string())),
        }
    }
}

impl Field {
    fn forge_repr(&self, field_num: usize) -> String {
        format!("{}->{}", field_num, self.type_name)
    }
}

#[macro_export]
macro_rules! words {
    ($s:expr) => {
        $s.split_whitespace().collect::<Vec<_>>().as_slice()
    };
}

fn main() {
    if std::env::args().len() == 1 {
        eprintln!("No definition files");
    }

    for input in std::env::args().skip(1) {
        match File::open(&input) {
            Err(e) => eprintln!("Unable to open file '{}': {}", input, e),
            Ok(mut file) => {
                let mut definition = String::new();
                file.read_to_string(&mut definition).unwrap();
                match Type::parse(definition.lines()) {
                    Err(e) => eprintln!("Failed to parse definition: {:?}", e),
                    Ok(parsed) => {
                        parsed.write_forge_spec(std::io::stdout()).unwrap();
                    }
                }
            }
        }
    }
}
