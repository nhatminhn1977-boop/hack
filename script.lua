local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Cài đặt tốc độ xoay (càng lớn càng nhanh)
local rotationSpeed = 0.5 

print("Đang khởi chạy chế độ xoay Anti-AFK...")

-- Sử dụng RenderStepped để chạy liên tục mỗi khung hình (mượt mà)
RunService.RenderStepped:Connect(function()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character.HumanoidRootPart
        
        -- Xoay nhân vật một góc nhỏ mỗi khung hình
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(rotationSpeed), 0)
    end
end)
