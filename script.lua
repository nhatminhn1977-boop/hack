local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- --- CẤU HÌNH HỆ THỐNG ---
local Config = {
    Dash = {Enabled = true, Method = "Root", Duration = 0.4}, --[cite: 1]
    Skills = {
        [Enum.KeyCode.One] = {Enabled = true, Method = "Camera"}, --[cite: 3, 4]
        [Enum.KeyCode.Two] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Three] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Four] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.R] = {Enabled = true, Method = "Camera"}
    },
    LockTarget = false,
    ESPEnabled = true --[cite: 5]
}

local target = nil
local isLocking = false
local currentMethod = "Camera"
local uiMinimized = false

-- --- GIAO DIỆN (UI) FIX OVERFLOW & MINIMIZE ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 260, 0, 425) -- Chiều cao tối ưu mới[cite: 6]
mainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.Active = true; mainFrame.Draggable = true
mainFrame.ClipsDescendants = true -- Ẩn mọi thứ thừa thãi khi thu gọn[cite: 6]

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundTransparency = 1

-- Nút Thu gọn / Mở rộng (Fix lỗi kích thước)[cite: 6]
local minBtn = Instance.new("TextButton", mainFrame)
minBtn.Size = UDim2.new(1, 0, 0, 35) -- Cố định chiều cao 35 pixel không sợ bị bóp méo[cite: 6]
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
        mainFrame.Size = UDim2.new(0, 260, 0, 35) -- Thu gọn chỉ còn thanh tiêu đề[cite: 6]
        minBtn.Text = "Mở rộng UI"
    else
        mainFrame.Size = UDim2.new(0, 260, 0, 425) -- Trở lại kích thước cũ[cite: 6]
        minBtn.Text = "Rút gọn UI"
    end
end)

-- Khu vực thông tin mục tiêu[cite: 6]
local avatarImg = Instance.new("ImageLabel", contentFrame)
avatarImg.Size = UDim2.new(0, 45, 0, 45); avatarImg.Position = UDim2.new(0.05, 0, 0, 10)
local nameLbl = Instance.new("TextLabel", contentFrame)
nameLbl.Size = UDim2.new(0, 180, 0, 45); nameLbl.Position = UDim2.new(0.28, 0, 0, 10)
nameLbl.TextColor3 = Color3.new(1, 1, 1); nameLbl.BackgroundTransparency = 1; nameLbl.Text = "No Target"
nameLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Hàm tạo nút tính năng chính (Full Width)[cite: 6]
local function createMainBtn(text, y, callback)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 28); btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); btn.TextColor3 = Color3.new(1, 1, 1); btn.Text = text
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- Khởi tạo các nút chính[cite: 6]
createMainBtn("Lock Target: OFF", 65, function(btn)
    Config.LockTarget = not Config.LockTarget
    btn.Text = "Lock Target: " .. (Config.LockTarget and "ON" or "OFF")
end)

createMainBtn("ESP: ON", 100, function(btn)
    Config.ESPEnabled = not Config.ESPEnabled --[cite: 5]
    btn.Text = "ESP: " .. (Config.ESPEnabled and "ON" or "OFF")
end)

createMainBtn("Auto Aim Dash: ON", 135, function(btn)
    Config.Dash.Enabled = not Config.Dash.Enabled
    btn.Text = "Auto Aim Dash: " .. (Config.Dash.Enabled and "ON" or "OFF")
end)

-- Quản lý Skill (Thiết kế dạng hàng đôi - Side by Side giúp tiết kiệm diện tích)[cite: 3, 4, 6]
local skillY = 175
for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}) do
    local skill = Config.Skills[key]
    
    -- Nút bật/tắt bên trái[cite: 6]
    local toggleBtn = Instance.new("TextButton", contentFrame)
    toggleBtn.Size = UDim2.new(0.43, 0, 0, 28); toggleBtn.Position = UDim2.new(0.05, 0, 0, skillY)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Text = "Skill " .. key.Name .. ": ON"
    toggleBtn.MouseButton1Click:Connect(function()
        skill.Enabled = not skill.Enabled
        toggleBtn.Text = "Skill " .. key.Name .. ": " .. (skill.Enabled and "ON" or "OFF")
    end)
    
    -- Nút chỉnh chế độ bên phải[cite: 3, 6]
    local modeBtn = Instance.new("TextButton", contentFrame)
    modeBtn.Size = UDim2.new(0.43, 0, 0, 28); modeBtn.Position = UDim2.new(0.52, 0, 0, skillY)
    modeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45); modeBtn.TextColor3 = Color3.new(1, 1, 1)
    modeBtn.Text = "Mode: " .. skill.Method
    modeBtn.MouseButton1Click:Connect(function()
        skill.Method = (skill.Method == "Camera" and "Root" or "Camera") --[cite: 3]
        modeBtn.Text = "Mode: " .. skill.Method
    end)
    
    skillY = skillY + 35 -- Khoảng cách giãn cách ngắn hơn nhờ chia đôi hàng[cite: 6]
end

-- --- DÒNG CREDIT (CRE) CỦA BẠN ---[cite: 6]
local creditLbl = Instance.new("TextLabel", contentFrame)
creditLbl.Size = UDim2.new(1, 0, 0, 20)
creditLbl.Position = UDim2.new(0, 0, 0, 360) -- Nằm gọn gàng dưới đáy[cite: 6]
creditLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
creditLbl.BackgroundTransparency = 1
creditLbl.TextSize = 12
creditLbl.Text = "Script by Nhật Minh 1602" -- Bạn sửa tên bạn ở đây nhé![cite: 6]

-- --- LOGIC XỬ LÝ GAMEPLAY (AIM & BYPASS) ---
local function doAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Phá vỡ vòng lặp tự xoay của Shift Lock[cite: 1]
    task.wait(duration)
    if hum then hum.AutoRotate = true end
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    if input.KeyCode == Enum.KeyCode.Q and Config.Dash.Enabled then
        -- Logic chặn ngắm khi dùng Side Dash (giữ A, S, D)[cite: 2]
        local movingSide = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
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
            -- Bypass hoàn toàn camera góc nhìn thứ 3 (Shift Lock)[cite: 1]
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)

-- --- TARGETING & ESP LOOPS (RESET CHUẨN ĐỊNH KỲ 0.2S) ---
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
