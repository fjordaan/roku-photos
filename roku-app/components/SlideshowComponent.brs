sub init()
    m.photo = m.top.findNode("photo")
    m.photo.observeField("loadStatus", "onLoadStatus")
    m.timer = m.top.findNode("timer")
    m.timer.observeField("fire", "onTimerFire")
end sub

sub onPhotoUrlChange()
    m.timer.control = "stop"   ' reset timer while new photo loads
    m.photo.uri = m.top.photoUrl
end sub

sub onLoadStatus()
    if m.photo.loadStatus <> "ready" then return
    if not m.top.paused
        m.timer.control = "start"
    end if
end sub

sub onPausedChange()
    if m.top.paused
        m.timer.control = "stop"
    else if m.photo.loadStatus = "ready"
        ' Photo already loaded — resume timer immediately
        m.timer.control = "start"
    end if
    ' If photo hasn't loaded yet, onLoadStatus will start the timer when it does
end sub

sub onSlideDurationChange()
    m.timer.duration = m.top.slideDuration
end sub

sub onTimerFire()
    m.top.advance = true
end sub
