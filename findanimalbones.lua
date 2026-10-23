-- ==========================================
-- DELTA AUTO — CRANK + CLAIM + SHRED
-- ==========================================

print("[DeltaAuto] Starting...")

-- Bersihin GUI lama
local CoreGui = game:GetService("CoreGui")
for _, name in ipairs({"DeltaAutoLoop","AutoShredGui"}) do
    local old = CoreGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaAutoLoop"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = CoreGui

-- ===== FRAME UTAMA =====
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 340)
frame.Position = UDim2.new(0, 8, 0, 8)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 20)
title.Position = UDim2.new(0, 6, 0, 4)
title.BackgroundTransparency = 1
title.Text = "⚡ DELTA AUTO"
title.TextColor3 = Color3.fromRGB(0, 255, 136)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Minimize
local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 18, 0, 18)
btnMin.Position = UDim2.new(1, -42, 0, 3)
btnMin.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
btnMin.Text = "–"
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 14
btnMin.Parent = frame
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,3)

-- Exit
local btnExit = Instance.new("TextButton")
btnExit.Size = UDim2.new(0, 18, 0, 18)
btnExit.Position = UDim2.new(1, -22, 0, 3)
btnExit.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnExit.Text = "✕"
btnExit.TextColor3 = Color3.new(1,1,1)
btnExit.Font = Enum.Font.GothamBold
btnExit.TextSize = 12
btnExit.Parent = frame
Instance.new("UICorner", btnExit).CornerRadius = UDim.new(0,3)

-- ===== REMOTE =====
local RS = game:GetService("ReplicatedStorage")
local bridge = RS:FindFirstChild("ffrostflame_bridgenet2@1.0.0")
if not bridge then warn("[DeltaAuto] Bridge not found") return end
local remote = bridge:FindFirstChild("dataRemoteEvent")
if not remote then warn("[DeltaAuto] Remote not found") return end

-- Semua UUID Claim
local CLAIM_UUIDS = {
    "c1cf2479-fa22-47cd-bc5f-e538fe2bfbfe",
    "68a76d09-88f0-4240-88ee-7edc75726181",
    "256e42be-1b30-4a21-995c-6c5f4fee63b2",
    "df67a47a-0cef-42f4-8251-78577958cb89",
    "b59c75b0-6c0e-4ced-8805-374fc90162ef",
    "12939477-e393-4925-b4a7-eda2f033cfca",
    "41d83d20-3d50-4c4b-9e73-50d7ed5a4769",
}
local CRANK_UUID = "c1cf2479-fa22-47cd-bc5f-e538fe2bfbfe"

-- Fire helper
local function fire(funcName, uuid, suffix)
    suffix = suffix or "@\004"
    local args = {
        {
            { Function = funcName, Args = { uuid } },
            suffix
        }
    }
    remote:FireServer(unpack(args))
end

-- ===== HELPER UUID =====
local function isUUID(s)
    return type(s) == "string"
        and s:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

local function getItemUID(tool)
    local v = tool:GetAttribute("ItemUID")
    if isUUID(v) then return v end
    local c = tool:FindFirstChild("ItemUID")
    if c and c:IsA("ValueBase") and isUUID(tostring(c.Value)) then return tostring(c.Value) end
    local d = tool:FindFirstChild("ItemUID", true)
    if d and d:IsA("ValueBase") and isUUID(tostring(d.Value)) then return tostring(d.Value) end
    return nil
end

-- ===== SECTION: CRANK =====
local crankLabel = Instance.new("TextLabel")
crankLabel.Size = UDim2.new(1, -12, 0, 16)
crankLabel.Position = UDim2.new(0, 6, 0, 28)
crankLabel.BackgroundTransparency = 1
crankLabel.Text = "🔧 Auto Crank"
crankLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
crankLabel.Font = Enum.Font.GothamBold
crankLabel.TextSize = 11
crankLabel.TextXAlignment = Enum.TextXAlignment.Left
crankLabel.Parent = frame

local btnCrankOn = Instance.new("TextButton")
btnCrankOn.Size = UDim2.new(0.5, -9, 0, 26)
btnCrankOn.Position = UDim2.new(0, 6, 0, 46)
btnCrankOn.BackgroundColor3 = Color3.fromRGB(0, 170, 68)
btnCrankOn.Text = "▶ ON"
btnCrankOn.TextColor3 = Color3.new(1,1,1)
btnCrankOn.Font = Enum.Font.GothamBold
btnCrankOn.TextSize = 12
btnCrankOn.Parent = frame
Instance.new("UICorner", btnCrankOn).CornerRadius = UDim.new(0,4)

local btnCrankOff = Instance.new("TextButton")
btnCrankOff.Size = UDim2.new(0.5, -9, 0, 26)
btnCrankOff.Position = UDim2.new(0.5, 3, 0, 46)
btnCrankOff.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
btnCrankOff.Text = "■ OFF"
btnCrankOff.TextColor3 = Color3.new(1,1,1)
btnCrankOff.Font = Enum.Font.GothamBold
btnCrankOff.TextSize = 12
btnCrankOff.Parent = frame
Instance.new("UICorner", btnCrankOff).CornerRadius = UDim.new(0,4)

-- ===== SECTION: CLAIM =====
local claimLabel = Instance.new("TextLabel")
claimLabel.Size = UDim2.new(1, -12, 0, 16)
claimLabel.Position = UDim2.new(0, 6, 0, 78)
claimLabel.BackgroundTransparency = 1
claimLabel.Text = "🎁 Auto Claim (7 UUID)"
claimLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
claimLabel.Font = Enum.Font.GothamBold
claimLabel.TextSize = 11
claimLabel.TextXAlignment = Enum.TextXAlignment.Left
claimLabel.Parent = frame

local btnClaimOn = Instance.new("TextButton")
btnClaimOn.Size = UDim2.new(0.5, -9, 0, 26)
btnClaimOn.Position = UDim2.new(0, 6, 0, 96)
btnClaimOn.BackgroundColor3 = Color3.fromRGB(0, 170, 68)
btnClaimOn.Text = "▶ ON"
btnClaimOn.TextColor3 = Color3.new(1,1,1)
btnClaimOn.Font = Enum.Font.GothamBold
btnClaimOn.TextSize = 12
btnClaimOn.Parent = frame
Instance.new("UICorner", btnClaimOn).CornerRadius = UDim.new(0,4)

local btnClaimOff = Instance.new("TextButton")
btnClaimOff.Size = UDim2.new(0.5, -9, 0, 26)
btnClaimOff.Position = UDim2.new(0.5, 3, 0, 96)
btnClaimOff.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
btnClaimOff.Text = "■ OFF"
btnClaimOff.TextColor3 = Color3.new(1,1,1)
btnClaimOff.Font = Enum.Font.GothamBold
btnClaimOff.TextSize = 12
btnClaimOff.Parent = frame
Instance.new("UICorner", btnClaimOff).CornerRadius = UDim.new(0,4)

-- ===== SECTION: SHRED =====
local shredLabel = Instance.new("TextLabel")
shredLabel.Size = UDim2.new(1, -12, 0, 16)
shredLabel.Position = UDim2.new(0, 6, 0, 128)
shredLabel.BackgroundTransparency = 1
shredLabel.Text = "💀 Auto Shred Backpack"
shredLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
shredLabel.Font = Enum.Font.GothamBold
shredLabel.TextSize = 11
shredLabel.TextXAlignment = Enum.TextXAlignment.Left
shredLabel.Parent = frame

local btnShredAll = Instance.new("TextButton")
btnShredAll.Size = UDim2.new(0.5, -9, 0, 26)
btnShredAll.Position = UDim2.new(0, 6, 0, 146)
btnShredAll.BackgroundColor3 = Color3.fromRGB(200, 120, 30)
btnShredAll.Text = "🔥 SHRED ALL"
btnShredAll.TextColor3 = Color3.new(1,1,1)
btnShredAll.Font = Enum.Font.GothamBold
btnShredAll.TextSize = 11
btnShredAll.Parent = frame
Instance.new("UICorner", btnShredAll).CornerRadius = UDim.new(0,4)

local btnShredOne = Instance.new("TextButton")
btnShredOne.Size = UDim2.new(0.5, -9, 0, 26)
btnShredOne.Position = UDim2.new(0.5, 3, 0, 146)
btnShredOne.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
btnShredOne.Text = "🧪 TEST 1"
btnShredOne.TextColor3 = Color3.new(1,1,1)
btnShredOne.Font = Enum.Font.GothamBold
btnShredOne.TextSize = 11
btnShredOne.Parent = frame
Instance.new("UICorner", btnShredOne).CornerRadius = UDim.new(0,4)

-- ===== STATUS =====
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -12, 0, 14)
status.Position = UDim2.new(0, 6, 0, 180)
status.BackgroundTransparency = 1
status.Text = "● IDLE"
status.TextColor3 = Color3.fromRGB(136,136,136)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

-- ===== CLAIM COUNTER =====
local claimInfo = Instance.new("TextLabel")
claimInfo.Size = UDim2.new(1, -12, 0, 14)
claimInfo.Position = UDim2.new(0, 6, 0, 198)
claimInfo.BackgroundTransparency = 1
claimInfo.Text = "Claim: 0 | Shred: 0"
claimInfo.TextColor3 = Color3.fromRGB(120, 220, 180)
claimInfo.Font = Enum.Font.Gotham
claimInfo.TextSize = 10
claimInfo.TextXAlignment = Enum.TextXAlignment.Left
claimInfo.Parent = frame

-- ===== DELAY =====
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1, -12, 0, 14)
delayLabel.Position = UDim2.new(0, 6, 0, 216)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay (detik):"
delayLabel.TextColor3 = Color3.fromRGB(180,180,180)
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextSize = 10
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = frame

local slider = Instance.new("TextBox")
slider.Size = UDim2.new(0, 50, 0, 18)
slider.Position = UDim2.new(1, -56, 0, 216)
slider.BackgroundColor3 = Color3.fromRGB(45,45,45)
slider.TextColor3 = Color3.fromRGB(0,255,136)
slider.Text = "0.3"
slider.Font = Enum.Font.Code
slider.TextSize = 11
slider.Parent = frame
Instance.new("UICorner", slider).CornerRadius = UDim.new(0,3)

-- ===== LOGIC =====
local crankRunning = false
local claimRunning = false
local crankCount, claimCount, shredCount = 0, 0, 0

local function getDelay()
    local n = tonumber(slider.Text)
    if not n or n < 0 then n = 0.3 end
    return n
end

local function updateStatus()
    local c = crankRunning and ("CRANK #"..crankCount) or "Crank:off"
    local cl = claimRunning and ("CLAIM #"..claimCount) or "Claim:off"
    status.Text = "● "..c.." | "..cl
    status.TextColor3 = (crankRunning or claimRunning)
        and Color3.fromRGB(0,255,136)
        or Color3.fromRGB(136,136,136)
    claimInfo.Text = ("Claim: %d | Shred: %d"):format(claimCount, shredCount)
end

-- CRANK
btnCrankOn.MouseButton1Click:Connect(function()
    if crankRunning then return end
    crankRunning = true
    crankCount = 0
    task.spawn(function()
        while crankRunning do
            pcall(fire, "Crank", CRANK_UUID)
            crankCount += 1
            updateStatus()
            task.wait(getDelay())
        end
    end)
end)
btnCrankOff.MouseButton1Click:Connect(function()
    crankRunning = false
    updateStatus()
end)

-- CLAIM
btnClaimOn.MouseButton1Click:Connect(function()
    if claimRunning then return end
    claimRunning = true
    claimCount = 0
    task.spawn(function()
        while claimRunning do
            for _, uuid in ipairs(CLAIM_UUIDS) do
                if not claimRunning then break end
                pcall(fire, "Claim", uuid)
                claimCount += 1
                updateStatus()
                task.wait(getDelay())
            end
        end
    end)
end)
btnClaimOff.MouseButton1Click:Connect(function()
    claimRunning = false
    updateStatus()
end)

-- SHRED ALL (langsung, bukan loop)
btnShredAll.MouseButton1Click:Connect(function()
    local bp = game.Players.LocalPlayer:FindFirstChild("Backpack")
    if not bp then
        btnShredAll.Text = "❌ No BP"
        task.wait(2)
        btnShredAll.Text = "🔥 SHRED ALL"
        return
    end
    btnShredAll.Text = "⏳ ..."
    local ok, skip = 0, 0
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            local uuid = getItemUID(tool)
            if uuid then
                pcall(fire, "Shred", uuid, "B\004")
                ok += 1
                shredCount += 1
                updateStatus()
                task.wait(0.25)
            else
                skip += 1
            end
        end
    end
    btnShredAll.Text = ("✅ %d ⚠️ %d"):format(ok, skip)
    task.wait(2.5)
    btnShredAll.Text = "🔥 SHRED ALL"
end)

-- SHRED TEST 1 ITEM
btnShredOne.MouseButton1Click:Connect(function()
    local bp = game.Players.LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            local uuid = getItemUID(tool)
            if uuid then
                print("[Test Shred]", tool.Name, "→", uuid)
                pcall(fire, "Shred", uuid, "B\004")
                shredCount += 1
                updateStatus()
                btnShredOne.Text = "✅ Done"
                task.wait(2)
                btnShredOne.Text = "🧪 TEST 1"
                return
            end
        end
    end
    btnShredOne.Text = "❌ None"
    task.wait(2)
    btnShredOne.Text = "🧪 TEST 1"
end)

-- ===== MINIMIZE =====
btnMin.MouseButton1Click:Connect(function()
    frame.Visible = false
    local restore = Instance.new("TextButton")
    restore.Size = UDim2.new(0, 38, 0, 38)
    restore.Position = UDim2.new(0, 8, 0, 8)
    restore.BackgroundColor3 = Color3.fromRGB(0, 170, 68)
    restore.Text = "Δ"
    restore.TextColor3 = Color3.new(1,1,1)
    restore.Font = Enum.Font.GothamBold
    restore.TextSize = 18
    restore.Parent = gui
    Instance.new("UICorner", restore).CornerRadius = UDim.new(1,0)

    restore.MouseButton1Click:Connect(function()
        frame.Visible = true
        restore:Destroy()
    end)
end)

-- ===== EXIT =====
btnExit.MouseButton1Click:Connect(function()
    crankRunning = false
    claimRunning = false
    gui:Destroy()
end)

updateStatus()
print("[DeltaAuto] Ready ✅")