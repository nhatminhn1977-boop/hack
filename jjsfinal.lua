local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local Config = {
    Dash = {Enabled = true, Method = "Root", Duration = 0.8},
    Skills = {
        [Enum.KeyCode.One] = {Enabled = true, Method = "Camera", Duration = 0},
        [Enum.KeyCode.Two] = {Enabled = true, Method = "Camera", Duration = 0},
        [Enum.KeyCode.Three] = {Enabled = true, Method = "Camera", Duration = 0},
        [Enum.KeyCode.Four] = {Enabled = true, Method = "Camera", Duration = 0},
        [Enum.KeyCode.R] = {Enabled = true, Method = "Camera", Duration = 0}
    },
    LockTarget = false,
    ESPEnabled = true,
    M1Aim = true,
    AutoBlockEnabled = true,
    AutoBlockBreak = {Enabled = true, Distance = 9, ArcOffset = 4} -- Added from x1
}

local skillKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}
local target = nil
local specificTargetName = nil
local isLocking = false
local isHoldingF = false
local currentMethod = "Camera"
local isListOpen = true
local isSkillsOpen = true
local isCurrentlyBlocking = false
local isAimingAtBullet = false
local BLOCK_LINGER_TIME = 0.35
local lastThreatTime = 0
local lastPositions = {}

local KnitServices, BlockServiceRE, ActivatedEvent, DeactivatedEvent, ItadoriActivatedEvent
task.spawn(function()
    KnitServices = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services")
    BlockServiceRE = KnitServices:WaitForChild("BlockService"):WaitForChild("RE")
    ActivatedEvent = BlockServiceRE:WaitForChild("Activated")
    DeactivatedEvent = BlockServiceRE:WaitForChild("Deactivated")
    -- Load Itadori event for Auto Block Break (added from x1)
    pcall(function()
        ItadoriActivatedEvent = KnitServices:WaitForChild("ItadoriService"):WaitForChild("RE"):WaitForChild("Activated")
    end)
end)

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false
gui.Name = "NhatMinh_MergedHub"

-- [ UI Setup: Mini Frame ]
local miniFrame = Instance.new("Frame", gui)
miniFrame.Size = UDim2.new(0, 230, 0, 170)
miniFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
miniFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
miniFrame.BorderSizePixel = 0
miniFrame.Visible = false
miniFrame.Active = true
local miniCorner = Instance.new("UICorner", miniFrame)
miniCorner.CornerRadius = UDim.new(0, 10)
local miniStroke = Instance.new("UIStroke", miniFrame)
miniStroke.Color = Color3.fromRGB(0, 180, 216)
miniStroke.Thickness = 1.5
miniStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local miniAvatar = Instance.new("ImageLabel", miniFrame)
miniAvatar.Size = UDim2.new(0, 36, 0, 36)
miniAvatar.Position = UDim2.new(0, 7, 0, 7)
miniAvatar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
miniAvatar.BorderSizePixel = 0
local mAvCorner = Instance.new("UICorner", miniAvatar); mAvCorner.CornerRadius = UDim.new(1, 0)

local miniName = Instance.new("TextLabel", miniFrame)
miniName.Size = UDim2.new(0, 130, 0, 20)
miniName.Position = UDim2.new(0, 50, 0, 7)
miniName.TextColor3 = Color3.fromRGB(255, 255, 255)
miniName.BackgroundTransparency = 1
miniName.Text = "No Target"
miniName.Font = Enum.Font.GothamBold
miniName.TextSize = 13
miniName.TextXAlignment = Enum.TextXAlignment.Left

local miniKills = Instance.new("TextLabel", miniFrame)
miniKills.Size = UDim2.new(0, 130, 0, 16)
miniKills.Position = UDim2.new(0, 50, 0, 27)
miniKills.TextColor3 = Color3.fromRGB(255, 80, 80)
miniKills.BackgroundTransparency = 1
miniKills.Text = "Kills: 0"
miniKills.Font = Enum.Font.Gotham
miniKills.TextSize = 11
miniKills.TextXAlignment = Enum.TextXAlignment.Left

local miniEvade = Instance.new("TextLabel", miniFrame)
miniEvade.Size = UDim2.new(0, 130, 0, 16)
miniEvade.Position = UDim2.new(0, 50, 0, 43)
miniEvade.TextColor3 = Color3.fromRGB(255, 215, 0)
miniEvade.BackgroundTransparency = 1
miniEvade.Text = "Evasive: N/A"
miniEvade.Font = Enum.Font.GothamBold
miniEvade.TextSize = 12
miniEvade.TextXAlignment = Enum.TextXAlignment.Left

local miniUltimate = Instance.new("TextLabel", miniFrame)
miniUltimate.Size = UDim2.new(0, 130, 0, 16)
miniUltimate.Position = UDim2.new(0, 50, 0, 59)
miniUltimate.TextColor3 = Color3.fromRGB(255, 85, 255)
miniUltimate.BackgroundTransparency = 1
miniUltimate.Text = "Ultimate: N/A"
miniUltimate.Font = Enum.Font.GothamBold
miniUltimate.TextSize = 12
miniUltimate.TextXAlignment = Enum.TextXAlignment.Left

local lineMini = Instance.new("Frame", miniFrame)
lineMini.Size = UDim2.new(1, -20, 0, 1)
lineMini.Position = UDim2.new(0, 10, 0, 80)
lineMini.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
lineMini.BorderSizePixel = 0

local skillLabels = {}
for i = 1, 4 do
    local lbl = Instance.new("TextLabel", miniFrame)
    lbl.Size = UDim2.new(1, -20, 0, 16)
    lbl.Position = UDim2.new(0, 15, 0, 75 + (i * 18))
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = "Skill " .. i .. ": READY"
    lbl.TextColor3 = Color3.fromRGB(85, 255, 127)
    skillLabels[i] = {Label = lbl, Obj = nil}
end

local maxBtn = Instance.new("TextButton", miniFrame)
maxBtn.Size = UDim2.new(0, 30, 0, 30)
maxBtn.Position = UDim2.new(1, -37, 0, 10)
maxBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
maxBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
maxBtn.Text = "+"
maxBtn.Font = Enum.Font.GothamBold
local maxCorner = Instance.new("UICorner", maxBtn); maxCorner.CornerRadius = UDim.new(0, 6)

-- [ UI Setup: Main Frame ]
local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 440, 0, 650)
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

local function makeDraggable(topElement, frameToMove)
    local dragToggle, dragStart, startPos
    topElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frameToMove.Position
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
                frameToMove.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
topBar.BorderSizePixel = 0
topBar.Active = true
local topBarCorner = Instance.new("UICorner", topBar); topBarCorner.CornerRadius = UDim.new(0, 10)
local topBarPatch = Instance.new("Frame", topBar)
topBarPatch.Size = UDim2.new(1, 0, 0, 10); topBarPatch.Position = UDim2.new(0, 0, 1, -10)
topBarPatch.BackgroundColor3 = Color3.fromRGB(28, 28, 35); topBarPatch.BorderSizePixel = 0
makeDraggable(topBar, mainFrame)
makeDraggable(miniFrame, miniFrame)

local hubTitle = Instance.new("TextLabel", topBar)
hubTitle.Size = UDim2.new(0, 180, 1, 0)
hubTitle.Position = UDim2.new(0, 15, 0, 0)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "NHAT MINH HUB (MERGED)"
hubTitle.TextColor3 = Color3.fromRGB(0, 180, 216)
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 13
hubTitle.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -95, 0, 7)
minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
local minCorner = Instance.new("UICorner", minBtn); minCorner.CornerRadius = UDim.new(0, 6)

local toggleListBtn = Instance.new("TextButton", topBar)
toggleListBtn.Size = UDim2.new(0, 26, 0, 26)
toggleListBtn.Position = UDim2.new(1, -65, 0, 7)
toggleListBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
toggleListBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
toggleListBtn.Text = "List"
toggleListBtn.Font = Enum.Font.GothamBold
local tlCorner = Instance.new("UICorner", toggleListBtn); tlCorner.CornerRadius = UDim.new(0, 6)

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
local rightFrame = Instance.new("Frame", contentFrame)
rightFrame.Size = UDim2.new(0, 140, 1, 0)
rightFrame.Position = UDim2.new(0, 290, 0, 0)
rightFrame.BackgroundTransparency = 1

local function updateMainFrameSize()
    local w = isListOpen and 440 or 290
    local h = isSkillsOpen and 670 or 495
    mainFrame.Size = UDim2.new(0, w, 0, h)
    rightFrame.Visible = isListOpen
end

minBtn.MouseButton1Click:Connect(function()
    miniFrame.Position = mainFrame.Position
    mainFrame.Visible = false
    miniFrame.Visible = true
end)

maxBtn.MouseButton1Click:Connect(function()
    mainFrame.Position = miniFrame.Position
    miniFrame.Visible = false
    mainFrame.Visible = true
end)

toggleListBtn.MouseButton1Click:Connect(function()
    isListOpen = not isListOpen
    if isListOpen then
        toggleListBtn.BackgroundColor3 = Color3.fromRGB(0, 119, 182)
    else
        toggleListBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end
    updateMainFrameSize()
end)

local helpFrame = Instance.new("Frame", gui)
helpFrame.Size = UDim2.new(0, 450, 0, 300)
helpFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
helpFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
helpFrame.Visible = false
local hc = Instance.new("UICorner", helpFrame); hc.CornerRadius = UDim.new(0, 10)
local hs = Instance.new("UIStroke", helpFrame); hs.Color = Color3.fromRGB(0, 255, 255); hs.Thickness = 1.5
local helpTitle = Instance.new("TextLabel", helpFrame)
helpTitle.Size = UDim2.new(1, 0, 0, 30)
helpTitle.Text = "MERGED HUB USAGE GUIDE"
helpTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
helpTitle.BackgroundTransparency = 1
helpTitle.Font = Enum.Font.GothamBold
local helpText = Instance.new("TextLabel", helpFrame)
helpText.Size = UDim2.new(1, -20, 1, -40)
helpText.Position = UDim2.new(0, 10, 0, 30)
helpText.Text = "- UI minimize, toggle list, and hide skills integrated.\n- Auto Block Break added: Auto TP back & attacks blocking enemies\n- Key X: Reset Aim Target\n- KEY Q: Aim Root for 0.8s (Only when not holding A,S,D)\n- HOLD F: Hard lock character direction to target\n- ESP updates [ AIMED ] text for easy spotting\n- Report bugs to nhatminhn1977@gmail.com\n- Script by Nhat Minh 1602"
helpText.TextColor3 = Color3.fromRGB(255, 255, 255)
helpText.BackgroundTransparency = 1
helpText.Font = Enum.Font.Gotham
helpText.TextSize = 12
helpText.TextXAlignment = Enum.TextXAlignment.Left
helpText.TextYAlignment = Enum.TextYAlignment.Top
local closeHelp = Instance.new("TextButton", helpFrame)
closeHelp.Size = UDim2.new(0, 30, 0, 30); closeHelp.Position = UDim2.new(1, -30, 0, 0)
closeHelp.Text = "X"; closeHelp.TextColor3 = Color3.fromRGB(255, 50, 50)
closeHelp.BackgroundTransparency = 1; closeHelp.Font = Enum.Font.GothamBold
closeHelp.MouseButton1Click:Connect(function() helpFrame.Visible = false end)
helpBtn.MouseButton1Click:Connect(function() helpFrame.Visible = not helpFrame.Visible end)

local leftFrame = Instance.new("Frame", contentFrame)
leftFrame.Size = UDim2.new(0, 290, 1, 0)
leftFrame.BackgroundTransparency = 1
local avatarImg = Instance.new("ImageLabel", leftFrame)
avatarImg.Size = UDim2.new(0, 45, 0, 45)
avatarImg.Position = UDim2.new(0.06, 0, 0, 12)
avatarImg.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
avatarImg.BorderSizePixel = 0
local avatarCorner = Instance.new("UICorner", avatarImg); avatarCorner.CornerRadius = UDim.new(1, 0)

local nameLbl = Instance.new("TextLabel", leftFrame)
nameLbl.Size = UDim2.new(0, 190, 0, 25)
nameLbl.Position = UDim2.new(0.28, 0, 0, 12)
nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLbl.BackgroundTransparency = 1
nameLbl.Text = "No Target"
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 14
nameLbl.TextXAlignment = Enum.TextXAlignment.Left

local killsLbl = Instance.new("TextLabel", leftFrame)
killsLbl.Size = UDim2.new(0, 190, 0, 20)
killsLbl.Position = UDim2.new(0.28, 0, 0, 37)
killsLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
killsLbl.BackgroundTransparency = 1
killsLbl.Text = "Kills: 0"
killsLbl.Font = Enum.Font.Gotham
killsLbl.TextSize = 12
killsLbl.TextXAlignment = Enum.TextXAlignment.Left

local evadeLbl = Instance.new("TextLabel", leftFrame)
evadeLbl.Size = UDim2.new(0, 190, 0, 22)
evadeLbl.Position = UDim2.new(0.28, 0, 0, 55)
evadeLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
evadeLbl.BackgroundTransparency = 1
evadeLbl.Text = "Evasive: N/A"
evadeLbl.Font = Enum.Font.GothamBlack
evadeLbl.TextSize = 13
evadeLbl.TextXAlignment = Enum.TextXAlignment.Left

local cashLbl = Instance.new("TextLabel", leftFrame)
cashLbl.Size = UDim2.new(0, 190, 0, 18)
cashLbl.Position = UDim2.new(0.28, 0, 0, 77)
cashLbl.TextColor3 = Color3.fromRGB(85, 255, 127)
cashLbl.BackgroundTransparency = 1
cashLbl.Text = "Cash: N/A"
cashLbl.Font = Enum.Font.Gotham
cashLbl.TextSize = 11
cashLbl.TextXAlignment = Enum.TextXAlignment.Left

local movesetLbl = Instance.new("TextLabel", leftFrame)
movesetLbl.Size = UDim2.new(0, 190, 0, 18)
movesetLbl.Position = UDim2.new(0.28, 0, 0, 95)
movesetLbl.TextColor3 = Color3.fromRGB(170, 170, 255)
movesetLbl.BackgroundTransparency = 1
movesetLbl.Text = "Moveset: N/A"
movesetLbl.Font = Enum.Font.Gotham
movesetLbl.TextSize = 11
movesetLbl.TextXAlignment = Enum.TextXAlignment.Left

local ultLbl = Instance.new("TextLabel", leftFrame)
ultLbl.Size = UDim2.new(0, 190, 0, 18)
ultLbl.Position = UDim2.new(0.28, 0, 0, 113)
ultLbl.TextColor3 = Color3.fromRGB(255, 85, 255)
ultLbl.BackgroundTransparency = 1
ultLbl.Text = "Ultimate: N/A"
ultLbl.Font = Enum.Font.Gotham
ultLbl.TextSize = 11
ultLbl.TextXAlignment = Enum.TextXAlignment.Left

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

local function createMainBtn(parentFrame, text, y, callback, isActiveInit)
    local btn = Instance.new("TextButton", parentFrame)
    btn.Size = UDim2.new(0.88, 0, 0, 30)
    btn.Position = UDim2.new(0.06, 0, 0, y)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    local btnCorner = Instance.new("UICorner", btn); btnCorner.CornerRadius = UDim.new(0, 6)
    local btnStroke = Instance.new("UIStroke", btn); btnStroke.Thickness = 1
    updateButtonVisual(btn, isActiveInit, text, text)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- [ Merged Buttons ]
createMainBtn(leftFrame, "Lock Target: OFF", 130, function(btn)
    Config.LockTarget = not Config.LockTarget
    updateButtonVisual(btn, Config.LockTarget, "Lock Target: ON", "Lock Target: OFF")
end, Config.LockTarget)

createMainBtn(leftFrame, "ESP NEAREST: ON", 165, function(btn)
    Config.ESPEnabled = not Config.ESPEnabled
    updateButtonVisual(btn, Config.ESPEnabled, "ESP NEAREST: ON", "ESP NEAREST: OFF")
end, Config.ESPEnabled)

createMainBtn(leftFrame, "Dash Aim (Q): ON", 200, function(btn)
    Config.Dash.Enabled = not Config.Dash.Enabled
    updateButtonVisual(btn, Config.Dash.Enabled, "Dash Aim (Q): ON", "Dash Aim (Q): OFF")
end, Config.Dash.Enabled)

createMainBtn(leftFrame, "M1 Aim: ON", 235, function(btn)
    Config.M1Aim = not Config.M1Aim
    updateButtonVisual(btn, Config.M1Aim, "M1 Aim: ON", "M1 Aim: OFF")
end, Config.M1Aim)

createMainBtn(leftFrame, "Auto Block: ON", 270, function(btn)
    Config.AutoBlockEnabled = not Config.AutoBlockEnabled
    updateButtonVisual(btn, Config.AutoBlockEnabled, "Auto Block: ON", "Auto Block: OFF")
    if not Config.AutoBlockEnabled then
        lastPositions = {}
        if isCurrentlyBlocking and DeactivatedEvent then
            DeactivatedEvent:FireServer()
            isCurrentlyBlocking = false
        end
    end
end, Config.AutoBlockEnabled)

-- [ Added from x1 ] Auto Block Break Button
createMainBtn(leftFrame, "Auto Block Break: ON", 305, function(btn)
    Config.AutoBlockBreak.Enabled = not Config.AutoBlockBreak.Enabled
    updateButtonVisual(btn, Config.AutoBlockBreak.Enabled, "Auto Block Break: ON", "Auto Block Break: OFF")
end, Config.AutoBlockBreak.Enabled)


local toggleSkillsBtn = Instance.new("TextButton", leftFrame)
toggleSkillsBtn.Size = UDim2.new(0.88, 0, 0, 30)
toggleSkillsBtn.Position = UDim2.new(0.06, 0, 0, 345)
toggleSkillsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
toggleSkillsBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleSkillsBtn.Text = "Hide Skill Settings"
toggleSkillsBtn.Font = Enum.Font.GothamBold
toggleSkillsBtn.TextSize = 12
local tsCorner = Instance.new("UICorner", toggleSkillsBtn); tsCorner.CornerRadius = UDim.new(0, 6)

local skillContainer = Instance.new("Frame", leftFrame)
skillContainer.Size = UDim2.new(1, 0, 0, 170)
skillContainer.Position = UDim2.new(0, 0, 0, 380)
skillContainer.BackgroundTransparency = 1

local bottomFrame = Instance.new("Frame", leftFrame)
bottomFrame.Size = UDim2.new(1, 0, 0, 80)
bottomFrame.Position = UDim2.new(0, 0, 0, 555)
bottomFrame.BackgroundTransparency = 1

toggleSkillsBtn.MouseButton1Click:Connect(function()
    isSkillsOpen = not isSkillsOpen
    skillContainer.Visible = isSkillsOpen
    if isSkillsOpen then
        toggleSkillsBtn.Text = "Hide Skill Settings"
        bottomFrame.Position = UDim2.new(0, 0, 0, 555)
    else
        toggleSkillsBtn.Text = "Show Skill Settings"
        bottomFrame.Position = UDim2.new(0, 0, 0, 380)
    end
    updateMainFrameSize()
end)

local skillY = 0
for _, key in ipairs(skillKeys) do
    local toggleBtn = Instance.new("TextButton", skillContainer)
    toggleBtn.Size = UDim2.new(0.33, 0, 0, 30)
    toggleBtn.Position = UDim2.new(0.06, 0, 0, skillY)
    toggleBtn.Font = Enum.Font.GothamMedium
    toggleBtn.TextSize = 11
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    local tCorner = Instance.new("UICorner", toggleBtn); tCorner.CornerRadius = UDim.new(0, 6)
    local tStroke = Instance.new("UIStroke", toggleBtn); tStroke.Thickness = 1
    local function updateSkillToggleVisual()
        local currentSkill = Config.Skills[key]
        if currentSkill.Enabled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(10, 135, 84)
            toggleBtn.Text = key.Name .. ": ON"
            tStroke.Color = Color3.fromRGB(46, 204, 113)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 40, 40)
            toggleBtn.Text = key.Name .. ": OFF"
            tStroke.Color = Color3.fromRGB(120, 40, 40)
        end
    end
    toggleBtn.MouseButton1Click:Connect(function()
        Config.Skills[key].Enabled = not Config.Skills[key].Enabled
        updateSkillToggleVisual()
    end)
    local modeBtn = Instance.new("TextButton", skillContainer)
    modeBtn.Size = UDim2.new(0.33, 0, 0, 30)
    modeBtn.Position = UDim2.new(0.41, 0, 0, skillY)
    modeBtn.Font = Enum.Font.GothamMedium
    modeBtn.TextSize = 11
    modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    local mCorner = Instance.new("UICorner", modeBtn); mCorner.CornerRadius = UDim.new(0, 6)
    local mStroke = Instance.new("UIStroke", modeBtn); mStroke.Thickness = 1
    local function updateSkillModeVisual()
        local currentSkill = Config.Skills[key]
        modeBtn.Text = currentSkill.Method
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
    local durationBox = Instance.new("TextBox", skillContainer)
    durationBox.Size = UDim2.new(0.20, 0, 0, 30)
    durationBox.Position = UDim2.new(0.76, 0, 0, skillY)
    durationBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    durationBox.TextColor3 = Color3.fromRGB(0, 255, 200)
    durationBox.Font = Enum.Font.GothamMedium
    durationBox.TextSize = 12
    local dCorner = Instance.new("UICorner", durationBox); dCorner.CornerRadius = UDim.new(0, 6)
    local dStroke = Instance.new("UIStroke", durationBox); dStroke.Thickness = 1; dStroke.Color = Color3.fromRGB(100, 100, 110)
    local function updateSkillDurationVisual()
        durationBox.Text = tostring(Config.Skills[key].Duration) .. "s"
    end
    durationBox.FocusLost:Connect(function()
        local rawText = durationBox.Text:gsub("s", "")
        local num = tonumber(rawText)
        if num and num >= 0 then
            Config.Skills[key].Duration = num
        end
        updateSkillDurationVisual()
    end)
    updateSkillToggleVisual()
    updateSkillModeVisual()
    updateSkillDurationVisual()
    skillY = skillY + 34
end
local resetBtn = Instance.new("TextButton", bottomFrame)
resetBtn.Size = UDim2.new(0.88, 0, 0, 34)
resetBtn.Position = UDim2.new(0.06, 0, 0, 10)
resetBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 13
resetBtn.Text = "Reset Current Aim (Key X)"
local resetCorner = Instance.new("UICorner", resetBtn); resetCorner.CornerRadius = UDim.new(0, 6)
local creditLbl = Instance.new("TextLabel", bottomFrame)
creditLbl.Size = UDim2.new(1, 0, 0, 20)
creditLbl.Position = UDim2.new(0, 0, 0, 50)
creditLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
creditLbl.BackgroundTransparency = 1
creditLbl.Font = Enum.Font.Gotham
creditLbl.TextSize = 11
creditLbl.Text = "Script by Nhat Minh 1602"

local rightTitle = Instance.new("TextLabel", rightFrame)
rightTitle.Size = UDim2.new(1, 0, 0, 20)
rightTitle.Position = UDim2.new(0, 0, 0, 12)
rightTitle.Text = "TARGET FILTER"
rightTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
rightTitle.BackgroundTransparency = 1
rightTitle.Font = Enum.Font.GothamBold
rightTitle.TextSize = 12

local clearTargetBtn = Instance.new("TextButton", rightFrame)
clearTargetBtn.Size = UDim2.new(0.9, 0, 0, 25)
clearTargetBtn.Position = UDim2.new(0.05, 0, 0, 40)
clearTargetBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
clearTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearTargetBtn.Text = "Clear Target"
clearTargetBtn.Font = Enum.Font.GothamBold
clearTargetBtn.TextSize = 11
local ctCorner = Instance.new("UICorner", clearTargetBtn); ctCorner.CornerRadius = UDim.new(0, 4)

local refreshListBtn = Instance.new("TextButton", rightFrame)
refreshListBtn.Size = UDim2.new(0.9, 0, 0, 25)
refreshListBtn.Position = UDim2.new(0.05, 0, 0, 70)
refreshListBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
refreshListBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshListBtn.Text = "Refresh List"
refreshListBtn.Font = Enum.Font.GothamBold
refreshListBtn.TextSize = 11
local rlCorner = Instance.new("UICorner", refreshListBtn); rlCorner.CornerRadius = UDim.new(0, 4)

local playerListScroll = Instance.new("ScrollingFrame", rightFrame)
playerListScroll.Size = UDim2.new(0.9, 0, 1, -110)
playerListScroll.Position = UDim2.new(0.05, 0, 0, 100)
playerListScroll.BackgroundTransparency = 1
playerListScroll.ScrollBarThickness = 4
playerListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local listLayout = Instance.new("UIListLayout", playerListScroll)
listLayout.Padding = UDim.new(0, 5)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function isValidTarget(child, myChar)
    if child == myChar then return false end
    if child.Name == "MechamaruBot" or child.Name == "KuroClone" then return false end
    local tHead = child:FindFirstChild("Head")
    local pHum = child:FindFirstChildOfClass("Humanoid")
    if not tHead or not pHum or pHum.Health <= 0 then return false end
    if specificTargetName and specificTargetName ~= "" then
        if child.Name ~= specificTargetName then return false end
    end
    return true
end

local function updateESPHighlight()
    local charactersModel = game.Workspace:FindFirstChild("Characters")
    if not charactersModel then return end
    for _, child in pairs(charactersModel:GetChildren()) do
        if child:IsA("Model") then
            if child == target and Config.ESPEnabled then
                if not child:FindFirstChild("PrimeHL") then
                    local hl = Instance.new("Highlight", child)
                    hl.Name = "PrimeHL"
                    hl.FillColor = Color3.new(1, 0, 0)
                end
                local head = child:FindFirstChild("Head")
                if head and not head:FindFirstChild("AimedESP") then
                    local bgui = Instance.new("BillboardGui")
                    bgui.Name = "AimedESP"
                    bgui.Adornee = head
                    bgui.Size = UDim2.new(0, 120, 0, 30)
                    bgui.StudsOffset = Vector3.new(0, 2.5, 0)
                    bgui.AlwaysOnTop = true
                    bgui.Parent = head
                    local txt = Instance.new("TextLabel", bgui)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = "[ AIMED ]"
                    txt.TextColor3 = Color3.fromRGB(255, 30, 30)
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 14
                    txt.TextStrokeTransparency = 0
                    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                end
            else
                local oldHl = child:FindFirstChild("PrimeHL")
                if oldHl then oldHl:Destroy() end
                local head = child:FindFirstChild("Head")
                if head then
                    local oldBg = head:FindFirstChild("AimedESP")
                    if oldBg then oldBg:Destroy() end
                end
            end
        end
    end
end

local function getTargetKills(pObj)
    if pObj and pObj:FindFirstChild("leaderstats") then
        local killsStat = pObj.leaderstats:FindFirstChild("Kills") or pObj.leaderstats:FindFirstChild("kills")
        if killsStat then
            return tostring(killsStat.Value)
        end
    end
    return "0"
end

local function updateTargetAttributes()
    if not target then
        evadeLbl.Text = "Evasive: N/A"
        cashLbl.Text = "Cash: N/A"
        movesetLbl.Text = "Moveset: N/A"
        ultLbl.Text = "Ultimate: N/A"
        miniEvade.Text = "Evasive: N/A"
        return
    end
    local ev = target:GetAttribute("Evade")
    local evText = "Evasive: " .. (ev ~= nil and tostring(ev) or "N/A")
    evadeLbl.Text = evText
    miniEvade.Text = evText
    local playerTarget = game.Players:FindFirstChild(target.Name)
    local csh = playerTarget and playerTarget:GetAttribute("Cash")
    local mov = playerTarget and playerTarget:GetAttribute("Moveset")
    local ult = playerTarget and playerTarget:GetAttribute("Ultimate")
    local cashText = "Cash: " .. (csh ~= nil and tostring(csh) or "N/A")
    local movText = "Moveset: " .. (mov ~= nil and tostring(mov) or "N/A")
    local ultText = "Ultimate: " .. (ult ~= nil and tostring(ult) or "N/A")
    cashLbl.Text = cashText
    movesetLbl.Text = movText
    ultLbl.Text = ultText
    miniUltimate.Text = ultText
end

local function forceResetTarget()
    local myChar = player.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHead or (myHum and myHum.Health <= 0) then
        target = nil
        nameLbl.Text = "No Target"
        miniName.Text = "No Target"
        killsLbl.Text = "Kills: 0"
        miniKills.Text = "Kills: 0"
        avatarImg.Image = ""
        miniAvatar.Image = ""
        updateESPHighlight()
        updateTargetAttributes()
        return
    end
    local closest, min = nil, 9999
    local charactersModel = game.Workspace:FindFirstChild("Characters")
    if charactersModel then
        for _, child in pairs(charactersModel:GetChildren()) do
            if child:IsA("Model") and isValidTarget(child, myChar) then
                local d = (child.Head.Position - myHead.Position).Magnitude
                if d < min then
                    min = d
                    closest = child
                end
            end
        end
    end
    target = closest
    if target and target:FindFirstChild("Head") then
        local tName = target.Name
        nameLbl.Text = tName
        miniName.Text = tName
        local pObj = Players:GetPlayerFromCharacter(target)
        if pObj then
            killsLbl.Text = "Kills: " .. getTargetKills(pObj)
            miniKills.Text = "Kills: " .. getTargetKills(pObj)
            pcall(function()
                local thumb = Players:GetUserThumbnailAsync(pObj.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                avatarImg.Image = thumb
                miniAvatar.Image = thumb
            end)
        else
            killsLbl.Text = "Kills: 0"
            miniKills.Text = "Kills: 0"
            avatarImg.Image = "rbxassetid://0"
            miniAvatar.Image = "rbxassetid://0"
        end
    else
        nameLbl.Text = "No Target"
        miniName.Text = "No Target"
        killsLbl.Text = "Kills: 0"
        miniKills.Text = "Kills: 0"
        avatarImg.Image = ""
        miniAvatar.Image = ""
    end
    updateESPHighlight()
    updateTargetAttributes()
end

resetBtn.MouseButton1Click:Connect(forceResetTarget)
local function refreshPlayerList()
    for _, v in pairs(playerListScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    local charactersModel = game.Workspace:FindFirstChild("Characters")
    if not charactersModel then return end
    for _, child in pairs(charactersModel:GetChildren()) do
        if child:IsA("Model") and child.Name ~= player.Name and child.Name ~= "MechamaruBot" and child.Name ~= "KuroClone" then
            local tHead = child:FindFirstChild("Head")
            if tHead then
                local btn = Instance.new("TextButton", playerListScroll)
                btn.Size = UDim2.new(1, -5, 0, 25)
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Text = child.Name
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 11
                btn.AutoButtonColor = false
                local corner = Instance.new("UICorner", btn)
                corner.CornerRadius = UDim.new(0, 4)
                if specificTargetName == child.Name then
                    btn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
                end
                btn.MouseButton1Click:Connect(function()
                    if specificTargetName == child.Name then
                        specificTargetName = nil
                        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    else
                        specificTargetName = child.Name
                        for _, v in pairs(playerListScroll:GetChildren()) do
                            if v:IsA("TextButton") then
                                v.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                            end
                        end
                        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 216)
                    end
                    forceResetTarget()
                end)
            end
        end
    end
end
refreshListBtn.MouseButton1Click:Connect(refreshPlayerList)
clearTargetBtn.MouseButton1Click:Connect(function()
    specificTargetName = nil
    refreshPlayerList()
    forceResetTarget()
end)
task.delay(1, refreshPlayerList)

-- [ Added from x1 ] Helper Functions for Block Break
local function playJJSAnimation(animId, priority)
    local myChar = player.Character
    local hum = myChar and myChar:FindFirstChild("Humanoid")
    if not hum then return nil end
    local animator = hum:FindFirstChild("Animator")
    if not animator then return nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = string.find(tostring(animId), "rbxassetid") and animId or "rbxassetid://" .. animId
    local track = animator:LoadAnimation(anim)
    track.Priority = priority or Enum.AnimationPriority.Action4
    track:Play()
    return track
end

local function lockFacingTarget(myChar, targetHrp, duration)
    task.spawn(function()
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not hum or not myHrp then return end
        hum.AutoRotate = false
        local startTime = os.clock()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if os.clock() - startTime >= duration or not targetHrp or not targetHrp.Parent or not myHrp or not myHrp.Parent then
                connection:Disconnect()
                if hum and hum.Parent then hum.AutoRotate = true end
                return
            end
            local targetPos = Vector3.new(targetHrp.Position.X, myHrp.Position.Y, targetHrp.Position.Z)
            myHrp.CFrame = CFrame.lookAt(myHrp.Position, targetPos)
        end)
    end)
end

local function tweenArcToBack(myHrp, targetHrp)
    local startPos = myHrp.Position
    local endCFrame = targetHrp.CFrame * CFrame.new(0, 0, Config.AutoBlockBreak.ArcOffset)
    local endPos = endCFrame.Position
    local sideOffset = targetHrp.CFrame.RightVector * 3
    local controlPos = ((startPos + endPos) / 2) + sideOffset
    local duration = 0.18
    local startTime = os.clock()
    while os.clock() - startTime < duration do
        local t = (os.clock() - startTime) / duration
        t = math.clamp(t, 0, 1)
        local currentPos = (1 - t)^2 * startPos + 2 * (1 - t) * t * controlPos + t^2 * endPos
        myHrp.CFrame = CFrame.lookAt(currentPos, Vector3.new(targetHrp.Position.X, currentPos.Y, targetHrp.Position.Z))
        RunService.Heartbeat:Wait()
    end
    myHrp.CFrame = CFrame.lookAt(endPos, Vector3.new(targetHrp.Position.X, endPos.Y, targetHrp.Position.Z))
end

local function doAim(method, duration)
    isLocking = true
    currentMethod = method
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = false end
    if duration and duration > 0 then
        task.wait(duration)
    else
        task.wait()
    end
    if hum and not isHoldingF and not isAimingAtBullet then
        hum.AutoRotate = true
    end
    isLocking = false
end

-- [ Modified Input System ]
local isExecutingBlockBreak = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or UserInputService:GetFocusedTextBox() then return end

    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        -- 1. Check Auto Block Break First
        if Config.AutoBlockBreak.Enabled and not isExecutingBlockBreak then
            local myChar = player.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local charactersFolder = workspace:FindFirstChild("Characters")
            
            if myHrp and charactersFolder then
                local closestTarget = nil
                local minDistance = math.huge
                for _, char in ipairs(charactersFolder:GetChildren()) do
                    if char:IsA("Model") and char ~= myChar then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if root and hum and hum.Health > 0 then
                            local dist = (root.Position - myHrp.Position).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                closestTarget = char
                            end
                        end
                    end
                end
                
                if closestTarget then
                    local targetHrp = closestTarget:FindFirstChild("HumanoidRootPart")
                    local infoFolder = closestTarget:FindFirstChild("Info")
                    local isBlocking = infoFolder and infoFolder:FindFirstChild("Block") ~= nil
                    local distance = (targetHrp.Position - myHrp.Position).Magnitude
                    
                    if isBlocking and distance <= Config.AutoBlockBreak.Distance then
                        isExecutingBlockBreak = true
                        lockFacingTarget(myChar, targetHrp, 1.0)
                        playJJSAnimation("117223862448096", Enum.AnimationPriority.Action3)
                        tweenArcToBack(myHrp, targetHrp)
                        task.wait(0.03)
                        playJJSAnimation("95295463826732", Enum.AnimationPriority.Action4)
                        if ItadoriActivatedEvent then
                            ItadoriActivatedEvent:FireServer(false, nil)
                        end
                        task.wait(0.5) 
                        isExecutingBlockBreak = false
                        return -- Ngăn M1 Aim chèn lên nếu đang Block Break
                    end
                end
            end
        end

        -- 2. Regular M1 Aim
        if Config.M1Aim and target then
            doAim("Root", 0.3)
        end
    end
    
    if input.KeyCode == Enum.KeyCode.X then
        forceResetTarget()
        return
    end
    
    if input.KeyCode == Enum.KeyCode.F then
        isHoldingF = true
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = false end
        return
    end
    
    if not target then return end
    
    if input.KeyCode == Enum.KeyCode.Q and Config.Dash.Enabled then
        local isMovingSide = UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)
        if not isMovingSide then
            doAim("Root", 0.8)
        end
    elseif Config.Skills[input.KeyCode] and Config.Skills[input.KeyCode].Enabled then
        doAim(Config.Skills[input.KeyCode].Method, Config.Skills[input.KeyCode].Duration)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        isHoldingF = false
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum and not isLocking and not isAimingAtBullet then
            hum.AutoRotate = true
        end
    end
end)

local currentTargetForSkills = nil
RunService.RenderStepped:Connect(function()
    local myChar = player.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local isRagdoll = false
    if myChar and myChar:GetAttribute("Ragdoll") == 1 then
        isRagdoll = true
    end
    if isHoldingF then
        if hum and hum.AutoRotate then
            hum.AutoRotate = false
        end
        if target and target:FindFirstChild("HumanoidRootPart") and myHrp and not isRagdoll then
            local targetHrp = target.HumanoidRootPart
            local targetPos = Vector3.new(targetHrp.Position.X, myHrp.Position.Y, targetHrp.Position.Z)
            myHrp.CFrame = CFrame.lookAt(myHrp.Position, targetPos)
        end
    elseif isLocking and target and target:FindFirstChild("Head") and myHrp and not isRagdoll then
        local headPos = target.Head.Position
        if currentMethod == "Root" then
            myHrp.CFrame = CFrame.lookAt(myHrp.Position, Vector3.new(headPos.X, myHrp.Position.Y, headPos.Z))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
    if target ~= currentTargetForSkills then
        currentTargetForSkills = target
        for i = 1, 4 do
            skillLabels[i].Label.Text = "Skill " .. i .. ": READY"
            skillLabels[i].Label.TextColor3 = Color3.fromRGB(85, 255, 127)
            skillLabels[i].Obj = nil
        end
        if target then
            local movesetFolder = target:FindFirstChild("Moveset")
            if movesetFolder then
                for _, skillObj in ipairs(movesetFolder:GetChildren()) do
                    local key = skillObj:GetAttribute("Key")
                    if type(key) == "number" and key >= 1 and key <= 4 then
                        skillLabels[key].Obj = skillObj
                        skillLabels[key].Label.Text = "[ " .. key .. " ] " .. skillObj.Name .. ": CALC..."
                    end
                end
            end
        end
    end
    if currentTargetForSkills then
        local currentTime = workspace:GetServerTimeNow()
        for i = 1, 4 do
            local skillData = skillLabels[i]
            local skillObj = skillData.Obj
            local lbl = skillData.Label
            if skillObj then
                local readyAt = skillObj:GetAttribute("ReadyAt")
                if readyAt then
                    local remainingTime = readyAt - currentTime
                    if remainingTime > 0 then
                        lbl.Text = string.format("[ %d ] %s: %.1fs", i, skillObj.Name, remainingTime)
                        lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
                    else
                        lbl.Text = string.format("[ %d ] %s: READY", i, skillObj.Name)
                        lbl.TextColor3 = Color3.fromRGB(85, 255, 127)
                    end
                else
                    lbl.Text = string.format("[ %d ] %s: READY", i, skillObj.Name)
                    lbl.TextColor3 = Color3.fromRGB(85, 255, 127)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        local myChar = player.Character
        local myHead = myChar and myChar:FindFirstChild("Head")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local charactersModel = game.Workspace:FindFirstChild("Characters")
        if not myHead or (myHum and myHum.Health <= 0) then
            target = nil
        else
            local targetHum = target and target:FindFirstChildOfClass("Humanoid")
            local targetDead = targetHum and targetHum.Health <= 0
            local targetValid = target and target.Parent == charactersModel and target:FindFirstChild("Head")
            local targetStillMeetsSpecific = true
            if specificTargetName and specificTargetName ~= "" and target and target.Name ~= specificTargetName then
                targetStillMeetsSpecific = false
            end
            if not Config.LockTarget or not target or not targetValid or targetDead or not targetStillMeetsSpecific then
                local closest, min = nil, 9999
                if charactersModel then
                    for _, child in pairs(charactersModel:GetChildren()) do
                        if child:IsA("Model") and isValidTarget(child, myChar) then
                            local tHead = child:FindFirstChild("Head")
                            if tHead then
                                local d = (tHead.Position - myHead.Position).Magnitude
                                if d < min then
                                    min = d
                                    closest = child
                                end
                            end
                        end
                    end
                end
                target = closest
            end
        end
        if target and target:FindFirstChild("Head") then
            local tName = target.Name
            nameLbl.Text = tName
            miniName.Text = tName
            local pObj = Players:GetPlayerFromCharacter(target)
            if pObj then
                killsLbl.Text = "Kills: " .. getTargetKills(pObj)
                miniKills.Text = "Kills: " .. getTargetKills(pObj)
                pcall(function()
                    local thumb = Players:GetUserThumbnailAsync(pObj.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    avatarImg.Image = thumb
                    miniAvatar.Image = thumb
                end)
            else
                killsLbl.Text = "Kills: 0"
                miniKills.Text = "Kills: 0"
                avatarImg.Image = "rbxassetid://0"
                miniAvatar.Image = "rbxassetid://0"
            end
        else
            nameLbl.Text = "No Target"
            miniName.Text = "No Target"
            killsLbl.Text = "Kills: 0"
            miniKills.Text = "Kills: 0"
            avatarImg.Image = ""
            miniAvatar.Image = ""
        end
        updateESPHighlight()
        updateTargetAttributes()
    end
end)

player.CharacterAdded:Connect(function()
    isHoldingF = false
    isAimingAtBullet = false
    task.delay(1, refreshPlayerList)
end)

updateMainFrameSize()

local function isHeadingTowards(item, itemCFrame, targetPos)
    local bulletPos = itemCFrame.Position
    local directionToTarget = (targetPos - bulletPos).Unit
    local isHeading = false
    if item:IsA("BasePart") and item.AssemblyLinearVelocity.Magnitude > 5 then
        local moveDirection = item.AssemblyLinearVelocity.Unit
        if moveDirection:Dot(directionToTarget) > 0.7 then
            isHeading = true
        end
    end
    if not isHeading then
        local lookDirection = itemCFrame.LookVector
        if lookDirection:Dot(directionToTarget) > 0.7 then
            isHeading = true
        end
    end
    return isHeading
end

RunService.Heartbeat:Connect(function()
    if not Config.AutoBlockEnabled then return end
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not rootPart then return end
    local bFolder = workspace:FindFirstChild("Bullets")
    if not bFolder then return end
    local incomingBullet = false
    local currentPositions = {}
    local closestBulletPos = nil
    local minBulletDist = math.huge
    for _, item in ipairs(bFolder:GetChildren()) do
        local itemCFrame = nil
        if item:IsA("BasePart") then
            itemCFrame = item.CFrame
        elseif item:IsA("Model") then
            itemCFrame = item:GetPivot()
        end
        if itemCFrame then
            local currentPos = itemCFrame.Position
            currentPositions[item] = currentPos
            local isMoving = true
            if lastPositions[item] then
                local moveDist = (currentPos - lastPositions[item]).Magnitude
                if moveDist < 0.05 then
                    isMoving = false
                end
            else
                if item:IsA("BasePart") and item.AssemblyLinearVelocity.Magnitude < 1 then
                    isMoving = false
                end
            end
            if isMoving then
                local distance = (currentPos - rootPart.Position).Magnitude
                if distance <= 25 then
                    if isHeadingTowards(item, itemCFrame, rootPart.Position) then
                        incomingBullet = true
                        if distance < minBulletDist then
                            minBulletDist = distance
                            closestBulletPos = currentPos
                        end
                    end
                end
            end
        end
    end
    lastPositions = currentPositions
    local currentTime = os.clock()
    if incomingBullet then
        lastThreatTime = currentTime
        if not isCurrentlyBlocking and ActivatedEvent then
            ActivatedEvent:FireServer(nil)
            isCurrentlyBlocking = true
        end
        if closestBulletPos and not isHoldingF then
            if hum and hum.AutoRotate then
                hum.AutoRotate = false
            end
            isAimingAtBullet = true
            rootPart.CFrame = CFrame.lookAt(
                rootPart.Position,
                Vector3.new(closestBulletPos.X, rootPart.Position.Y, closestBulletPos.Z)
            )
        end
    else
        if isCurrentlyBlocking and (currentTime - lastThreatTime >= BLOCK_LINGER_TIME) then
            if DeactivatedEvent then
                DeactivatedEvent:FireServer()
            end
            isCurrentlyBlocking = false
            if isAimingAtBullet then
                isAimingAtBullet = false
                if hum and not isHoldingF and not isLocking then
                    hum.AutoRotate = true
                end
            end
        end
    end
end)






local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local emote = playerGui:WaitForChild("Emotes"):WaitForChild("Emote")
local page1 = emote:WaitForChild("Page1")
local page2 = emote:WaitForChild("Page2")
local switch = emote:WaitForChild("Switch")
local equipped = playerGui:WaitForChild("Menus"):WaitForChild("Group"):WaitForChild("Inventory"):WaitForChild("Items"):WaitForChild("Emotes"):WaitForChild("Equipped")

local function show(gui)
    if gui:IsA("GuiObject") then
        gui.Visible = true
        for _, child in ipairs(gui:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
    end
end

local active = false
page2.Visible = false
switch.Visible = true --switch button idfk
show(page1)
show(equipped)

switch.MouseButton1Click:Connect(function()
    active = not active
    page1.Visible = not active
    page2.Visible = active
    if active then show(page2) else show(page1) end
end)
