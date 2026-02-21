sub init()
    m.top.setFocus(true)
    m.statusLabel = m.top.findNode("status")
    m.keyLabel = m.top.findNode("currentKey")
    m.photo = m.top.findNode("photo")

    fetchPlaylist()
end sub

sub fetchPlaylist()
    ' Server config — will move to roRegistry in Stage 2
    nasIp = "192.168.1.51"
    serverPort = "8080"
    url = "http://" + nasIp + ":" + serverPort + "/api/playlist?limit=20"

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
        m.statusLabel.text = "No photos found"
        return
    end if

    firstPhoto = photos[0]
    m.statusLabel.text = firstPhoto.filename
    m.photo.uri = firstPhoto.url
end sub

sub onPlaylistError()
    m.statusLabel.text = "Error: " + m.task.fetchError
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return true
    m.keyLabel.text = key
    return true
end function
