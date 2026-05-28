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
inputBox.PlaceholderText = "Dán Webhook URL..."

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.8, 0, 0, 40)
btn.Position = UDim2.new(0.1, 0, 0.6, 0)
btn.Text = "Bắt đầu Treo (Nhảy Anti-AFK)"
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

-- 2. Logic chính
btn.MouseButton1Click:Connect(function()
    local url = inputBox.Text
    if url == "" then return end
    frame:Destroy()

    local startTime = os.time()
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

    -- Anti-AFK cải tiến (Thay thế đoạn cũ)
    task.spawn(function()
        while true do
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                print("Đã thực hiện lệnh nhảy!") -- Kiểm tra trong Console
            else
                print("Không tìm thấy nhân vật!")
            end
            task.wait(60)
        end
    end)

    -- Vòng lặp gửi Webhook mỗi 10 giây
    task.spawn(function()
        while true do
            local uptime = os.difftime(os.time(), startTime)
            local hours = math.floor(uptime / 3600)
            local minutes = math.floor((uptime % 3600) / 60)
            local seconds = uptime % 60

            local data = {
                ["embeds"] = {{
                    ["title"] = "Trạng thái treo game",
                    ["fields"] = {
                        {["name"] = "Game:", ["value"] = gameName, ["inline"] = false},
                        {["name"] = "Thời gian treo:", ["value"] = string.format("%02d:%02d:%02d", hours, minutes, seconds), ["inline"] = true}
                    },
                    ["color"] = 0x00FF00
                }}
            }

            request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
            
            task.wait(10)
        end
    end)
end)
