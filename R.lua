-- ╔══════════════════════════════════════╗
-- ║       PURPLE HUB V3 - RTA Server     ║
-- ║     حقوق محفوظة لسيرفر RTA           ║
-- ╚══════════════════════════════════════╝

local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local DISCORD_LINK = "discord.gg/RTA"

-- ══════════════════════════════════════
-- [أدوات مساعدة]
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

-- ══════════════════════════════════════
-- [ScreenGui الرئيسية]
-- ══════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PurpleHubV3"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════
-- [1] شاشة الترحيب (بدون إيموجي)
-- ══════════════════════════════════════
local splashBG = Instance.new("Frame")
splashBG.Size = UDim2.new(1, 0, 1, 0)
splashBG.Position = UDim2.new(0, 0, 0, 0)
splashBG.BackgroundColor3 = Color3.fromRGB(8, 3, 20)
splashBG.ZIndex = 100
splashBG.Parent = screenGui

addGradient(splashBG,
    Color3.fromRGB(30, 10, 70),
    Color3.fromRGB(5, 2, 15),
    160
)

-- نجوم متحركة في الخلفية
for i = 1, 40 do
    local star = Instance.new("Frame")
    star.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(200, 180, 255)
    star.BackgroundTransparency = math.random(40, 80) / 100
    star.BorderSizePixel = 0
    star.ZIndex = 101
    star.Parent = splashBG
    addCorner(star, 99)

    task.spawn(function()
        while star.Parent do
            tween(star, math.random(10, 25) / 10, {BackgroundTransparency = math.random(60, 95) / 100})
            task.wait(math.random(10, 30) / 10)
        end
    end)
end

-- حلقة ضوئية كبيرة
local glowRing = Instance.new("Frame")
glowRing.Size = UDim2.new(0, 260, 0, 260)
glowRing.Position = UDim2.new(0.5, -130, 0.5, -200)
glowRing.BackgroundTransparency = 1
glowRing.ZIndex = 102
glowRing.Parent = splashBG
addCorner(glowRing, 130)
addStroke(glowRing, Color3.fromRGB(160, 100, 255), 3, 0.3)

local glowRing2 = Instance.new("Frame")
glowRing2.Size = UDim2.new(0, 210, 0, 210)
glowRing2.Position = UDim2.new(0.5, -105, 0.5, -175)
glowRing2.BackgroundTransparency = 1
glowRing2.ZIndex = 102
glowRing2.Parent = splashBG
addCorner(glowRing2, 105)
addStroke(glowRing2, Color3.fromRGB(200, 150, 255), 2, 0.5)

-- أيقونة وسط (بدون إيموجي، سنضع دائرة فارغة أو لا شيء، لكن حفاظاً على التصميم نضع نقطة)
local splashIcon = Instance.new("TextLabel")
splashIcon.Size = UDim2.new(0, 100, 0, 100)
splashIcon.Position = UDim2.new(0.5, -50, 0.5, -195)
splashIcon.BackgroundTransparency = 1
splashIcon.Text = ""  -- تم إزالة الإيموجي
splashIcon.TextSize = 62
splashIcon.Font = Enum.Font.GothamBold
splashIcon.ZIndex = 103
splashIcon.Parent = splashBG

-- اسم الهوب (بدون إيموجي)
local splashTitle = Instance.new("TextLabel")
splashTitle.Size = UDim2.new(0, 320, 0, 55)
splashTitle.Position = UDim2.new(0.5, -160, 0.5, -100)
splashTitle.BackgroundTransparency = 1
splashTitle.Text = "PURPLE HUB"
splashTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
splashTitle.Font = Enum.Font.GothamBold
splashTitle.TextSize = 38
splashTitle.ZIndex = 103
splashTitle.Parent = splashBG
addGradient(splashTitle,
    Color3.fromRGB(255, 230, 255),
    Color3.fromRGB(180, 120, 255),
    0
)

-- النسخة
local splashVersion = Instance.new("TextLabel")
splashVersion.Size = UDim2.new(0, 300, 0, 28)
splashVersion.Position = UDim2.new(0.5, -150, 0.5, -45)
splashVersion.BackgroundTransparency = 1
splashVersion.Text = "V 3.0  -  RTA Server Edition"
splashVersion.TextColor3 = Color3.fromRGB(180, 150, 230)
splashVersion.Font = Enum.Font.Gotham
splashVersion.TextSize = 15
splashVersion.ZIndex = 103
splashVersion.Parent = splashBG

-- شريط تحميل
local loadBarBG = Instance.new("Frame")
loadBarBG.Size = UDim2.new(0, 280, 0, 8)
loadBarBG.Position = UDim2.new(0.5, -140, 0.5, 10)
loadBarBG.BackgroundColor3 = Color3.fromRGB(30, 15, 60)
loadBarBG.ZIndex = 103
loadBarBG.Parent = splashBG
addCorner(loadBarBG, 6)

local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 0, 1, 0)
loadBar.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
loadBar.ZIndex = 104
loadBar.Parent = loadBarBG
addCorner(loadBar, 6)
addGradient(loadBar,
    Color3.fromRGB(200, 150, 255),
    Color3.fromRGB(100, 60, 200),
    0
)

local loadText = Instance.new("TextLabel")
loadText.Size = UDim2.new(0, 280, 0, 24)
loadText.Position = UDim2.new(0.5, -140, 0.5, 24)
loadText.BackgroundTransparency = 1
loadText.Text = "جار التحميل..."
loadText.TextColor3 = Color3.fromRGB(180, 150, 230)
loadText.Font = Enum.Font.Gotham
loadText.TextSize = 13
loadText.ZIndex = 103
loadText.Parent = splashBG

-- حقوق + ديسكورد (بدون إيموجي)
local splashRights = Instance.new("TextLabel")
splashRights.Size = UDim2.new(1, -20, 0, 22)
splashRights.Position = UDim2.new(0, 10, 1, -68)
splashRights.BackgroundTransparency = 1
splashRights.Text = "حقوق محفوظة لسيرفر RTA  |  " .. DISCORD_LINK
splashRights.TextColor3 = Color3.fromRGB(130, 100, 190)
splashRights.Font = Enum.Font.Gotham
splashRights.TextSize = 12
splashRights.ZIndex = 103
splashRights.Parent = splashBG

local splashDiscord = Instance.new("TextLabel")
splashDiscord.Size = UDim2.new(1, -20, 0, 22)
splashDiscord.Position = UDim2.new(0, 10, 1, -44)
splashDiscord.BackgroundTransparency = 1
splashDiscord.Text = "Discord: " .. DISCORD_LINK
splashDiscord.TextColor3 = Color3.fromRGB(150, 120, 220)
splashDiscord.Font = Enum.Font.GothamBold
splashDiscord.TextSize = 13
splashDiscord.ZIndex = 103
splashDiscord.Parent = splashBG

-- انيميشن تحميل (نصوص بدون إيموجي)
local loadingTexts = {
    "جار تحميل الوحدات...",
    "تهيئة الواجهة...",
    "الاتصال بالسيرفر...",
    "تحضير الأدوات...",
    "مرحباً بك في Purple Hub!"
}

task.spawn(function()
    for i, txt in ipairs(loadingTexts) do
        loadText.Text = txt
        local progress = i / #loadingTexts
        tween(loadBar, 0.5, {Size = UDim2.new(progress, 0, 1, 0)})
        task.wait(0.6)
    end
    task.wait(0.4)
    -- أنيميشن اختفاء
    tween(splashBG, 0.7, {BackgroundTransparency = 1})
    for _, obj in ipairs(splashBG:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("Frame") then
            if obj:IsA("TextLabel") then
                tween(obj, 0.5, {TextTransparency = 1})
            else
                tween(obj, 0.5, {BackgroundTransparency = 1})
            end
        end
    end
    task.wait(0.8)
    splashBG:Destroy()
end)

-- ══════════════════════════════════════
-- [2] الإطار الرئيسي
-- ══════════════════════════════════════
local phoneFrame = Instance.new("Frame")
phoneFrame.Size = UDim2.new(0, 370, 0, 520)
phoneFrame.Position = UDim2.new(0.5, -185, 0.5, -260)
phoneFrame.BackgroundColor3 = Color3.fromRGB(14, 7, 30)
phoneFrame.BorderSizePixel = 0
phoneFrame.ClipsDescendants = true
phoneFrame.Parent = screenGui
addCorner(phoneFrame, 28)
addGradient(phoneFrame,
    Color3.fromRGB(40, 20, 80),
    Color3.fromRGB(10, 5, 25),
    150
)

-- توهج خارجي
local outerGlow = Instance.new("Frame")
outerGlow.Size = UDim2.new(1, 20, 1, 20)
outerGlow.Position = UDim2.new(0, -10, 0, -10)
outerGlow.BackgroundTransparency = 1
outerGlow.ZIndex = phoneFrame.ZIndex - 1
outerGlow.Parent = phoneFrame
addCorner(outerGlow, 34)
addStroke(outerGlow, Color3.fromRGB(160, 100, 255), 5, 0.55)

-- شريط علوي ملون
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 70)
topBar.BackgroundColor3 = Color3.fromRGB(30, 15, 65)
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
topBar.Parent = phoneFrame
addGradient(topBar,
    Color3.fromRGB(70, 35, 140),
    Color3.fromRGB(20, 10, 50),
    90
)

-- خط زخرفي أسفل الشريط
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.Position = UDim2.new(0, 0, 0, 68)
topLine.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
topLine.BorderSizePixel = 0
topLine.ZIndex = 3
topLine.Parent = phoneFrame
addGradient(topLine,
    Color3.fromRGB(200, 150, 255),
    Color3.fromRGB(80, 40, 160),
    0
)

-- أيقونة العنوان (بدون إيموجي)
local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 40, 0, 40)
titleIcon.Position = UDim2.new(0, 16, 0, 14)
titleIcon.BackgroundTransparency = 1
titleIcon.Text = ""  -- إزالة الإيموجي
titleIcon.TextSize = 26
titleIcon.Font = Enum.Font.GothamBold
titleIcon.ZIndex = 3
titleIcon.Parent = phoneFrame

-- عنوان رئيسي
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 0, 30)
titleLabel.Position = UDim2.new(0, 56, 0, 11)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PURPLE HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 3
titleLabel.Parent = phoneFrame
addGradient(titleLabel,
    Color3.fromRGB(255, 230, 255),
    Color3.fromRGB(200, 150, 255),
    0
)

-- RTA Badge (بدون إيموجي)
local rtaBadge = Instance.new("Frame")
rtaBadge.Size = UDim2.new(0, 80, 0, 22)
rtaBadge.Position = UDim2.new(0, 56, 0, 43)
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
rtaText.ZIndex = 4
rtaText.Parent = rtaBadge

-- Discord زر صغير (بدون إيموجي)
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 90, 0, 26)
discordBtn.Position = UDim2.new(1, -106, 0, 40)
discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
discordBtn.Text = "Discord"
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 11
discordBtn.ZIndex = 3
discordBtn.Parent = phoneFrame
addCorner(discordBtn, 8)

discordBtn.MouseButton1Click:Connect(function()
    setclipboard(DISCORD_LINK)
    discordBtn.Text = "تم النسخ!"
    task.wait(2)
    discordBtn.Text = "Discord"
end)

discordBtn.MouseEnter:Connect(function()
    tween(discordBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(110, 125, 255)})
end)
discordBtn.MouseLeave:Connect(function()
    tween(discordBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(88, 101, 242)})
end)

-- ══════════════════════════════════════
-- [3] منطقة التمرير
-- ══════════════════════════════════════
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -100)
scrollFrame.Position = UDim2.new(0, 5, 0, 80)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 255)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = phoneFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 10)
listPadding.PaddingBottom = UDim.new(0, 12)
listPadding.Parent = scrollFrame

-- ══════════════════════════════════════
-- [4] دالة إنشاء الفئات (بدون إيموجي)
-- ══════════════════════════════════════
local function createCategoryLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 320, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text  -- النص بدون إيموجي
    lbl.TextColor3 = Color3.fromRGB(180, 140, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order
    lbl.Parent = scrollFrame
    return lbl
end

-- ══════════════════════════════════════
-- [5] دالة إنشاء الأزرار (نص = "5" بدون وظائف)
-- ══════════════════════════════════════
local function createButton(order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 320, 0, 52)
    btn.BackgroundColor3 = Color3.fromRGB(25, 12, 52)
    btn.Text = "5"  -- تم تغيير الاسم إلى 5
    btn.LayoutOrder = order
    btn.AutoButtonColor = false
    btn.Parent = scrollFrame
    addCorner(btn, 14)
    addStroke(btn, Color3.fromRGB(80, 50, 150), 1.5)
    addGradient(btn,
        Color3.fromRGB(45, 22, 90),
        Color3.fromRGB(18, 9, 40),
        135
    )

    -- لا حاجة لأيقونة أو نص إضافي لأن النص هو "5"

    local stroke = btn:FindFirstChildOfClass("UIStroke")

    btn.MouseEnter:Connect(function()
        tween(btn, 0.18, {BackgroundColor3 = Color3.fromRGB(55, 28, 105)})
        if stroke then tween(stroke, 0.18, {Color = Color3.fromRGB(200, 150, 255)}) end
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.18, {BackgroundColor3 = Color3.fromRGB(25, 12, 52)})
        if stroke then tween(stroke, 0.18, {Color = Color3.fromRGB(80, 50, 150)}) end
    end)

    -- لا يوجد callback عند الضغط
    btn.MouseButton1Click:Connect(function()
        -- وميض فقط بدون وظيفة
        tween(btn, 0.08, {BackgroundColor3 = Color3.fromRGB(100, 55, 200)})
        task.wait(0.1)
        tween(btn, 0.2, {BackgroundColor3 = Color3.fromRGB(25, 12, 52)})
    end)

    return btn
end

-- ══════════════════════════════════════
-- [6] دالة إنشاء مفتاح تبديل Toggle (نص = "5"، بدون وظيفة)
-- ══════════════════════════════════════
local function createToggle(order)
    local state = false

    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 320, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(25, 12, 52)
    row.LayoutOrder = order
    row.Parent = scrollFrame
    addCorner(row, 14)
    addStroke(row, Color3.fromRGB(80, 50, 150), 1.5)
    addGradient(row,
        Color3.fromRGB(45, 22, 90),
        Color3.fromRGB(18, 9, 40),
        135
    )

    -- النص "5" فقط
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)  -- محاذاة لليسار
    label.BackgroundTransparency = 1
    label.Text = "5"
    label.TextColor3 = Color3.fromRGB(230, 210, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = row.ZIndex + 1
    label.Parent = row

    -- Toggle track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 44, 0, 24)
    track.Position = UDim2.new(1, -54, 0.5, -12)
    track.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
    track.ZIndex = row.ZIndex + 1
    track.Parent = row
    addCorner(track, 12)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = UDim2.new(0, 3, 0.5, -9)
    thumb.BackgroundColor3 = Color3.fromRGB(160, 120, 220)
    thumb.ZIndex = row.ZIndex + 2
    thumb.Parent = track
    addCorner(thumb, 9)

    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = row.ZIndex + 3
    clickArea.Parent = row

    clickArea.MouseButton1Click:Connect(function()
        state = not state
        if state then
            tween(track, 0.2, {BackgroundColor3 = Color3.fromRGB(120, 70, 220)})
            tween(thumb, 0.2, {Position = UDim2.new(0, 23, 0.5, -9), BackgroundColor3 = Color3.fromRGB(220, 190, 255)})
        else
            tween(track, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 30, 80)})
            tween(thumb, 0.2, {Position = UDim2.new(0, 3, 0.5, -9), BackgroundColor3 = Color3.fromRGB(160, 120, 220)})
        end
        -- لا يوجد callback، المفتاح للشكل فقط
    end)

    return row
end

-- ══════════════════════════════════════
-- [7] إضافة العناصر (جميعها نصوص "5" وبدون وظائف)
-- ══════════════════════════════════════

-- معلومات اللاعب (بدون إيموجي)
local infoCard = Instance.new("Frame")
infoCard.Size = UDim2.new(0, 320, 0, 58)
infoCard.BackgroundColor3 = Color3.fromRGB(35, 18, 70)
infoCard.LayoutOrder = 1
infoCard.Parent = scrollFrame
addCorner(infoCard, 14)
addStroke(infoCard, Color3.fromRGB(120, 80, 200), 1.5)
addGradient(infoCard,
    Color3.fromRGB(60, 30, 110),
    Color3.fromRGB(25, 12, 55),
    135
)

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -16, 1, 0)
infoText.Position = UDim2.new(0, 14, 0, 0)
infoText.BackgroundTransparency = 1
infoText.Text = localPlayer.DisplayName .. "  -  " .. localPlayer.Name
infoText.TextColor3 = Color3.fromRGB(220, 195, 255)
infoText.Font = Enum.Font.GothamBold
infoText.TextSize = 13
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.ZIndex = infoCard.ZIndex + 1
infoText.Parent = infoCard

local infoSub = Instance.new("TextLabel")
infoSub.Size = UDim2.new(1, -16, 0, 20)
infoSub.Position = UDim2.new(0, 14, 0, 32)
infoSub.BackgroundTransparency = 1
infoSub.Text = "Purple Hub  -  RTA Server"
infoSub.TextColor3 = Color3.fromRGB(160, 130, 210)
infoSub.Font = Enum.Font.Gotham
infoSub.TextSize = 11
infoSub.TextXAlignment = Enum.TextXAlignment.Left
infoSub.ZIndex = infoCard.ZIndex + 1
infoSub.Parent = infoCard

-- فئات بدون إيموجي
createCategoryLabel("الادوات", 2)

-- أزرار بلا وظائف والنص "5"
createButton(3)
createButton(4)
createButton(5)
createButton(6)

createCategoryLabel("خيارات متقدمة", 7)

createToggle(8)
createToggle(9)

createButton(10)  -- زر إعادة التشغيل الأصلي، الآن "5" وبدون وظيفة

-- فاصل سفلي
createCategoryLabel("", 11)

local creditCard = Instance.new("Frame")
creditCard.Size = UDim2.new(0, 320, 0, 44)
creditCard.BackgroundColor3 = Color3.fromRGB(20, 10, 45)
creditCard.LayoutOrder = 12
creditCard.Parent = scrollFrame
addCorner(creditCard, 12)
addStroke(creditCard, Color3.fromRGB(80, 50, 130), 1)

local creditText = Instance.new("TextLabel")
creditText.Size = UDim2.new(1, 0, 1, 0)
creditText.BackgroundTransparency = 1
creditText.Text = "RTA Server  |  discord.gg/RTA"
creditText.TextColor3 = Color3.fromRGB(120, 90, 180)
creditText.Font = Enum.Font.Gotham
creditText.TextSize = 11
creditText.ZIndex = creditCard.ZIndex + 1
creditText.Parent = creditCard

-- ══════════════════════════════════════
-- [8] زر الفتح / الإغلاق (بدون إيموجي)
-- ══════════════════════════════════════
local isMenuOpen = true

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 52, 0, 52)
toggleBtn.Position = UDim2.new(1, -68, 1, -70)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 100)
toggleBtn.Text = "X"  -- بدلاً من ✕
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 22
toggleBtn.TextColor3 = Color3.fromRGB(230, 200, 255)
toggleBtn.ZIndex = 50
toggleBtn.Parent = screenGui
addCorner(toggleBtn, 99)
addStroke(toggleBtn, Color3.fromRGB(160, 110, 255), 2.5)

-- توهج خلف الزر
local btnGlow = Instance.new("Frame")
btnGlow.Size = UDim2.new(1, 16, 1, 16)
btnGlow.Position = UDim2.new(0, -8, 0, -8)
btnGlow.BackgroundTransparency = 1
btnGlow.ZIndex = 49
btnGlow.Parent = toggleBtn
addCorner(btnGlow, 99)
addStroke(btnGlow, Color3.fromRGB(160, 100, 255), 3, 0.7)

toggleBtn.MouseEnter:Connect(function()
    tween(toggleBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(80, 45, 155)})
end)
toggleBtn.MouseLeave:Connect(function()
    tween(toggleBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(50, 25, 100)})
end)

-- السحب
local dragging = false
local dragStart, startPos2

toggleBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos2 = toggleBtn.Position
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if dragging and (
        inp.UserInputType == Enum.UserInputType.MouseMovement
     or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        toggleBtn.Position = UDim2.new(
            startPos2.X.Scale, startPos2.X.Offset + delta.X,
            startPos2.Y.Scale, startPos2.Y.Offset + delta.Y
        )
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    if dragging then return end
    isMenuOpen = not isMenuOpen
    local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    if isMenuOpen then
        phoneFrame.Visible = true
        phoneFrame.Size = UDim2.new(0, 370, 0, 0)
        TweenService:Create(phoneFrame, ti, {Size = UDim2.new(0, 370, 0, 520)}):Play()
        toggleBtn.Text = "X"
    else
        local t = TweenService:Create(phoneFrame, ti, {Size = UDim2.new(0, 370, 0, 0)})
        t:Play()
        toggleBtn.Text = "="  -- رمز بسيط بدلاً من ☰
        t.Completed:Connect(function()
            if not isMenuOpen then phoneFrame.Visible = false end
        end)
    end
end)

-- ══════════════════════════════════════
-- [9] سحب الإطار الرئيسي
-- ══════════════════════════════════════
local frameDragging = false
local frameDragStart, frameStartPos

topBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        frameDragging = true
        frameDragStart = inp.Position
        frameStartPos = phoneFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        frameDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(inp)
    if frameDragging and (
        inp.UserInputType == Enum.UserInputType.MouseMovement
     or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - frameDragStart
        phoneFrame.Position = UDim2.new(
            frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ══════════════════════════════════════
-- [10] وميض التوهج المستمر
-- ══════════════════════════════════════
task.spawn(function()
    while phoneFrame.Parent do
        tween(outerGlow:FindFirstChildOfClass("UIStroke"), 2.5, {Transparency = 0.3})
        task.wait(2.5)
        tween(outerGlow:FindFirstChildOfClass("UIStroke"), 2.5, {Transparency = 0.7})
        task.wait(2.5)
    end
end)

print("✅ Purple Hub V3 | RTA Server - Loaded (Clean Version)")
