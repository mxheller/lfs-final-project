// data ListInstructor:
//   | mtC
//   | linkC(val :: Number, rest :: ListInstructor)
// end

// data BinTreeStudent:
//   | mtS
//   | nodeS(val :: Number, left :: BinTreeStudent, right :: BinTreeStudent)
// end

one sig TListInstructor extends InstructorType {}
one sig mtC extends Variant {}
one sig linkC extends Variant {}
fact TListInstructorConstraints {
    TListInstructor.variants = mtC + linkC
    no mtC.fields
    linkC.fields = 0->TNumber + 1->TListInstructor
}
one sig TBinTreeStudent extends StudentType {}
one sig mtS extends Variant {}
one sig nodeS extends Variant {}
fact TBinTreeStudentConstraints {
    TBinTreeStudent.variants = mtS + nodeS
    no mtS.fields
    nodeS.fields = 0->TNumber + 1->TBinTreeStudent + 2->TBinTreeStudent
}
one sig TNumber extends BuiltinType {}

// The instructor type is less expressive/the student type is more expressive
run {missingField[InstructorType, StudentType]} for 2 Type, 4 Variant
