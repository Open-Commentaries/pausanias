pandoc --lua-filter capture_locations.lua\
    -f docx+styles\
    --extract-media=../static/img GN_Ongoing\ comments\ on\ APRIP\(1\)\(1\)_with-images.docx\
    -t gfm -o ../commentaries/tlg0525.tlg001.apcip-nagy.md && gsed -i 's/..\/static//g' '../commentaries/tlg0525.tlg001.apcip-nagy.md'