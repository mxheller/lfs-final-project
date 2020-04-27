abstract sig Type {
    variants : set Variant
}
abstract sig Variant {
    fields : seq Type
}

abstract sig BuiltinType extends Type {}
abstract sig StudentType extends Type {}
abstract sig InstructorType extends Type {}

pred equivalent {
    // There exists a bijection between student and instructor types
    some f: Type->Type | bijective[f, StudentType, InstructorType] | {
        let f = f + ((BuiltinType->BuiltinType) & iden) | {
            // There exists a bijection between student and instructor variants
            some g: Variant->Variant | {
                bijective[g, StudentType.variants, InstructorType.variants]

                // All student types are equivalent to their corresponding instructor type
                all t1: StudentType | let t2 = f[t1] | {
                    bijective[((t1.variants)->(t2.variants)) & g, t1.variants, t2.variants]
                    all v1: t1.variants | let v2 = g[v1] | {
                        variantEqual[v1, v2, f]
                    }
                }
            }
        }
    }
}

pred missingVariant[typeSetA : set Type, typeSetB : set Type] {
    // There exists a bijection between student and instructor types
    some f: Type->Type | bijective[f, typeSetA, typeSetB] | {
        let f = f + ((BuiltinType->BuiltinType) & iden) | {
            // There exists an injection between student and instructor variants
            some g: Variant->Variant | {
                injective[g, typeSetA.variants, typeSetB.variants]
                // All student types are equivalent to their corresponding instructor type
                all t1: typeSetA | let t2 = f[t1] | {
                    injective[((t1.variants)->(t2.variants)) & g, t1.variants, t2.variants]
                    all v1: t1.variants | let v2 = g[v1] | {
						variantEqual[v1, v2, f]
                    }
                }
            }
        }
    }
}

pred missingField[typeSetA : set Type, typeSetB : set Type] {
    // There exists a bijection between student and instructor types
    some f: Type->Type | bijective[f, typeSetA, typeSetB] | {
        let f = f + ((BuiltinType->BuiltinType) & iden) | {
            // There exists a bijection between student and instructor variants
            some g: Variant->Variant | {
                bijective[g, typeSetA.variants, typeSetB.variants]

                // All student types are equivalent to their corresponding instructor type
                all t1: typeSetA | let t2 = f[t1] | {
                    bijective[((t1.variants)->(t2.variants)) & g, t1.variants, t2.variants]
                    all v1: t1.variants | let v2 = g[v1] | {
                        lessExpressiveVariant[v1, v2, f]
                    }
                }
            }
        }
    }
}

pred variantEqual[variantA: Variant, variantB: Variant, f: Type->Type] {
    // There exists a bijection between the fields of the variant
    some g: Int->Int | {
        bijective[g, variantA.fields.inds, variantB.fields.inds]

        // Ensure that the types are equivalent
        all i: g.Int | {
             let t1 = variantA.fields[i] | let t2 = variantB.fields[g[i]] | {
                 // The types are equal
                f[t1] = t2
             }
        }
    }
}

pred lessExpressiveVariant[variantA: Variant, variantB: Variant, f: Type->Type] {
    // There exists an injection between the fields of the variant
    some g: Int->Int | {
        injective[g, variantA.fields.inds, variantB.fields.inds]

        // Ensure that the types are equivalent
        all i: g.Int | {
             let t1 = variantA.fields[i] | let t2 = variantB.fields[g[i]] | {
                 // The types are equal
                f[t1] = t2
             }
        }
    }
}

// Ensure that `f` is a function between domain `a` and codomain `b`
pred functional[f: univ->univ, a: univ, b: univ] {
	// Ensure that the domain of this relation is equal to a
    f.univ = a

    // Ensure that the range is equal to b
    f[univ] in b

	// Ensure it's a function
    ~f.f in iden
}

// Ensure that `f` is an injection between domain `a` and codomain `b`
pred injective[f: univ->univ, a: univ, b: univ] {
    functional[f, a, b]
    f.~f in iden
}

// Ensure that `f` is a bijection between domain `a` and codomain `b`
pred bijective[f: univ->univ, a: univ, b: univ] {
    injective[f, a, b]
	// surjective
	f[a] = b
}
