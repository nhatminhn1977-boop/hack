local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- --- CẤU HÌNH HỆ THỐNG ---
local Config = {
    Dash = {Enabled = true, Method = "Root", Duration = 0.4}, -- 
    Skills = {
        [Enum.KeyCode.One] = {Enabled = true, Method = "Camera"}, -- 
        [Enum.KeyCode.Two] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Three] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.Four] = {Enabled = true, Method = "Camera"},
        [Enum.KeyCode.R] = {Enabled = true, Method = "Camera"}
    },
    LockTarget = false,
    ESPEnabled = true -- 
}

local target = nil
local isLocking = false
local currentMethod = "Camera"
local uiMinimized = false

-- --- GIAO DIỆN (UI) TỔNG HỢP ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 260, 0, 520); mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); mainFrame.Active = true; mainFrame.Draggable = true

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 0.9, 0); contentFrame.Position = UDim2.new(0, 0, 0.1, 0)
contentFrame.BackgroundTransparency = 1

-- Nút Rút gọn UI
local minBtn = Instance.new("TextButton", mainFrame)
minBtn.Size = UDim2.new(1, 0, 0.1, 0); minBtn.Text = "Rút gọn UI"; minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.MouseButton1Click:Connect(function()
    uiMinimized = not uiMinimized
    contentFrame.Visible = not uiMinimized
    mainFrame.Size = uiMinimized and UDim2.new(0, 260, 0, 40) or UDim2.new(0, 260, 0, 520)
end)

-- Thông tin mục tiêu
local avatarImg = Instance.new("ImageLabel", contentFrame)
avatarImg.Size = UDim2.new(0, 50, 0, 50); avatarImg.Position = UDim2.new(0.05, 0, 0.02, 0)
local nameLbl = Instance.new("TextLabel", contentFrame)
nameLbl.Size = UDim2.new(0, 180, 0, 50); nameLbl.Position = UDim2.new(0.3, 0, 0.02, 0); nameLbl.TextColor3 = Color3.new(1,1,1); nameLbl.BackgroundTransparency = 1; nameLbl.Text = "No Target"

local function createBtn(text, y, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 25); btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.TextColor3 = Color3.new(1,1,1); btn.Text = text
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- Các nút chức năng chính
createBtn("Lock Target: OFF", 70, contentFrame, function(btn)
    Config.LockTarget = not Config.LockTarget
    btn.Text = "Lock Target: " .. (Config.LockTarget and "ON" or "OFF")
end)

createBtn("ESP: ON", 100, contentFrame, function(btn)
    Config.ESPEnabled = not Config.ESPEnabled -- 
    btn.Text = "ESP: " .. (Config.ESPEnabled and "ON" or "OFF")
end)

createBtn("Auto Aim Dash: ON", 130, contentFrame, function(btn)
    Config.Dash.Enabled = not Config.Dash.Enabled
    btn.Text = "Auto Aim Dash: " .. (Config.Dash.Enabled and "ON" or "OFF")
end)

-- Quản lý Skill lẻ
local skillY = 170
for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}) do
    local skill = Config.Skills[key]
    createBtn("Skill " .. key.Name .. ": ON", skillY, contentFrame, function(btn)
        skill.Enabled = not skill.Enabled
        btn.Text = "Skill " .. key.Name .. ": " .. (skill.Enabled and "ON" or "OFF")
    end)
    createBtn("Mode " .. key.Name .. ": " .. skill.Method, skillY + 30, contentFrame, function(btn)
        skill.Method = (skill.Method == "Camera" and "Root" or "Camera") -- [cite: 3]
        btn.Text = "Mode " .. key.Name .. ": " .. skill.Method
    end)
    skillY = skillY + 65
end

-- --- LOGIC XỬ LÝ (AIM & BYPASS) ---
local function doAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Phá Shift Lock 
    task.wait(duration)
    if hum then hum.AutoRotate = true end
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    if input.KeyCode == Enum.KeyCode.Q and Config.Dash.Enabled then
        -- Side Dash Check (A, S, D) 
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
            -- Xoay người cứng (Bypass Shift Lock) 
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)

-- --- TARGETING & ESP (RESET 0.2S) ---
task.spawn(function()
    while task.wait(0.2) do
        -- Tìm mục tiêu mới nếu không Lock
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

        -- Cập nhật ESP và UI
        for _, p in pairs(Players:GetPlayers()) do
            local oldHl = p.Character and p.Character:FindFirstChild("PrimeHL")
            if oldHl then oldHl:Destroy() end
        end

        if target and target.Character then
            nameLbl.Text = target.Name
            pcall(function() avatarImg.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            if Config.ESPEnabled then -- 
                local hl = Instance.new("Highlight", target.Character); hl.Name = "PrimeHL"
                hl.FillColor = Color3.new(1, 0, 0)
            end
        else
            nameLbl.Text = "No Target"; avatarImg.Image = ""
        end
    end
end)
