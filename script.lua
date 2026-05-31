local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Bỏ qua mọi logic UI phức tạp, tạo UI trực tiếp vào CoreGui nếu có thể, hoặc dùng ScreenGui đơn giản
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Active = true
frame.Draggable = true

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1, 0, 1, 0)
label.Text = "SCRIPT ACTIVE"
label.TextColor3 = Color3.new(1, 1, 1)

-- Kiểm tra xem Script có chạy không bằng cách in ra log
print("Combat Assist: Script đã chạy thành công!")

-- --- Logic cốt lõi (Không UI) ---
local target = nil
local isLocking = false

task.spawn(function()
    while task.wait(1) do
        local closest, min = nil, 9999
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local dist = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if dist < min then min = dist; closest = p end
            end
        end
        target = closest
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R, Enum.KeyCode.Q}
    for _, k in pairs(keys) do
        if input.KeyCode == k then
            isLocking = true
            task.wait(input.KeyCode == Enum.KeyCode.Q and 0.3 or 0.01)
            isLocking = false
            break
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocking and target and target.Character and target.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
    end
end)
