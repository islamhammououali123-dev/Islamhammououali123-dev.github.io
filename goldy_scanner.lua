-- goldy_scanner.lua
-- Safe MM2 scanner. Black UI, one COPY button.
-- Yields between modules so Roblox does not freeze.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("badtrip_scan") then
    PlayerGui.badtrip_scan:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "badtrip_scan"
sg.ResetOnSpawn = false
sg.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 150)
frame.Position = UDim2.new(0.5, -130, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = sg

local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 8) fc.Parent = frame
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(255, 200, 40) fs.Thickness = 1.4 fs.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
title.BorderSizePixel = 0
title.Text = "badtrip | goldy id grabber"
title.TextColor3 = Color3.fromRGB(255, 215, 60)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame
local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 8) tc.Parent = title

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 24, 0, 22)
close.Position = UDim2.new(1, -26, 0, 2)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = frame
close.MouseButton1Click:Connect(function() sg:Destroy() end)

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -20, 0, 38)
copyBtn.Position = UDim2.new(0, 10, 0, 38)
copyBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
copyBtn.BorderSizePixel = 0
copyBtn.Text = "COPY ALL GOLDY IDs"
copyBtn.TextColor3 = Color3.fromRGB(255, 230, 150)
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 13
copyBtn.AutoButtonColor = false
copyBtn.Parent = frame
local cbc = Instance.new("UICorner") cbc.CornerRadius = UDim.new(0, 5) cbc.Parent = copyBtn
local cbs = Instance.new("UIStroke") cbs.Color = Color3.fromRGB(255, 215, 60) cbs.Thickness = 1.5 cbs.Parent = copyBtn

local cbg = Instance.new("UIGradient")
cbg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 4, 4))
})
cbg.Rotation = 90
cbg.Parent = copyBtn

copyBtn.MouseEnter:Connect(function()
    copyBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    cbs.Thickness = 2
end)
copyBtn.MouseLeave:Connect(function()
    copyBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    cbs.Thickness = 1.5
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 50)
status.Position = UDim2.new(0, 10, 0, 84)
status.BackgroundTransparency = 1
status.Text = "click to scan + copy"
status.TextColor3 = Color3.fromRGB(160, 160, 160)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.Parent = frame

----------------------------------------------------------------
-- SAFE scan
----------------------------------------------------------------

-- modules whose names suggest server/networking/init code we should NOT require
local skipPatterns = {
    "server", "remote", "network", "init", "boot",
    "load", "fire", "anim", "controller", "input", "cam",
    "round", "match", "gamemode", "music", "sound",
    "tween", "particle", "debug", "test"
}

local function shouldSkipModule(m)
    local name = m.Name:lower()
    for _, p in ipairs(skipPatterns) do
        if name:find(p) then return true end
    end
    -- skip anything inside the local player or character
    local lp = Players.LocalPlayer
    if m:IsDescendantOf(lp) then return true end
    return false
end

local running = false

local function collectGoldyIds()
    local lines = {}
    local seenLines = {}
    local visited = {}

    local function add(label, value)
        if value == nil or tostring(value) == "" then return end
        local key = label .. "|" .. tostring(value)
        if seenLines[key] then return end
        seenLines[key] = true
        table.insert(lines, label .. " = " .. tostring(value))
    end

    local function dumpItem(name, data, source)
        table.insert(lines, "")
        table.insert(lines, "--- " .. tostring(name) .. " (in " .. source .. ") ---")
        local count = 0
        for k, v in pairs(data) do
            if type(v) ~= "table" then
                add(tostring(k), v)
                count = count + 1
                if count > 30 then break end
            end
        end
    end

    local function scanTable(tbl, source, depth)
        if depth > 3 then return end
        if visited[tbl] then return end
        visited[tbl] = true

        for k, v in pairs(tbl) do
            if type(v) == "table" then
                local hit = false
                if tostring(k):lower():find("gold") then hit = true end
                local nm = rawget(v, "Name") or rawget(v, "ItemName")
                if nm and tostring(nm):lower():find("gold") then hit = true end
                if hit then
                    dumpItem(k, v, source)
                end
                scanTable(v, source, depth + 1)
            end
        end
    end

    -- collect candidate modules from ReplicatedStorage only
    local modules = {}
    for _, m in ipairs(ReplicatedStorage:GetDescendants()) do
        if m:IsA("ModuleScript") and not shouldSkipModule(m) then
            table.insert(modules, m)
        end
    end

    status.Text = "scanning " .. #modules .. " modules..."

    local startTime = tick()
    local maxTime = 8 -- hard cap so we never freeze

    for i, m in ipairs(modules) do
        if tick() - startTime > maxTime then
            table.insert(lines, "(time limit hit at module " .. i .. " of " .. #modules .. ")")
            break
        end

        -- yield every 5 modules so Roblox stays responsive
        if i % 5 == 0 then
            status.Text = "scanning " .. i .. "/" .. #modules .. "..."
            task.wait()
        end

        local ok, data = pcall(require, m)
        if ok and type(data) == "table" then
            local ok2 = pcall(scanTable, data, m.Name, 0)
            if not ok2 then
                -- table had something weird, just skip
            end
        end
    end

    -- also check live ImageLabels in PlayerGui (the inventory might have Goldy displayed)
    for _, v in ipairs(PlayerGui:GetDescendants()) do
        if (v:IsA("ImageLabel") or v:IsA("ImageButton")) then
            local parentName = v.Parent and tostring(v.Parent.Name):lower() or ""
            local grandparentName = v.Parent and v.Parent.Parent and tostring(v.Parent.Parent.Name):lower() or ""
            if parentName:find("gold") or grandparentName:find("gold") or v.Name:lower():find("gold") then
                table.insert(lines, "")
                table.insert(lines, "--- INSTANCE " .. v:GetFullName() .. " ---")
                add("Image", v.Image)
            end
        end
    end

    return lines
end

copyBtn.MouseButton1Click:Connect(function()
    if running then
        status.Text = "already scanning, wait..."
        return
    end
    running = true
    status.Text = "scanning..."
    status.TextColor3 = Color3.fromRGB(160, 160, 160)

    task.spawn(function()
        local ok, lines = pcall(collectGoldyIds)
        running = false

        if not ok then
            status.Text = "scan errored: " .. tostring(lines)
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end

        if #lines == 0 then
            status.Text = "no goldy data found in ReplicatedStorage"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end

        table.insert(lines, 1, "=== badtrip goldy ids ===")
        local text = table.concat(lines, "\n")

        if setclipboard then
            local ok3 = pcall(setclipboard, text)
            if ok3 then
                status.Text = "COPIED " .. (#lines) .. " lines. paste anywhere (Ctrl+V)"
                status.TextColor3 = Color3.fromRGB(120, 220, 120)
                return
            end
        end
        if toclipboard then
            pcall(toclipboard, text)
            status.Text = "COPIED " .. (#lines) .. " lines. paste anywhere (Ctrl+V)"
            status.TextColor3 = Color3.fromRGB(120, 220, 120)
            return
        end

        status.Text = "found " .. (#lines) .. " lines but no clipboard. printed to console."
        status.TextColor3 = Color3.fromRGB(255, 200, 40)
        print(text)
    end)
end)
