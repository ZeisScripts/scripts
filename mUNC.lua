local passCount = 0
local totalCount = 0
local reportLog = {}

local function test(name, fn)
    totalCount = totalCount + 1
    local success, result = pcall(fn)
    if success and result then
        passCount = passCount + 1
        local msg = "✅ [mUNC] " .. name .. " - Passed"
        print(msg)
        table.insert(reportLog, msg)
    else
        local msg = "❌ [mUNC] " .. name .. " - Failed"
        print(msg)
        table.insert(reportLog, msg)
    end
end

print("=== Starting mUNC Realism Test ===")
table.insert(reportLog, "=== mUNC Test Report ===")

test("getgenv", function()
    if type(getgenv) ~= "function" then return false end
    local g = getgenv()
    if type(g) ~= "table" then return false end
    local k = "mUNC_" .. tostring(math.random(100, 999))
    g[k] = true
    local match = (g[k] == true)
    g[k] = nil
    return match
end)

test("getrenv", function()
    if type(getrenv) ~= "function" then return false end
    local r = getrenv()
    return type(r) == "table" and r.print ~= nil
end)

test("getreg", function()
    if type(getreg) ~= "function" then return false end
    local reg = getreg()
    return type(reg) == "table" and #reg > 0
end)

test("getgc", function()
    if type(getgc) ~= "function" then return false end
    local gc = getgc()
    return type(gc) == "table" and #gc > 0
end)

test("getscriptextenv", function()
    return type(getscriptextenv) == "function" or type(getscriptenv) == "function"
end)

test("loadstring", function()
    if type(loadstring) ~= "function" then return false end
    local f, err = loadstring("return 42")
    if type(f) ~= "function" then return false end
    return f() == 42
end)

test("checkclosure", function()
    if type(checkclosure) ~= "function" then return false end
    local lClosure = function() end
    return checkclosure(lClosure) == true and checkclosure(print) == false
end)

test("newcclosure", function()
    if type(newcclosure) ~= "function" then return false end
    local f = newcclosure(function() return 100 end)
    if type(f) ~= "function" then return false end
    if type(iscclosure) == "function" and not iscclosure(f) then return false end
    return f() == 100
end)

test("hookfunction", function()
    local hook = hookfunction or replaceclosure
    if type(hook) ~= "function" then return false end
    local target = function() return "original" end
    local replacement = function() return "hooked" end
    hook(target, replacement)
    local ok = (target() == "hooked")
    return ok
end)

test("iscclosure", function()
    if type(iscclosure) ~= "function" then return false end
    return iscclosure(print) == true and iscclosure(function() end) == false
end)

test("islclosure", function()
    if type(islclosure) ~= "function" then return false end
    return islclosure(function() end) == true and islclosure(print) == false
end)

test("hookmetamethod", function()
    if type(hookmetamethod) ~= "function" then return false end
    local t = setmetatable({}, { __index = function() return "old" end })
    hookmetamethod(t, "__index", function() return "new" end)
    return t.any == "new"
end)

test("getrawmetatable", function()
    if type(getrawmetatable) ~= "function" then return false end
    local mt = getrawmetatable(game)
    return type(mt) == "table" and type(mt.__index) == "function"
end)

test("setrawmetatable", function()
    if type(setrawmetatable) ~= "function" then return false end
    local t = setmetatable({}, {})
    local newMt = { __index = function() return "mod" end }
    setrawmetatable(t, newMt)
    return t.test == "mod"
end)

test("setreadonly", function()
    if type(setreadonly) ~= "function" then return false end
    local t = {}
    setreadonly(t, true)
    local _, err = pcall(function() t.x = 1 end)
    return not err == false and (type(isreadonly) ~= "function" or isreadonly(t) == true)
end)

test("isreadonly", function()
    if type(isreadonly) ~= "function" then return false end
    local t = {}
    if isreadonly(t) ~= false then return false end
    if type(setreadonly) == "function" then
        setreadonly(t, true)
        return isreadonly(t) == true
    end
    return true
end)

test("debug.getupvalue", function()
    if type(debug) ~= "table" or type(debug.getupvalue) ~= "function" then return false end
    local count = 0
    local f = function() print(count) end
    return debug.getupvalue(f, 1) == 0
end)

test("debug.setupvalue", function()
    if type(debug) ~= "table" or type(debug.setupvalue) ~= "function" then return false end
    local count = 0
    local f = function() return count end
    debug.setupvalue(f, 1, 99)
    return f() == 99
end)

test("debug.getconstants", function()
    if type(debug) ~= "table" or type(debug.getconstants) ~= "function" then return false end
    local f = function() local x = "munc_const" end
    local consts = debug.getconstants(f)
    if type(consts) ~= "table" then return false end
    for _, v in pairs(consts) do
        if v == "munc_const" then return true end
    end
    return false
end)

test("debug.setconstant", function()
    if type(debug) ~= "table" or type(debug.setconstant) ~= "function" then return false end
    local f = function() return "old" end
    local consts = debug.getconstants or function() return { "old" } end
    local idx = 1
    for i, v in pairs(consts(f)) do
        if v == "old" then idx = i break end
    end
    debug.setconstant(f, idx, "new")
    return f() == "new"
end)

test("debug.getprotos", function()
    if type(debug) ~= "table" or type(debug.getprotos) ~= "function" then return false end
    local f = function() local function inner() end end
    local protos = debug.getprotos(f)
    return type(protos) == "table" and #protos >= 1
end)

test("debug.getinfo", function()
    if type(debug) ~= "table" or type(debug.getinfo) ~= "function" then return false end
    local info = debug.getinfo(print)
    return type(info) == "table" and info.short_src ~= nil
end)

test("Drawing.new", function()
    if type(Drawing) ~= "table" or type(Drawing.new) ~= "function" then return false end
    local square = Drawing.new("Square")
    local ok = (type(square) == "table" and square.Visible ~= nil)
    if ok and type(square.Remove) == "function" then square:Remove() end
    return ok
end)

test("Drawing Text Support", function()
    if type(Drawing) ~= "table" or type(Drawing.new) ~= "function" then return false end
    local text = Drawing.new("Text")
    local ok = (type(text) == "table" and text.Text ~= nil)
    if ok and type(text.Remove) == "function" then text:Remove() end
    return ok
end)

test("isrenderobj", function()
    if type(isrenderobj) ~= "function" or type(Drawing) ~= "table" then return false end
    local square = Drawing.new("Square")
    local ok = isrenderobj(square) == true
    if type(square.Remove) == "function" then square:Remove() end
    return ok
end)

test("cleardrawall", function()
    return type(cleardrawall) == "function" or type(clear_drawing_listeners) == "function"
end)

test("getnilinstances", function()
    if type(getnilinstances) ~= "function" then return false end
    local instances = getnilinstances()
    if type(instances) ~= "table" then return false end
    local part = Instance.new("Part")
    part.Parent = nil
    local found = false
    for _, v in pairs(getnilinstances()) do
        if v == part then found = true break end
    end
    part:Destroy()
    return found
end)

test("getloadedmodules", function()
    if type(getloadedmodules) ~= "function" then return false end
    return type(getloadedmodules()) == "table"
end)

test("fireclickdetector", function()
    if type(fireclickdetector) ~= "function" then return false end
    local cd = Instance.new("ClickDetector")
    local fired = false
    cd.MouseClick:Connect(function() fired = true end)
    fireclickdetector(cd)
    cd:Destroy()
    return fired
end)

test("firetouchinterest", function()
    if type(firetouchinterest) ~= "function" then return false end
    local p1 = Instance.new("Part")
    local p2 = Instance.new("Part")
    local touched = false
    p1.Touched:Connect(function() touched = true end)
    firetouchinterest(p1, p2, 0)
    firetouchinterest(p1, p2, 1)
    p1:Destroy()
    p2:Destroy()
    return touched
end)

test("cache.invalidate", function()
    if type(cache) ~= "table" or type(cache.invalidate) ~= "function" then return false end
    local part = Instance.new("Part")
    cache.invalidate(part)
    local ok = (part ~= nil)
    part:Destroy()
    return ok
end)

test("cache.replace", function()
    if type(cache) ~= "table" or type(cache.replace) ~= "function" then return false end
    local p1 = Instance.new("Part")
    local p2 = Instance.new("Part")
    cache.replace(p1, p2)
    p1:Destroy()
    p2:Destroy()
    return true
end)

test("cloneref", function()
    if type(cloneref) ~= "function" then return false end
    local p = Instance.new("Part")
    local c = cloneref(p)
    local ok = (p ~= c and p:GetDebugId() == c:GetDebugId())
    p:Destroy()
    return ok
end)

test("request", function()
    local req = request or (http and http.request) or (syn and syn.request)
    if type(req) ~= "function" then return false end
    return true
end)

test("crypt.encrypt", function()
    local c = crypt or (syn and syn.crypt)
    if type(c) ~= "table" or type(c.encrypt) ~= "function" then return false end
    local key = "12345678123456781234567812345678"
    local enc, k = c.encrypt("mUNC", key)
    return enc ~= nil and enc ~= "mUNC"
end)

test("crypt.hash", function()
    local c = crypt or (syn and syn.crypt)
    if type(c) ~= "table" then return false end
    local hashFn = c.hash or c.sha256
    if type(hashFn) ~= "function" then return false end
    return hashFn("mUNC") ~= nil
end)

test("readfile", function()
    if type(readfile) ~= "function" or type(writefile) ~= "function" then return false end
    local key = "munc_temp_" .. tostring(math.random(100, 999))
writefile(key, "data")
local content = readfile(key)
return content == "data"
end)
test("writefile", function()
if type(writefile) ~= "function" then return false end
local key = "munc_temp_w"
local ok = pcall(function() writefile(key, "test") end)
return ok
end)
test("appendfile", function()
if type(appendfile) ~= "function" or type(writefile) ~= "function" or type(readfile) ~= "function" then return false end
local key = "munc_temp_a"
writefile(key, "A")
appendfile(key, "B")
return readfile(key) == "AB"
end)
test("isfile / isfolder", function()
if type(isfile) ~= "function" or type(isfolder) ~= "function" or type(writefile) ~= "function" then return false end
writefile("munc_test_file", "1")
return isfile("munc_test_file") == true and isfolder("munc_test_file") == false
end)
test("makefolder", function()
if type(makefolder) ~= "function" or type(isfolder) ~= "function" then return false end
makefolder("munc_test_dir")
return isfolder("munc_test_dir") == true
end)
test("getinstances", function()
if type(getinstances) ~= "function" then return false end
local res = getinstances()
return type(res) == "table" and #res > 0
end)
test("getscripts", function()
if type(getscripts) ~= "function" then return false end
return type(getscripts()) == "table"
end)
test("getsenv", function()
if type(getsenv) ~= "function" then return false end
return true
end)
test("getscriptclosure", function()
return type(getscriptclosure) == "function" or type(getscriptfunction) == "function"
end)
test("setclipboard", function()
if type(setclipboard) ~= "function" then return false end
return pcall(function() setclipboard("mUNC") end)
end)
test("identifyexecutor", function()
if type(identifyexecutor) ~= "function" and type(getexecutorname) ~= "function" then return false end
local name = identifyexecutor or getexecutorname
return type(name()) == "string"
end)
test("decompile (Basic Check)", function()
return type(decompile) == "function" or type(Decompile) == "function"
end)
test("decompile (Functional Execution)", function()
local decomp = decompile or Decompile
if type(decomp) ~= "function" then return false end
local folder = Instance.new("Folder")
local scr = Instance.new("LocalScript", folder)
scr.Source = "print('mUNC')"
local sourceResult = decomp(scr)
scr:Destroy()
folder:Destroy()
return type(sourceResult) == "string" and #sourceResult > 0
end)
test("cloneref (Identity Spoofing)", function()
if type(cloneref) ~= "function" then return false end
local part = Instance.new("Part")
local clone = cloneref(part)
local isValid = (part ~= clone and part:GetDebugId() == clone:GetDebugId())
part:Destroy()
return isValid
end)
test("gethiddenproperty (Spoof Detection)", function()
if type(gethiddenproperty) ~= "function" and type(gethiddenproperties) ~= "function" then return false end
local f = gethiddenproperty or gethiddenproperties
local p = Instance.new("Part")
local s, r = pcall(function() return f(p, "Size") end)
p:Destroy()
return s
end)
test("sethiddenproperty (Spoof Write Check)", function()
if type(sethiddenproperty) ~= "function" then return false end
local p = Instance.new("Part")
local s = pcall(function() sethiddenproperty(p, "Size", Vector3.new(1,1,1)) end)
p:Destroy()
return s
end)
test("getcallbackvalue (Anti-Cheat Hook Audit)", function()
return type(getcallbackvalue) == "function" or type(getcallbackmember) == "function"
end)
test("compareinstances (Reference Spoofing Bypass)", function()
if type(compareinstances) ~= "function" then return false end
local p = Instance.new("Part")
local res = compareinstances(p, p)
p:Destroy()
return res == true
end)
test("checkcaller (Context Security Bypass)", function()
return type(checkcaller) == "function" and checkcaller() == true
end)
test("restorefunction (Metatable Reset)", function()
return type(restorefunction) == "function" or type(restoreclosure) == "function"
end)
local scorePercentage = math.round((passCount / totalCount) * 100)
local finalScoreMsg = string.format("Result: %d%%", scorePercentage)
print("=== mUNC Test Finished ===")
print(finalScoreMsg)
table.insert(reportLog, "=============================")
table.insert(reportLog, string.format("Final Capability Score: %d%% (%d/%d Tests passed)", scorePercentage, passCount, totalCount))
if type(writefile) == "function" then
pcall(function()
writefile("mUNC_Report.txt", table.concat(reportLog, "\n"))
print("💾 [mUNC] Saved to mUNC_Report.txt")
end)
end
