--[[ 
    Delta Auto Throw + Auto Place + Auto Tap Bonus
    Compatible: Delta Executor Mobile
    Fitur: Throw Loop, Auto Place, Auto Tap Bonus (mulai dari 0)
]]

-- ========== KONFIGURASI ==========
local LOOP_DELAY = 0.3           -- jeda loop throw (lebih lambat = aman)
local ENABLE_AUTO_PLACE = true

-- ========== AUTO PLACE CONFIG ==========
local PLACE_ANIMAL = "a5"
local PLACE_POSITION = Vector3.new(-45.51749038696289, 2.5000109672546387, 20.316205978393555)

-- ========== AUTO TAP BONUS CONFIG ==========
local TAP_START_VALUE = 0        -- ⬅️ MULAI DARI 0
local TAP_INCREMENT = 1
local TAP_DELAY = 1.5            -- ⬅️ LAMBAT: 1.5 detik antar tap

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ========== VARIABEL ==========
local isRunning = false
local isMinimized = false
local loopConnection = nil
local tapConnection = nil

local autoTapEnabled = false
local currentTapValue = TAP_START_VALUE

-- ========== GUI SETUP ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaAutoThrow"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, _ = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ========== MAIN FRAME ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 400)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- ========== TITLE BAR ==========
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 20)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ Delta Auto v1.3"
TitleLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- ========== MINIMIZE BUTTON ==========
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -66, 0, 6)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- ========== EXIT BUTTON ==========
local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0, 28, 0, 28)
ExitBtn.Position = UDim2.new(1, -32, 0, 6)
ExitBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ExitBtn.Text = "✕"
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.TextSize = 16
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.BorderSizePixel = 0
ExitBtn.Parent = TitleBar

local ExitCorner = Instance.new("UICorner")
ExitCorner.CornerRadius = UDim.new(0, 6)
ExitCorner.Parent = ExitBtn

-- ========== STATUS LABEL ==========
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -30, 0, 22)
StatusLabel.Position = UDim2.new(0, 15, 0, 48)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- ========== TOGGLE THROW BUTTON ==========
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -30, 0, 42)
ToggleBtn.Position = UDim2.new(0, 15, 0, 75)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
ToggleBtn.Text = "▶  START THROW"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
ToggleBtn.TextSize = 15
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 255, 150)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

-- ========== AUTO PLACE TOGGLE ==========
local PlaceToggleBtn = Instance.new("TextButton")
PlaceToggleBtn.Size = UDim2.new(1, -30, 0, 42)
PlaceToggleBtn.Position = UDim2.new(0, 15, 0, 125)
PlaceToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
PlaceToggleBtn.Text = "🏠  AUTO PLACE: ON"
PlaceToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
PlaceToggleBtn.TextSize = 14
PlaceToggleBtn.Font = Enum.Font.GothamBold
PlaceToggleBtn.BorderSizePixel = 0
PlaceToggleBtn.Parent = MainFrame

local PlaceToggleCorner = Instance.new("UICorner")
PlaceToggleCorner.CornerRadius = UDim.new(0, 8)
PlaceToggleCorner.Parent = PlaceToggleBtn

local PlaceToggleStroke = Instance.new("UIStroke")
PlaceToggleStroke.Color = Color3.fromRGB(0, 255, 150)
PlaceToggleStroke.Thickness = 2
PlaceToggleStroke.Parent = PlaceToggleBtn

local autoPlaceEnabled = ENABLE_AUTO_PLACE

-- ========== AUTO TAP TOGGLE ==========
local TapToggleBtn = Instance.new("TextButton")
TapToggleBtn.Size = UDim2.new(1, -30, 0, 42)
TapToggleBtn.Position = UDim2.new(0, 15, 0, 175)
TapToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
TapToggleBtn.Text = "👆  AUTO TAP: OFF"
TapToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
TapToggleBtn.TextSize = 14
TapToggleBtn.Font = Enum.Font.GothamBold
TapToggleBtn.BorderSizePixel = 0
TapToggleBtn.Parent = MainFrame

local TapToggleCorner = Instance.new("UICorner")
TapToggleCorner.CornerRadius = UDim.new(0, 8)
TapToggleCorner.Parent = TapToggleBtn

local TapToggleStroke = Instance.new("UIStroke")
TapToggleStroke.Color = Color3.fromRGB(255, 80, 80)
TapToggleStroke.Thickness = 2
TapToggleStroke.Parent = TapToggleBtn

-- ========== TAP VALUE DISPLAY ==========
local TapValueFrame = Instance.new("Frame")
TapValueFrame.Size = UDim2.new(1, -30, 0, 38)
TapValueFrame.Position = UDim2.new(0, 15, 0, 225)
TapValueFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
TapValueFrame.BorderSizePixel = 0
TapValueFrame.Parent = MainFrame

local TapValueCorner = Instance.new("UICorner")
TapValueCorner.CornerRadius = UDim.new(0, 6)
TapValueCorner.Parent = TapValueFrame

local TapValueLabel = Instance.new("TextLabel")
TapValueLabel.Size = UDim2.new(1, -10, 1, 0)
TapValueLabel.Position = UDim2.new(0, 5, 0, 0)
TapValueLabel.BackgroundTransparency = 1
TapValueLabel.Text = "Tap Value: " .. currentTapValue
TapValueLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
TapValueLabel.TextSize = 14
TapValueLabel.Font = Enum.Font.GothamBold
TapValueLabel.Parent = TapValueFrame

-- ========== RESET BUTTON ==========
local SetValueBtn = Instance.new("TextButton")
SetValueBtn.Size = UDim2.new(0.48, 0, 0, 32)
SetValueBtn.Position = UDim2.new(0, 15, 0, 270)
SetValueBtn.BackgroundColor3 = Color3.fromRGB(45, 65, 90)
SetValueBtn.Text = "↺ RESET"
SetValueBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
SetValueBtn.TextSize = 12
SetValueBtn.Font = Enum.Font.GothamBold
SetValueBtn.BorderSizePixel = 0
SetValueBtn.Parent = MainFrame

local SetValueCorner = Instance.new("UICorner")
SetValueCorner.CornerRadius = UDim.new(0, 6)
SetValueCorner.Parent = SetValueBtn

-- ========== TAP ONCE BUTTON ==========
local TapOnceBtn = Instance.new("TextButton")
TapOnceBtn.Size = UDim2.new(0.48, 0, 0, 32)
TapOnceBtn.Position = UDim2.new(0.52, 0, 0, 270)
TapOnceBtn.BackgroundColor3 = Color3.fromRGB(45, 65, 90)
TapOnceBtn.Text = "👆 TAP 1x"
TapOnceBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
TapOnceBtn.TextSize = 12
TapOnceBtn.Font = Enum.Font.GothamBold
TapOnceBtn.BorderSizePixel = 0
TapOnceBtn.Parent = MainFrame

local TapOnceCorner = Instance.new("UICorner")
TapOnceCorner.CornerRadius = UDim.new(0, 6)
TapOnceCorner.Parent = TapOnceBtn

-- ========== INFO ==========
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -30, 0, 55)
InfoLabel.Position = UDim2.new(0, 15, 0, 310)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Throw → Place → Tap Bonus\nTap mulai dari 0 (+1 per tap)\nDrag judul untuk pindah"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
InfoLabel.TextSize = 11
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextWrapped = true
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = MainFrame

-- ========== CREDIT ==========
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, 0, 0, 20)
Credit.Position = UDim2.new(0, 0, 1, -25)
Credit.BackgroundTransparency = 1
Credit.Text = "Delta Auto Script v1.3"
Credit.TextColor3 = Color3.fromRGB(100, 100, 120)
Credit.TextSize = 11
Credit.Font = Enum.Font.Gotham
Credit.Parent = MainFrame

-- ========== MINIMIZED ICON ==========
local MiniIcon = Instance.new("TextButton")
MiniIcon.Size = UDim2.new(0, 50, 0, 50)
MiniIcon.Position = UDim2.new(0, 10, 0.5, -25)
MiniIcon.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MiniIcon.Text = "⚡"
MiniIcon.TextColor3 = Color3.fromRGB(0, 200, 255)
MiniIcon.TextSize = 24
MiniIcon.Font = Enum.Font.GothamBold
MiniIcon.BorderSizePixel = 0
MiniIcon.Visible = false
MiniIcon.Active = true
MiniIcon.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 25)
MiniCorner.Parent = MiniIcon

local MiniStroke = Instance.new("UIStroke")
MiniStroke.Color = Color3.fromRGB(0, 200, 255)
MiniStroke.Thickness = 2
MiniStroke.Parent = MiniIcon

-- ========== THROW FUNCTIONS ==========
local function ThrowStart()
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Throw_Start"):InvokeServer()
    end)
end

local function ThrowResolve()
    pcall(function()
        local args = { 0.9804443223474052 }
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Throw_Resolve"):InvokeServer(unpack(args))
    end)
end

local function ThrowComplete()
    pcall(function()
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Throw_Complete"):InvokeServer()
    end)
end

-- ========== AUTO PLACE ==========
local function PlaceAnimal()
    local ok = pcall(function()
        local args = { PLACE_ANIMAL, PLACE_POSITION }
        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Plot_PlaceAnimal"):InvokeServer(unpack(args))
    end)
    return ok
end

-- ========== AUTO TAP BONUS (MULAI 0) ==========
local function TapBonus()
    local sendValue = currentTapValue
    local ok, result = pcall(function()
        local args = { sendValue }
        return ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Training_TapBonus"):InvokeServer(unpack(args))
    end)
    
    if ok then
        currentTapValue = currentTapValue + TAP_INCREMENT
        TapValueLabel.Text = "Tap Value: " .. currentTapValue
        print("[Delta Auto] Tap OK: " .. sendValue .. " → next: " .. currentTapValue)
        return true
    else
        warn("[Delta Auto] Tap error: " .. tostring(result))
        return false
    end
end

-- ========== LOOP LOGIC ==========
local function StartLoop()
    if isRunning then return end
    isRunning = true
    
    StatusLabel.Text = "Status: ON 🟢"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    ToggleBtn.Text = "⏸  STOP THROW"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    ToggleStroke.Color = Color3.fromRGB(255, 80, 80)
    
    loopConnection = task.spawn(function()
        while isRunning do
            ThrowStart()
            task.wait(0.1)
            ThrowResolve()
            task.wait(0.1)
            ThrowComplete()
            
            if autoPlaceEnabled then
                task.wait(0.1)
                PlaceAnimal()
            end
            
            task.wait(LOOP_DELAY)
        end
    end)
    
    print("[Delta Auto] Loop STARTED")
end

local function StopLoop()
    isRunning = false
    
    StatusLabel.Text = "Status: OFF 🔴"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    ToggleBtn.Text = "▶  START THROW"
    ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    ToggleStroke.Color = Color3.fromRGB(0, 255, 150)
    
    if loopConnection then
        pcall(function() task.cancel(loopConnection) end)
        loopConnection = nil
    end
    
    print("[Delta Auto] Loop STOPPED")
end

-- ========== AUTO TAP LOOP (LAMBAT) ==========
local function StartAutoTap()
    if autoTapEnabled then return end
    autoTapEnabled = true
    
    TapToggleBtn.Text = "👆  AUTO TAP: ON"
    TapToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
    TapToggleStroke.Color = Color3.fromRGB(0, 255, 150)
    
    tapConnection = task.spawn(function()
        while autoTapEnabled do
            TapBonus()
            task.wait(TAP_DELAY)
        end
    end)
    
    print("[Delta Auto] Auto Tap STARTED")
end

local function StopAutoTap()
    autoTapEnabled = false
    
    TapToggleBtn.Text = "👆  AUTO TAP: OFF"
    TapToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    TapToggleStroke.Color = Color3.fromRGB(255, 80, 80)
    
    if tapConnection then
        pcall(function() task.cancel(tapConnection) end)
        tapConnection = nil
    end
    
    print("[Delta Auto] Auto Tap STOPPED")
end

-- ========== BUTTON EVENTS ==========
ToggleBtn.MouseButton1Click:Connect(function()
    if isRunning then StopLoop() else StartLoop() end
end)

PlaceToggleBtn.MouseButton1Click:Connect(function()
    autoPlaceEnabled = not autoPlaceEnabled
    if autoPlaceEnabled then
        PlaceToggleBtn.Text = "🏠  AUTO PLACE: ON"
        PlaceToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        PlaceToggleStroke.Color = Color3.fromRGB(0, 255, 150)
    else
        PlaceToggleBtn.Text = "🏠  AUTO PLACE: OFF"
        PlaceToggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        PlaceToggleStroke.Color = Color3.fromRGB(255, 80, 80)
    end
end)

TapToggleBtn.MouseButton1Click:Connect(function()
    if autoTapEnabled then StopAutoTap() else StartAutoTap() end
end)

SetValueBtn.MouseButton1Click:Connect(function()
    currentTapValue = TAP_START_VALUE
    TapValueLabel.Text = "Tap Value: " .. currentTapValue
    print("[Delta Auto] Tap reset ke " .. TAP_START_VALUE)
end)

TapOnceBtn.MouseButton1Click:Connect(function()
    local before = TapOnceBtn.Text
    TapOnceBtn.Text = "⏳..."
    task.spawn(function()
        TapBonus()
        task.wait(0.3)
        TapOnceBtn.Text = "✅ " .. (currentTapValue - TAP_INCREMENT)
        task.wait(0.8)
        TapOnceBtn.Text = before
    end)
end)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    MainFrame.Visible = false
    MiniIcon.Visible = true
end)

MiniIcon.MouseButton1Click:Connect(function()
    isMinimized = false
    MiniIcon.Visible = false
    MainFrame.Visible = true
end)

ExitBtn.MouseButton1Click:Connect(function()
    StopLoop()
    StopAutoTap()
    ScreenGui:Destroy()
    print("[Delta Auto] Script Exited")
end)

-- ========== MOBILE DRAG SUPPORT ==========
do
    local dragging = false
    local dragStart, startPos

    local function setupDrag(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
    end

    setupDrag(TitleBar)
    setupDrag(MiniIcon)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local target = isMinimized and MiniIcon or MainFrame
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

print("[Delta Auto] ✅ Script v1.3 Loaded! Tap mulai dari: " .. currentTapValue)