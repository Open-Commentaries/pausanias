local locationPattern = "{(%d+%.%d+%.%d+)}"

function Para(para)
    if para.content[1].text ~= nil then
        _, _, location = para.content[1].text:find(locationPattern)

        if location ~= nil then
            return {
                pandoc.Para("---"),
                pandoc.Span("@urn:cts:greekLit:tlg0525.tlg001.aprip:" .. location),
                para
            }
        end
    end

    return para
end

function Div(div)
    if div.attributes["custom-style"] == "chs_h2" then
        return pandoc.Header(2, pandoc.utils.stringify(div.content), div.attr, div.classes)
    end

    if div.attributes["custom-style"] == "chs_h3" then
        return pandoc.Header(3, pandoc.utils.stringify(div.content), div.attr, div.classes)
    end

    if div.attributes["custom-style"] == "chs_h4" then
        return pandoc.Header(4, pandoc.utils.stringify(div.content), div.attr, div.classes)
    end

    if div.attributes["custom-style"] == "chs_h5" then
        return pandoc.Header(5, pandoc.utils.stringify(div.content), div.attr, div.classes)
    end

    if div.attributes["custom-style"] == "chs_h6" then
        return pandoc.Header(6, pandoc.utils.stringify(div.content), div.attr, div.classes)
    end

    return div
end