local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Cấu hình tọa độ đích
local targetPos = Vector3.new(-57.3561363, 22.9888306, 488.23172)
local targetCFrame = CFrame.new(targetPos)

-- Cấu hình Teleport luân phiên
local TP_DELAY = 0.01 -- Thời gian nghỉ giữa mỗi lần nhảy mục tiêu

-- Cấu hình Toggles Mặc định
local Toggles = {
    AutoBypass = true,
    AutoFarm = true,
    AutoPopUlt = true,
    AutoHop = true -- Mặc định bật Auto Hop
}
local isRunning = false
local attemptCount = 0

-- ==========================================
-- HỆ THỐNG CONFIG FILE (LƯU/TẢI THIẾT LẬP)
-- ==========================================
local configName = "ezconfig.txt"

local function saveConfig()
    if writefile then
        local data = {
            Toggles = Toggles,
            IsRunning = isRunning
        }
        pcall(function()
            writefile(configName, HttpService:JSONEncode(data))
        end)
    end
end

local function loadConfig()
    if isfile and isfile(configName) and readfile then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(configName))
        end)
        
        if success and type(result) == "table" then
            if result.Toggles then
                Toggles.AutoBypass = result.Toggles.AutoBypass ~= nil and result.Toggles.AutoBypass or true
                Toggles.AutoFarm = result.Toggles.AutoFarm ~= nil and result.Toggles.AutoFarm or true
                Toggles.AutoPopUlt = result.Toggles.AutoPopUlt ~= nil and result.Toggles.AutoPopUlt or true
                
                if result.Toggles.AutoHop ~= nil then
                    Toggles.AutoHop = result.Toggles.AutoHop
                elseif result.Toggles.AutoQuit ~= nil then
                    Toggles.AutoHop = result.Toggles.AutoQuit
                else
                    Toggles.AutoHop = true
                end
            end
            if result.IsRunning ~= nil then
                isRunning = result.IsRunning
            end
        end
    else
        saveConfig() -- Tạo file config nếu chưa có
    end
end

-- Tải Config trước khi vẽ UI
loadConfig()

-- ==========================================
-- TẠO UI (GIAO DIỆN)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EZ02ScriptHub"
ScreenGui.ResetOnSpawn = false
local guiParent = pcall(function() return gethui() end) and gethui() or CoreGui
if guiParent:FindFirstChild(ScreenGui.Name) then guiParent[ScreenGui.Name]:Destroy() end
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 310)
MainFrame.Position = UDim2.new(0.5, -130, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "EZ 0.2 SCRIPT"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame

local AttemptLabel = Instance.new("TextLabel")
AttemptLabel.Size = UDim2.new(1, -20, 0, 20)
AttemptLabel.Position = UDim2.new(0, 10, 0, 70)
AttemptLabel.BackgroundTransparency = 1
AttemptLabel.Text = "Bypass Attempts: 0"
AttemptLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
AttemptLabel.Font = Enum.Font.GothamSemibold
AttemptLabel.TextSize = 13
AttemptLabel.Parent = MainFrame

local function createCheckbox(name, text, yPos)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 25)
    Frame.Position = UDim2.new(0, 10, 0, yPos)
    Frame.BackgroundTransparency = 1
    Frame.Parent = MainFrame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 20, 0, 20)
    Btn.Position = UDim2.new(0, 0, 0.5, -10)
    Btn.BackgroundColor3 = Toggles[name] and Color3.fromRGB(150, 100, 255) or Color3.fromRGB(50, 50, 50)
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.Parent = Frame

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -30, 1, 0)
    Lbl.Position = UDim2.new(0, 30, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.Parent = Frame

    Btn.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        Btn.BackgroundColor3 = Toggles[name] and Color3.fromRGB(150, 100, 255) or Color3.fromRGB(50, 50, 50)
        saveConfig()
    end)
end

createCheckbox("AutoBypass", "1. Auto Bypass", 95)
createCheckbox("AutoFarm", "2. Auto Farm Ultimate", 125)
createCheckbox("AutoPopUlt", "3. Auto Pop Ult & Kill", 155)
createCheckbox("AutoHop", "4. Auto hop server after done", 185)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 200, 0, 35)
ToggleBtn.Position = UDim2.new(0.5, -100, 0, 230)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ToggleBtn.Text = "START"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- Logic Kéo Thả UI
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Logic Nút Thu Gọn
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 30, 0, 30)
        MinimizeBtn.Text = "+"
        MinimizeBtn.Size = UDim2.new(1, 0, 1, 0)
        MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
        
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child ~= UICorner and child ~= MinimizeBtn then
                child.Visible = false
            end
        end
    else
        MainFrame.Size = UDim2.new(0, 260, 0, 310)
        MinimizeBtn.Text = "-"
        MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
        MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
        
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child ~= UICorner and child ~= MinimizeBtn then
                child.Visible = true
            end
        end
    end
end)

-- ==========================================
-- HÀM TIỆN ÍCH & LOGIC CORE
-- ==========================================
local function updateStatus(text) StatusLabel.Text = "Status: " .. text end

local function getChar()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        local cf = workspace:FindFirstChild("Characters")
        if cf then char = cf:FindFirstChild(LocalPlayer.Name) end
    end
    return char
end

local function getHRP()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

local function triggerReset()
    pcall(function() ReplicatedStorage.Knit.Knit.Services.JoinService.RE.Reset:FireServer() end)
end

local function getValidCharacters()
    local charsFolder = workspace:FindFirstChild("Characters")
    if not charsFolder then return {} end

    local validChars = {}
    for _, char in pairs(charsFolder:GetChildren()) do
        if char:IsA("Model") and char ~= LocalPlayer.Character then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and hum and hum.Health > 0 then
                table.insert(validChars, char)
            end
        end
    end
    return validChars
end

local function waitForRespawnAndHealth()
    updateStatus("Waiting for respawn...")
    task.wait(0.5)
    
    while isRunning do
        local tempChar = getChar()
        local tempRoot = tempChar and tempChar:FindFirstChild("HumanoidRootPart")
        
        if tempRoot and not tempChar:FindFirstChild("RagdollConstraints") then
            local hum = tempChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                break
            end
        end
        task.wait(0.1)
    end
    if isRunning then updateStatus("Respawn complete."); task.wait(0.1) end
end

-- ==========================================
-- CHECK DOMAIN CLEAR FUNCTION
-- ==========================================
local function waitForDomainClear()
    local domains = workspace:FindFirstChild("Domains")
    if not domains then return end
    
    if #domains:GetChildren() > 0 then
        updateStatus("Waiting for Domain to clear...")
        while isRunning and #domains:GetChildren() > 0 do
            task.wait(0.5)
        end
        if isRunning then 
            updateStatus("Domain cleared.") 
            task.wait(0.2)
        end
    end
end

-- ==========================================
-- PHASE 1: BYPASS TELEPORT
-- ==========================================
local function doTeleportCycle()
    for i = 1, 3 do
        if not isRunning then return false end
        
        local char = getChar()
        local hrp = getHRP()
        if not hrp or not char then task.wait(1); return false end
        
        updateStatus("Bypass Cycle " .. i .. "/3...")
        char:PivotTo(targetCFrame)
        
        task.wait(0.2)
        
        local currentHRP = getHRP()
        if currentHRP then
            local dist = (currentHRP.Position - targetPos).Magnitude
            if dist <= 20 then
                updateStatus("Cycle " .. i .. ": OK")
            else
                updateStatus("Rubberbanded. Resetting...")
                return false
            end
        end
        task.wait(0.1)
    end
    return true
end

local function phaseBypass()
    while isRunning do
        attemptCount = attemptCount + 1
        AttemptLabel.Text = "Bypass Attempts: " .. attemptCount
        
        local pass = doTeleportCycle()
        if pass then
            updateStatus("Bypass completed.")
            return true
        else
            triggerReset()
            waitForRespawnAndHealth()
        end
    end
    return false
end

-- ==========================================
-- PHASE 2: FARM ULTIMATE (ĐÃ BỔ SUNG ANTI-STUCK 30S NGẦM)
-- ==========================================
local function fireGojoSkills(char)
    pcall(function()
        local moveset = char:FindFirstChild("Moveset")
        if not moveset then return end
        local Knit = ReplicatedStorage.Knit.Knit.Services
        Knit.GojoService.RE.Activated:FireServer("Up", nil)
        if moveset:FindFirstChild("Reversal Red") then Knit.ReversalRedService.RE.Activated:FireServer(moveset["Reversal Red"], nil) end
        if moveset:FindFirstChild("Rapid Punches") then Knit.RapidPunchesService.RE.Activated:FireServer(moveset["Rapid Punches"], nil) end
        if moveset:FindFirstChild("Twofold Kick") then Knit.TwofoldKickService.RE.Activated:FireServer(moveset["Twofold Kick"], nil) end
        Knit.MovementService.RE.Dash:FireServer("Back", true)
    end)
end

local function phaseFarm()
    updateStatus("Farming Ultimate...")
    
    local lastUlt = tonumber(LocalPlayer:GetAttribute("Ultimate")) or 0
    local lastCheckTime = os.clock()

    while isRunning do
        local ultValue = tonumber(LocalPlayer:GetAttribute("Ultimate")) or 0
        if ultValue >= 100 then
            updateStatus("Ultimate fully charged.")
            return "completed"
        end

        -- Kiếm tra ngầm mỗi 30s
        if os.clock() - lastCheckTime >= 30 then
            if ultValue <= lastUlt then
                -- Ult không tăng -> ping cao/lỗi bypass -> Cưỡng chế reset & chạy lại từ đầu
                triggerReset()
                waitForRespawnAndHealth()
                return "restart"
            end
            lastUlt = ultValue
            lastCheckTime = os.clock()
        end

        local dummy = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Dummy")
        local char = getChar()
        local hrp = getHRP()

        if dummy and dummy:FindFirstChild("HumanoidRootPart") and hrp and char then
            char:PivotTo(dummy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
            fireGojoSkills(char)
        end
        task.wait(0.01)
    end
    return "stopped"
end

-- ==========================================
-- PHASE 3: POP ULT & TELEPORT LUÂN PHIÊN
-- ==========================================
local function phasePopAndKill()
    updateStatus("Waiting for stun to end...")
    while isRunning do
        local char = getChar()
        local info = char and char:FindFirstChild("Info")
        if info and not info:FindFirstChild("Stun") then break end
        task.wait(0.1)
    end

    if not isRunning then return end
    
    local char = getChar()
    if char then char:PivotTo(targetCFrame) end
    
    updateStatus("Anti-afterimage delay (1s)...")
    task.wait(1)
    
    waitForDomainClear()

    if not isRunning then return end

    updateStatus("Activating Domain Expansion...")
    pcall(function() ReplicatedStorage.Knit.Knit.Services.GojoService.RE.Ultimate:FireServer() end)
    task.wait(0.3)
    
    updateStatus("Casting Skill...")
    pcall(function() ReplicatedStorage.Knit.Knit.Services.GojoService.RE.RightActivated:FireServer(nil) end)
    
    task.wait(4.5)

    if not isRunning then return end

    if Toggles.AutoHop then
        updateStatus("Task done. Preparing to hop...")
        task.delay(11.5, function()
            pcall(function()
                ReplicatedStorage.Knit.Knit.Services.RankedService.RE.Teleport:FireServer(2)
            end)
        end)
    end

    updateStatus("Auto TP running...")
    local targetIndex = 1
    
    while isRunning do
        local chars = getValidCharacters()
        local myChar = getChar()
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if myHrp and #chars > 0 then
            if targetIndex > #chars then
                targetIndex = 1
            end
            
            local targetChar = chars[targetIndex]
            local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if targetHrp then
                myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
                updateStatus("Teleporting to target [" .. targetIndex .. "/" .. #chars .. "]")
            end
            
            targetIndex = targetIndex + 1
        else
            targetIndex = 1
            updateStatus("Scanning for targets...")
        end
        
        task.wait(TP_DELAY)
    end
end

-- ==========================================
-- MASTER THREAD (ĐIỀU HƯỚNG CHUỖI)
-- ==========================================
local function mainSequence()
    while isRunning do
        local needsRestart = false

        if Toggles.AutoBypass then
            local pass = phaseBypass()
            if not pass or not isRunning then return end
            
            updateStatus("Anti-afterimage delay (1s)...")
            task.wait(1)
            waitForDomainClear()
        end

        if Toggles.AutoFarm then
            local farmResult = phaseFarm()
            if farmResult == "restart" then
                needsRestart = true
            elseif farmResult ~= "completed" or not isRunning then
                return
            end
        end

        if not needsRestart then
            if Toggles.AutoPopUlt then
                phasePopAndKill()
            end

            if isRunning and not Toggles.AutoPopUlt then
                updateStatus("Task finished.")
            end
            
            break -- Hoàn tất bình thường, thoát vòng lặp Master
        end
    end
end

-- ==========================================
-- HÀNH ĐỘNG NÚT START / STOP
-- ==========================================
local function toggleScriptState()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "STOP"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        attemptCount = 0
        AttemptLabel.Text = "Bypass Attempts: 0"
        task.spawn(mainSequence)
    else
        ToggleBtn.Text = "START"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        updateStatus("Idle.")
    end
    saveConfig()
end

ToggleBtn.MouseButton1Click:Connect(toggleScriptState)

-- ==========================================
-- AUTO EXECUTE CHECK
-- ==========================================
if isRunning then
    isRunning = false
    toggleScriptState()
end
                Toggles.AutoFarm = result.Toggles.AutoFarm
                Toggles.AutoPopUlt = result.Toggles.AutoPopUlt
                Toggles.AutoQuit = result.Toggles.AutoQuit
            end
            if result.IsRunning ~= nil then
                isRunning = result.IsRunning
            end
        end
    else
        saveConfig()
    end
end
loadConfig()
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EZ02ScriptHub"
ScreenGui.ResetOnSpawn = false
local guiParent = pcall(function() return gethui() end) and gethui() or CoreGui
if guiParent:FindFirstChild(ScreenGui.Name) then guiParent[ScreenGui.Name]:Destroy() end
ScreenGui.Parent = guiParent
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 310)
MainFrame.Position = UDim2.new(0.5, -130, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "EZ 0.2 SCRIPT"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = MainFrame
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextWrapped = true
StatusLabel.Parent = MainFrame
local AttemptLabel = Instance.new("TextLabel")
AttemptLabel.Size = UDim2.new(1, -20, 0, 20)
AttemptLabel.Position = UDim2.new(0, 10, 0, 70)
AttemptLabel.BackgroundTransparency = 1
AttemptLabel.Text = "Bypass Attempts: 0"
AttemptLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
AttemptLabel.Font = Enum.Font.GothamSemibold
AttemptLabel.TextSize = 13
AttemptLabel.Parent = MainFrame
local function createCheckbox(name, text, yPos)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 25)
    Frame.Position = UDim2.new(0, 10, 0, yPos)
    Frame.BackgroundTransparency = 1
    Frame.Parent = MainFrame
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 20, 0, 20)
    Btn.Position = UDim2.new(0, 0, 0.5, -10)
    Btn.BackgroundColor3 = Toggles[name] and Color3.fromRGB(150, 100, 255) or Color3.fromRGB(50, 50, 50)
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.Parent = Frame
    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -30, 1, 0)
    Lbl.Position = UDim2.new(0, 30, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 13
    Lbl.Parent = Frame
    Btn.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        Btn.BackgroundColor3 = Toggles[name] and Color3.fromRGB(150, 100, 255) or Color3.fromRGB(50, 50, 50)
        saveConfig()
    end)
end
createCheckbox("AutoBypass", "1. Auto Bypass", 95)
createCheckbox("AutoFarm", "2. Auto Farm Ultimate", 125)
createCheckbox("AutoPopUlt", "3. Auto Pop Ult & Kill", 155)
createCheckbox("AutoQuit", "4. Auto Quit (11.5s)", 185)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 200, 0, 35)
ToggleBtn.Position = UDim2.new(0.5, -100, 0, 230)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ToggleBtn.Text = "START"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 30, 0, 30)
        MinimizeBtn.Text = "+"
        MinimizeBtn.Size = UDim2.new(1, 0, 1, 0)
        MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child ~= UICorner and child ~= MinimizeBtn then
                child.Visible = false
            end
        end
    else
        MainFrame.Size = UDim2.new(0, 260, 0, 310)
        MinimizeBtn.Text = "-"
        MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
        MinimizeBtn.Position = UDim2.new(1, -30, 0, 0)
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child ~= UICorner and child ~= MinimizeBtn then
                child.Visible = true
            end
        end
    end
end)
local function updateStatus(text) StatusLabel.Text = "Status: " .. text end
local function getChar()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        local cf = workspace:FindFirstChild("Characters")
        if cf then char = cf:FindFirstChild(LocalPlayer.Name) end
    end
    return char
end
local function getHRP()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end
local function triggerReset()
    pcall(function() ReplicatedStorage.Knit.Knit.Services.JoinService.RE.Reset:FireServer() end)
end
local function getValidCharacters()
    local charsFolder = workspace:FindFirstChild("Characters")
    if not charsFolder then return {} end
    local validChars = {}
    for _, char in pairs(charsFolder:GetChildren()) do
        if char:IsA("Model") and char ~= LocalPlayer.Character then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                table.insert(validChars, char)
            end
        end
    end
    return validChars
end
local function waitForDomainClear()
    local domains = workspace:FindFirstChild("Domains")
    if not domains then return end
    if #domains:GetChildren() > 0 then
        updateStatus("Waiting for Domain to clear...")
        while isRunning and #domains:GetChildren() > 0 do
            task.wait(0.5)
        end
        if isRunning then
            updateStatus("Domain cleared.")
            task.wait(0.2)
        end
    end
end
local function waitForRespawnAndHealth()
    updateStatus("Waiting for respawn...")
    task.wait(0.5)
    while isRunning do
        local tempChar = getChar()
        local tempRoot = tempChar and tempChar:FindFirstChild("HumanoidRootPart")
        if tempRoot and not tempChar:FindFirstChild("RagdollConstraints") then
            local hum = tempChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                break
            end
        end
        task.wait(0.1)
    end
    if isRunning then updateStatus("Respawn complete."); task.wait(0.1) end
end
local function doTeleportCycle()
    for i = 1, 3 do
        if not isRunning then return false end
        local char = getChar()
        local hrp = getHRP()
        if not hrp or not char then task.wait(1); return false end
        updateStatus("Bypass Cycle " .. i .. "/3...")
        char:PivotTo(targetCFrame)
        task.wait(0.2)
        local currentHRP = getHRP()
        if currentHRP then
            local dist = (currentHRP.Position - targetPos).Magnitude
            if dist <= 20 then
                updateStatus("Cycle " .. i .. ": OK")
            else
                updateStatus("Rubberbanded. Resetting...")
                return false
            end
        end
        task.wait(0.1)
    end
    return true
end
local function phaseBypass()
    while isRunning do
        attemptCount = attemptCount + 1
        AttemptLabel.Text = "Bypass Attempts: " .. attemptCount
        local pass = doTeleportCycle()
        if pass then
            updateStatus("Bypass completed.")
            return true
        else
            triggerReset()
            waitForRespawnAndHealth()
        end
    end
    return false
end
local function fireGojoSkills(char)
    pcall(function()
        local moveset = char:FindFirstChild("Moveset")
        if not moveset then return end
        local Knit = ReplicatedStorage.Knit.Knit.Services
        Knit.GojoService.RE.Activated:FireServer("Up", nil)
        if moveset:FindFirstChild("Reversal Red") then Knit.ReversalRedService.RE.Activated:FireServer(moveset["Reversal Red"], nil) end
        if moveset:FindFirstChild("Rapid Punches") then Knit.RapidPunchesService.RE.Activated:FireServer(moveset["Rapid Punches"], nil) end
        if moveset:FindFirstChild("Twofold Kick") then Knit.TwofoldKickService.RE.Activated:FireServer(moveset["Twofold Kick"], nil) end
        Knit.MovementService.RE.Dash:FireServer("Back", true)
    end)
end
local function phaseFarm()
    updateStatus("Farming Ultimate...")
    while isRunning do
        local ultValue = tonumber(LocalPlayer:GetAttribute("Ultimate")) or 0
        if ultValue >= 100 then
            updateStatus("Ultimate fully charged.")
            break
        end
        local dummy = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Dummy")
        local char = getChar()
        local hrp = getHRP()
        if dummy and dummy:FindFirstChild("HumanoidRootPart") and hrp and char then
            char:PivotTo(dummy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2))
            fireGojoSkills(char)
        end
        task.wait(0.01)
    end
end
local function phasePopAndKill()
    updateStatus("Waiting for stun to end...")
    while isRunning do
        local char = getChar()
        local info = char and char:FindFirstChild("Info")
        if info and not info:FindFirstChild("Stun") then break end
        task.wait(0.1)
    end
    if not isRunning then return end
    local char = getChar()
    if char then char:PivotTo(targetCFrame) end
    waitForDomainClear()
    if not isRunning then return end
    updateStatus("Activating Domain Expansion...")
    pcall(function() ReplicatedStorage.Knit.Knit.Services.GojoService.RE.Ultimate:FireServer() end)
    task.wait(0.3)
    updateStatus("Casting Skill...")
    pcall(function() ReplicatedStorage.Knit.Knit.Services.GojoService.RE.RightActivated:FireServer(nil) end)
    task.wait(4.5)
    if not isRunning then return end
    if Toggles.AutoQuit then
        updateStatus("Auto Quit in 11.5s...")
        task.delay(11.5, function()
            LocalPlayer:Kick("Auto Quit Task Completed!")
        end)
    end
    updateStatus("Auto TP running...")
    local targetIndex = 1
    while isRunning do
        local chars = getValidCharacters()
        local myChar = getChar()
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp and #chars > 0 then
            if targetIndex > #chars then
                targetIndex = 1
            end
            local targetChar = chars[targetIndex]
            local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if targetHrp then
                myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
                updateStatus("Teleporting to target [" .. targetIndex .. "/" .. #chars .. "]")
            end
            targetIndex = targetIndex + 1
        else
            targetIndex = 1
            updateStatus("Scanning for targets...")
        end
        task.wait(TP_DELAY)
    end
end
local function mainSequence()
    if Toggles.AutoBypass then
        local pass = phaseBypass()
        if not pass or not isRunning then return end
        waitForDomainClear()
    end
    if Toggles.AutoFarm then
        phaseFarm()
        if not isRunning then return end
    end
    if Toggles.AutoPopUlt then
        phasePopAndKill()
    end
    if isRunning and not Toggles.AutoPopUlt then
        updateStatus("Task finished.")
    end
end
local function toggleScriptState()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = "STOP"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        attemptCount = 0
        AttemptLabel.Text = "Bypass Attempts: 0"
        task.spawn(mainSequence)
    else
        ToggleBtn.Text = "START"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        updateStatus("Idle.")
    end
    saveConfig()
end
ToggleBtn.MouseButton1Click:Connect(toggleScriptState)
if isRunning then
    isRunning = false
    toggleScriptState()
end
