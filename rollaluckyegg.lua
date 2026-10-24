-- Delta Auto Roll + EquipBest — mobile GUI
-- Loop: Charge -> Roll -> State -> (optional) EquipBest.
-- EquipBest mode: AUTO (each cycle) | ONCE (manual button).

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local RollEvent = RS:WaitForChild("RollEvent")
local RollPetRequest = RS:WaitForChild("RollPetRequest")

local COOLDOWN = 0.6
local loopOn = false
local running = false
local equipMode = "OFF" -- "OFF" | "AUTO" | "ONCE"

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaAutoRoll"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 220, 0, 230)
main.Position = UDim2.new(0.5, -110, 0.5, -115)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 70)
stroke.Thickness = 1
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
header.BorderSizePixel = 0
header.Parent = main

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 10)
hCorner.Parent = header

local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 12)
hFix.Position = UDim2.new(0, 0, 1, -12)
hFix.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
hFix.BorderSizePixel = 0
hFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Delta Auto Roll"
title.TextColor3 = Color3.fromRGB(230, 230, 235)
title.Font = Enum.Font.GothamMedium
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 22)
minBtn.Position = UDim2.new(1, -64, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
minBtn.BorderSizePixel = 0
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 22)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 48, 48)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 240, 240)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, 0, 1, -34)
body.Position = UDim2.new(0, 0, 0, 34)
body.BackgroundTransparency = 1
body.Parent = main

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -24, 0, 44)
toggle.Position = UDim2.new(0, 12, 0, 12)
toggle.BackgroundColor3 = Color3.fromRGB(52, 52, 60)
toggle.BorderSizePixel = 0
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(200, 200, 210)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16
toggle.Parent = body
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

-- EquipBest section
local eqLabel = Instance.new("TextLabel")
eqLabel.Size = UDim2.new(1, -24, 0, 16)
eqLabel.Position = UDim2.new(0, 12, 0, 66)
eqLabel.BackgroundTransparency = 1
eqLabel.Text = "EquipBest"
eqLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
eqLabel.Font = Enum.Font.GothamMedium
eqLabel.TextSize = 12
eqLabel.TextXAlignment = Enum.TextXAlignment.Left
eqLabel.Parent = body

local eqRow = Instance.new("Frame")
eqRow.Size = UDim2.new(1, -24, 0, 34)
eqRow.Position = UDim2.new(0, 12, 0, 84)
eqRow.BackgroundTransparency = 1
eqRow.Parent = body

local function mkEqBtn(text, xScale, xOff)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(xScale, xOff, 1, 0)
	b.Position = UDim2.new(0, 0, 0, 0)
	if xScale == 0.5 then
		b.Position = UDim2.new(0.5, 4, 0, 0)
		b.Size = UDim2.new(0.5, -4, 1, 0)
	else
		b.Size = UDim2.new(0.5, -4, 1, 0)
	end
	b.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.fromRGB(200, 200, 210)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	b.Parent = eqRow
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end

local eqAuto = mkEqBtn("AUTO", 0, 0)
local eqOnce = mkEqBtn("ONCE", 0, 0)
eqOnce.Position = UDim2.new(0.5, 4, 0, 0)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 20)
status.Position = UDim2.new(0, 12, 0, 130)
status.BackgroundTransparency = 1
status.Text = "idle"
status.TextColor3 = Color3.fromRGB(140, 140, 150)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = body

local hint = Instance.new("TextLabel")
hint.Size = UDim2.new(1, -24, 0, 16)
hint.Position = UDim2.new(0, 12, 0, 152)
hint.BackgroundTransparency = 1
hint.Text = "drag header to move"
hint.TextColor3 = Color3.fromRGB(90, 90, 100)
hint.Font = Enum.Font.Gotham
hint.TextSize = 11
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = body

-- drag
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
header.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- minimize
local minimized = false
local fullSize = main.Size
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		body.Visible = false
		main.Size = UDim2.new(0, 220, 0, 34)
		minBtn.Text = "+"
	else
		body.Visible = true
		main.Size = fullSize
		minBtn.Text = "—"
	end
end)

-- exit
closeBtn.MouseButton1Click:Connect(function()
	loopOn = false
	gui:Destroy()
end)

-- helpers
local function setStatus(s)
	status.Text = s
end

local function fireCharge()
	pcall(function() RollEvent:FireServer(unpack({"Charge"})) end)
end

local function fireRoll()
	pcall(function() RollEvent:FireServer(unpack({"Roll", 1})) end)
end

local function fireState()
	pcall(function() RollPetRequest:InvokeServer(unpack({"State"})) end)
end

local function fireEquipBest()
	pcall(function() RollPetRequest:InvokeServer(unpack({"EquipBest"})) end)
end

local function paintEq()
	eqAuto.BackgroundColor3 = (equipMode == "AUTO") and Color3.fromRGB(46, 140, 84) or Color3.fromRGB(48, 48, 56)
	eqAuto.TextColor3     = (equipMode == "AUTO") and Color3.fromRGB(240, 255, 245) or Color3.fromRGB(200, 200, 210)
	eqOnce.BackgroundColor3 = (equipMode == "ONCE") and Color3.fromRGB(90, 120, 200) or Color3.fromRGB(48, 48, 56)
	eqOnce.TextColor3       = (equipMode == "ONCE") and Color3.fromRGB(240, 245, 255) or Color3.fromRGB(200, 200, 210)
end

eqAuto.MouseButton1Click:Connect(function()
	equipMode = (equipMode == "AUTO") and "OFF" or "AUTO"
	paintEq()
end)

eqOnce.MouseButton1Click:Connect(function()
	equipMode = "ONCE"
	paintEq()
	fireEquipBest()
	setStatus("equipbest (once)")
	task.delay(1, function()
		if status.Text == "equipbest (once)" then setStatus("idle") end
	end)
end)

-- loop
local function doCycle()
	fireCharge(); setStatus("charge"); task.wait(COOLDOWN)
	fireRoll();   setStatus("roll");   task.wait(COOLDOWN)
	fireState();  setStatus("state");  task.wait(COOLDOWN)
	if equipMode == "AUTO" then
		fireEquipBest(); setStatus("equipbest (auto)")
	end
end

toggle.MouseButton1Click:Connect(function()
	loopOn = not loopOn
	if loopOn then
		toggle.Text = "ON"
		toggle.BackgroundColor3 = Color3.fromRGB(46, 140, 84)
		toggle.TextColor3 = Color3.fromRGB(240, 255, 245)
		if not running then
			running = true
			task.spawn(function()
				while loopOn and gui.Parent do
					doCycle()
					task.wait(COOLDOWN)
				end
				running = false
				setStatus("idle")
			end)
		end
	else
		toggle.Text = "OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(52, 52, 60)
		toggle.TextColor3 = Color3.fromRGB(200, 200, 210)
		setStatus("stopping...")
	end
end)

paintEq()