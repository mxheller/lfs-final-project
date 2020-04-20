abstract sig Type {
    variants : set Variant
}
abstract sig Variant {
    fields : set Int->Type
}

one sig TNumber extends Type {}

one sig TreeA extends Type {}
one sig mtA extends Variant {}
one sig nodeA extends Variant {}

one sig TreeB extends Type {}
one sig mtB extends Variant {}
one sig nodeB extends Variant {}

fact functionalFields {
    ~(Variant.fields).(Variant.fields) in iden 
}

pred variantEqual[typeA: Type, typeB: Type, variantA: Variant, variantB: Variant] {
    // There exists a bijection between the fields of the variant
    some f: Int->Int | {
        bijective[f, variantA.fields.Type, variantB.fields.Type]

        // Ensure that the types are the same
        all i: f.Int | {
             let t1 = variantA.fields[i] | let t2 = variantB.fields[f[i]] | {
                 // The types are literally equivalent or are references to their parents
                t1 = t2 or (t1 = typeA and t2 = typeB)
             }
        }
    }
}

pred typeEqual[typeA: Type, typeB: Type] {
    // Establish a bijection between the variants of `a` and the variants of `b`
    some f: Variant->Variant | {
        bijective[f, typeA.variants, typeB.variants]

        // The corresponding variants are equivalent
        all vA: f.Variant | let vB = f[vA] {
             variantEqual[typeA, typeB, vA, vB]
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

    // Ensure its a function
    ~f.f in iden
}

pred treeA {
    TreeA.variants = mtA + nodeA
    no mtA.fields
    nodeA.fields = 0->TNumber + 1->TreeA + 2->TreeA
}

pred treeB {
    TreeB.variants = mtB + nodeB
    no mtB.fields
    nodeB.fields = 3->TNumber + 4->TreeB + 5->TreeB
}

run {treeA treeB typeEqual[TreeA, TreeB]} for 3 Type, 4 Variant
