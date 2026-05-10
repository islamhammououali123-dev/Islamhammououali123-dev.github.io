-- goldy_scanner.lua
-- Safe MM2 scanner. NO require() calls. Just walks live instances.
-- Black UI, one COPY button.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
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
-- SAFE scan: NO require() at all. Just live instances.
----------------------------------------------------------------
local running = false

local function nameMatches(name)
    return tostring(name):lower():find("gold") ~= nil
end

local function ancestorMatches(inst)
    local cur = inst
    local depth = 0
    while cur and depth < 4 do
        if nameMatches(cur.Name) then return true, cur.Name end
        cur = cur.Parent
        depth = depth + 1
    end
    return false, nil
end

local function collectGoldyIds()
    local lines = {}
    local seen = {}

    local function add(label, value)
        if value == nil or tostring(value) == "" then return end
        local key = label .. "|" .. tostring(value)
        if seen[key] then return end
        seen[key] = true
        table.insert(lines, label .. " = " .. tostring(value))
    end

    -- only walk three safe containers
    local roots = {ReplicatedStorage, Workspace, PlayerGui}

    local total = 0
    local matches = 0
    local startTime = tick()

    for _, root in ipairs(roots) do
        local descendants = root:GetDescendants()
        for i, v in ipairs(descendants) do
            total = total + 1

            -- yield often, status update
            if total % 200 == 0 then
                status.Text = "scanning... " .. total .. " checked, " .. matches .. " matches"
                task.wait()
            end

            -- hard time cap
            if tick() - startTime > 6 then
                table.insert(lines, "(time cap reached)")
                break
            end

            local hit, hitName = false, nil
            if nameMatches(v.Name) then
                hit, hitName = true, v.Name
            else
                local a, an = ancestorMatches(v.Parent)
                if a then hit, hitName = true, an end
            end

            if hit then
                if v:IsA("ImageLabel") or v:IsA("ImageButton") then
                    matches = matches + 1
                    table.insert(lines, "")
                    table.insert(lines, "[ImageLabel] " .. v:GetFullName() .. " (near: " .. hitName .. ")")
                    add("Image", v.Image)
                elseif v:IsA("Decal") then
                    matches = matches + 1
                    table.insert(lines, "")
                    table.insert(lines, "[Decal] " .. v:GetFullName())
                    add("Texture", v.Texture)
                elseif v:IsA("SpecialMesh") then
                    matches = matches + 1
                    table.insert(lines, "")
                    table.insert(lines, "[SpecialMesh] " .. v:GetFullName())
                    add("MeshId", v.MeshId)
                    add("TextureId", v.TextureId)
                elseif v:IsA("MeshPart") then
                    matches = matches + 1
                    table.insert(lines, "")
                    table.insert(lines, "[MeshPart] " .. v:GetFullName())
                    add("MeshId", v.MeshId)
                    add("TextureID", v.TextureID)
                elseif v:IsA("Tool") then
                    matches = matches + 1
                    table.insert(lines, "")
                    table.insert(lines, "[Tool] " .. v:GetFullName())
                    add("TextureId", v.TextureId)
                elseif v:IsA("StringValue") or v:IsA("NumberValue") or v:IsA("IntValue") then
                    matches = matches + 1
                    table.insert(lines, "")
                    table.insert(lines, "[" .. v.ClassName .. "] " .. v:GetFullName())
                    add("Value", v.Value)
                end
            end
        end
    end

    table.insert(lines, 1, "scanned " .. total .. " instances, found " .. matches .. " match(es)")
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
            status.Text = "error: " .. tostring(lines):sub(1, 60)
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end

        if not lines or #lines <= 1 then
            status.Text = "no goldy instances found. try in a round."
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

        status.Text = "found " .. (#lines) .. " lines, no clipboard. printed to console."
        status.TextColor3 = Color3.fromRGB(255, 200, 40)
        print(text)
    end)
end)
