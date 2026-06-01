local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Cấu hình
local settings = { 
    AimDash = true, -- Q mặc định xoay người
    AimSkills = true, 
    MethodSkill = "Camera", -- "Camera" hoặc "Root"
    espEnabled = false 
}

local targetPlayer = nil
local isLocking = false
local isDashing = false

-- --- UI ---
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui); frame.Size = UDim2.new(0, 220, 0, 320); frame.Position = UDim2.new(0.05, 0, 0.3, 0); frame.BackgroundColor3 = Color3.new(0,0,0); frame.Active = true; frame.Draggable = true
local infoLabel = Instance.new("TextLabel", frame); infoLabel.Size = UDim2.new(1, 0, 0, 40); infoLabel.Text = "Target: None"; infoLabel.TextColor3 = Color3.new(1,1,1); infoLabel.BackgroundTransparency = 1

-- Nút Toggles
local function addBtn(text, key, val, y)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Position = UDim2.new(0.05, 0, 0, y); btn.Text = text .. ": " .. tostring(val)
    btn.MouseButton1Click:Connect(function()
        if type(settings[key]) == "boolean" then settings[key] = not settings[key]
        else settings[key] = (settings[key] == "Camera" and "Root" or "Camera") end
        btn.Text = text .. ": " .. tostring(settings[key])
    end)
end
addBtn("Skill Method", "MethodSkill", "Camera", 50)
addBtn("Aim Dash", "AimDash", true, 90)
addBtn("Aim Skills", "AimSkills", true, 130)
addBtn("ESP Nearest", "espEnabled", false, 170)

-- --- Logic ---
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
        if targetPlayer then infoLabel.Text = "Target: " .. targetPlayer.Name end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not targetPlayer then return end
    local isSkill = (settings.AimSkills and ({[Enum.KeyCode.One]=true, [Enum.KeyCode.Two]=true, [Enum.KeyCode.Three]=true, [Enum.KeyCode.Four]=true, [Enum.KeyCode.R]=true})[input.KeyCode])
    local isDash = (settings.AimDash and input.KeyCode == Enum.KeyCode.Q and not (UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)))
    
    if isSkill or isDash then
        isLocking = true
        isDashing = isDash
        task.wait(isDash and 0.4 or 0.01)
        isLocking = false
        isDashing = false
    end
end)

RunService.RenderStepped:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    -- ESP Nearest Only
    for _, p in pairs(Players:GetPlayers()) do
        local hl = p.Character and p.Character:FindFirstChild("ESP_H")
        if hl then hl:Destroy() end
        local tag = p.Character and p.Character.Head:FindFirstChild("ESP_T")
        if tag then tag:Destroy() end
    end
    
    if settings.espEnabled and targetPlayer and targetPlayer.Character then
        local hl = Instance.new("Highlight", targetPlayer.Character); hl.Name = "ESP_H"
        local tag = Instance.new("BillboardGui", targetPlayer.Character.Head); tag.Name = "ESP_T"; tag.AlwaysOnTop = true; tag.Size = UDim2.new(0, 100, 0, 50)
        local lbl = Instance.new("TextLabel", tag); lbl.Size = UDim2.new(1,0,1,0); lbl.Text = targetPlayer.Name; lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.new(1,1,1)
    end

    -- Aim Logic
    if isLocking and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local targetPos = targetPlayer.Character.Head.Position
        if isDashing or settings.MethodSkill == "Root" then
            if root then
                local flatTarget = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z)
                root.CFrame = CFrame.lookAt(root.Position, flatTarget)
            end
        else
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)
