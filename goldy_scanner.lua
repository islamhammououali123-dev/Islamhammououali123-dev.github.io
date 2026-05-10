-- goldy_scanner.lua
-- Aggressive MM2 scanner. Dumps every weapon's data so you can find Goldy
-- without anyone equipping it. Results in an on-screen GUI.
-- Tap any line with [tap to copy] to copy the value to clipboard.

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
frame.Size = UDim2.new(0, 460, 0, 380)
frame.Position = UDim2.new(0.5, -230, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = sg

local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 8) fc.Parent = frame
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(255, 200, 40) fs.Thickness = 1.4 fs.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
title.BorderSizePixel = 0
title.Text = "  badtrip goldy scanner"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 215, 60)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

local filterBox = Instance.new("TextBox")
filterBox.Size = UDim2.new(0, 120, 0, 20)
filterBox.Position = UDim2.new(1, -150, 0, 2)
filterBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
filterBox.BorderSizePixel = 0
filterBox.Text = "gold"
filterBox.PlaceholderText = "filter (empty = all)"
filterBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
filterBox.TextColor3 = Color3.fromRGB(255, 220, 120)
filterBox.Font = Enum.Font.Gotham
filterBox.TextSize = 11
filterBox.Parent = frame
local fbc = Instance.new("UICorner") fbc.CornerRadius = UDim.new(0, 4) fbc.Parent = filterBox

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 24, 0, 24)
close.Position = UDim2.new(1, -24, 0, 0)
close.BackgroundTransparency = 1
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 100, 100)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = frame
close.MouseButton1Click:Connect(function() sg:Destroy() end)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -10, 1, -60)
list.Position = UDim2.new(0, 5, 0, 28)
list.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = frame

local lay = Instance.new("UIListLayout")
lay.SortOrder = Enum.SortOrder.LayoutOrder
lay.Padding = UDim.new(0, 1)
lay.Parent = list

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -10, 0, 24)
scanBtn.Position = UDim2.new(0, 5, 1, -28)
scanBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
scanBtn.BorderSizePixel = 0
scanBtn.Text = "RESCAN"
scanBtn.TextColor3 = Color3.fromRGB(255, 215, 60)
scanBtn.Font = Enum.Font.GothamBold
scanBtn.TextSize = 12
scanBtn.Parent = frame
local sbc = Instance.new("UICorner") sbc.CornerRadius = UDim.new(0, 4) sbc.Parent = scanBtn
local sbs = Instance.new("UIStroke") sbs.Color = Color3.fromRGB(255, 200, 40) sbs.Thickness = 1 sbs.Parent = scanBtn

local function clearList()
    for _, c in ipairs(list:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
end

local function addLine(text, color, copyValue)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 16)
    b.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    b.BorderSizePixel = 0
    b.Text = " " .. text
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextColor3 = color or Color3.fromRGB(220, 220, 220)
    b.Font = Enum.Font.Code
    b.TextSize = 11
    b.AutoButtonColor = true
    b.Parent = list
    if copyValue and setclipboard then
        b.MouseButton1Click:Connect(function()
            pcall(setclipboard, tostring(copyValue))
            local original = b.Text
            b.Text = " [COPIED] " .. tostring(copyValue)
            task.delay(1.2, function() b.Text = original end)
        end)
    end
end

local function tableContainsGold(t, filter, depth)
    depth = depth or 0
    if depth > 3 then return false end
    for k, v in pairs(t) do
        if tostring(k):lower():find(filter) then return true end
        if type(v) == "string" and v:lower():find(filter) then return true end
        if type(v) == "table" and tableContainsGold(v, filter, depth + 1) then return true end
    end
    return false
end

local function dumpItem(name, data, source)
    addLine("=== " .. tostring(name) .. " (in " .. source .. ") ===",
            Color3.fromRGB(255, 215, 60))
    if type(data) ~= "table" then
        addLine("  value = " .. tostring(data), Color3.fromRGB(200, 200, 200))
        return
    end
    -- prioritize Image / Icon / Texture / Mesh / Name fields first
    local priorityKeys = {"Image", "Icon", "TextureId", "Texture",
                          "MeshId", "Mesh", "Name", "ItemName", "Rarity"}
    local seen = {}
    for _, pk in ipairs(priorityKeys) do
        local v = data[pk]
        if v ~= nil then
            seen[pk] = true
            local copyVal = (type(v) == "string" or type(v) == "number") and v or nil
            addLine("  " .. pk .. " = " .. tostring(v) .. (copyVal and "  [tap to copy]" or ""),
                    Color3.fromRGB(120, 220, 255), copyVal)
        end
    end
    for k, v in pairs(data) do
        if not seen[k] and type(v) ~= "table" then
            addLine("  " .. tostring(k) .. " = " .. tostring(v),
                    Color3.fromRGB(180, 180, 180))
        end
    end
end

local function runScan()
    clearList()
    local filter = (filterBox.Text or ""):lower()
    if filter == "" then filter = "gold" end
    addLine("scanning for: " .. filter, Color3.fromRGB(160, 160, 160))

    local services = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("Workspace"),
        game:GetService("Lighting"),
        game:GetService("StarterPack"),
        game:GetService("StarterGui"),
    }

    local matchCount = 0
    local moduleCount = 0
    local errCount = 0

    for _, container in ipairs(services) do
        for _, m in ipairs(container:GetDescendants()) do
            if m:IsA("ModuleScript") then
                moduleCount += 1
                local ok, data = pcall(require, m)
                if not ok then
                    errCount += 1
                elseif type(data) == "table" then
                    -- look at every entry: if its key OR its Name field matches filter, dump it
                    for k, v in pairs(data) do
                        if type(v) == "table" then
                            local hit = false
                            if tostring(k):lower():find(filter) then hit = true end
                            local nm = v.Name or v.ItemName
                            if nm and tostring(nm):lower():find(filter) then hit = true end
                            if hit then
                                matchCount += 1
                                dumpItem(k, v, m.Name)
                            end
                        elseif type(v) == "string" and v:lower():find(filter) then
                            -- top level string match
                            matchCount += 1
                            addLine("[string] " .. m.Name .. "." .. tostring(k) .. " = " .. v,
                                    Color3.fromRGB(120, 220, 255), v)
                        end
                    end
                    -- ALSO check nested sub-tables (Weapons, Items, etc.)
                    for k, v in pairs(data) do
                        if type(v) == "table" then
                            for kk, vv in pairs(v) do
                                if type(vv) == "table" then
                                    local hit = false
                                    if tostring(kk):lower():find(filter) then hit = true end
                                    local nm = vv.Name or vv.ItemName
                                    if nm and tostring(nm):lower():find(filter) then hit = true end
                                    if hit then
                                        matchCount += 1
                                        dumpItem(kk, vv, m.Name .. "." .. tostring(k))
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- also scan live Instances
    for _, v in ipairs(game:GetDescendants()) do
        if tostring(v.Name):lower():find(filter) then
            if v:IsA("SpecialMesh") then
                matchCount += 1
                addLine("INSTANCE " .. v:GetFullName(), Color3.fromRGB(255, 215, 60))
                addLine("  MeshId = " .. v.MeshId .. "  [tap to copy]",
                        Color3.fromRGB(120, 220, 255), v.MeshId)
                addLine("  TextureId = " .. v.TextureId .. "  [tap to copy]",
                        Color3.fromRGB(120, 220, 255), v.TextureId)
            elseif v:IsA("MeshPart") then
                matchCount += 1
                addLine("INSTANCE " .. v:GetFullName(), Color3.fromRGB(255, 215, 60))
                addLine("  MeshId = " .. v.MeshId .. "  [tap to copy]",
                        Color3.fromRGB(120, 220, 255), v.MeshId)
                addLine("  TextureID = " .. v.TextureID .. "  [tap to copy]",
                        Color3.fromRGB(120, 220, 255), v.TextureID)
            elseif v:IsA("Decal") then
                matchCount += 1
                addLine("INSTANCE " .. v:GetFullName(), Color3.fromRGB(255, 215, 60))
                addLine("  Texture = " .. v.Texture .. "  [tap to copy]",
                        Color3.fromRGB(120, 220, 255), v.Texture)
            elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
                matchCount += 1
                addLine("INSTANCE " .. v:GetFullName(), Color3.fromRGB(255, 215, 60))
                addLine("  Image = " .. v.Image .. "  [tap to copy]",
                        Color3.fromRGB(120, 220, 255), v.Image)
            end
        end
    end

    addLine("------", Color3.fromRGB(80, 80, 80))
    addLine("scanned " .. moduleCount .. " modules, " .. errCount .. " errored, " ..
            matchCount .. " match(es)",
            matchCount > 0 and Color3.fromRGB(120, 220, 120) or Color3.fromRGB(255, 100, 100))
    if matchCount == 0 then
        addLine("try with filter empty, or change to 'knife' / 'godly'",
                Color3.fromRGB(255, 150, 150))
    end
end

scanBtn.MouseButton1Click:Connect(runScan)
runScan()
