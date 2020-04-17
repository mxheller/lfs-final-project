#lang forge

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

pred treeA {
    TreeA.variants = mtA + nodeA
    no mtA.fields
    nodeA.fields = sing[0]->TNumber + sing[1]->TreeA + sing[2]->TreeA
}

one sig TreeB extends Type {}
one sig mtB extends Variant {}
one sig nodeB extends Variant {}

pred treeB {
    TreeB.variants = mtB + nodeB
    no mtB.fields
    nodeB.fields = sing[1]->TNumber + sing[0]->TreeB + sing[2]->TreeB
}

run {treeA treeB} for 3 Type, 4 Variant
