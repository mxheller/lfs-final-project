document.addEventListener('DOMContentLoaded', function() {
    let correctParsedOutput = null

    function setLoadText(text, status) {
        const node = document.querySelector('#program-status')
        node.innerHTML = text
        node.classList.value = status
    }

    function setGenerationStatus(text, status) {
        const node = document.querySelector('#generation-status')
        node.innerHTML = text
        node.classList.value = status
    }

    function disableButtons() {
        document.querySelector('#default-generator').disabled = true
        document.querySelector('#cool-generator').disabled = true
    }

    function enableButtons() {
        document.querySelector('#default-generator').disabled = false
        document.querySelector('#cool-generator').disabled = false
    }

    document.querySelector('#program-loader').addEventListener('click', () => {
        setLoadText('Loading...', 'info')
        setTimeout(() => {
            chrome.storage.sync.get(['codeForLogic'], function(items) {
                const code = items.codeForLogic
                if (code.length === 0) {
                    return setLoadText(
                        'No code found. Did you hit Run?',
                        'error'
                    )
                }

                const validateOutput = validateLoad(items.codeForLogic)

                if (!validateOutput.error) {
                    correctParsedOutput = validateOutput
                    setLoadText('Successfully loaded!', 'success')
                    enableButtons()
                } else {
                    correctParsedOutput = null
                    setLoadText(validateOutput.error, 'error')
                    disableButtons()
                    setGenerationStatus('', '')
                }
            })
        }, 1100)
    })

    // Returns {student: string, instructor: string}. {error: string} if error.
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
            student = lines.slice(studentStart + 1, instructorStart).join('\n')
            instructor = lines
                .slice(instructorStart + 1, lines.length)
                .join('\n')
        } else if (instructorStart < studentStart) {
            instructor = lines
                .slice(instructorStart + 1, studentStart)
                .join('\n')
            student = lines.slice(studentStart + 1, input.length).join('\n')
        } else {
            return { error: 'Invalid data definition.' }
        }

        return { student, instructor }
    }

    function getSpec(path, successMessage) {
        setGenerationStatus('Loading...', 'info')
        axios
            .post(path, correctParsedOutput)
            .then(content => {
                // Jank!
                if (content.data.includes('error')) {
                    setGenerationStatus(content.data, 'error')
                } else {
                    copyTextToClipboard(content.data)
                    setGenerationStatus(successMessage, 'success')
                }
            })
            .catch(_ => {
                // TODO: Figure out if this catches both network and http errors
                console.log('Network error!')
                setGenerationStatus('Network error retrieving spec.', 'error')
            })
    }

    document
        .querySelector('#default-generator')
        .addEventListener('click', () =>
            getSpec(
                'http://localhost:8000/parse',
                'Copied default spec to clipboard!'
            )
        )
})

function copyTextToClipboard(text) {
    //Create a textbox field where we can insert text to.
    var copyFrom = document.createElement('textarea')

    //Set the text content to be the text you wished to copy.
    copyFrom.textContent = text

    //Append the textbox field into the body as a child.
    //"execCommand()" only works when there exists selected text, and the text is inside
    //document.body (meaning the text is part of a valid rendered HTML element).
    document.body.appendChild(copyFrom)

    //Select all the text!
    copyFrom.select()

    //Execute command
    document.execCommand('copy')

    //(Optional) De-select the text using blur().
    copyFrom.blur()

    //Remove the textbox field from the document.body, so no other JavaScript nor
    //other elements can get access to this.
    document.body.removeChild(copyFrom)
}
