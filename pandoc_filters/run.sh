pandoc --lua-filter capture_locations.lua\
    -f docx+styles\
    --extract-media=. GN_Ongoing\ comments\ on\ APRIP\(1\)\(1\)_with-images.docx -t gfm -o commentary.md