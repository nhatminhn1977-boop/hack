local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- CẤU HÌNH (Sửa true/false để bật/tắt xoay người/xoay cam)
local Config = {
    Methods = { [Enum.KeyCode.One]="Camera", [Enum.KeyCode.Two]="Camera", [Enum.KeyCode.Three]="Camera", [Enum.KeyCode.Four]="Camera", [Enum.KeyCode.R]="Camera" },
    ESP = true
}

local target = nil
local isLocking = false
local currentMethod = "Camera"

-- UI ĐƠN GIẢN (KHÔNG FONT - TRÁNH LỖI)
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 200, 0, 300); frame.Position = UDim2.new(0.05, 0, 0.2, 0); frame.BackgroundColor3 = Color3.new(0,0,0); frame.Active = true; frame.Draggable = true
local avatar = Instance.new("ImageLabel", frame); avatar.Size = UDim2.new(0, 50, 0, 50); avatar.Position = UDim2.new(0.1, 0, 0.05, 0)
local name = Instance.new("TextLabel", frame); name.Size = UDim2.new(0, 100, 0, 50); name.Position = UDim2.new(0.4, 0, 0.05, 0); name.TextColor3 = Color3.new(1,1,1); name.BackgroundTransparency = 1

local function addButton(key)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, 120 + (key.Value * 10))
    btn.Text = "Skill " .. key.Name .. ": " .. Config.Methods[key]
    btn.MouseButton1Click:Connect(function()
        Config.Methods[key] = (Config.Methods[key] == "Camera" and "Root" or "Camera")
        btn.Text = "Skill " .. key.Name .. ": " .. Config.Methods[key]
    end)
end
addButton(Enum.KeyCode.One); addButton(Enum.KeyCode.Two); addButton(Enum.KeyCode.Three); addButton(Enum.KeyCode.Four); addButton(Enum.KeyCode.R)

-- LOGIC AIM (BYPASS SHIFT LOCK)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    local method = (input.KeyCode == Enum.KeyCode.Q) and "Root" or Config.Methods[input.KeyCode]
    if method then
        isLocking = true; currentMethod = method
        -- Tạm thời đưa Camera về Scriptable để "đá" Shift Lock ra ngoài
        if method == "Camera" then Camera.CameraType = Enum.CameraType.Scriptable end
        task.wait(input.KeyCode == Enum.KeyCode.Q and 0.4 or 0.1)
        Camera.CameraType = Enum.CameraType.Custom -- Trả lại camera
        isLocking = false
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character and target.Character:Head then
        local headPos = target.Character.Head.Position
        local root = player.Character and player.Character.HumanoidRootPart
        
        if currentMethod == "Root" and root then
            root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
        else
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
        end
    end
end)

-- TÌM TARGET (RESET 0.2S)
task.spawn(function()
    while task.wait(0.2) do
        local min, closest = 9999, nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local d = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if d < min then min = d; closest = p end
            end
        end
        target = closest
        if target then 
            name.Text = target.Name
            pcall(function() avatar.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        end
    end
end)
