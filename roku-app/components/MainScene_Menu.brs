' ============================================================
' Menu state machine for MainScene
' Shared scope with MainScene.brs and MainScene_Keys.brs
'
' m.menuStack   — roArray of { menuId: string, selectedIndex: integer }
' m.menuComponent — the MenuComponent node
' m.autoCloseTimer — Timer node (2s, fires onAutoCloseTimer)
' m.autoCloseActive — boolean flag
' ============================================================

' ---- Open / close ----

sub openExitMenu()
    m.menuStack = [{ menuId: "exit", selectedIndex: 0 }]
    m.autoCloseTimer.control = "stop"
    m.autoCloseActive = false
    refreshMenuDisplay()
end sub

sub openMainMenu()
    m.menuStack = [{ menuId: "main", selectedIndex: 0 }]
    m.autoCloseTimer.control = "stop"
    m.autoCloseActive = false
    refreshMenuDisplay()
end sub

sub openPhotosMenu()
    ' Open main menu with Photos pre-selected, then enter Photos submenu
    m.menuStack = [
        { menuId: "main",   selectedIndex: 0 },
        { menuId: "photos", selectedIndex: 0 }
    ]
    m.autoCloseTimer.control = "stop"
    m.autoCloseActive = false
    refreshMenuDisplay()
end sub

sub openSettingsMenu()
    ' Open main menu with Settings pre-selected, then enter Settings submenu
    m.menuStack = [
        { menuId: "main",     selectedIndex: 2 },
        { menuId: "settings", selectedIndex: 0 }
    ]
    m.autoCloseTimer.control = "stop"
    m.autoCloseActive = false
    refreshMenuDisplay()
end sub

sub pushSubmenu(menuId as String)
    m.menuStack.push({ menuId: menuId, selectedIndex: 0 })
    m.autoCloseTimer.control = "stop"
    m.autoCloseActive = false
    refreshMenuDisplay()
end sub

sub popMenu()
    if m.menuStack.count() > 1
        m.menuStack.pop()
        refreshMenuDisplay()
    else
        closeMenu()
    end if
end sub

sub closeMenu()
    print "closeMenu"
    m.menuStack = []
    m.autoCloseTimer.control = "stop"
    m.autoCloseActive = false
    m.menuComponent.visible = false
    print "closeMenu done, menuComponent valid=" + (m.menuComponent <> invalid).toStr()
end sub

function isMenuOpen() as Boolean
    return m.menuStack.count() > 0
end function

' Returns true if Settings (or any of its sub-menus) is anywhere in the stack.
' Settings menus do not auto-close after boolean selection.
function isInSettings() as Boolean
    for each entry in m.menuStack
        mid = entry.menuId
        if mid = "settings" or mid = "slide_duration" or mid = "play_settings"
            return true
        end if
    end for
    return false
end function

sub refreshMenuDisplay()
    if m.menuStack.count() = 0
        m.menuComponent.visible = false
        return
    end if
    entry = m.menuStack[m.menuStack.count() - 1]
    m.menuComponent.menuDef       = buildMenuDef(entry.menuId)
    m.menuComponent.selectedIndex = entry.selectedIndex
end sub

' ---- Navigation ----

sub menuMoveUp()
    if m.menuStack.count() = 0 then return
    lastIdx = m.menuStack.count() - 1
    entry   = m.menuStack[lastIdx]
    def     = buildMenuDef(entry.menuId)
    count   = def.items.count()
    newSel  = (entry.selectedIndex - 1 + count) MOD count
    entry.selectedIndex = newSel
    m.menuStack[lastIdx] = entry
    m.menuComponent.selectedIndex = newSel
end sub

sub menuMoveDown()
    if m.menuStack.count() = 0 then return
    lastIdx = m.menuStack.count() - 1
    entry   = m.menuStack[lastIdx]
    def     = buildMenuDef(entry.menuId)
    count   = def.items.count()
    newSel  = (entry.selectedIndex + 1) MOD count
    entry.selectedIndex = newSel
    m.menuStack[lastIdx] = entry
    m.menuComponent.selectedIndex = newSel
end sub

sub menuSelect()
    if m.menuStack.count() = 0 then return
    lastIdx = m.menuStack.count() - 1
    entry   = m.menuStack[lastIdx]
    def     = buildMenuDef(entry.menuId)
    item    = def.items[entry.selectedIndex]
    if item = invalid then return
    print "menuSelect: item=" + item.id + " sel=" + entry.selectedIndex.toStr()

    if item.hasSubmenu = true
        pushSubmenu(item.submenuId)
    else
        handleMenuAction(item.id)
    end if
end sub

sub menuBack()
    ' If auto-close countdown is running, Back cancels it (menu stays open)
    if m.autoCloseActive
        m.autoCloseTimer.control = "stop"
        m.autoCloseActive = false
        return
    end if
    popMenu()
end sub

' ---- Actions ----

sub handleMenuAction(itemId as String)
    ' Universal: close / cancel
    if itemId = "cancel" or itemId = "close_menu"
        closeMenu()
        return
    end if

    ' Exit app
    if itemId = "exit_app"
        m.top.getScene().exitChannel()
        return
    end if

    ' Photos menu
    if itemId = "all_photos"
        m.settings.photoType  = "all"
        m.settings.folderPath = ""
        saveSettings()
        fetchPlaylist()
        startAutoClose()
        return
    end if

    if itemId = "this_folder"
        m.settings.photoType  = "folder"
        m.settings.folderPath = m.currentFolder
        saveSettings()
        fetchPlaylist()
        startAutoClose()
        return
    end if

    ' Order menu
    if itemId = "order_random"
        m.settings.order = "random"
        saveSettings()
        fetchPlaylist()
        startAutoClose()
        return
    end if

    if itemId = "order_az"
        m.settings.order = "az"
        saveSettings()
        fetchPlaylist()
        startAutoClose()
        return
    end if

    ' Slide duration
    if itemId = "dur_1"
        m.settings.slideDuration = 1
        applySlideDuration()
        saveSettings()
        refreshMenuDisplay()
        return
    end if
    if itemId = "dur_2"
        m.settings.slideDuration = 2
        applySlideDuration()
        saveSettings()
        refreshMenuDisplay()
        return
    end if
    if itemId = "dur_5"
        m.settings.slideDuration = 5
        applySlideDuration()
        saveSettings()
        refreshMenuDisplay()
        return
    end if
    if itemId = "dur_10"
        m.settings.slideDuration = 10
        applySlideDuration()
        saveSettings()
        refreshMenuDisplay()
        return
    end if

    ' Play settings
    if itemId = "looping"
        m.settings.looping = true
        saveSettings()
        refreshMenuDisplay()
        return
    end if
    if itemId = "stop_at_end"
        m.settings.looping = false
        saveSettings()
        refreshMenuDisplay()
        return
    end if
    if itemId = "dissolve"
        m.settings.dissolve = true
        m.slideshow.dissolve = true
        saveSettings()
        refreshMenuDisplay()
        return
    end if
    if itemId = "no_transition"
        m.settings.dissolve = false
        m.slideshow.dissolve = false
        saveSettings()
        refreshMenuDisplay()
        return
    end if
end sub

' Start the 2-second auto-close countdown after a boolean selection.
' No-op if we are inside the Settings menu hierarchy.
sub startAutoClose()
    if isInSettings() then return
    refreshMenuDisplay()
    m.autoCloseTimer.control = "stop"
    m.autoCloseActive = true
    m.autoCloseTimer.control = "start"
end sub

sub onAutoCloseTimer()
    m.autoCloseActive = false
    closeMenu()
end sub

' ---- Menu definitions ----

function buildMenuDef(menuId as String) as Object
    if menuId = "exit"           then return buildExitMenuDef()
    if menuId = "main"           then return buildMainMenuDef()
    if menuId = "photos"         then return buildPhotosMenuDef()
    if menuId = "order"          then return buildOrderMenuDef()
    if menuId = "settings"       then return buildSettingsMenuDef()
    if menuId = "slide_duration" then return buildSlideDurationMenuDef()
    if menuId = "play_settings"  then return buildPlaySettingsMenuDef()
    return invalid
end function

function buildExitMenuDef() as Object
    return {
        heading: "Exit screensaver?",
        items: [
            { id: "cancel",   title: "Cancel",           checked: false, hasSubmenu: false, label: "" },
            { id: "exit_app", title: "Exit screensaver", checked: false, hasSubmenu: false, label: "" }
        ]
    }
end function

function buildMainMenuDef() as Object
    photoLabel = "All"
    if m.settings.photoType = "folder" then photoLabel = "This folder"
    orderLabel = "Random order"
    if m.settings.order = "az" then orderLabel = "A-Z"
    return {
        heading: "",
        items: [
            { id: "photos",     title: "Photos",     label: photoLabel, checked: false, hasSubmenu: true,  submenuId: "photos"   },
            { id: "order",      title: "Order",      label: orderLabel, checked: false, hasSubmenu: true,  submenuId: "order"    },
            { id: "settings",   title: "Settings",   label: "",         checked: false, hasSubmenu: true,  submenuId: "settings" },
            { id: "close_menu", title: "Close menu", label: "",         checked: false, hasSubmenu: false }
        ]
    }
end function

function buildPhotosMenuDef() as Object
    return {
        heading: "",
        items: [
            { id: "all_photos",  title: "Displaying all photos", checked: (m.settings.photoType = "all"),    hasSubmenu: false, label: "" },
            { id: "this_folder", title: "This folder only",      checked: (m.settings.photoType = "folder"), hasSubmenu: false, label: "" },
            { id: "close_menu",  title: "Close menu",            checked: false, hasSubmenu: false, label: "" }
        ]
    }
end function

function buildOrderMenuDef() as Object
    return {
        heading: "",
        items: [
            { id: "order_random", title: "Random order",    checked: (m.settings.order = "random"), hasSubmenu: false, label: "" },
            { id: "order_az",     title: "A-Z by filename", checked: (m.settings.order = "az"),     hasSubmenu: false, label: "" },
            { id: "close_menu",   title: "Close menu",      checked: false, hasSubmenu: false, label: "" }
        ]
    }
end function

function buildSettingsMenuDef() as Object
    durLabel  = m.settings.slideDuration.toStr() + "s"
    if m.settings.looping
        playLabel = "Looping"
    else
        playLabel = "Stop at end"
    end if
    if m.settings.dissolve
        playLabel = playLabel + ", Dissolve"
    else
        playLabel = playLabel + ", No transition"
    end if
    return {
        heading: "",
        items: [
            { id: "slide_duration", title: "Slide duration", label: durLabel,  checked: false, hasSubmenu: true, submenuId: "slide_duration" },
            { id: "play_settings",  title: "Play settings",  label: playLabel, checked: false, hasSubmenu: true, submenuId: "play_settings"  },
            { id: "close_menu",     title: "Close menu",     label: "",        checked: false, hasSubmenu: false }
        ]
    }
end function

function buildSlideDurationMenuDef() as Object
    d = m.settings.slideDuration
    return {
        heading: "",
        items: [
            { id: "dur_1",      title: "1 second",   checked: (d = 1),  hasSubmenu: false, label: "" },
            { id: "dur_2",      title: "2 seconds",  checked: (d = 2),  hasSubmenu: false, label: "" },
            { id: "dur_5",      title: "5 seconds",  checked: (d = 5),  hasSubmenu: false, label: "" },
            { id: "dur_10",     title: "10 seconds", checked: (d = 10), hasSubmenu: false, label: "" },
            { id: "close_menu", title: "Close menu", checked: false, hasSubmenu: false, label: "" }
        ]
    }
end function

function buildPlaySettingsMenuDef() as Object
    return {
        heading: "",
        items: [
            { id: "looping",       title: "Looping",               checked: m.settings.looping,          hasSubmenu: false, label: "" },
            { id: "stop_at_end",   title: "Stop after last slide", checked: not m.settings.looping,      hasSubmenu: false, label: "" },
            { id: "dissolve",      title: "Dissolve",              checked: m.settings.dissolve,         hasSubmenu: false, label: "" },
            { id: "no_transition", title: "No transition",         checked: not m.settings.dissolve,     hasSubmenu: false, label: "" },
            { id: "close_menu",    title: "Close menu",            checked: false, hasSubmenu: false, label: "" }
        ]
    }
end function
