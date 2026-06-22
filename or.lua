-- 1.2

local G2L = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local flying = false
local speed = 120
local ANIMATION_ID = 96276041445117
local currentTrack = nil
local flyConnection = nil -- Quản lý vòng lặp tránh Memory Leak

local function playFlyAnim(char, state)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    
    if not state then
        if currentTrack then
            currentTrack:Stop()
            currentTrack = nil
        end
        return
    end
    if currentTrack then currentTrack:Stop() end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(ANIMATION_ID)
    
    pcall(function()
        currentTrack = animator:LoadAnimation(anim)
        currentTrack.Looped = true
        currentTrack.Priority = Enum.AnimationPriority.Movement
        currentTrack:Play()
    end)
end

G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "UltimateFlySystemGui"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 240, 0, 160)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "EZ FLY BY MINH 🔥"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -30, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner", MinimizeButton)
MinCorner.CornerRadius = UDim.new(0, 5)

local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 220, 0, 45)
FlyButton.Position = UDim2.new(0.5, -110, 0, 45)
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyButton.Text = "FLY: OFF [V]"
FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
FlyButton.TextSize = 14
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner", FlyButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)
local ButtonStroke = Instance.new("UIStroke", FlyButton)
ButtonStroke.Color = Color3.fromRGB(150, 40, 40)
ButtonStroke.Thickness = 1.5

----------------------------------------------------
-- KHU VỰC ĐIỀU CHỈNH TỐC ĐỘ (SPEED CONTROLS)
----------------------------------------------------
local SpeedFrame = Instance.new("Frame", MainFrame)
SpeedFrame.Size = UDim2.new(0, 220, 0, 45)
SpeedFrame.Position = UDim2.new(0.5, -110, 0, 100)
SpeedFrame.BackgroundTransparency = 1

local SpeedLabel = Instance.new("TextLabel", SpeedFrame)
SpeedLabel.Size = UDim2.new(0, 110, 1, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "SPEED: " .. tostring(speed)
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Nút Giảm Tốc Độ [-]
local DecButton = Instance.new("TextButton", SpeedFrame)
DecButton.Size = UDim2.new(0, 45, 0, 35)
DecButton.Position = UDim2.new(1, -100, 0.5, -17.5)
DecButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DecButton.Text = "-"
DecButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DecButton.TextSize = 16
DecButton.Font = Enum.Font.SourceSansBold
DecButton.BorderSizePixel = 0

local DecCorner = Instance.new("UICorner", DecButton)
DecCorner.CornerRadius = UDim.new(0, 6)
local DecStroke = Instance.new("UIStroke", DecButton)
DecStroke.Color = Color3.fromRGB(55, 55, 55)
DecStroke.Thickness = 1

-- Nút Tăng Tốc Độ [+]
local IncButton = Instance.new("TextButton", SpeedFrame)
IncButton.Size = UDim2.new(0, 45, 0, 35)
IncButton.Position = UDim2.new(1, -45, 0.5, -17.5)
IncButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IncButton.Text = "+"
IncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
IncButton.TextSize = 16
IncButton.Font = Enum.Font.SourceSansBold
IncButton.BorderSizePixel = 0

local IncCorner = Instance.new("UICorner", IncButton)
IncCorner.CornerRadius = UDim.new(0, 6)
local IncStroke = Instance.new("UIStroke", IncButton)
IncStroke.Color = Color3.fromRGB(55, 55, 55)
IncStroke.Thickness = 1

local function updateSpeedDisplay()
    SpeedLabel.Text = "SPEED: " .. tostring(speed)
end

DecButton.MouseButton1Click:Connect(function()
    if speed > 10 then 
        speed = speed - 10
        updateSpeedDisplay()
    end
end)

IncButton.MouseButton1Click:Connect(function()
    speed = speed + 10
    updateSpeedDisplay()
end)
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
        -- 1. Sử dụng BodyVelocity điều khiển tốc độ
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        -- 2. Đưa BodyGyro vào để chống xoay người khi va chạm và đồng bộ Shift Lock giống script tham khảo[cite: 2]
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.P = 90000 -- Lực giữ góc hướng giống bản mẫu V3[cite: 2]
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = hrp.CFrame
        bg.Parent = hrp
        
        -- Chuyển trạng thái sang PlatformStand để chống các lực can thiệp từ hoạt ảnh chạy mặt đất
        humanoid.PlatformStand = true
        
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying or not hrp:IsDescendantOf(workspace) then 
                bv:Destroy()
                bg:Destroy()
                humanoid.PlatformStand = false
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
            
            -- Khóa hướng xoay của người khớp hoàn toàn với CFrame của Camera (Hỗ trợ Shift Lock tối đa)[cite: 2]
            bg.CFrame = cam.CFrame
        end)
    else
        humanoid.PlatformStand = false
    end
end

local function ToggleFlyState()
    local character = player.Character
    if flying then
        FlyButton.Text = "FLY: ACTIVE [V]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(20, 180, 20)
        FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonStroke.Color = Color3.fromRGB(50, 255, 50)
        fly()
        if character then playFlyAnim(character, true) end
    else
        FlyButton.Text = "FLY: OFF [V]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        ButtonStroke.Color = Color3.fromRGB(150, 40, 40)
        fly()
        if character then playFlyAnim(character, false) end
    end
end

FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    ToggleFlyState()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.V then
        flying = not flying
        ToggleFlyState()
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    if flying then
        flying = false
        ToggleFlyState()
    end
end)

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 35, 0, 35)
        MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) 
        MainStroke.Color = Color3.fromRGB(150, 40, 40) 
        Title.Visible = false
        FlyButton.Visible = false
        SpeedFrame.Visible = false
        MinimizeButton.Position = UDim2.new(0, 5, 0, 5)
        MinimizeButton.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 240, 0, 160)
        MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) 
        MainStroke.Color = Color3.fromRGB(45, 45, 45) 
        Title.Visible = true
        FlyButton.Visible = true
        SpeedFrame.Visible = true
        MinimizeButton.Position = UDim2.new(1, -30, 0, 5)
        MinimizeButton.Text = "-"
    end
end)
