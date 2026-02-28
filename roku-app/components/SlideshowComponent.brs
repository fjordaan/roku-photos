sub init()
    m.posterA    = m.top.findNode("posterA")
    m.posterB    = m.top.findNode("posterB")
    m.currentIsA = true   ' true = posterA is current, false = posterB is current
    m.posterA.observeField("loadStatus", "onPosterAStatus")
    m.posterB.observeField("loadStatus", "onPosterBStatus")
    m.timer = m.top.findNode("timer")
    m.timer.observeField("fire", "onTimerFire")
end sub

' Returns the currently-displayed poster
function currentPoster() as Object
    if m.currentIsA then return m.posterA else return m.posterB
end function

' Returns the hidden preload poster
function nextPoster() as Object
    if m.currentIsA then return m.posterB else return m.posterA
end function

sub onPhotoUrlChange()
    m.timer.control = "stop"
    newUrl = m.top.photoUrl
    np = nextPoster()
    if np.uri = newUrl and np.loadStatus = "ready"
        ' Already preloaded — swap posters for instant display
        currentPoster().visible = false
        np.visible = true
        m.currentIsA = not m.currentIsA
        if not m.top.paused then m.timer.control = "start"
    else
        currentPoster().uri = newUrl
    end if
end sub

sub onPreloadUrlChange()
    nextPoster().uri = m.top.preloadUrl
end sub

sub onPosterAStatus()
    status = m.posterA.loadStatus
    if status = "loading" or status = "none" then return
    if not m.currentIsA then return   ' posterA is the preload poster, not current
    if status = "ready"
        if not m.top.paused then m.timer.control = "start"
    else   ' failed — skip immediately
        m.top.advance = true
    end if
end sub

sub onPosterBStatus()
    status = m.posterB.loadStatus
    if status = "loading" or status = "none" then return
    if m.currentIsA then return       ' posterB is the preload poster, not current
    if status = "ready"
        if not m.top.paused then m.timer.control = "start"
    else   ' failed — skip immediately
        m.top.advance = true
    end if
end sub

sub onPausedChange()
    if m.top.paused
        m.timer.control = "stop"
    else if currentPoster().loadStatus = "ready"
        m.timer.control = "start"
    end if
    ' If photo hasn't loaded yet, onPosterXStatus will start the timer when it does
end sub

sub onSlideDurationChange()
    m.timer.duration = m.top.slideDuration
end sub

sub onTimerFire()
    m.top.advance = true
end sub
