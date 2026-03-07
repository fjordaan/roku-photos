sub init()
    m.pathLabel     = m.top.findNode("pathLabel")
    m.dateLabel     = m.top.findNode("dateLabel")
    m.filenameLabel = m.top.findNode("filenameLabel")
    m.top.visible   = false
end sub

sub onDataChange()
    m.pathLabel.text     = m.top.photoPath
    m.dateLabel.text     = m.top.photoDate
    m.filenameLabel.text = m.top.photoFilename
end sub
