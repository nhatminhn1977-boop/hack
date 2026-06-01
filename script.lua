local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- --- CẤU HÌNH NÂNG CAO  ---
local Config = {
    Dash = {Enabled = true, Method = "Root", Duration = 0.4},
    Skills = {
        [Enum.KeyCode.One] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Two] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Three] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Four] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.R] = {Enabled = true, Method = "Camera"}
    },
    LockTarget = false -- Mặc định là Off 
}

local target = nil
local isLocking = false
local currentMethod = "Camera"

-- --- UI ULTIMATE  ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 480)
frame.Position = UDim2.new(0.05, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true; frame.Draggable = true

local avatarImg = Instance.new("ImageLabel", frame)
avatarImg.Size = UDim2.new(0, 50, 0, 50); avatarImg.Position = UDim2.new(0.05, 0, 0.02, 0)

local nameLbl = Instance.new("TextLabel", frame)
nameLbl.Size = UDim2.new(0, 180, 0, 50); nameLbl.Position = UDim2.new(0.3, 0, 0.02, 0)
nameLbl.TextColor3 = Color3.new(1, 1, 1); nameLbl.BackgroundTransparency = 1; nameLbl.Text = "No Target"

-- Hàm tạo nút Toggle (Bật/Tắt) hoặc Method (Camera/Root) 
local function createToggle(text, y, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- Nút điều khiển chung 
createToggle("Lock Aim: OFF", 100, function(btn)
    Config.LockTarget = not Config.LockTarget
    btn.Text = "Lock Aim: " .. (Config.LockTarget and "ON" or "OFF")
end)

createToggle("Auto Aim Dash: ON", 135, function(btn)
    Config.Dash.Enabled = not Config.Dash.Enabled
    btn.Text = "Auto Aim Dash: " .. (Config.Dash.Enabled and "ON" or "OFF")
end)

-- Tạo các nút cho từng Skill 
local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}
for i, key in ipairs(keys) do
    local yBase = 170 + (i-1) * 60
    
    -- Nút Bật/Tắt Auto Aim Skill
    createToggle("Aim Skill " .. key.Name .. ": ON", yBase, function(btn)
        Config.Skills[key].Enabled = not Config.Skills[key].Enabled
        btn.Text = "Aim Skill " .. key.Name .. ": " .. (Config.Skills[key].Enabled and "ON" or "OFF")
    end)
    
    -- Nút Chỉnh Chế độ (Camera/Root)
    createToggle("Mode " .. key.Name .. ": " .. Config.Skills[key].Method, yBase + 25, function(btn)
        Config.Skills[key].Method = (Config.Skills[key].Method == "Camera" and "Root" or "Camera")
        btn.Text = "Mode " .. key.Name .. ": " .. Config.Skills[key].Method
    end)
end

-- --- LOGIC AIM & BYPASS  ---
local function startAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Bypass Shift Lock 
    task.wait(duration)
    if hum then hum.AutoRotate = true end
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    -- Dash Aim (Q) 
    if input.KeyCode == Enum.KeyCode.Q and Config.Dash.Enabled then
        -- Side Dash Check: Không aim khi giữ A, S, D 
        local isSide = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
        if not isSide then startAim("Root", Config.Dash.Duration) end
        
    -- Skill Aim (1, 2, 3, 4, R) [cite: 4]
    elseif Config.Skills[input.KeyCode] and Config.Skills[input.KeyCode].Enabled then
        startAim(Config.Skills[input.KeyCode].Method, 0.1)
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if currentMethod == "Root" and root then
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)

-- --- TARGETING & ESP (RESET 0.2S)  ---
task.spawn(function()
    while task.wait(0.2) do
        -- Chỉ tìm mục tiêu mới nếu KHÔNG bật Lock Aim 
        if not Config.LockTarget or target == nil then
            local closest, min = nil, 9999
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local dist = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                    if dist < min then min = dist; closest = p end
                end
            end
            target = closest
        end
        
        -- Cập nhật ESP & UI 
        for _, p in pairs(Players:GetPlayers()) do
            local hl = p.Character and p.Character:FindFirstChild("AimHighlight")
            if hl then hl:Destroy() end
        end
        
        if target and target.Character then
            nameLbl.Text = target.Name
            pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            
            -- ESP bôi người đang aim 
            local hl = Instance.new("Highlight", target.Character)
            hl.Name = "AimHighlight"; hl.FillColor = Color3.new(1, 0, 0)
        end
    end
end)
