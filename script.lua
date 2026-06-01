local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local targetPlayer = nil
local isLocking = false
local isDashing = false

-- --- UI Tối giản (Fix lỗi Font) ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, 0, 1, 0)
status.Text = "Combat Assist Active"
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1

-- --- Logic Aim & Dash ---
task.spawn(function()
    while task.wait(0.5) do
        local closest, min = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                local d = (p.Character.Head.Position - player.Character.Head.Position).Magnitude
                if d < min then min = d; closest = p end
            end
        end
        targetPlayer = closest
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not targetPlayer then return end
    
    -- Xử lý Dash (Q) - Aim xoay người trong 0.4s
    if input.KeyCode == Enum.KeyCode.Q then
        isLocking = true
        isDashing = true
        task.wait(0.4)
        isDashing = false
        isLocking = false
    -- Xử lý Skills 1,2,3,4,R - Aim Camera
    elseif ({[Enum.KeyCode.One]=true, [Enum.KeyCode.Two]=true, [Enum.KeyCode.Three]=true, [Enum.KeyCode.Four]=true, [Enum.KeyCode.R]=true})[input.KeyCode] then
        isLocking = true
        task.wait(0.1)
        isLocking = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not isLocking or not targetPlayer or not targetPlayer.Character then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local head = targetPlayer.Character:FindFirstChild("Head")
    if not head then return end

    if isDashing and root then
        -- Xoay người (Aim ngang)
        local flatTarget = Vector3.new(head.Position.X, root.Position.Y, head.Position.Z)
        root.CFrame = CFrame.lookAt(root.Position, flatTarget)
    else
        -- Aim Camera (Aim dọc/ngang)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
    end
end)
