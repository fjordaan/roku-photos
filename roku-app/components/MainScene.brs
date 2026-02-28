sub init()
    m.top.setFocus(true)

    m.slideshow      = m.top.findNode("slideshow")
    m.hud            = m.top.findNode("hud")
    m.photoPath      = m.top.findNode("photoPath")
    m.errorLabel     = m.top.findNode("errorLabel")
    m.pauseOverlay   = m.top.findNode("pauseOverlay")
    m.pauseIcon      = m.top.findNode("pauseIcon")
    m.pauseIconTimer = m.top.findNode("pauseIconTimer")
    m.pauseIconTimer.observeField("fire", "onPauseIconTimer")

    m.playlist = []
    m.index    = 0
    m.paused   = false

    ' Read server config from registry (falls back to hardcoded defaults)
    reg          = CreateObject("roRegistrySection", "roku-photos")
    nasIp        = reg.Read("server_ip")
    serverPort   = reg.Read("server_port")
    slideDuration = reg.Read("slide_duration")
    if nasIp = ""         then nasIp        = "192.168.1.51"
    if serverPort = ""    then serverPort   = "8080"
    if slideDuration = "" then slideDuration = "5"

    m.serverBase = "http://" + nasIp + ":" + serverPort
    m.slideshow.slideDuration = Val(slideDuration)

    m.slideshow.observeField("advance", "onAdvance")

    fetchPlaylist()
end sub

sub fetchPlaylist()
    url = m.serverBase + "/api/playlist?order=random&limit=500"
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
        showError("No photos found")
        return
    end if

    m.playlist = photos
    showPhoto(0)
    m.slideshow.paused = false   ' start auto-advance
end sub

sub onPlaylistError()
    showError("Server error: " + m.task.fetchError)
end sub

sub showPhoto(index as Integer)
    m.index = index
    photo = m.playlist[m.index]
    m.slideshow.photoUrl = photo.url
    m.hud.current = m.index + 1
    m.hud.total   = m.playlist.count()
    m.photoPath.text = photo.path

    ' Preload next photo while current is displaying
    nextIndex = (m.index + 1) MOD m.playlist.count()
    m.slideshow.preloadUrl = m.playlist[nextIndex].url
end sub

sub onAdvance()
    goForward()
end sub

sub goBack()
    count = m.playlist.count()
    if count = 0 then return
    showPhoto((m.index - 1 + count) MOD count)
end sub

sub goForward()
    count = m.playlist.count()
    if count = 0 then return
    showPhoto((m.index + 1) MOD count)
end sub

sub togglePause()
    m.paused = not m.paused
    m.slideshow.paused = m.paused
    if m.paused
        m.pauseIcon.text = "||"
    else
        m.pauseIcon.text = ">"
    end if
    m.pauseOverlay.visible = true
    m.pauseIconTimer.control = "start"   ' restarts if already running
end sub

sub onPauseIconTimer()
    m.pauseOverlay.visible = false
end sub

sub showError(msg as String)
    m.errorLabel.text = msg
    m.errorLabel.visible = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return true

    if key = "left"
        goBack()
    else if key = "right"
        goForward()
    else if key = "play"
        togglePause()
    else if key = "back"
        ' Exit the channel
        m.top.getScene().exitChannel()
    end if

    return true
end function
