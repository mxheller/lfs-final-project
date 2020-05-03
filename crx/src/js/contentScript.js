const actualCode = `
setInterval(() => {
    localStorage["codeForLogic"] = CPO.documents.get("definitions://").getValue()
}, 1000)
`;

const scriptEl = document.createElement("script");
scriptEl.textContent = actualCode;
document.body.appendChild(scriptEl);

setInterval(() => {
    chrome.storage.local.set({ codeForLogic: localStorage["codeForLogic"] });
}, 1050);
