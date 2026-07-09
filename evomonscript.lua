local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local specialTargets = {}
local blacklistedPets = {}

local isAutoGoing = false
local isAutoMoving = false
local isMinimized = false

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function convertToPetName(inputStr)
    local num = tonumber(inputStr)
    if not num or num < 0 then return nil end
    local x = math.floor(num / 100)
    local yz = num % 100
    return string.format("Pet%d_%02d", x, yz)
end

local function getMyCreature()
    local cacheServer = Workspace:FindFirstChild("RuntimeCache")
        and Workspace.RuntimeCache:FindFirstChild("RuntimeCacheServer")
        and Workspace.RuntimeCache.RuntimeCacheServer:FindFirstChild("CreatureModelCache")
    if not cacheServer then return nil end
    
    for _, modelHolder in ipairs(cacheServer:GetChildren()) do
        if tonumber(modelHolder.Name) then
            local myCreature = modelHolder:FindFirstChild(player.Name)
            if myCreature then
                return myCreature
            end
        end
    end
    return nil
end

local function getNearestTarget(myCreatureRoot)
    if not myCreatureRoot then return nil end
    local cacheServer = Workspace:FindFirstChild("RuntimeCache")
        and Workspace.RuntimeCache:FindFirstChild("RuntimeCacheServer")
        and Workspace.RuntimeCache.RuntimeCacheServer:FindFirstChild("CreatureModelCache")
    if not cacheServer then return nil end

    local nearestPet = nil
    local shortestDistance = math.huge

    for _, modelHolder in ipairs(cacheServer:GetChildren()) do
        if tonumber(modelHolder.Name) then
            for _, pet in ipairs(modelHolder:GetChildren()) do
                if pet.Name == player.Name then
                    continue
                end
                if Players:FindFirstChild(pet.Name) or Players:GetPlayerFromCharacter(pet) then
                    continue
                end
                if string.match(pet.Name, "^Npc%d+") then
                    continue
                end
                if string.match(pet.Name, "^Pet%d+_%d+_Boss") then
                    continue
                end
                if table.find(blacklistedPets, pet.Name) then
                    continue
                end
                if #specialTargets > 0 and not table.find(specialTargets, pet.Name) then
                    continue
                end
                
                local rootPart = pet:FindFirstChild("HumanoidRootPart")
                local humanoid = pet:FindFirstChildOfClass("Humanoid")
                if rootPart and humanoid then
                    local distance = (myCreatureRoot.Position - rootPart.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestPet = pet
                    end
                end
            end
        end
    end
    return nearestPet
end

local function startAutoGoLoop()
    task.spawn(function()
        while isAutoGoing do
            local myCreature = getMyCreature()
            local myRoot = myCreature and myCreature:FindFirstChild("HumanoidRootPart")
            local myHumanoid = myCreature and myCreature:FindFirstChildOfClass("Humanoid")
            
            if myRoot and myHumanoid then
                local nearestTarget = getNearestTarget(myRoot)
                if nearestTarget then
                    local targetRoot = nearestTarget:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local distance = (myRoot.Position - targetRoot.Position).Magnitude
                        
                        if isAutoMoving and distance <= 8 then
                            VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                            task.wait(0.1)
                            VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                            task.wait(0.5)
                        else
                            myHumanoid.WalkToPoint = targetRoot.Position
                            task.wait(1)
                        end
                    else
                        task.wait(1)
                    end
                else
                    task.wait(1)
                end
            else
                task.wait(1)
            end
        end
    end)
end

local function startAutoMoveLoop()
    task.spawn(function()
        while isAutoMoving do
            if isAutoGoing then 
                task.wait(0.5)
                continue 
            end
            
            VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            task.wait(0.5)
            VIM:SendKeyEvent(true, Enum.KeyCode.S, false, game)
            task.wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.S, false, game)
            task.wait(0.5)
        end
    end)
end

local oldUI = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("UltimateFarmUI_v5")
if oldUI then oldUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateFarmUI_v5"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true 
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 340)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "EZ SIMPLE AUTO FARM SCRIPT"
Title.TextColor3 = Color3.fromRGB(0, 225, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 25, 0, 25)
ToggleBtn.Position = UDim2.new(1, -30, 0, 5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 225, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

local GoBtn = Instance.new("TextButton")
GoBtn.Size = UDim2.new(0, 220, 0, 30)
GoBtn.Position = UDim2.new(0.5, -110, 0, 40)
GoBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
GoBtn.Text = "Auto Go Target: OFF"
GoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
GoBtn.Font = Enum.Font.SourceSansBold
GoBtn.Parent = MainFrame
Instance.new("UICorner", GoBtn).CornerRadius = UDim.new(0, 6)

local MoveBtn = Instance.new("TextButton")
MoveBtn.Size = UDim2.new(0, 220, 0, 30)
MoveBtn.Position = UDim2.new(0.5, -110, 0, 75)
MoveBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
MoveBtn.Text = "Auto Start Battle: OFF"
MoveBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MoveBtn.Font = Enum.Font.SourceSansBold
MoveBtn.Parent = MainFrame
Instance.new("UICorner", MoveBtn).CornerRadius = UDim.new(0, 6)

local TargetBox = Instance.new("TextBox")
TargetBox.Size = UDim2.new(0, 145, 0, 25)
TargetBox.Position = UDim2.new(0, 10, 0, 115)
TargetBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.PlaceholderText = "Target ID..."
TargetBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
TargetBox.Font = Enum.Font.SourceSans
TargetBox.TextSize = 13
TargetBox.Text = ""
TargetBox.Parent = MainFrame
Instance.new("UICorner", TargetBox).CornerRadius = UDim.new(0, 4)

local TargetClear = Instance.new("TextButton")
TargetClear.Size = UDim2.new(0, 65, 0, 25)
TargetClear.Position = UDim2.new(0, 165, 0, 115)
TargetClear.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
TargetClear.Text = "Clear"
TargetClear.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetClear.Font = Enum.Font.SourceSansBold
TargetClear.TextSize = 13
TargetClear.Parent = MainFrame
Instance.new("UICorner", TargetClear).CornerRadius = UDim.new(0, 4)

local TargetListLabel = Instance.new("TextLabel")
TargetListLabel.Size = UDim2.new(0, 220, 0, 30)
TargetListLabel.Position = UDim2.new(0, 10, 0, 145)
TargetListLabel.BackgroundTransparency = 1
TargetListLabel.Text = "Targets: ALL"
TargetListLabel.TextColor3 = Color3.fromRGB(0, 225, 255)
TargetListLabel.TextSize = 12
TargetListLabel.Font = Enum.Font.SourceSansItalic
TargetListLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetListLabel.TextYAlignment = Enum.TextYAlignment.Top
TargetListLabel.TextWrapped = true
TargetListLabel.Parent = MainFrame

local BlacklistBox = Instance.new("TextBox")
BlacklistBox.Size = UDim2.new(0, 145, 0, 25)
BlacklistBox.Position = UDim2.new(0, 10, 0, 185)
BlacklistBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
BlacklistBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BlacklistBox.PlaceholderText = "Blacklist ID..."
BlacklistBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
BlacklistBox.Font = Enum.Font.SourceSans
BlacklistBox.TextSize = 13
BlacklistBox.Text = ""
BlacklistBox.Parent = MainFrame
Instance.new("UICorner", BlacklistBox).CornerRadius = UDim.new(0, 4)

local BlacklistClear = Instance.new("TextButton")
BlacklistClear.Size = UDim2.new(0, 65, 0, 25)
BlacklistClear.Position = UDim2.new(0, 165, 0, 185)
BlacklistClear.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
BlacklistClear.Text = "Clear"
BlacklistClear.TextColor3 = Color3.fromRGB(255, 255, 255)
BlacklistClear.Font = Enum.Font.SourceSansBold
BlacklistClear.TextSize = 13
BlacklistClear.Parent = MainFrame
Instance.new("UICorner", BlacklistClear).CornerRadius = UDim.new(0, 4)

local BlacklistListLabel = Instance.new("TextLabel")
BlacklistListLabel.Size = UDim2.new(0, 220, 0, 30)
BlacklistListLabel.Position = UDim2.new(0, 10, 0, 215)
BlacklistListLabel.BackgroundTransparency = 1
BlacklistListLabel.Text = "Blacklisted Pets: None"
BlacklistListLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
BlacklistListLabel.TextSize = 12
BlacklistListLabel.Font = Enum.Font.SourceSansItalic
BlacklistListLabel.TextXAlignment = Enum.TextXAlignment.Left
BlacklistListLabel.TextYAlignment = Enum.TextYAlignment.Top
BlacklistListLabel.TextWrapped = true
BlacklistListLabel.Parent = MainFrame

local NoteLabel = Instance.new("TextLabel")
NoteLabel.Size = UDim2.new(0, 220, 0, 45)
NoteLabel.Position = UDim2.new(0, 10, 0, 250)
NoteLabel.BackgroundTransparency = 1
NoteLabel.Text = "Syntax: Type pet's ID (Enter to Add)\nExample: ID:n.018(Pebble) then type 18\nID:n.101 then 101\nAuto ignore players, Npcs and Bosses."
NoteLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
NoteLabel.TextSize = 11
NoteLabel.Font = Enum.Font.SourceSansItalic
NoteLabel.TextXAlignment = Enum.TextXAlignment.Left
NoteLabel.TextYAlignment = Enum.TextYAlignment.Top
NoteLabel.TextWrapped = true
NoteLabel.Parent = MainFrame

local CreLabel = Instance.new("TextLabel")
CreLabel.Size = UDim2.new(0, 220, 0, 20)
CreLabel.Position = UDim2.new(0, 10, 0, 305)
CreLabel.BackgroundTransparency = 1
CreLabel.Text = "SCRIPT OWNER: Nhật Minh 🗿"
CreLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
CreLabel.TextSize = 11
CreLabel.Font = Enum.Font.SourceSansBold
CreLabel.TextXAlignment = Enum.TextXAlignment.Left
CreLabel.Parent = MainFrame

makeDraggable(MainFrame)

local toggleElements = {GoBtn, MoveBtn, TargetBox, TargetClear, TargetListLabel, BlacklistBox, BlacklistClear, BlacklistListLabel, NoteLabel, CreLabel}

local function updateButtonVisuals()
    if isAutoGoing then
        GoBtn.Text = "Auto Go Target: ON"
        GoBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        GoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        GoBtn.Text = "Auto Go Target: OFF"
        GoBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        GoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end

    if isAutoMoving then
        MoveBtn.Text = "Auto Start Battle: ON"
        MoveBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        MoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        MoveBtn.Text = "Auto Start Battle: OFF"
        MoveBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        MoveBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 35, 0, 35)
        Title.Visible = false
        ToggleBtn.Position = UDim2.new(0, 5, 0, 5)
        ToggleBtn.Text = "+"
        for _, el in ipairs(toggleElements) do el.Visible = false end
    else
        MainFrame.Size = UDim2.new(0, 240, 0, 340)
        Title.Visible = true
        ToggleBtn.Position = UDim2.new(1, -30, 0, 5)
        ToggleBtn.Text = "-"
        for _, el in ipairs(toggleElements) do el.Visible = true end
    end
end)

TargetBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and TargetBox.Text ~= "" then
        local petName = convertToPetName(TargetBox.Text)
        if petName then
            if not table.find(specialTargets, petName) then
                table.insert(specialTargets, petName)
                TargetListLabel.Text = "Targets: " .. table.concat(specialTargets, ", ")
            end
        end
        TargetBox.Text = ""
    end
end)

TargetClear.MouseButton1Click:Connect(function()
    specialTargets = {}
    TargetListLabel.Text = "Targets: ALL"
end)

BlacklistBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and BlacklistBox.Text ~= "" then
        local petName = convertToPetName(BlacklistBox.Text)
        if petName then
            if not table.find(blacklistedPets, petName) then
                table.insert(blacklistedPets, petName)
                BlacklistListLabel.Text = "Blacklisted Pets: " .. table.concat(blacklistedPets, ", ")
            end
        end
        BlacklistBox.Text = ""
    end
end)

BlacklistClear.MouseButton1Click:Connect(function()
    blacklistedPets = {}
    BlacklistListLabel.Text = "Blacklisted Pets: None"
end)

GoBtn.MouseButton1Click:Connect(function()
    isAutoGoing = not isAutoGoing
    updateButtonVisuals()
    if isAutoGoing then
        startAutoGoLoop()
    end
end)

MoveBtn.MouseButton1Click:Connect(function()
    isAutoMoving = not isAutoMoving
    updateButtonVisuals()
    if isAutoMoving then
        startAutoMoveLoop()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        isAutoGoing = false
        isAutoMoving = false
        updateButtonVisuals()
    end
end)
