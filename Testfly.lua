--[[
    Mobile Fly Script - Tối ưu hóa cho Executor Điện thoại
    Tính năng: Có GUI bật/tắt, nút đổi tốc độ, bay theo hướng Camera bằng Joystick.
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:Service("RunService")
local camera = workspace.CurrentCamera

-- Cấu hình mặc định
local flying = false
local speed = 50
local speeds = {50, 100, 180, 300}
local speedIndex = 1

-- Tạo GUI (Tự động thích ứng màn hình điện thoại)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileFlyGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Khung hiển thị chính
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 130, 0, 140)
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể giữ và di chuyển bảng trên điện thoại

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Tiêu đề GUI
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "FLY MOBILE"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 16

-- Nút Bật / Tắt Bay
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
ToggleButton.Position = UDim2.new(0.08, 0, 0.28, 0)
ToggleButton.Size = UDim2.new(0.84, 0, 0, 35)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Fly: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 15

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = ToggleButton

-- Nút Thay đổi Tốc độ (Speed)
local SpeedButton = Instance.new("TextButton")
SpeedButton.Name = "SpeedButton"
SpeedButton.Parent = MainFrame
SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedButton.Position = UDim2.new(0.08, 0, 0.62, 0)
SpeedButton.Size = UDim2.new(0.84, 0, 0, 35)
SpeedButton.Font = Enum.Font.SourceSansBold
SpeedButton.Text = "Speed: " .. speed
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.TextSize = 15

local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 8)
UICorner3.Parent = SpeedButton

-- Khởi tạo biến lưu lực vật lý
local bv, bg

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end
    hum.PlatformStand = true -- Đưa nhân vật vào trạng thái lơ lửng

    -- Dọn dẹp lực cũ chống lỗi trùng lặp
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    -- Vòng lặp xử lý di chuyển liên tục
    task.spawn(function()
        while flying and char and hrp and hum and hrp.Parent do
            RunService.RenderStepped:Wait()
            bg.CFrame = camera.CFrame
            
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                -- Chuyển đổi hướng di chuyển của Joystick theo góc nhìn của Camera
                local relativeMove = camera.CFrame:VectorToObjectSpace(moveDir)
                local flyDir = (camera.CFrame.LookVector * -relativeMove.Z) + (camera.CFrame.RightVector * relativeMove.X)
                
                if flyDir.Magnitude > 0 then
                    bv.Velocity = flyDir.Unit * speed
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
            else
                -- Giữ nhân vật đứng im tại chỗ không bị rơi (Hover)
                bv.Velocity = Vector3.new(0, 0.01, 0)
            end
        end
    end)
end

local function stopFly()
    flying = false
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- Lắng nghe sự kiện click nút Bật/Tắt
ToggleButton.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        ToggleButton.Text = "Fly: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(65, 255, 65)
        ToggleButton.TextColor3 = Color3.fromRGB(30, 30, 30)
        startFly()
    else
        ToggleButton.Text = "Fly: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopFly()
    end
end)

-- Lắng nghe sự kiện click nút Đổi Tốc Độ
SpeedButton.MouseButton1Click:Connect(function()
    speedIndex = speedIndex + 1
    if speedIndex > #speeds then speedIndex = 1 end
    speed = speeds[speedIndex]
    SpeedButton.Text = "Speed: " .. speed
end)

-- Reset trạng thái khi nhân vật bị reset/đổi map
LocalPlayer.CharacterAdded:Connect(function()
    if flying then
        stopFly()
        ToggleButton.Text = "Fly: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 65, 65)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)
