local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local emote = playerGui:WaitForChild("Emotes"):WaitForChild("Emote")
local page1 = emote:WaitForChild("Page1")
local page2 = emote:WaitForChild("Page2")
local switch = emote:WaitForChild("Switch")
local equipped = playerGui:WaitForChild("Menus"):WaitForChild("Group"):WaitForChild("Inventory"):WaitForChild("Items"):WaitForChild("Emotes"):WaitForChild("Equipped")

local function show(gui)
    if gui:IsA("GuiObject") then
        gui.Visible = true
        for _, child in ipairs(gui:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
    end
end

local active = false
page2.Visible = false
switch.Visible = true
show(page1)
show(equipped)

switch.MouseButton1Click:Connect(function()
    active = not active
    page1.Visible = not active
    page2.Visible = active
    if active then show(page2) else show(page1) end
end)
