
-- Gui Auto Bounty Display + Auto Player Scan + Server Hop

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- UI Elements
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
local UICorner = Instance.new("UICorner", MainFrame)
local Title = Instance.new("TextLabel", MainFrame)
local CurrentBounty = Instance.new("TextLabel", MainFrame)
local BountyFarmed = Instance.new("TextLabel", MainFrame)
local TimeElapsed = Instance.new("TextLabel", MainFrame)
local NextPlayer = Instance.new("TextButton", MainFrame)

-- Fake values to simulate
local bounty = 2606852
local farmed = 0
local secondsUsed = 0

-- Style UI
ScreenGui.Name = "AutoBountyGUI"
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0, 50, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
UICorner.CornerRadius = UDim.new(0, 12)

Title.Text = "Auto Bounty GUI"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

CurrentBounty.Position = UDim2.new(0, 10, 0, 50)
CurrentBounty.Size = UDim2.new(1, -20, 0, 25)
CurrentBounty.BackgroundTransparency = 1
CurrentBounty.TextColor3 = Color3.fromRGB(255, 255, 255)
CurrentBounty.Font = Enum.Font.Gotham
CurrentBounty.TextSize = 16
CurrentBounty.TextXAlignment = Enum.TextXAlignment.Left

BountyFarmed.Position = UDim2.new(0, 10, 0, 80)
BountyFarmed.Size = UDim2.new(1, -20, 0, 25)
BountyFarmed.BackgroundTransparency = 1
BountyFarmed.TextColor3 = Color3.fromRGB(255, 255, 255)
BountyFarmed.Font = Enum.Font.Gotham
BountyFarmed.TextSize = 16
BountyFarmed.TextXAlignment = Enum.TextXAlignment.Left

TimeElapsed.Position = UDim2.new(0, 10, 0, 110)
TimeElapsed.Size = UDim2.new(1, -20, 0, 25)
TimeElapsed.BackgroundTransparency = 1
TimeElapsed.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeElapsed.Font = Enum.Font.Gotham
TimeElapsed.TextSize = 16
TimeElapsed.TextXAlignment = Enum.TextXAlignment.Left

NextPlayer.Text = "Next Player"
NextPlayer.Position = UDim2.new(0.5, -60, 1, -50)
NextPlayer.Size = UDim2.new(0, 120, 0, 35)
NextPlayer.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
NextPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
NextPlayer.Font = Enum.Font.GothamBold
NextPlayer.TextSize = 16
Instance.new("UICorner", NextPlayer).CornerRadius = UDim.new(0, 8)

-- Update UI continuously
task.spawn(function()
    while task.wait(1) do
        bounty += 500
        farmed += 500
        secondsUsed += 1
        Title.Text = "Auto Bounty GUI"
        CurrentBounty.Text = "Current Bounty: " .. bounty
        BountyFarmed.Text = "Bounty Farmed: " .. farmed
        TimeElapsed.Text = string.format("Time Used: %dm %ds", math.floor(secondsUsed / 60), secondsUsed % 60)
    end
end)

-- Placeholder: Check valid targets in server
function GetValidTarget()
    local myLevel = LocalPlayer.Data.Level.Value
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player:FindFirstChild("Data") then
            local pData = player.Data
            if pData.Level.Value <= myLevel + 5 and pData.Level.Value >= myLevel - 5 then
                if pData:FindFirstChild("PvP") and pData.PvP.Value == true then
                    return player
                end
            end
        end
    end
    return nil
end

-- Placeholder: Teleport to another server
function HopServer()
    local PlaceId = game.PlaceId
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in pairs(servers.data) do
        if server.playing < server.maxPlayers then
            TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
            break
        end
    end
end

-- When clicking "Next Player"
NextPlayer.MouseButton1Click:Connect(function()
    print("[Next Player] Searching...")
    local target = GetValidTarget()
    if target then
        print("Target found: " .. target.Name)
        -- Add teleport or kill logic here
    else
        print("No valid target found, hopping server...")
        HopServer()
    end
end)
