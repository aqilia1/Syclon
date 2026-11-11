--[[
    Rod And Reef v12
    - Billboard nama ESP diperkecil (TextSize fixed, bukan TextScaled) + offset vertikal
    - STOP -> auto re-equip rod (fire "L" sekali)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

pcall(function()
    local old = playerGui:FindFirstChild("RodAndReefGui")
    if old then old:Destroy() end
    local core = game:GetService("CoreGui")
    local old2 = core:FindFirstChild("RodAndReefGui")
    if old2 then old2:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RodAndReefGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

local okParent = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not okParent or not ScreenGui.Parent then
    ScreenGui.Parent = playerGui
end

local CONFIG = {
    DefaultDelay = 3,
    MinDelay = 0.5,
    MaxDelay = 30,
    Color = Color3.fromRGB(24, 26, 34),
    InnerBg = Color3.fromRGB(32, 35, 46),
    SubBg = Color3.fromRGB(40, 44, 58),
    HeaderBg = Color3.fromRGB(44, 48, 64),
    Accent = Color3.fromRGB(90, 190, 255),
    Success = Color3.fromRGB(70, 210, 130),
    Danger = Color3.fromRGB(240, 90, 90),
    TextColor = Color3.fromRGB(238, 240, 245),
    TextDim = Color3.fromRGB(170, 178, 195),
    Warn = Color3.fromRGB(255, 200, 90),
    Credit = Color3.fromRGB(140, 148, 165),
    EspColor = Color3.fromRGB(255, 100, 100),
    DexColor = Color3.fromRGB(255, 225, 100),
    RowBg = Color3.fromRGB(50, 55, 72),
    RowHover = Color3.fromRGB(66, 72, 92),
    RowOn = Color3.fromRGB(40, 130, 85),
    PanelBg = Color3.fromRGB(36, 40, 52),
    Pad = 10,
    RowH = 26,
    Gap = 8,
}

local function create(className, props)
    local ok, inst = pcall(Instance.new, className)
    if not ok or not inst then return nil end
    for k, v in pairs(props) do
        pcall(function() inst[k] = v end)
    end
    return inst
end

local function getViewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local FRAME_W = math.min(580, getViewport().X - 20)
local FRAME_H = 320
local MainFrame = create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, FRAME_W, 0, FRAME_H),
    Position = UDim2.new(0.5, -FRAME_W/2, 0.5, -FRAME_H/2),
    BackgroundColor3 = CONFIG.Color,
    BorderSizePixel = 0,
    Active = true,
    Parent = ScreenGui,
})
if not MainFrame then return end
create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = MainFrame })
create("UIStroke", { Color = CONFIG.Accent, Thickness = 1.5, Transparency = 0.5, Parent = MainFrame })

local HDR_H = 38
local Header = create("Frame", {
    Size = UDim2.new(1, 0, 0, HDR_H),
    BackgroundColor3 = CONFIG.HeaderBg,
    BorderSizePixel = 0,
    Active = true,
    Parent = MainFrame,
})
create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Header })
create("Frame", {
    Size = UDim2.new(1, 0, 0, 12),
    Position = UDim2.new(0, 0, 1, -12),
    BackgroundColor3 = CONFIG.HeaderBg,
    BorderSizePixel = 0,
    Parent = Header,
})

create("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "🎣 Rod And Reef",
    TextColor3 = CONFIG.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})

local MinBtn = create("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -58, 0, 6),
    BackgroundColor3 = CONFIG.SubBg,
    Text = "—",
    TextColor3 = CONFIG.TextColor,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    AutoButtonColor = false,
    Parent = Header,
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = MinBtn })

local CloseBtn = create("TextButton", {
    Size = UDim2.new(0, 26, 0, 26),
    Position = UDim2.new(1, -30, 0, 6),
    BackgroundColor3 = CONFIG.SubBg,
    Text = "✕",
    TextColor3 = CONFIG.TextColor,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    AutoButtonColor = false,
    Parent = Header,
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = CloseBtn })

local PAD = CONFIG.Pad
local GAP = CONFIG.Gap
local BODY_TOP = HDR_H + PAD
local FOOTER_H = 20
local BodyW = FRAME_W - PAD * 2
local LeftW = math.floor(BodyW * 0.42)
local RightW = BodyW - LeftW - GAP
local BodyH = FRAME_H - BODY_TOP - PAD - FOOTER_H

-- LEFT COLUMN
local LeftCol = create("Frame", {
    Size = UDim2.new(0, LeftW, 0, BodyH),
    Position = UDim2.new(0, PAD, 0, BODY_TOP),
    BackgroundColor3 = CONFIG.InnerBg,
    BorderSizePixel = 0,
    Parent = MainFrame,
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = LeftCol })

create("TextLabel", {
    Size = UDim2.new(1, -16, 0, 18),
    Position = UDim2.new(0, 8, 0, 8),
    BackgroundTransparency = 1,
    Text = "Auto Fishing",
    TextColor3 = CONFIG.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = LeftCol,
})

local InfoLabel = create("TextLabel", {
    Size = UDim2.new(1, -16, 0, 34),
    Position = UDim2.new(0, 8, 0, 30),
    BackgroundColor3 = Color3.fromRGB(22, 24, 32),
    Text = "Idle",
    TextColor3 = CONFIG.Warn,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Parent = LeftCol,
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = InfoLabel })

local DelayFrame = create("Frame", {
    Size = UDim2.new(1, -16, 0, 62),
    Position = UDim2.new(0, 8, 0, 72),
    BackgroundColor3 = CONFIG.SubBg,
    BorderSizePixel = 0,
    Parent = LeftCol,
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = DelayFrame })

local DelayLabel = create("TextLabel", {
    Size = UDim2.new(1, -16, 0, 20),
    Position = UDim2.new(0, 8, 0, 5),
    BackgroundTransparency = 1,
    Text = "Delay: 3.0s",
    TextColor3 = CONFIG.TextColor,
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = DelayFrame,
})

local DelayInput = create("TextBox", {
    Size = UDim2.new(0, 62, 0, 28),
    Position = UDim2.new(0, 8, 0, 28),
    BackgroundColor3 = CONFIG.RowBg,
    Text = "3",
    TextColor3 = CONFIG.TextColor,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    ClearTextOnFocus = false,
    Parent = DelayFrame,
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = DelayInput })

local currentDelay = CONFIG.DefaultDelay
local function updateLabels()
    DelayLabel.Text = string.format("Delay: %.1fs", currentDelay)
    DelayInput.Text = tostring(currentDelay)
end

local function makeArrow(text, posX, callback, parent)
    local btn = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 28),
        Position = UDim2.new(0, posX, 0, 28),
        BackgroundColor3 = CONFIG.RowBg,
        Text = text,
        TextColor3 = CONFIG.TextColor,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        AutoButtonColor = false,
        Parent = parent,
    })
    if btn then
        create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

makeArrow("−", 78, function()
    currentDelay = math.max(CONFIG.MinDelay, math.floor((currentDelay - 0.5) * 10) / 10)
    updateLabels()
end, DelayFrame)

makeArrow("+", 112, function()
    currentDelay = math.min(CONFIG.MaxDelay, math.floor((currentDelay + 0.5) * 10) / 10)
    updateLabels()
end, DelayFrame)

DelayInput.FocusLost:Connect(function()
    local num = tonumber(DelayInput.Text)
    if num and num >= CONFIG.MinDelay and num <= CONFIG.MaxDelay then
        currentDelay = math.floor(num * 10) / 10
    end
    updateLabels()
end)

local ToggleBtn = create("TextButton", {
    Size = UDim2.new(1, -16, 0, 46),
    Position = UDim2.new(0, 8, 0, 142),
    BackgroundColor3 = CONFIG.Success,
    Text = "▶  START",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    AutoButtonColor = false,
    Parent = LeftCol,
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ToggleBtn })

-- RIGHT COLUMN
local RightCol = create("Frame", {
    Size = UDim2.new(0, RightW, 0, BodyH),
    Position = UDim2.new(0, PAD + LeftW + GAP, 0, BODY_TOP),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = MainFrame,
})

local function makeSection(parent, yPos, height, title)
    local sec = create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        Position = UDim2.new(0, 0, 0, yPos),
        BackgroundColor3 = CONFIG.InnerBg,
        BorderSizePixel = 0,
        Parent = parent,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = sec })
    create("TextLabel", {
        Size = UDim2.new(1, -110, 0, 20),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = CONFIG.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sec,
    })
    return sec
end

local function makeDropdownBtn(parent, yPos, rightOffset, placeholder)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -(rightOffset or 20), 0, 28),
        Position = UDim2.new(0, 10, 0, yPos),
        BackgroundColor3 = CONFIG.RowBg,
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
    })
    create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
    local lbl = create("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = placeholder or "Pilih...",
        TextColor3 = CONFIG.TextColor,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })
    create("TextLabel", {
        Size = UDim2.new(0, 22, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = CONFIG.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        Parent = btn,
    })
    return btn, lbl
end

local ESP_H = 118
local EspSec = makeSection(RightCol, 0, ESP_H, "ESP NPC")

local espEnabled = false
local EspToggleBtn = create("TextButton", {
    Size = UDim2.new(0, 56, 0, 28),
    Position = UDim2.new(1, -66, 0, 36),
    BackgroundColor3 = CONFIG.Danger,
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    Parent = EspSec,
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = EspToggleBtn })

local EspDropdownBtn, EspDropdownLbl = makeDropdownBtn(EspSec, 36, 76, "Pilih NPC  (0)")

local EspStatus = create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 1, -26),
    BackgroundTransparency = 1,
    Text = "ESP off",
    TextColor3 = CONFIG.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = EspSec,
})

local TP_H = 118
local TpSec = makeSection(RightCol, ESP_H + GAP, TP_H, "TELEPORT NPC")

local TpDropdownBtn, TpDropdownLbl = makeDropdownBtn(TpSec, 36, 100, "Pilih NPC")

local TpGoBtn = create("TextButton", {
    Size = UDim2.new(0, 84, 0, 28),
    Position = UDim2.new(1, -94, 0, 36),
    BackgroundColor3 = CONFIG.Accent,
    Text = "Teleport",
    TextColor3 = Color3.fromRGB(15, 20, 30),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    Parent = TpSec,
})
create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = TpGoBtn })

local TpStatus = create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 1, -26),
    BackgroundTransparency = 1,
    Text = "Pilih NPC lalu Teleport",
    TextColor3 = CONFIG.TextDim,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TpSec,
})

create("TextLabel", {
    Size = UDim2.new(1, 0, 0, FOOTER_H),
    Position = UDim2.new(0, 0, 1, -FOOTER_H - 4),
    BackgroundTransparency = 1,
    Text = "powered by syclon",
    TextColor3 = CONFIG.Credit,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Center,
    Parent = MainFrame,
})

-- OVERLAY
local OVERLAY_HDR = 26
local OVERLAY_FOOTER = 32
local BASE_Z = 1000

local Overlay = create("Frame", {
    Name = "DropdownOverlay",
    Size = UDim2.new(0, 200, 0, 100),
    BackgroundColor3 = CONFIG.PanelBg,
    BorderSizePixel = 0,
    Visible = false,
    Active = true,
    ZIndex = BASE_Z,
    Parent = ScreenGui,
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Overlay })
create("UIStroke", { Color = CONFIG.Accent, Thickness = 1.2, Transparency = 0.3, Parent = Overlay })

local OverlayHdr = create("Frame", {
    Size = UDim2.new(1, 0, 0, OVERLAY_HDR),
    BackgroundColor3 = CONFIG.HeaderBg,
    BorderSizePixel = 0,
    ZIndex = BASE_Z + 1,
    Parent = Overlay,
})
create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = OverlayHdr })
create("Frame", {
    Size = UDim2.new(1, 0, 0, 8),
    Position = UDim2.new(0, 0, 1, -8),
    BackgroundColor3 = CONFIG.HeaderBg,
    BorderSizePixel = 0,
    ZIndex = BASE_Z + 1,
    Parent = OverlayHdr,
})

local OverlayTitle = create("TextLabel", {
    Size = UDim2.new(1, -34, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "Pilih NPC",
    TextColor3 = CONFIG.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = BASE_Z + 2,
    Parent = OverlayHdr,
})

local OverlayCloseBtn = create("TextButton", {
    Size = UDim2.new(0, 22, 0, 22),
    Position = UDim2.new(1, -26, 0, 2),
    BackgroundColor3 = CONFIG.Danger,
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    ZIndex = BASE_Z + 3,
    Parent = OverlayHdr,
})
create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = OverlayCloseBtn })

local OverlayScroll = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -(OVERLAY_HDR + OVERLAY_FOOTER)),
    Position = UDim2.new(0, 0, 0, OVERLAY_HDR),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    ScrollBarImageColor3 = CONFIG.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = BASE_Z + 1,
    Parent = Overlay,
})

local OverlayActions = create("Frame", {
    Size = UDim2.new(1, 0, 0, OVERLAY_FOOTER),
    Position = UDim2.new(0, 0, 1, -OVERLAY_FOOTER),
    BackgroundColor3 = CONFIG.PanelBg,
    BorderSizePixel = 0,
    ZIndex = BASE_Z + 1,
    Parent = Overlay,
})

local OverlayAllBtn = create("TextButton", {
    Size = UDim2.new(0.5, -4, 0, 26),
    Position = UDim2.new(0, 4, 0, 3),
    BackgroundColor3 = CONFIG.Success,
    Text = "All",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    ZIndex = BASE_Z + 2,
    Parent = OverlayActions,
})
create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = OverlayAllBtn })

local OverlayNoneBtn = create("TextButton", {
    Size = UDim2.new(0.5, -4, 0, 26),
    Position = UDim2.new(0.5, 0, 0, 3),
    BackgroundColor3 = CONFIG.Danger,
    Text = "None",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    ZIndex = BASE_Z + 2,
    Parent = OverlayActions,
})
create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = OverlayNoneBtn })

-- STATE
local highlights = {}
local billboards = {}
local espSelected = {}
local tpSelected = nil
local ROW_H = CONFIG.RowH
local overlayMode = nil

local function findDialogueFolder()
    local direct = Workspace:FindFirstChild("DialogueNPCs")
    if direct then return direct end
    return Workspace:FindFirstChild("DialogueNPCs", true)
end

local function countMap(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function getModelRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("Head")
        or model:FindFirstChildWhichIsA("BasePart", true)
end

local function collectNames()
    local folder = findDialogueFolder()
    local names, seen = {}, {}
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") and not seen[child.Name] then
                seen[child.Name] = true
                table.insert(names, child.Name)
            end
        end
    end
    table.sort(names)
    return names, folder ~= nil
end

local function clearOverlayRows()
    for _, c in ipairs(OverlayScroll:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
end

local function positionOverlay(triggerBtn, withActions, title)
    local vp = getViewport()
    local abs = triggerBtn.AbsolutePosition
    local absSize = triggerBtn.AbsoluteSize
    local names, hasFolder = collectNames()
    local totalCount = #names
    local actionsH = withActions and OVERLAY_FOOTER or 0
    local contentH = OVERLAY_HDR + math.max(totalCount, 1) * ROW_H + actionsH
    local minH = OVERLAY_HDR + ROW_H + actionsH

    local w = absSize.X
    if w < 160 then w = 160 end
    local x = abs.X
    if x + w > vp.X - 8 then x = vp.X - w - 8 end
    if x < 8 then x = 8 end

    local belowY = abs.Y + absSize.Y + 4
    local maxBelow = vp.Y - belowY - 8
    local maxAbove = abs.Y - 8

    local h, y
    if contentH <= maxBelow then
        h = contentH
        y = belowY
    elseif contentH <= maxAbove then
        h = contentH
        y = abs.Y - contentH - 4
    else
        if maxBelow >= maxAbove then
            h = math.max(minH, math.min(contentH, maxBelow))
            y = belowY
        else
            h = math.max(minH, math.min(contentH, maxAbove))
            y = abs.Y - h - 4
        end
    end

    Overlay.Position = UDim2.new(0, x, 0, y)
    Overlay.Size = UDim2.new(0, w, 0, h)
    OverlayTitle.Text = title or "Pilih NPC"
    OverlayActions.Visible = withActions
    OverlayScroll.Size = UDim2.new(1, 0, 1, -(OVERLAY_HDR + actionsH))
    OverlayScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(totalCount, 1) * ROW_H)
    OverlayScroll.CanvasPosition = Vector2.new(0, 0)

    if not hasFolder or totalCount == 0 then
        local empty = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, ROW_H),
            BackgroundTransparency = 1,
            Text = "DialogueNPCs kosong",
            TextColor3 = CONFIG.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            ZIndex = BASE_Z + 2,
            Parent = OverlayScroll,
        })
        if empty then empty.Position = UDim2.new(0, 0, 0, 0) end
    end
end

local refreshEsp

local function buildEspOverlayRows(triggerBtn)
    clearOverlayRows()
    local names = collectNames()
    for i, name in ipairs(names) do
        local isOn = espSelected[name] and true or false
        local row = create("TextButton", {
            Size = UDim2.new(1, 0, 0, ROW_H),
            Position = UDim2.new(0, 0, 0, (i - 1) * ROW_H),
            BackgroundColor3 = isOn and CONFIG.RowOn or CONFIG.RowBg,
            Text = "",
            AutoButtonColor = false,
            ZIndex = BASE_Z + 2,
            Parent = OverlayScroll,
        })
        local check = create("TextLabel", {
            Size = UDim2.new(0, 22, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = isOn and "☑" or "☐",
            TextColor3 = isOn and Color3.fromRGB(255,255,255) or CONFIG.TextDim,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = BASE_Z + 3,
            Parent = row,
        })
        create("TextLabel", {
            Size = UDim2.new(1, -34, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = CONFIG.TextColor,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = BASE_Z + 3,
            Parent = row,
        })
        row.MouseEnter:Connect(function()
            if not espSelected[name] then row.BackgroundColor3 = CONFIG.RowHover end
        end)
        row.MouseLeave:Connect(function()
            row.BackgroundColor3 = espSelected[name] and CONFIG.RowOn or CONFIG.RowBg
        end)
        row.MouseButton1Click:Connect(function()
            espSelected[name] = not espSelected[name] or nil
            check.Text = espSelected[name] and "☑" or "☐"
            row.BackgroundColor3 = espSelected[name] and CONFIG.RowOn or CONFIG.RowBg
            if espEnabled then refreshEsp() else
                EspDropdownLbl.Text = string.format("Pilih NPC  (%d)", countMap(espSelected))
            end
        end)
    end
    positionOverlay(triggerBtn, true, "ESP NPC")
end

local function buildTpOverlayRows(triggerBtn)
    clearOverlayRows()
    local names = collectNames()
    for i, name in ipairs(names) do
        local isOn = (tpSelected == name)
        local row = create("TextButton", {
            Size = UDim2.new(1, 0, 0, ROW_H),
            Position = UDim2.new(0, 0, 0, (i - 1) * ROW_H),
            BackgroundColor3 = isOn and CONFIG.RowOn or CONFIG.RowBg,
            Text = "",
            AutoButtonColor = false,
            ZIndex = BASE_Z + 2,
            Parent = OverlayScroll,
        })
        create("TextLabel", {
            Size = UDim2.new(0, 22, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = isOn and "●" or "○",
            TextColor3 = isOn and Color3.fromRGB(255,255,255) or CONFIG.TextDim,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = BASE_Z + 3,
            Parent = row,
        })
        create("TextLabel", {
            Size = UDim2.new(1, -34, 1, 0),
            Position = UDim2.new(0, 32, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = CONFIG.TextColor,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = BASE_Z + 3,
            Parent = row,
        })
        row.MouseEnter:Connect(function()
            if tpSelected ~= name then row.BackgroundColor3 = CONFIG.RowHover end
        end)
        row.MouseLeave:Connect(function()
            row.BackgroundColor3 = (tpSelected == name) and CONFIG.RowOn or CONFIG.RowBg
        end)
        row.MouseButton1Click:Connect(function()
            tpSelected = name
            TpDropdownLbl.Text = "Pilih NPC: " .. name
            TpStatus.Text = "Target: " .. name
            Overlay.Visible = false
            overlayMode = nil
        end)
    end
    positionOverlay(triggerBtn, false, "TELEPORT NPC")
end

local function closeOverlay()
    Overlay.Visible = false
    overlayMode = nil
end

OverlayCloseBtn.MouseButton1Click:Connect(closeOverlay)

EspDropdownBtn.MouseButton1Click:Connect(function()
    if overlayMode == "esp" and Overlay.Visible then
        closeOverlay()
        return
    end
    overlayMode = "esp"
    buildEspOverlayRows(EspDropdownBtn)
    Overlay.Visible = true
end)

TpDropdownBtn.MouseButton1Click:Connect(function()
    if overlayMode == "tp" and Overlay.Visible then
        closeOverlay()
        return
    end
    overlayMode = "tp"
    buildTpOverlayRows(TpDropdownBtn)
    Overlay.Visible = true
end)

OverlayAllBtn.MouseButton1Click:Connect(function()
    if overlayMode ~= "esp" then return end
    local folder = findDialogueFolder()
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") then espSelected[child.Name] = true end
        end
    end
    buildEspOverlayRows(EspDropdownBtn)
    if espEnabled then refreshEsp() end
end)

OverlayNoneBtn.MouseButton1Click:Connect(function()
    if overlayMode ~= "esp" then return end
    espSelected = {}
    buildEspOverlayRows(EspDropdownBtn)
    if espEnabled then refreshEsp() end
end)

local function clearEsp()
    for _, hl in pairs(highlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    for _, bb in pairs(billboards) do
        if bb and bb.Parent then bb:Destroy() end
    end
    highlights = {}
    billboards = {}
end

local function attachEspToModel(model)
    if not model or not model:IsA("Model") then return end
    if not (highlights[model] and highlights[model].Parent) then
        local hl = Instance.new("Highlight")
        hl.Name = "RodAndReefESP"
        hl.FillColor = CONFIG.EspColor
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.35
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = model
        hl.Parent = model
        highlights[model] = hl
    end
    if not (billboards[model] and billboards[model].Parent) then
        local root = getModelRoot(model)
        if root then
            local bb = Instance.new("BillboardGui")
            bb.Name = "RodAndReefName"
            bb.Size = UDim2.new(0, 120, 0, 18)          -- kecil
            bb.StudsOffset = Vector3.new(0, 2.5, 0)     -- di atas kepala
            bb.AlwaysOnTop = true
            bb.MaxDistance = 120                        -- batas jarak
            bb.Adornee = root
            bb.Parent = root

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = model.Name
            lbl.TextColor3 = CONFIG.DexColor
            lbl.TextStrokeTransparency = 0.2
            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 13                            -- fixed, bukan TextScaled
            lbl.TextScaled = false
            lbl.TextWrapped = false
            lbl.Parent = bb

            billboards[model] = bb
        end
    end
end

refreshEsp = function()
    clearEsp()
    EspDropdownLbl.Text = string.format("Pilih NPC  (%d)", countMap(espSelected))
    if not espEnabled then
        EspStatus.Text = "ESP off"
        return
    end
    if countMap(espSelected) == 0 then
        EspStatus.Text = "Belum ada NPC dipilih"
        return
    end
    local folder = findDialogueFolder()
    if not folder then
        EspStatus.Text = "DialogueNPCs tidak ada"
        return
    end
    local count = 0
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") and espSelected[child.Name] then
            attachEspToModel(child)
            count = count + 1
        end
    end
    EspStatus.Text = string.format("ESP on: %d model", count)
end

local folderConnAdd, folderConnRemove
local function bindFolderWatch()
    if folderConnAdd then folderConnAdd:Disconnect(); folderConnAdd = nil end
    if folderConnRemove then folderConnRemove:Disconnect(); folderConnRemove = nil end
    local folder = findDialogueFolder()
    if not folder then return end
    folderConnAdd = folder.ChildAdded:Connect(function()
        if espEnabled then task.wait(0.15); refreshEsp() end
    end)
    folderConnRemove = folder.ChildRemoved:Connect(function()
        if espEnabled then task.wait(0.15); refreshEsp() end
    end)
end

EspToggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        EspToggleBtn.Text = "ON"
        TweenService:Create(EspToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Success}):Play()
        bindFolderWatch()
        refreshEsp()
    else
        EspToggleBtn.Text = "OFF"
        TweenService:Create(EspToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Danger}):Play()
        clearEsp()
        EspStatus.Text = "ESP off"
    end
end)

TpGoBtn.MouseButton1Click:Connect(function()
    if not tpSelected then
        TpStatus.Text = "Pilih NPC dulu"
        return
    end
    local folder = findDialogueFolder()
    if not folder then
        TpStatus.Text = "DialogueNPCs tidak ada"
        return
    end
    local chr = player.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp then
        TpStatus.Text = "Character belum ada"
        return
    end
    local target
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") and child.Name == tpSelected then
            local r = getModelRoot(child)
            if r then target = r; break end
        end
    end
    if not target then
        TpStatus.Text = "Model target tidak ada"
        return
    end
    hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
    TpStatus.Text = "TP ke " .. tpSelected
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not Overlay.Visible then return end
    if input.KeyCode == Enum.KeyCode.Escape then
        closeOverlay()
        return
    end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local mp = input.Position
    local op = Overlay.AbsolutePosition
    local os = Overlay.AbsoluteSize
    if mp.X < op.X or mp.X > op.X + os.X or mp.Y < op.Y or mp.Y > op.Y + os.Y then
        closeOverlay()
    end
end)

-- MIN ICON + DRAG
local MinIcon = create("TextButton", {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 20, 0.5, -25),
    BackgroundColor3 = CONFIG.Color,
    Text = "🎣",
    TextColor3 = CONFIG.Accent,
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    Visible = false,
    AutoButtonColor = false,
    Parent = ScreenGui,
})
create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = MinIcon })
create("UIStroke", { Color = CONFIG.Accent, Thickness = 1.5, Transparency = 0.4, Parent = MinIcon })

local function makeDraggable(frame, dragArea)
    local dragging = false
    local dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            if Overlay.Visible then
                if overlayMode == "esp" then
                    buildEspOverlayRows(EspDropdownBtn)
                elseif overlayMode == "tp" then
                    buildTpOverlayRows(TpDropdownBtn)
                end
            end
        end
    end)
end

makeDraggable(MainFrame, Header)
makeDraggable(MinIcon, MinIcon)

MinBtn.MouseButton1Click:Connect(function()
    closeOverlay()
    MainFrame.Visible = false
    MinIcon.Visible = true
end)
MinIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinIcon.Visible = false
end)
CloseBtn.MouseButton1Click:Connect(function()
    clearEsp()
    ScreenGui:Destroy()
end)

-- LOOP
local isRunning = false
local bufferSupported = pcall(function() return buffer.fromstring("test") end)

local function getByteNet()
    local rs = game:GetService("ReplicatedStorage")
    return rs:FindFirstChild("ByteNetReliable") or rs:WaitForChild("ByteNetReliable", 5)
end

local function waitDelay(seconds, packetName)
    local total = seconds
    local waited = 0
    while waited < total and isRunning do
        local remaining = total - waited
        InfoLabel.Text = string.format("%s... %.1fs", packetName or "-", remaining)
        InfoLabel.TextColor3 = CONFIG.Warn
        local step = math.min(0.1, remaining)
        task.wait(step)
        waited = waited + step
    end
end

local function fireL()
    local bn = getByteNet()
    if not bn then return false end
    InfoLabel.Text = "Throwing..."
    InfoLabel.TextColor3 = CONFIG.Success
    pcall(function()
        bn:FireServer(buffer.fromstring("L\004<\000\000\000\000\000\200B"))
    end)
    return true
end

local function fireN()
    local bn = getByteNet()
    if not bn then return false end
    InfoLabel.Text = "Catching..."
    InfoLabel.TextColor3 = CONFIG.Success
    pcall(function()
        bn:FireServer(buffer.fromstring("N\004\a\000Perfect"))
    end)
    return true
end

local function fireP()
    local bn = getByteNet()
    if not bn then return false end
    InfoLabel.Text = "Reeling..."
    InfoLabel.TextColor3 = CONFIG.Success
    pcall(function()
        bn:FireServer(buffer.fromstring("P\004"))
    end)
    return true
end

local function setToggleUI(running)
    isRunning = running
    if running then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Danger}):Play()
        ToggleBtn.Text = "■  STOP"
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Success}):Play()
        ToggleBtn.Text = "▶  START"
        InfoLabel.Text = "Idle"
        InfoLabel.TextColor3 = CONFIG.Warn
    end
end

local function startLoop()
    if isRunning then return end
    if not bufferSupported then
        InfoLabel.Text = "buffer not supported"
        InfoLabel.TextColor3 = CONFIG.Danger
        return
    end
    setToggleUI(true)
    task.spawn(function()
        while isRunning do
            fireL()
            waitDelay(currentDelay, "Throwing")
            if not isRunning then break end
            fireN()
            waitDelay(currentDelay, "Catching")
            if not isRunning then break end
            fireP()
            waitDelay(currentDelay, "Reeling")
        end
    end)
end

local function stopLoop()
    if not isRunning then return end
    isRunning = false
    setToggleUI(false)
    -- Re-equip rod setelah stop: fire "L" sekali
    task.wait(0.2)
    local bn = getByteNet()
    if bn then
        pcall(function()
            bn:FireServer(buffer.fromstring("L\004<\000\000\000\000\000\200B"))
        end)
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    if isRunning then stopLoop() else startLoop() end
end)

updateLabels()
setToggleUI(false)

task.spawn(function()
    task.wait(1)
    refreshEsp()
end)

print("[Rod And Reef v12] loaded — powered by syclon")