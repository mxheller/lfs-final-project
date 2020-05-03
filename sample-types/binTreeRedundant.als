// data BinTreeStudent:
//   | mtC
//   | leaf(val :: Number)
//   | nodeC(val :: Number, left :: BinTreeCorrect, right :: BinTreeCorrect)
// end

one sig TBinTreeStudent extends StudentType {}
one sig mtS extends Variant {}
one sig leafS extends Variant {}
one sig nodeS extends Variant {}
fact TBinTreeStudentConstraints {
    TBinTreeStudent.variants = mtS + leafS + nodeS
    no mtS.fields
    leafS.fields = 0->TNumber
    nodeS.fields = 0->TNumber + 1->TBinTreeStudent + 2->TBinTreeStudent
}
one sig TNumber extends BuiltinType {}

// The student type has a possibly redundant variant (leaf)
run {maybeRedundantVariant[TBinTreeStudent]} for 1 Type, 3 Variant
