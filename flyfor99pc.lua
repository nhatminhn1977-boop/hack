local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

----------------------------------------------------
-- CẤU HÌNH BIẾN
----------------------------------------------------
local flying = false
local speed = 120
local flyConnection = nil

local opRangeEnabled = false
local hitboxSize = 100
local SCAN_RADIUS = 1000
local activeHitboxes = {}

local autoChopEnabled = false

local EXCLUDE_LIST = {
    ["Apple"] = true, ["Berry"] = true, ["Bolt"] = true, ["Broken Fan"] = true,
    ["Broken Microwave"] = true, ["Bunny Foot"] = true, ["Carrot"] = true,
    ["Chair"] = true, ["Coal"] = true, ["Coin Stack"] = true, ["Fuel Canister"] = true,
    ["Log"] = true, ["Morsel"] = true, ["Old Radio"] = true, ["Sheet Metal"] = true, ["Tyre"] = true
}

-- Dọn dẹp GUI cũ
local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild("UltimateMergedGui")
if oldGui then oldGui:Destroy() end

----------------------------------------------------
-- LOGIC HITBOX (KÍCH HOẠT THỦ CÔNG)
----------------------------------------------------
local function getRootPart(character)
    return character.PrimaryPart 
        or character:FindFirstChild("HumanoidRootPart") 
        or character:FindFirstChild("Torso") 
end

local function isValidEntity(character)
    if EXCLUDE_LIST[character.Name] then return false end
    if character:FindFirstChildOfClass("Humanoid") then return true end
    if character:FindFirstChild("Head") and getRootPart(character) then
        return true
    end
    return false
end

local function clearAllHitboxes()
    for model, hb in pairs(activeHitboxes) do
        if hb and hb.Parent then hb:Destroy() end
    end
    table.clear(activeHitboxes)
end

local function scanAndApplyHitboxes()
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return end
    
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        local desc = descendants[i]
        
        if desc:IsA("Model") and desc ~= myChar and not desc:IsDescendantOf(myChar) then
            pcall(function()
                if isValidEntity(desc) then
                    local root = getRootPart(desc)
                    if root then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        
                        if dist <= SCAN_RADIUS then
                            local currentHb = activeHitboxes[desc]
                            if not currentHb or not currentHb.Parent then
                                local hb = Instance.new("Part")
                                hb.Name = "OpRangeInvisibleHitbox"
                                hb.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                                hb.Transparency = 1 
                                hb.CanCollide = false 
                                hb.Massless = true 
                                hb.CFrame = root.CFrame
                                hb.Parent = desc 
                                
                                local weld = Instance.new("WeldConstraint")
                                weld.Part0 = root
                                weld.Part1 = hb
                                weld.Parent = hb
                                
                                activeHitboxes[desc] = hb
                            end
                        end
                    end
                end
            end)
        end
    end
end

----------------------------------------------------
-- LOGIC AUTO CHOP TREES
----------------------------------------------------
local function getNearestTree()
    local nearest = nil
    local minDist = math.huge
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        local obj = descendants[i]
        if obj.Name == "Small Tree" then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = part
                end
            end
        end
    end
    return nearest
end

task.spawn(function()
    RunService.Heartbeat:Connect(function(deltaTime)
        if autoChopEnabled then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local tree = getNearestTree()
            if tree then
                -- Tính toán vị trí đứng (cách cây 3 studs để vụt trúng)
                local targetPos = tree.Position + Vector3.new(3, 0, 3)
                local currentPos = hrp.Position
                local dist = (currentPos - targetPos).Magnitude
                
                -- Khóa lực hấp dẫn để lơ lửng khi bay tới cây
                hrp.Velocity = Vector3.new(0, 0, 0)
                
                if dist > 3 then
                    -- Bay mượt về phía cây
                    local moveDir = (targetPos - currentPos).Unit
                    hrp.CFrame = hrp.CFrame + (moveDir * (speed * deltaTime))
                    hrp.CFrame = CFrame.lookAt(hrp.Position, tree.Position)
                else
                    -- Đã tới nơi, xoay mặt vào cây
                    hrp.CFrame = CFrame.lookAt(hrp.Position, tree.Position)
                end
                
                -- Spam Click (Kích hoạt công cụ trên tay hoặc click ảo)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
                pcall(function() VirtualUser:ClickButton1(Vector2.new(0,0)) end)
                pcall(function() mouse1click() end)
            end
        end
    end)
end)

----------------------------------------------------
-- LOGIC BAY
----------------------------------------------------
local function fly()
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    
    if flyConnection then 
        flyConnection:Disconnect() 
        flyConnection = nil 
    end
    
    local oldBv = hrp:FindFirstChild("FlyVelocity")
    if oldBv then oldBv:Destroy() end
    local oldBg = hrp:FindFirstChild("FlyGyro")
    if oldBg then oldBg:Destroy() end

    if flying then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.P = 90000 
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        
        humanoid.PlatformStand = true
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying or not hrp:IsDescendantOf(workspace) then 
                bv:Destroy()
                bg:Destroy()
                -- Chỉ trả PlatformStand về false nếu autoChop cũng đang tắt
                if not autoChopEnabled then humanoid.PlatformStand = false end
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                return 
            end
            
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            
            bv.Velocity = moveDir * speed
            bg.CFrame = cam.CFrame
        end)
    else
        if not autoChopEnabled then humanoid.PlatformStand = false end
    end
end

player.CharacterAdded:Connect(function()
    if flying then flying = false end
    if autoChopEnabled then autoChopEnabled = false end
end)

----------------------------------------------------
-- THIẾT KẾ GIAO DIỆN UI PREMIUM
----------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateMergedGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 260) -- Mở rộng khung để chứa nút mới
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(19, 19, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 48)
MainStroke.Thickness = 1.2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 32)
Title.Position = UDim2.new(0, 14, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "EZ MOD MENU"
Title.TextColor3 = Color3.fromRGB(140, 140, 155)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = UDim2.new(0, 22, 0, 22)
MinimizeButton.Position = UDim2.new(1, -28, 0, 6)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 210)
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.BorderSizePixel = 0
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

-- NÚT FLY
local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 212, 0, 45)
FlyButton.Position = UDim2.new(0.5, -106, 0, 40)
FlyButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
FlyButton.Text = "FLY: OFF [V]"
FlyButton.TextColor3 = Color3.fromRGB(150, 150, 160)
FlyButton.TextSize = 13
FlyButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", FlyButton).CornerRadius = UDim.new(0, 8)
local FlyStroke = Instance.new("UIStroke", FlyButton)
FlyStroke.Color = Color3.fromRGB(235, 64, 52)
FlyStroke.Thickness = 1.5

-- KHU VỰC TỐC ĐỘ FLY
local SpeedFrame = Instance.new("Frame", MainFrame)
SpeedFrame.Size = UDim2.new(0, 212, 0, 35)
SpeedFrame.Position = UDim2.new(0.5, -106, 0, 90)
SpeedFrame.BackgroundTransparency = 1

local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
SpeedLabel.Size = UDim2.new(0, 100, 1, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "SPEED: " .. tostring(speed)
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 12
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

local DecButton = Instance.new("TextButton", SpeedFrame)
DecButton.Size = UDim2.new(0, 40, 0, 30)
DecButton.Position = UDim2.new(1, -90, 0.5, -15)
DecButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
DecButton.Text = "-"
DecButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", DecButton).CornerRadius = UDim.new(0, 6)

local IncButton = Instance.new("TextButton", SpeedFrame)
IncButton.Size = UDim2.new(0, 40, 0, 30)
IncButton.Position = UDim2.new(1, -40, 0.5, -15)
IncButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
IncButton.Text = "+"
IncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IncButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", IncButton).CornerRadius = UDim.new(0, 6)

local function updateSpeedDisplay()
    SpeedLabel.Text = "SPEED: " .. tostring(speed)
end

DecButton.MouseButton1Click:Connect(function()
    if speed > 10 then speed = speed - 10 updateSpeedDisplay() end
end)
IncButton.MouseButton1Click:Connect(function()
    speed = speed + 10 updateSpeedDisplay()
end)

-- NÚT HITBOX
local HitboxBtn = Instance.new("TextButton", MainFrame)
HitboxBtn.Size = UDim2.new(0, 212, 0, 45)
HitboxBtn.Position = UDim2.new(0.5, -106, 0, 140)
HitboxBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
HitboxBtn.Text = "OP RANGE: OFF"
HitboxBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
HitboxBtn.TextSize = 13
HitboxBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", HitboxBtn).CornerRadius = UDim.new(0, 8)
local HitboxStroke = Instance.new("UIStroke", HitboxBtn)
HitboxStroke.Color = Color3.fromRGB(235, 64, 52)
HitboxStroke.Thickness = 1.5

-- NÚT AUTO CHOP
local AutoChopBtn = Instance.new("TextButton", MainFrame)
AutoChopBtn.Size = UDim2.new(0, 212, 0, 45)
AutoChopBtn.Position = UDim2.new(0.5, -106, 0, 190)
AutoChopBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
AutoChopBtn.Text = "AUTO CHOP: OFF [J]"
AutoChopBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
AutoChopBtn.TextSize = 13
AutoChopBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", AutoChopBtn).CornerRadius = UDim.new(0, 8)
local AutoChopStroke = Instance.new("UIStroke", AutoChopBtn)
AutoChopStroke.Color = Color3.fromRGB(235, 64, 52)
AutoChopStroke.Thickness = 1.5

----------------------------------------------------
-- KẾT NỐI SỰ KIỆN NÚT BẤM
----------------------------------------------------
local function ToggleFlyState()
    if flying then
        FlyButton.Text = "FLY: ACTIVE [V]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(24, 34, 28)
        FlyButton.TextColor3 = Color3.fromRGB(100, 255, 150)
        FlyStroke.Color = Color3.fromRGB(46, 204, 113)
        fly()
    else
        FlyButton.Text = "FLY: OFF [V]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        FlyButton.TextColor3 = Color3.fromRGB(150, 150, 160)
        FlyStroke.Color = Color3.fromRGB(235, 64, 52)
        fly()
    end
end

local function ToggleAutoChopState()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if autoChopEnabled then
        AutoChopBtn.Text = "AUTO CHOP: ACTIVE [J]"
        AutoChopBtn.BackgroundColor3 = Color3.fromRGB(24, 34, 28)
        AutoChopBtn.TextColor3 = Color3.fromRGB(100, 255, 150)
        AutoChopStroke.Color = Color3.fromRGB(46, 204, 113)
        if hum then hum.PlatformStand = true end -- Lơ lửng chống rơi
    else
        AutoChopBtn.Text = "AUTO CHOP: OFF [J]"
        AutoChopBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        AutoChopBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
        AutoChopStroke.Color = Color3.fromRGB(235, 64, 52)
        if hum and not flying then hum.PlatformStand = false end -- Trả lại trọng lực nếu không bay
    end
end

FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    ToggleFlyState()
end)

HitboxBtn.MouseButton1Click:Connect(function()
    opRangeEnabled = not opRangeEnabled
    if opRangeEnabled then
        HitboxBtn.Text = "OP RANGE: ACTIVE (1000s)"
        HitboxBtn.BackgroundColor3 = Color3.fromRGB(24, 34, 28)
        HitboxBtn.TextColor3 = Color3.fromRGB(100, 255, 150)
        HitboxStroke.Color = Color3.fromRGB(46, 204, 113)
        scanAndApplyHitboxes()
    else
        HitboxBtn.Text = "OP RANGE: OFF"
        HitboxBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        HitboxBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
        HitboxStroke.Color = Color3.fromRGB(235, 64, 52)
        clearAllHitboxes()
    end
end)

AutoChopBtn.MouseButton1Click:Connect(function()
    autoChopEnabled = not autoChopEnabled
    ToggleAutoChopState()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then
        flying = not flying
        ToggleFlyState()
    elseif input.KeyCode == Enum.KeyCode.J then
        if autoChopEnabled then -- Chỉ bắt sự kiện tắt để dừng khẩn cấp hoặc toggle tùy ý
            autoChopEnabled = false
            ToggleAutoChopState()
        end
    end
end)

-- LOGIC THU NHỎ UI
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 34, 0, 34)
        Title.Visible = false
        FlyButton.Visible = false
        SpeedFrame.Visible = false
        HitboxBtn.Visible = false
        AutoChopBtn.Visible = false
        MinimizeButton.Position = UDim2.new(0, 6, 0, 6)
        MinimizeButton.Text = "+"
        MainStroke.Color = Color3.fromRGB(70, 70, 80)
    else
        MainFrame.Size = UDim2.new(0, 240, 0, 260)
        Title.Visible = true
        FlyButton.Visible = true
        SpeedFrame.Visible = true
        HitboxBtn.Visible = true
        AutoChopBtn.Visible = true
        MinimizeButton.Position = UDim2.new(1, -28, 0, 6)
        MinimizeButton.Text = "−"
        MainStroke.Color = Color3.fromRGB(40, 40, 48)
    end
end)
