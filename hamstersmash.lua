-- +1 Hamster Splash | Launch every 5s, Rebirth every 1ms
-- powered by Syclon
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")

local function log(...) print("[HamsterSplash]", ...) end

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui", 10)

local Remotes      = ReplicatedStorage:FindFirstChild("Remotes")
local LaunchRemote = Remotes and Remotes:FindFirstChild("Launch")
local ActionRemote = Remotes and Remotes:FindFirstChild("Action")
if not LaunchRemote then log("WARN: Remotes.Launch tidak ketemu") end
if not ActionRemote then log("WARN: Remotes.Action tidak ketemu") end

local function findZone()
    local map = Workspace:FindFirstChild("Map")
    local w1  = map and map:FindFirstChild("World1")
    return w1 and w1:FindFirstChild("LaunchZone")
end
local launchZone = findZone()
if not launchZone then
    local t0 = tick()
    repeat task.wait(0.25); launchZone = findZone() until launchZone or (tick()-t0 > 15)
end
if launchZone then log("LaunchZone ok:", tostring(launchZone.Position))
else log("WARN: LaunchZone tidak ketemu di Map.World1") end

-- ===== launch state =====
local running, loopThread = false, nil
local teleportedThisArm = false
local LAUNCH_INTERVAL = 5.0    -- 5 detik per fire
local TELEPORT_RETRIES = 8

-- ===== rebirth state =====
local rbRunning, rbThread = false, nil
local REBIRTH_INTERVAL = 0.001 -- 1 milidetik; InvokeServer tetap yield server round-trip

local function teleportOnce()
    if not launchZone then log("teleport: no zone"); return false end
    local targetPos = launchZone.Position + Vector3.new(0, 3, 0)
    for i = 1, TELEPORT_RETRIES do
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            task.wait(0.2)
        else
            hrp.CFrame = CFrame.new(targetPos)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.15)
            local dist = (hrp.Position - targetPos).Magnitude
            if dist < 8 then
                log(string.format("teleport OK (dist=%.1f, attempt=%d)", dist, i))
                return true
            end
        end
    end
    log("teleport FAILED")
    return false
end

local function fireLaunch()
    if not LaunchRemote then return end
    pcall(function() LaunchRemote:FireServer() end)
end

local function doRebirth()
    if not ActionRemote then return end
    pcall(function()
        ActionRemote:InvokeServer("Rebirth")
    end)
end

local function startLoop()
    if running then return end
    running = true
    if not teleportedThisArm then
        teleportedThisArm = true
        task.spawn(function() teleportOnce() end)
    end
    loopThread = task.spawn(function()
        task.wait(0.4)
        while running do
            fireLaunch()
            task.wait(LAUNCH_INTERVAL)
        end
    end)
end

local function stopLoop()
    running = false
    teleportedThisArm = false
    if loopThread then task.cancel(loopThread); loopThread = nil end
end

local function startRebirth()
    if rbRunning then return end
    rbRunning = true
    rbThread = task.spawn(function()
        while rbRunning do
            doRebirth()
            task.wait(REBIRTH_INTERVAL)
        end
    end)
end

local function stopRebirth()
    rbRunning = false
    if rbThread then task.cancel(rbThread); rbThread = nil end
end

-- ===== GUI =====
local existing = PlayerGui:FindFirstChild("HamsterSplashGui")
if existing then existing:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "HamsterSplashGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(250, 230)
frame.Position = UDim2.new(0.5, -125, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 200, 140)
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -70, 0, 28)
title.Position = UDim2.fromOffset(10, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(220, 240, 230)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "+1 Hamster Splash"
title.Parent = frame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(28, 22)
minBtn.Position = UDim2.new(1, -66, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 60)
minBtn.TextColor3 = Color3.fromRGB(220,220,220)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Text = "_"
minBtn.Parent = frame
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local exitBtn = Instance.new("TextButton")
exitBtn.Size = UDim2.fromOffset(28, 22)
exitBtn.Position = UDim2.new(1, -34, 0, 3)
exitBtn.BackgroundColor3 = Color3.fromRGB(120, 45, 45)
exitBtn.TextColor3 = Color3.fromRGB(255,230,230)
exitBtn.Font = Enum.Font.GothamBold
exitBtn.TextSize = 14
exitBtn.Text = "X"
exitBtn.Parent = frame
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, -20, 0, 18)
status.Position = UDim2.fromOffset(10, 32)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextColor3 = Color3.fromRGB(150,160,170)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Text = "Launch: OFF"
status.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 40)
toggle.Position = UDim2.fromOffset(10, 52)
toggle.BackgroundColor3 = Color3.fromRGB(55,60,72)
toggle.TextColor3 = Color3.fromRGB(240,240,240)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 15
toggle.Text = "LAUNCH OFF"
toggle.AutoButtonColor = false
toggle.Parent = frame
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

local rbStatus = Instance.new("TextLabel")
rbStatus.BackgroundTransparency = 1
rbStatus.Size = UDim2.new(1, -20, 0, 18)
rbStatus.Position = UDim2.fromOffset(10, 100)
rbStatus.Font = Enum.Font.Gotham
rbStatus.TextSize = 11
rbStatus.TextColor3 = Color3.fromRGB(150,160,170)
rbStatus.TextXAlignment = Enum.TextXAlignment.Left
rbStatus.Text = "Rebirth: OFF"
rbStatus.Parent = frame

local rbToggle = Instance.new("TextButton")
rbToggle.Size = UDim2.new(1, -20, 0, 40)
rbToggle.Position = UDim2.fromOffset(10, 120)
rbToggle.BackgroundColor3 = Color3.fromRGB(55,60,72)
rbToggle.TextColor3 = Color3.fromRGB(240,240,240)
rbToggle.Font = Enum.Font.GothamBold
rbToggle.TextSize = 15
rbToggle.Text = "REBIRTH OFF"
rbToggle.AutoButtonColor = false
rbToggle.Parent = frame
Instance.new("UICorner", rbToggle).CornerRadius = UDim.new(0, 8)

local info = Instance.new("TextLabel")
info.BackgroundTransparency = 1
info.Size = UDim2.new(1, -20, 0, 16)
info.Position = UDim2.fromOffset(10, 166)
info.Font = Enum.Font.Gotham
info.TextSize = 10
info.TextColor3 = Color3.fromRGB(120,130,140)
info.TextXAlignment = Enum.TextXAlignment.Left
info.Text = "Launch 5s · Rebirth 1ms"
info.Parent = frame

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Size = UDim2.new(1, -20, 0, 16)
footer.Position = UDim2.new(0, 10, 1, -22)
footer.Font = Enum.Font.Gotham
footer.TextSize = 10
footer.TextColor3 = Color3.fromRGB(90, 100, 110)
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Text = "powered by Syclon"
footer.Parent = frame

local sBadge = Instance.new("TextButton")
sBadge.Name = "SBadge"
sBadge.Size = UDim2.fromOffset(46, 46)
sBadge.Position = UDim2.new(0.5, -23, 0.3, 0)
sBadge.BackgroundColor3 = Color3.fromRGB(40,190,120)
sBadge.TextColor3 = Color3.fromRGB(255,255,255)
sBadge.Font = Enum.Font.GothamBlack
sBadge.TextSize = 22
sBadge.Text = "S"
sBadge.Visible = false
sBadge.Parent = gui
Instance.new("UICorner", sBadge).CornerRadius = UDim.new(1, 0)
local sStroke = Instance.new("UIStroke")
sStroke.Color = Color3.fromRGB(80,255,170)
sStroke.Thickness = 2
sStroke.Parent = sBadge

local function paintLaunch(on)
    if on then
        toggle.BackgroundColor3 = Color3.fromRGB(40,190,120)
        toggle.Text = "LAUNCH ON"
        stroke.Color = Color3.fromRGB(80,255,170)
        status.Text = "Launch: teleported, firing every 5s..."
        status.TextColor3 = Color3.fromRGB(120,220,160)
    else
        toggle.BackgroundColor3 = Color3.fromRGB(55,60,72)
        toggle.Text = "LAUNCH OFF"
        stroke.Color = Color3.fromRGB(60,200,140)
        status.Text = "Launch: OFF"
        status.TextColor3 = Color3.fromRGB(150,160,170)
    end
end

local function paintRebirth(on)
    if on then
        rbToggle.BackgroundColor3 = Color3.fromRGB(200,140,40)
        rbToggle.Text = "REBIRTH ON"
        rbStatus.Text = "Rebirth: firing as fast as server allows..."
        rbStatus.TextColor3 = Color3.fromRGB(230,200,120)
    else
        rbToggle.BackgroundColor3 = Color3.fromRGB(55,60,72)
        rbToggle.Text = "REBIRTH OFF"
        rbStatus.Text = "Rebirth: OFF"
        rbStatus.TextColor3 = Color3.fromRGB(150,160,170)
    end
end

toggle.MouseButton1Click:Connect(function()
    if running then stopLoop(); paintLaunch(false)
    else startLoop(); paintLaunch(true) end
end)

rbToggle.MouseButton1Click:Connect(function()
    if rbRunning then stopRebirth(); paintRebirth(false)
    else startRebirth(); paintRebirth(true) end
end)

local minimized = false
local function setMinimized(m)
    minimized = m
    frame.Visible = not m
    sBadge.Visible = m
    if m then sBadge.Position = frame.Position end
end

minBtn.MouseButton1Click:Connect(function() setMinimized(true) end)
sBadge.MouseButton1Click:Connect(function() setMinimized(false) end)

exitBtn.MouseButton1Click:Connect(function()
    stopLoop(); stopRebirth(); gui:Destroy()
end)

local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local sDragging, sStart, sStartPos
sBadge.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        sDragging = true; sStart = input.Position; sStartPos = sBadge.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then sDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - sStart
        sBadge.Position = UDim2.new(
            sStartPos.X.Scale, sStartPos.X.Offset + d.X,
            sStartPos.Y.Scale, sStartPos.Y.Offset + d.Y)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if running then stopLoop(); paintLaunch(false) end
end)