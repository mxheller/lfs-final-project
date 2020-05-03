// data BinTreeCorrect:
//   | mtC
//   | nodeC(val :: Number, left :: BinTreeCorrect, right :: BinTreeCorrect)
// end

// data PersonCorrect:
//   | personC(name :: String, age :: Number)
// end

// data BinTreeStudent:
//   | nodeS(val :: Number, left :: BinTreeStudent, right :: BinTreeStudent)
// end

// data PersonStudent:
//   | personS(name :: String)
// end

one sig TBinTreeCorrect extends InstructorType {}
one sig mtC extends Variant {}
one sig nodeC extends Variant {}
fact TBinTreeCorrectConstraints {
    TBinTreeCorrect.variants = mtC + nodeC
    no mtC.fields
    nodeC.fields = 0->TNumber + 1->TBinTreeCorrect + 2->TBinTreeCorrect
}
one sig TPersonCorrect extends InstructorType {}
one sig personC extends Variant {}
fact TPersonCorrectConstraints {
    TPersonCorrect.variants = personC
    personC.fields = 0->TString + 1->TNumber
}
one sig TBinTreeStudent extends StudentType {}
one sig mtS extends Variant {}
one sig nodeS extends Variant {}
fact TBinTreeStudentConstraints {
    TBinTreeStudent.variants = mtS + nodeS
    no mtS.fields
    nodeS.fields = 0->TNumber + 1->TBinTreeStudent + 2->TBinTreeStudent
}
one sig TPersonStudent extends StudentType {}
one sig personS extends Variant {}
fact TPersonStudentConstraints {
    TPersonStudent.variants = personS
    personS.fields = 0->TString
}
one sig TString extends BuiltinType {}
one sig TNumber extends BuiltinType {}

// The student type is missing a field
run {missingField[StudentType, InstructorType]} for 4 Type, 6 Variant
