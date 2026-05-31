local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Biến cấu hình
local targetPlayer = nil
local isLocking = false
local espEnabled = false
local autoResetAim = true -- Mặc định bật
local isCollapsed = false

-- --- UI Logic (Giữ nguyên cấu trúc) ---
-- ... (Các phần khởi tạo Frame, ListContainer, Nút bấm) ...

-- Nút Bật/Tắt Auto Reset Aim
local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(0.9, 0, 0, 30)
resetBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
resetBtn.Text = "Auto Reset: ON"
resetBtn.MouseButton1Click:Connect(function()
    autoResetAim = not autoResetAim
    resetBtn.Text = autoResetAim and "Auto Reset: ON" or "Auto Reset: OFF"
end)

-- --- Logic Aim Nearest 0.5s ---
task.spawn(function()
    while task.wait(0.5) do
        if autoResetAim then
            local closest, min = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local dist = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                    if dist < min then min = dist; closest = p end
                end
            end
            targetPlayer = closest
        end
    end
end)

-- --- Logic Input Skill & Dash ---
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not targetPlayer then return end
    
    local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}
    local isDash = (input.KeyCode == Enum.KeyCode.Q)
    
    -- Kiểm tra giữ phím di chuyển (A, S, D) cho Dash
    local isMovingSide = (UserInputService:IsKeyDown(Enum.KeyCode.A) or 
                          UserInputService:IsKeyDown(Enum.KeyCode.S) or 
                          UserInputService:IsKeyDown(Enum.KeyCode.D))
    
    for _, key in pairs(keys) do
        if input.KeyCode == key then
            isLocking = true
            task.wait(0.01)
            isLocking = false
            break
        end
    end
    
    if isDash and not isMovingSide then
        isLocking = true
        task.wait(0.3) -- Thời gian đặc biệt cho dash
        isLocking = false
    end
end)

-- --- Render Loop (ESP + Camera Lock) ---
RunService.RenderStepped:Connect(function()
    -- ESP Logic...
    
    -- Camera Lock Logic
    if isLocking and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPlayer.Character.Head.Position)
    end
end)
