print("hello world")


local d = os.getenv("HOME") .. "/.config/awesome/themes/ia"

-- https://stackoverflow.com/a/25266573
function dirLookup(dir)
    local p = io.popen('find "'..dir..'" -type f')  --Open directory look for files, save data in p. By giving '-type f' as parameter, it returns all files.     
    for file in p:lines() do                         --Loop through all files
        print(file)       
    end
 end

 dirLookup(d)