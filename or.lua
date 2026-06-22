local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Khởi tạo biến quản lý
local hitboxEnabled = false
local hitboxSize = 10
local hitboxTransparency = 0.7
local originalSizes = {} -- Lưu lại kích thước gốc của người chơi để khôi phục khi tắt

-- Hàm xử lý "in đậm" và phóng to Hitbox từng người chơi
local function applyHitboxLogic(p)
    if p == player then return end -- Không áp dụng lên chính mình
    
    local character = p.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then return end
    
    -- Lưu lại kích thước ban đầu nếu chưa có dữ liệu
    if not originalSizes[p.UserId] then
        originalSizes[p.UserId] = {
            Size = hrp.Size,
            Transparency = hrp.Transparency,
            Color = hrp.Color,
            Material = hrp.Material
        }
    end
    
    -- Tạo hoặc tìm khung viền "In đậm" (SelectionBox)
    local selectionBox = hrp:FindFirstChild("HitboxBoldOutline")
    if not selectionBox then
        selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "HitboxBoldOutline"
        selectionBox.Color3 = Color3.fromRGB(0, 255, 255) -- Màu xanh Neon sáng
        selectionBox.LineThickness = 0.08 -- Độ dày của nét in đậm
        selectionBox.Adornee = hrp
        selectionBox.Parent = hrp
    end
    
    if hitboxEnabled then
        -- Kích hoạt phóng to và hiện hình ảnh
        hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        hrp.Transparency = hitboxTransparency
        hrp.Color = Color3.fromRGB(255, 0, 85) -- Màu hồng/đỏ Neon
        hrp.Material = Enum.Material.Neon
        hrp.CanCollide = false -- Quan trọng: Tránh bị lỗi kẹt hoặc văng map
        selectionBox.Visible = true
    else
        -- Khôi phục về mặc định của Game
        local orig = originalSizes[p.UserId]
        if orig then
            hrp.Size = orig.Size
            hrp.Transparency = orig.Transparency
            hrp.Color = orig.Color
            hrp.Material = orig.Material
            hrp.CanCollide = true
        end
        selectionBox.Visible = false
    end
end

-- Hàm quét cập nhật toàn bộ server
local function updateAllHitboxes()
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function()
            applyHitboxLogic(p)
        end)
    end
end

-- Vòng lặp chạy ngầm nhẹ nhàng để quét người chơi mới hồi sinh hoặc mới vào phòng
task.spawn(function()
    while true do
        task.wait(0.5) -- Quét mỗi 0.5s (Cực nhẹ, không gây giật lag)
        if hitboxEnabled then
            updateAllHitboxes()
        end
    end
end)

-- KHỞI TẠO GIAO DIỆN ĐIỀU KHIỂN (UI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateHitboxGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 240)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(50, 50, 50)
MainStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "HITBOX VISUALIZER & EXPANDER 🎯"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- 1. NÚT TẮT BẬT HITBOX
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0, 270, 0, 40)
ToggleBtn.Position = UDim2.new(0.5, -135, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleBtn.Text = "HITBOX: DISABLED"
ToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(150, 40, 40)
ToggleStroke.Thickness = 1.5

-- 2. ĐIỀU CHỈNH KÍCH THƯỚC (SIZE)
local SizeFrame = Instance.new("Frame", MainFrame)
SizeFrame.Size = UDim2.new(0, 270, 0, 40)
SizeFrame.Position = UDim2.new(0.5, -135, 0, 100)
SizeFrame.BackgroundTransparency = 1

local SizeLabel = Instance.new("TextLabel", SizeFrame)
SizeLabel.Size = UDim2.new(0, 150, 1, 0)
SizeLabel.BackgroundTransparency = 1
SizeLabel.Text = "HITBOX SIZE: " .. tostring(hitboxSize)
SizeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SizeLabel.TextSize = 13
SizeLabel.Font = Enum.Font.SourceSansBold
SizeLabel.TextXAlignment = Enum.TextXAlignment.Left

local SizeDec = Instance.new("TextButton", SizeFrame)
SizeDec.Size = UDim2.new(0, 40, 0, 30)
SizeDec.Position = UDim2.new(1, -85, 0.5, -15)
SizeDec.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SizeDec.Text = "-"
SizeDec.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeDec.TextSize = 16
SizeDec.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", SizeDec).CornerRadius = UDim.new(0, 6)

local SizeInc = Instance.new("TextButton", SizeFrame)
SizeInc.Size = UDim2.new(0, 40, 0, 30)
SizeInc.Position = UDim2.new(1, -40, 0.5, -15)
SizeInc.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SizeInc.Text = "+"
SizeInc.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeInc.TextSize = 16
SizeInc.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", SizeInc).CornerRadius = UDim.new(0, 6)

-- 3. ĐIỀU CHỈNH ĐỘ TRONG SUỐT (TRANSPARENCY)
local TransFrame = Instance.new("Frame", MainFrame)
TransFrame.Size = UDim2.new(0, 270, 0, 40)
TransFrame.Position = UDim2.new(0.5, -135, 0, 150)
TransFrame.BackgroundTransparency = 1

local TransLabel = Instance.new("TextLabel", TransFrame)
TransLabel.Size = UDim2.new(0, 150, 1, 0)
TransLabel.BackgroundTransparency = 1
TransLabel.Text = "HITBOX OPACITY: " .. tostring(1 - hitboxTransparency)
TransLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TransLabel.TextSize = 13
TransLabel.Font = Enum.Font.SourceSansBold
TransLabel.TextXAlignment = Enum.TextXAlignment.Left

local TransDec = Instance.new("TextButton", TransFrame)
TransDec.Size = UDim2.new(0, 40, 0, 30)
TransDec.Position = UDim2.new(1, -85, 0.5, -15)
TransDec.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TransDec.Text = "-"
TransDec.TextColor3 = Color3.fromRGB(255, 255, 255)
TransDec.TextSize = 16
TransDec.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TransDec).CornerRadius = UDim.new(0, 6)

local TransInc = Instance.new("TextButton", TransFrame)
TransInc.Size = UDim2.new(0, 40, 0, 30)
TransInc.Position = UDim2.new(1, -40, 0.5, -15)
TransInc.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TransInc.Text = "+"
TransInc.TextColor3 = Color3.fromRGB(255, 255, 255)
TransInc.TextSize = 16
TransInc.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TransInc).CornerRadius = UDim.new(0, 6)

-- NÚT THU NHỎ (MINIMIZE)
local MinimizeButton = Instance.new("TextButton", MainFrame)
MinimizeButton.Size = U
