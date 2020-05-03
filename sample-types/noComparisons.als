// data PersonCorrect:
//   | personC(name :: String, age :: Number)
// end

// data BinTreeStudent:
//   | nodeS(val :: Number, left :: BinTreeStudent, right :: BinTreeStudent)
// end

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
one sig TString extends BuiltinType {}
one sig TNumber extends BuiltinType {}

// This passes none of our predicates
