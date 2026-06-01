-- SCRIPT HOÀN THIỆN THEO YÊU CẦU
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- CẤU HÌNH
local Config = {
    -- Tùy chỉnh: "Camera" (Xoay cam) hoặc "Root" (Xoay người)
    SkillMethods = { [Enum.KeyCode.One]="Camera", [Enum.KeyCode.Two]="Camera", [Enum.KeyCode.Three]="Camera", [Enum.KeyCode.Four]="Camera", [Enum.KeyCode.R]="Camera" },
    ESP = true
}

local target = nil
local isLocking = false
local currentMode = "Camera" -- Camera hoặc Root

-- UI TỐI GIẢN (KHÔNG LỖI FONT)
local gui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 350); frame.Position = UDim2.new(0.05, 0, 0.2, 0); frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true; frame.Draggable = true
local avatar = Instance.new("ImageLabel", frame); avatar.Size = UDim2.new(0, 50, 0, 50); avatar.Position = UDim2.new(0.05, 0, 0.05, 0)
local name = Instance.new("TextLabel", frame); name.Size = UDim2.new(0, 150, 0, 50); name.Position = UDim2.new(0.3, 0, 0.05, 0); name.TextColor3 = Color3.new(1,1,1); name.BackgroundTransparency = 1

local function addButton(text, keyCode)
    local btn = Instance.new("TextButton", frame); btn.Size = UDim2.new(0.9, 0, 0, 35); btn.Position = UDim2.new(0.05, 0, 0, 100 + (keyCode and 40 or 0))
    btn.Text = text
    btn.MouseButton1Click:Connect(function()
        Config.SkillMethods[keyCode] = (Config.SkillMethods[keyCode] == "Camera" and "Root" or "Camera")
        btn.Text = text .. ": " .. Config.SkillMethods[keyCode]
    end)
end
addButton("Skill 1", Enum.KeyCode.One); addButton("Skill R", Enum.KeyCode.R)

-- LOGIC TÌM MỤC TIÊU (RESET MỖI 0.2S)
task.spawn(function()
    while task.wait(0.2) do
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

-- LOGIC AIM
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not target then return end
    
    -- DASH: Ưu tiên xoay người (Root) trong 0.4s, bỏ qua Shift Lock
    if input.KeyCode == Enum.KeyCode.Q then
        isLocking = true; currentMode = "Root"; task.wait(0.4); isLocking = false
    -- SKILLS: Tùy chỉnh
    elseif Config.SkillMethods[input.KeyCode] then
        isLocking = true; currentMode = Config.SkillMethods[input.KeyCode]; task.wait(0.1); isLocking = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not isLocking or not target or not target.Character then 
        -- Xóa ESP nếu không aim
        local hl = player.Character and player.Character:FindFirstChild("ESP_H") 
        if hl then hl:Destroy() end
        return 
    end
    
    local headPos = target.Character.Head.Position
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    -- ESP Bôi người gần nhất
    if not target.Character:FindFirstChild("ESP_H") then 
        local h = Instance.new("Highlight", target.Character); h.Name = "ESP_H" 
    end
    
    -- THỰC THI AIM
    if currentMode == "Root" and root then
        -- Xoay người (Phá Shift Lock)
        root.CFrame = CFrame.lookAt(root.Position, Vector3.new(headPos.X, root.Position.Y, headPos.Z))
    else
        -- Xoay Cam
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
    end
end)
