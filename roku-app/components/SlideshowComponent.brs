sub init()
    m.posterA    = m.top.findNode("posterA")
    m.posterB    = m.top.findNode("posterB")
    m.currentIsA = true   ' true = posterA is current/visible
    m.posterA.observeField("loadStatus", "onPosterAStatus")
    m.posterB.observeField("loadStatus", "onPosterBStatus")
    m.timer = m.top.findNode("timer")
    m.timer.observeField("fire", "onTimerFire")
end sub

function currentPoster() as Object
    if m.currentIsA then return m.posterA else return m.posterB
end function

function nextPoster() as Object
    if m.currentIsA then return m.posterB else return m.posterA
end function

sub onPhotoUrlChange()
    m.timer.control = "stop"
    newUrl = m.top.photoUrl
    np = nextPoster()
    if np.uri = newUrl and np.loadStatus = "ready"
        ' Preloaded — instant swap, current poster stays untouched
        currentPoster().visible = false
        np.visible = true
        m.currentIsA = not m.currentIsA
        if not m.top.paused then m.timer.control = "start"
    else if np.uri <> newUrl
        ' Not preloaded — load into next (hidden) poster so the current
        ' poster stays visible during load; status handler will swap when ready
        np.uri = newUrl
    end if
    ' If np.uri = newUrl but still loading: preload in progress,
    ' onPosterXStatus will swap when it finishes
end sub

sub onPreloadUrlChange()
    np = nextPoster()
    ' Don't clobber if next poster is already loading the current photo
    if np.uri <> m.top.photoUrl
        np.uri = m.top.preloadUrl
    end if
end sub

' When the next (hidden) poster finishes loading the current photo, swap it in.
' When the next poster finishes loading a future preload, just leave it.
sub onPosterAStatus()
    status = m.posterA.loadStatus
    if status = "loading" or status = "none" then return

    if m.currentIsA
        ' posterA is the current visible poster
        if status = "ready"
            if not m.top.paused then m.timer.control = "start"
        else   ' failed
            m.top.advance = true
        end if
    else
        ' posterA is the hidden next poster — did it just load the current photo?
        if m.posterA.uri = m.top.photoUrl
            if status = "ready"
                currentPoster().visible = false
                m.posterA.visible = true
                m.currentIsA = true
                if not m.top.paused then m.timer.control = "start"
                ' Preload was blocked earlier — kick it off now
                if m.top.preloadUrl <> "" and m.top.preloadUrl <> m.top.photoUrl
                    nextPoster().uri = m.top.preloadUrl
                end if
            else   ' failed — skip
                m.top.advance = true
            end if
        end if
        ' else: this is a future preload finishing — nothing to do yet
    end if
end sub

sub onPosterBStatus()
    status = m.posterB.loadStatus
    if status = "loading" or status = "none" then return

    if not m.currentIsA
        ' posterB is the current visible poster
        if status = "ready"
            if not m.top.paused then m.timer.control = "start"
        else   ' failed
            m.top.advance = true
        end if
    else
        ' posterB is the hidden next poster — did it just load the current photo?
        if m.posterB.uri = m.top.photoUrl
            if status = "ready"
                currentPoster().visible = false
                m.posterB.visible = true
                m.currentIsA = false
                if not m.top.paused then m.timer.control = "start"
                ' Preload was blocked earlier — kick it off now
                if m.top.preloadUrl <> "" and m.top.preloadUrl <> m.top.photoUrl
                    nextPoster().uri = m.top.preloadUrl
                end if
            else   ' failed — skip
                m.top.advance = true
            end if
        end if
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
