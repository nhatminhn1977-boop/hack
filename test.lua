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

local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}

local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then copy[k] = deepCopy(v) else copy[k] = v end
    end
    return copy
end

local CurrentSelectedProfile = 1
local Profiles = { [1] = { Name = "Default", Data = deepCopy(Config) } }

local target = nil
local isLocking = false
local currentMethod = "Camera"
local uiMinimized = false

-- GIAO DIỆN CHÍNH
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 290, 0, 650); mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); mainFrame.BorderSizePixel = 0
mainFrame.Active = true; mainFrame.ClipsDescendants = true 
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(0, 180, 216); Instance.new("UIStroke", mainFrame).Thickness = 1.5

local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 40); topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

-- LOGIC DRAG
local dragToggle, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true; dragStart = input.Position; startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end end)

-- NÚT HƯỚNG DẪN (?)
local helpBtn = Instance.new("TextButton", topBar)
helpBtn.Size = UDim2.new(0, 26, 0, 26); helpBtn.Position = UDim2.new(1, -65, 0, 7)
helpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45); helpBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
helpBtn.Text = "?"; Instance.new("UICorner", helpBtn).CornerRadius = UDim.new(0, 6)

local helpFrame = Instance.new("Frame", gui)
helpFrame.Size = UDim2.new(0, 300, 0, 250); helpFrame.Position = UDim2.new(0.5, -150, 0.5, -125); helpFrame.Visible = false
Instance.new("UICorner", helpFrame); Instance.new("UIStroke", helpFrame).Color = Color3.fromRGB(0, 255, 255)
local closeHelp = Instance.new("TextButton", helpFrame); closeHelp.Text = "X"; closeHelp.Size = UDim2.new(0,30,0,30); closeHelp.Position = UDim2.new(1, -30, 0, 0)
closeHelp.TextColor3 = Color3.new(1,0,0); closeHelp.BackgroundTransparency = 1
closeHelp.MouseButton1Click:Connect(function() helpFrame.Visible = false end)
helpBtn.MouseButton1Click:Connect(function() helpFrame.Visible = not helpFrame.Visible end)

-- NỘI DUNG HƯỚNG DẪN
local helpText = Instance.new("TextLabel", helpFrame)
helpText.Size = UDim2.new(1, 0, 1, 0); helpText.BackgroundTransparency = 1
helpText.Text = "Phím G: Chuyển Config\nPhím X: Reset Aim\nLock Target: Khóa mục tiêu\nESP: Định vị đối thủ"
helpText.TextColor3 = Color3.new(1,1,1)

-- CÁC NÚT VÀ LOGIC KHÁC (Đã fix lỗi TextBox mặc định)
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -40); contentFrame.Position = UDim2.new(0, 0, 0, 40); contentFrame.BackgroundTransparency = 1

local nameInput = Instance.new("TextBox", contentFrame)
nameInput.Text = ""; nameInput.PlaceholderText = "Nhập tên Config..." -- Đã fix
nameInput.Size = UDim2.new(0.65, 0, 0, 30); nameInput.Position = UDim2.new(0.06, 0, 0, 360)

local codeInput = Instance.new("TextBox", contentFrame)
codeInput.Text = ""; codeInput.PlaceholderText = "Mã xuất tại đây..." -- Đã fix
codeInput.Size = UDim2.new(0.88, 0, 0, 30); codeInput.Position = UDim2.new(0.06, 0, 0, 430)

-- LOGIC PHÍM TẮT G & HÀM CŨ
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.G then
        CurrentSelectedProfile = (CurrentSelectedProfile % #Profiles) + 1
        Config = deepCopy(Profiles[CurrentSelectedProfile].Data)
        print("Đã chuyển sang: " .. Profiles[CurrentSelectedProfile].Name)
    elseif input.KeyCode == Enum.KeyCode.X then
        -- Gọi lại hàm reset target của bạn ở đây
    end
end)
local function forceResetTarget()
    for _, p in pairs(Players:GetPlayers()) do
        local oldHl = p.Character and p.Character:FindFirstChild("PrimeHL")
        if oldHl then oldHl:Destroy() end
    end
    local myChar = player.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHead or (myHum and myHum.Health <= 0) then target = nil; nameLbl.Text = "🎯 No Target"; avatarImg.Image = ""; return end

    local closest, min = nil, 9999
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local pHum = p.Character:FindFirstChildOfClass("Humanoid")
            if pHum and pHum.Health > 0 then
                local d = (p.Character.Head.Position - myHead.Position).Magnitude
                if d < min then min = d; closest = p end
            end
        end
    end
    target = closest
    if target and target.Character and target.Character:FindFirstChild("Head") then
        nameLbl.Text = "🎯 " .. target.Name
        pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        if Config.ESPEnabled then 
            local hl = Instance.new("Highlight", target.Character); hl.Name = "PrimeHL"; hl.FillColor = Color3.new(1, 0, 0)
        end
    else
        nameLbl.Text = "🎯 No Target"; avatarImg.Image = ""
    end
end

resetBtn.MouseButton1Click:Connect(forceResetTarget)

local creditLbl = Instance.new("TextLabel", contentFrame)
creditLbl.Size = UDim2.new(1, 0, 0, 20)
creditLbl.Position = UDim2.new(0, 0, 0, 545)
creditLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
creditLbl.BackgroundTransparency = 1
creditLbl.Font = Enum.Font.Gotham
creditLbl.TextSize = 11
creditLbl.Text = "💎 Script by Nhật Minh 1602 💎" 

-- LOGIC CORE VÀ VÒNG LẶP (ĐƯỢC GIỮ NGUYÊN)
local function doAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end 
    task.wait(duration)
    if hum then hum.AutoRotate = true end
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.X then
        forceResetTarget()
        return
    end
    if not target then return end
    if input.KeyCode == Enum.KeyCode.Q and Config.Dash.Enabled then
        local movingSide = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D) 
        if not movingSide then doAim("Root", Config.Dash.Duration) end
    elseif Config.Skills[input.KeyCode] and Config.Skills[input.KeyCode].Enabled then
        doAim(Config.Skills[input.KeyCode].Method, 0.1)
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character and target.Character:FindFirstChild("Head") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local headPos = target.Character.Head.Position
        local root = player.Character.HumanoidRootPart
        if currentMethod == "Root" then
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        local myChar = player.Character
        local myHead = myChar and myChar:FindFirstChild("Head")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

        if not myHead or (myHum and myHum.Health <= 0) then
            target = nil
        else
            local targetHum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
            local targetDead = targetHum and targetHum.Health <= 0

            if not Config.LockTarget or not target or not target.Parent or not target.Character or not target.Character:FindFirstChild("Head") or targetDead then
                local closest, min = nil, 9999
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                        local pHum = p.Character:FindFirstChildOfClass("Humanoid")
                        if pHum and pHum.Health > 0 then
                            local d = (p.Character.Head.Position - myHead.Position).Magnitude
                            if d < min then min = d; closest = p end
                        end
                    end
                end
                target = closest
            end
        end
        
        for _, p in pairs(Players:GetPlayers()) do
            local oldHl = p.Character and p.Character:FindFirstChild("PrimeHL")
            if oldHl then oldHl:Destroy() end
        end

        if target and target.Character and target.Character:FindFirstChild("Head") then
            nameLbl.Text = "🎯 " .. target.Name
            pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            if Config.ESPEnabled then 
                local hl = Instance.new("Highlight", target.Character); hl.Name = "PrimeHL"; hl.FillColor = Color3.new(1, 0, 0)
            end
        else
            nameLbl.Text = "🎯 No Target"; avatarImg.Image = ""
        end
    end
end)
