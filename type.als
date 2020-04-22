abstract sig Type {
    variants : set Variant
}
abstract sig Variant {
    fields : seq Type
}

one sig Number extends Type {}

one sig TreeA extends Type {}
one sig mtA extends Variant {}
one sig nodeA extends Variant {}

one sig TreeB extends Type {}
one sig mtB extends Variant {}
one sig nodeB extends Variant {}

fact equivalent {
    let studentTypes = TreeA | let instructorTypes = TreeB | let primitives = Number | {
        // There exists a bijection between Types
        some f: Type->Type | bijective[f, studentTypes, instructorTypes] | {
			let f = f + ((primitives->primitives) & iden) | {
				// There exists a bijection between Variants
			    some g: Variant->Variant | {
                    bijective[g, studentTypes.variants, instructorTypes.variants]

                    // All student types are equivalent to their corresponding type
                    all t1: studentTypes | let t2 = f[t1] | {
                        bijective[((t1.variants)->(t2.variants)) & g, t1.variants, t2.variants]
                        all v1: t1.variants | let v2 = g[v1] | {
                            variantEqual[v1, v2, f]
                        }
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

// Ensure that `f` is a bijection between domain `a` and codomain `b`
pred bijective[f: univ->univ, a: univ, b: univ] {
    // Ensure that the domain of this relation is equal to a
    f.univ = a

    // Ensure that the range is equal to b
    f[univ] = b

    // Domain and codomain have the same cardinality
    #a = #b

    // Injectivity
    f.~f in iden

    // Ensure it's a function
    ~f.f in iden
}

pred treeA {
    TreeA.variants = mtA + nodeA
    no mtA.fields
    nodeA.fields = 0->Number + 1->TreeA + 2->TreeA
}

pred treeB {
    TreeB.variants = mtB + nodeB
    no mtB.fields
    nodeB.fields = 0->Number + 1->TreeB + 2->TreeB
}

run {treeA treeB} for 3 Type, 4 Variant
