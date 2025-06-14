-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- == Config
getgenv().AutoBountyConfig = {
    Team = "Pirates",
    SafeHealth = {40, 50},
    Skip = { Fruit = {Enabled=true, AvoidFruit={"Portal-Portal","Kitsune-Kitsune","Love-Love"}}, AvoidV4=true },
    HuntMethod = { UseMovePredict=true, HitAndRun=true },
    SpamSkillOnV4 = { Enabled=true, Weapons={"Melee","Gun","Sword","Blox Fruit"} },
    ChatNotify = { Enabled=false, Message={"Custom Auto Bounty Script"} },
    CustomRun = { Enabled=true, YRun=5000 },
    Misc = { AutoTeleportSea3=true, AutoTeleportSea2=false, AutoStoreFruit=true, AutoRandomFruit=false,
        AutoDash=true, AutoRejoin=true, BoostFPS=false, WhiteScreen=false, DisableNotify=false, ClickDelay=0.01 },
    Items = {
        Use={"Melee","Sword","Gun","Blox Fruit"},
        Melee={Enable=true, Skills={Z={Enable=true,HoldTime=1},X={Enable=true,HoldTime=0.5},C={Enable=true,HoldTime=0.5}}},
        Sword={Enable=true, Skills={Z={Enable=true,HoldTime=0.2},X={Enable=true,HoldTime=0.2}}},
        Gun={Enable=true, Skills={Z={Enable=true,HoldTime=0.2},X={Enable=true,HoldTime=0.2}}},
        BloxFruit={Enable=true, Skills={Z={Enable=true,HoldTime=0.2},X={Enable=true,HoldTime=0.2},C={Enable=true,HoldTime=0.2},V={Enable=false,HoldTime=0.1},F={Enable=true,HoldTime=0.1}}}
    }
}

-- == GUI Creation
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "AutoBountyGUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 50, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "Auto Bounty GUI"

local cb, bf, te, status = Instance.new("TextLabel", frame), Instance.new("TextLabel", frame), Instance.new("TextLabel", frame), Instance.new("TextLabel", frame)
for _, obj in ipairs({cb, bf, te, status}) do
    obj.Size = UDim2.new(1, -20, 0, 25)
    obj.BackgroundTransparency = 1
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Font = Enum.Font.Gotham
    obj.TextSize = 16
    obj.TextXAlignment = Enum.TextXAlignment.Left
end
cb.Position = UDim2.new(0, 10, 0, 50)
bf.Position = UDim2.new(0, 10, 0, 80)
te.Position = UDim2.new(0, 10, 0, 110)
status.Position = UDim2.new(0, 10, 0, 140)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 120, 0, 35)
btn.Position = UDim2.new(0.5, -60, 1, -50)
btn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 16
btn.Text = "Next Player"
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

-- == State
local bountyVal = 0
local farmedVal = 0
local seconds = 0
local running = false
local lastBounty = 0
local target = nil

-- == Utility
local function fmtTime(s)
    return string.format("%dm %ds", math.floor(s / 60), s % 60)
end

local function hopServer()
    status.Text = "Status: Hopping to new server..."
    local pid = game.PlaceId
    local success, srv = pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/" .. pid .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if not success then
        status.Text = "Status: Failed to fetch servers, retrying..."
        task.wait(5)
        return hopServer()
    end
    for _, sv in ipairs(srv.data) do
        if sv.playing < sv.maxPlayers then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(pid, sv.id, LocalPlayer)
            end)
            return
        end
    end
    status.Text = "Status: No available servers, retrying..."
    task.wait(5)
    hopServer()
end

local function isInSafeZone(player)
    -- Kiểm tra xem người chơi có đang ở khu vực an toàn (safe zone) hay không
    -- Đây là một giả định đơn giản, cần điều chỉnh theo game
    local safeZones = {
        Vector3.new(0, 0, 0), -- Thay bằng tọa độ của safe zone trong Blox Fruits
    }
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        for _, zone in ipairs(safeZones) do
            if (pos - zone).Magnitude < 100 then -- Giả định khoảng cách safe zone
                return true
            end
        end
    end
    return false
end

local function findTarget()
    local myLvl = LocalPlayer:WaitForChild("Data", 5) and LocalPlayer.Data:WaitForChild("Level", 5) and LocalPlayer.Data.Level.Value or 0
    if myLvl == 0 then return nil end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl:FindFirstChild("Data") then
            local d = pl.Data
            if d:FindFirstChild("Level") and d:FindFirstChild("PvP") and d.PvP.Value and not isInSafeZone(pl) then
                local lvl = d.Level.Value
                if lvl >= myLvl - 5 and lvl <= myLvl + 5 then
                    -- Kiểm tra Skip Fruit và V4
                    local fruit = d:FindFirstChild("DevilFruit") and d.DevilFruit.Value or ""
                    if AutoBountyConfig.Skip.Fruit.Enabled then
                        for _, avoidFruit in ipairs(AutoBountyConfig.Skip.Fruit.AvoidFruit) do
                            if fruit == avoidFruit then
                                return nil
                            end
                        end
                    end
                    if AutoBountyConfig.Skip.AvoidV4 and d:FindFirstChild("V4") and d.V4.Value then
                        return nil
                    end
                    return pl
                end
            end
        end
    end
    return nil
end

local function teleportToTarget(tgt)
    local char = LocalPlayer.Character
    local tgtChar = tgt and tgt.Character
    if char and tgtChar and char:FindFirstChild("HumanoidRootPart") and tgtChar:FindFirstChild("HumanoidRootPart") then
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(char.HumanoidRootPart, tweenInfo, {CFrame = tgtChar.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)})
        tween:Play()
        tween.Completed:Wait()
    end
end

local function useSkill(weaponType, skill)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
        -- Giả lập nhấn phím skill (Z, X, C, v.v.)
        local args = { [1] = skill }
        game:GetService("VirtualInputManager"):SendKeyEvent(true, skill, false, game)
        task.wait(AutoBountyConfig.Items[weaponType].Skills[skill].HoldTime)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, skill, false, game)
    end
end

local function attackTarget(tgt)
    if not tgt or not tgt.Character or not LocalPlayer.Character then return end
    local config = AutoBountyConfig.Items
    for _, weapon in ipairs(config.Use) do
        if config[weapon].Enable then
            for skill, skillData in pairs(config[weapon].Skills) do
                if skillData.Enable then
                    useSkill(weapon, skill)
                    task.wait(0.1)
                end
            end
        end
    end
end

local function runFarm()
    bountyVal = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Bounty") and LocalPlayer.leaderstats.Bounty.Value or 0
    lastBounty = bountyVal
    farmedVal = 0
    seconds = 0
    running = true
    title.Text = "Auto Bounty Running"
    status.Text = "Status: Searching for target..."

    local function updateGUI()
        seconds = seconds + 1
        bountyVal = LocalPlayer.leaderstats and LocalPlayer.leaderstats.Bounty and LocalPlayer.leaderstats.Bounty.Value or bountyVal
        farmedVal = bountyVal - lastBounty
        cb.Text = "Current Bounty: " .. bountyVal
        bf.Text = "Farmed: " .. farmedVal
        te.Text = "Time: " .. fmtTime(seconds)
    end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not running then
            connection:Disconnect()
            return
        end
        target = findTarget()
        if target then
            status.Text = "Status: Attacking " .. target.Name
            teleportToTarget(target)
            attackTarget(target)
        else
            status.Text = "Status: No suitable target, hopping server..."
            running = false
            hopServer()
        end
    end)

    -- Cập nhật GUI mỗi giây
    task.spawn(function()
        while running do
            updateGUI()
            task.wait(1)
        end
    end)
end

btn.MouseButton1Click:Connect(function()
    if running then
        running = false
        btn.Text = "Next Player"
        status.Text = "Status: Stopped"
    else
        task.spawn(runFarm)
        btn.Text = "Stop"
    end
end)

-- Auto run on load
task.spawn(runFarm)
