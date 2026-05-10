-- badtrip.script
-- Small black UI for MM2 with a red test button

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("badtrip") then
    PlayerGui.badtrip:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "badtrip"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 200, 0, 130)
Main.Position = UDim2.new(0.5, -100, 0.5, -65)
Main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(25, 25, 25)
MainStroke.Thickness = 1
MainStroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 24)
Title.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Title.BorderSizePixel = 0
Title.Text = "badtrip | mm2"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 6)
TitleCorner.Parent = Title

local TestButton = Instance.new("TextButton")
TestButton.Name = "TestButton"
TestButton.Size = UDim2.new(1, -20, 0, 32)
TestButton.Position = UDim2.new(0, 10, 0, 40)
TestButton.BackgroundColor3 = Color3.fromRGB(140, 20, 20)
TestButton.BorderSizePixel = 0
TestButton.Text = "Test"
TestButton.TextColor3 = Color3.fromRGB(240, 240, 240)
TestButton.Font = Enum.Font.GothamSemibold
TestButton.TextSize = 13
TestButton.AutoButtonColor = false
TestButton.Parent = Main

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 4)
BtnCorner.Parent = TestButton

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Color = Color3.fromRGB(70, 10, 10)
BtnStroke.Thickness = 1
BtnStroke.Parent = TestButton

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -20, 0, 40)
Status.Position = UDim2.new(0, 10, 0, 80)
Status.BackgroundTransparency = 1
Status.Text = "ready"
Status.TextColor3 = Color3.fromRGB(160, 160, 160)
Status.Font = Enum.Font.Gotham
Status.TextSize = 11
Status.TextWrapped = true
Status.Parent = Main

TestButton.MouseEnter:Connect(function()
    TestButton.BackgroundColor3 = Color3.fromRGB(170, 25, 25)
end)

TestButton.MouseLeave:Connect(function()
    TestButton.BackgroundColor3 = Color3.fromRGB(140, 20, 20)
end)

TestButton.MouseButton1Click:Connect(function()
    Status.Text = "button works!"
    Status.TextColor3 = Color3.fromRGB(120, 220, 120)
    task.wait(1.5)
    Status.Text = "ready"
    Status.TextColor3 = Color3.fromRGB(160, 160, 160)
end)
