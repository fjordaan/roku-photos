' ============================================================
' MenuComponent — purely visual menu panel
' All navigation state lives in MainScene; this component
' just renders what it is told via menuDef + selectedIndex.
' ============================================================

sub init()
    m.panel       = m.top.findNode("panel")
    m.heading     = m.top.findNode("heading")
    m.itemsGroup  = m.top.findNode("itemsGroup")
    m.itemRows    = []
    m.itemIsClose = []
    m.top.visible = false
end sub

' ---- Public interface ----

sub onMenuDefChange()
    def = m.top.menuDef
    if def = invalid
        m.top.visible = false
        return
    end if

    ' Clear existing rows
    while m.itemsGroup.getChildCount() > 0
        m.itemsGroup.removeChildIndex(0)
    end while
    m.itemRows    = []
    m.itemIsClose = []

    ' Heading
    h = def.heading
    if h <> invalid and h <> ""
        m.heading.text    = h
        m.heading.visible = true
    else
        m.heading.text    = ""
        m.heading.visible = false
    end if

    items = def.items
    if items = invalid or items.count() = 0
        m.top.visible = false
        return
    end if

    for i = 0 to items.count() - 1
        refs = buildItemRow(items[i], i)
        m.itemsGroup.appendChild(refs.row)
        m.itemRows.push(refs)
        m.itemIsClose.push(items[i].id = "close_menu")
    end for

    layoutPanel(def)
    applyHighlight(m.top.selectedIndex)
    m.top.visible = true
end sub

sub onSelectedChange()
    print "onSelectedChange: " + m.top.selectedIndex.toStr() + " rows=" + m.itemRows.count().toStr()
    applyHighlight(m.top.selectedIndex)
end sub

' ---- Row construction ----

function buildItemRow(item as Object, rowIndex as Integer) as Object
    panelW = 500
    itemH  = 54
    padH   = 20
    titleX = 44
    arrowX = 462   ' panelW - padH - arrowW
    labelW = 120

    row = createObject("roSGNode", "Group")
    row.translation = [0, rowIndex * itemH]

    ' Highlight background (full row width, shown only when selected)
    hl = createObject("roSGNode", "Rectangle")
    hl.color   = "0xDEEAF8FF"
    hl.width   = panelW
    hl.height  = itemH
    hl.visible = false
    row.appendChild(hl)

    ' Checkmark — always takes up space; visible only if item.checked = true
    ck = createObject("roSGNode", "Label")
    ck.text        = chr(10003)
    ck.color       = "0x333333FF"
    ck.font        = "font:MediumSystemFont"
    ck.translation = [padH, 15]
    ck.visible     = (item.checked = true)
    row.appendChild(ck)

    ' Title — width depends on presence of label and arrow
    hasLabel = (item.label <> invalid and item.label <> "")
    hasArrow = (item.hasSubmenu = true)

    if hasArrow and hasLabel
        titleW = arrowX - titleX - 8 - labelW - 6
    else if hasArrow
        titleW = arrowX - titleX - 8
    else
        titleW = panelW - padH - titleX
    end if

    titleColor = "0x333333FF"
    if item.id = "close_menu" then titleColor = "0x888888FF"

    t = createObject("roSGNode", "Label")
    t.text        = item.title
    t.color       = titleColor
    t.font        = "font:MediumSystemFont"
    t.translation = [titleX, 15]
    t.width       = titleW
    row.appendChild(t)

    ' Right-side label
    lbl = invalid
    if hasLabel
        lbl = createObject("roSGNode", "Label")
        lbl.text        = item.label
        lbl.color       = "0x666666FF"
        lbl.font        = "font:SmallSystemFont"
        lbl.horizAlign  = "right"
        lbl.width       = labelW
        lbl.translation = [arrowX - labelW - 6, 19]
        row.appendChild(lbl)
    end if

    ' Disclosure arrow
    arr = invalid
    if hasArrow
        arr = createObject("roSGNode", "Label")
        arr.text        = ">"
        arr.color       = "0x999999FF"
        arr.font        = "font:MediumSystemFont"
        arr.translation = [arrowX, 15]
        row.appendChild(arr)
    end if

    ' Return direct references to avoid findNode on older firmware
    return { row: row, hl: hl, ck: ck, title: t, lbl: lbl, arr: arr }
end function

' ---- Panel layout ----

sub layoutPanel(def as Object)
    panelW   = 500
    itemH    = 54
    padV     = 14
    headH    = 46
    screenW  = 1280
    screenH  = 720
    padH     = 20

    hasHeading = (def.heading <> invalid and def.heading <> "")
    headingH   = 0
    if hasHeading then headingH = headH

    itemCount = def.items.count()
    panelH    = padV + headingH + (itemCount * itemH) + padV

    panelX = int((screenW - panelW) / 2)
    panelY = int((screenH - panelH) / 2)

    m.top.translation = [panelX, panelY]
    m.panel.width     = panelW
    m.panel.height    = panelH

    if hasHeading
        m.heading.translation    = [padH, padV]
        m.itemsGroup.translation = [0, padV + headingH]
    else
        m.heading.visible        = false
        m.itemsGroup.translation = [0, padV]
    end if
end sub

' ---- Highlight ----

sub applyHighlight(index as Integer)
    for i = 0 to m.itemRows.count() - 1
        refs = m.itemRows[i]
        sel  = (i = index)

        refs.hl.visible = sel

        if sel
            refs.title.color = "0x1A4A8AFF"
            refs.ck.color    = "0x1A4A8AFF"
        else if m.itemIsClose[i] = true
            refs.title.color = "0x888888FF"
            refs.ck.color    = "0x333333FF"
        else
            refs.title.color = "0x333333FF"
            refs.ck.color    = "0x333333FF"
        end if

        if refs.lbl <> invalid
            if sel then refs.lbl.color = "0x2255AAFF" else refs.lbl.color = "0x666666FF"
        end if

        if refs.arr <> invalid
            if sel then refs.arr.color = "0x2255AAFF" else refs.arr.color = "0x999999FF"
        end if
    end for
end sub
