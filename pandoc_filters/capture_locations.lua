local locationPattern = "{(%d+%.%d+%.%d+)}"

function Para(para)
    if para.content[1].text ~= nil then
        _, _, location = para.content[1].text:find(locationPattern)

        if location ~= nil then
            return {
                pandoc.Header(2, "@urn:cts:greekLit:tlg0525.tlg001.aprip:" .. location, pandoc.Attr("location-" .. location)),
                para
            }
        end
    end

    return para
end