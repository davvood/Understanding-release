--[[
    Understanding  loader
    loadstring(game:HttpGet("https://raw.githubusercontent.com/davvood/Understanding-release/refs/heads/main/loader.lua"))()

    Downloads the latest UnderstandingMenu.lua from GitHub and runs it, with a native iOS loading sheet.
    If GitHub can't be reached it uses the last downloaded copy (Understanding_cache.lua), then a
    copy you put in the executor workspace yourself (UnderstandingMenu.lua).
]]

local RAW = "https://raw.githubusercontent.com/davvood/Understanding-release/"
local BASE = RAW .. "refs/heads/main/"
local MENU_URL = BASE .. "UnderstandingMenu.lua"
local LOADER_URL = BASE .. "loader.lua"
-- Branch links are cached by GitHub for up to 5 minutes after a publish; links pinned to a
-- commit are always exact. This API call says which commit is newest. Its answer may be cached
-- for a minute (also by Roblox itself, which is why a reload right after a release used to give
-- the old version), so every request gets a different "?t=" ending: nothing can answer it from a cache.
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
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
while not Players.LocalPlayer do
    task.wait()
end
local lp = Players.LocalPlayer
local playerGui = lp:WaitForChild("PlayerGui")

-- ── macOS Sheet Palette ──────────────────────────────────
local COL = {
    surface = Color3.fromRGB(24, 24, 28), -- #18181C
    well = Color3.fromRGB(38, 38, 44), -- #26262C
    track = Color3.fromRGB(46, 46, 52), -- #2E2E34
    border = Color3.fromRGB(62, 62, 70), -- #3E3E46
    accent = Color3.fromRGB(10, 132, 255), -- macOS Blue #0A84FF
    green = Color3.fromRGB(48, 209, 88), -- #30D158
    red = Color3.fromRGB(255, 69, 58), -- #FF453A
    txt = Color3.fromRGB(246, 246, 250),
    dim = Color3.fromRGB(152, 152, 160), -- #9898A0
    tlRed = Color3.fromRGB(255, 95, 86), -- #FF5F56
    tlYellow = Color3.fromRGB(255, 189, 46), -- #FFBD2E
    tlGreen = Color3.fromRGB(39, 201, 63), -- #27C93F
}

-- ── Tracked Tween Manager ────────────────────────────────
local activeTweens = {}

local function removeTweenEntry(entry)
    if entry.done then
        return
    end
    entry.done = true
    local perObj = activeTweens[entry.obj]
    if perObj then
        for prop in pairs(entry.props) do
            if perObj[prop] == entry then
                perObj[prop] = nil
            end
        end
        if next(perObj) == nil then
            activeTweens[entry.obj] = nil
        end
    end
    if entry.conn then
        pcall(entry.conn.Disconnect, entry.conn)
        entry.conn = nil
    end
    pcall(entry.tw.Destroy, entry.tw)
end

local function cancelPropTweens(obj, props)
    local perObj = activeTweens[obj]
    if not perObj then
        return
    end
    for prop in pairs(props) do
        local old = perObj[prop]
        if old and not old.done then
            old.done = true
            for p in pairs(old.props) do
                if perObj[p] == old then
                    perObj[p] = nil
                end
            end
            if old.conn then
                pcall(old.conn.Disconnect, old.conn)
                old.conn = nil
            end
            pcall(old.tw.Cancel, old.tw)
            pcall(old.tw.Destroy, old.tw)
        end
    end
    if next(perObj) == nil then
        activeTweens[obj] = nil
    end
end

local function tween(obj, t, props, style, dir)
    if not obj then
        return nil
    end
    cancelPropTweens(obj, props)
    local info = TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local ok, tw = pcall(TweenService.Create, TweenService, obj, info, props)
    if not ok or not tw then
        return nil
    end
    local perObj = activeTweens[obj]
    if not perObj then
        perObj = {}
        activeTweens[obj] = perObj
    end
    local entry = { tw = tw, obj = obj, props = props, conn = nil, done = false }
    for prop in pairs(props) do
        perObj[prop] = entry
    end
    local okConn, conn = pcall(function()
        return tw.Completed:Connect(function()
            removeTweenEntry(entry)
        end)
    end)
    if okConn then
        entry.conn = conn
    end
    tw:Play()
    return tw
end

local function destroyAllTweens()
    local seen = {}
    for obj, perObj in pairs(activeTweens) do
        activeTweens[obj] = nil
        for _, entry in pairs(perObj) do
            if not seen[entry] then
                seen[entry] = true
                entry.done = true
                if entry.conn then
                    pcall(entry.conn.Disconnect, entry.conn)
                    entry.conn = nil
                end
                pcall(entry.tw.Cancel, entry.tw)
                pcall(entry.tw.Destroy, entry.tw)
            end
        end
    end
end

local function round(r, p, scaleRadius)
    local c = Instance.new("UICorner")
    c.CornerRadius = scaleRadius and UDim.new(scaleRadius, 0) or UDim.new(0, r)
    c.Parent = p
    return c
end

local function cleanupOrphans()
    pcall(function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child.Name == "UnderstandingLoaderBlur" then
                child:Destroy()
            end
        end
    end)
    pcall(function()
        for _, child in ipairs(playerGui:GetChildren()) do
            if child:GetAttribute("UnderstandingLoader") == true then
                child:Destroy()
            end
        end
    end)
end

local function resolveLogoAsset(file)
    if not (isfile and isfile(file)) then
        return nil
    end
    local loaders = {}
    if type(getcustomasset) == "function" then
        table.insert(loaders, getcustomasset)
    end
    -- selene: allow(undefined_variable)
    local globalSynAsset = getsynasset
    if type(globalSynAsset) == "function" then
        table.insert(loaders, globalSynAsset)
    elseif type(syn) == "table" and type(syn.getsynasset) == "function" then
        table.insert(loaders, syn.getsynasset)
    end
    for _, loaderFn in ipairs(loaders) do
        local ok, id = pcall(loaderFn, file)
        if ok and type(id) == "string" and id ~= "" then
            return id
        end
    end
    return nil
end

-- ── macOS Loader Sheet UI ────────────────────────────────
local uiToken = 0
local blurFx = nil
local gui, scrim, card, cardStroke, scale = nil, nil, nil, nil, nil
local subLbl, status, pctLbl, fill = nil, nil, nil, nil

local function createUi()
    cleanupOrphans()
    uiToken += 1

    local okBlur, fx = pcall(function()
        local b = Instance.new("BlurEffect")
        b.Name = "UnderstandingLoaderBlur"
        b.Size = 0
        b.Parent = Lighting
        return b
    end)
    if okBlur and fx then
        blurFx = fx
        tween(fx, 0.24, { Size = 10 }, Enum.EasingStyle.Quad)
    end

    gui = Instance.new("ScreenGui")
    gui.Name = "UL" .. tostring(math.random(1000, 9999))
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 101
    gui:SetAttribute("UnderstandingLoader", true)
    gui.Parent = playerGui

    scrim = Instance.new("Frame")
    scrim.Size = UDim2.fromScale(1, 1)
    scrim.BackgroundColor3 = Color3.new(0, 0, 0)
    scrim.BackgroundTransparency = 1
    scrim.BorderSizePixel = 0
    scrim.ZIndex = 1
    scrim.Parent = gui

    card = Instance.new("Frame")
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.Size = UDim2.fromOffset(340, 160)
    card.BackgroundColor3 = COL.surface
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ZIndex = 2
    card.Parent = gui
    round(18, card)

    cardStroke = Instance.new("UIStroke")
    cardStroke.Color = COL.border
    cardStroke.Thickness = 1
    cardStroke.Transparency = 1
    cardStroke.Parent = card

    scale = Instance.new("UIScale")
    scale.Scale = 0.92
    scale.Parent = card

    local fadeTargets = {
        { scrim, "BackgroundTransparency", 0.50 },
        { card, "BackgroundTransparency", 0 },
        { cardStroke, "Transparency", 0 },
    }

    -- Top-left macOS traffic light dots + subtle titlebar hairline
    for idx, dotCol in ipairs({ COL.tlRed, COL.tlYellow, COL.tlGreen }) do
        local dot = Instance.new("Frame")
        dot.Position = UDim2.fromOffset(14 + (idx - 1) * 16, 11)
        dot.Size = UDim2.fromOffset(10, 10)
        dot.BackgroundColor3 = dotCol
        dot.BackgroundTransparency = 1
        dot.BorderSizePixel = 0
        dot.Parent = card
        round(0, dot, 0.5)
        table.insert(fadeTargets, { dot, "BackgroundTransparency", 0 })
        local dotRim = Instance.new("UIStroke")
        dotRim.Color = Color3.new(0, 0, 0)
        dotRim.Thickness = 1
        dotRim.Transparency = 1
        dotRim.Parent = dot
        table.insert(fadeTargets, { dotRim, "Transparency", 0.72 })
    end

    local barSep = Instance.new("Frame")
    barSep.Position = UDim2.fromOffset(0, 32)
    barSep.Size = UDim2.new(1, 0, 0, 1)
    barSep.BackgroundColor3 = COL.border
    barSep.BackgroundTransparency = 1
    barSep.BorderSizePixel = 0
    barSep.Parent = card
    table.insert(fadeTargets, { barSep, "BackgroundTransparency", 0.65 })

    local badge = Instance.new("Frame")
    badge.Position = UDim2.fromOffset(18, 44)
    badge.Size = UDim2.fromOffset(40, 40)
    badge.BackgroundColor3 = COL.accent
    badge.BackgroundTransparency = 1
    badge.BorderSizePixel = 0
    badge.Parent = card
    round(10, badge)

    local logoId = resolveLogoAsset("Understanding_logo_v2.png")
    if logoId then
        local im = Instance.new("ImageLabel")
        im.Size = UDim2.fromScale(1, 1)
        im.BackgroundTransparency = 1
        im.Image = logoId
        im.ImageTransparency = 1
        im.ScaleType = Enum.ScaleType.Fit
        im.Parent = badge
        round(10, im)
        table.insert(fadeTargets, { im, "ImageTransparency", 0 })
    else
        local badgeLbl = Instance.new("TextLabel")
        badgeLbl.Size = UDim2.fromScale(1, 1)
        badgeLbl.BackgroundTransparency = 1
        badgeLbl.Font = Enum.Font.BuilderSansBold
        badgeLbl.TextSize = 18
        badgeLbl.TextColor3 = Color3.new(1, 1, 1)
        badgeLbl.TextTransparency = 1
        badgeLbl.Text = "U"
        badgeLbl.Parent = badge
        table.insert(fadeTargets, { badge, "BackgroundTransparency", 0 })
        table.insert(fadeTargets, { badgeLbl, "TextTransparency", 0 })
    end

    local function makeLabel(text, size, font, col, x, y, w, h, xa)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Position = UDim2.fromOffset(x, y)
        l.Size = UDim2.fromOffset(w, h)
        l.Font = font
        l.TextSize = size
        l.TextColor3 = col
        l.TextTransparency = 1
        l.TextXAlignment = xa or Enum.TextXAlignment.Left
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.Text = text
        l.Parent = card
        table.insert(fadeTargets, { l, "TextTransparency", 0 })
        return l
    end

    makeLabel("Understanding", 15, Enum.Font.BuilderSansBold, COL.txt, 70, 45, 186, 20)
    subLbl = makeLabel("Preparing...", 12, Enum.Font.BuilderSansMedium, COL.dim, 70, 65, 186, 16)

    local pctPill = Instance.new("Frame")
    pctPill.AnchorPoint = Vector2.new(1, 0)
    pctPill.Position = UDim2.new(1, -18, 0, 53)
    pctPill.Size = UDim2.fromOffset(48, 22)
    pctPill.BackgroundColor3 = COL.well
    pctPill.BackgroundTransparency = 1
    pctPill.BorderSizePixel = 0
    pctPill.Parent = card
    round(0, pctPill, 0.5)
    table.insert(fadeTargets, { pctPill, "BackgroundTransparency", 0 })

    local pctStroke = Instance.new("UIStroke")
    pctStroke.Color = COL.border
    pctStroke.Thickness = 1
    pctStroke.Transparency = 1
    pctStroke.Parent = pctPill
    table.insert(fadeTargets, { pctStroke, "Transparency", 0.45 })

    pctLbl = Instance.new("TextLabel")
    pctLbl.Size = UDim2.fromScale(1, 1)
    pctLbl.BackgroundTransparency = 1
    pctLbl.Font = Enum.Font.BuilderSansMedium
    pctLbl.TextSize = 11
    pctLbl.TextColor3 = COL.dim
    pctLbl.TextTransparency = 1
    pctLbl.TextXAlignment = Enum.TextXAlignment.Center
    pctLbl.Text = "0%"
    pctLbl.Parent = pctPill
    table.insert(fadeTargets, { pctLbl, "TextTransparency", 0 })

    status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position = UDim2.fromOffset(18, 96)
    status.Size = UDim2.fromOffset(304, 34)
    status.Font = Enum.Font.BuilderSans
    status.TextSize = 12
    status.TextColor3 = COL.dim
    status.TextTransparency = 1
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextYAlignment = Enum.TextYAlignment.Top
    status.TextWrapped = true
    status.ClipsDescendants = true
    status.Text = "Starting..."
    status.Parent = card
    table.insert(fadeTargets, { status, "TextTransparency", 0 })

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 18, 1, -20)
    track.Size = UDim2.new(1, -36, 0, 4)
    track.BackgroundColor3 = COL.track
    track.BackgroundTransparency = 1
    track.BorderSizePixel = 0
    track.Parent = card
    round(0, track, 0.5)
    table.insert(fadeTargets, { track, "BackgroundTransparency", 0 })

    fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = COL.accent
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    fill.Parent = track
    round(0, fill, 0.5)
    table.insert(fadeTargets, { fill, "BackgroundTransparency", 0 })

    tween(scale, 0.28, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    for _, item in ipairs(fadeTargets) do
        tween(item[1], 0.22, { [item[2]] = item[3] }, Enum.EasingStyle.Quad)
    end
end

local function ensureUi()
    if not gui or not gui.Parent then
        createUi()
    end
end

local function fadeOutUi(dur)
    if blurFx then
        tween(blurFx, dur, { Size = 0 }, Enum.EasingStyle.Quad)
    end
    if scrim then
        tween(scrim, dur, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
    end
    if card then
        tween(card, dur, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
        if cardStroke then
            tween(cardStroke, dur, { Transparency = 1 }, Enum.EasingStyle.Quad)
        end
        if scale then
            tween(scale, dur, { Scale = 0.94 }, Enum.EasingStyle.Quad)
        end
        for _, o in ipairs(card:GetDescendants()) do
            if o:IsA("TextLabel") then
                tween(o, dur * 0.9, { TextTransparency = 1 }, Enum.EasingStyle.Quad)
            elseif o:IsA("ImageLabel") then
                tween(o, dur * 0.9, { ImageTransparency = 1 }, Enum.EasingStyle.Quad)
            elseif o:IsA("UIStroke") then
                tween(o, dur * 0.9, { Transparency = 1 }, Enum.EasingStyle.Quad)
            elseif o:IsA("Frame") then
                tween(o, dur * 0.9, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
            end
        end
    end
end

local function teardownUi()
    uiToken += 1
    destroyAllTweens()
    if blurFx then
        pcall(blurFx.Destroy, blurFx)
        blurFx = nil
    end
    pcall(function()
        for _, child in ipairs(Lighting:GetChildren()) do
            if child.Name == "UnderstandingLoaderBlur" then
                child:Destroy()
            end
        end
    end)
    if gui then
        pcall(gui.Destroy, gui)
        gui = nil
    end
    scrim, card, cardStroke, scale = nil, nil, nil, nil
    subLbl, status, pctLbl, fill = nil, nil, nil, nil
end

local function dismissBeforeLaunch()
    if not gui and not blurFx then
        return
    end
    fadeOutUi(0.18)
    task.wait(0.20)
    teardownUi()
end

local function step(text, pct, sub)
    local clamped = math.clamp(pct or 0, 0, 1)
    if status then
        status.Text = text
    end
    if pctLbl then
        pctLbl.Text = math.floor(clamped * 100 + 0.5) .. "%"
    end
    if sub and subLbl then
        subLbl.Text = sub
    end
    if fill then
        tween(fill, 0.24, { Size = UDim2.fromScale(clamped, 1) })
    end
end

local function close(delay)
    local token = uiToken
    task.delay(delay or 0, function()
        if token ~= uiToken then
            return
        end
        fadeOutUi(0.20)
        task.delay(0.24, function()
            if token == uiToken then
                teardownUi()
            end
        end)
    end)
end

local function measureStatusHeight(msg)
    local h = 0
    local ok, bounds = pcall(function()
        return TextService:GetTextSize(msg, 12, Enum.Font.BuilderSans, Vector2.new(304, 360))
    end)
    if ok and bounds and bounds.Y > 0 then
        h = math.ceil(bounds.Y) + 4
    else
        local lines = 0
        for line in (msg .. "\n"):gmatch("([^\n]*)\n") do
            lines += math.max(1, math.ceil(#line / 44))
        end
        h = lines * 16 + 4
    end
    return math.clamp(h, 34, 240)
end

local function fail(msg)
    ensureUi()
    local errText = tostring(msg)
    local textH = measureStatusHeight(errText)
    local cardH = math.max(160, 96 + textH + 34)
    status.TextColor3 = COL.red
    status.Size = UDim2.fromOffset(304, textH)
    if textH >= 240 then
        status.TextTruncate = Enum.TextTruncate.AtEnd
    else
        status.TextTruncate = Enum.TextTruncate.None
    end
    pctLbl.TextColor3 = COL.red
    fill.BackgroundColor3 = COL.red
    if cardStroke then
        tween(cardStroke, 0.22, { Color = COL.red, Transparency = 0.45 })
    end
    tween(card, 0.22, { Size = UDim2.fromOffset(340, cardH) })
    step(errText, 1, "Failed to start")
    warn("[Understanding loader] " .. errText)
    close(6)
end

createUi()

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
        if ok2 and type(res) == "table" and type(res.Body) == "string" and res.Body ~= "" then
            local statusOk = (res.StatusCode == nil and res.Success == true)
                or (
                    type(res.StatusCode) == "number"
                    and res.StatusCode >= 200
                    and res.StatusCode < 300
                    and res.Success ~= false
                )
            if statusOk then
                return res.Body
            end
        end
    end
    return nil
end

local function looksLikeMenu(src)
    return type(src) == "string" and #src > 1000 and src:find("UnderstandingDestroy", 1, true) ~= nil
end

-- Single fast pass: API latest commit SHA -> Atom feed fallback -> pinned raw fetch -> raw/main cache-busted fetch
local LATEST_COMMIT_ATOM = "https://github.com/davvood/Understanding-release/commits/main.atom"
local latestSha = nil -- commit the menu was downloaded from (lets the menu spot newer releases)
local function downloadMenuOnce()
    local fresh = "?t=" .. tostring(os.time()) .. tostring(math.random(1000, 9999))
    local sha = nil
    local apiBody = httpGet(LATEST_COMMIT_API .. fresh)
    if apiBody then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(apiBody)
        end)
        if ok and type(data) == "table" and type(data.sha) == "string" and #data.sha == 40 then
            sha = data.sha
        end
    end
    if not sha then
        local atomBody = httpGet(LATEST_COMMIT_ATOM .. fresh)
        local atomSha = type(atomBody) == "string" and atomBody:match("<entry>.-Grit::Commit/(%x+)") or nil
        if type(atomSha) == "string" and #atomSha == 40 then
            sha = atomSha
        end
    end
    if sha then
        latestSha = sha
        local pinnedBody = httpGet(RAW .. sha .. "/UnderstandingMenu.lua")
        if looksLikeMenu(pinnedBody) then
            return pinnedBody, "GitHub"
        end
    end
    latestSha = nil
    local mainBody = httpGet(MENU_URL .. fresh)
    if looksLikeMenu(mainBody) then
        return mainBody, "GitHub"
    end
    return nil, nil
end

local function readLocal(file)
    local ok, src = pcall(function()
        return isfile and readfile and isfile(file) and readfile(file)
    end)
    return ok and looksLikeMenu(src) and src or nil
end

local function readOfflineFallback()
    local cached = readLocal(CACHE_FILE)
    if cached then
        return cached, "cached copy (GitHub unreachable)"
    end
    local localCopy = readLocal(LOCAL_FILE)
    if localCopy then
        return localCopy, "workspace copy (GitHub unreachable)"
    end
    return nil, nil
end

step("Downloading menu...", 0.25, "GitHub")
local src, source = downloadMenuOnce()
if src then
    if writefile then
        pcall(writefile, CACHE_FILE, src) -- offline fallback for next time
    end
else
    src, source = readOfflineFallback()
    if not src then
        -- Only retry when no offline fallback copy exists on disk yet
        for attempt = 1, 2 do
            step("Retrying download (" .. attempt .. "/2)...", 0.25 + attempt * 0.15, "Retrying")
            task.wait(0.8)
            src, source = downloadMenuOnce()
            if src then
                if writefile then
                    pcall(writefile, CACHE_FILE, src)
                end
                break
            end
        end
    end
end
if not src then
    return fail("Couldn't download the menu and no saved copy was found.")
end

local version = src:match("Understanding%s+(v[%d%.]+)") or src:match("['\"](v%d+[%d%.]+)") or "?"
step("Starting " .. version .. " (" .. source .. ")...", 0.78, version)

-- ── Run ──────────────────────────────────────────────────
local fn, compileErr = loadstring(src)
if not fn then
    return fail("Menu failed to compile: " .. tostring(compileErr))
end

tween(fill, 0.18, { BackgroundColor3 = COL.green }, Enum.EasingStyle.Quad)
tween(pctLbl, 0.18, { TextColor3 = COL.green }, Enum.EasingStyle.Quad)
step("Loaded " .. version .. "  ·  press C to toggle", 1, version)
task.wait(0.24)
dismissBeforeLaunch()

_G._UnderstandingLoader = MENU_URL -- fallback for teleports
_G._UnderstandingLoaderScript = LOADER_URL -- teleports re-run this loader (card, retries, visible errors)
_G._UnderstandingSha = source == "GitHub" and latestSha or nil
local ok, runErr = pcall(fn)
if not ok then
    return fail("Menu crashed while starting: " .. tostring(runErr))
end
