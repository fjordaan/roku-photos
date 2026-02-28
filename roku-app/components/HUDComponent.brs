sub init()
    m.counter = m.top.findNode("counter")
end sub

sub onCountChange()
    m.counter.text = m.top.current.toStr() + " / " + m.top.total.toStr()
end sub
