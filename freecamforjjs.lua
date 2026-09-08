local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local isFreeCam = false
local speed = 1.2 -- Tốc độ di chuyển
local sensitivity = 0.2 -- Độ nhạy xoay camera

local pos = Vector3.zero
local rotX, rotY = 0, 0

-- ==========================================
-- [ 1. TẠO UI MỞ RỘNG (KÈM DANH SÁCH) ]
-- ==========================================
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "FreeCamEntityUI"
gui.ResetOnSpawn = false
gui.Parent = parentGui

-- Khung Frame chính
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 310)
frame.Position = UDim2.new(0, 20, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Nút Bật/Tắt FreeCam
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1, -20, 0, 36)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Text = "Free Cam: OFF"
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- Tiêu đề Danh sách
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -20, 0, 20)
title.Position = UDim2.new(0, 10, 0, 52)
title.BackgroundTransparency = 1
title.Text = "Danh sách Characters:"
title.TextColor3 = Color3.fromRGB(180, 180, 180)
title.Font = Enum.Font.GothamSemibold
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left

-- Cuộn danh sách (ScrollingFrame)
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, -20, 0, 220)
scroll.Position = UDim2.new(0, 10, 0, 75)
scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 4
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)

local listPadding = Instance.new("UIPadding", scroll)
listPadding.PaddingTop = UDim.new(0, 4)
listPadding.PaddingBottom = UDim.new(0, 4)
listPadding.PaddingLeft = UDim.new(0, 4)
listPadding.PaddingRight = UDim.new(0, 4)

-- ==========================================
-- [ 2. LOGIC BẬT/TẮT FREECAM & STUN TAG ]
-- ==========================================
local function setStunTag(enable)
    local char = player.Character
    if not char then return end
    
    local info = char:FindFirstChild("Info")
    if not info then
        info = Instance.new("Folder")
        info.Name = "Info"
        info.Parent = char
    end

    if enable then
        if not info:FindFirstChild("Stun") then
            local stun = Instance.new("StringValue")
            stun.Name = "Stun"
            stun.Parent = info
        end
    else
        local stun = info:FindFirstChild("Stun")
        if stun then
            stun:Destroy()
        end
    end
end

local function toggleFreeCam(state)
    if state ~= nil then
        isFreeCam = state
    else
        isFreeCam = not isFreeCam
    end

    if isFreeCam then
        toggleBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
        toggleBtn.Text = "Free Cam: ON"
        setStunTag(true)
        
        local currentCFrame = camera.CFrame
        pos = currentCFrame.Position
        local rx, ry, _ = currentCFrame:ToOrientation()
        rotX = math.deg(rx)
        rotY = math.deg(ry)
        
        camera.CameraType = Enum.CameraType.Scriptable
    else
        toggleBtn.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
        toggleBtn.Text = "Free Cam: OFF"
        setStunTag(false)
        
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        camera.CameraType = Enum.CameraType.Custom
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
        end
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    toggleFreeCam()
end)

-- ==========================================
-- [ 3. LOGIC TELEPORT FREECAM ĐẾN THỰC THỂ ]
-- ==========================================
local function teleportCamToTarget(targetChar)
    if not targetChar then return end
    local head = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
    if not head then return end

    -- Nếu Free Cam đang tắt thì bật lên trước
    if not isFreeCam then
        toggleFreeCam(true)
    end

    -- Đặt vị trí Free Cam ngay tại Head của target
    pos = head.Position
end

-- ==========================================
-- [ 4. DỰNG VÀ CẬP NHẬT DANH SÁCH CHARACTERS ]
-- ==========================================
local function updateCharacterList()
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local charactersFolder = workspace:FindFirstChild("Characters")
    if not charactersFolder then return end

    for _, charModel in pairs(charactersFolder:GetChildren()) do
        if charModel:IsA("Model") then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
            btn.TextColor3 = Color3.fromRGB(240, 240, 240)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.Text = charModel.Name
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                teleportCamToTarget(charModel)
            end)
        end
    end
end

-- Tự động theo dõi workspace.Characters
task.spawn(function()
    local charactersFolder = workspace:WaitForChild("Characters", 5)
    if charactersFolder then
        charactersFolder.ChildAdded:Connect(updateCharacterList)
        charactersFolder.ChildRemoved:Connect(updateCharacterList)
        updateCharacterList()
    end
end)

-- ==========================================
-- [ 5. ĐIỀU KHIỂN CHUỘT & ĐIỀU HƯỚNG ]
-- ==========================================
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

UserInputService.InputBegan:Connect(function(input)
    if isFreeCam and input.UserInputType == Enum.UserInputType.MouseButton2 then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isFreeCam and input.UserInputType == Enum.UserInputType.MouseButton2 then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isFreeCam and input.UserInputType == Enum.UserInputType.MouseMovement then
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            rotY = rotY - input.Delta.X * sensitivity
            rotX = math.clamp(rotX - input.Delta.Y * sensitivity, -89, 89)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not isFreeCam then return end

    local rotationCFrame = CFrame.Angles(0, math.rad(rotY), 0) * CFrame.Angles(math.rad(rotX), 0, 0)

    local moveDir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir + Vector3.new(0, -1, 0) end

    pos = pos + (rotationCFrame * moveDir) * speed
    camera.CFrame = CFrame.new(pos) * rotationCFrame
end)

-- Phím tắt Shift + P
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        toggleFreeCam()
    end
end)
