-- goldy_scanner.lua
-- Run this in MM2. Results show in an on-screen GUI (no need to read the console).
-- Tap a result line to copy the Image ID into your clipboard (if executor supports setclipboard).

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
frame.Size = UDim2.new(0, 380, 0, 320)
frame.Position = UDim2.new(0.5, -190, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = sg

local fc = Instance.new("UICorner") fc.CornerRadius = UDim.new(0, 8) fc.Parent = frame
local fs = Instance.new("UIStroke") fs.Color = Color3.fromRGB(255, 200, 40) fs.Thickness = 1.4 fs.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
title.BorderSizePixel = 0
title.Text = "badtrip goldy scanner"
title.TextColor3 = Color3.fromRGB(255, 215, 60)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

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
list.Size = UDim2.new(1, -10, 1, -34)
list.Position = UDim2.new(0, 5, 0, 28)
list.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = frame

local lay = Instance.new("UIListLayout")
lay.SortOrder = Enum.SortOrder.LayoutOrder
lay.Padding = UDim.new(0, 2)
lay.Parent = list

local function addLine(text, color, copyValue)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 18)
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
            b.Text = " [COPIED] " .. text
            task.delay(1, function() b.Text = " " .. text end)
        end)
    end
end

addLine("scanning... (tap any line with an ID to copy)", Color3.fromRGB(160, 160, 160))

task.spawn(function()
    local found = 0
    local rs = game:GetService("ReplicatedStorage")

    local function scanTable(tbl, source, depth, path)
        if depth > 5 then return end
        for k, v in pairs(tbl) do
            local ks = tostring(k):lower()
            local matched = ks:find("gold")
            if type(v) == "table" then
                local nameField = v.Name or v.ItemName
                if nameField and tostring(nameField):lower():find("gold") then
                    matched = true
                end
                if matched then
                    found += 1
                    addLine("FOUND in " .. source .. " at " .. path .. "." .. tostring(k),
                            Color3.fromRGB(255, 215, 60))
                    for kk, vv in pairs(v) do
                        local copyVal = nil
                        if tostring(kk):lower():find("image") or tostring(kk):lower():find("icon")
                           or tostring(kk):lower():find("mesh") or tostring(kk):lower():find("texture") then
                            copyVal = vv
                            addLine("  " .. tostring(kk) .. " = " .. tostring(vv) .. "  [tap to copy]",
                                    Color3.fromRGB(120, 220, 255), copyVal)
                        else
                            addLine("  " .. tostring(kk) .. " = " .. tostring(vv),
                                    Color3.fromRGB(200, 200, 200))
                        end
                    end
                end
                scanTable(v, source, depth + 1, path .. "." .. tostring(k))
            end
        end
    end

    -- search every ModuleScript everywhere the client can see
    for _, container in ipairs({rs, game:GetService("ReplicatedFirst"),
                                 game:GetService("Workspace"), game:GetService("Lighting")}) do
        for _, m in ipairs(container:GetDescendants()) do
            if m:IsA("ModuleScript") then
                local ok, data = pcall(require, m)
                if ok and type(data) == "table" then
                    scanTable(data, m:GetFullName(), 0, "root")
                end
            end
        end
    end

    -- also: search Instances named Goldy / containing Goldy with SpecialMesh / Decal
    for _, v in ipairs(game:GetDescendants()) do
        if tostring(v.Name):lower():find("gold") then
            if v:IsA("SpecialMesh") or v:IsA("MeshPart") then
                found += 1
                addLine("INSTANCE " .. v:GetFullName(), Color3.fromRGB(255, 215, 60))
                local mid = v.MeshId or (v:IsA("MeshPart") and v.MeshId) or ""
                local tid = v.TextureId or (v:IsA("MeshPart") and v.TextureID) or ""
                if mid ~= "" then addLine("  MeshId = " .. mid .. "  [tap to copy]",
                                          Color3.fromRGB(120, 220, 255), mid) end
                if tid ~= "" then addLine("  TextureId = " .. tid .. "  [tap to copy]",
                                          Color3.fromRGB(120, 220, 255), tid) end
            elseif v:IsA("Decal") or v:IsA("ImageLabel") then
                found += 1
                addLine("INSTANCE " .. v:GetFullName(), Color3.fromRGB(255, 215, 60))
                addLine("  Image = " .. tostring(v.Texture or v.Image) .. "  [tap to copy]",
                        Color3.fromRGB(120, 220, 255), v.Texture or v.Image)
            end
        end
    end

    if found == 0 then
        addLine("nothing found. join a round + try again while goldy is held",
                Color3.fromRGB(255, 100, 100))
    else
        addLine("=== done. " .. found .. " match(es) ===", Color3.fromRGB(120, 220, 120))
    end
end)
