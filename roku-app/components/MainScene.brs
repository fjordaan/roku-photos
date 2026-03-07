' ============================================================
' MainScene — init, settings, playlist, photo navigation
' Menu logic: MainScene_Menu.brs
' Key handling: MainScene_Keys.brs
' ============================================================

sub init()
    m.top.setFocus(true)

    m.slideshow       = m.top.findNode("slideshow")
    m.hud             = m.top.findNode("hud")
    m.photoInfo       = m.top.findNode("photoInfo")
    m.endScreen       = m.top.findNode("endScreen")
    m.errorLabel      = m.top.findNode("errorLabel")
    m.pauseIcon       = m.top.findNode("pauseIcon")
    m.pauseIconTimer  = m.top.findNode("pauseIconTimer")
    m.menuComponent   = m.top.findNode("menuComponent")
    m.autoCloseTimer  = m.top.findNode("autoCloseTimer")

    m.pauseIconTimer.observeField("fire", "onPauseIconTimer")
    m.autoCloseTimer.observeField("fire", "onAutoCloseTimer")
    m.slideshow.observeField("advance", "onAdvance")

    ' Playlist + navigation state
    m.playlist         = []
    m.index            = 0
    m.paused           = false
    m.currentFolder    = ""
    m.menuStack        = []
    m.autoCloseActive  = false
    m.photoInfoVisible = false
    m.endScreenActive  = false

    loadSettings()
    m.slideshow.slideDuration = m.settings.slideDuration
    m.slideshow.dissolve      = m.settings.dissolve

    fetchPlaylist()
end sub

' ---- Settings ----

sub loadSettings()
    ' Display settings always start at defaults on launch — no persistence.
    m.settings = {
        photoType:     "all",
        folderPath:    "",
        order:         "random",
        slideDuration: 5,
        looping:       true,
        dissolve:      true
    }

    ' Server config only is read from registry (set once, rarely changes).
    reg        = CreateObject("roRegistrySection", "roku-photos")
    nasIp      = reg.Read("server_ip")
    serverPort = reg.Read("server_port")
    if nasIp      = "" then nasIp      = "192.168.1.51"
    if serverPort = "" then serverPort = "8080"

    m.serverBase = "http://" + nasIp + ":" + serverPort
end sub

sub saveSettings()
    reg = CreateObject("roRegistrySection", "roku-photos")
    reg.Write("photo_type",     m.settings.photoType)
    reg.Write("folder_path",    m.settings.folderPath)
    reg.Write("order",          m.settings.order)
    reg.Write("slide_duration", m.settings.slideDuration.toStr())
    if m.settings.looping
        reg.Write("looping", "true")
    else
        reg.Write("looping", "false")
    end if
    if m.settings.dissolve
        reg.Write("dissolve", "true")
    else
        reg.Write("dissolve", "false")
    end if
    reg.Flush()
end sub

' ---- Playlist ----

sub fetchPlaylist()
    url = m.serverBase + "/api/playlist?order=" + m.settings.order + "&limit=500"
    if m.settings.photoType = "folder" and m.settings.folderPath <> ""
        url = url + "&type=folder&path=" + urlEncode(m.settings.folderPath)
    end if

    m.task = CreateObject("roSGNode", "FetchPlaylistTask")
    m.task.url = url
    m.task.observeField("jsonResult", "onPlaylistLoaded")
    m.task.observeField("fetchError", "onPlaylistError")
    m.task.control = "RUN"
end sub

sub onPlaylistLoaded()
    if m.task.jsonResult = "" then return

    photos = ParseJson(m.task.jsonResult)
    if photos = invalid or photos.count() = 0
        ' If folder filter returned nothing, fall back to all photos
        if m.settings.photoType = "folder"
            m.settings.photoType  = "all"
            m.settings.folderPath = ""
            saveSettings()
            fetchPlaylist()
            return
        end if
        showError("No photos found")
        return
    end if

    ' Try to stay at the current photo after a re-fetch (e.g. order change)
    targetPath = ""
    if m.playlist.count() > 0 and m.index < m.playlist.count()
        targetPath = m.playlist[m.index].path
    end if

    m.playlist = photos

    startIdx = 0
    if targetPath <> ""
        for i = 0 to photos.count() - 1
            if photos[i].path = targetPath
                startIdx = i
                exit for
            end if
        end for
    end if

    showPhoto(startIdx)
    m.slideshow.paused = m.paused
end sub

sub onPlaylistError()
    showError("Server error: " + m.task.fetchError)
end sub

' ---- Photo display ----

sub showPhoto(index as Integer)
    m.index = index
    photo   = m.playlist[m.index]

    m.slideshow.photoUrl = photo.url
    m.hud.current        = m.index + 1
    m.hud.total          = m.playlist.count()

    ' Extract folder path for "This folder" menu option and info overlay
    pathLen = Len(photo.path)
    fileLen = 0
    if photo.filename <> invalid then fileLen = Len(photo.filename)
    if fileLen > 0 and pathLen > fileLen + 1
        m.currentFolder = Left(photo.path, pathLen - fileLen - 1)
    else
        m.currentFolder = ""
    end if

    ' Update photo info overlay (visible or not — stays current when toggled on)
    m.photoInfo.photoPath     = m.currentFolder
    if photo.filename <> invalid then
        m.photoInfo.photoFilename = photo.filename
    else
        m.photoInfo.photoFilename = ""
    end if
    if photo.date <> invalid then
        m.photoInfo.photoDate = photo.date
    else
        m.photoInfo.photoDate = ""
    end if

    ' Preload next photo
    nextIdx = m.index + 1
    if nextIdx >= m.playlist.count() then nextIdx = 0
    m.slideshow.preloadUrl = m.playlist[nextIdx].url
end sub

sub onAdvance()
    goForward()
end sub

' ---- Navigation ----

sub goBack()
    count = m.playlist.count()
    if count = 0 then return
    showPhoto((m.index - 1 + count) MOD count)
end sub

sub goForward()
    count = m.playlist.count()
    if count = 0 then return
    if m.index >= count - 1
        if not m.settings.looping
            m.paused = true
            m.slideshow.paused = true
            showEndScreen()
            return
        end if
        showPhoto(0)
    else
        showPhoto(m.index + 1)
    end if
end sub

sub goBack10()
    count = m.playlist.count()
    if count = 0 then return
    newIdx = m.index - 10
    if newIdx < 0 then newIdx = 0
    showPhoto(newIdx)
end sub

sub goForward10()
    count = m.playlist.count()
    if count = 0 then return
    newIdx = m.index + 10
    if newIdx >= count then newIdx = count - 1
    showPhoto(newIdx)
end sub

' ---- Pause / play ----

sub togglePause()
    m.paused = not m.paused
    m.slideshow.paused = m.paused
    if m.paused
        m.pauseIcon.uri = "pkg:/images/icon_pause.png"
    else
        m.pauseIcon.uri = "pkg:/images/icon_play.png"
    end if
    m.pauseIcon.visible = true
    m.pauseIconTimer.control = "start"
end sub

sub onPauseIconTimer()
    m.pauseIcon.visible = false
end sub

sub applySlideDuration()
    m.slideshow.slideDuration = m.settings.slideDuration
end sub

' Re-sort/shuffle the current in-memory playlist and stay at the current photo.
sub applyOrder()
    if m.playlist.count() = 0 then return

    currentPath = m.playlist[m.index].path

    if m.settings.order = "az"
        m.playlist.SortBy("filename", "i")
    else
        ' Fisher-Yates shuffle
        count = m.playlist.count()
        for i = count - 1 to 1 step -1
            j = int(rnd(0) * (i + 1))
            tmp          = m.playlist[i]
            m.playlist[i] = m.playlist[j]
            m.playlist[j] = tmp
        end for
    end if

    ' Stay at the same photo in its new position
    newIdx = 0
    for i = 0 to m.playlist.count() - 1
        if m.playlist[i].path = currentPath
            newIdx = i
            exit for
        end if
    end for
    showPhoto(newIdx)
end sub

' ---- End of slideshow screen ----

sub showEndScreen()
    m.endScreenActive        = true
    m.endScreen.selectedIndex = 0
    m.endScreen.visible      = true
end sub

sub hideEndScreen()
    m.endScreenActive   = false
    m.endScreen.visible = false
end sub

sub endScreenUp()
    count = 3
    newIdx = (m.endScreen.selectedIndex - 1 + count) MOD count
    m.endScreen.selectedIndex = newIdx
end sub

sub endScreenDown()
    count = 3
    newIdx = (m.endScreen.selectedIndex + 1) MOD count
    m.endScreen.selectedIndex = newIdx
end sub

sub endScreenSelect()
    idx = m.endScreen.selectedIndex
    hideEndScreen()
    if idx = 0
        ' Restart current playlist from beginning
        m.paused = false
        showPhoto(0)
        m.slideshow.paused = false
    else if idx = 1
        ' Restart with all photos, random order
        m.settings.photoType  = "all"
        m.settings.folderPath = ""
        m.settings.order      = "random"
        saveSettings()
        m.paused = false
        fetchPlaylist()
    else if idx = 2
        m.top.exitApp = true
    end if
end sub

sub endScreenGoBack()
    hideEndScreen()
    m.paused = false
    m.slideshow.paused = false
    goBack()
end sub

sub endScreenGoBack10()
    hideEndScreen()
    m.paused = false
    m.slideshow.paused = false
    goBack10()
end sub

' ---- Photo info overlay ----

sub showPhotoInfo()
    m.photoInfoVisible    = true
    m.photoInfo.visible   = true
end sub

sub hidePhotoInfo()
    m.photoInfoVisible    = false
    m.photoInfo.visible   = false
end sub

' ---- Error display ----

sub showError(msg as String)
    m.errorLabel.text    = msg
    m.errorLabel.visible = true
end sub

' ---- Utilities ----

' URL-encode a string without roUrlTransfer (not available on the render thread).
' Keeps / unencoded so NAS paths remain readable; encodes everything else.
function urlEncode(s as String) as String
    safe    = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~/"
    hex     = "0123456789ABCDEF"
    encoded = ""
    for i = 1 to Len(s)
        c    = Mid(s, i, 1)
        code = Asc(c)
        if Instr(1, safe, c) > 0
            encoded = encoded + c
        else
            encoded = encoded + "%" + Mid(hex, int(code / 16) + 1, 1) + Mid(hex, (code MOD 16) + 1, 1)
        end if
    end for
    return encoded
end function
