sub init()
    m.posterA      = m.top.findNode("posterA")
    m.posterB      = m.top.findNode("posterB")
    m.currentIsA   = true   ' true = posterA is current/visible
    m.dissolveActive = false ' true while a dissolve is in progress

    m.posterA.observeField("loadStatus", "onPosterAStatus")
    m.posterB.observeField("loadStatus", "onPosterBStatus")

    m.timer = m.top.findNode("timer")
    m.timer.observeField("fire", "onTimerFire")

    m.animA        = m.top.findNode("animA")
    m.animB        = m.top.findNode("animB")
    m.dissolveTimer = m.top.findNode("dissolveTimer")
    m.dissolveTimer.observeField("fire", "onDissolveTimer")
end sub

function currentPoster() as Object
    if m.currentIsA then return m.posterA else return m.posterB
end function

function nextPoster() as Object
    if m.currentIsA then return m.posterB else return m.posterA
end function

sub onPhotoUrlChange()
    m.timer.control = "stop"

    ' If a dissolve is in progress, complete it immediately before swapping again
    if m.dissolveActive
        abortDissolve()
    end if

    newUrl = m.top.photoUrl
    np     = nextPoster()

    if np.uri = newUrl and np.loadStatus = "ready"
        ' Already preloaded — swap now
        swapIn()
    else if np.uri <> newUrl
        ' Not preloaded — load into next (hidden) poster; status handler will swap
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

' Called when the next (hidden) poster finishes loading the current photo.
sub onPosterAStatus()
    status = m.posterA.loadStatus
    if status = "loading" or status = "none" then return

    if m.currentIsA
        ' posterA is current (just loaded after being set as the target)
        if status = "ready"
            if not m.top.paused then m.timer.control = "start"
        else
            m.top.advance = true   ' skip failed photo
        end if
    else
        ' posterA is the hidden next poster — did it just load the current target?
        if m.posterA.uri = m.top.photoUrl
            if status = "ready"
                swapIn()
                kickPreload()
            else
                m.top.advance = true
            end if
        end if
    end if
end sub

sub onPosterBStatus()
    status = m.posterB.loadStatus
    if status = "loading" or status = "none" then return

    if not m.currentIsA
        ' posterB is current
        if status = "ready"
            if not m.top.paused then m.timer.control = "start"
        else
            m.top.advance = true
        end if
    else
        ' posterB is the hidden next poster
        if m.posterB.uri = m.top.photoUrl
            if status = "ready"
                swapIn()
                kickPreload()
            else
                m.top.advance = true
            end if
        end if
    end if
end sub

' ---- Swap logic ----

sub swapIn()
    if m.top.dissolve
        doDissolveSwap()
    else
        doInstantSwap()
    end if
end sub

sub doInstantSwap()
    currentPoster().visible = false
    nextPoster().visible    = true
    m.currentIsA = not m.currentIsA
    if not m.top.paused then m.timer.control = "start"
end sub

sub doDissolveSwap()
    ' New poster becomes visible BEHIND the current (z-order: A behind B).
    ' We then fade OUT the current poster so the new one shows through.
    m.dissolveActive = true
    np = nextPoster()
    np.opacity = 1.0
    np.visible  = true

    if m.currentIsA
        ' Current = A (behind); new = B (on top) — nothing to do, B is already above A.
        ' Wait — A is behind B. So if A is current and visible, and B is new...
        ' B is ON TOP of A. B is already rendered above A.
        ' Make B visible (it's on top), then fade OUT A.
        m.animA.control = "start"
    else
        ' Current = B (on top); new = A (behind).
        ' A becomes visible behind B, then fade OUT B.
        m.animB.control = "start"
    end if

    m.dissolveTimer.control = "start"
end sub

sub onDissolveTimer()
    ' Dissolve complete — hide old poster and reset its opacity
    cp = currentPoster()
    cp.visible = false
    cp.opacity = 1.0

    ' Stop the animation (it may already be done, but be safe)
    if m.currentIsA
        m.animA.control = "stop"
    else
        m.animB.control = "stop"
    end if

    m.currentIsA     = not m.currentIsA
    m.dissolveActive = false

    if not m.top.paused then m.timer.control = "start"
    kickPreload()
end sub

' Abort an in-progress dissolve and snap to the swapped state
sub abortDissolve()
    m.dissolveTimer.control = "stop"
    m.animA.control = "stop"
    m.animB.control = "stop"

    cp = currentPoster()
    cp.visible = false
    cp.opacity = 1.0

    np = nextPoster()
    np.opacity = 1.0
    np.visible = true

    m.currentIsA     = not m.currentIsA
    m.dissolveActive = false
end sub

sub kickPreload()
    if not m.dissolveActive
        if m.top.preloadUrl <> "" and m.top.preloadUrl <> m.top.photoUrl
            nextPoster().uri = m.top.preloadUrl
        end if
    end if
end sub

' ---- Other handlers ----

sub onPausedChange()
    if m.top.paused
        m.timer.control = "stop"
    else if currentPoster().loadStatus = "ready" and not m.dissolveActive
        m.timer.control = "start"
    end if
end sub

sub onSlideDurationChange()
    m.timer.duration = m.top.slideDuration
end sub

sub onTimerFire()
    m.top.advance = true
end sub
