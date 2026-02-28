sub init()
    m.photo = m.top.findNode("photo")
    m.timer = m.top.findNode("timer")
    m.timer.observeField("fire", "onTimerFire")
end sub

sub onPhotoUrlChange()
    m.photo.uri = m.top.photoUrl
end sub

sub onPausedChange()
    if m.top.paused
        m.timer.control = "stop"
    else
        m.timer.control = "start"
    end if
end sub

sub onSlideDurationChange()
    m.timer.duration = m.top.slideDuration
end sub

sub onTimerFire()
    m.top.advance = true
end sub
