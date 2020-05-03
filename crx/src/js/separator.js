const assert = require('assert')

// Not exporting this because I'm definitely not messing with bundling for this project.
// Copy pasta is yummy for a reason. ✂️🍝
function validateLoad(input) {
    const lines = input.trim().split('\n')
    let studentStart = lines.indexOf('# @Student')
    if (studentStart === -1) {
        return { error: 'No student def found.' }
    }

    let instructorStart = lines.indexOf('# @Instructor')
    if (instructorStart === -1) {
        return { error: 'No instructor def found.' }
    }

    let student = ''
    let instructor = ''
    if (studentStart < instructorStart) {
        // student definition comes before instructor definition
        student = lines.slice(studentStart + 1, instructorStart).join('\n')
        instructor = lines.slice(instructorStart + 1, lines.length).join('\n')
    } else if (instructorStart < studentStart) {
        // instructor definition comes before student definition
        instructor = lines.slice(instructorStart + 1, studentStart).join('\n')
        student = lines.slice(studentStart + 1, input.length).join('\n')
    } else {
        // definitions happen on the same line
        return { error: 'Invalid data definition.' }
    }

    return { student, instructor }
}

let input = `
# @Student
data foo:
    | hi(there: blah blah)
end

# @Instructor
data kee:
    | kaw
end
`
const inputOne = validateLoad(input)
assert(!inputOne.error)
assert(inputOne.student === 'data foo:\n    | hi(there: blah blah)\nend\n')
assert(inputOne.instructor === 'data kee:\n    | kaw\nend')

let input2 = `
# @Instructor
data iAmCorrect: # Here is a comment
    | corr(foo: Number)
    | mt
end
# @Student
data wrong:
    | so(badly: wrong)
end


`
const inputTwo = validateLoad(input2)
assert(!inputTwo.error)
assert(inputTwo.student === 'data wrong:\n    | so(badly: wrong)\nend')
assert(
    inputTwo.instructor ===
        'data iAmCorrect: # Here is a comment\n    | corr(foo: Number)\n    | mt\nend'
)

let input3 = `
# @Instructor
data foo:
  | meme(a :: Number, b :: String)
end

# @Student
data bar:
  | mimi(few :: String, faw :: Number)
end


# No fucking way`
console.log(validateLoad(input3))
