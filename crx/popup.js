document.addEventListener('DOMContentLoaded', function() {
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
        const val = document.querySelector('#spec-input').value
        if (val.length) {
            setLoadText('Successfully loaded!', 'success')
            enableButtons()
        } else {
            setLoadText('Enter data definitions.', 'error')
            disableButtons()
            setGenerationStatus('', '')
        }
    })

    function getSpec(path, successMessage) {
        setGenerationStatus('Loading...', 'info')
        axios
            .get(path)
            .then(content => {
                console.log(content)
                copyTextToClipboard('Should be done by extension!')
                setGenerationStatus(successMessage, 'success')
            })
            .catch(_ => {
                console.log('Network error!')
                setGenerationStatus('Error retrieving spec.', 'error')
            })
    }

    document
        .querySelector('#default-generator')
        .addEventListener('click', () =>
            getSpec(
                'https://jsonplaceholder.typicode.com/todos/1',
                'Successfully got default spec!'
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
