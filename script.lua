local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local player = Players.LocalPlayer

-- 1. Tạo UI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local inputBox = Instance.new("TextBox", frame)
inputBox.Size = UDim2.new(0.8, 0, 0, 40)
inputBox.Position = UDim2.new(0.1, 0, 0.2, 0)
inputBox.PlaceholderText = "Nhập Asset ID (Số)..."
inputBox.Parent = frame

local equipBtn = Instance.new("TextButton", frame)
equipBtn.Size = UDim2.new(0.8, 0, 0, 40)
equipBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
equipBtn.Text = "Mặc bằng ID"
equipBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
equipBtn.Parent = frame

-- 2. Logic mặc đồ bằng ID
equipBtn.MouseButton1Click:Connect(function()
    local id = tonumber(inputBox.Text)
    if not id then return end

    -- Load phụ kiện từ Roblox thông qua ID
    local success, asset = pcall(function()
        return MarketplaceService:LoadAsset(id)
    end)

    if success and asset then
        local accessory = asset:FindFirstChildOfClass("Accessory")
        if accessory then
            accessory.Parent = player.Character
            print("Đã mặc phụ kiện ID: " .. id)
        else
            warn("ID này không phải là một Accessory hợp lệ!")
        end
        asset:Destroy() -- Xóa model tạm sau khi lấy xong accessory
    else
        warn("Không thể tải ID này: " .. tostring(asset))
    end
end)
