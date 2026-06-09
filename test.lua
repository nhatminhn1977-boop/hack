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

-- ====================================================================
-- 🔥 HỆ THỐNG QUẢN LÝ PROFILE CONFIG (NEW)
-- ====================================================================
local CurrentSelectedProfile = 1
local Profiles = {
    [1] = { Name = "Profile 1", Data = nil },
    [2] = { Name = "Profile 2", Data = nil }
}

-- Hàm deep copy để sao lưu dữ liệu tránh bị dính tham chiếu (reference pointer)
local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Khởi tạo sẵn dữ liệu mặc định ban đầu cho cả 2 Profile
Profiles[1].Data = deepCopy(Config)
Profiles[2].Data = deepCopy(Config)
-- ====================================================================

local target = nil
local isLocking = false
local currentMethod = "Camera"
local uiMinimized = false

-- KHỞI TẠO MAINFRAME PHONG CÁCH MỚI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 280, 0, 520) -- Tăng chiều cao từ 480 lên 520 để có chỗ cho cụm nút Config
mainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true 

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(0, 180, 216)
mainStroke.Thickness = 1.5
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- THANH TIÊU ĐỀ (TOP BAR) HỖ TRỢ KÉO THẢ
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
topBar.BorderSizePixel = 0

local topBarCorner = Instance.new("UICorner", topBar)
topBarCorner.CornerRadius = UDim.new(0, 10)

local topBarPatch = Instance.new("Frame", topBar)
topBarPatch.Size = UDim2.new(1, 0, 0, 10)
topBarPatch.Position = UDim2.new(0, 0, 1, -10)
topBarPatch.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
topBarPatch.BorderSizePixel = 0

local dragToggle, dragStart, startPos
local dragInput

topBar.InputBegan:Connect(function(input)
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

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        game:GetService("TweenService"):Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = position}):Play()
    end
end)

-- NÚT THU GỌN MENU
local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(1, 0, 1, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "✨ NHẬT MINH HUB | Rút gọn UI"
minBtn.TextColor3 = Color3.fromRGB(0, 180, 216)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 13

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1

minBtn.MouseButton1Click:Connect(function()
    uiMinimized = not uiMinimized
    contentFrame.Visible = not uiMinimized
    if uiMinimized then
        mainFrame.Size = UDim2.new(0, 280, 0, 40)
        minBtn.Text = "✨ NHẬT MINH HUB | Mở rộng UI"
    else
        mainFrame.Size = UDim2.new(0, 280, 0, 520) -- Đồng bộ mở rộng theo chiều cao mới
        minBtn.Text = "✨ NHẬT MINH HUB | Rút gọn UI"
    end
end)

-- KHU VỰC HIỂN THỊ MỤC TIÊU (TARGET PROFILE)
local avatarImg = Instance.new("ImageLabel", contentFrame)
avatarImg.Size = UDim2.new(0, 45, 0, 45)
avatarImg.Position = UDim2.new(0.06, 0, 0, 12)
avatarImg.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
avatarImg.BorderSizePixel = 0

local avatarCorner = Instance.new("UICorner", avatarImg)
avatarCorner.CornerRadius = UDim.new(1, 0)

local avatarStroke = Instance.new("UIStroke", avatarImg)
avatarStroke.Color = Color3.fromRGB(55, 55, 65)
avatarStroke.Thickness = 1

local nameLbl = Instance.new("TextLabel", contentFrame)
nameLbl.Size = UDim2.new(0, 190, 0, 45)
nameLbl.Position = UDim2.new(0.28, 0, 0, 12)
nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = "🎯 No Target"
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 14
nameLbl.TextXAlignment = Enum.TextXAlignment.Left

-- HÀM TẠO NÚT CHÍNH VỚI HIỆU ỨNG ĐỔI MÀU TRỰC QUAN
local function updateButtonVisual(btn, state, activeText, inactiveText)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(0, 119, 182)
        btn.Text = activeText
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = Color3.fromRGB(0, 180, 216) end
    else
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.Text = inactiveText
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = Color3.fromRGB(55, 55, 65) end
    end
end

-- Định nghĩa trước các biến lưu Button để hàm Load Config có thể gọi cập nhật giao diện trực quan
local lockTargetBtn, espBtn, dashBtn
local skillUIReferences = {} -- Bảng lưu các nút Skill để làm mới UI khi load config

local function createMainBtn(text, y, callback, isActiveInit)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Size = UDim2.new(0.88, 0, 0, 32)
    btn.Position = UDim2.new(0.06, 0, 0, y)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Thickness = 1
    
    updateButtonVisual(btn, isActiveInit, text, text)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

lockTargetBtn = createMainBtn("🔒 Lock Target: OFF", 68, function(btn)
    Config.LockTarget = not Config.LockTarget
    updateButtonVisual(btn, Config.LockTarget, "🔒 Lock Target: ON", "🔒 Lock Target: OFF")
end, Config.LockTarget)

espBtn = createMainBtn("👁️ ESP NEAREST: ON", 106, function(btn)
    Config.ESPEnabled = not Config.ESPEnabled
    updateButtonVisual(btn, Config.ESPEnabled, "👁️ ESP NEAREST: ON", "👁️ ESP NEAREST: OFF")
end, Config.ESPEnabled)

dashBtn = createMainBtn("⚡ Auto Aim Dash: ON", 144, function(btn)
    Config.Dash.Enabled = not Config.Dash.Enabled
    updateButtonVisual(btn, Config.Dash.Enabled, "⚡ Auto Aim Dash: ON", "⚡ Auto Aim Dash: OFF")
end, Config.Dash.Enabled)

-- HỆ THỐNG NÚT ĐIỀU CHỈNH SKILLS TRỰC QUAN
local skillY = 188
for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}) do
    local skill = Config.Skills[key]
    
    local toggleBtn = Instance.new("TextButton", contentFrame)
    toggleBtn.Size = UDim2.new(0.42, 0, 0, 30)
    toggleBtn.Position = UDim2.new(0.06, 0, 0, skillY)
    toggleBtn.Font = Enum.Font.GothamMedium
    toggleBtn.TextSize = 12
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local tCorner = Instance.new("UICorner", toggleBtn)
    tCorner.CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke", toggleBtn)
    tStroke.Thickness = 1
    
    local function updateSkillToggleVisual()
        if skill.Enabled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(10, 135, 84)
            toggleBtn.Text = "🔥 Skill " .. key.Name .. ": ON"
            tStroke.Color = Color3.fromRGB(46, 204, 113)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 40, 40)
            toggleBtn.Text = "💤 Skill " .. key.Name .. ": OFF"
            tStroke.Color = Color3.fromRGB(120, 40, 40)
        end
    end
    updateSkillToggleVisual()
    
    toggleBtn.MouseButton1Click:Connect(function()
        skill.Enabled = not skill.Enabled
        updateSkillToggleVisual()
    end)
    
    local modeBtn = Instance.new("TextButton", contentFrame)
    modeBtn.Size = UDim2.new(0.42, 0, 0, 30)
    modeBtn.Position = UDim2.new(0.52, 0, 0, skillY)
    modeBtn.Font = Enum.Font.GothamMedium
    modeBtn.TextSize = 12
    modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local mCorner = Instance.new("UICorner", modeBtn)
    mCorner.CornerRadius = UDim.new(0, 6)
    local mStroke = Instance.new("UIStroke", modeBtn)
    mStroke.Thickness = 1
    
    local function updateSkillModeVisual()
        modeBtn.Text = "🎬 " .. skill.Method
        if skill.Method == "Camera" then
            modeBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
            mStroke.Color = Color3.fromRGB(165, 105, 189)
        else
            modeBtn.BackgroundColor3 = Color3.fromRGB(211, 84, 0)
            mStroke.Color = Color3.fromRGB(230, 126, 34)
        end
    end
    updateSkillModeVisual()
    
    modeBtn.MouseButton1Click:Connect(function()
        skill.Method = (skill.Method == "Camera" and "Root" or "Camera") 
        updateSkillModeVisual()
    end)
    
    -- Lưu lại reference để hệ thống Load Config có thể ép cập nhật giao diện
    skillUIReferences[key] = {
        UpdateToggle = updateSkillToggleVisual,
        UpdateMode = updateSkillModeVisual
    }
    
    skillY = skillY + 36
end

-- ====================================================================
-- 📦 KHỞI TẠO KHU VỰC ĐIỀU KHIỂN CONFIG VÀ LOADOUT (NEW)
-- ====================================================================
local configFrame = Instance.new("Frame", contentFrame)
configFrame.Size = UDim2.new(0.88, 0, 0, 32)
configFrame.Position = UDim2.new(0.06, 0, 0, 375) -- Đẩy vùng kĩ năng cũ xuống một chút
configFrame.BackgroundTransparency = 1

local profileBtn = Instance.new("TextButton", configFrame)
profileBtn.Size = UDim2.new(0.4, 0, 1, 0)
profileBtn.Position = UDim2.new(0, 0, 0, 0)
profileBtn.BackgroundColor3 = Color3.fromRGB(45, 52, 54)
profileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
profileBtn.Font = Enum.Font.GothamBold
profileBtn.TextSize = 11
profileBtn.Text = "📁 Profile 1"

local pCorner = Instance.new("UICorner", profileBtn)
pCorner.CornerRadius = UDim.new(0, 6)
local pStroke = Instance.new("UIStroke", profileBtn)
pStroke.Color = Color3.fromRGB(99, 110, 114)

-- Click để đổi nhanh giữa Profile 1 và Profile 2 qua lại công khai
profileBtn.MouseButton1Click:Connect(function()
    CurrentSelectedProfile = (CurrentSelectedProfile == 1 and 2 or 1)
    profileBtn.Text = "📁 " .. Profiles[CurrentSelectedProfile].Name
end)

local saveConfigBtn = Instance.new("TextButton", configFrame)
saveConfigBtn.Size = UDim2.new(0.28, 0, 1, 0)
saveConfigBtn.Position = UDim2.new(0.43, 0, 0, 0)
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
saveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveConfigBtn.Font = Enum.Font.GothamBold
saveConfigBtn.TextSize = 11
saveConfigBtn.Text = "💾 LƯU"

local sCorner = Instance.new("UICorner", saveConfigBtn)
sCorner.CornerRadius = UDim.new(0, 6)

-- Xử lý chức năng Lưu tất cả các nút hiện tại vào bộ nhớ Profile đang chọn
saveConfigBtn.MouseButton1Click:Connect(function()
    Profiles[CurrentSelectedProfile].Data = deepCopy(Config)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nhật Minh Hub",
        Text = "Đã lưu cài đặt vào " .. Profiles[CurrentSelectedProfile].Name,
        Duration = 2
    })
end)

local loadConfigBtn = Instance.new("TextButton", configFrame)
loadConfigBtn.Size = UDim2.new(0.26, 0, 1, 0)
loadConfigBtn.Position = UDim2.new(0.74, 0, 0, 0)
loadConfigBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
loadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadConfigBtn.Font = Enum.Font.GothamBold
loadConfigBtn.TextSize = 11
loadConfigBtn.Text = "🔌 TẢI"

local lCorner = Instance.new("UICorner", loadConfigBtn)
lCorner.CornerRadius = UDim.new(0, 6)

-- Xử lý chức năng Tải cấu hình từ Profile ra và ép đồng bộ lại giao diện UI trực quan
loadConfigBtn.MouseButton1Click:Connect(function()
    local savedData = Profiles[CurrentSelectedProfile].Data
    if savedData then
        Config = deepCopy(savedData)
        
        -- Làm mới trạng thái giao diện của 3 nút tính năng chính
        updateButtonVisual(lockTargetBtn, Config.LockTarget, "🔒 Lock Target: ON", "🔒 Lock Target: OFF")
        updateButtonVisual(espBtn, Config.ESPEnabled, "👁️ ESP NEAREST: ON", "👁️ ESP NEAREST: OFF")
        updateButtonVisual(dashBtn, Config.Dash.Enabled, "⚡ Auto Aim Dash: ON", "⚡ Auto Aim Dash: OFF")
        
        -- Duyệt vòng lặp làm mới toàn bộ chữ viết và màu sắc của 5 nút Skill
        for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}) do
            if skillUIReferences[key] then
                skillUIReferences[key].UpdateToggle()
                skillUIReferences[key].UpdateMode()
            end
        end
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nhật Minh Hub",
            Text = "Đã áp dụng cấu hình " .. Profiles[CurrentSelectedProfile].Name,
            Duration = 2
        })
    end
end)
-- ====================================================================

-- HÀM PHẢN HỒI RESET AIM LẬP TỨC (0 MILI GIÂY ĐỘ TRỄ)
local function forceResetTarget()
    for _, p in pairs(Players:GetPlayers()) do
        local oldHl = p.Character and p.Character:FindFirstChild("PrimeHL")
        if oldHl then oldHl:Destroy() end
    end

    local myChar = player.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

    if not myHead or (myHum and myHum.Health <= 0) then
        target = nil
        nameLbl.Text = "🎯 No Target"
        avatarImg.Image = ""
        return
    end

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
            local hl = Instance.new("Highlight", target.Character); hl.Name = "PrimeHL"
            hl.FillColor = Color3.new(1, 0, 0)
        end
    else
        nameLbl.Text = "🎯 No Target"
        avatarImg.Image = ""
    end
end

-- NÚT RESET SANG TRỌNG Ở DƯỚI CÙNG (Hạ thấp Y xuống 415 do chèn cụm nút Config)
local resetBtn = Instance.new("TextButton", contentFrame)
resetBtn.Size = UDim2.new(0.88, 0, 0, 34)
resetBtn.Position = UDim2.new(0.06, 0, 0, 415)
resetBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 13
resetBtn.Text = "🔄 Reset Current Aim (Phím X)"

local resetCorner = Instance.new("UICorner", resetBtn)
resetCorner.CornerRadius = UDim.new(0, 6)
local resetStroke = Instance.new("UIStroke", resetBtn)
resetStroke.Color = Color3.fromRGB(231, 76, 60)
resetStroke.Thickness = 1

resetBtn.MouseButton1Click:Connect(function()
    forceResetTarget()
end)

local creditLbl = Instance.new("TextLabel", contentFrame)
creditLbl.Size = UDim2.new(1, 0, 0, 20)
creditLbl.Position = UDim2.new(0, 0, 0, 455) -- Hạ thấp Y xuống 455 để cân bằng khoảng cách đáy
creditLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
creditLbl.BackgroundTransparency = 1
creditLbl.Font = Enum.Font.Gotham
creditLbl.TextSize = 11
creditLbl.Text = "💎 Script by Nhật Minh 1602 💎" 

-- LOGIC CORE VÀ VÒNG LẶP (ĐƯỢC GIỮ NGUYÊN HOÀN HẢO)
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
                local hl = Instance.new("Highlight", target.Character); hl.Name = "PrimeHL"
                hl.FillColor = Color3.new(1, 0, 0)
            end
        else
            nameLbl.Text = "🎯 No Target"; avatarImg.Image = ""
        end
    end
end)
