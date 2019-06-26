function createApp ({ elmApp }) {
  const events = [
    'onCreated',
    'onUpdated',
    // 'onMoved',
    // 'onSelectionChanged',
    // 'onActiveChanged',
    // 'onActivated',
    // 'onHighlightChanged',
    // 'onHighlighted',
    // 'onDetached',
    // 'onAttached',
    'onRemoved'
    // 'onReplaced'
    // 'onZoomChange'
  ]

  return {
    init: function () {

      function byIndex(a, b) {
        if (a.index < b.index) return -1
        if (a.index > b.index) return 1
        return 0
      }

      function normaliseTab (tab) {
        return {
          ...tab,
          favIconUrl: tab.favIconUrl || '',
          muted: tab.mutedInfo.muted
        }
      }

      function reload() {
        chrome.tabs.query({}, function (tabs) {
          const normalisedTabs = tabs.sort(byIndex).map(normaliseTab)

          chrome.storage.local.get(['savedTabs'], function ({ savedTabs }) {
            if (!Array.isArray(savedTabs)) {
              savedTabs = []
            }

            elmApp.ports.tabs.send(normalisedTabs)
            elmApp.ports.savedTabs.send(savedTabs)
          })
        })
      }

      reload()

      events.forEach(event => {
        chrome.tabs[event].addListener(function () {
          reload()
        })
      })

      elmApp.ports.openTab.subscribe(function (id) {
        chrome.tabs.update(id, { active: true }, function () {
          reload()
        })
      })

      elmApp.ports.closeTab.subscribe(function (id) {
        chrome.tabs.remove(id, function () {
          reload()
        })
      })

      elmApp.ports.bulkCloseTab.subscribe(function (ids) {
        chrome.tabs.remove(ids, function () {
          reload()
        })
      })

      elmApp.ports.togglePin.subscribe(function (id) {
        chrome.tabs.get(id, function (tab) {
          chrome.tabs.update(id, { pinned: !tab.pinned }, function () {
            reload()
          })
        })
      })

      elmApp.ports.toggleMute.subscribe(function (id) {
        chrome.tabs.get(id, function (tab) {
          chrome.tabs.update(id, { muted: !tab.mutedInfo.muted }, function () {
            reload()
          })
        })
      })

      elmApp.ports.saveTab.subscribe(function (tab) {
        chrome.storage.local.get(['savedTabs'], function ({ savedTabs }) {
          if (!Array.isArray(savedTabs)) {
            savedTabs = []
          }

          savedTabs.push(tab)

          chrome.storage.local.set({ savedTabs }, function () {
            elmApp.ports.savedTabs.send(savedTabs)
          })
        })
      })
    }
  }
}
