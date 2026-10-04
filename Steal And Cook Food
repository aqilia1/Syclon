-- Delta Roblox Teleport & Save Location GUI (Compact Version with Walk Mode for Saved Point)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local savedCFrame = nil
local selectedTarget = nil
local currentTween = nil
local movementMode = "Teleport"

-- ScreenGui Main
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaTP_Compact"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame (Ukuran ringkas: 220x290)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 290)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 8)
MainUICorner.Parent = MainFrame

-- Title Bar
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 0, 30)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "Teleport Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = MainFrame

-- Minimize & Exit
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Position = UDim2.new(1, -50, 0, 4)
MinimizeBtn.Text = "-"
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinimizeBtn.Parent = MainFrame

local MinUICorner = Instance.new("UICorner")
MinUICorner.CornerRadius = UDim.new(0, 4)
MinUICorner.Parent = MinimizeBtn

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0, 22, 0, 22)
ExitBtn.Position = UDim2.new(1, -26, 0, 4)
ExitBtn.Text = "X"
ExitBtn.TextSize = 12
ExitBtn.Font = Enum.Font.SourceSansBold
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExitBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ExitBtn.Parent = MainFrame

local ExitUICorner = Instance.new("UICorner")
ExitUICorner.CornerRadius = UDim.new(0, 4)
ExitUICorner.Parent = ExitBtn

-- Open/Restore Button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -20)
OpenBtn.Text = "TP"
OpenBtn.TextSize = 13
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui

local OpenUICorner = Instance.new("UICorner")
OpenUICorner.CornerRadius = UDim.new(0, 20)
OpenUICorner.Parent = OpenBtn

-- Dropdown Header Simple
local DropdownHeader = Instance.new("TextButton")
DropdownHeader.Size = UDim2.new(0.9, 0, 0, 28)
DropdownHeader.Position = UDim2.new(0.05, 0, 0, 35)
DropdownHeader.Text = "-- Pilih Tujuan -- ▼"
DropdownHeader.TextColor3 = Color3.fromRGB(200, 200, 200)
DropdownHeader.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
DropdownHeader.Font = Enum.Font.SourceSans
DropdownHeader.TextSize = 12
DropdownHeader.Parent = MainFrame

local DropHeaderCorner = Instance.new("UICorner")
DropHeaderCorner.CornerRadius = UDim.new(0, 5)
DropHeaderCorner.Parent = DropdownHeader

-- Dropdown Container
local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(0.9, 0, 0, 100)
DropdownList.Position = UDim2.new(0.05, 0, 0, 65)
DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
DropdownList.Visible = false
DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownList.ScrollBarThickness = 4
DropdownList.ZIndex = 10
DropdownList.Parent = MainFrame

local DropListCorner = Instance.new("UICorner")
DropListCorner.CornerRadius = UDim.new(0, 5)
DropListCorner.Parent = DropdownList

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = DropdownList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Mode Selection (Teleport / Jalan)
local ModeTPBtn = Instance.new("TextButton")
ModeTPBtn.Size = UDim2.new(0.43, 0, 0, 24)
ModeTPBtn.Position = UDim2.new(0.05, 0, 0, 70)
ModeTPBtn.Text = "TP"
ModeTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeTPBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 200)
ModeTPBtn.Font = Enum.Font.SourceSansBold
ModeTPBtn.TextSize = 12
ModeTPBtn.Parent = MainFrame

local ModeTPCorner = Instance.new("UICorner")
ModeTPCorner.CornerRadius = UDim.new(0, 4)
ModeTPCorner.Parent = ModeTPBtn

local ModeWalkBtn = Instance.new("TextButton")
ModeWalkBtn.Size = UDim2.new(0.43, 0, 0, 24)
ModeWalkBtn.Position = UDim2.new(0.52, 0, 0, 70)
ModeWalkBtn.Text = "Jalan"
ModeWalkBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
ModeWalkBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ModeWalkBtn.Font = Enum.Font.SourceSansBold
ModeWalkBtn.TextSize = 12
ModeWalkBtn.Parent = MainFrame

local ModeWalkCorner = Instance.new("UICorner")
ModeWalkCorner.CornerRadius = UDim.new(0, 4)
ModeWalkCorner.Parent = ModeWalkBtn

-- Start & Stop Buttons
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.43, 0, 0, 30)
StartBtn.Position = UDim2.new(0.05, 0, 0, 102)
StartBtn.Text = "Mulai"
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 80)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 13
StartBtn.Parent = MainFrame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 5)
StartCorner.Parent = StartBtn

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.43, 0, 0, 30)
StopBtn.Position = UDim2.new(0.52, 0, 0, 102)
StopBtn.Text = "Stop"
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 13
StopBtn.Parent = MainFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 5)
StopCorner.Parent = StopBtn

-- Save & Go Saved Buttons
local SavePosBtn = Instance.new("TextButton")
SavePosBtn.Size = UDim2.new(0.9, 0, 0, 28)
SavePosBtn.Position = UDim2.new(0.05, 0, 0, 140)
SavePosBtn.Text = "💾 Save Posisi Saat Ini"
SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 160)
SavePosBtn.Font = Enum.Font.SourceSansBold
SavePosBtn.TextSize = 12
SavePosBtn.Parent = MainFrame

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 5)
SaveCorner.Parent = SavePosBtn

local TpSavedBtn = Instance.new("TextButton")
TpSavedBtn.Size = UDim2.new(0.9, 0, 0, 28)
TpSavedBtn.Position = UDim2.new(0.05, 0, 0, 175)
TpSavedBtn.Text = "📍 Ke Saved Point"
TpSavedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TpSavedBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 140)
TpSavedBtn.Font = Enum.Font.SourceSansBold
TpSavedBtn.TextSize = 12
TpSavedBtn.Parent = MainFrame

local TpSavedCorner = Instance.new("UICorner")
TpSavedCorner.CornerRadius = UDim.new(0, 5)
TpSavedCorner.Parent = TpSavedBtn

----------------------------------------------------
-- LOGIK EXECUTION & FOLDER SCAN
----------------------------------------------------

ModeTPBtn.MouseButton1Click:Connect(function()
    movementMode = "Teleport"
    ModeTPBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 200)
    ModeTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModeWalkBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ModeWalkBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

ModeWalkBtn.MouseButton1Click:Connect(function()
    movementMode = "Jalan"
    ModeWalkBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 200)
    ModeWalkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModeTPBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    ModeTPBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
end)

local function PopulateDropdown()
    for _, child in pairs(DropdownList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local itemHeight = 24
    local totalItems = 0
    local spawnsFolder = game.Workspace:FindFirstChild("Spawns")

    if spawnsFolder then
        for i = 1, 10 do
            local subFolder = spawnsFolder:FindFirstChild(tostring(i))
            if subFolder then
                for _, targetObj in pairs(subFolder:GetChildren()) do
                    totalItems = totalItems + 1
                    
                    local ItemBtn = Instance.new("TextButton")
                    ItemBtn.Size = UDim2.new(1, 0, 0, itemHeight)
                    ItemBtn.Text = "[" .. i .. "] " .. targetObj.Name
                    ItemBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
                    ItemBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    ItemBtn.Font = Enum.Font.SourceSans
                    ItemBtn.TextSize = 12
                    ItemBtn.ZIndex = 11
                    ItemBtn.Parent = DropdownList

                    ItemBtn.MouseButton1Click:Connect(function()
                        selectedTarget = targetObj
                        DropdownHeader.Text = "[" .. i .. "] " .. targetObj.Name
                        DropdownList.Visible = false
                    end)
                end
            end
        end
    end
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, totalItems * itemHeight)
end

PopulateDropdown()

DropdownHeader.MouseButton1Click:Connect(function()
    DropdownList.Visible = not DropdownList.Visible
end)

-- Fungsi universal untuk menangani pergerakan (TP / Jalan)
local function MoveToCFrame(targetCFrame)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if root then
        if currentTween then
            currentTween:Cancel()
            currentTween = nil
        end

        if movementMode == "Teleport" then
            root.CFrame = targetCFrame
        elseif movementMode == "Jalan" then
            local distance = (root.Position - targetCFrame.Position).Magnitude
            local speed = 50
            local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
            
            currentTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
            currentTween:Play()
        end
    end
end

-- Mulai eksekusi ke lokasi dari Dropdown
StartBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then return end
    local targetCFrame = selectedTarget:IsA("BasePart") and selectedTarget.CFrame or selectedTarget:GetPivot()
    MoveToCFrame(targetCFrame)
end)

-- Simpan Posisi Saat Ini
SavePosBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        savedCFrame = root.CFrame
        SavePosBtn.Text = "✅ Posisi Tersimpan"
        task.wait(1.2)
        SavePosBtn.Text = "💾 Save Posisi Saat Ini"
    end
end)

-- Ke Saved Point (Menggunakan Mode TP / Jalan yang sedang aktif)
TpSavedBtn.MouseButton1Click:Connect(function()
    if savedCFrame then
        MoveToCFrame(savedCFrame)
    else
        TpSavedBtn.Text = "❌ Belum Ada Posisi!"
        task.wait(1.2)
        TpSavedBtn.Text = "📍 Ke Saved Point"
    end
end)

-- Stop Pergerakan Jalan
StopBtn.MouseButton1Click:Connect(function()
    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

ExitBtn.MouseButton1Click:Connect(function()
    if currentTween then currentTween:Cancel() end
    ScreenGui:Destroy()
end)
