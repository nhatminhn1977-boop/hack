local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local BlockServiceRE = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("BlockService"):WaitForChild("RE")
local BlockActivate = BlockServiceRE:WaitForChild("Activated")
local BlockDeactivate = BlockServiceRE:WaitForChild("Deactivated")

local isAutoBlockEnabled = false
local unblockThread = nil
local connections = {}

local function getNearestTarget()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil, math.huge end
    local myPos = char.HumanoidRootPart.Position
    local nearest, minDist = nil, math.huge
    local charsFolder = workspace:FindFirstChild("Characters")
    
    if not charsFolder then return nil, math.huge end
    for _, target in pairs(charsFolder:GetChildren()) do
        if target ~= char and target:FindFirstChild("HumanoidRootPart") then
            local dist = (target.HumanoidRootPart.Position - myPos).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = target
            end
        end
    end
    return nearest, minDist
end

local function isTargetFacingMe(targetChar)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end

    local directionToMe = (char.HumanoidRootPart.Position - targetRoot.Position).Unit
    local dotProduct = math.clamp(targetRoot.CFrame.LookVector:Dot(directionToMe), -1, 1)
    
    return math.deg(math.acos(dotProduct)) <= 90
end

local function faceTargetAndBlock(targetChar)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart and targetRoot then
        humanoid.AutoRotate = false
        rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(targetRoot.Position.X, rootPart.Position.Y, targetRoot.Position.Z))
    end

    pcall(function() BlockActivate:FireServer(nil) end)

    if unblockThread then task.cancel(unblockThread) end
    unblockThread = task.delay(0.25, function()
        pcall(function() BlockDeactivate:FireServer() end)
        if humanoid then humanoid.AutoRotate = true end
        unblockThread = nil
    end)
end

local function monitorCharacter(char)
    if char == LocalPlayer.Character then return end
    local infoFolder = char:WaitForChild("Info", 5)
    if infoFolder then
        connections[char] = infoFolder.ChildAdded:Connect(function(child)
            if isAutoBlockEnabled and child.Name == "InSkill" then
                local nearest, dist = getNearestTarget()
                if nearest == char and dist <= 10 and isTargetFacingMe(char) then
                    faceTargetAndBlock(char)
                end
            end
        end)
    end
end

local charsFolder = workspace:WaitForChild("Characters")
for _, char in pairs(charsFolder:GetChildren()) do task.spawn(monitorCharacter, char) end
charsFolder.ChildAdded:Connect(function(char) task.spawn(monitorCharacter, char) end)
charsFolder.ChildRemoved:Connect(function(char)
    if connections[char] then
        connections[char]:Disconnect()
        connections[char] = nil
    end
end)

local UI_NAME = "AutoBlockUI"
local parent = (gethui and gethui()) or CoreGui
if parent:FindFirstChild(UI_NAME) then parent[UI_NAME]:Destroy() end

local ScreenGui = Instance.new("ScreenGui", parent)
ScreenGui.Name = UI_NAME

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 110, 0, 65)
MainFrame.Position = UDim2.new(0.5, -55, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -14, 0, 35)
ToggleBtn.Position = UDim2.new(0, 7, 0, 7)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

local CreLabel = Instance.new("TextLabel", MainFrame)
CreLabel.Size = UDim2.new(1, 0, 0, 15)
CreLabel.Position = UDim2.new(0, 0, 0, 45)
CreLabel.BackgroundTransparency = 1
CreLabel.Text = "cre: Minh"
CreLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
CreLabel.Font = Enum.Font.Gotham
CreLabel.TextSize = 10

ToggleBtn.MouseButton1Click:Connect(function()
    isAutoBlockEnabled = not isAutoBlockEnabled
    if isAutoBlockEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
        ToggleBtn.Text = "ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        ToggleBtn.Text = "OFF"
    end
end)

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
