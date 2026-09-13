local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local isEnabled = true
local lastUseTime = 0
local COOLDOWN = 0.1
local isLooping = false
local blackFlashCount = 0
local flashDelay = 1
local currentMode = "Legit"
local isEditMode = false
local oldGui = player.PlayerGui:FindFirstChild("EZBlackFlashUI")
if oldGui then oldGui:Destroy() end
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
gui.Name = "EZBlackFlashUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 160, 0, 290)
frame.Position = UDim2.new(0.5, -80, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 8)
local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
local miniFrame = Instance.new("Frame", gui)
miniFrame.Size = UDim2.new(0, 40, 0, 40)
miniFrame.Position = frame.Position
miniFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
miniFrame.Active = true
miniFrame.Draggable = true
miniFrame.Visible = false
local miniCorner = Instance.new("UICorner", miniFrame)
miniCorner.CornerRadius = UDim.new(0, 8)
local miniStroke = Instance.new("UIStroke", miniFrame)
miniStroke.Thickness = 2
miniStroke.Color = Color3.fromRGB(46, 204, 113)
local maxBtn = Instance.new("TextButton", miniFrame)
maxBtn.Size = UDim2.new(1, 0, 1, 0)
maxBtn.BackgroundTransparency = 1
maxBtn.Text = "+"
maxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
maxBtn.Font = Enum.Font.GothamBold
maxBtn.TextSize = 20
minBtn.MouseButton1Click:Connect(function()
    miniFrame.Position = frame.Position
    frame.Visible = false
    miniFrame.Visible = true
end)
maxBtn.MouseButton1Click:Connect(function()
    frame.Position = miniFrame.Position
    miniFrame.Visible = false
    frame.Visible = true
end)
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.BackgroundTransparency = 1
title.Text = "EZ Black Flash"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 35)
toggleBtn.Position = UDim2.new(0.05, 0, 0, 40)
toggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Text = "Auto: ON"
local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 6)
local mbRow = Instance.new("Frame", frame)
mbRow.Size = UDim2.new(0.9, 0, 0, 30)
mbRow.Position = UDim2.new(0.05, 0, 0, 85)
mbRow.BackgroundTransparency = 1
local mbLabel = Instance.new("TextLabel", mbRow)
mbLabel.Size = UDim2.new(0.7, 0, 1, 0)
mbLabel.BackgroundTransparency = 1
mbLabel.Text = "Mobile Button"
mbLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
mbLabel.Font = Enum.Font.GothamSemibold
mbLabel.TextSize = 14
mbLabel.TextXAlignment = Enum.TextXAlignment.Left
local mbToggle = Instance.new("TextButton", mbRow)
mbToggle.Size = UDim2.new(0, 26, 0, 26)
mbToggle.Position = UDim2.new(1, -26, 0.5, -13)
mbToggle.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
mbToggle.Text = ""
local mbToggleCorner = Instance.new("UICorner", mbToggle)
mbToggleCorner.CornerRadius = UDim.new(0, 6)
local editToggleBtn = Instance.new("TextButton", frame)
editToggleBtn.Size = UDim2.new(0.9, 0, 0, 30)
editToggleBtn.Position = UDim2.new(0.05, 0, 0, 125)
editToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
editToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
editToggleBtn.Font = Enum.Font.GothamBold
editToggleBtn.TextSize = 12
editToggleBtn.Text = "Edit UI: OFF"
local editCorner = Instance.new("UICorner", editToggleBtn)
editCorner.CornerRadius = UDim.new(0, 6)
local modeBtn = Instance.new("TextButton", frame)
modeBtn.Size = UDim2.new(0.9, 0, 0, 30)
modeBtn.Position = UDim2.new(0.05, 0, 0, 165)
modeBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 12
modeBtn.Text = "Mode: Legit"
local modeCorner = Instance.new("UICorner", modeBtn)
modeCorner.CornerRadius = UDim.new(0, 6)
local delayRow = Instance.new("Frame", frame)
delayRow.Size = UDim2.new(0.9, 0, 0, 30)
delayRow.Position = UDim2.new(0.05, 0, 0, 205)
delayRow.BackgroundTransparency = 1
local delayLbl = Instance.new("TextLabel", delayRow)
delayLbl.Size = UDim2.new(0.6, 0, 1, 0)
delayLbl.BackgroundTransparency = 1
delayLbl.Text = "Delay(s):"
delayLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
delayLbl.Font = Enum.Font.GothamSemibold
delayLbl.TextSize = 13
delayLbl.TextXAlignment = Enum.TextXAlignment.Left
local delayInput = Instance.new("TextBox", delayRow)
delayInput.Size = UDim2.new(0.4, 0, 0.8, 0)
delayInput.Position = UDim2.new(0.6, 0, 0.1, 0)
delayInput.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
delayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
delayInput.Font = Enum.Font.GothamBold
delayInput.TextSize = 13
delayInput.Text = tostring(flashDelay)
local delayCorner = Instance.new("UICorner", delayInput)
delayCorner.CornerRadius = UDim.new(0, 4)
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(0.9, 0, 0, 20)
statusLabel.Position = UDim2.new(0.05, 0, 0, 240)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 12
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
local creLabel = Instance.new("TextLabel", frame)
creLabel.Size = UDim2.new(0.9, 0, 0, 20)
creLabel.Position = UDim2.new(0.05, 0, 0, 260)
creLabel.BackgroundTransparency = 1
creLabel.Font = Enum.Font.Gotham
creLabel.TextSize = 11
creLabel.Text = "cre: Minh"
creLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
creLabel.TextXAlignment = Enum.TextXAlignment.Right
local isMbEnabled = false
local mobileBtn = Instance.new("TextButton", gui)
mobileBtn.Size = UDim2.new(0, 60, 0, 60)
mobileBtn.Position = UDim2.new(0.8, 0, 0.7, 0)
mobileBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
mobileBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileBtn.Font = Enum.Font.GothamBold
mobileBtn.TextSize = 16
mobileBtn.Text = "cast"
mobileBtn.Visible = false
local mbCorner = Instance.new("UICorner", mobileBtn)
mbCorner.CornerRadius = UDim.new(1, 0)
local function updateStatusUI(looping)
    if looping then
        statusLabel.Text = "Status: Auto Chain ON"
        statusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        miniStroke.Color = Color3.fromRGB(192, 57, 43)
    else
        statusLabel.Text = "Status: Idle"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        miniStroke.Color = Color3.fromRGB(46, 204, 113)
    end
end
toggleBtn.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        toggleBtn.Text = "Auto: ON"
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
        toggleBtn.Text = "Auto: OFF"
        isLooping = false 
        updateStatusUI(false)
    end
end)
mbToggle.MouseButton1Click:Connect(function()
    isMbEnabled = not isMbEnabled
    if isMbEnabled then
        mbToggle.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        mobileBtn.Visible = true
    else
        mbToggle.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
        mobileBtn.Visible = false
    end
end)
editToggleBtn.MouseButton1Click:Connect(function()
    isEditMode = not isEditMode
    if isEditMode then
        editToggleBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
        editToggleBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
        editToggleBtn.Text = "Edit UI: ON"
        mobileBtn.BackgroundTransparency = 0.5
    else
        editToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 110)
        editToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        editToggleBtn.Text = "Edit UI: OFF"
        mobileBtn.BackgroundTransparency = 0
    end
end)
modeBtn.MouseButton1Click:Connect(function()
    if currentMode == "Legit" then
        currentMode = "Tele"
        modeBtn.BackgroundColor3 = Color3.fromRGB(155, 89, 182)
        modeBtn.Text = "Mode: Tele"
    else
        currentMode = "Legit"
        modeBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
        modeBtn.Text = "Mode: Legit"
    end
end)
delayInput.FocusLost:Connect(function()
    local val = tonumber(delayInput.Text)
    if val and val >= 0 then
        flashDelay = val
    else
        delayInput.Text = tostring(flashDelay)
    end
end)
local function getClosestTarget()
    local myChar = player.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    local closest = nil
    local minDist = math.huge
    local characters = workspace:FindFirstChild("Characters")
    if characters then
        for _, char in pairs(characters:GetChildren()) do
            if char ~= myChar and char:IsA("Model") then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = char
                    end
                end
            end
        end
    end
    return closest
end
local function isPlayerInBackArc(myHrp, targetHrp)
    local toPlayer = (myHrp.Position - targetHrp.Position).Unit
    local targetBack = -targetHrp.CFrame.LookVector
    local dot = targetBack:Dot(toPlayer)
    return dot >= math.cos(math.rad(35))
end
local function playAnimation(animId, priority)
    local myChar = player.Character
    local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return nil end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(animId)
    local track = animator:LoadAnimation(anim)
    track.Priority = priority or Enum.AnimationPriority.Action3
    track:Play()
    return track
end
local function tweenArc(myHrp, targetHrp, duration)
    local startPos = myHrp.Position
    local endCFrame = targetHrp.CFrame * CFrame.new(0, 0, 4) 
    local endPos = endCFrame.Position
    local controlPos = ((startPos + endPos) / 2) + targetHrp.CFrame.RightVector * 5 
    local startTime = os.clock()
    while os.clock() - startTime < duration do
        local t = math.clamp((os.clock() - startTime) / duration, 0, 1)
        local currentPos = (1-t)^2 * startPos + 2*(1-t)*t * controlPos + t^2 * endPos
        myHrp.CFrame = CFrame.lookAt(currentPos, Vector3.new(targetHrp.Position.X, currentPos.Y, targetHrp.Position.Z))
        RunService.Heartbeat:Wait()
    end
    myHrp.CFrame = CFrame.lookAt(endPos, Vector3.new(targetHrp.Position.X, endPos.Y, targetHrp.Position.Z))
end
local function aimAtTarget(myChar, targetHrp, duration)
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not hum or not myHrp then return end
    hum.AutoRotate = false
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= duration or not targetHrp or not targetHrp.Parent or hum.Health <= 0 then
            if hum and hum.Parent then hum.AutoRotate = true end
            conn:Disconnect()
            return
        end
        local targetPos = Vector3.new(targetHrp.Position.X, myHrp.Position.Y, targetHrp.Position.Z)
        myHrp.CFrame = CFrame.lookAt(myHrp.Position, targetPos)
    end)
end
local function aimCameraToHead(targetHead, duration)
    local camera = workspace.CurrentCamera
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= duration or not targetHead or not targetHead.Parent then
            conn:Disconnect()
            return
        end
        local currentCamPos = camera.CFrame.Position
        camera.CFrame = CFrame.lookAt(currentCamPos, targetHead.Position)
    end)
end
local function executeCast()
    if not isEnabled then return end
    if isLooping then
        isLooping = false
        updateStatusUI(false)
        return
    end
    isLooping = true
    blackFlashCount = 0 
    updateStatusUI(true)
    task.spawn(function()
        local skillTriggered = false
        local conn1, conn2
        local currentDfMove = nil
        local function connectAttributes(dfMove)
            if dfMove and dfMove ~= currentDfMove then
                if conn1 then conn1:Disconnect() end
                if conn2 then conn2:Disconnect() end
                currentDfMove = dfMove
                conn1 = dfMove:GetAttributeChangedSignal("LastUse"):Connect(function() skillTriggered = true end)
                conn2 = dfMove:GetAttributeChangedSignal("ReadyAt"):Connect(function() skillTriggered = true end)
            end
        end
        local function cleanup()
            if conn1 then conn1:Disconnect() end
            if conn2 then conn2:Disconnect() end
            isLooping = false
            blackFlashCount = 0
            updateStatusUI(false)
        end
        while isEnabled and isLooping and not skillTriggered do
            local hitExecutedThisFrame = false
            local charsFolder = workspace:FindFirstChild("Characters")
            local myChar = (charsFolder and charsFolder:FindFirstChild(player.Name)) or player.Character
            if myChar then
                local moveset = myChar:FindFirstChild("Moveset")
                local dfMove = moveset and moveset:FindFirstChild("Divergent Fist")
                if dfMove then connectAttributes(dfMove) end
                local infoFolder = myChar:FindFirstChild("Info")
                local hasStun = infoFolder and infoFolder:FindFirstChild("Stun")
                local hasInSkill = infoFolder and infoFolder:FindFirstChild("InSkill")
                if not hasStun and not hasInSkill then
                    local target = getClosestTarget()
                    if target then
                        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                        local targetHrp = target:FindFirstChild("HumanoidRootPart")
                        local targetHead = target:FindFirstChild("HumanoidRootPart")
                        if myHrp and targetHrp then
                            local distance = (targetHrp.Position - myHrp.Position).Magnitude
                            if distance <= 10 then
                                local currentTime = os.clock()
                                if currentTime - lastUseTime >= COOLDOWN then
                                    lastUseTime = currentTime
                                    blackFlashCount = blackFlashCount + 1
                                    hitExecutedThisFrame = true
                                    local Event = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DivergentFistService"):WaitForChild("RE"):WaitForChild("Activated")
                                    if blackFlashCount < 4 then
                                        if currentMode == "Legit" then
                                            if dfMove then Event:FireServer(dfMove, nil) end 
                                            task.wait(0.21)
                                            task.spawn(function()
                                                local inBackArc = isPlayerInBackArc(myHrp, targetHrp)
                                                if not inBackArc then
                                                    local animTrack = playAnimation("117223862448096", Enum.AnimationPriority.Action3)
                                                    if animTrack then
                                                        task.delay(0.1, function() animTrack:Stop() end)
                                                    end
                                                    tweenArc(myHrp, targetHrp, 0.2)
                                                end
                                            end)
                                            task.delay(0.12, function()
                                                if dfMove then Event:FireServer(dfMove, nil) end
                                            end)
                                            task.spawn(function() aimAtTarget(myChar, targetHrp, 0.5) end)
                                            if targetHead then
                                                task.spawn(function() aimCameraToHead(targetHead, 0.5) end)
                                            end
                                        elseif currentMode == "Tele" then
                                            if dfMove then Event:FireServer(dfMove, nil) end
                                            task.wait(0.3)
                                            local endCFrame = targetHrp.CFrame * CFrame.new(0, 0, 4)
                                            myHrp.CFrame = CFrame.lookAt(endCFrame.Position, Vector3.new(targetHrp.Position.X, endCFrame.Position.Y, targetHrp.Position.Z))
                                            task.wait(0.03)
                                            if dfMove then Event:FireServer(dfMove, nil) end
                                            task.spawn(function() aimAtTarget(myChar, targetHrp, 0.5) end)
                                            if targetHead then
                                                task.spawn(function() aimCameraToHead(targetHead, 0.5) end)
                                            end
                                        end
                                        if blackFlashCount < 3 then
                                            task.wait(flashDelay)
                                        end
                                    else
                                        if dfMove then Event:FireServer(dfMove, nil) end
                                        blackFlashCount = 0 
                                        task.wait(flashDelay) 
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if not hitExecutedThisFrame then
                task.wait(0.05)
            end
        end
        cleanup()
    end)
end
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then
        executeCast()
    end
end)
local dragStartPos = nil
local frameStartPos = nil
mobileBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isEditMode then
            dragStartPos = input.Position
            frameStartPos = mobileBtn.Position
            mobileBtn.BackgroundTransparency = 0.5 
        end
    end
end)
mobileBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if not isEditMode then
            executeCast()
        else
            mobileBtn.BackgroundTransparency = 0.5
        end
    end
end)
mobileBtn.InputChanged:Connect(function(input)
    if isEditMode and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        if dragStartPos and frameStartPos then
            local delta = input.Position - dragStartPos
            mobileBtn.Position = UDim2.new(
                frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
            )
        end
    end
end)
