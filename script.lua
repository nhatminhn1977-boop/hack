local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local aimbotEnabled = false
local targetPlayer = nil
local isCollapsed = false

-- --- UI Setup ---
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 220, 0, 450)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local collapseBtn = Instance.new("TextButton", frame)
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(0.85, 0, 0, 0)
collapseBtn.Text = "-"
collapseBtn.MouseButton1Click:Connect(function()
    isCollapsed = not isCollapsed
    frame.Size = isCollapsed and UDim2.new(0, 220, 0, 40) or UDim2.new(0, 220, 0, 450)
    for _, child in pairs(frame:GetChildren()) do
        if child ~= collapseBtn then child.Visible = not isCollapsed end
    end
end)

local listContainer = Instance.new("ScrollingFrame", frame)
listContainer.Size = UDim2.new(1, 0, 0.7, 0)
listContainer.Position = UDim2.new(0, 0, 0.1, 0)
listContainer.BackgroundTransparency = 1
listContainer.CanvasSize = UDim2.new(0, 0, 5, 0)

local closestBtn = Instance.new("TextButton", frame)
closestBtn.Size = UDim2.new(0.9, 0, 0, 40)
closestBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
closestBtn.Text = "AIM GẦN NHẤT"

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.05, 0, 0.91, 0)
toggleBtn.Text = "Aimbot: OFF"

-- --- Chức năng ---
local function updatePlayerList()
    for _, child in pairs(listContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local yPos = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", listContainer)
            btn.Size = UDim2.new(1, -10, 0, 50)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.Text = "      " .. p.Name
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BackgroundColor3 = (targetPlayer == p) and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 50)
            
            -- Avatar
            local avatar = Instance.new("ImageLabel", btn)
            avatar.Size = UDim2.new(0, 40, 0, 40)
            avatar.Position = UDim2.new(0, 5, 0, 5)
            avatar.BackgroundTransparency = 1
            pcall(function() avatar.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            
            btn.MouseButton1Click:Connect(function()
                targetPlayer = p
                updatePlayerList()
            end)
            yPos += 55
        end
    end
end

closestBtn.MouseButton1Click:Connect(function()
    local closest, min = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < min then min = dist; closest = p end
        end
    end
    targetPlayer = closest
    updatePlayerList()
end)

toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleBtn.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.AutoRotate = false end
            local targetPos = Vector3.new(targetPlayer.Character.HumanoidRootPart.Position.X, myRoot.Position.Y, targetPlayer.Character.HumanoidRootPart.Position.Z)
            myRoot.CFrame = CFrame.lookAt(myRoot.Position, targetPos)
        end
    elseif player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.AutoRotate = true
    end
end)
