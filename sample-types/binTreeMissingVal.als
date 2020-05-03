// data BinTreeCorrect:
//   | mtC
//   | nodeC(val :: Number, left :: BinTreeCorrect, right :: BinTreeCorrect)
// end

// data BinTreeStudent:
//   | mtS
//   | nodeS(left :: BinTreeStudent, right :: BinTreeStudent)
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
one sig mtS extends Variant {}
one sig nodeS extends Variant {}
fact TBinTreeStudentConstraints {
    TBinTreeStudent.variants = mtS + nodeS
    no mtS.fields
    nodeS.fields = 0->TBinTreeStudent + 1->TBinTreeStudent
}
one sig TNumber extends BuiltinType {}

// The student type is missing a field
run {missingField[StudentType, InstructorType]} for 2 Type, 4 Variant
