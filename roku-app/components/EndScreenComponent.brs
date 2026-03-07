sub init()
    m.panel      = m.top.findNode("panel")
    m.heading    = m.top.findNode("heading")
    m.itemsGroup = m.top.findNode("itemsGroup")

    m.items = [
        "Restart slideshow",
        "All photos, random order",
        "Exit"
    ]

    ' Layout constants (same style as MenuComponent)
    m.panelW = 500
    m.itemH  = 54
    m.padV   = 14
    m.headH  = 46
    m.padH   = 20

    buildRows()
    layoutPanel()
    applyHighlight(0)

    m.top.visible = false
end sub

sub buildRows()
    for i = 0 to m.items.count() - 1
        row = CreateObject("roSGNode", "Group")
        row.translation = [0, i * m.itemH]

        hl = CreateObject("roSGNode", "Rectangle")
        hl.color   = "0xDEEAF8FF"
        hl.width   = m.panelW
        hl.height  = m.itemH
        hl.visible = false
        row.appendChild(hl)

        lbl = CreateObject("roSGNode", "Label")
        lbl.text        = m.items[i]
        lbl.color       = "0x333333FF"
        lbl.font        = "font:MediumSystemFont"
        lbl.translation = [m.padH, 15]
        lbl.width       = m.panelW - m.padH * 2
        row.appendChild(lbl)

        m.itemsGroup.appendChild(row)
    end for
end sub

sub layoutPanel()
    panelH = m.padV + m.headH + (m.items.count() * m.itemH) + m.padV
    panelX = int((1280 - m.panelW) / 2)
    panelY = int((720  - panelH)   / 2)

    m.top.translation        = [panelX, panelY]
    m.panel.width            = m.panelW
    m.panel.height           = panelH
    m.heading.translation    = [m.padH, m.padV]
    m.itemsGroup.translation = [0, m.padV + m.headH]
end sub

sub onSelectedChange()
    applyHighlight(m.top.selectedIndex)
end sub

sub applyHighlight(index as Integer)
    for i = 0 to m.itemsGroup.getChildCount() - 1
        row = m.itemsGroup.getChild(i)
        sel = (i = index)
        row.getChild(0).visible = sel   ' highlight rectangle
        lbl = row.getChild(1)
        if sel then lbl.color = "0x1A4A8AFF" else lbl.color = "0x333333FF"
    end for
end sub
