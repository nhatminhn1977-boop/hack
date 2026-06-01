-- SCRIPT TỐI ƯU HÓA CAO ĐỘ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CẤU HÌNH CÁ NHÂN: Sửa "Camera" thành "Root" nếu muốn xoay người
local Config = {
    AimMethods = { [Enum.KeyCode.One] = "Camera", [Enum.KeyCode.Two] = "Camera", [Enum.KeyCode.Three] = "Camera", [Enum.KeyCode.Four] = "Camera", [Enum.KeyCode.R] = "Camera" },
    DashMethod = "Root",
    ESP = true
}

local target = nil
local isLocking = false
local currentMethod = "Camera"

-- Tạo UI cơ bản nhất để tránh lỗi
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 150); frame.Position = UDim2.new(0.05, 0, 0.3, 0); frame.BackgroundColor3 = Color3.new(0,0,0)
frame.Active = true; frame.Draggable = true
local avatar = Instance.new("ImageLabel", frame); avatar.Size = UDim2.new(0, 50, 0, 50); avatar.Position = UDim2.new(0, 5, 0, 5)
local name = Instance.new("TextLabel", frame); name.Size = UDim2.new(0, 100, 0, 50); name.Position = UDim2.new(0, 60, 0, 5); name.TextColor3 = Color3.new(1,1,1); name.BackgroundTransparency = 1

-- Logic tìm mục tiêu
task.spawn(function()
    while task.wait(0.5) do
        local min, closest = 9999, nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local dist = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if dist < min then min = dist; closest = p end
            end
        end
        target = closest
        if target then
            name.Text = target.Name
            pcall(function() avatar.Image = Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
        end
    end
end)

-- Logic Dash và Skill
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    local method = (input.KeyCode == Enum.KeyCode.Q) and Config.DashMethod or Config.AimMethods[input.KeyCode]
    if method then
        currentMethod = method
        isLocking = true
        task.wait(input.KeyCode == Enum.KeyCode.Q and 0.4 or 0.1)
        isLocking = false
    end
end)

-- RenderStepped xử lý Aiming (Đè lên Shift Lock)
RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        if currentMethod == "Root" then
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
            end
        else
            -- Ép Camera nhìn mục tiêu, Shift Lock không thể cản được
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
        end
    end
end)
