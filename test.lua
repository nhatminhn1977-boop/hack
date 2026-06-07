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
G2L["1"].Name = "EliteFlySystemGui"
G2L["1"].ResetOnSpawn = false
G2L["1"].Parent = player:WaitForChild("PlayerGui")

-- 2. Tạo Frame chính (Tông đen xám sang trọng)
local MainFrame = Instance.new("Frame", G2L["1"])
MainFrame.Size = UDim2.new(0, 240, 0, 110)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- Nằm gọn gàng bên góc trái màn hình
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) -- Đen sâu huyền bí
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Viền ngoài màu xám Titan sắc nét
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1.5

-- Tiêu đề Menu (Chữ trắng pha đỏ sang chảnh)
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ELITE FLY SYSTEM ⚡"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold

-- 3. NÚT BẬT/TẮT BAY (Màu đỏ neon / xám trạng thái)
local FlyButton = Instance.new("TextButton", MainFrame)
FlyButton.Size = UDim2.new(0, 200, 0, 45)
FlyButton.Position = UDim2.new(0.5, -100, 0, 45)
FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Mặc định màu tối khi chưa bay
FlyButton.Text = "FLY: OFF [E]"
FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
FlyButton.TextSize = 14
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.BorderSizePixel = 0

local ButtonCorner = Instance.new("UICorner", FlyButton)
ButtonCorner.CornerRadius = UDim.new(0, 8)

-- Viền nút bấm mặc định màu đỏ trầm
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
        -- Vô hiệu hóa trọng lực và di chuyển theo hướng camera
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
            
            -- Điều khiển bằng phím WASD
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            
            bv.Velocity = moveDir * speed
        end)
    end
end

-- =======================================================
-- HỆ THỐNG ĐỒNG BỘ TRẠNG THÁI GIỮA NÚT UI VÀ PHÍM TẮT
-- =======================================================

-- Hàm cập nhật giao diện trực quan theo trạng thái bay
local function ToggleFlyState()
    if flying then
        FlyButton.Text = "FLY: ACTIVE [E]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20) -- Đỏ rực khi bật
        FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ButtonStroke.Color = Color3.fromRGB(255, 50, 50) -- Viền sáng rực
        fly()
    else
        FlyButton.Text = "FLY: OFF [E]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Trở về màu tối
        FlyButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        ButtonStroke.Color = Color3.fromRGB(150, 40, 40)
    end
end

-- Lắng nghe sự kiện click chuột vào nút trên UI
FlyButton.MouseButton1Click:Connect(function()
    flying = not flying
    ToggleFlyState()
end)

-- Bật/Tắt bay bằng phím E (Kết hợp đồng bộ UI)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        flying = not flying
        ToggleFlyState()
    end
end)

return G2L["1"]
