sub init()
    m.top.functionName = "fetch"
end sub

sub fetch()
    http = CreateObject("roUrlTransfer")
    http.SetUrl(m.top.url)

    response = http.GetToString()

    if response = ""
        m.top.fetchError = "No response from server"
    else
        m.top.jsonResult = response
    end if
end sub
