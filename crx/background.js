chrome.tabs.onUpdated.addListener(function(id, info, tab) {
    chrome.pageAction.show(tab.id)
})

chrome.pageAction.onClicked.addListener(function(tab) {
    chrome.pageAction.show(tab.id)
})
