--[[
    Understanding  loader
    loadstring(game:HttpGet("https://raw.githubusercontent.com/davvood/Understanding-release/refs/heads/main/loader.lua"))()

    Downloads the latest UnderstandingMenu.lua from GitHub and runs it, with a small loading card.
    If GitHub can't be reached it uses the last downloaded copy (Understanding_cache.lua), then a
    copy you put in the executor workspace yourself (UnderstandingMenu.lua).
]]

local RAW = "https://raw.githubusercontent.com/davvood/Understanding-release/"
local BASE = RAW .. "refs/heads/main/"
local MENU_URL = BASE .. "UnderstandingMenu.lua"
local LOADER_URL = BASE .. "loader.lua"
-- Branch links are cached by GitHub for up to 5 minutes after a publish; links pinned to a
-- commit are always exact. This API call says which commit is newest (cached ~1 minute).
local LATEST_COMMIT_API = "https://api.github.com/repos/davvood/Understanding-release/commits/main"
local CACHE_FILE = "Understanding_cache.lua"
local LOCAL_FILE = "UnderstandingMenu.lua"

-- After a teleport this runs as soon as the new server starts: wait until the game has loaded
if not game:IsLoaded() then
    game.Loaded:Wait()
end
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
while not Players.LocalPlayer do
    task.wait()
end
local lp = Players.LocalPlayer

-- ── Loading card ─────────────────────────────────────────
local COL = {
    bg = Color3.fromRGB(17, 17, 22),
    track = Color3.fromRGB(12, 12, 15),
    border = Color3.fromRGB(40, 40, 52),
    accent = Color3.fromRGB(108, 82, 230),
    txt = Color3.fromRGB(232, 232, 240),
    dim = Color3.fromRGB(128, 128, 145),
    red = Color3.fromRGB(220, 90, 90),
}

local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end
local function round(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
end

local gui = Instance.new("ScreenGui")
gui.Name = "UL" .. tostring(math.random(1000, 9999))
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 101
gui.Parent = lp:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.5)
card.Size = UDim2.fromOffset(300, 108)
card.BackgroundColor3 = COL.bg
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.Parent = gui
round(10, card)
local cardStroke = Instance.new("UIStroke")
cardStroke.Color = COL.border
cardStroke.Transparency = 1
cardStroke.Parent = card
local scale = Instance.new("UIScale")
scale.Scale = 0.92
scale.Parent = card

local function label(text, size, font, col, y)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = UDim2.fromOffset(20, y)
    l.Size = UDim2.new(1, -40, 0, size + 4)
    l.Font = font
    l.TextSize = size
    l.TextColor3 = col
    l.TextTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    l.Parent = card
    return l
end

local dot = Instance.new("Frame")
dot.Size = UDim2.fromOffset(8, 8)
dot.Position = UDim2.fromOffset(20, 24)
dot.BackgroundColor3 = COL.accent
dot.BackgroundTransparency = 1
dot.BorderSizePixel = 0
dot.Parent = card
round(4, dot)

local title = label("Understanding", 16, Enum.Font.GothamBold, COL.txt, 18)
title.Position = UDim2.fromOffset(36, 18)
local status = label("Starting...", 12, Enum.Font.Gotham, COL.dim, 48)

local track = Instance.new("Frame")
track.Position = UDim2.new(0, 20, 1, -24)
track.Size = UDim2.new(1, -40, 0, 4)
track.BackgroundColor3 = COL.track
track.BackgroundTransparency = 1
track.BorderSizePixel = 0
track.Parent = card
round(2, track)
local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = COL.accent
fill.BorderSizePixel = 0
fill.Parent = track
round(2, fill)

-- Fade in
tween(card, 0.25, { BackgroundTransparency = 0 })
tween(cardStroke, 0.25, { Transparency = 0 })
tween(scale, 0.25, { Scale = 1 })
tween(dot, 0.25, { BackgroundTransparency = 0 })
tween(track, 0.25, { BackgroundTransparency = 0 })
tween(title, 0.25, { TextTransparency = 0 })
tween(status, 0.25, { TextTransparency = 0 })

local function step(text, pct)
    status.Text = text
    tween(fill, 0.3, { Size = UDim2.fromScale(pct, 1) })
end

local function close(delay)
    task.delay(delay or 0, function()
        tween(card, 0.2, { BackgroundTransparency = 1 })
        tween(cardStroke, 0.2, { Transparency = 1 })
        tween(scale, 0.2, { Scale = 0.95 })
        for _, o in ipairs(card:GetDescendants()) do
            if o:IsA("TextLabel") then
                tween(o, 0.2, { TextTransparency = 1 })
            elseif o:IsA("Frame") then
                tween(o, 0.2, { BackgroundTransparency = 1 })
            end
        end
        task.delay(0.25, function()
            gui:Destroy()
        end)
    end)
end

local function fail(msg)
    status.TextColor3 = COL.red
    fill.BackgroundColor3 = COL.red
    step(msg, 1)
    warn("[Understanding loader] " .. msg)
    close(6)
end

-- ── Download ─────────────────────────────────────────────
-- game:HttpGet first, then the executor's request() if HttpGet is missing or fails
local function httpGet(url)
    -- selene: allow(incorrect_standard_library_use) -- HttpGet is added by the executor
    local ok, body = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and type(body) == "string" and body ~= "" then
        return body
    end
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok2, res = pcall(req, { Url = url, Method = "GET" })
        if ok2 and type(res) == "table" and res.StatusCode == 200 and type(res.Body) == "string" then
            return res.Body
        end
    end
    return nil
end

-- Menu link pinned to the newest commit, or the branch link if the API can't be reached
local function freshMenuUrl()
    local body = httpGet(LATEST_COMMIT_API)
    local ok, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if ok and type(data) == "table" and type(data.sha) == "string" and #data.sha == 40 then
        return RAW .. data.sha .. "/UnderstandingMenu.lua"
    end
    return MENU_URL
end

local function looksLikeMenu(src)
    return type(src) == "string" and #src > 1000 and src:find("UnderstandingDestroy", 1, true) ~= nil
end

local function readLocal(file)
    local ok, src = pcall(function()
        return isfile and isfile(file) and readfile(file)
    end)
    return ok and looksLikeMenu(src) and src or nil
end

step("Downloading menu...", 0.25)
local src, source = nil, nil
for attempt = 1, 3 do
    local body = httpGet(freshMenuUrl())
    if looksLikeMenu(body) then
        src, source = body, "GitHub"
        break
    end
    if attempt < 3 then
        step("Download failed, retrying (" .. attempt .. "/2)...", 0.25)
        task.wait(1.5)
    end
end

if src then
    pcall(writefile, CACHE_FILE, src) -- offline fallback for next time
else
    src = readLocal(CACHE_FILE)
    source = src and "cached copy (GitHub unreachable)"
    if not src then
        src = readLocal(LOCAL_FILE)
        source = src and "workspace copy (GitHub unreachable)"
    end
end
if not src then
    return fail("Couldn't download the menu and no saved copy was found.")
end

local version = src:match("Understanding%s+(v[%d%.]+)") or src:match("['\"](v%d+%.%d+)") or "?"
step("Starting " .. version .. " from " .. source .. "...", 0.7)

-- ── Run ──────────────────────────────────────────────────
local fn, compileErr = loadstring(src)
if not fn then
    return fail("Menu failed to compile: " .. tostring(compileErr))
end
_G._UnderstandingLoader = MENU_URL -- fallback for teleports
_G._UnderstandingLoaderScript = LOADER_URL -- teleports re-run this loader (card, retries, visible errors)
local ok, runErr = pcall(fn)
if not ok then
    return fail("Menu crashed while starting: " .. tostring(runErr))
end

step("Loaded " .. version .. "  ·  press C to toggle", 1)
close(1.2)
