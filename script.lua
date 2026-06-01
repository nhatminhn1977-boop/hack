local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local Config = {
    Dash = {Enabled = true, Method = "Root", Duration = 0.4}, 
    Skills = {
        [Enum.KeyCode.One] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Two] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Three] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Four] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.R] = {Enabled = true, Method = "Camera"}
    },
    LockTarget = false,
    ESPEnabled = true 
}
local target = nil
local isLocking = false
local currentMethod = "Camera"
local uiMinimized = false
local gui = Instance.new("ScreenGui", player.PlayerGui)
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 260, 0, 425)
mainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.Active = true
mainFrame.ClipsDescendants = true 
local dragToggle, dragStart, startPos
local dragInput
local function updateInput(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    game:GetService("TweenService"):Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = position}):Play()
end
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        updateInput(input)
    end
end)
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1
local minBtn = Instance.new("TextButton", mainFrame)
minBtn.Size = UDim2.new(1, 0, 0, 35)
minBtn.Position = UDim2.new(0, 0, 0, 0)
minBtn.Text = "Rút gọn UI"
minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 14
minBtn.MouseButton1Click:Connect(function()
    uiMinimized = not uiMinimized
    contentFrame.Visible = not uiMinimized
    if uiMinimized then
        mainFrame.Size = UDim2.new(0, 260, 0, 35)
        minBtn.Text = "Mở rộng UI"
    else
        mainFrame.Size = UDim2.new(0, 260, 0, 425)
        minBtn.Text = "Rút gọn UI"
    end
end)
local avatarImg = Instance.new("ImageLabel", contentFrame)
avatarImg.Size = UDim2.new(0, 45, 0, 45); avatarImg.Position = UDim2.new(0.05, 0, 0, 10)
local nameLbl = Instance.new("TextLabel", contentFrame)
nameLbl.Size = UDim2.new(0, 180, 0, 45); nameLbl.Position = UDim2.new(0.28, 0, 0, 10)
nameLbl.TextColor3 = Color3.new(1, 1, 1); nameLbl.BackgroundTransparency = 1; nameLbl.Text = "No Target"
nameLbl.TextXAlignment = Enum.TextXAlignment.Left
local function createMainBtn(text, y, callback)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 28); btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.TextColor3 = Color3.new(1, 1, 1); btn.Text = text
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end
createMainBtn("Lock Target: OFF", 65, function(btn)
    Config.LockTarget = not Config.LockTarget
    btn.Text = "Lock Target: " .. (Config.LockTarget and "ON" or "OFF")
end)
createMainBtn("ESP: ON", 100, function(btn)
    Config.ESPEnabled = not Config.ESPEnabled
    btn.Text = "ESP: " .. (Config.ESPEnabled and "ON" or "OFF")
end)

createMainBtn("Auto Aim Dash: ON", 135, function(btn)
    Config.Dash.Enabled = not Config.Dash.Enabled
    btn.Text = "Auto Aim Dash: " .. (Config.Dash.Enabled and "ON" or "OFF")
end)
local skillY = 175
for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}) do
    local skill = Config.Skills[key]
    local toggleBtn = Instance.new("TextButton", contentFrame)
    toggleBtn.Size = UDim2.new(0.43, 0, 0, 28); toggleBtn.Position = UDim2.new(0.05, 0, 0, skillY)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Text = "Skill " .. key.Name .. ": ON"
    toggleBtn.MouseButton1Click:Connect(function()
        skill.Enabled = not skill.Enabled
        toggleBtn.Text = "Skill " .. key.Name .. ": " .. (skill.Enabled and "ON" or "OFF")
    end)
    local modeBtn = Instance.new("TextButton", contentFrame)
    modeBtn.Size = UDim2.new(0.43, 0, 0, 28); modeBtn.Position = UDim2.new(0.52, 0, 0, skillY)
    modeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); modeBtn.TextColor3 = Color3.new(1, 1, 1)
    modeBtn.Text = "Mode: " .. skill.Method
    modeBtn.MouseButton1Click:Connect(function()
        skill.Method = (skill.Method == "Camera" and "Root" or "Camera") --[cite: 3]
        modeBtn.Text = "Mode: " .. skill.Method
    end)
    
    skillY = skillY + 35
end
local creditLbl = Instance.new("TextLabel", contentFrame)
creditLbl.Size = UDim2.new(1, 0, 0, 20)
creditLbl.Position = UDim2.new(0, 0, 0, 360) 
creditLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
creditLbl.BackgroundTransparency = 1
creditLbl.TextSize = 12
creditLbl.Text = "Script by Nhật Minh 1602" 
local function doAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Phá Shift Lock[cite: 1]
    task.wait(duration)
    if hum then hum.AutoRotate = true end
    isLocking = false
end
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    if input.KeyCode == Enum.KeyCode.Q and Config.Dash.Enabled then
        local movingSide = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D) --[cite: 2]
        if not movingSide then doAim("Root", Config.Dash.Duration) end
    elseif Config.Skills[input.KeyCode] and Config.Skills[input.KeyCode].Enabled then
        doAim(Config.Skills[input.KeyCode].Method, 0.1)
    end
end)
RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if currentMethod == "Root" and root then
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z)) --[cite: 1]
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)
task.spawn(function()
    while task.wait(0.2) do
        if not Config.LockTarget or not target or not target.Parent then
            local closest, min = nil, 9999
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local d = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                    if d < min then min = d; closest = p end
                end
            end
            target = closest
        end
        for _, p in pairs(Players:GetPlayers()) do
            local oldHl = p.Character and p.Character:FindFirstChild("PrimeHL")
            if oldHl then oldHl:Destroy() end
        end

        if target and target.Character then
            nameLbl.Text = target.Name
            pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            if Config.ESPEnabled then --[cite: 5]
                local hl = Instance.new("Highlight", target.Character); hl.Name = "PrimeHL"
                hl.FillColor = Color3.new(1, 0, 0)
            end
        else
            nameLbl.Text = "No Target"; avatarImg.Image = ""
        end
    end
end)
