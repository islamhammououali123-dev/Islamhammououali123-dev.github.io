-- badtrip.script
-- Black MM2 UI with neon-bordered realistic buttons
-- Visual Goldy spawner (client-side visual only)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("badtrip") then
    PlayerGui.badtrip:Destroy()
end

local SpawnedFolder = Workspace:FindFirstChild("badtrip_goldy")
if SpawnedFolder then SpawnedFolder:Destroy() end
SpawnedFolder = Instance.new("Folder")
SpawnedFolder.Name = "badtrip_goldy"
SpawnedFolder.Parent = Workspace

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
Main.Size = UDim2.new(0, 220, 0, 290)
Main.Position = UDim2.new(0.5, -110, 0.5, -145)
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

    -- inner gradient for "realistic" depth
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 28)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 14, 14)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 4, 4))
    })
    grad.Rotation = 90
    grad.Parent = btn

    -- neon border
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = opts.NeonColor or Color3.fromRGB(255, 200, 40)
    stroke.Thickness = 1.4
    stroke.Transparency = 0.1
    stroke.Parent = btn

    -- highlight line on top for realism
    local highlight = Instance.new("Frame")
    highlight.Size = UDim2.new(1, -6, 0, 1)
    highlight.Position = UDim2.new(0, 3, 0, 1)
    highlight.BorderSizePixel = 0
    highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    highlight.BackgroundTransparency = 0.85
    highlight.Parent = btn

    -- hover and click animations
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
-- Test button (red)
----------------------------------------------------------------
local TestButton = makeButton({
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 36),
    Text = "Test",
    NeonColor = Color3.fromRGB(255, 60, 60)
})
TestButton.TextColor3 = Color3.fromRGB(255, 200, 200)

----------------------------------------------------------------
-- Spawn button (single goldy) - gold neon
----------------------------------------------------------------
local SpawnButton = makeButton({
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 74),
    Text = "Spawn",
    NeonColor = Color3.fromRGB(255, 200, 40)
})

----------------------------------------------------------------
-- Amount textbox
----------------------------------------------------------------
local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(1, -20, 0, 28)
AmountBox.Position = UDim2.new(0, 10, 0, 112)
AmountBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
AmountBox.BorderSizePixel = 0
AmountBox.Text = ""
AmountBox.PlaceholderText = "amount (1 - 50)"
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

----------------------------------------------------------------
-- Spawn All Goldy button
----------------------------------------------------------------
local SpawnAllButton = makeButton({
    Parent = Main,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 150),
    Text = "Spawn All Goldy",
    NeonColor = Color3.fromRGB(255, 215, 70)
})
SpawnAllButton.TextColor3 = Color3.fromRGB(255, 230, 150)

----------------------------------------------------------------
-- Status label
----------------------------------------------------------------
local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.new(0, 10, 1, -38)
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
-- Visual Goldy spawner (CLIENT-SIDE VISUAL ONLY)
-- Builds a glowing gold knife model that floats near you.
-- This is purely visual on your screen and does not affect gameplay.
----------------------------------------------------------------
local function buildGoldyVisual(originCFrame, index, total)
    local model = Instance.new("Model")
    model.Name = "VisualGoldy"

    -- handle
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 0.4, 1.6)
    handle.Material = Enum.Material.Neon
    handle.Color = Color3.fromRGB(120, 80, 0)
    handle.CanCollide = false
    handle.Anchored = true
    handle.TopSurface = Enum.SurfaceType.Smooth
    handle.BottomSurface = Enum.SurfaceType.Smooth
    handle.Parent = model

    -- blade
    local blade = Instance.new("Part")
    blade.Name = "Blade"
    blade.Size = Vector3.new(0.25, 0.6, 2.2)
    blade.Material = Enum.Material.Neon
    blade.Color = Color3.fromRGB(255, 215, 60)
    blade.CanCollide = false
    blade.Anchored = true
    blade.TopSurface = Enum.SurfaceType.Smooth
    blade.BottomSurface = Enum.SurfaceType.Smooth
    blade.Parent = model

    -- shape blade with wedge mesh look
    local bladeMesh = Instance.new("SpecialMesh")
    bladeMesh.MeshType = Enum.MeshType.Wedge
    bladeMesh.Scale = Vector3.new(1, 1, 1.4)
    bladeMesh.Parent = blade

    -- glow
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 220, 90)
    light.Brightness = 2
    light.Range = 8
    light.Parent = blade

    -- name tag
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 80, 0, 20)
    bb.StudsOffset = Vector3.new(0, 1.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = handle
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Goldy"
    lbl.TextColor3 = Color3.fromRGB(255, 215, 60)
    lbl.TextStrokeTransparency = 0.3
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.Parent = bb

    model.Parent = SpawnedFolder

    -- arrange in a circle around origin
    local angle = (index / math.max(total, 1)) * math.pi * 2
    local radius = math.min(4 + total * 0.2, 12)
    local offset = Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)
    local basePos = originCFrame.Position + offset

    handle.CFrame = CFrame.new(basePos)
    blade.CFrame = handle.CFrame * CFrame.new(0, 0, -1.3)

    -- floating + spinning animation
    local startTime = tick() + index * 0.1
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not model.Parent then conn:Disconnect() return end
        local t = tick() - startTime
        local bob = math.sin(t * 2) * 0.4
        local spin = CFrame.Angles(0, t * 1.5, 0)
        local newCF = CFrame.new(basePos + Vector3.new(0, bob, 0)) * spin
        handle.CFrame = newCF
        blade.CFrame = newCF * CFrame.new(0, 0, -1.3)
    end)

    return model
end

local function clearVisuals()
    for _, c in ipairs(SpawnedFolder:GetChildren()) do
        c:Destroy()
    end
end

local function getOriginCFrame()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart.CFrame
    end
    return CFrame.new(0, 5, 0)
end

----------------------------------------------------------------
-- Button actions
----------------------------------------------------------------
TestButton.MouseButton1Click:Connect(function()
    setStatus("button works!", Color3.fromRGB(120, 220, 120))
    task.delay(1.5, function() setStatus("ready") end)
end)

SpawnButton.MouseButton1Click:Connect(function()
    buildGoldyVisual(getOriginCFrame(), 1, 1)
    setStatus("spawned 1 visual goldy", Color3.fromRGB(255, 215, 60))
    task.delay(1.5, function() setStatus("ready") end)
end)

SpawnAllButton.MouseButton1Click:Connect(function()
    local n = tonumber(AmountBox.Text)
    if not n then n = 10 end
    n = math.clamp(math.floor(n), 1, 50)
    clearVisuals()
    local origin = getOriginCFrame()
    for i = 1, n do
        buildGoldyVisual(origin, i, n)
    end
    setStatus("spawned " .. n .. " visual goldy", Color3.fromRGB(255, 215, 60))
    task.delay(2, function() setStatus("ready") end)
end)
