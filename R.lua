-- [المكتبات الأساسية]
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local userInputService = game:GetService("UserInputService")

local weaponHitEvent = replicatedStorage:WaitForChild("WeaponsSystem"):WaitForChild("Network"):WaitForChild("WeaponHit")
local storeItemRemote = replicatedStorage:WaitForChild("Inventory"):WaitForChild("StoreItem")

-- [المتغيرات وحالات التشغيل]
local isKillNearestActive = false
local isCollectingCash = false
local isEspActive = false
local isAimBotActive = false
local isRpgStoreActive = false
local isMenuOpen = true
local fovRadius = 80

local killLoop, cashLoop, aimbotConnection, rpgStoreLoop
local cashAnimationTrack = nil

-- [1] إنشاء الواجهة الرئيسية
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PurplePhoneHubV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local phoneFrame = Instance.new("Frame")
phoneFrame.Size = UDim2.new(0, 380, 0, 380)
phoneFrame.Position = UDim2.new(0.5, -190, 0.5, -190)
phoneFrame.BackgroundColor3 = Color3.fromRGB(22, 11, 36)
phoneFrame.BorderSizePixel = 0
phoneFrame.ClipsDescendants = true
phoneFrame.Parent = screenGui

local phoneGradient = Instance.new("UIGradient")
phoneGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 40, 160)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 15, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 5, 35))
})
phoneGradient.Rotation = 45
phoneGradient.Parent = phoneFrame

local uiCornerPhone = Instance.new("UICorner")
uiCornerPhone.CornerRadius = UDim.new(0, 26)
uiCornerPhone.Parent = phoneFrame

local shadowFrame = Instance.new("Frame")
shadowFrame.Size = UDim2.new(1, 10, 1, 10)
shadowFrame.Position = UDim2.new(0, -5, 0, -5)
shadowFrame.BackgroundTransparency = 1
shadowFrame.Parent = phoneFrame
local shadowStroke = Instance.new("UIStroke")
shadowStroke.Color = Color3.fromRGB(180, 130, 255)
shadowStroke.Thickness = 4
shadowStroke.Transparency = 0.6
shadowStroke.Parent = shadowFrame
local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 28)
shadowCorner.Parent = shadowFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ PURPLE HUB"
titleLabel.TextColor3 = Color3.fromRGB(240, 200, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 22
titleLabel.Parent = phoneFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 130, 255))
})
titleGradient.Parent = titleLabel

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -60)
scrollFrame.Position = UDim2.new(0, 0, 0, 55)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
scrollFrame.ScrollBarThickness = 2
scrollFrame.Parent = phoneFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 12)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- زر الإغلاق والقائمة
local toggleMenuBtn = Instance.new("TextButton")
toggleMenuBtn.Name = "ToggleMenu"
toggleMenuBtn.Size = UDim2.new(0, 50, 0, 50)
toggleMenuBtn.Position = UDim2.new(1, -60, 0, 10)
toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 70)
toggleMenuBtn.Text = "✕"
toggleMenuBtn.Font = Enum.Font.GothamBold
toggleMenuBtn.TextSize = 22
toggleMenuBtn.TextColor3 = Color3.fromRGB(240, 210, 255)
toggleMenuBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleMenuBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(150, 100, 255)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleMenuBtn

-- نظام السحب المطور والتعديل لمنع التعليق
local draggingToggle = false
local dragStart = nil
local startPos = nil

toggleMenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = true
        dragStart = input.Position
        startPos = toggleMenuBtn.Position
    end
end)

userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingToggle = false
    end
end)

userInputService.InputChanged:Connect(function(input)
    if draggingToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        toggleMenuBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

toggleMenuBtn.MouseEnter:Connect(function()
    tweenService:Create(toggleMenuBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 40, 120)}):Play()
end)
toggleMenuBtn.MouseLeave:Connect(function()
    tweenService:Create(toggleMenuBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 20, 70)}):Play()
end)

-- دالة إنشاء الأزرار
local function createButton(text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 240, 0, 48)
    btn.BackgroundColor3 = Color3.fromRGB(35, 18, 60)
    btn.Text = text .. " : OFF"
    btn.TextColor3 = Color3.fromRGB(230, 210, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.LayoutOrder = order
    btn.Parent = scrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 14)
    btnCorner.Parent = btn

    local btnGradient = Instance.new("UIGradient")
    btnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 30, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 18, 60))
    })
    btnGradient.Rotation = 135
    btnGradient.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(100, 70, 180)
    btnStroke.Thickness = 1.5
    btnStroke.Parent = btn

    btn.MouseEnter:Connect(function()
        tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 30, 110)}):Play()
        tweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(200, 150, 255)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        tweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 18, 60)}):Play()
        tweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 70, 180)}):Play()
    end)

    return btn
end

local killNearestBtn = createButton("قتل أقرب لاعبين", 1)
local farmCashBtn = createButton("تجميع الفلوس ذكي", 2)
local espBtn = createButton("رادار كشف الأعداء", 3)
local aimbotBtn = createButton("دائرة خطوط التصويب", 4)
local rpgStoreBtn = createButton("تخزين أر بي جي تلقائيا", 5)

-- شريط حجم الدائرة
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 240, 0, 45)
sliderFrame.BackgroundTransparency = 1
sliderFrame.LayoutOrder = 6
sliderFrame.Parent = scrollFrame

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 18)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "🔘 حجم الدائرة: " .. fovRadius
sliderLabel.TextColor3 = Color3.fromRGB(200, 180, 220)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 12
sliderLabel.Parent = sliderFrame

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(1, 0, 0, 8)
sliderBar.Position = UDim2.new(0, 0, 0, 28)
sliderBar.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
sliderBar.Parent = sliderFrame
local sliderBarCorner = Instance.new("UICorner")
sliderBarCorner.CornerRadius = UDim.new(1, 0)
sliderBarCorner.Parent = sliderBar

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 20, 0, 20)
sliderButton.Position = UDim2.new(0.3, -10, 0.5, -10)
sliderButton.BackgroundColor3 = Color3.fromRGB(200, 150, 255)
sliderButton.Text = ""
sliderButton.Parent = sliderBar
local sliderBtnCorner = Instance.new("UICorner")
sliderBtnCorner.CornerRadius = UDim.new(1, 0)
sliderBtnCorner.Parent = sliderButton

-- دائرة التصويب
local fovCircleGui = Instance.new("Frame")
fovCircleGui.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircleGui.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
fovCircleGui.BackgroundTransparency = 1
fovCircleGui.Visible = false
fovCircleGui.Parent = screenGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(160, 90, 255)
fovStroke.Thickness = 2
fovStroke.Parent = fovCircleGui

local fovCornerInstance = Instance.new("UICorner")
fovCornerInstance.CornerRadius = UDim.new(1, 0)
fovCornerInstance.Parent = fovCircleGui

-- [0] شاشة الترحيب
local welcomeGui = Instance.new("ScreenGui")
welcomeGui.Name = "WelcomeGui"
welcomeGui.ResetOnSpawn = false
welcomeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
welcomeGui.Parent = localPlayer:WaitForChild("PlayerGui")

local welcomeFrame = Instance.new("Frame")
welcomeFrame.Size = UDim2.new(0, 350, 0, 220)
welcomeFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
welcomeFrame.BackgroundColor3 = Color3.fromRGB(22, 11, 36)
welcomeFrame.BorderSizePixel = 0
welcomeFrame.ZIndex = 10
welcomeFrame.Parent = welcomeGui

local welcomeCorner = Instance.new("UICorner")
welcomeCorner.CornerRadius = UDim.new(0, 20)
welcomeCorner.Parent = welcomeFrame

local welcomeStroke = Instance.new("UIStroke")
welcomeStroke.Color = Color3.fromRGB(130, 70, 210)
welcomeStroke.Thickness = 2
welcomeStroke.Parent = welcomeFrame

local welcomeTitle = Instance.new("TextLabel")
welcomeTitle.Size = UDim2.new(1, 0, 0, 40)
welcomeTitle.Position = UDim2.new(0, 0, 0, 20)
welcomeTitle.BackgroundTransparency = 1
welcomeTitle.Text = "⚡ PURPLE HUB"
welcomeTitle.TextColor3 = Color3.fromRGB(240, 200, 255)
welcomeTitle.Font = Enum.Font.GothamBold
welcomeTitle.TextSize = 28
welcomeTitle.ZIndex = 10
welcomeTitle.Parent = welcomeFrame

local welcomeSub = Instance.new("TextLabel")
welcomeSub.Size = UDim2.new(1, 0, 0, 30)
welcomeSub.Position = UDim2.new(0, 0, 0, 70)
welcomeSub.BackgroundTransparency = 1
welcomeSub.Text = "RTA Server"
welcomeSub.TextColor3 = Color3.fromRGB(200, 160, 255)
welcomeSub.Font = Enum.Font.Gotham
welcomeSub.TextSize = 18
welcomeSub.ZIndex = 10
welcomeSub.Parent = welcomeFrame

local welcomeDiscord = Instance.new("TextLabel")
welcomeDiscord.Size = UDim2.new(1, 0, 0, 30)
welcomeDiscord.Position = UDim2.new(0, 0, 0, 110)
welcomeDiscord.BackgroundTransparency = 1
welcomeDiscord.Text = "discord.gg/Hh2zAXjCqz"
welcomeDiscord.TextColor3 = Color3.fromRGB(180, 140, 255)
welcomeDiscord.Font = Enum.Font.Gotham
welcomeDiscord.TextSize = 16
welcomeDiscord.ZIndex = 10
welcomeDiscord.Parent = welcomeFrame

local welcomeClose = Instance.new("TextButton")
welcomeClose.Size = UDim2.new(0, 100, 0, 35)
welcomeClose.Position = UDim2.new(0.5, -50, 0, 160)
welcomeClose.BackgroundColor3 = Color3.fromRGB(80, 30, 150)
welcomeClose.Text = "موافق"
welcomeClose.TextColor3 = Color3.fromRGB(255, 255, 255)
welcomeClose.Font = Enum.Font.GothamBold
welcomeClose.TextSize = 16
welcomeClose.ZIndex = 10
welcomeClose.Parent = welcomeFrame
local welcomeCloseCorner = Instance.new("UICorner")
welcomeCloseCorner.CornerRadius = UDim.new(0, 10)
welcomeCloseCorner.Parent = welcomeClose

local function closeWelcome()
    if welcomeGui and welcomeGui.Parent then
        welcomeGui:Destroy()
    end
end

welcomeClose.MouseButton1Click:Connect(closeWelcome)
task.delay(6, closeWelcome)

-- [2] فتح وإغلاق الهاتف
toggleMenuBtn.MouseButton1Click:Connect(function()
    if draggingToggle then return end
    isMenuOpen = not isMenuOpen
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if isMenuOpen then
        phoneFrame.Visible = true
        tweenService:Create(phoneFrame, tweenInfo, {Size = UDim2.new(0, 380, 0, 380), BackgroundTransparency = 0}):Play()
        toggleMenuBtn.Text = "✕"
    else
        local tween = tweenService:Create(phoneFrame, tweenInfo, {Size = UDim2.new(0, 380, 0, 0), BackgroundTransparency = 1})
        tween:Play()
        toggleMenuBtn.Text = "☰"
        tween.Completed:Connect(function() if not isMenuOpen then phoneFrame.Visible = false end end)
    end
end)

-- [3] شريط التحكم بحجم الدائرة
local dragging = false
sliderButton.MouseButton1Down:Connect(function() dragging = true end)
userInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

userInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local barAbsolutePosition = sliderBar.AbsolutePosition
        local barAbsoluteSize = sliderBar.AbsoluteSize
        local inputPosition = input.Position.X
        local percentage = math.clamp((inputPosition - barAbsolutePosition.X) / barAbsoluteSize.X, 0, 1)
        
        sliderButton.Position = UDim2.new(percentage, -10, 0.5, -10)
        fovRadius = math.floor(30 + (percentage * 120))
        sliderLabel.Text = "🔘 حجم الدائرة: " .. fovRadius
        
        fovCircleGui.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
        fovCircleGui.Position = UDim2.new(0.5, -fovRadius, 0.5, -fovRadius)
    end
end)

-- [4] الدوال الأساسية
local function getSafeZone()
    local safeZonesFolder = workspace:FindFirstChild("SafeZones")
    if safeZonesFolder then
        local zones = safeZonesFolder:GetChildren()
        if #zones >= 5 then return zones[5] end
    end
    return nil
end

-- ============== قتل أقرب لاعبين ==============
local function killNearestPlayers()
    local char = localPlayer.Character
    if not char then return end
    local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local targets = {}
    for _, p in pairs(players:GetPlayers()) do
        if p ~= localPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
            local tChar = p.Character
            if tChar.Humanoid.Health > 0 then
                local dist = (humanoidRootPart.Position - tChar.HumanoidRootPart.Position).Magnitude
                table.insert(targets, {player = p, distance = dist})
            end
        end
    end

    if #targets == 0 then return end
    table.sort(targets, function(a, b) return a.distance < b.distance end)

    local nearestTargets = {}
    for i = 1, math.min(2, #targets) do
        table.insert(nearestTargets, targets[i].player)
    end

    local sniper = char:FindFirstChild("Sniper") or localPlayer.Backpack:FindFirstChild("Sniper")
    if not sniper then return end
    if sniper.Parent == localPlayer.Backpack then
        char.Humanoid:EquipTool(sniper)
        task.wait(0.1)
    end

    for _, p in pairs(nearestTargets) do
        if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local hitPart = p.Character:FindFirstChild("HumanoidRootPart")
            if hitPart then
                task.spawn(function()
                    weaponHitEvent:FireServer(sniper, {
                        p = hitPart.Position,
                        pid = 1,
                        part = hitPart,
                        d = 10,
                        maxDist = 99999,
                        h = p.Character.Humanoid,
                        m = Enum.Material.Plastic,
                        n = Vector3.new(0, 1, 0),
                        t = 0,
                        sid = 24
                    })
                end)
            end
        end
    end
end

killNearestBtn.MouseButton1Click:Connect(function()
    isKillNearestActive = not isKillNearestActive
    if isKillNearestActive then
        killNearestBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 220)
        killNearestBtn.Text = "قتل أقرب لاعبين : ON"
        killLoop = task.spawn(function()
            while isKillNearestActive do
                killNearestPlayers()
                task.wait(0.25)
            end
        end)
    else
        if killLoop then task.cancel(killLoop) end
        killNearestBtn.BackgroundColor3 = Color3.fromRGB(35, 18, 60)
        killNearestBtn.Text = "قتل أقرب لاعبين : OFF"
    end
end)

-- ============== تجميع الفلوس الذكي ==============
local cryAnimationId = "rbxassetid://507771019"

local function playCryAnimation()
    local char = localPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 5)
    if not animator then return end

    if cashAnimationTrack then
        cashAnimationTrack:Stop()
        cashAnimationTrack = nil
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = cryAnimationId
    local track = animator:LoadAnimation(animation)
    track.Looped = true
    track:Play()
    cashAnimationTrack = track
end

local function stopCryAnimation()
    if cashAnimationTrack then
        cashAnimationTrack:Stop()
        cashAnimationTrack = nil
    end
end

local function collectCash()
    local char = localPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local handle = nil
    for _, object in pairs(workspace:GetChildren()) do
        local h = object:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then
            handle = h
            break
        end
    end

    if handle then
        if not cashAnimationTrack or not cashAnimationTrack.IsPlaying then
            playCryAnimation()
        end
        hrp.CFrame = handle.CFrame * CFrame.new(0, -3, 0)
    else
        local safeZone = getSafeZone()
        if safeZone and safeZone:IsA("BasePart") then
            hrp.CFrame = safeZone.CFrame + Vector3.new(0, 3, 0)
        end
        stopCryAnimation()
    end
end

farmCashBtn.MouseButton1Click:Connect(function()
    isCollectingCash = not isCollectingCash
    if isCollectingCash then
        farmCashBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 220)
        farmCashBtn.Text = "تجميع الفلوس ذكي : ON"
        cashLoop = task.spawn(function()
            while isCollectingCash do
                collectCash()
                task.wait(0.1)
            end
        end)
        playCryAnimation()
    else
        if cashLoop then task.cancel(cashLoop) end
        stopCryAnimation()
        farmCashBtn.BackgroundColor3 = Color3.fromRGB(35, 18, 60)
        farmCashBtn.Text = "تجميع الفلوس ذكي : OFF"
        
        local char = localPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local safeZone = getSafeZone()
        if hrp and safeZone and safeZone:IsA("BasePart") then
            hrp.CFrame = safeZone.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- ============== تخزين أر بي جي تلقائيا (الجزء المصلح) ==============
local function autoStoreRpg()
    local char = localPlayer.Character
    if not char then return end
    
    local rpg = char:FindFirstChild("RPG") or localPlayer.Backpack:FindFirstChild("RPG")
    if rpg then
        -- استدعاء السيرفر لتخزين الـ RPG في الانفنتوري
        storeItemRemote:FireServer(rpg)
    end
end

rpgStoreBtn.MouseButton1Click:Connect(function()
    isRpgStoreActive = not isRpgStoreActive
    if isRpgStoreActive then
        rpgStoreBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 220)
        rpgStoreBtn.Text = "تخزين أر بي جي تلقائيا : ON"
        rpgStoreLoop = task.spawn(function()
            while isRpgStoreActive do
                autoStoreRpg()
                task.wait(1) -- فحص كل ثانية لتجنب الضغط العالي على السيرفر
            end
        end)
    else
        if rpgStoreLoop then task.cancel(rpgStoreLoop) end
        rpgStoreBtn.BackgroundColor3 = Color3.fromRGB(35, 18, 60)
        rpgStoreBtn.Text = "تخزين أر بي جي تلقائيا : OFF"
    end
end)
