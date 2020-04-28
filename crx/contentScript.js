const actualCode = `
console.log(CPO.documents.get("definitions://").getValue());
`

const scriptEl = document.createElement('script')
scriptEl.textContent = actualCode
document.body.appendChild(scriptEl)
