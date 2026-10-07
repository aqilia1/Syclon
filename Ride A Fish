local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- System Safe Parent (Cek CoreGui, jika gagal pakai PlayerGui)
local guiParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if CoreGui and pcall(function() return CoreGui.Name end) then
        guiParent = CoreGui
    end
end)

-- Hapus GUI lama jika ada
if guiParent:FindFirstChild("SyclonWildEggGUI") then
    guiParent.SyclonWildEggGUI:Destroy()
end

-- Data & State
local selectedWildEggsTargets = {}
local selectedESPTargets = {}
local knownWildEggsNames = {}

local isRunning = false
local espEnabled = true
local activeDropdown = nil
local isMinimized = false

-- Helper Functions
local function getRootPart()
    local character = LocalPlayer.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function triggerProximityPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        pcall(function()
            local oldHold = prompt.HoldDuration
            local oldDist = prompt.MaxActivationDistance
            prompt.HoldDuration = 0
            prompt.MaxActivationDistance = math.huge
            
            if fireproximityprompt then
                fireproximityprompt(prompt)
            end
            
            task.delay(0.1, function()
                if prompt and prompt.Parent then
                    prompt.HoldDuration = oldHold
                    prompt.MaxActivationDistance = oldDist
                end
            end)
        end)
    end
end

local function storeEggRemote()
    pcall(function()
        local eggGame = ReplicatedStorage:FindFirstChild("EggGame")
        if eggGame and eggGame:FindFirstChild("Requests") then
            eggGame.Requests:FireServer("StoreEgg")
        end
    end)
end

local function getWildEggsData()
    local mapCounts = {}
    local eggRuntime = Workspace:FindFirstChild("EggRuntime")
    local wildEggsFolder = eggRuntime and eggRuntime:FindFirstChild("WildEggs")
    
    if wildEggsFolder then
        for _, child in ipairs(wildEggsFolder:GetChildren()) do
            local name = child:GetAttribute("EggTier") or child.Name
            mapCounts[name] = (mapCounts[name] or 0) + 1
            if not table.find(knownWildEggsNames, name) then
                table.insert(knownWildEggsNames, name)
            end
        end
    end
    table.sort(knownWildEggsNames)
    return knownWildEggsNames, mapCounts
end

-- ESP System
local function createESP(instance, name, color)
    if not instance or not instance.Parent then return end
    if not selectedESPTargets[name] then
        if instance:FindFirstChild("EggBillboard") then instance.EggBillboard:Destroy() end
        return
    end
    if instance:FindFirstChild("EggBillboard") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EggBillboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 120, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Adornee = instance

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "• " .. name .. " •"
    label.TextColor3 = color or Color3.fromRGB(0, 230, 255)
    label.TextStrokeTransparency = 0.2
    label.TextSize = 11
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard

    billboard.Parent = instance
end

local function updateESP()
    if not espEnabled then
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc.Name == "EggBillboard" then desc:Destroy() end
        end
        return
    end

    local eggRuntime = Workspace:FindFirstChild("EggRuntime")
    local wildEggsFolder = eggRuntime and eggRuntime:FindFirstChild("WildEggs")
    if wildEggsFolder then
        for _, item in ipairs(wildEggsFolder:GetChildren()) do
            local name = item:GetAttribute("EggTier") or item.Name
            createESP(item, name, Color3.fromRGB(0, 230, 255))
        end
    end
end

-- ==================== UI BUILDER ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyclonWildEggGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = guiParent

-- Window Utama
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 210)
mainFrame.Position = UDim2.new(0.08, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

pcall(function()
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
end)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLogo = Instance.new("TextLabel")
titleLogo.Size = UDim2.new(0, 35, 1, 0)
titleLogo.Text = " S"
titleLogo.TextColor3 = Color3.fromRGB(0, 180, 255)
titleLogo.Font = Enum.Font.SourceSansBold
titleLogo.TextSize = 18
titleLogo.BackgroundTransparency = 1
titleLogo.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 30, 0, 0)
titleLabel.Text = "★SYCLON★"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -56, 0, 5)
minimizeBtn.Text = "─"
minimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(32, 36, 45)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 12
minimizeBtn.Parent = titleBar
pcall(function()
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -29, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 35)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 12
closeBtn.Parent = titleBar
pcall(function()
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
end)

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -45)
contentFrame.Position = UDim2.new(0, 10, 0, 38)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local function createStyledButton(text, pos, bgCol, textCol)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = bgCol
    btn.TextColor3 = textCol
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.AutoButtonColor = true
    
    pcall(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = btn
    end)
    
    return btn
end

local dropdownWildEggsBtn = createStyledButton("Select Eggs(0)  ▼", UDim2.new(0, 0, 0, 0), Color3.fromRGB(30, 35, 45), Color3.fromRGB(0, 200, 255))
dropdownWildEggsBtn.Parent = contentFrame

local dropdownESPBtn = createStyledButton("Select Esp Eggs (0)  ▼", UDim2.new(0, 0, 0, 38), Color3.fromRGB(30, 35, 45), Color3.fromRGB(210, 120, 255))
dropdownESPBtn.Parent = contentFrame

local espToggleBtn = createStyledButton("ESP: ON", UDim2.new(0, 0, 0, 76), Color3.fromRGB(110, 40, 160), Color3.fromRGB(255, 255, 255))
espToggleBtn.Parent = contentFrame

local toggleBtn = createStyledButton("START TELEPORT", UDim2.new(0, 0, 0, 120), Color3.fromRGB(0, 160, 110), Color3.fromRGB(255, 255, 255))
toggleBtn.Parent = contentFrame

-- Scroll Frame Dropdown
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 0, 110)
scrollFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 22)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.Visible = false
scrollFrame.ZIndex = 10
scrollFrame.Parent = contentFrame

pcall(function()
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 7)
    scrollCorner.Parent = scrollFrame
end)

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 3)
listLayout.Parent = scrollFrame

-- Icon Syclon (Minimized GUI)
local iconFrame = Instance.new("Frame")
iconFrame.Name = "SyclonIcon"
iconFrame.Size = UDim2.new(0, 45, 0, 45)
iconFrame.Position = mainFrame.Position
iconFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 29)
iconFrame.Visible = false
iconFrame.Active = true
iconFrame.Draggable = true
iconFrame.Parent = screenGui

pcall(function()
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconFrame
end)

local iconBtn = Instance.new("TextButton")
iconBtn.Size = UDim2.new(1, 0, 1, 0)
iconBtn.Text = "S"
iconBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
iconBtn.Font = Enum.Font.SourceSansBold
iconBtn.TextSize = 24
iconBtn.BackgroundTransparency = 1
iconBtn.Parent = iconFrame

-- Logic Handler UI
local function updateDropdownTitles()
    local _, weCounts = getWildEggsData()

    local weSelected = 0
    for _, v in pairs(selectedWildEggsTargets) do if v then weSelected = weSelected + 1 end end
    dropdownWildEggsBtn.Text = "Select Eggs (" .. weSelected .. ")" .. (activeDropdown == "WildEggs" and "  ▲" or "  ▼")

    local espSelected = 0
    for _, v in pairs(selectedESPTargets) do if v then espSelected = espSelected + 1 end end
    dropdownESPBtn.Text = "Select Esp Eggs
local itemButtons = {}
local function renderDropdownContent(mode)
    for _, btn in ipairs(itemButtons) do btn:Destroy() end
    itemButtons = {}

    local currentList, mapCounts = getWildEggsData()
    local targetTable = (mode == "WildEggs") and selectedWildEggsTargets or selectedESPTargets

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(#currentList * 26, 26))

    if #currentList == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 24)
        emptyLabel.Text = "Tidak ada item terdeteksi"
        emptyLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.TextSize = 10
        emptyLabel.Font = Enum.Font.SourceSansItalic
        emptyLabel.ZIndex = 11
        emptyLabel.Parent = scrollFrame
        table.insert(itemButtons, emptyLabel)
        return
    end

    for _, itemName in ipairs(currentList) do
        local isSelected = targetTable[itemName] or false
        local activeInMap = mapCounts[itemName] or 0

        local itemBtn = Instance.new("TextButton")
        itemBtn.Size = UDim2.new(1, -6, 0, 24)
        itemBtn.Text = (isSelected and "  [✓] " or "  [  ] ") .. itemName .. "  (x" .. activeInMap .. ")"
        
        itemBtn.BackgroundColor3 = isSelected and ((mode == "WildEggs") and Color3.fromRGB(0, 100, 140) or Color3.fromRGB(120, 40, 150)) or Color3.fromRGB(28, 32, 40)
        itemBtn.TextColor3 = (activeInMap > 0) and Color3.fromRGB(230, 230, 230) or Color3.fromRGB(130, 130, 130)
        itemBtn.TextSize = 11
        itemBtn.Font = Enum.Font.SourceSans
        itemBtn.TextXAlignment = Enum.TextXAlignment.Left
        itemBtn.ZIndex = 11
        itemBtn.Parent = scrollFrame

        pcall(function()
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = itemBtn
        end)

        itemBtn.MouseButton1Click:Connect(function()
            targetTable[itemName] = not targetTable[itemName]
            renderDropdownContent(mode)
            updateDropdownTitles()
            updateESP()
        end)
        table.insert(itemButtons, itemBtn)
    end
end

local function toggleDropdown(mode)
    if activeDropdown == mode then
        activeDropdown = nil
        scrollFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 250, 0, 210)
    else
        activeDropdown = mode
        renderDropdownContent(mode)
        scrollFrame.Visible = true

        if mode == "WildEggs" then
            scrollFrame.Position = UDim2.new(0, 0, 0, 36)
        elseif mode == "ESP" then
            scrollFrame.Position = UDim2.new(0, 0, 0, 74)
        end

        mainFrame.Size = UDim2.new(0, 250, 0, 320)
    end
    updateDropdownTitles()
end

dropdownWildEggsBtn.MouseButton1Click:Connect(function() toggleDropdown("WildEggs") end)
dropdownESPBtn.MouseButton1Click:Connect(function() toggleDropdown("ESP") end)

espToggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggleBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espToggleBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(110, 40, 160) or Color3.fromRGB(50, 55, 65)
    updateESP()
end)

-- Minimize & Restore System
local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        iconFrame.Position = mainFrame.Position
        mainFrame.Visible = false
        iconFrame.Visible = true
    else
        mainFrame.Position = iconFrame.Position
        iconFrame.Visible = false
        mainFrame.Visible = true
    end
end

minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
iconBtn.MouseButton1Click:Connect(toggleMinimize)

closeBtn.MouseButton1Click:Connect(function()
    isRunning = false
    screenGui:Destroy()
end)

-- Background Loop
task.spawn(function()
    while screenGui and screenGui.Parent do
        pcall(function()
            updateESP()
            if activeDropdown then
                renderDropdownContent(activeDropdown)
            end
            updateDropdownTitles()
        end)
        task.wait(1)
    end
end)

-- Teleport Logic
local function processTeleportTarget(targetObj)
    local rootPart = getRootPart()
    if not rootPart or not targetObj or not targetObj.Parent then return false end

    local targetPart = targetObj:IsA("Model") and (targetObj.PrimaryPart or targetObj:FindFirstChildWhichIsA("BasePart")) or targetObj
    if not targetPart then return false end

    local originalPosition = rootPart.CFrame
    
    rootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.4)

    local prompt = targetObj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        triggerProximityPrompt(prompt)
        task.wait(0.3)
    end

    rootPart.CFrame = originalPosition
    task.wait(1.0)
    storeEggRemote()
    task.wait(0.3)

    return true
end

local function startCollecting()
    activeDropdown = nil
    scrollFrame.Visible = false
    if not isMinimized then mainFrame.Size = UDim2.new(0, 250, 0, 210) end
    updateDropdownTitles()

    while isRunning do
        local foundAny = false
        local eggRuntime = Workspace:FindFirstChild("EggRuntime")
        local wildEggsFolder = eggRuntime and eggRuntime:FindFirstChild("WildEggs")
        
        if wildEggsFolder and isRunning then
            for _, eggObj in ipairs(wildEggsFolder:GetChildren()) do
                if not isRunning then break end
                local eggName = eggObj:GetAttribute("EggTier") or eggObj.Name
                if selectedWildEggsTargets[eggName] then
                    foundAny = processTeleportTarget(eggObj)
                end
            end
        end

        task.wait(foundAny and 0.5 or 1.5)
    end

    toggleBtn.Text = "START TELEPORT"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 110)
end

toggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        isRunning = false
        toggleBtn.Text = "START TELEPORT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 110)
    else
        isRunning = true
        toggleBtn.Text = "STOP TELEPORT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        task.spawn(startCollecting)
    end
end)
