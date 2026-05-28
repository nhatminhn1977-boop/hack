local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 1. Tạo GUI nhập liệu
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local inputBox = Instance.new("TextBox", frame)
inputBox.Size = UDim2.new(0.8, 0, 0, 40)
inputBox.Position = UDim2.new(0.1, 0, 0.2, 0)
inputBox.PlaceholderText = "Dán Webhook URL vào đây..."
inputBox.Text = ""

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.8, 0, 0, 40)
btn.Position = UDim2.new(0.1, 0, 0.6, 0)
btn.Text = "Bắt đầu treo"
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

-- 2. Logic xử lý sau khi nhấn nút
btn.MouseButton1Click:Connect(function()
    local url = inputBox.Text
    if url ~= "" then
        frame:Destroy() -- Xóa UI sau khi nhập xong
        
        -- Bắt đầu vòng lặp gửi Webhook
        task.spawn(function()
            local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
            
            while true do
                local data = {
                    ["embeds"] = {{
                        ["title"] = "Trạng thái treo game",
                        ["description"] = "Đang chơi: **" .. gameName .. "**",
                        ["color"] = 3447003,
                        ["footer"] = {["text"] = "Treo game 24/7"}
                    }}
                }

                request({
                    Url = url,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(data)
                })
                
                task.wait(20) -- Gửi mỗi 20 giây
            end
        end)
    end
end)
