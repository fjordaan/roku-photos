' ============================================================
' Key event handler for MainScene
' Shared scope with MainScene.brs and MainScene_Menu.brs
' ============================================================

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return true
    print "KEY: " + key + " menuOpen=" + isMenuOpen().toStr()

    if m.endScreenActive
        if key = "up"
            endScreenUp()
        else if key = "down"
            endScreenDown()
        else if key = "OK" or key = "right"
            endScreenSelect()
        else if key = "left"
            endScreenGoBack()
        else if key = "rewind"
            endScreenGoBack10()
        else if key = "back"
            hideEndScreen()
            openExitMenu()
        end if
        ' All other keys (menu shortcuts etc.) are blocked on end screen
        return true
    end if

    if isMenuOpen()
        ' These slideshow controls pass-through even while a menu is open
        if key = "play"
            togglePause()
            return true
        end if
        if key = "rewind"
            goBack10()
            return true
        end if
        if key = "fastforward"
            goForward10()
            return true
        end if
        if key = "replay"
            closeMenu()
            openPhotosMenu()
            return true
        end if
        if key = "options"
            closeMenu()
            openSettingsMenu()
            return true
        end if

        ' Menu navigation
        if key = "up"
            menuMoveUp()
        else if key = "down"
            menuMoveDown()
        else if key = "OK" or key = "right"
            menuSelect()
        else if key = "back" or key = "left"
            menuBack()
        end if
        return true
    end if

    ' No menu open — slideshow controls
    if key = "left"
        goBack()
    else if key = "right"
        goForward()
    else if key = "play"
        togglePause()
    else if key = "back"
        openExitMenu()
    else if key = "OK"
        openMainMenu()
    else if key = "rewind"
        goBack10()
    else if key = "fastforward"
        goForward10()
    else if key = "replay"
        openPhotosMenu()
    else if key = "options"
        openSettingsMenu()
    else if key = "down"
        showPhotoInfo()
    else if key = "up"
        if m.photoInfoVisible
            hidePhotoInfo()
        end if
        ' else: Thumbnails overlay — Stage 5
    end if

    return true
end function
