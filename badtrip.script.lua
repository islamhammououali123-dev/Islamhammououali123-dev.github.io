-- badtrip.script
-- Black MM2 UI with neon-bordered realistic buttons
-- Visual Goldy "inventory" spawner (client-side visual only)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("badtrip") then
    PlayerGui.badtrip:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "badtrip"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

----------------------------------------------------------------
-- Main frame
----------------------------------------------------------------
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 230, 0, 470)
Main.Position = UDim2.new(0.5, -115, 0.5, -235)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(25, 25, 25)
MainStroke.Thickness = 1
MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
})
MainGradient.Rotation = 90
MainGradient.Parent = Main

----------------------------------------------------------------
-- Title bar
----------------------------------------------------------------
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Title.BorderSizePixel = 0
Title.Text = "badtrip | mm2"
Title.TextColor3 = Color3.fromRGB(235, 235, 235)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.new(1, 0, 0, 1)
TitleAccent.Position = UDim2.new(0, 0, 1, -1)
TitleAccent.BorderSizePixel = 0
TitleAccent.BackgroundColor3 = Color3.fromRGB(255, 200, 40)
TitleAccent.Parent = Title

----------------------------------------------------------------
-- Realistic neon-bordered button factory
----------------------------------------------------------------
local function makeButton(opts)
    local btn = Instance.new("TextButton")
    btn.Size = opts.Size
    btn.Position = opts.Position
    btn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    btn.BorderSizePixel = 0
    btn.Text = opts.Text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = opts.Parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = btn

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 28)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 14, 14)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 4, 4))
    })
    grad.Rotation = 90
    grad.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = opts.NeonColor or Color3.fromRGB(255, 200, 40)
    stroke.Thickness = 1.4
    stroke.Transparency = 0.1
    stroke.Parent = btn

    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(1, -6, 0, 1)
    highlight.Position = UDim2.new(0, 3, 0, 1)
    highlight.BorderSizePixel = 0
    highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    highlight.BackgroundTransparency = 0.85
    highlight.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0, Thickness = 1.8}):Play()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.1, Thickness = 1.4}):Play()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(14, 14, 14)}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {Size = opts.Size - UDim2.new(0, 0, 0, 2)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.08), {Size = opts.Size}):Play()
    end)

    return btn, stroke
end

----------------------------------------------------------------
-- Buttons
----------------------------------------------------------------
local TestButton = makeButton({
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 36),
    Text = "Test",
    NeonColor = Color3.fromRGB(255, 60, 60)
})
TestButton.TextColor3 = Color3.fromRGB(255, 200, 200)

local SpawnButton = makeButton({
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 74),
    Text = "Spawn (1 Goldy in inv)",
    NeonColor = Color3.fromRGB(255, 200, 40)
})

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(1, -20, 0, 28)
AmountBox.Position = UDim2.new(0, 10, 0, 112)
AmountBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
AmountBox.BorderSizePixel = 0
AmountBox.Text = ""
AmountBox.PlaceholderText = "amount (1 - 99)"
AmountBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
AmountBox.TextColor3 = Color3.fromRGB(255, 220, 120)
AmountBox.Font = Enum.Font.Gotham
AmountBox.TextSize = 12
AmountBox.ClearTextOnFocus = false
AmountBox.Parent = Main

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 5)
BoxCorner.Parent = AmountBox

local BoxStroke = Instance.new("UIStroke")
BoxStroke.Color = Color3.fromRGB(255, 200, 40)
BoxStroke.Thickness = 1.2
BoxStroke.Transparency = 0.4
BoxStroke.Parent = AmountBox

local SpawnAllButton = makeButton({
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 150),
    Text = "Spawn All Goldy",
    NeonColor = Color3.fromRGB(255, 215, 70)
})
SpawnAllButton.TextColor3 = Color3.fromRGB(255, 230, 150)

local SpawnX5Button = makeButton({
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 28),
    Position = UDim2.new(0, 10, 0, 188),
    Text = "Spawn Goldy x5",
    NeonColor = Color3.fromRGB(255, 215, 70)
})
SpawnX5Button.TextColor3 = Color3.fromRGB(255, 230, 150)

-- Image ID textbox (paste real Goldy asset id here)
local ImageBox = Instance.new("TextBox")
ImageBox.Size = UDim2.new(1, -20, 0, 26)
ImageBox.Position = UDim2.new(0, 10, 0, 224)
ImageBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ImageBox.BorderSizePixel = 0
ImageBox.Text = ""
ImageBox.PlaceholderText = "paste goldy image id here"
ImageBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
ImageBox.TextColor3 = Color3.fromRGB(255, 220, 120)
ImageBox.Font = Enum.Font.Gotham
ImageBox.TextSize = 11
ImageBox.ClearTextOnFocus = false
ImageBox.Parent = Main

local ImgCorner = Instance.new("UICorner")
ImgCorner.CornerRadius = UDim.new(0, 5)
ImgCorner.Parent = ImageBox

local ImgStroke = Instance.new("UIStroke")
ImgStroke.Color = Color3.fromRGB(255, 200, 40)
ImgStroke.Thickness = 1.2
ImgStroke.Transparency = 0.4
ImgStroke.Parent = ImageBox

local ClearButton = makeButton({
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 24),
    Position = UDim2.new(0, 10, 0, 258),
    Text = "Clear Fake Inventory",
    NeonColor = Color3.fromRGB(120, 120, 120)
})
ClearButton.TextColor3 = Color3.fromRGB(200, 200, 200)

----------------------------------------------------------------
-- Fake inventory panel (always works, no MM2 hook needed)
----------------------------------------------------------------
local InvLabel = Instance.new("TextLabel")
InvLabel.Size = UDim2.new(1, -20, 0, 14)
InvLabel.Position = UDim2.new(0, 10, 0, 290)
InvLabel.BackgroundTransparency = 1
InvLabel.Text = "fake inventory:"
InvLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
InvLabel.TextXAlignment = Enum.TextXAlignment.Left
InvLabel.Font = Enum.Font.Gotham
InvLabel.TextSize = 10
InvLabel.Parent = Main

local InvFrame = Instance.new("ScrollingFrame")
InvFrame.Size = UDim2.new(1, -20, 0, 140)
InvFrame.Position = UDim2.new(0, 10, 0, 308)
InvFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
InvFrame.BorderSizePixel = 0
InvFrame.ScrollBarThickness = 3
InvFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 40)
InvFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
InvFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
InvFrame.Parent = Main

local InvCorner = Instance.new("UICorner")
InvCorner.CornerRadius = UDim.new(0, 5)
InvCorner.Parent = InvFrame

local InvStroke = Instance.new("UIStroke")
InvStroke.Color = Color3.fromRGB(40, 40, 40)
InvStroke.Thickness = 1
InvStroke.Parent = InvFrame

local InvGrid = Instance.new("UIGridLayout")
InvGrid.CellSize = UDim2.new(0, 40, 0, 40)
InvGrid.CellPadding = UDim2.new(0, 4, 0, 4)
InvGrid.SortOrder = Enum.SortOrder.LayoutOrder
InvGrid.Parent = InvFrame

local InvPadding = Instance.new("UIPadding")
InvPadding.PaddingTop = UDim.new(0, 4)
InvPadding.PaddingLeft = UDim.new(0, 4)
InvPadding.Parent = InvFrame

----------------------------------------------------------------
-- Status
----------------------------------------------------------------
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 16)
Status.Position = UDim2.new(0, 10, 1, -22)
Status.BackgroundTransparency = 1
Status.Text = "ready"
Status.TextColor3 = Color3.fromRGB(160, 160, 160)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextWrapped = true
Status.Parent = Main

local function setStatus(text, color)
    Status.Text = text
    Status.TextColor3 = color or Color3.fromRGB(160, 160, 160)
end

----------------------------------------------------------------
-- Goldy slot builder
----------------------------------------------------------------
local goldyCount = 0

local function makeGoldySlot()
    goldyCount = goldyCount + 1

    local slot = Instance.new("Frame")
    slot.Name = "GoldySlot_" .. goldyCount
    slot.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    slot.BorderSizePixel = 0
    slot.LayoutOrder = goldyCount
    slot.Parent = InvFrame

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 4)
    sc.Parent = slot

    local ss = Instance.new("UIStroke")
    ss.Color = Color3.fromRGB(255, 215, 60)
    ss.Thickness = 1.2
    ss.Transparency = 0.2
    ss.Parent = slot

    -- gold gradient inside the slot
    local sg = Instance.new("UIGradient")
    sg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 45, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 12, 0))
    })
    sg.Rotation = 135
    sg.Parent = slot

    -- icon: real Goldy image if user pasted an ID, else drawn knife
    local idText = ImageBox.Text
    local idNum = tonumber(string.match(idText, "%d+"))
    if idNum then
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(1, -6, 1, -14)
        icon.Position = UDim2.new(0, 3, 0, 2)
        icon.BackgroundTransparency = 1
        icon.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=110&height=110&assetId=" .. idNum
        icon.Parent = slot
    else
        local handle = Instance.new("Frame")
        handle.Size = UDim2.new(0, 4, 0, 14)
        handle.Position = UDim2.new(0.5, -2, 0.5, 4)
        handle.BackgroundColor3 = Color3.fromRGB(120, 80, 0)
        handle.BorderSizePixel = 0
        handle.Parent = slot
        local hc = Instance.new("UICorner")
        hc.CornerRadius = UDim.new(0, 2)
        hc.Parent = handle

        local blade = Instance.new("Frame")
        blade.Size = UDim2.new(0, 6, 0, 16)
        blade.Position = UDim2.new(0.5, -3, 0.5, -14)
        blade.BackgroundColor3 = Color3.fromRGB(255, 220, 70)
        blade.BorderSizePixel = 0
        blade.Parent = slot
        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 1)
        bc.Parent = blade
    end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 10)
    label.Position = UDim2.new(0, 0, 1, -11)
    label.BackgroundTransparency = 1
    label.Text = "Goldy"
    label.TextColor3 = Color3.fromRGB(255, 220, 90)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 9
    label.Parent = slot

    return slot
end

local function clearInventory()
    for _, c in ipairs(InvFrame:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    goldyCount = 0
end

----------------------------------------------------------------
-- Best-effort: also try to inject into MM2's real inventory UI
-- (safe — fails silently if the GUI isn't found)
----------------------------------------------------------------
local function tryInjectIntoMM2Inventory()
    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if gui:IsA("ScrollingFrame") and tostring(gui.Parent.Name):lower():find("invent") then
            local first = gui:FindFirstChildWhichIsA("Frame") or gui:FindFirstChildWhichIsA("TextButton")
            if first then
                local fake = first:Clone()
                fake.Name = "FakeGoldy"
                local nameLbl = fake:FindFirstChild("ItemName", true)
                if nameLbl and nameLbl:FindFirstChild("Label") then
                    nameLbl.Label.Text = "Goldy"
                end
                local idText = ImageBox.Text
                local idNum = tonumber(string.match(idText, "%d+"))
                if idNum then
                    local iconHolder = fake:FindFirstChild("Container", true)
                    local iconImg = iconHolder and iconHolder:FindFirstChild("Icon")
                    if iconImg and iconImg:IsA("ImageLabel") then
                        iconImg.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. idNum
                    end
                end
                fake.Parent = gui
                return true
            end
        end
    end
    return false
end

----------------------------------------------------------------
-- Button actions
----------------------------------------------------------------
TestButton.MouseButton1Click:Connect(function()
    setStatus("button works!", Color3.fromRGB(120, 220, 120))
    task.delay(1.5, function() setStatus("ready") end)
end)

SpawnButton.MouseButton1Click:Connect(function()
    makeGoldySlot()
    local injected = tryInjectIntoMM2Inventory()
    setStatus(injected and "added 1 Goldy (also in MM2 ui)" or "added 1 Goldy to fake inv",
              Color3.fromRGB(255, 215, 60))
    task.delay(1.5, function() setStatus("ready") end)
end)

SpawnAllButton.MouseButton1Click:Connect(function()
    local n = tonumber(AmountBox.Text) or 10
    n = math.clamp(math.floor(n), 1, 99)
    local injectedCount = 0
    for i = 1, n do
        makeGoldySlot()
        if tryInjectIntoMM2Inventory() then injectedCount = injectedCount + 1 end
    end
    setStatus("added " .. n .. " Goldy" ..
              (injectedCount > 0 and (" (" .. injectedCount .. " in mm2 ui)") or ""),
              Color3.fromRGB(255, 215, 60))
    task.delay(2, function() setStatus("ready") end)
end)

SpawnX5Button.MouseButton1Click:Connect(function()
    local injectedCount = 0
    for i = 1, 5 do
        makeGoldySlot()
        if tryInjectIntoMM2Inventory() then injectedCount = injectedCount + 1 end
    end
    setStatus("added 5 Goldy" ..
              (injectedCount > 0 and (" (" .. injectedCount .. " in mm2 ui)") or ""),
              Color3.fromRGB(255, 215, 60))
    task.delay(2, function() setStatus("ready") end)
end)

ClearButton.MouseButton1Click:Connect(function()
    clearInventory()
    setStatus("cleared", Color3.fromRGB(180, 180, 180))
    task.delay(1, function() setStatus("ready") end)
end)
