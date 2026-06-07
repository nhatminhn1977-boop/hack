--[=[
 d888b  db     db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88     88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88     88    88           odD'      88      88    88 88ooo88 
88  ooo 88     88    88         .88'        88      88    88 88~~~88 
88. ~8~ 88b   d88   .88.        j88.         88booo. 88b   d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local G2L = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local flying = false
local speed = 50 -- Tốc độ bay gốc của bạn

-- 1. Khởi tạo ScreenGui
G2L["1"] = Instance.new("ScreenGui")
G2L["1"].Name = "UltimateFlySystemGui"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = player:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Tông đen xám)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 240, 0, 110)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1.5

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ELITE FLY SYSTEM ⚡"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Nút Thu Gọn (Đặt ở góc trên bên phải của MainFrame khi mở rộng)
local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -30, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.BorderSizePixel = 0

local MinCorner = Instance.new("UICorner", MinimizeButton)
MinCorner.CornerRadius = UDim.new(0, 5)

-- 3. NÚT BẬT/TẮT BAY
local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 220, 0, 45)
FlyButton.Position = UDim2.new(0.5, -110, 0, 45)
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyButton.Text = "FLY: OFF [E]"
FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
FlyButton.TextSize = 14
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner", FlyButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)

local ButtonStroke = Instance.new("UIStroke", FlyButton)
ButtonStroke.Color = Color3.fromRGB(150, 40, 40)
ButtonStroke.Thickness = 1.5

-- =======================================================
-- HÀM XỬ LÝ BAY (GIỮ NGUYÊN 100% CỐT LÕI CỦA BẠN)
-- =======================================================

local function fly()
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    if flying then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        RunService.RenderStepped:Connect(function()
            if not flying then 
                bv:Destroy()
                return 
            end
            
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            
            bv.Velocity = moveDir * speed
        end)
    end
end

-- =======================================================
-- HỆ THỐNG ĐỒNG BỘ TRẠNG THÁI VÀ CHỨC NĂNG NÂNG CẤP
-- =======================================================

-- Hàm cập nhật giao diện trực quan theo trạng thái
local function ToggleFlyState()
    if flying then
        FlyButton.Text = "FLY: ACTIVE [E]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
        FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonStroke.Color = Color3.fromRGB(255, 50, 50)
        fly()
    else
        FlyButton.Text = "FLY: OFF [E]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        ButtonStroke.Color = Color3.fromRGB(150, 40, 40)
    end
end

-- Sự kiện Click Nút Fly trên UI
FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    ToggleFlyState()
end)

-- Sự kiện Phím E (ĐÃ SỬA LỖI: Luôn cho phép switch kể cả khi thu nhỏ)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        flying = not flying
        ToggleFlyState()
    end
end)

-- 🔄 TỰ ĐỘNG RESET CHẾ ĐỘ KHI CHẾT VÀ HỒI SINH
player.CharacterAdded:Connect(function(newCharacter)
    if flying then
        flying = false
        ToggleFlyState()
    end
end)

-- 📉 TÍNH NĂNG THU GỌN MENU (Đball biến mất, chỉ để lại dấu cộng)
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        -- Thu nhỏ hoàn toàn: Biến MainFrame thành một khối vuông bằng đúng nút dấu cộng
        MainFrame.Size = UDim2.new(0, 30, 0, 30)
        MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Chuyển nền xám cho đồng bộ nút
        MainStroke.Color = Color3.fromRGB(150, 40, 40) -- Viền đỏ neon mỏng quanh dấu cộng cho đẹp
        
        -- Ẩn tất cả các thành phần chữ và nút to đi
        Title.Visible = false
        FlyButton.Visible = false
        
        -- Đưa nút thu nhỏ về vị trí chính giữa để làm dấu "+"
        MinimizeButton.Position = UDim2.new(0, 2, 0, 2)
        MinimizeButton.Text = "+"
        MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        MinimizeButton.BackgroundTransparency = 1 -- Ẩn nền nút nhỏ để nhìn liền mạch với MainFrame
    else
        -- Mở rộng lại bình thường như cũ
        MainFrame.Size = UDim2.new(0, 240, 0, 110)
        MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        MainStroke.Color = Color3.fromRGB(45, 45, 45)
        
        Title.Visible = true
        FlyButton.Visible = true
        
        -- Trả nút thu nhỏ về góc trên bên phải
        MinimizeButton.Position = UDim2.new(1, -30, 0, 5)
        MinimizeButton.Text = "-"
        MinimizeButton.BackgroundTransparency = 0
        MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

return G2L["1"]
