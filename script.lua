local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- --- CẤU HÌNH ---
local Config = {
    -- SkillMethods: "Camera" hoặc "Root" [cite: 3]
    Skills = {
        [Enum.KeyCode.One] = "Camera",
        [Enum.KeyCode.Two] = "Camera",
        [Enum.KeyCode.Three] = "Camera",
        [Enum.KeyCode.Four] = "Camera",
        [Enum.KeyCode.R] = "Camera"
    }
}

local target = nil
local isLocking = false
local currentMethod = "Camera"

-- --- UI PRIME V2 (FIX NÚT) ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 380)
frame.Position = UDim2.new(0.05, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

-- Avatar và Tên
local avatarImg = Instance.new("ImageLabel", frame)
avatarImg.Size = UDim2.new(0, 50, 0, 50)
avatarImg.Position = UDim2.new(0.05, 0, 0.03, 0)

local nameLbl = Instance.new("TextLabel", frame)
nameLbl.Size = UDim2.new(0, 160, 0, 50)
nameLbl.Position = UDim2.new(0.3, 0, 0.03, 0)
nameLbl.TextColor3 = Color3.new(1, 1, 1)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = "No Target"

-- Hàm tạo nút chuẩn
local function createSkillBtn(keyCode, yPos)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = "Skill " .. keyCode.Name .. ": " .. Config.Skills[keyCode]
    
    btn.MouseButton1Click:Connect(function()
        if Config.Skills[keyCode] == "Camera" then
            Config.Skills[keyCode] = "Root"
        else
            Config.Skills[keyCode] = "Camera"
        end
        btn.Text = "Skill " .. keyCode.Name .. ": " .. Config.Skills[keyCode]
    end)
    return btn
end

-- Khởi tạo các nút [cite: 4]
createSkillBtn(Enum.KeyCode.One, 110)
createSkillBtn(Enum.KeyCode.Two, 150)
createSkillBtn(Enum.KeyCode.Three, 190)
createSkillBtn(Enum.KeyCode.Four, 230)
createSkillBtn(Enum.KeyCode.R, 270)

-- --- LOGIC AIM & BYPASS SHIFT LOCK ---
local function startAiming(method, duration)
    if not target then return end
    isLocking = true
    currentMethod = method
    
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end -- Bypass Shift Lock bằng cách tắt AutoRotate 
    
    task.wait(duration)
    
    if hum then hum.AutoRotate = true end
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    -- Dash Aim (Q) 
    if input.KeyCode == Enum.KeyCode.Q then
        -- Side Dash Check 
        local isSide = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
        if not isSide then
            startAiming("Root", 0.4)
        end
    -- Skill Aim [cite: 4]
    elseif Config.Skills[input.KeyCode] then
        startAiming(Config.Skills[input.KeyCode], 0.1)
    end
end)

-- RenderStepped xử lý xoay 
RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        
        if currentMethod == "Root" and root then
            -- Xoay nhân vật (Bypass Shift Lock)
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
        elseif currentMethod == "Camera" then
            -- Xoay Camera
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)

-- --- TARGET & ESP (RESET 0.2S) ---
task.spawn(function()
    while task.wait(0.2) do
        local closest, min = nil, 9999
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local dist = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if dist < min then min = dist; closest = p end
            end
        end
        
        -- Update Target
        target = closest
        
        -- Update UI & ESP
        for _, p in pairs(Players:GetPlayers()) do
            local hl = p.Character and p.Character:FindFirstChild("Highlight_Aim")
            if hl then hl:Destroy() end
        end
        
        if target then
            nameLbl.Text = target.Name
            pcall(function()
                avatarImg.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            
            -- Bôi người gần nhất
            local hl = Instance.new("Highlight", target.Character)
            hl.Name = "Highlight_Aim"
            hl.FillColor = Color3.new(1, 0, 0)
        else
            nameLbl.Text = "No Target"
            avatarImg.Image = ""
        end
    end
end)
