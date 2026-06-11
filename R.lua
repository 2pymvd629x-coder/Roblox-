-- ╔══════════════════════════════════════╗
-- ║       PURPLE HUB V3 - RTA Server     ║
-- ║     حقوق محفوظة لسيرفر RTA           ║
-- ╚══════════════════════════════════════╝

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace       = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local DISCORD_LINK = "discord.gg/RTA"

-- [ريموتات السيرفر الأساسية]
local weaponHitEvent = nil
local storeItemRemote = ReplicatedStorage:WaitForChild("Inventory"):WaitForChild("StoreItem")

task.spawn(function()
    local ws = ReplicatedStorage:FindFirstChild("WeaponsSystem")
    local net = ws and ws:FindFirstChild("Network")
    if net then weaponHitEvent = net:FindFirstChild("WeaponHit") end
end)

-- [المتغيرات وحالات التشغيل]
local isKillNearestActive = false
local isCollectingCash = false
local isRpgStoreActive = false
local isEspActive = false
local isAimBotActive = false
local fovRadius = 80
local guiVisible = true

local killLoop, cashLoop, rpgStoreLoop, aimbotConnection

-- ══════════════════════════════════════
-- [أدوات مساعدة للتصميم]
-- ══════════════════════════════════════
local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 16)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(150, 100, 255)
    s.Thickness = thickness or 1.5
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function addGradient(parent, c0, c1, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c0),
        ColorSequenceKeypoint.new(1, c1)
    })
    g.Rotation = rotation or 135
    g.Parent = parent
    return g
end

-- وظيفة تجعل أي إطار قابل للسحب (Drag Function)
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle = dragHandle or frame

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ══════════════════════════════════════
-- [ScreenGui الرئيسية]
-- ══════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PurpleHubV3_Perfect"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true

local success, err = pcall(function()
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui", 5)
end)
if not success then screenGui.Parent = localPlayer.PlayerGui end

-- الإطار الرئيسي للسكربت
local phoneFrame = Instance.new("Frame")
phoneFrame.Size = UDim2.new(0, 370, 0, 520)
phoneFrame.Position = UDim2.new(0.5, -185, 0.5, -260)
phoneFrame.BackgroundColor3 = Color3.fromRGB(14, 7, 30)
phoneFrame.BorderSizePixel = 0
phoneFrame.ClipsDescendants = true
phoneFrame.Parent = screenGui
addCorner(phoneFrame, 28)
addGradient(phoneFrame, Color3.fromRGB(40, 20, 80), Color3.fromRGB(10, 5, 25), 150)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 70)
topBar.BackgroundColor3 = Color3.fromRGB(30, 15, 65)
topBar.ZIndex = 2
topBar.Parent = phoneFrame
addGradient(topBar, Color3.fromRGB(70, 35, 140), Color3.fromRGB(20, 10, 50), 90)

makeDraggable(phoneFrame, topBar)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 0, 30)
titleLabel.Position = UDim2.new(0, 20, 0, 11)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PURPLE HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 3
titleLabel.Parent = phoneFrame

local rtaBadge = Instance.new("Frame")
rtaBadge.Size = UDim2.new(0, 80, 0, 22)
rtaBadge.Position = UDim2.new(0, 20, 0, 43)
rtaBadge.BackgroundColor3 = Color3.fromRGB(100, 55, 200)
rtaBadge.ZIndex = 3
rtaBadge.Parent = phoneFrame
addCorner(rtaBadge, 8)

local rtaText = Instance.new("TextLabel")
rtaText.Size = UDim2.new(1, 0, 1, 0)
rtaText.BackgroundTransparency = 1
rtaText.Text = "RTA Server"
rtaText.TextColor3 = Color3.fromRGB(230, 210, 255)
rtaText.Font = Enum.Font.GothamBold
rtaText.TextSize = 11
rtaText.Parent = rtaBadge

-- منطقة التمرير
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -100)
scrollFrame.Position = UDim2.new(0, 5, 0, 80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 255)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = phoneFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

local function createCategoryLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 320, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = " " .. text
    lbl.TextColor3 = Color3.fromRGB(180, 140, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = scrollFrame
    return lbl
end

-- دائرة الـ FOV للمساعد
local fovCircleGui = Instance.new("Frame")
fovCircleGui.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircleGui.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
fovCircleGui.BackgroundTransparency = 1
fovCircleGui.Visible = false
fovCircleGui.Parent = screenGui
addCorner(fovCircleGui, 9999)
addStroke(fovCircleGui, Color3.fromRGB(160, 90, 255), 2)

-- ══════════════════════════════════════
-- [زر الهاتف الصغير لإغلاق وفتح الواجهة + سحب الزر]
-- ══════════════════════════════════════
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 55, 0, 55)
toggleButton.Position = UDim2.new(0, 20, 0.3, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(35, 15, 75)
toggleButton.Text = "RTA"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.ZIndex = 10
toggleButton.Parent = screenGui
addCorner(toggleButton, 99)
addStroke(toggleButton, Color3.fromRGB(160, 100, 255), 2)
addGradient(toggleButton, Color3.fromRGB(90, 40, 180), Color3.fromRGB(30, 10, 60), 135)

makeDraggable(toggleButton, toggleButton)

local function toggleGuiElements()
    guiVisible = not guiVisible
    phoneFrame.Visible = guiVisible
end

toggleButton.MouseButton1Click:Connect(toggleGuiElements)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        toggleGuiElements()
    end
end)

-- ══════════════════════════════════════
-- [الوظائف الميكانيكية والبرمجية]
-- ══════════════════════════════════════

local function getSafeZone()
    local safeZonesFolder = Workspace:FindFirstChild("SafeZones")
    if safeZonesFolder then
        local zones = safeZonesFolder:GetChildren()
        if #zones >= 5 then return zones[5] end
    end
    return nil
end

local function killNearestPlayers()
    if not weaponHitEvent then return end
    local char = localPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character.Humanoid.Health > 0 then
                local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                table.insert(targets, {player = p, distance = dist})
            end
        end
    end
    if #targets == 0 then return end
    table.sort(targets, function(a, b) return a.distance < b.distance end)

    local sniper = char:FindFirstChild("Sniper") or localPlayer.Backpack:FindFirstChild("Sniper")
    if not sniper then return end
    if sniper.Parent == localPlayer.Backpack then
        char.Humanoid:EquipTool(sniper)
    end

    local targetPlayer = targets[1].player
    local hitPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hitPart then
        pcall(function()
            weaponHitEvent:FireServer(sniper, {
                p = hitPart.Position, pid = 1, part = hitPart, d = 10, maxDist = 99999,
                h = targetPlayer.Character.Humanoid, m = Enum.Material.Plastic,
                n = Vector3.new(0, 1, 0), t = 0, sid = 24
            })
        end)
    end
end

-- [دالة تجميع الفلوس المحدثة - تم استثناء الأسلحة تماماً]
local function collectCash()
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local cashPart = nil
    -- البحث في الـ Workspace عن الفلوس فقط مع استثناء مجسمات الأسلحة المعروفة
    for _, object in pairs(Workspace:GetChildren()) do
        -- التأكد من أن المجسم ليس من الأسلحة المذكورة M4 أو AR أو M16
        if object.Name ~= "M4" and object.Name ~= "AR" and object.Name ~= "M16" and object.Name ~= "WeaponsSystem" then
            -- التحقق من وجود جزء للتجميع والتحقق من الاسم الشائع للفلوس بالسيرفر
            local h = object:FindFirstChild("Handle") or object:FindFirstChild("Cash") or object:FindFirstChild("Money")
            if h and h:IsA("BasePart") then 
                cashPart = h 
                break 
            end
        end
    end

    if cashPart then
        hrp.CFrame = cashPart.CFrame
    else
        -- إذا لم تتوفر فلوس بالخريطة ينتقل لمنطقة الأمان تلقائياً
        local safeZone = getSafeZone()
        if safeZone and safeZone:IsA("BasePart") then hrp.CFrame = safeZone.CFrame + Vector3.new(0, 3, 0) end
    end
end

local function applyEsp(character)
    if not character then return end
    task.wait(0.2)
    local highlight = character:FindFirstChild("PurpleESP")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "PurpleESP"
        highlight.FillColor = Color3.fromRGB(140, 60, 250)
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Adornee = character
        highlight.Parent = character
    end
    highlight.Enabled = isEspActive
end

local function toggleEsp(state)
    isEspActive = state
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character then
            applyEsp(p.Character)
        end
    end
end

for _, player in pairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function(char)
        if isEspActive then applyEsp(char) end
    end)
end

-- [حساب وتحديد المسافات فوق الرأس بدقة بناءً على مسافة 80 ستميد]
local function getClosestPlayerToFOV()
    local closestTarget = nil
    local maxDistance = fovRadius
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local calculatedOffset = 0

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                local head = p.Character:FindFirstChild("Head") or p.Character.HumanoidRootPart
                local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
                
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < maxDistance then
                        maxDistance = dist
                        closestTarget = head
                        
                        -- حساب المسافة الحقيقية لتحديد الارتفاع المطلوب
                        local realDistance = (camera.CFrame.Position - head.Position).Magnitude
                        if realDistance <= 80 then
                            calculatedOffset = 2  
                        else
                            calculatedOffset = 7  
                        end
                    end
                end
            end
        end
    end
    return closestTarget, calculatedOffset
end

local function toggleAimbot(state)
    isAimBotActive = state
    fovCircleGui.Visible = state 
    
    if state then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local target, offset = getClosestPlayerToFOV()
            if target then
                local targetPositionWithOffset = target.Position + Vector3.new(0, offset, 0)
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetPositionWithOffset)
            end
        end)
    else
        if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
    end
end

-- ══════════════════════════════════════
-- [دالة بناء الأزرار الذكية التفاعلية]
-- ══════════════════════════════════════
local function createToggle(text, order, callback)
    local state = false
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 320, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(25, 12, 52)
    row.LayoutOrder = order
    row.Parent = scrollFrame
    addCorner(row, 14)
    addStroke(row, Color3.fromRGB(80, 50, 150), 1.5)
    addGradient(row, Color3.fromRGB(45, 22, 90), Color3.fromRGB(18, 9, 40), 135)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 210, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -54, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
    track.Parent = row
    addCorner(track, 12)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = UDim2.new(0, 3, 0.5, -9)
    thumb.BackgroundColor3 = Color3.fromRGB(160, 120, 220)
    thumb.Parent = track
    addCorner(thumb, 9)

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = row

    clickArea.MouseButton1Click:Connect(function()
        state = not state
        if state then
            tween(track, 0.15, {BackgroundColor3 = Color3.fromRGB(140, 60, 250)})
            tween(thumb, 0.15, {Position = UDim2.new(0, 23, 0.5, -9), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
        else
            tween(track, 0.15, {BackgroundColor3 = Color3.fromRGB(50, 30, 80)})
            tween(thumb, 0.15, {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(160, 120, 220)})
        end
        callback(state)
    end)
end

local function createSlider(order)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 320, 0, 55)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 12, 52)
    sliderFrame.LayoutOrder = order
    sliderFrame.Parent = scrollFrame
    addCorner(sliderFrame, 14)
    addStroke(sliderFrame, Color3.fromRGB(80, 50, 150), 1.5)

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, -32, 0, 22)
    sliderLabel.Position = UDim2.new(0, 16, 0, 8)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Text = "حجم دائرة التصويب: " .. fovRadius
    sliderLabel.TextColor3 = Color3.fromRGB(200, 180, 220)
    sliderLabel.Font = Enum.Font.GothamBold
    sliderLabel.TextSize = 12
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.Parent = sliderFrame

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -32, 0, 6)
    sliderBar.Position = UDim2.new(0, 16, 0, 38)
    sliderBar.BackgroundColor3 = Color3.fromRGB(40, 20, 70)
    sliderBar.Parent = sliderFrame
    addCorner(sliderBar, 3)

    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new(0.4, -8, 0.5, -8)
    sliderButton.BackgroundColor3 = Color3.fromRGB(180, 120, 255)
    sliderButton.Text = ""
    sliderButton.Parent = sliderBar
    addCorner(sliderButton, 99)

    local dragging = false
    sliderButton.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local barPos = sliderBar.AbsolutePosition
            local barSize = sliderBar.AbsoluteSize
            local percentage = math.clamp((input.Position.X - barPos.X) / barSize.X, 0, 1)
            
            sliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
            fovRadius = math.floor(30 + (percentage * 150))
            sliderLabel.Text = "حجم دائرة التصويب: " .. fovRadius
            fovCircleGui.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
            fovCircleGui.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
        end
    end)
end

-- ══════════════════════════════════════
-- [حقن القوائم بالترتيب بالأزرار المحدثة]
-- ══════════════════════════════════════

createCategoryLabel("السكربت قيد التطوير  ", 1)

createToggle("قتل أقرب اللاعبين تلقائيا", 2, function(state)
    isKillNearestActive = state
    if isKillNearestActive then
        killLoop = task.spawn(function()
            while isKillNearestActive do
                killNearestPlayers()
                task.wait(0.3)
            end
        end)
    else
        if killLoop then task.cancel(killLoop) end
    end
end)

createToggle("تجميع فلوس", 3, function(state)
    isCollectingCash = state
    if isCollectingCash then
        cashLoop = task.spawn(function()
            while isCollectingCash do
                collectCash()
                task.wait(0.15)
            end
        end)
    else
        if cashLoop then task.cancel(cashLoop) end
        local char = localPlayer.Character
        local safeZone = getSafeZone()
        if char and char:FindFirstChild("HumanoidRootPart") and safeZone and safeZone:IsA("BasePart") then
            char.HumanoidRootPart.CFrame = safeZone.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

createToggle("تخزين أر بي جي تلقائيا", 4, function(state)
    isRpgStoreActive = state
    if isRpgStoreActive then
        rpgStoreLoop = task.spawn(function()
            while isRpgStoreActive do
                pcall(function()
                    local args = { "RPG" }
                    storeItemRemote:FireServer(unpack(args))
                end)
                task.wait(0.5)
            end
        end)
    else
        if rpgStoreLoop then task.cancel(rpgStoreLoop) end
    end
end)

createToggle("تصويب", 5, function(state)
    toggleAimbot(state)
end)

createToggle("كشف الاعبين", 6, function(state)
    toggleEsp(state)
end)

-- شريط التحكم بحجم الدائرة
createSlider(7)
