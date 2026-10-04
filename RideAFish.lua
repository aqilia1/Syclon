local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Penanganan lokasi GUI aman (CoreGui / PlayerGui)
local guiParent = CoreGui
local success, _ = pcall(function() return CoreGui.Name end)
if not success then
    guiParent = LocalPlayer:WaitForChild("PlayerGui")
end

if guiParent:FindFirstChild("WildEggESPSelectorGUI") then
    guiParent.WildEggESPSelectorGUI:Destroy()
end

-- Data Seleksi (Tetap tersimpan meski item di map hilang)
local selectedSpawnPointTargets = {}
local selectedWildEggsTargets = {}
local selectedESPTargets = {}

-- Cache Semua Nama Item yang Pernah Ditemukan (Agar teks UI tidak hilang)
local knownSpawnPointNames = {}
local knownWildEggsNames = {}

local isRunning = false
local espEnabled = true
local activeDropdown = nil
local isMinimized = false
local savedSpawnCFrame = nil

-- FUNGSI SCAN SPAWNPOINT (Daftar & Hitung Jumlah di Map)
local function getSpawnPointData()
    local mapCounts = {}
    local spawnPointFolder = Workspace:FindFirstChild("SpawnPoint")
    
    if spawnPointFolder then
        for _, subFolder in ipairs(spawnPointFolder:GetChildren()) do
            local targets = subFolder:GetChildren()
            if #targets == 0 then targets = {subFolder} end

            for _, item in ipairs(targets) do
                local name = item:GetAttribute("EggTier") or item.Name
                mapCounts[name] = (mapCounts[name] or 0) + 1
                
                if not table.find(knownSpawnPointNames, name) then
                    table.insert(knownSpawnPointNames, name)
                end
            end
        end
    end
    table.sort(knownSpawnPointNames)
    return knownSpawnPointNames, mapCounts
end

-- FUNGSI SCAN WILDEGGS (Daftar & Hitung Jumlah di Map)
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

-- ESP SYSTEM KHUSUS WILDEGGS
local function createESP(instance, name, color)
    if not instance or not instance.Parent then return end
    
    if not selectedESPTargets[name] then
        if instance:FindFirstChild("EggBillboard") then
            instance.EggBillboard:Destroy()
        end
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
    label.Text = name
    label.TextColor3 = color or Color3.fromRGB(0, 200, 255)
    label.TextStrokeTransparency = 0
    label.TextSize = 10
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
            createESP(item, name, Color3.fromRGB(0, 200, 255))
        end
    end
end

-- UI UTAMA
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WildEggESPSelectorGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 215)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 0, 25)
titleLabel.Text = " Teleport & WildEggs ESP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.TextSize = 11
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -25)
contentFrame.Position = UDim2.new(0, 0, 0, 25)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Buttons Control
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -25, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.Parent = mainFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -50, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 14
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.Parent = mainFrame

-- Dropdown Buttons
local dropdownSpawnPointBtn = Instance.new("TextButton")
dropdownSpawnPointBtn.Size = UDim2.new(0.9, 0, 0, 22)
dropdownSpawnPointBtn.Position = UDim2.new(0.05, 0, 0.04, 0)
dropdownSpawnPointBtn.Text = "TP SpawnPoint (0) ▼"
dropdownSpawnPointBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownSpawnPointBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
dropdownSpawnPointBtn.TextSize = 11
dropdownSpawnPointBtn.Font = Enum.Font.SourceSansBold
dropdownSpawnPointBtn.Parent = contentFrame

local dropdownWildEggsBtn = Instance.new("TextButton")
dropdownWildEggsBtn.Size = UDim2.new(0.9, 0, 0, 22)
dropdownWildEggsBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
dropdownWildEggsBtn.Text = "TP WildEggs (0) ▼"
dropdownWildEggsBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownWildEggsBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
dropdownWildEggsBtn.TextSize = 11
dropdownWildEggsBtn.Font = Enum.Font.SourceSansBold
dropdownWildEggsBtn.Parent = contentFrame

local dropdownESPBtn = Instance.new("TextButton")
dropdownESPBtn.Size = UDim2.new(0.9, 0, 0, 22)
dropdownESPBtn.Position = UDim2.new(0.05, 0, 0.40, 0)
dropdownESPBtn.Text = "ESP WildEggs (0) ▼"
dropdownESPBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownESPBtn.TextColor3 = Color3.fromRGB(200, 100, 255)
dropdownESPBtn.TextSize = 11
dropdownESPBtn.Font = Enum.Font.SourceSansBold
dropdownESPBtn.Parent = contentFrame

local espToggleBtn = Instance.new("TextButton")
espToggleBtn.Size = UDim2.new(0.9, 0, 0, 20)
espToggleBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
espToggleBtn.Text = "MASTER ESP: ON"
espToggleBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
espToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggleBtn.TextSize = 10
espToggleBtn.Font = Enum.Font.SourceSansBold
espToggleBtn.Parent = contentFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 26)
toggleBtn.Position = UDim2.new(0.05, 0, 0.74, 0)
toggleBtn.Text = "START TELEPORT"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.Parent = contentFrame

-- Scrolling Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.9, 0, 0, 120)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollFrame.BorderSizePixel = 1
scrollFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
scrollFrame.ScrollBarThickness = 6
scrollFrame.Visible = false
scrollFrame.ZIndex = 10
scrollFrame.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = scrollFrame

local function updateDropdownTitles()
    local _, spCounts = getSpawnPointData()
    local _, weCounts = getWildEggsData()

    local spSelected = 0
    for _, v in pairs(selectedSpawnPointTargets) do if v then spSelected = spSelected + 1 end end
    dropdownSpawnPointBtn.Text = "TP SpawnPoint (" .. spSelected .. ")" .. (activeDropdown == "SpawnPoint" and " ▲" or " ▼")

    local weSelected = 0
    for _, v in pairs(selectedWildEggsTargets) do if v then weSelected = weSelected + 1 end end
    dropdownWildEggsBtn.Text = "TP WildEggs (" .. weSelected .. ")" .. (activeDropdown == "WildEggs" and " ▲" or " ▼")

    local espSelected = 0
    for _, v in pairs(selectedESPTargets) do if v then espSelected = espSelected + 1 end end
    dropdownESPBtn.Text = "ESP WildEggs (" .. espSelected .. ")" .. (activeDropdown == "ESP" and " ▲" or " ▼")
end

local itemButtons = {}
local function renderDropdownContent(mode)
    for _, btn in ipairs(itemButtons) do btn:Destroy() end
    itemButtons = {}

    local currentList = {}
    local mapCounts = {}
    local targetTable = {}

    if mode == "SpawnPoint" then
        currentList, mapCounts = getSpawnPointData()
        targetTable = selectedSpawnPointTargets
    elseif mode == "WildEggs" then
        currentList, mapCounts = getWildEggsData()
        targetTable = selectedWildEggsTargets
    elseif mode == "ESP" then
        currentList, mapCounts = getWildEggsData()
        targetTable = selectedESPTargets
    end

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(#currentList * 24, 24))

    if #currentList == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 24)
        emptyLabel.Text = "(Belum ada item terdeteksi)"
        emptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
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
        itemBtn.Size = UDim2.new(1, -8, 0, 22)
        -- Tetap tampilkan tulisan nama telur + jumlah aktif di map (x0 jika habis)
        itemBtn.Text = (isSelected and "[✓] " or "[  ] ") .. itemName .. " (x" .. activeInMap .. ")"
        
        local activeColor = Color3.fromRGB(40, 40, 40)
        if isSelected then
            if mode == "SpawnPoint" then activeColor = Color3.fromRGB(180, 130, 0)
            elseif mode == "WildEggs" then activeColor = Color3.fromRGB(0, 130, 180)
            elseif mode == "ESP" then activeColor = Color3.fromRGB(140, 0, 180) end
        end

        itemBtn.BackgroundColor3 = activeColor
        itemBtn.TextColor3 = (activeInMap > 0) and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(130, 130, 130)
        itemBtn.TextSize = 11
        itemBtn.Font = Enum.Font.SourceSans
        itemBtn.TextXAlignment = Enum.TextXAlignment.Left
        itemBtn.ZIndex = 11
        itemBtn.Parent = scrollFrame

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
        mainFrame.Size = UDim2.new(0, 240, 0, 215)
    else
        activeDropdown = mode
        renderDropdownContent(mode)
        scrollFrame.Visible = true

        if mode == "SpawnPoint" then
            scrollFrame.Position = UDim2.new(0.05, 0, 0.18, 0)
        elseif mode == "WildEggs" then
            scrollFrame.Position = UDim2.new(0.05, 0, 0.36, 0)
        elseif mode == "ESP" then
            scrollFrame.Position = UDim2.new(0.05, 0, 0.54, 0)
        end

        mainFrame.Size = UDim2.new(0, 240, 0, 335)
    end
    updateDropdownTitles()
end

dropdownSpawnPointBtn.MouseButton1Click:Connect(function() toggleDropdown("SpawnPoint") end)
dropdownWildEggsBtn.MouseButton1Click:Connect(function() toggleDropdown("WildEggs") end)
dropdownESPBtn.MouseButton1Click:Connect(function() toggleDropdown("ESP") end)

espToggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggleBtn.Text = espEnabled and "MASTER ESP: ON" or "MASTER ESP: OFF"
    espToggleBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(120, 0, 180) or Color3.fromRGB(70, 70, 70)
    updateESP()
end)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 240, 0, 25)
        minimizeBtn.Text = "+"
    else
        contentFrame.Visible = true
        minimizeBtn.Text = "-"
        mainFrame.Size = activeDropdown and UDim2.new(0, 240, 0, 335) or UDim2.new(0, 240, 0, 215)
    end
end)

-- HELPER TELEPORT & INTERAKSI
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

local function returnToSpawn()
    local hrp = getHRP()
    if savedSpawnCFrame and hrp then
        hrp.CFrame = savedSpawnCFrame
    end
end

closeBtn.MouseButton1Click:Connect(function()
    isRunning = false
    returnToSpawn()
    screenGui:Destroy()
end)

local function interactAndHold(instance)
    local prompt = instance:FindFirstChildOfClass("ProximityPrompt") or instance:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        if prompt.MaxActivationDistance < 30 then prompt.MaxActivationDistance = 30 end
        local holdDuration = prompt.HoldDuration > 0 and prompt.HoldDuration or 0.1
        local startTime = tick()
        while instance and instance.Parent and (tick() - startTime < holdDuration + 0.6) do
            fireproximityprompt(prompt)
            task.wait(0.1)
        end
    else
        task.wait(0.3)
    end
end

-- LOOP REFRESH ESP DAN UI COUNT DENGAN BERKALA
task.spawn(function()
    while true do
        updateESP()
        if activeDropdown then
            renderDropdownContent(activeDropdown)
        end
        updateDropdownTitles()
        task.wait(1)
    end
end)

-- LOGIKA AUTO TELEPORT
local function startCollecting()
    activeDropdown = nil
    scrollFrame.Visible = false
    if not isMinimized then mainFrame.Size = UDim2.new(0, 240, 0, 215) end
    updateDropdownTitles()

    local hrp = getHRP()
    if hrp then savedSpawnCFrame = hrp.CFrame end

    while isRunning do
        local hrpCurrent = getHRP()
        if not hrpCurrent then break end

        -- 1. Scan & Teleport ke SpawnPoint Items
        local spawnPointFolder = Workspace:FindFirstChild("SpawnPoint")
        if spawnPointFolder and isRunning then
            for _, subFolder in ipairs(spawnPointFolder:GetChildren()) do
                if not isRunning then break end

                local targets = subFolder:GetChildren()
                if #targets == 0 then targets = {subFolder} end

                for _, targetObj in ipairs(targets) do
                    if not isRunning then break end
                    local itemName = targetObj:GetAttribute("EggTier") or targetObj.Name

                    if selectedSpawnPointTargets[itemName] then
                        if targetObj and targetObj.Parent then
                            local targetCFrame = targetObj:IsA("Model") and targetObj:GetPivot() or targetObj.CFrame
                            if targetCFrame then
                                hrpCurrent.CFrame = targetCFrame * CFrame.new(0, 0.5, 0)
                                task.wait(0.35)
                                interactAndHold(targetObj)
                                task.wait(0.15)
                                returnToSpawn()
                                task.wait(0.3)
                            end
                        end
                    end
                end
            end
        end

        -- 2. Scan & Teleport ke WildEggs Items
        local eggRuntime = Workspace:FindFirstChild("EggRuntime")
        local wildEggsFolder = eggRuntime and eggRuntime:FindFirstChild("WildEggs")
        if wildEggsFolder and isRunning then
            for _, eggObj in ipairs(wildEggsFolder:GetChildren()) do
                if not isRunning then break end

                local eggName = eggObj:GetAttribute("EggTier") or eggObj.Name
                if selectedWildEggsTargets[eggName] then
                    if eggObj and eggObj.Parent then
                        local targetCFrame = eggObj:IsA("Model") and eggObj:GetPivot() or eggObj.CFrame
                        if targetCFrame then
                            hrpCurrent.CFrame = targetCFrame * CFrame.new(0, 0.5, 0)
                            task.wait(0.35)
                            interactAndHold(eggObj)
                            task.wait(0.15)
                            returnToSpawn()
                            task.wait(0.3)
                        end
                    end
                end
            end
        end

        task.wait(0.5)
    end

    returnToSpawn()
    toggleBtn.Text = "START TELEPORT"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
end

toggleBtn.MouseButton1Click:Connect(function()
    if isRunning then
        isRunning = false
        returnToSpawn()
        toggleBtn.Text = "START TELEPORT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        isRunning = true
        toggleBtn.Text = "STOP"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        task.spawn(startCollecting)
    end
end)
