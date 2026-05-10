-- goldy_scanner.lua
-- Black UI. One button: copies every Goldy ID it can find to your clipboard.
-- Then paste it anywhere (Ctrl+V) to see all the IDs at once.

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("badtrip_scan") then
    PlayerGui.badtrip_scan:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "badtrip_scan"
sg.ResetOnSpawn = false
sg.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 130)
frame.Position = UDim2.new(0.5, -120, 0.5, -65)
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
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 84)
status.BackgroundTransparency = 1
status.Text = "click to scan + copy"
status.TextColor3 = Color3.fromRGB(160, 160, 160)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.Parent = frame

----------------------------------------------------------------
-- Scan logic
----------------------------------------------------------------
local function collectGoldyIds()
    local lines = {}
    local seen = {}
    local function add(label, value)
        if not value or tostring(value) == "" then return end
        local key = label .. "|" .. tostring(value)
        if seen[key] then return end
        seen[key] = true
        table.insert(lines, label .. " = " .. tostring(value))
    end

    local function dumpItem(name, data, source)
        table.insert(lines, "")
        table.insert(lines, "--- " .. tostring(name) .. " (in " .. source .. ") ---")
        for k, v in pairs(data) do
            if type(v) ~= "table" then
                add(tostring(k), v)
            end
        end
    end

    -- 1. ModuleScripts (item database)
    local services = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("Workspace"),
        game:GetService("Lighting"),
        game:GetService("StarterPack"),
        game:GetService("StarterGui"),
    }

    local function scanTable(tbl, source, depth)
        if depth > 4 then return end
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                local hit = false
                if tostring(k):lower():find("gold") then hit = true end
                local nm = v.Name or v.ItemName
                if nm and tostring(nm):lower():find("gold") then hit = true end
                if hit then
                    dumpItem(k, v, source)
                end
                scanTable(v, source, depth + 1)
            end
        end
    end

    for _, container in ipairs(services) do
        for _, m in ipairs(container:GetDescendants()) do
            if m:IsA("ModuleScript") then
                local ok, data = pcall(require, m)
                if ok and type(data) == "table" then
                    scanTable(data, m:GetFullName(), 0)
                end
            end
        end
    end

    -- 2. Live instances named with "gold"
    for _, v in ipairs(game:GetDescendants()) do
        if tostring(v.Name):lower():find("gold") then
            if v:IsA("SpecialMesh") then
                table.insert(lines, "")
                table.insert(lines, "--- INSTANCE " .. v:GetFullName() .. " ---")
                add("MeshId", v.MeshId)
                add("TextureId", v.TextureId)
            elseif v:IsA("MeshPart") then
                table.insert(lines, "")
                table.insert(lines, "--- INSTANCE " .. v:GetFullName() .. " ---")
                add("MeshId", v.MeshId)
                add("TextureID", v.TextureID)
            elseif v:IsA("Decal") then
                table.insert(lines, "")
                table.insert(lines, "--- INSTANCE " .. v:GetFullName() .. " ---")
                add("Texture", v.Texture)
            elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
                table.insert(lines, "")
                table.insert(lines, "--- INSTANCE " .. v:GetFullName() .. " ---")
                add("Image", v.Image)
            end
        end
    end

    return lines
end

copyBtn.MouseButton1Click:Connect(function()
    status.Text = "scanning..."
    status.TextColor3 = Color3.fromRGB(160, 160, 160)
    task.wait()

    local lines = collectGoldyIds()
    if #lines == 0 then
        status.Text = "no goldy data found in client"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    table.insert(lines, 1, "=== badtrip goldy ids ===")
    local text = table.concat(lines, "\n")

    if setclipboard then
        local ok = pcall(setclipboard, text)
        if ok then
            status.Text = "COPIED " .. #lines .. " lines! paste anywhere (Ctrl+V)"
            status.TextColor3 = Color3.fromRGB(120, 220, 120)
            return
        end
    end
    if toclipboard then
        pcall(toclipboard, text)
        status.Text = "COPIED " .. #lines .. " lines! paste anywhere (Ctrl+V)"
        status.TextColor3 = Color3.fromRGB(120, 220, 120)
        return
    end

    status.Text = "found " .. #lines .. " lines, but executor has no clipboard. printing to console."
    status.TextColor3 = Color3.fromRGB(255, 200, 40)
    print(text)
end)
