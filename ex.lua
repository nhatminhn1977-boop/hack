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

-- Mảng chứa thứ tự phím
local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}

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

-- ====================================================================
-- 🔥 HỆ THỐNG QUẢN LÝ PROFILE CONFIG
-- ====================================================================
local CurrentSelectedProfile = 1
local Profiles = {
    [1] = { Name = "Default", Data = deepCopy(Config) }
}

local target = nil
local isLocking = false
local currentMethod = "Camera"
local uiMinimized = false

-- KHỞI TẠO MAINFRAME
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 290, 0, 650)
mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
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

-- THANH TIÊU ĐỀ
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
topBar.BorderSizePixel = 0
topBar.Active = true 

local topBarCorner = Instance.new("UICorner", topBar)
topBarCorner.CornerRadius = UDim.new(0, 10)

local topBarPatch = Instance.new("Frame", topBar)
topBarPatch.Size = UDim2.new(1, 0, 0, 10)
topBarPatch.Position = UDim2.new(0, 0, 1, -10)
topBarPatch.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
topBarPatch.BorderSizePixel = 0

-- LOGIC DRAG UI
local dragToggle, dragStart, startPos
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

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragToggle then
            local delta = input.Position - dragStart
            local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            mainFrame.Position = position
        end
    end
end)

-- NÚT THU GỌN MENU
local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(1, -40, 1, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "✨ NHẬT MINH HUB | Rút gọn UI"
minBtn.TextColor3 = Color3.fromRGB(0, 180, 216)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 13

-- NÚT HƯỚNG DẪN (?)
local helpBtn = Instance.new("TextButton", topBar)
helpBtn.Size = UDim2.new(0, 26, 0, 26)
helpBtn.Position = UDim2.new(1, -35, 0, 7)
helpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
helpBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
helpBtn.Text = "?"
helpBtn.Font = Enum.Font.GothamBold
local helpCorner = Instance.new("UICorner", helpBtn); helpCorner.CornerRadius = UDim.new(0, 6)

local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1

minBtn.MouseButton1Click:Connect(function()
    uiMinimized = not uiMinimized
    contentFrame.Visible = not uiMinimized
    if uiMinimized then
        mainFrame.Size = UDim2.new(0, 290, 0, 40)
        minBtn.Text = "✨ NHẬT MINH HUB | Mở rộng UI"
    else
        mainFrame.Size = UDim2.new(0, 290, 0, 650)
        minBtn.Text = "✨ NHẬT MINH HUB | Rút gọn UI"
    end
end)

-- BẢNG HELP UI
local helpFrame = Instance.new("Frame", gui)
helpFrame.Size = UDim2.new(0, 450, 0, 280) -- Rộng 450, Cao 280 (Bạn có thể tăng giảm số 450 và 280 tùy ý)
helpFrame.Position = UDim2.new(0.5, -225, 0.5, -140)
helpFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
helpFrame.Visible = false
local hc = Instance.new("UICorner", helpFrame); hc.CornerRadius = UDim.new(0, 10)
local hs = Instance.new("UIStroke", helpFrame); hs.Color = Color3.fromRGB(0, 255, 255); hs.Thickness = 1.5

local helpTitle = Instance.new("TextLabel", helpFrame)
helpTitle.Size = UDim2.new(1, 0, 0, 30)
helpTitle.Text = "HƯỚNG DẪN SỬ DỤNG"
helpTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
helpTitle.BackgroundTransparency = 1
helpTitle.Font = Enum.Font.GothamBold

local helpText = Instance.new("TextLabel", helpFrame)
helpText.Size = UDim2.new(1, -20, 1, -40)
helpText.Position = UDim2.new(0, 10, 0, 30)
helpText.Text = "- THIS SCRIPT IS NO KEY\- Bấm vào khu config để switch hoặc bấm G\n- Phím X: Reset mục tiêu (Aim)\n- Chế độ camera:xoay cam về mục tiêu\n- Chế độ root:xoay người về mục tiêu\n- Aim là aim người chơi gần nhất,có thể lock nếu muốn\n- Để lưu config,trước tiên chỉnh theo ý rồi bấm lưu.Bấm tải để load\n- Reset current Aim chỉ cần thiết khi lỗi hoặc đang khóa Aim\n- Bấm xuất mã để load config từ mã\n- SCRIPT CHỈ HOẠT ĐỘNG TRÊN MÁY TÍNH\n- Lỗi báo về nhatminhn1977@gmail.com\n- UI Design by Gemini\n- Core & Function Design by Nhật Minh"
helpText.TextColor3 = Color3.fromRGB(255, 255, 255)
helpText.BackgroundTransparency = 1
helpText.Font = Enum.Font.Gotham
helpText.TextSize = 13
helpText.TextXAlignment = Enum.TextXAlignment.Left
helpText.TextYAlignment = Enum.TextYAlignment.Top

local closeHelp = Instance.new("TextButton", helpFrame)
closeHelp.Size = UDim2.new(0, 30, 0, 30)
closeHelp.Position = UDim2.new(1, -30, 0, 0)
closeHelp.Text = "X"
closeHelp.TextColor3 = Color3.fromRGB(255, 50, 50)
closeHelp.BackgroundTransparency = 1
closeHelp.Font = Enum.Font.GothamBold
closeHelp.MouseButton1Click:Connect(function() helpFrame.Visible = false end)
helpBtn.MouseButton1Click:Connect(function() helpFrame.Visible = not helpFrame.Visible end)

-- AVATAR VÀ TARGET
local avatarImg = Instance.new("ImageLabel", contentFrame)
avatarImg.Size = UDim2.new(0, 45, 0, 45)
avatarImg.Position = UDim2.new(0.06, 0, 0, 12)
avatarImg.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
avatarImg.BorderSizePixel = 0

local avatarCorner = Instance.new("UICorner", avatarImg)
avatarCorner.CornerRadius = UDim.new(1, 0)

local nameLbl = Instance.new("TextLabel", contentFrame)
nameLbl.Size = UDim2.new(0, 190, 0, 45)
nameLbl.Position = UDim2.new(0.28, 0, 0, 12)
nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = "🎯 No Target"
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 14
nameLbl.TextXAlignment = Enum.TextXAlignment.Left

-- NÚT CHÍNH
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

local lockTargetBtn, espBtn, dashBtn
local skillUIReferences = {}

local function createMainBtn(text, y, callback, isActiveInit)
    local btn = Instance.new("TextButton", contentFrame)
    btn.Size = UDim2.new(0.88, 0, 0, 32)
    btn.Position = UDim2.new(0.06, 0, 0, y)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    local btnCorner = Instance.new("UICorner", btn); btnCorner.CornerRadius = UDim.new(0, 6)
    local btnStroke = Instance.new("UIStroke", btn); btnStroke.Thickness = 1
    
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

-- NÚT SKILLS
local skillY = 184
for _, key in ipairs(skillKeys) do
    local toggleBtn = Instance.new("TextButton", contentFrame)
    toggleBtn.Size = UDim2.new(0.42, 0, 0, 30)
    toggleBtn.Position = UDim2.new(0.06, 0, 0, skillY)
    toggleBtn.Font = Enum.Font.GothamMedium
    toggleBtn.TextSize = 12
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    local tCorner = Instance.new("UICorner", toggleBtn); tCorner.CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke", toggleBtn); tStroke.Thickness = 1
    
    local function updateSkillToggleVisual()
        local currentSkill = Config.Skills[key]
        if currentSkill.Enabled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(10, 135, 84)
            toggleBtn.Text = "🔥 Skill " .. key.Name .. ": ON"
            tStroke.Color = Color3.fromRGB(46, 204, 113)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 40, 40)
            toggleBtn.Text = "💤 Skill " .. key.Name .. ": OFF"
            tStroke.Color = Color3.fromRGB(120, 40, 40)
        end
    end
    
    toggleBtn.MouseButton1Click:Connect(function()
        Config.Skills[key].Enabled = not Config.Skills[key].Enabled
        updateSkillToggleVisual()
    end)
    
    local modeBtn = Instance.new("TextButton", contentFrame)
    modeBtn.Size = UDim2.new(0.42, 0, 0, 30)
    modeBtn.Position = UDim2.new(0.52, 0, 0, skillY)
    modeBtn.Font = Enum.Font.GothamMedium
    modeBtn.TextSize = 12
    modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    local mCorner = Instance.new("UICorner", modeBtn); mCorner.CornerRadius = UDim.new(0, 6)
    local mStroke = Instance.new("UIStroke", modeBtn); mStroke.Thickness = 1
    
    local function updateSkillModeVisual()
        local currentSkill = Config.Skills[key]
        modeBtn.Text = "🎬 " .. currentSkill.Method
        if currentSkill.Method == "Camera" then
            modeBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
            mStroke.Color = Color3.fromRGB(165, 105, 189)
        else
            modeBtn.BackgroundColor3 = Color3.fromRGB(211, 84, 0)
            mStroke.Color = Color3.fromRGB(230, 126, 34)
        end
    end
    
    modeBtn.MouseButton1Click:Connect(function()
        Config.Skills[key].Method = (Config.Skills[key].Method == "Camera" and "Root" or "Camera") 
        updateSkillModeVisual()
    end)
    
    updateSkillToggleVisual()
    updateSkillModeVisual()
    
    skillUIReferences[key] = {
        UpdateToggle = updateSkillToggleVisual,
        UpdateMode = updateSkillModeVisual
    }
    
    skillY = skillY + 34
end

-- ====================================================================
-- 📦 KHU VỰC ĐIỀU KHIỂN CONFIG MỚI (ĐÃ FIX LỖI TEXTBOX)
-- ====================================================================

local createFrame = Instance.new("Frame", contentFrame)
createFrame.Size = UDim2.new(0.88, 0, 0, 30)
createFrame.Position = UDim2.new(0.06, 0, 0, 360)
createFrame.BackgroundTransparency = 1

local nameInput = Instance.new("TextBox", createFrame)
nameInput.Size = UDim2.new(0.65, 0, 1, 0)
nameInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.PlaceholderText = "Nhập tên Config để tạo..."
nameInput.Text = "" -- Đã được fix
nameInput.Font = Enum.Font.Gotham
nameInput.TextSize = 12
local nCorner = Instance.new("UICorner", nameInput); nCorner.CornerRadius = UDim.new(0, 6)

local createBtn = Instance.new("TextButton", createFrame)
createBtn.Size = UDim2.new(0.3, 0, 1, 0)
createBtn.Position = UDim2.new(0.7, 0, 0, 0)
createBtn.BackgroundColor3 = Color3.fromRGB(0, 168, 255)
createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
createBtn.Text = "TẠO"
createBtn.Font = Enum.Font.GothamBold
createBtn.TextSize = 12
local crCorner = Instance.new("UICorner", createBtn); crCorner.CornerRadius = UDim.new(0, 6)

local manageFrame = Instance.new("Frame", contentFrame)
manageFrame.Size = UDim2.new(0.88, 0, 0, 30)
manageFrame.Position = UDim2.new(0.06, 0, 0, 395)
manageFrame.BackgroundTransparency = 1

local profileBtn = Instance.new("TextButton", manageFrame)
profileBtn.Size = UDim2.new(0.4, 0, 1, 0)
profileBtn.BackgroundColor3 = Color3.fromRGB(45, 52, 54)
profileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
profileBtn.Font = Enum.Font.GothamBold
profileBtn.TextSize = 11
profileBtn.Text = "📁 " .. Profiles[CurrentSelectedProfile].Name
local pCorner = Instance.new("UICorner", profileBtn); pCorner.CornerRadius = UDim.new(0, 6)

local saveBtn = Instance.new("TextButton", manageFrame)
saveBtn.Size = UDim2.new(0.28, 0, 1, 0)
saveBtn.Position = UDim2.new(0.43, 0, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Text = "💾 LƯU"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 11
local sCorner = Instance.new("UICorner", saveBtn); sCorner.CornerRadius = UDim.new(0, 6)

local loadBtn = Instance.new("TextButton", manageFrame)
loadBtn.Size = UDim2.new(0.26, 0, 1, 0)
loadBtn.Position = UDim2.new(0.74, 0, 0, 0)
loadBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.Text = "🔌 TẢI"
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 11
local lCorner = Instance.new("UICorner", loadBtn); lCorner.CornerRadius = UDim.new(0, 6)

local codeFrame = Instance.new("Frame", contentFrame)
codeFrame.Size = UDim2.new(0.88, 0, 0, 65)
codeFrame.Position = UDim2.new(0.06, 0, 0, 430)
codeFrame.BackgroundTransparency = 1

local codeInput = Instance.new("TextBox", codeFrame)
codeInput.Size = UDim2.new(1, 0, 0, 30)
codeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
codeInput.TextColor3 = Color3.fromRGB(0, 255, 150)
codeInput.PlaceholderText = "Nhập hoặc lấy mã xuất tại đây..."
codeInput.Text = "" -- Đã được fix
codeInput.TextXAlignment = Enum.TextXAlignment.Left
codeInput.TextScaled = true
codeInput.Font = Enum.Font.Code
codeInput.ClearTextOnFocus = false
local cCorner = Instance.new("UICorner", codeInput); cCorner.CornerRadius = UDim.new(0, 6)

local exportBtn = Instance.new("TextButton", codeFrame)
exportBtn.Size = UDim2.new(0.48, 0, 0, 30)
exportBtn.Position = UDim2.new(0, 0, 0, 35)
exportBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exportBtn.Text = "📤 XUẤT MÃ"
exportBtn.Font = Enum.Font.GothamBold
exportBtn.TextSize = 11
local eCorner = Instance.new("UICorner", exportBtn); eCorner.CornerRadius = UDim.new(0, 6)

local importBtn = Instance.new("TextButton", codeFrame)
importBtn.Size = UDim2.new(0.48, 0, 0, 30)
importBtn.Position = UDim2.new(0.52, 0, 0, 35)
importBtn.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
importBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
importBtn.Text = "📥 ÁP DỤNG"
importBtn.Font = Enum.Font.GothamBold
importBtn.TextSize = 11
local iCorner = Instance.new("UICorner", importBtn); iCorner.CornerRadius = UDim.new(0, 6)

-- --- CÁC HÀM XỬ LÝ CHỨC NĂNG CONFIG ---

local function refreshUIFromConfig()
    updateButtonVisual(lockTargetBtn, Config.LockTarget, "🔒 Lock Target: ON", "🔒 Lock Target: OFF")
    updateButtonVisual(espBtn, Config.ESPEnabled, "👁️ ESP NEAREST: ON", "👁️ ESP NEAREST: OFF")
    updateButtonVisual(dashBtn, Config.Dash.Enabled, "⚡ Auto Aim Dash: ON", "⚡ Auto Aim Dash: OFF")
    for _, key in ipairs(skillKeys) do
        skillUIReferences[key].UpdateToggle()
        skillUIReferences[key].UpdateMode()
    end
end

createBtn.MouseButton1Click:Connect(function()
    local newName = nameInput.Text
    if newName ~= "" then
        table.insert(Profiles, { Name = newName, Data = deepCopy(Config) })
        CurrentSelectedProfile = #Profiles
        profileBtn.Text = "📁 " .. Profiles[CurrentSelectedProfile].Name
        nameInput.Text = ""
    end
end)

profileBtn.MouseButton1Click:Connect(function()
    CurrentSelectedProfile = (CurrentSelectedProfile % #Profiles) + 1
    profileBtn.Text = "📁 " .. Profiles[CurrentSelectedProfile].Name
end)

saveBtn.MouseButton1Click:Connect(function()
    Profiles[CurrentSelectedProfile].Data = deepCopy(Config)
end)

loadBtn.MouseButton1Click:Connect(function()
    Config = deepCopy(Profiles[CurrentSelectedProfile].Data)
    refreshUIFromConfig()
end)

local function encodeSkill(skill)
    if skill.Enabled then
        return skill.Method == "Camera" and "1" or "2"
    else
        return "3"
    end
end

exportBtn.MouseButton1Click:Connect(function()
    local codeStr = ""
    for i, profile in ipairs(Profiles) do
        local d = profile.Data
        local a = d.LockTarget and "2" or "1"
        local b = d.ESPEnabled and "1" or "2"
        local c = d.Dash.Enabled and "1" or "2"
        local s1 = encodeSkill(d.Skills[skillKeys[1]])
        local s2 = encodeSkill(d.Skills[skillKeys[2]])
        local s3 = encodeSkill(d.Skills[skillKeys[3]])
        local s4 = encodeSkill(d.Skills[skillKeys[4]])
        local sR = encodeSkill(d.Skills[skillKeys[5]])
        
        codeStr = codeStr .. profile.Name .. a .. b .. c .. s1 .. s2 .. s3 .. s4 .. sR
        if i < #Profiles then codeStr = codeStr .. "_" end
    end
    
    pcall(function() setclipboard(codeStr) end) 
    
    local oldColor = codeInput.TextColor3
    codeInput.TextColor3 = Color3.fromRGB(46, 204, 113)
    codeInput.Text = "✅ ĐÃ COPY MÃ VÀO CLIPBOARD!"
    
    task.delay(1.5, function()
        codeInput.TextColor3 = oldColor
        codeInput.Text = codeStr
    end)
end)

local function decodeSkill(val)
    if val == "1" then return {Enabled = true, Method = "Camera"}
    elseif val == "2" then return {Enabled = true, Method = "Root"}
    else return {Enabled = false, Method = "Camera"} end
end

importBtn.MouseButton1Click:Connect(function()
    local rawCode = codeInput.Text
    if rawCode == "" then return end
    
    local parts = string.split(rawCode, "_")
    local importedProfiles = {}
    
    for _, part in ipairs(parts) do
        if string.len(part) >= 9 then
            local vals = string.sub(part, -8)
            local name = string.sub(part, 1, -9)
            local a, b, c, s1, s2, s3, s4, sR = string.match(vals, "(.)(.)(.)(.)(.)(.)(.)(.)")
            
            local newCfg = deepCopy(Config)
            newCfg.LockTarget = (a == "2")
            newCfg.ESPEnabled = (b == "1")
            newCfg.Dash.Enabled = (c == "1")
            
            newCfg.Skills[skillKeys[1]] = decodeSkill(s1)
            newCfg.Skills[skillKeys[2]] = decodeSkill(s2)
            newCfg.Skills[skillKeys[3]] = decodeSkill(s3)
            newCfg.Skills[skillKeys[4]] = decodeSkill(s4)
            newCfg.Skills[skillKeys[5]] = decodeSkill(sR)
            
            table.insert(importedProfiles, {Name = name, Data = newCfg})
        end
    end
    
    if #importedProfiles > 0 then
        Profiles = importedProfiles
        CurrentSelectedProfile = 1
        Config = deepCopy(Profiles[1].Data)
        profileBtn.Text = "📁 " .. Profiles[1].Name
        refreshUIFromConfig()
    end
end)

-- ====================================================================

local resetBtn = Instance.new("TextButton", contentFrame)
resetBtn.Size = UDim2.new(0.88, 0, 0, 34)
resetBtn.Position = UDim2.new(0.06, 0, 0, 505)
resetBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 13
resetBtn.Text = "🔄 Reset Current Aim (Phím X)"
local resetCorner = Instance.new("UICorner", resetBtn); resetCorner.CornerRadius = UDim.new(0, 6)

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

-- LOGIC CORE VÀ VÒNG LẶP
local function doAim(method, duration)
    isLocking = true; currentMethod = method
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then hum.AutoRotate = false end 
    task.wait(duration)
    if hum then hum.AutoRotate = true end
    isLocking = false
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or UserInputService:GetFocusedTextBox() then return end
    
    -- Xử lý đổi Config qua phím G
    if input.KeyCode == Enum.KeyCode.G then
        CurrentSelectedProfile = (CurrentSelectedProfile % #Profiles) + 1
        Config = deepCopy(Profiles[CurrentSelectedProfile].Data)
        refreshUIFromConfig()
        profileBtn.Text = "📁 " .. Profiles[CurrentSelectedProfile].Name
        return
    end

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
