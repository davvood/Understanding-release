--[[
    Understanding  loader
    loadstring(game:HttpGet("https://raw.githubusercontent.com/davvood/Understanding-release/refs/heads/main/loader.lua"))()

    Verifies Discord membership and downloads the latest UnderstandingMenu.lua from the
    Understanding verification worker, with a native macOS/iOS loading sheet.
]]

local LOADER_URL = "https://raw.githubusercontent.com/davvood/Understanding-release/refs/heads/main/loader.lua"
local DISCORD_INVITE = "https://discord.gg/h4R9W7gT2H"
local DISCORD_INVITE_CODE = "h4R9W7gT2H"
local VERIFY_URL = "https://understanding-verify.understanding-menu.workers.dev" -- Cloudflare Worker URL for Discord verification & gated menu delivery

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
    wellHover = Color3.fromRGB(50, 50, 58), -- #32323A
    track = Color3.fromRGB(46, 46, 52), -- #2E2E34
    border = Color3.fromRGB(62, 62, 70), -- #3E3E46
    accent = Color3.fromRGB(10, 132, 255), -- macOS Blue #0A84FF
    accentHover = Color3.fromRGB(34, 148, 255),
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
    if not isfile then
        return nil
    end
    local okF, exists = pcall(isfile, file)
    if not (okF and exists) then
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
            if o:IsA("TextButton") then
                tween(o, dur * 0.9, { BackgroundTransparency = 1, TextTransparency = 1 }, Enum.EasingStyle.Quad)
            elseif o:IsA("TextLabel") then
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
        if token ~= uiToken or not gui or not gui.Parent then
            return
        end
        fadeOutUi(0.20)
        task.delay(0.24, function()
            if token == uiToken and gui and gui.Parent then
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
-- request() with 2xx status check first, then game:HttpGet if request() is missing or unavailable
local function httpGet(url, allowErrorBody)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if ok and type(res) == "table" then
            if type(res.StatusCode) == "number" and res.StatusCode > 0 then
                if
                    res.StatusCode >= 200
                    and res.StatusCode < 300
                    and res.Success ~= false
                    and type(res.Body) == "string"
                    and res.Body ~= ""
                then
                    return res.Body, res.StatusCode
                end
                if allowErrorBody and type(res.Body) == "string" and res.Body ~= "" then
                    return res.Body, res.StatusCode
                end
                return nil, res.StatusCode
            elseif res.StatusCode == nil and res.Success == true and type(res.Body) == "string" and res.Body ~= "" then
                return res.Body, 200
            end
        end
    end
    -- selene: allow(incorrect_standard_library_use) -- HttpGet is added by the executor
    local ok2, body = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok2 and type(body) == "string" and body ~= "" then
        return body, 200
    end
    return nil, nil
end

local function looksLikeMenu(src)
    return type(src) == "string" and #src > 1000 and src:find("UnderstandingDestroy", 1, true) ~= nil
end

local verifyBase = VERIFY_URL:gsub("/+$", "")
local latestSha = nil -- SHA of the menu served by the worker (lets the menu spot newer releases)

local function freshQuery()
    return "&t=" .. tostring(os.time()) .. tostring(math.random(1000, 9999))
end

local function fetchWorkerVersion()
    local body = httpGet(verifyBase .. "/version?t=" .. tostring(os.time()) .. tostring(math.random(1000, 9999)))
    if type(body) ~= "string" or body == "" then
        return nil
    end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
    if ok and type(data) == "table" and type(data.sha) == "string" and data.sha ~= "" then
        return data.sha
    end
    return nil
end

local function downloadMenuOnce()
    local url = verifyBase .. "/menu?userId=" .. tostring(lp.UserId) .. freshQuery()
    local body, statusCode = httpGet(url, true)
    if (statusCode == nil or (statusCode >= 200 and statusCode < 300)) and looksLikeMenu(body) then
        latestSha = fetchWorkerVersion()
        return body, "Server", nil
    end
    if type(body) == "string" and body ~= "" then
        local okJson, res = pcall(HttpService.JSONDecode, HttpService, body)
        if okJson and type(res) == "table" and type(res.reason) == "string" and res.reason ~= "" then
            return nil, nil, res.reason
        end
    end
    latestSha = nil
    return nil, nil, nil
end

-- ── Discord Membership Verification ──────────────────────
local function verifyDiscordMembership()
    if type(VERIFY_URL) ~= "string" or VERIFY_URL == "" then
        return true
    end

    local function queryDiscord()
        local body = httpGet(verifyBase .. "/check?userId=" .. tostring(lp.UserId) .. freshQuery())
        if not body then
            return false, "network"
        end
        local okJson, res = pcall(HttpService.JSONDecode, HttpService, body)
        if not okJson or type(res) ~= "table" or type(res.inDiscord) ~= "boolean" then
            return false, "network"
        end
        if res.inDiscord then
            return true, nil
        end
        local reason = type(res.reason) == "string" and res.reason ~= "" and res.reason or "not_linked"
        return false, reason
    end

    local function tryDiscordRpcInvite()
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        if not req or DISCORD_INVITE_CODE == "" then
            return
        end
        task.spawn(function()
            pcall(function()
                local nonce = tostring(os.time()) .. "-" .. tostring(math.random(10000, 99999))
                local okGuid, guid = pcall(HttpService.GenerateGUID, HttpService, false)
                if okGuid and type(guid) == "string" and guid ~= "" then
                    nonce = guid
                end
                req({
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["Origin"] = "https://discord.com",
                    },
                    Body = HttpService:JSONEncode({
                        cmd = "INVITE_BROWSER",
                        nonce = nonce,
                        args = { code = DISCORD_INVITE_CODE },
                    }),
                })
            end)
        end)
    end

    step("Checking Discord membership...", 0.12, "Discord")
    local verified, reason = queryDiscord()
    if verified then
        return true
    end

    ensureUi()
    local rpcSent = false
    if reason ~= "network" and reason ~= "blacklisted" then
        rpcSent = true
        tryDiscordRpcInvite()
    end

    local doneEvent = Instance.new("BindableEvent")
    local outcome = nil
    local function finish(res)
        if outcome ~= nil then
            return
        end
        outcome = res
        doneEvent:Fire()
    end

    local guardConns = {}
    if gui then
        pcall(function()
            table.insert(
                guardConns,
                gui.AncestryChanged:Connect(function()
                    if not gui or not gui.Parent then
                        finish("closed")
                    end
                end)
            )
        end)
    end

    local actionBar = nil
    local btnConns = {}
    local primaryBtn = nil
    local currentMode = nil
    local checking = false
    local copyToken = 0

    local function clearActions()
        for _, c in ipairs(btnConns) do
            pcall(c.Disconnect, c)
        end
        table.clear(btnConns)
        if actionBar then
            pcall(actionBar.Destroy, actionBar)
            actionBar = nil
        end
        primaryBtn = nil
        currentMode = nil
    end

    local function makeActionButton(parent, x, w, label, styleKind, onClick)
        local isPrimary = styleKind == "primary"
        local baseBg = isPrimary and COL.accent or COL.well
        local hoverBg = isPrimary and COL.accentHover or COL.wellHover
        local txtCol = isPrimary and Color3.new(1, 1, 1) or (styleKind == "close" and COL.dim or COL.txt)

        local btn = Instance.new("TextButton")
        btn.AutoButtonColor = false
        btn.Position = UDim2.fromOffset(x, 0)
        btn.Size = UDim2.fromOffset(w, 30)
        btn.BackgroundColor3 = baseBg
        btn.BackgroundTransparency = 1
        btn.BorderSizePixel = 0
        btn.Font = isPrimary and Enum.Font.BuilderSansBold or Enum.Font.BuilderSansMedium
        btn.TextSize = 12
        btn.TextColor3 = txtCol
        btn.TextTransparency = 1
        btn.Text = label
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.Parent = parent
        round(8, btn)

        if not isPrimary then
            local rim = Instance.new("UIStroke")
            rim.Color = COL.border
            rim.Thickness = 1
            rim.Transparency = 1
            rim.Parent = btn
            tween(rim, 0.18, { Transparency = styleKind == "close" and 0.45 or 0.35 }, Enum.EasingStyle.Quad)
        end

        tween(btn, 0.18, { BackgroundTransparency = 0, TextTransparency = 0 }, Enum.EasingStyle.Quad)

        table.insert(
            btnConns,
            btn.MouseEnter:Connect(function()
                if btn.Active and outcome == nil then
                    tween(btn, 0.12, { BackgroundColor3 = hoverBg }, Enum.EasingStyle.Quad)
                    if styleKind == "close" then
                        tween(btn, 0.12, { TextColor3 = COL.txt }, Enum.EasingStyle.Quad)
                    end
                end
            end)
        )
        table.insert(
            btnConns,
            btn.MouseLeave:Connect(function()
                if outcome == nil then
                    tween(btn, 0.14, { BackgroundColor3 = baseBg }, Enum.EasingStyle.Quad)
                    if styleKind == "close" then
                        tween(btn, 0.14, { TextColor3 = txtCol }, Enum.EasingStyle.Quad)
                    end
                end
            end)
        )
        table.insert(
            btnConns,
            btn.MouseButton1Click:Connect(function()
                if btn.Active and outcome == nil then
                    onClick(btn)
                end
            end)
        )
        return btn
    end

    local renderState
    local function runRecheck()
        if checking or outcome ~= nil then
            return
        end
        checking = true
        if primaryBtn and primaryBtn.Parent then
            primaryBtn.Active = false
            primaryBtn.Text = "Checking..."
            tween(primaryBtn, 0.12, { BackgroundTransparency = 0.45 }, Enum.EasingStyle.Quad)
        end
        if subLbl then
            subLbl.Text = "Checking..."
        end
        task.spawn(function()
            local okNow, nextReason = queryDiscord()
            if outcome ~= nil or not gui or not gui.Parent then
                return
            end
            if okNow then
                finish("verified")
                return
            end
            if nextReason ~= "network" and nextReason ~= "blacklisted" and not rpcSent then
                rpcSent = true
                tryDiscordRpcInvite()
            end
            checking = false
            local subText = nextReason == "network" and "Connection Error"
                or (nextReason == "blacklisted" and "Blacklisted" or "Not verified yet")
            local reused = renderState(nextReason, subText)
            if reused and primaryBtn and primaryBtn.Parent then
                primaryBtn.Active = true
                primaryBtn.Text = nextReason == "network" and "Retry" or "Check Again"
                tween(primaryBtn, 0.14, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad)
            end
        end)
    end

    renderState = function(stateReason, subOverride)
        local isError = stateReason == "network"
        local isBlacklisted = stateReason == "blacklisted"
        local msg
        if isBlacklisted then
            msg = "You have been blacklisted from using Understanding."
        elseif isError then
            msg =
                "Couldn't reach the verification server.\nCheck your connection or executor permissions, then click Retry."
        elseif stateReason == "not_in_server" then
            msg = "You aren't in the Understanding Discord server.\nRejoin, then click Check Again."
        else
            msg = "Join the Understanding Discord server and run:\n/verify " .. lp.Name .. "\nthen click Check Again."
        end

        local textH = measureStatusHeight(msg)
        local btnY = 96 + textH + 10
        local cardH = math.max(196, btnY + 30 + 30)

        status.Size = UDim2.fromOffset(304, textH)
        status.TextTruncate = textH >= 240 and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
        if isError or isBlacklisted then
            status.TextColor3 = COL.red
            pctLbl.TextColor3 = COL.red
            fill.BackgroundColor3 = COL.red
            if cardStroke then
                tween(cardStroke, 0.22, { Color = COL.red, Transparency = 0.45 })
            end
            step(msg, 0.12, subOverride or (isBlacklisted and "Blacklisted" or "Connection Error"))
        else
            status.TextColor3 = COL.txt
            pctLbl.TextColor3 = COL.accent
            fill.BackgroundColor3 = COL.accent
            if cardStroke then
                tween(cardStroke, 0.22, { Color = COL.border, Transparency = 0 })
            end
            step(msg, 0.12, subOverride or "Discord Required")
        end

        tween(card, 0.22, { Size = UDim2.fromOffset(340, cardH) })

        local targetMode = isBlacklisted and "blacklisted" or (isError and "error" or "verify")
        if actionBar and actionBar.Parent and currentMode == targetMode then
            tween(actionBar, 0.22, { Position = UDim2.fromOffset(18, btnY) })
            return true
        end

        clearActions()
        currentMode = targetMode
        actionBar = Instance.new("Frame")
        actionBar.Name = "VerifyActions"
        actionBar.Position = UDim2.fromOffset(18, btnY)
        actionBar.Size = UDim2.fromOffset(304, 30)
        actionBar.BackgroundTransparency = 1
        actionBar.BorderSizePixel = 0
        actionBar.Parent = card

        if isBlacklisted then
            makeActionButton(actionBar, 0, 304, "Close", "close", function()
                finish("closed")
            end)
        elseif isError then
            primaryBtn = makeActionButton(actionBar, 0, 148, "Retry", "primary", runRecheck)
            makeActionButton(actionBar, 156, 148, "Close", "close", function()
                finish("closed")
            end)
        else
            makeActionButton(actionBar, 0, 100, "Copy Invite", "secondary", function(copyBtn)
                copyToken += 1
                local tok = copyToken
                local copied = setclipboard and pcall(setclipboard, DISCORD_INVITE)
                copyBtn.Text = copied and "Copied!" or "Unavailable"
                task.delay(1.6, function()
                    if tok == copyToken and copyBtn.Parent and outcome == nil then
                        copyBtn.Text = "Copy Invite"
                    end
                end)
            end)
            primaryBtn = makeActionButton(actionBar, 108, 114, "Check Again", "primary", runRecheck)
            makeActionButton(actionBar, 230, 74, "Close", "close", function()
                finish("closed")
            end)
        end
        return false
    end

    renderState(reason, nil)

    while outcome == nil do
        if not gui or not gui.Parent then
            outcome = "closed"
            break
        end
        doneEvent.Event:Wait()
    end

    for _, c in ipairs(guardConns) do
        pcall(c.Disconnect, c)
    end
    pcall(doneEvent.Destroy, doneEvent)

    if outcome ~= "verified" then
        for _, c in ipairs(btnConns) do
            pcall(c.Disconnect, c)
        end
        table.clear(btnConns)
        close(0)
        return false
    end

    clearActions()
    if status then
        status.TextColor3 = COL.dim
        status.Size = UDim2.fromOffset(304, 34)
        status.TextTruncate = Enum.TextTruncate.None
    end
    if pctLbl then
        pctLbl.TextColor3 = COL.dim
    end
    if fill then
        fill.BackgroundColor3 = COL.accent
    end
    if cardStroke then
        tween(cardStroke, 0.22, { Color = COL.border, Transparency = 0 })
    end
    if card then
        tween(card, 0.22, { Size = UDim2.fromOffset(340, 160) })
    end
    return true
end

if not verifyDiscordMembership() then
    return
end

step("Downloading menu...", 0.25, "Server")
local src, source, denyReason = downloadMenuOnce()
if not src and denyReason ~= "blacklisted" then
    for attempt = 1, 2 do
        step("Retrying download (" .. attempt .. "/2)...", 0.25 + attempt * 0.15, "Retrying")
        task.wait(0.8)
        src, source, denyReason = downloadMenuOnce()
        if src or denyReason == "blacklisted" then
            break
        end
    end
end
if denyReason == "blacklisted" then
    return fail("You have been blacklisted from using Understanding.")
end
if not src then
    return fail("Couldn't download the menu from the server. Try again in a moment.")
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

_G._UnderstandingLoader = nil -- never bypass loader on teleport
_G._UnderstandingLoaderScript = LOADER_URL -- teleports re-run this loader (verification + card)
_G._UnderstandingSha = latestSha
local ok, runErr = pcall(fn)
if not ok then
    return fail("Menu crashed while starting: " .. tostring(runErr))
end
