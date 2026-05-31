local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local targetPlayer = nil
local isLocking = false
local espEnabled = false
local autoResetAim = true
local isCollapsed = false

-- --- UI Tạo Giao diện ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 450)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true; frame.Draggable = true

local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(1, 0, 0.5, 0); listFrame.Position = UDim2.new(0, 0, 0.1, 0)
listFrame.BackgroundTransparency = 1; listFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

local function updateList()
    for _, child in pairs(listFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local y = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1, -10, 0, 40); btn.Position = UDim2.new(0, 5, 0, y)
            btn.Text = "  " .. p.Name; btn.TextXAlignment = Enum.TextXAlignment.Left
            local img = Instance.new("ImageLabel", btn); img.Size = UDim2.new(0, 30, 0, 30); img.Position = UDim2.new(0, 150, 0, 5)
            pcall(function() img.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            btn.MouseButton1Click:Connect(function() targetPlayer = p end)
            y += 45
        end
    end
end

local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(0.9, 0, 0, 30); resetBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
resetBtn.Text = "Auto Reset: ON"
resetBtn.MouseButton1Click:Connect(function() autoResetAim = not autoResetAim; resetBtn.Text = autoResetAim and "Auto Reset: ON" or "Auto Reset: OFF" end)

local espBtn = Instance.new("TextButton", frame)
espBtn.Size = UDim2.new(0.9, 0, 0, 30); espBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
espBtn.Text = "ESP: OFF"
espBtn.MouseButton1Click:Connect(function() espEnabled = not espEnabled; espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF" end)

-- --- Logic Cốt lõi ---
task.spawn(function()
    while task.wait(0.5) do
        if autoResetAim then
            local closest, min = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local d = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                    if d < min then min = d; closest = p end
                end
            end
            targetPlayer = closest
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not targetPlayer then return end
    local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.R}
    for _, k in pairs(keys) do if input.KeyCode == k then isLocking = true; task.wait(0.01); isLocking = false end end
    
    if input.KeyCode == Enum.KeyCode.Q then
        if not (UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)) then
            isLocking = true; task.wait(0.3); isLocking = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocking and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPlayer.Character.Head.Position)
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local hl = p.Character:FindFirstChild("ESP_H") or Instance.new("Highlight", p.Character); hl.Name = "ESP_H"; hl.Enabled = espEnabled
            local tag = p.Character.Head:FindFirstChild("ESP_T") or Instance.new("BillboardGui", p.Character.Head); tag.Name = "ESP_T"; tag.AlwaysOnTop = true; tag.Enabled = espEnabled
            if not tag:FindFirstChild("L") then local l = Instance.new("TextLabel", tag); l.Name = "L"; l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1 end
            tag.L.Text = p.Name
        end
    end
end)

updateList()
