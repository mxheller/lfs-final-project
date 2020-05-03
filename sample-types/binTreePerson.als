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
//   | personS(name :: String, age :: Number)
// end

one sig TString extends BuiltinType {}
one sig Number extends BuiltinType {}

one sig BinTreeCorrect extends InstructorType {}
one sig mtC extends Variant {}
one sig nodeC extends Variant {}
fact abstractBinTreeCorrect {
    BinTreeCorrect.variants = mtC + nodeC
    no mtC.fields
    nodeC.fields = 0->PersonCorrect + 1->BinTreeCorrect + 2->BinTreeCorrect
}
one sig BinTreeStudent extends StudentType {}
one sig mtS extends Variant {}
one sig nodeS extends Variant {}
fact abstractBinTreeStudent {
    BinTreeStudent.variants = nodeS + mtS
    no mtS.fields
    nodeS.fields = 0->PersonStudent + 1->BinTreeStudent + 2->BinTreeStudent
}
one sig PersonCorrect extends InstructorType {}
one sig personCorrect extends Variant {}
fact abstractPersonCorrect {
    PersonCorrect.variants = personCorrect
    personCorrect.fields = 0->TString + 1->Number
}
one sig PersonStudent extends StudentType {}
one sig personStudent extends Variant {}
fact abstractPersonStudent {
    PersonStudent.variants = personStudent
    personStudent.fields = 0->TString + 1->Number
}

// The types are equivalent
run {equivalent} for 4 Type, 6 Variant
