local locationPattern = "{(%d+%.%d+%.%d+)}"

function Para(para)
    if para.content[1].text ~= nil then
        _, _, location = para.content[1].text:find(locationPattern)

        if location ~= nil then
            local citation = "@urn:cts:greekLit:tlg0525.tlg001:" .. 
                location .. "\n:citable_urn: urn:cts:greekLit:tlg0525.tlg001.apcip-nagy:" .. 
                location

            return {
                pandoc.Para(pandoc.Str("---")), 
                pandoc.Span(pandoc.Str(citation))
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
        -- we need to unwrap chs_h3 headings because they
        -- contain the references that are turned into URNs
        -- in the next filter
        return div.content
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
