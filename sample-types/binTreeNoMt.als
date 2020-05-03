// data BinTreeCorrect:
//   | mtC
//   | nodeC(val :: Number, left :: BinTreeCorrect, right :: BinTreeCorrect)
// end

// data BinTreeStudent:
//   | nodeS(val :: Number, left :: BinTreeStudent, right :: BinTreeStudent)
// end

one sig TBinTreeCorrect extends InstructorType {}
one sig mtC extends Variant {}
one sig nodeC extends Variant {}
fact TBinTreeCorrectConstraints {
    TBinTreeCorrect.variants = mtC + nodeC
    no mtC.fields
    nodeC.fields = 0->TNumber + 1->TBinTreeCorrect + 2->TBinTreeCorrect
}
one sig TBinTreeStudent extends StudentType {}
one sig nodeS extends Variant {}
fact TBinTreeStudentConstraints {
    TBinTreeStudent.variants = nodeS
    nodeS.fields = 0->TNumber + 1->TBinTreeStudent + 2->TBinTreeStudent
}
one sig TNumber extends BuiltinType {}

// The student type is missing a variant
run {missingVariant[StudentType, InstructorType]} for 2 Type, 4 Variant
