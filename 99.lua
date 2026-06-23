local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local homeCFrame = nil
local initChar = player.Character or player.CharacterAdded:Wait()
local initHrp = initChar:WaitForChild("HumanoidRootPart", 10)
if initHrp then
    homeCFrame = initHrp.CFrame
end
for _, guiName in pairs({"ResourceTrackerV5Gui", "ResourceTrackerV6Gui", "ResourceTrackerV7Gui", "ResourceTrackerV8Gui", "ResourceTrackerV9Gui", "ResourceTrackerV10Gui"}) do
    local oldGui = player:WaitForChild("PlayerGui"):FindFirstChild(guiName)
    if oldGui then oldGui:Destroy() end
end
local oldEspFolder = workspace:FindFirstChild("Resource_ESP_Folder")
if oldEspFolder then oldEspFolder:Destroy() end
local espFolder = Instance.new("Folder")
espFolder.Name = "Resource_ESP_Folder"
espFolder.Parent = workspace
local currentTab = "Fuel" 
local TABS_CONFIG = {
    Fuel = {"Coal", "Fuel Canister", "Oil Barrel"},
    Chest = {"Item Chest1", "Item Chest2", "Item Chest3", "Item Chest4", "Item Chest5"},
    Irons = {"Broken Fan", "Broken Microwave", "Old Radio", "Sheet Metal", "Log"}
}
local currentResources = {}
local teleportedObjects = {} 
local MAX_ESP_COUNT = 10     
_G.AutoFarmBunny = false
_G.CheckBunnyFoot = false
_G.AutoFarmWolf = false
_G.CheckWolfPelt = false
_G.AutoFarmAlphaWolf = false
_G.CheckAlphaWolfPelt = false
_G.AutoFarmBear = false
_G.CheckBearPelt = false
local function resetHitbox(mobName)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == mobName then
            local hb = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
            if hb and hb:IsA("BasePart") then
                hb.Size = Vector3.new(2.5, 2.5, 2.5)
                hb.CanCollide = true               
            end
        end
    end
end
local function createESP(object, name, distance)
    if not object or not object.Parent then return end
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ResourceESP"
    bgui.AlwaysOnTop = true
    bgui.Size = UDim2.new(0, 100, 0, 30)
    bgui.Adornee = object
    bgui.MaxDistance = 2500 
    local label = Instance.new("TextLabel", bgui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    local color = Color3.fromRGB(255, 255, 255)
    local icon = "📦"
    if name == "Coal" then 
        color = Color3.fromRGB(170, 170, 170)
        icon = "⚫ Coal"
    elseif name == "Fuel Canister" then 
        color = Color3.fromRGB(46, 204, 113)
        icon = "🔋 Fuel"
    elseif name == "Log" then 
        color = Color3.fromRGB(230, 126, 34)
        icon = "🪵 Log"
    elseif name == "Oil Barrel" then
        color = Color3.fromRGB(52, 152, 219)
        icon = "🛢️ Oil Barrel"
    elseif name == "Broken Fan" then
        color = Color3.fromRGB(149, 165, 166)
        icon = "💨 Broken Fan"
    elseif name == "Broken Microwave" then
        color = Color3.fromRGB(127, 140, 141)
        icon = "📟 Microwave"
    elseif name == "Old Radio" then
        color = Color3.fromRGB(155, 89, 182)
        icon = "📻 Old Radio"
    elseif name == "Sheet Metal" then
        color = Color3.fromRGB(200, 200, 205)
        icon = "🪙 Sheet Metal"
    elseif string.find(name, "Item Chest") then
        color = Color3.fromRGB(241, 196, 15)
        icon = "🎁 " .. string.gsub(name, "Item ", "")
    end
    label.Text = string.format("%s\n[%dm]", icon, math.floor(distance))
    label.TextColor3 = color
    label.TextSize = 10
    label.Font = Enum.Font.SourceSansBold
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    bgui.Parent = espFolder
    local box = Instance.new("SelectionBox")
    box.Adornee = object
    box.Color3 = color
    box.LineThickness = 0.05
    box.Transparency = 0.4
    box.Parent = espFolder
end
local function getSortedResources()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    local myPosition = hrp.Position
    local resourceList = {}
    local targets = TABS_CONFIG[currentTab]
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if teleportedObjects[obj] then continue end
            for _, targetName in pairs(targets) do
                if obj.Name == targetName then
                    local success, objPivot = pcall(function() return obj:GetPivot() end)
                    if success and objPivot then
                        local distance = (myPosition - objPivot.Position).Magnitude
                        local isDuplicateSpatial = false
                        for _, existing in ipairs(resourceList) do
                            if (existing.Position - objPivot.Position).Magnitude < 3 then
                                isDuplicateSpatial = true
                                break
                            end
                        end
                        if not isDuplicateSpatial then
                            table.insert(resourceList, {
                                Object = obj, 
                                Name = obj.Name, 
                                Distance = distance,
                                Position = objPivot.Position
                            })
                        end
                    end
                    break
                end
            end
        end
    end
    table.sort(resourceList, function(a, b)
        return a.Distance < b.Distance
    end)
    return resourceList
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ResourceTrackerV10Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 330, 0, 640) 
MainFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(55, 55, 60)
MainStroke.Thickness = 1.5
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "RESOURCE & ADVANCED FARM HUB v10 🪐"
Title.TextColor3 = Color3.fromRGB(245, 245, 245)
Title.TextSize = 11
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, -20, 0, 30)
TabFrame.Position = UDim2.new(0, 10, 0, 35)
TabFrame.BackgroundTransparency = 1
local FuelTabBtn = Instance.new("TextButton", TabFrame)
FuelTabBtn.Size = UDim2.new(0.33, -4, 1, 0)
FuelTabBtn.Position = UDim2.new(0, 0, 0, 0)
FuelTabBtn.Font = Enum.Font.SourceSansBold
FuelTabBtn.TextSize = 10
Instance.new("UICorner", FuelTabBtn).CornerRadius = UDim.new(0, 5)
local ChestTabBtn = Instance.new("TextButton", TabFrame)
ChestTabBtn.Size = UDim2.new(0.33, -4, 1, 0)
ChestTabBtn.Position = UDim2.new(0.33, 2, 0, 0)
ChestTabBtn.Font = Enum.Font.SourceSansBold
ChestTabBtn.TextSize = 10
Instance.new("UICorner", ChestTabBtn).CornerRadius = UDim.new(0, 5)
local IronsTabBtn = Instance.new("TextButton", TabFrame)
IronsTabBtn.Size = UDim2.new(0.34, -4, 1, 0)
IronsTabBtn.Position = UDim2.new(0.66, 4, 0, 0)
IronsTabBtn.Font = Enum.Font.SourceSansBold
IronsTabBtn.TextSize = 10
Instance.new("UICorner", IronsTabBtn).CornerRadius = UDim.new(0, 5)
local RefreshBtn = Instance.new("TextButton", MainFrame)
RefreshBtn.Size = UDim2.new(1, -20, 0, 25)
RefreshBtn.Position = UDim2.new(0, 10, 0, 70)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
RefreshBtn.Text = "MANUAL REFRESH (RESET ALL) 🔄"
RefreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
RefreshBtn.TextSize = 10
RefreshBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", RefreshBtn).Color = Color3.fromRGB(60, 60, 65)
local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Size = UDim2.new(1, -20, 0, 150)
ScrollList.Position = UDim2.new(0, 10, 0, 100)
ScrollList.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
local ListLayout = Instance.new("UIListLayout", ScrollList)
ListLayout.Padding = UDim.new(0, 5)
local QuickTeleBtn = Instance.new("TextButton", MainFrame)
QuickTeleBtn.Size = UDim2.new(1, -20, 0, 35)
QuickTeleBtn.Position = UDim2.new(0, 10, 0, 255)
QuickTeleBtn.BackgroundColor3 = Color3.fromRGB(46, 134, 222)
QuickTeleBtn.Text = "TELEPORT TO CLOSEST ITEM 🚀"
QuickTeleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
QuickTeleBtn.TextSize = 11
QuickTeleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", QuickTeleBtn).CornerRadius = UDim.new(0, 6)
local HomeBtn = Instance.new("TextButton", MainFrame)
HomeBtn.Size = UDim2.new(1, -20, 0, 35)
HomeBtn.Position = UDim2.new(0, 10, 0, 295)
HomeBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
HomeBtn.Text = "🏠 TELEPORT TO HOME BASE"
HomeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HomeBtn.TextSize = 11
HomeBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", HomeBtn).CornerRadius = UDim.new(0, 6)
local FarmSectionLabel = Instance.new("TextLabel", MainFrame)
FarmSectionLabel.Size = UDim2.new(1, -20, 0, 20)
FarmSectionLabel.Position = UDim2.new(0, 10, 0, 335)
FarmSectionLabel.BackgroundTransparency = 1
FarmSectionLabel.Text = "─── AUTO FARM SYSTEM ───"
FarmSectionLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
FarmSectionLabel.TextSize = 11
FarmSectionLabel.Font = Enum.Font.SourceSansBold
local FarmScroll = Instance.new("ScrollingFrame", MainFrame)
FarmScroll.Size = UDim2.new(1, -20, 0, 270)
FarmScroll.Position = UDim2.new(0, 10, 0, 360)
FarmScroll.BackgroundTransparency = 1
FarmScroll.BorderSizePixel = 0
FarmScroll.ScrollBarThickness = 3
local FarmLayout = Instance.new("UIListLayout", FarmScroll)
FarmLayout.Padding = UDim.new(0, 6)
local AutoFarmBunnyBtn = Instance.new("TextButton", FarmScroll)
AutoFarmBunnyBtn.Size = UDim2.new(1, -6, 0, 32)
AutoFarmBunnyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
AutoFarmBunnyBtn.Text = "🐰 AUTO FARM BUNNY: OFF"
AutoFarmBunnyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoFarmBunnyBtn.TextSize = 11
AutoFarmBunnyBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", AutoFarmBunnyBtn).CornerRadius = UDim.new(0, 6)
local FarmStroke = Instance.new("UIStroke", AutoFarmBunnyBtn)
FarmStroke.Color = Color3.fromRGB(55, 55, 60)
local BunnyFootToggleBtn = Instance.new("TextButton", FarmScroll)
BunnyFootToggleBtn.Size = UDim2.new(1, -6, 0, 32)
BunnyFootToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
BunnyFootToggleBtn.Text = "🦶 CHECK BUNNY FOOT (100 studs): OFF"
BunnyFootToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
BunnyFootToggleBtn.TextSize = 11
BunnyFootToggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", BunnyFootToggleBtn).CornerRadius = UDim.new(0, 6)
local FootStroke = Instance.new("UIStroke", BunnyFootToggleBtn)
FootStroke.Color = Color3.fromRGB(55, 55, 60)
local AutoFarmWolfBtn = Instance.new("TextButton", FarmScroll)
AutoFarmWolfBtn.Size = UDim2.new(1, -6, 0, 32)
AutoFarmWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
AutoFarmWolfBtn.Text = "🐺 AUTO FARM WOLF: OFF"
AutoFarmWolfBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoFarmWolfBtn.TextSize = 11
AutoFarmWolfBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", AutoFarmWolfBtn).CornerRadius = UDim.new(0, 6)
local WolfStroke = Instance.new("UIStroke", AutoFarmWolfBtn)
WolfStroke.Color = Color3.fromRGB(55, 55, 60)
local WolfPeltToggleBtn = Instance.new("TextButton", FarmScroll)
WolfPeltToggleBtn.Size = UDim2.new(1, -6, 0, 32)
WolfPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
WolfPeltToggleBtn.Text = "🩸 CHECK WOLF PELT (100 studs): OFF"
WolfPeltToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
WolfPeltToggleBtn.TextSize = 11
WolfPeltToggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", WolfPeltToggleBtn).CornerRadius = UDim.new(0, 6)
local PeltStroke = Instance.new("UIStroke", WolfPeltToggleBtn)
PeltStroke.Color = Color3.fromRGB(55, 55, 60)
local AutoFarmAlphaWolfBtn = Instance.new("TextButton", FarmScroll)
AutoFarmAlphaWolfBtn.Size = UDim2.new(1, -6, 0, 32)
AutoFarmAlphaWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
AutoFarmAlphaWolfBtn.Text = "👑 AUTO FARM ALPHA WOLF: OFF"
AutoFarmAlphaWolfBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoFarmAlphaWolfBtn.TextSize = 11
AutoFarmAlphaWolfBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", AutoFarmAlphaWolfBtn).CornerRadius = UDim.new(0, 6)
local AlphaWolfStroke = Instance.new("UIStroke", AutoFarmAlphaWolfBtn)
AlphaWolfStroke.Color = Color3.fromRGB(55, 55, 60)
local AlphaWolfPeltToggleBtn = Instance.new("TextButton", FarmScroll)
AlphaWolfPeltToggleBtn.Size = UDim2.new(1, -6, 0, 32)
AlphaWolfPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
AlphaWolfPeltToggleBtn.Text = "✨ CHECK ALPHA WOLF PELT (100 studs): OFF"
AlphaWolfPeltToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
AlphaWolfPeltToggleBtn.TextSize = 11
AlphaWolfPeltToggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", AlphaWolfPeltToggleBtn).CornerRadius = UDim.new(0, 6)
local AlphaPeltStroke = Instance.new("UIStroke", AlphaWolfPeltToggleBtn)
AlphaPeltStroke.Color = Color3.fromRGB(55, 55, 60)
local AutoFarmBearBtn = Instance.new("TextButton", FarmScroll)
AutoFarmBearBtn.Size = UDim2.new(1, -6, 0, 32)
AutoFarmBearBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
AutoFarmBearBtn.Text = "🐻 AUTO FARM BEAR: OFF"
AutoFarmBearBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoFarmBearBtn.TextSize = 11
AutoFarmBearBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", AutoFarmBearBtn).CornerRadius = UDim.new(0, 6)
local BearStroke = Instance.new("UIStroke", AutoFarmBearBtn)
BearStroke.Color = Color3.fromRGB(55, 55, 60)
local BearPeltToggleBtn = Instance.new("TextButton", FarmScroll)
BearPeltToggleBtn.Size = UDim2.new(1, -6, 0, 32)
BearPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
BearPeltToggleBtn.Text = "🪵 CHECK BEAR PELT (100 studs): OFF"
BearPeltToggleBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
BearPeltToggleBtn.TextSize = 11
BearPeltToggleBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", BearPeltToggleBtn).CornerRadius = UDim.new(0, 6)
local BearPeltStroke = Instance.new("UIStroke", BearPeltToggleBtn)
BearPeltStroke.Color = Color3.fromRGB(55, 55, 60)
FarmLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    FarmScroll.CanvasSize = UDim2.new(0, 0, 0, FarmLayout.AbsoluteContentSize.Y + 10)
end)
local function executeTeleport(targetObj, itemFrame)
    if itemFrame then itemFrame:Destroy() end
    if targetObj then
        teleportedObjects[targetObj] = true
        for _, child in pairs(espFolder:GetChildren()) do
            if (child:IsA("BillboardGui") or child:IsA("SelectionBox")) and child.Adornee == targetObj then 
                child:Destroy() 
            end
        end
        for i, data in ipairs(currentResources) do
            if data.Object == targetObj then
                table.remove(currentResources, i)
                break
            end
        end
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp and targetObj.Parent then
            hrp.CFrame = targetObj:GetPivot() * CFrame.new(0, 3, 0)
        end
        return true
    end
    return false
end
local function updateTabVisuals()
    FuelTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    FuelTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    FuelTabBtn.Text = "FUEL 🔥"
    ChestTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    ChestTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    ChestTabBtn.Text = "CHESTS 🎁"
    IronsTabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    IronsTabBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    IronsTabBtn.Text = "IRONS ⚙️"
    if currentTab == "Fuel" then
        FuelTabBtn.BackgroundColor3 = Color3.fromRGB(46, 134, 222)
        FuelTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        FuelTabBtn.Text = "🔥 FUEL ACTIVE"
    elseif currentTab == "Chest" then
        ChestTabBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15) 
        ChestTabBtn.TextColor3 = Color3.fromRGB(16, 16, 18)
        ChestTabBtn.Text = "✨ CHEST ACTIVE"
    elseif currentTab == "Irons" then
        IronsTabBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        IronsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        IronsTabBtn.Text = "🛠️ IRONS ACTIVE"
    end
end
_G.UpdateUIList = function(clearExclusions)
    if clearExclusions then teleportedObjects = {} end
    espFolder:ClearAllChildren()
    for _, child in pairs(ScrollList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    currentResources = getSortedResources()
    for index, data in ipairs(currentResources) do
        local itemFrame = Instance.new("Frame", ScrollList)
        itemFrame.Size = UDim2.new(1, 0, 0, 35)
        itemFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
        data.CurrentFrame = itemFrame
        local txt = Instance.new("TextLabel", itemFrame)
        txt.Size = UDim2.new(1, -75, 1, 0)
        txt.Position = UDim2.new(0, 10, 0, 0)
        txt.BackgroundTransparency = 1
        local displayName = data.Name
        if data.Name == "Fuel Canister" then
            displayName = "Fuel"
        elseif string.find(data.Name, "Item Chest") then
            displayName = string.gsub(data.Name, "Item ", "")
        end
        txt.Text = string.format("%s — %d Studs", displayName, math.floor(data.Distance))
        txt.TextColor3 = Color3.fromRGB(210, 210, 215)
        txt.TextSize = 11
        txt.Font = Enum.Font.SourceSansBold
        txt.TextXAlignment = Enum.TextXAlignment.Left
        local teleBtn = Instance.new("TextButton", itemFrame)
        teleBtn.Size = UDim2.new(0, 60, 1, -8)
        teleBtn.Position = UDim2.new(1, -65, 0, 4)
        if currentTab == "Chest" then
            teleBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
            teleBtn.TextColor3 = Color3.fromRGB(16, 16, 18)
        elseif currentTab == "Irons" then
            teleBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
            teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            teleBtn.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
            teleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
        teleBtn.Text = "TELE"
        teleBtn.TextSize = 10
        teleBtn.Font = Enum.Font.SourceSansBold
        Instance.new("UICorner", teleBtn).CornerRadius = UDim.new(0, 4)
        teleBtn.MouseButton1Down:Connect(function()
            executeTeleport(data.Object, itemFrame)
        end)
        if index <= MAX_ESP_COUNT then
            createESP(data.Object, data.Name, data.Distance)
        end
    end
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)
AutoFarmBunnyBtn.MouseButton1Down:Connect(function()
    _G.AutoFarmBunny = not _G.AutoFarmBunny
    if _G.AutoFarmBunny then
        _G.AutoFarmWolf = false; _G.AutoFarmAlphaWolf = false; _G.AutoFarmBear = false
        resetHitbox("Wolf"); resetHitbox("Alpha Wolf"); resetHitbox("Bear")
        AutoFarmWolfBtn.Text = "🐺 AUTO FARM WOLF: OFF"; AutoFarmWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); WolfStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmAlphaWolfBtn.Text = "👑 AUTO FARM ALPHA WOLF: OFF"; AutoFarmAlphaWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); AlphaWolfStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmBearBtn.Text = "🐻 AUTO FARM BEAR: OFF"; AutoFarmBearBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); BearStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmBunnyBtn.Text = "🐰 AUTO FARM BUNNY: ON"
        AutoFarmBunnyBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        FarmStroke.Color = Color3.fromRGB(50, 255, 50)
    else
        _G.AutoFarmBunny = false
        resetHitbox("Bunny") 
        AutoFarmBunnyBtn.Text = "🐰 AUTO FARM BUNNY: OFF"
        AutoFarmBunnyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        FarmStroke.Color = Color3.fromRGB(55, 55, 60)
    end
end)
BunnyFootToggleBtn.MouseButton1Down:Connect(function()
    _G.CheckBunnyFoot = not _G.CheckBunnyFoot
    if _G.CheckBunnyFoot then
        BunnyFootToggleBtn.Text = "💡 CHECK FOOT: ENABLED"
        BunnyFootToggleBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        FootStroke.Color = Color3.fromRGB(255, 150, 50)
    else
        BunnyFootToggleBtn.Text = "🦶 CHECK BUNNY FOOT (100 studs): OFF"
        BunnyFootToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        FootStroke.Color = Color3.fromRGB(55, 55, 60)
    end
end)
local function checkBunnyFootNearby()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Bunny Foot" then
            local root = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true) or (obj:IsA("Model") and obj.PrimaryPart)
            if root and (hrp.Position - root.Position).Magnitude <= 100 then return true end
        end
    end
    return false
end
local function getClosestBunny()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closestTarget, maxDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Bunny" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local root = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if root and (not humanoid or humanoid.Health > 0) then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < maxDist then maxDist = dist; closestTarget = obj end
            end
        end
    end
    return closestTarget
end
task.spawn(function()
    while true do
        if _G.AutoFarmBunny then
            if _G.CheckBunnyFoot and checkBunnyFootNearby() then
                _G.AutoFarmBunny = false
                resetHitbox("Bunny") 
                AutoFarmBunnyBtn.Text = "🐰 AUTO FARM BUNNY: OFF"
                AutoFarmBunnyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
                FarmStroke.Color = Color3.fromRGB(55, 55, 60)
            else
                local bunny = getClosestBunny()
                if bunny then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name == "Bunny" then
                            local hb = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                            if hb and hb:IsA("BasePart") and hb.Size.X < 100 then
                                hb.Size = Vector3.new(100, 100, 100)
                                hb.CanCollide = false
                            end
                        end
                    end
                    local character = player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bunnyRoot = bunny:IsA("BasePart") and bunny or bunny:FindFirstChild("HumanoidRootPart") or bunny.PrimaryPart
                        local timeout = 0
                        while bunny and bunny.Parent and _G.AutoFarmBunny do
                            local humanoid = bunny:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health <= 0 then break end
                            if not bunnyRoot or not bunnyRoot:IsDescendantOf(Workspace) then break end
                            hrp.CFrame = CFrame.new(bunnyRoot.Position + Vector3.new(0, 20, 0))
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                            timeout = timeout + 0.05
                            if timeout > 3 then break end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
AutoFarmWolfBtn.MouseButton1Down:Connect(function()
    _G.AutoFarmWolf = not _G.AutoFarmWolf
    if _G.AutoFarmWolf then
        _G.AutoFarmBunny = false; _G.AutoFarmAlphaWolf = false; _G.AutoFarmBear = false
        resetHitbox("Bunny"); resetHitbox("Alpha Wolf"); resetHitbox("Bear")
        AutoFarmBunnyBtn.Text = "🐰 AUTO FARM BUNNY: OFF"; AutoFarmBunnyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); FarmStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmAlphaWolfBtn.Text = "👑 AUTO FARM ALPHA WOLF: OFF"; AutoFarmAlphaWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); AlphaWolfStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmBearBtn.Text = "🐻 AUTO FARM BEAR: OFF"; AutoFarmBearBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); BearStroke.Color = Color3.fromRGB(55, 55, 60)

        AutoFarmWolfBtn.Text = "🐺 AUTO FARM WOLF: ON"
        AutoFarmWolfBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        WolfStroke.Color = Color3.fromRGB(50, 255, 50)
    else
        _G.AutoFarmWolf = false
        resetHitbox("Wolf") 
        AutoFarmWolfBtn.Text = "🐺 AUTO FARM WOLF: OFF"
        AutoFarmWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        WolfStroke.Color = Color3.fromRGB(55, 55, 60)
    end
end)
WolfPeltToggleBtn.MouseButton1Down:Connect(function()
    _G.CheckWolfPelt = not _G.CheckWolfPelt
    if _G.CheckWolfPelt then
        WolfPeltToggleBtn.Text = "💡 CHECK PELT: ENABLED"
        WolfPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        PeltStroke.Color = Color3.fromRGB(255, 150, 50)
    else
        WolfPeltToggleBtn.Text = "🩸 CHECK WOLF PELT (100 studs): OFF"
        WolfPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        PeltStroke.Color = Color3.fromRGB(55, 55, 60)
    end
end)
local function checkWolfPeltNearby()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Wolf Pelt" then
            local root = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true) or (obj:IsA("Model") and obj.PrimaryPart)
            if root and (hrp.Position - root.Position).Magnitude <= 100 then return true end
        end
    end
    return false
end
local function getClosestWolf()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closestTarget, maxDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Wolf" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local root = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if root and (not humanoid or humanoid.Health > 0) then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < maxDist then maxDist = dist; closestTarget = obj end
            end
        end
    end
    return closestTarget
end
task.spawn(function()
    while true do
        if _G.AutoFarmWolf then
            if _G.CheckWolfPelt and checkWolfPeltNearby() then
                _G.AutoFarmWolf = false
                resetHitbox("Wolf") 
                AutoFarmWolfBtn.Text = "🐺 AUTO FARM WOLF: OFF"
                AutoFarmWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
                WolfStroke.Color = Color3.fromRGB(55, 55, 60)
            else
                local wolf = getClosestWolf()
                if wolf then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name == "Wolf" then
                            local hb = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                            if hb and hb:IsA("BasePart") and hb.Size.X < 100 then
                                hb.Size = Vector3.new(100, 100, 100)
                                hb.CanCollide = false
                            end
                        end
                    end
                    local character = player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local wolfRoot = wolf:IsA("BasePart") and wolf or wolf:FindFirstChild("HumanoidRootPart") or wolf.PrimaryPart
                        local timeout = 0
                        while wolf and wolf.Parent and _G.AutoFarmWolf do
                            local humanoid = wolf:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health <= 0 then break end
                            if not wolfRoot or not wolfRoot:IsDescendantOf(Workspace) then break end
                            hrp.CFrame = CFrame.new(wolfRoot.Position + Vector3.new(0, 20, 0))
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                            timeout = timeout + 0.05
                            if timeout > 3 then break end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
AutoFarmAlphaWolfBtn.MouseButton1Down:Connect(function()
    _G.AutoFarmAlphaWolf = not _G.AutoFarmAlphaWolf
    if _G.AutoFarmAlphaWolf then
        _G.AutoFarmBunny = false; _G.AutoFarmWolf = false; _G.AutoFarmBear = false
        resetHitbox("Bunny"); resetHitbox("Wolf"); resetHitbox("Bear")
        AutoFarmBunnyBtn.Text = "🐰 AUTO FARM BUNNY: OFF"; AutoFarmBunnyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); FarmStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmWolfBtn.Text = "🐺 AUTO FARM WOLF: OFF"; AutoFarmWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); WolfStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmBearBtn.Text = "🐻 AUTO FARM BEAR: OFF"; AutoFarmBearBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); BearStroke.Color = Color3.fromRGB(55, 55, 60)

        AutoFarmAlphaWolfBtn.Text = "👑 AUTO FARM ALPHA WOLF: ON"
        AutoFarmAlphaWolfBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        AlphaWolfStroke.Color = Color3.fromRGB(50, 255, 50)
    else
        _G.AutoFarmAlphaWolf = false
        resetHitbox("Alpha Wolf") 
        AutoFarmAlphaWolfBtn.Text = "👑 AUTO FARM ALPHA WOLF: OFF"
        AutoFarmAlphaWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        AlphaWolfStroke.Color = Color3.fromRGB(55, 55, 60)
    end
end)
AlphaWolfPeltToggleBtn.MouseButton1Down:Connect(function()
    _G.CheckAlphaWolfPelt = not _G.CheckAlphaWolfPelt
    if _G.CheckAlphaWolfPelt then
        AlphaWolfPeltToggleBtn.Text = "💡 CHECK ALPHA PELT: ENABLED"
        AlphaWolfPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        AlphaPeltStroke.Color = Color3.fromRGB(255, 150, 50)
    else
        AlphaWolfPeltToggleBtn.Text = "✨ CHECK ALPHA WOLF PELT (100 studs): OFF"
        AlphaWolfPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        AlphaPeltStroke.Color = Color3.fromRGB(55, 55, 60)
    end
end)
local function checkAlphaWolfPeltNearby()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Alpha Wolf Pelt" or obj.Name == "Alpha Wofl Pelt" then
            local root = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true) or (obj:IsA("Model") and obj.PrimaryPart)
            if root and (hrp.Position - root.Position).Magnitude <= 100 then return true end
        end
    end
    return false
end
local function getClosestAlphaWolf()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closestTarget, maxDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Alpha Wolf" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local root = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if root and (not humanoid or humanoid.Health > 0) then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < maxDist then maxDist = dist; closestTarget = obj end
            end
        end
    end
    return closestTarget
end
task.spawn(function()
    while true do
        if _G.AutoFarmAlphaWolf then
            if _G.CheckAlphaWolfPelt and checkAlphaWolfPeltNearby() then
                _G.AutoFarmAlphaWolf = false
                resetHitbox("Alpha Wolf") 
                AutoFarmAlphaWolfBtn.Text = "👑 AUTO FARM ALPHA WOLF: OFF"
                AutoFarmAlphaWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
                AlphaWolfStroke.Color = Color3.fromRGB(55, 55, 60)
            else
                local alphaWolf = getClosestAlphaWolf()
                if alphaWolf then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name == "Alpha Wolf" then
                            local hb = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                            if hb and hb:IsA("BasePart") and hb.Size.X < 100 then
                                hb.Size = Vector3.new(100, 100, 100)
                                hb.CanCollide = false
                            end
                        end
                    end
                    local character = player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local alphaRoot = alphaWolf:IsA("BasePart") and alphaWolf or alphaWolf:FindFirstChild("HumanoidRootPart") or alphaWolf.PrimaryPart
                        local timeout = 0
                        while alphaWolf and alphaWolf.Parent and _G.AutoFarmAlphaWolf do
                            local humanoid = alphaWolf:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health <= 0 then break end
                            if not alphaRoot or not alphaRoot:IsDescendantOf(Workspace) then break end
                            hrp.CFrame = CFrame.new(alphaRoot.Position + Vector3.new(0, 20, 0))
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                            timeout = timeout + 0.05
                            if timeout > 3 then break end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
AutoFarmBearBtn.MouseButton1Down:Connect(function()
    _G.AutoFarmBear = not _G.AutoFarmBear
    if _G.AutoFarmBear then
        _G.AutoFarmBunny = false; _G.AutoFarmWolf = false; _G.AutoFarmAlphaWolf = false
        resetHitbox("Bunny"); resetHitbox("Wolf"); resetHitbox("Alpha Wolf")
        AutoFarmBunnyBtn.Text = "🐰 AUTO FARM BUNNY: OFF"; AutoFarmBunnyBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); FarmStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmWolfBtn.Text = "🐺 AUTO FARM WOLF: OFF"; AutoFarmWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); WolfStroke.Color = Color3.fromRGB(55, 55, 60)
        AutoFarmAlphaWolfBtn.Text = "👑 AUTO FARM ALPHA WOLF: OFF"; AutoFarmAlphaWolfBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33); AlphaWolfStroke.Color = Color3.fromRGB(55, 55, 60)

        AutoFarmBearBtn.Text = "🐻 AUTO FARM BEAR: ON"
        AutoFarmBearBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        BearStroke.Color = Color3.fromRGB(50, 255, 50)
    else
        _G.AutoFarmBear = false
        resetHitbox("Bear") 
        AutoFarmBearBtn.Text = "🐻 AUTO FARM BEAR: OFF"
        AutoFarmBearBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        BearStroke.Color = Color3.fromRGB(55, 55, 60)
    end
end)
BearPeltToggleBtn.MouseButton1Down:Connect(function()
    _G.CheckBearPelt = not _G.CheckBearPelt
    if _G.CheckBearPelt then
        BearPeltToggleBtn.Text = "💡 CHECK BEAR PELT: ENABLED"
        BearPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(230, 126, 34)
        BearPeltStroke.Color = Color3.fromRGB(255, 150, 50)
    else
        BearPeltToggleBtn.Text = "🪵 CHECK BEAR PELT (100 studs): OFF"
        BearPeltToggleBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
        BearPeltStroke.Color = Color3.fromRGB(55, 55, 60)
    end
end)
local function checkBearPeltNearby()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Bear Pelt" then
            local root = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true) or (obj:IsA("Model") and obj.PrimaryPart)
            if root and (hrp.Position - root.Position).Magnitude <= 100 then return true end
        end
    end
    return false
end
local function getClosestBear()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closestTarget, maxDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Bear" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local root = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            if root and (not humanoid or humanoid.Health > 0) then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < maxDist then maxDist = dist; closestTarget = obj end
            end
        end
    end
    return closestTarget
end
task.spawn(function()
    while true do
        if _G.AutoFarmBear then
            if _G.CheckBearPelt and checkBearPeltNearby() then
                _G.AutoFarmBear = false
                resetHitbox("Bear") 
                AutoFarmBearBtn.Text = "🐻 AUTO FARM BEAR: OFF"
                AutoFarmBearBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
                BearStroke.Color = Color3.fromRGB(55, 55, 60)
            else
                local bear = getClosestBear()
                if bear then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name == "Bear" then
                            local hb = obj:IsA("BasePart") and obj or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                            if hb and hb:IsA("BasePart") and hb.Size.X < 100 then
                                hb.Size = Vector3.new(100, 100, 100)
                                hb.CanCollide = false
                            end
                        end
                    end
                    local character = player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local bearRoot = bear:IsA("BasePart") and bear or bear:FindFirstChild("HumanoidRootPart") or bear.PrimaryPart
                        local timeout = 0
                        while bear and bear.Parent and _G.AutoFarmBear do
                            local humanoid = bear:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health <= 0 then break end
                            if not bearRoot or not bearRoot:IsDescendantOf(Workspace) then break end
                            hrp.CFrame = CFrame.new(bearRoot.Position + Vector3.new(0, 20, 0))
                            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                            timeout = timeout + 0.05
                            if timeout > 3 then break end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
FuelTabBtn.MouseButton1Down:Connect(function()
    if currentTab ~= "Fuel" then
        currentTab = "Fuel"
        updateTabVisuals()
        _G.UpdateUIList(false)
    end
end)
ChestTabBtn.MouseButton1Down:Connect(function()
    if currentTab ~= "Chest" then
        currentTab = "Chest"
        updateTabVisuals()
        _G.UpdateUIList(false)
    end
end)
IronsTabBtn.MouseButton1Down:Connect(function()
    if currentTab ~= "Irons" then
        currentTab = "Irons"
        updateTabVisuals()
        _G.UpdateUIList(false)
    end
end)
QuickTeleBtn.MouseButton1Down:Connect(function()
    if #currentResources > 0 then
        local closest = currentResources[1]
        if closest and closest.Object then
            executeTeleport(closest.Object, closest.CurrentFrame)
        end
    end
end)
RefreshBtn.MouseButton1Down:Connect(function()
    _G.UpdateUIList(true)
end)
HomeBtn.MouseButton1Down:Connect(function()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if hrp and homeCFrame then
        hrp.CFrame = homeCFrame
    end
end)
-- Khởi chạy mặc định lần đầu
updateTabVisuals()
_G.UpdateUIList(true)
