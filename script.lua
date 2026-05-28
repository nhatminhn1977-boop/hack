local webhookUrl = "https://discordapp.com/api/webhooks/1509390748334817321/SS-U1Yco3JUNLJ-wRcCAumZ99SVpwE9oJ4QGzdoe0P4jiebtY9pMCcekUaNDT5-GuzDx"
local HttpService = game:GetService("HttpService")

-- Lấy tên game hiện tại
local gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

print("Đang bắt đầu gửi thông báo đến Discord...")

while true do
    local data = {
        ["embeds"] = {{
            ["title"] = "Trạng thái treo game",
            ["description"] = "Bạn đang chơi game: **" .. gameName .. "**",
            ["color"] = 3447003 -- Màu xanh dương
        }}
    }

    local jsonData = HttpService:JSONEncode(data)

    -- Gửi request đến Discord
    local success, response = pcall(function()
        return request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end)

    if success then
        print("Đã gửi thành công!")
    else
        warn("Gửi thất bại: " .. tostring(response))
    end

    -- Đợi 10 giây trước khi gửi tiếp
    task.wait(10) 
end
