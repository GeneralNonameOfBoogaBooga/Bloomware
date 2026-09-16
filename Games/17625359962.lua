-- ==============================================================================
-- BLOOMWARE | Steal An Egg — Key-Protected Build (strict key, no close button, auto jump)
-- ==============================================================================

-- ==============================================================================
-- ЧАСТЬ 1: KEY SYSTEM (Junkie) — строгая проверка, без KEYLESS
-- ==============================================================================
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "BW Egg"
Junkie.identifier = "1072682"
Junkie.provider = "BW Egg"

-- Принудительно убираем любые следы предыдущей key-системы
pcall(function()
    local cg = game:GetService("CoreGui")
    for _, g in ipairs(cg:GetChildren()) do
        if g.Name == "JunkieKeySystemUI" then g:Destroy() end
    end
end)

local SCRIPT_KEY = (function()
    getgenv().UI_CLOSED = false
    getgenv().SCRIPT_KEY = nil
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local Lighting = game:GetService("Lighting")

    local Colors = {
        background = Color3.fromRGB(13, 17, 23),
        surface = Color3.fromRGB(22, 27, 34),
        surfaceLight = Color3.fromRGB(30, 36, 44),
        primary = Color3.fromRGB(88, 166, 255),
        primaryDark = Color3.fromRGB(58, 136, 225),
        primaryGlow = Color3.fromRGB(120, 180, 255),
        accent = Color3.fromRGB(136, 87, 224),
        success = Color3.fromRGB(47, 183, 117),
        successDark = Color3.fromRGB(37, 153, 97),
        successGlow = Color3.fromRGB(67, 203, 137),
        error = Color3.fromRGB(248, 81, 73),
        textPrimary = Color3.fromRGB(230, 237, 243),
        textSecondary = Color3.fromRGB(139, 148, 158),
        textMuted = Color3.fromRGB(110, 118, 129),
        border = Color3.fromRGB(48, 54, 61),
        borderLight = Color3.fromRGB(63, 71, 79),
        glass = Color3.fromRGB(255, 255, 255),
        neonBlue = Color3.fromRGB(0, 229, 255),
        neonPurple = Color3.fromRGB(187, 134, 252)
    }

    local function hasFileSystemSupport()
        local hasWritefile = pcall(function() return type(writefile) == "function" end)
        local hasReadfile = pcall(function() return type(readfile) == "function" end)
        local hasIsfile = pcall(function() return type(isfile) == "function" end)
        return hasWritefile and hasReadfile and hasIsfile
    end

    local fileSystemSupported = hasFileSystemSupport()

    local function saveVerifiedKey(key)
        if not fileSystemSupported then return false end
        local ok = pcall(function() writefile("verified_key.txt", key) end)
        return ok
    end

    local function loadVerifiedKey()
        if not fileSystemSupported then return nil end
        local ok, content = pcall(function() return readfile("verified_key.txt") end)
        if not ok or not content then return nil end
        return content
    end

    local function clearSavedKey()
        if not fileSystemSupported then return false end
        local ok = pcall(function() delfile("verified_key.txt") end)
        return ok
    end

    local function loadUIFactory()
        return function(Colors, Players, TweenService, UserInputService, Lighting)
            local IconAssets = {
                shield = 84528813312016,
                x = 73070135088117,
                key = 128426502701541,
                link = 73034596791310,
                check = 83827110621355
            }

            local function createIconImage(name, size, color)
                local id = IconAssets[name]
                if id then
                    local img = Instance.new("ImageLabel")
                    img.BackgroundTransparency = 1
                    img.Size = UDim2.new(0, size or 18, 0, size or 18)
                    img.Image = "rbxassetid://" .. tostring(id)
                    img.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
                    img.ScaleType = Enum.ScaleType.Fit
                    if img:IsA("ImageLabel") and img.ResampleMode ~= nil then
                        img.ResampleMode = Enum.ResamplerMode.Default
                    end
                    return img
                end
                local lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(0, size or 18, 0, size or 18)
                lbl.TextScaled = true
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
                lbl.Text = ({ shield = "🛡️", key = "🔑", link = "🔗", x = "✕", check = "✓" })[name] or "🔘"
                return lbl
            end

            return function(self)
                if self.gui then self.gui:Destroy() end

                self.gui = Instance.new("ScreenGui")
                self.gui.Name = "JunkieKeySystemUI"
                self.gui.ResetOnSpawn = false
                self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                self.gui.IgnoreGuiInset = true

                local backdrop = Instance.new("Frame")
                backdrop.Name = "Backdrop"
                backdrop.Size = UDim2.new(1, 0, 1, 0)
                backdrop.Position = UDim2.new(0, 0, 0, 0)
                backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                backdrop.BackgroundTransparency = 0.4
                backdrop.BorderSizePixel = 0
                backdrop.Parent = self.gui

                local blur = Instance.new("BlurEffect")
                blur.Size = 16
                blur.Name = "JunkieUIBlur"
                blur.Parent = Lighting

                local container = Instance.new("Frame")
                container.Name = "Container"

                local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
                local viewportSize = workspace.CurrentCamera.ViewportSize

                if isMobile then
                    container.Size = UDim2.new(0.6, 0, 0, math.min(320, viewportSize.Y * 0.8))
                    container.Position = UDim2.new(0.5, 0, 0.5, 0)
                    container.AnchorPoint = Vector2.new(0.5, 0.5)
                else
                    container.Size = UDim2.new(0, 580, 0, 320)
                    container.Position = UDim2.new(0.5, 0, 0.5, 0)
                    container.AnchorPoint = Vector2.new(0.5, 0.5)
                end

                container.BackgroundColor3 = Colors.surface
                container.BorderSizePixel = 0
                container.Parent = backdrop
                container:SetAttribute("IsMobile", isMobile)

                local containerCorner = Instance.new("UICorner")
                containerCorner.CornerRadius = UDim.new(0, 14)
                containerCorner.Parent = container

                local containerStroke = Instance.new("UIStroke")
                containerStroke.Color = Colors.border
                containerStroke.Thickness = 1
                containerStroke.Transparency = 0.3
                containerStroke.Parent = container

                local shadow = Instance.new("Frame")
                shadow.Name = "Shadow"
                shadow.Size = UDim2.new(1, 40, 1, 40)
                shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
                shadow.AnchorPoint = Vector2.new(0.5, 0.5)
                shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                shadow.BackgroundTransparency = 0.7
                shadow.BorderSizePixel = 0
                shadow.ZIndex = 0
                shadow.Parent = backdrop

                local shadowCorner = Instance.new("UICorner")
                shadowCorner.CornerRadius = UDim.new(0, 18)
                shadowCorner.Parent = shadow

                local glowFrame = Instance.new("Frame")
                glowFrame.Name = "GlowEffect"
                glowFrame.Size = UDim2.new(1, 60, 1, 60)
                glowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
                glowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
                glowFrame.BackgroundColor3 = Colors.primary
                glowFrame.BackgroundTransparency = 0.95
                glowFrame.BorderSizePixel = 0
                glowFrame.ZIndex = -1
                glowFrame.Parent = backdrop

                local glowCorner = Instance.new("UICorner")
                glowCorner.CornerRadius = UDim.new(0, 30)
                glowCorner.Parent = glowFrame

                local glowTween = TweenService:Create(glowFrame,
                    TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                    {BackgroundTransparency = 0.9, Size = UDim2.new(1, 80, 1, 80)}
                )
                glowTween:Play()

                local glassOverlay = Instance.new("Frame")
                glassOverlay.Name = "GlassOverlay"
                glassOverlay.Size = UDim2.new(1, 0, 1, 0)
                glassOverlay.Position = UDim2.new(0, 0, 0, 0)
                glassOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                glassOverlay.BackgroundTransparency = 0.98
                glassOverlay.BorderSizePixel = 0
                glassOverlay.ZIndex = 1
                glassOverlay.Parent = container

                local glassCorner = Instance.new("UICorner")
                glassCorner.CornerRadius = UDim.new(0, 14)
                glassCorner.Parent = glassOverlay

                local glassGradient = Instance.new("UIGradient")
                glassGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
                }
                glassGradient.Rotation = 45
                glassGradient.Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 0.96),
                    NumberSequenceKeypoint.new(0.5, 0.98),
                    NumberSequenceKeypoint.new(1, 1)
                }
                glassGradient.Parent = glassOverlay

                local topBar = Instance.new("Frame")
                topBar.Name = "TopBar"
                topBar.Size = UDim2.new(1, 0, 0, 45)
                topBar.Position = UDim2.new(0, 0, 0, 0)
                topBar.BackgroundColor3 = Colors.background
                topBar.BorderSizePixel = 0
                topBar.ZIndex = 10
                topBar.Parent = container

                local topBarCorner = Instance.new("UICorner")
                topBarCorner.CornerRadius = UDim.new(0, 14)
                topBarCorner.Parent = topBar

                local topBarFix = Instance.new("Frame")
                topBarFix.Size = UDim2.new(1, 0, 0, 10)
                topBarFix.Position = UDim2.new(0, 0, 1, -10)
                topBarFix.BackgroundColor3 = Colors.background
                topBarFix.BorderSizePixel = 0
                topBarFix.Parent = topBar

                local brandLogo = Instance.new("Frame")
                brandLogo.Name = "BrandLogo"
                brandLogo.Size = UDim2.new(0, 200, 1, 0)
                brandLogo.Position = UDim2.new(0, 20, 0, 0)
                brandLogo.BackgroundTransparency = 1
                brandLogo.ZIndex = 11
                brandLogo.Parent = topBar

                local brandLogoIcon = createIconImage("shield", 20, Colors.primary)
                brandLogoIcon.AnchorPoint = Vector2.new(0, 0.5)
                brandLogoIcon.Position = UDim2.new(0, 0, 0.5, 0)
                brandLogoIcon.ZIndex = 11
                brandLogoIcon.Parent = brandLogo

                local brandLogoText = Instance.new("TextLabel")
                brandLogoText.BackgroundTransparency = 1
                brandLogoText.Size = UDim2.new(1, -30, 1, 0)
                brandLogoText.Position = UDim2.new(0, 28, 0, 0)
                brandLogoText.Text = "Junkie Key System"
                brandLogoText.TextColor3 = Colors.textPrimary
                brandLogoText.TextSize = 15
                brandLogoText.TextXAlignment = Enum.TextXAlignment.Left
                brandLogoText.Font = Enum.Font.GothamSemibold
                brandLogoText.ZIndex = 11
                brandLogoText.Parent = brandLogo

                -- Кнопка закрытия убрана
                local closeButton = Instance.new("Frame")
                closeButton.Name = "CloseButton"
                closeButton.Size = UDim2.new(0, 0, 0, 0)
                closeButton.Position = UDim2.new(1, -40, 0.5, 0)
                closeButton.BackgroundTransparency = 1
                closeButton.Visible = false
                closeButton.ZIndex = 0
                closeButton.Parent = topBar

                local contentArea = Instance.new("Frame")
                contentArea.Name = "ContentArea"
                contentArea.Size = UDim2.new(1, -40, 1, -65)
                contentArea.Position = UDim2.new(0, 20, 0, 55)
                contentArea.BackgroundTransparency = 1
                contentArea.Parent = container

                local titleSection = Instance.new("Frame")
                titleSection.Name = "TitleSection"
                titleSection.Size = UDim2.new(1, 0, 0, 85)
                titleSection.Position = UDim2.new(0, 0, 0, 5)
                titleSection.BackgroundTransparency = 1
                titleSection.Parent = contentArea

                local iconFrame = Instance.new("Frame")
                iconFrame.Name = "IconFrame"
                iconFrame.Size = UDim2.new(0, 52, 0, 52)
                iconFrame.Position = UDim2.new(0.5, -26, 0, 0)
                iconFrame.BackgroundColor3 = Colors.surfaceLight
                iconFrame.BorderSizePixel = 0
                iconFrame.Parent = titleSection

                local iconCorner = Instance.new("UICorner")
                iconCorner.CornerRadius = UDim.new(0, 12)
                iconCorner.Parent = iconFrame

                local iconGradient = Instance.new("UIGradient")
                iconGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Colors.primary),
                    ColorSequenceKeypoint.new(0.5, Colors.primaryGlow),
                    ColorSequenceKeypoint.new(1, Colors.accent)
                }
                iconGradient.Rotation = 45
                iconGradient.Parent = iconFrame

                local iconStroke = Instance.new("UIStroke")
                iconStroke.Color = Colors.primary
                iconStroke.Thickness = 2
                iconStroke.Transparency = 0.5
                iconStroke.Parent = iconFrame

                local strokeGradient = Instance.new("UIGradient")
                strokeGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Colors.neonBlue),
                    ColorSequenceKeypoint.new(0.5, Colors.primary),
                    ColorSequenceKeypoint.new(1, Colors.neonPurple)
                }
                strokeGradient.Rotation = 0
                strokeGradient.Parent = iconStroke

                local strokeTween = TweenService:Create(strokeGradient,
                    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
                    {Rotation = 360}
                )
                strokeTween:Play()

                local mainIcon = createIconImage("shield", 26, Color3.fromRGB(255, 255, 255))
                mainIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                mainIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
                mainIcon.Parent = iconFrame

                local titleText = Instance.new("TextLabel")
                titleText.Name = "TitleText"
                titleText.Size = UDim2.new(1, 0, 0, 24)
                titleText.Position = UDim2.new(0, 0, 0, 58)
                titleText.BackgroundTransparency = 1
                titleText.Text = self.title
                titleText.TextColor3 = Colors.textPrimary
                titleText.TextSize = 17
                titleText.TextXAlignment = Enum.TextXAlignment.Center
                titleText.Font = Enum.Font.GothamBold
                titleText.Parent = titleSection

                local subtitleText = Instance.new("TextLabel")
                subtitleText.Name = "SubtitleText"
                subtitleText.Size = UDim2.new(1, 0, 0, 18)
                subtitleText.Position = UDim2.new(0, 0, 0, 82)
                subtitleText.BackgroundTransparency = 1
                subtitleText.Text = self.subtitle
                subtitleText.TextColor3 = Colors.textSecondary
                subtitleText.TextSize = 13
                subtitleText.TextXAlignment = Enum.TextXAlignment.Center
                subtitleText.Font = Enum.Font.Gotham
                subtitleText.Parent = titleSection

                local inputSection = Instance.new("Frame")
                inputSection.Name = "InputSection"
                inputSection.Size = UDim2.new(1, 0, 0, 46)
                inputSection.Position = UDim2.new(0, 0, 0, 115)
                inputSection.BackgroundColor3 = Colors.surfaceLight
                inputSection.BorderSizePixel = 0
                inputSection.Parent = contentArea

                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, 10)
                inputCorner.Parent = inputSection

                local inputStroke = Instance.new("UIStroke")
                inputStroke.Color = Colors.border
                inputStroke.Thickness = 1
                inputStroke.Transparency = 0.5
                inputStroke.Parent = inputSection

                local keyIcon = createIconImage("key", 18, Colors.primary)
                keyIcon.AnchorPoint = Vector2.new(0, 0.5)
                keyIcon.Position = UDim2.new(0, 14, 0.5, 0)
                keyIcon.Parent = inputSection

                local keyInput = Instance.new("TextBox")
                keyInput.Name = "KeyInput"
                keyInput.Size = UDim2.new(1, -50, 1, 0)
                keyInput.Position = UDim2.new(0, 40, 0, 0)
                keyInput.BackgroundTransparency = 1
                keyInput.PlaceholderText = "Enter your verification key"
                keyInput.PlaceholderColor3 = Colors.textMuted
                keyInput.Text = ""
                keyInput.TextColor3 = Colors.textPrimary
                keyInput.TextSize = 14
                keyInput.TextXAlignment = Enum.TextXAlignment.Left
                keyInput.TextTruncate = Enum.TextTruncate.AtEnd
                keyInput.Font = Enum.Font.Gotham
                keyInput.ClearTextOnFocus = false
                keyInput.Parent = inputSection

                local buttonSection = Instance.new("Frame")
                buttonSection.Name = "ButtonSection"
                buttonSection.Size = UDim2.new(1, 0, 0, 40)
                buttonSection.Position = UDim2.new(0, 0, 0, 175)
                buttonSection.BackgroundTransparency = 1
                buttonSection.Parent = contentArea

                local getLinkButton = Instance.new("TextButton")
                getLinkButton.Name = "GetLinkButton"
                getLinkButton.Size = UDim2.new(0.48, 0, 1, 0)
                getLinkButton.Position = UDim2.new(0, 0, 0, 0)
                getLinkButton.BackgroundColor3 = Colors.primary
                getLinkButton.Text = ""
                getLinkButton.Font = Enum.Font.GothamSemibold
                getLinkButton.TextSize = 14
                getLinkButton.BorderSizePixel = 0
                getLinkButton.AutoButtonColor = false
                getLinkButton.Parent = buttonSection

                local getLinkCorner = Instance.new("UICorner")
                getLinkCorner.CornerRadius = UDim.new(0, 10)
                getLinkCorner.Parent = getLinkButton

                local getLinkGradient = Instance.new("UIGradient")
                getLinkGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Colors.primary),
                    ColorSequenceKeypoint.new(1, Colors.primaryDark)
                }
                getLinkGradient.Rotation = 90
                getLinkGradient.Parent = getLinkButton

                local getLinkGlow = Instance.new("UIStroke")
                getLinkGlow.Color = Colors.primaryGlow
                getLinkGlow.Thickness = 0
                getLinkGlow.Transparency = 0.8
                getLinkGlow.Parent = getLinkButton

                local getLinkIcon = createIconImage("link", 16, Color3.fromRGB(255, 255, 255))
                getLinkIcon.AnchorPoint = Vector2.new(0, 0.5)
                getLinkIcon.Position = UDim2.new(0, 12, 0.5, 0)
                getLinkIcon.Parent = getLinkButton

                local getLinkText = Instance.new("TextLabel")
                getLinkText.Name = "ButtonText"
                getLinkText.Size = UDim2.new(1, 0, 1, 0)
                getLinkText.Position = UDim2.new(0, 0, 0, 0)
                getLinkText.BackgroundTransparency = 1
                getLinkText.Text = "Get Link"
                getLinkText.TextColor3 = Color3.fromRGB(255, 255, 255)
                getLinkText.Font = Enum.Font.GothamSemibold
                getLinkText.TextSize = 14
                getLinkText.TextXAlignment = Enum.TextXAlignment.Center
                getLinkText.Parent = getLinkButton

                local verifyButton = Instance.new("TextButton")
                verifyButton.Name = "VerifyButton"
                verifyButton.Size = UDim2.new(0.48, 0, 1, 0)
                verifyButton.Position = UDim2.new(0.52, 0, 0, 0)
                verifyButton.BackgroundColor3 = Colors.success
                verifyButton.BorderSizePixel = 0
                verifyButton.Text = ""
                verifyButton.TextSize = 14
                verifyButton.Font = Enum.Font.GothamSemibold
                verifyButton.AutoButtonColor = false
                verifyButton.Parent = buttonSection

                local verifyCorner = Instance.new("UICorner")
                verifyCorner.CornerRadius = UDim.new(0, 10)
                verifyCorner.Parent = verifyButton

                local verifyGradient = Instance.new("UIGradient")
                verifyGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Colors.success),
                    ColorSequenceKeypoint.new(1, Colors.successDark)
                }
                verifyGradient.Rotation = 90
                verifyGradient.Parent = verifyButton

                local verifyGlow = Instance.new("UIStroke")
                verifyGlow.Color = Colors.successGlow
                verifyGlow.Thickness = 0
                verifyGlow.Transparency = 0.8
                verifyGlow.Parent = verifyButton

                local verifyIcon = createIconImage("check", 16, Color3.fromRGB(255, 255, 255))
                verifyIcon.AnchorPoint = Vector2.new(0, 0.5)
                verifyIcon.Position = UDim2.new(0, 12, 0.5, 0)
                verifyIcon.Parent = verifyButton

                local verifyText = Instance.new("TextLabel")
                verifyText.Name = "ButtonText"
                verifyText.Size = UDim2.new(1, 0, 1, 0)
                verifyText.Position = UDim2.new(0, 0, 0, 0)
                verifyText.BackgroundTransparency = 1
                verifyText.Text = "Verify Key"
                verifyText.TextColor3 = Color3.fromRGB(255, 255, 255)
                verifyText.Font = Enum.Font.GothamSemibold
                verifyText.TextSize = 14
                verifyText.TextXAlignment = Enum.TextXAlignment.Center
                verifyText.Parent = verifyButton

                local statusBar = Instance.new("Frame")
                statusBar.Name = "StatusBar"
                statusBar.Size = UDim2.new(1, -40, 0, 2)
                statusBar.Position = UDim2.new(0.5, 0, 1, -14)
                statusBar.AnchorPoint = Vector2.new(0.5, 0)
                statusBar.BackgroundColor3 = Colors.border
                statusBar.BorderSizePixel = 0
                statusBar.Parent = container

                local statusText = Instance.new("TextLabel")
                statusText.Name = "StatusText"
                statusText.BackgroundTransparency = 1
                statusText.Text = ""
                statusText.TextColor3 = Colors.textSecondary
                statusText.Font = Enum.Font.Gotham
                statusText.TextSize = 12
                statusText.TextXAlignment = Enum.TextXAlignment.Center
                statusText.Size = UDim2.new(1, -40, 0, 20)
                statusText.Position = UDim2.new(0.5, 0, 1, -38)
                statusText.AnchorPoint = Vector2.new(0.5, 0)
                statusText.Visible = false
                statusText.Parent = container

                self.elements = {
                    backdrop = backdrop,
                    container = container,
                    iconFrame = iconFrame,
                    brandLogo = brandLogo,
                    title = titleText,
                    subtitle = subtitleText,
                    getLinkButton = getLinkButton,
                    inputContainer = inputSection,
                    inputFrame = inputSection,
                    keyInput = keyInput,
                    verifyButton = verifyButton,
                    statusBar = statusBar,
                    statusText = statusText,
                    inputStroke = inputStroke,
                    closeButton = closeButton,
                    glassOverlay = glassOverlay,
                    glowFrame = glowFrame
                }

                local function createAmbientParticle()
                    local particle = Instance.new("Frame")
                    particle.Name = "AmbientParticle"
                    particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
                    particle.Position = UDim2.new(math.random(), 0, 1, 0)
                    particle.BackgroundColor3 = Colors.primaryGlow
                    particle.BackgroundTransparency = 0.7
                    particle.BorderSizePixel = 0
                    particle.Parent = container
                    local particleCorner = Instance.new("UICorner")
                    particleCorner.CornerRadius = UDim.new(1, 0)
                    particleCorner.Parent = particle
                    local floatTween = TweenService:Create(particle,
                        TweenInfo.new(math.random(8, 12), Enum.EasingStyle.Linear),
                        { Position = UDim2.new(particle.Position.X.Scale, 0, -0.1, 0), BackgroundTransparency = 1 }
                    )
                    floatTween:Play()
                    floatTween.Completed:Connect(function() particle:Destroy() end)
                end

                task.spawn(function()
                    while container and container.Parent do
                        createAmbientParticle()
                        task.wait(math.random(2, 4))
                    end
                end)

                local function setupAnimations()
                    local elements = self.elements
                    if elements.getLinkButton then
                        elements.getLinkButton.MouseEnter:Connect(function()
                            TweenService:Create(elements.getLinkButton, TweenInfo.new(0.2), { BackgroundColor3 = Colors.primaryGlow }):Play()
                        end)
                        elements.getLinkButton.MouseLeave:Connect(function()
                            TweenService:Create(elements.getLinkButton, TweenInfo.new(0.2), { BackgroundColor3 = Colors.primary }):Play()
                        end)
                    end
                    if elements.verifyButton then
                        elements.verifyButton.MouseEnter:Connect(function()
                            TweenService:Create(elements.verifyButton, TweenInfo.new(0.2), { BackgroundColor3 = Colors.successGlow }):Play()
                        end)
                        elements.verifyButton.MouseLeave:Connect(function()
                            TweenService:Create(elements.verifyButton, TweenInfo.new(0.2), { BackgroundColor3 = Colors.success }):Play()
                        end)
                    end
                    if elements.keyInput and elements.inputStroke then
                        elements.keyInput.Focused:Connect(function()
                            TweenService:Create(elements.inputStroke, TweenInfo.new(0.2), { Color = Colors.primary, Thickness = 2, Transparency = 0 }):Play()
                        end)
                        elements.keyInput.FocusLost:Connect(function()
                            TweenService:Create(elements.inputStroke, TweenInfo.new(0.2), { Color = Colors.border, Thickness = 1, Transparency = 0.5 }):Play()
                        end)
                    end
                end

                local function animateEntrance()
                    local container = self.elements.container
                    local backdrop = self.elements.backdrop
                    if container then
                        container.BackgroundTransparency = 1
                        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 }):Play()
                    end
                    if backdrop then
                        backdrop.BackgroundTransparency = 1
                        TweenService:Create(backdrop, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.4 }):Play()
                    end
                end

                self.gui.Parent = game:GetService("CoreGui")
                self.gui.AncestryChanged:Connect(function(_, parent)
                    if parent == nil then
                        local blur = Lighting:FindFirstChild("JunkieUIBlur")
                        if blur then blur:Destroy() end
                    end
                end)

                self.showSuccess = function(self, message)
                    if not self.elements then return end
                    local container = self.elements.container
                    local loadingOverlay = container:FindFirstChild("LoadingOverlay")
                    if loadingOverlay then
                        local mainContainer = loadingOverlay:FindFirstChild("MainContainer")
                        local spinnerContainer = mainContainer and mainContainer:FindFirstChild("SpinnerContainer")
                        local loadingText = mainContainer and mainContainer:FindFirstChild("LoadingText")
                        local hintText = mainContainer and mainContainer:FindFirstChild("HintText")
                        if spinnerContainer then
                            for _, child in ipairs(spinnerContainer:GetChildren()) do
                                if child:IsA("Frame") then
                                    TweenService:Create(child, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                                end
                            end
                            task.wait(0.25)
                            local successCircle = Instance.new("Frame")
                            successCircle.Name = "SuccessCircle"
                            successCircle.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
                            successCircle.BackgroundTransparency = 1
                            successCircle.Size = UDim2.new(0, 80, 0, 80)
                            successCircle.Position = UDim2.new(0.5, 0, 0, 20)
                            successCircle.AnchorPoint = Vector2.new(0.5, 0)
                            successCircle.Parent = mainContainer
                            local successCorner = Instance.new("UICorner")
                            successCorner.CornerRadius = UDim.new(1, 0)
                            successCorner.Parent = successCircle
                            local checkmark = Instance.new("TextLabel")
                            checkmark.BackgroundTransparency = 1
                            checkmark.Size = UDim2.new(1, 0, 1, 0)
                            checkmark.Font = Enum.Font.GothamBold
                            checkmark.Text = "✓"
                            checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
                            checkmark.TextSize = 0
                            checkmark.TextTransparency = 1
                            checkmark.Parent = successCircle
                            TweenService:Create(successCircle, TweenInfo.new(0.4, Enum.EasingStyle.Back), { BackgroundTransparency = 0.15, Size = UDim2.new(0, 90, 0, 90) }):Play()
                            task.wait(0.15)
                            TweenService:Create(checkmark, TweenInfo.new(0.3, Enum.EasingStyle.Back), { TextSize = 52, TextTransparency = 0 }):Play()
                            task.wait(0.3)
                        end
                        if loadingText then
                            task.wait(0.1)
                            loadingText.Text = message or "Verified!"
                            loadingText.TextColor3 = Color3.fromRGB(34, 197, 94)
                        end
                        if hintText then
                            hintText.Text = "Starting script"
                            hintText.TextColor3 = Color3.fromRGB(34, 197, 94)
                        end
                    end
                    task.wait(0.8)
                end

                self.updateStatus = function(self, message, color, duration)
                    local statusText = self.elements.statusText
                    local statusBar = self.elements.statusBar
                    if statusText then
                        statusText.Text = message
                        statusText.TextColor3 = color or Colors.textSecondary
                        statusText.Visible = true
                        if statusBar then
                            TweenService:Create(statusBar, TweenInfo.new(0.2), {
                                BackgroundColor3 = color or Colors.border,
                                Size = UDim2.new(1, -40, 0, 3)
                            }):Play()
                        end
                        if duration and duration > 0 then
                            task.delay(duration, function()
                                if statusText and statusText.Text == message then
                                    statusText.Visible = false
                                    if statusBar then
                                        TweenService:Create(statusBar, TweenInfo.new(0.2), {
                                            BackgroundColor3 = Colors.border,
                                            Size = UDim2.new(1, -40, 0, 2)
                                        }):Play()
                                    end
                                end
                            end)
                        end
                    end
                end

                self.setButtonLoading = function(self, button, text, loading)
                    if loading then
                        local buttonText = button:FindFirstChild("ButtonText")
                        if buttonText then buttonText.Text = text end
                        button.Interactable = false
                    else
                        local buttonText = button:FindFirstChild("ButtonText")
                        if buttonText then buttonText.Text = text end
                        button.Interactable = true
                    end
                end

                self.shakeInput = function(self)
                    local frame = self.elements.inputFrame
                    if not frame then return end
                    local orig = frame.Position
                    for i = 1, 3 do
                        TweenService:Create(frame, TweenInfo.new(0.05), {
                            Position = UDim2.new(orig.X.Scale, orig.X.Offset - 8, orig.Y.Scale, orig.Y.Offset)
                        }):Play()
                        task.wait(0.05)
                        TweenService:Create(frame, TweenInfo.new(0.05), {
                            Position = UDim2.new(orig.X.Scale, orig.X.Offset + 8, orig.Y.Scale, orig.Y.Offset)
                        }):Play()
                        task.wait(0.05)
                    end
                    frame.Position = orig
                end

                self.animateSuccess = function(self)
                    local iconFrame = self.elements.iconFrame
                    if iconFrame then
                        TweenService:Create(iconFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                            Size = UDim2.new(0, 62, 0, 62),
                            Position = UDim2.new(0.5, -31, 0, -5)
                        }):Play()
                        task.wait(0.2)
                        TweenService:Create(iconFrame, TweenInfo.new(0.2), {
                            Size = UDim2.new(0, 52, 0, 52),
                            Position = UDim2.new(0.5, -26, 0, 0)
                        }):Play()
                    end
                end

                self.close = function(self)
                    if not self.gui then return end
                    getgenv().UI_CLOSED = true
                    local container = self.elements.container
                    local backdrop = self.elements.backdrop
                    local blur = Lighting:FindFirstChild("JunkieUIBlur")
                    TweenService:Create(container, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(backdrop, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                    task.wait(0.2)
                    if blur then blur:Destroy() end
                    self.gui:Destroy()
                    self.gui = nil
                end

                self.setLoadingState = function(self, isLoading, message)
                    if not self.elements then return end
                    local container = self.elements.container
                    local inputFrame = self.elements.inputFrame
                    local verifyButton = self.elements.verifyButton
                    local getLinkButton = self.elements.getLinkButton
                    local iconFrame = self.elements.iconFrame
                    local title = self.elements.title
                    local subtitle = self.elements.subtitle
                    if isLoading then
                        if inputFrame then inputFrame.Visible = false end
                        if verifyButton then verifyButton.Visible = false end
                        if getLinkButton then getLinkButton.Visible = false end
                        if iconFrame then iconFrame.Visible = false end
                        if title then title.Visible = false end
                        if subtitle then subtitle.Visible = false end
                        local loadingOverlay = container:FindFirstChild("LoadingOverlay")
                        if not loadingOverlay then
                            loadingOverlay = Instance.new("Frame")
                            loadingOverlay.Name = "LoadingOverlay"
                            loadingOverlay.BackgroundTransparency = 1
                            loadingOverlay.Size = UDim2.new(1, 0, 1, 0)
                            loadingOverlay.Position = UDim2.new(0, 0, 0, 0)
                            loadingOverlay.ZIndex = 100
                            loadingOverlay.Parent = container
                            local mainContainer = Instance.new("Frame")
                            mainContainer.Name = "MainContainer"
                            mainContainer.BackgroundTransparency = 1
                            mainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
                            mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
                            mainContainer.Size = UDim2.new(0, 280, 0, 200)
                            mainContainer.Parent = loadingOverlay
                            local spinnerContainer = Instance.new("Frame")
                            spinnerContainer.Name = "SpinnerContainer"
                            spinnerContainer.BackgroundTransparency = 1
                            spinnerContainer.AnchorPoint = Vector2.new(0.5, 0)
                            spinnerContainer.Position = UDim2.new(0.5, 0, 0, 20)
                            spinnerContainer.Size = UDim2.new(0, 80, 0, 80)
                            spinnerContainer.Parent = mainContainer
                            local bgCircle = Instance.new("Frame")
                            bgCircle.BackgroundTransparency = 1
                            bgCircle.Size = UDim2.new(1, 0, 1, 0)
                            bgCircle.Parent = spinnerContainer
                            local bgStroke = Instance.new("UIStroke")
                            bgStroke.Color = Colors.accent
                            bgStroke.Thickness = 4
                            bgStroke.Transparency = 0.85
                            bgStroke.Parent = bgCircle
                            local bgCorner = Instance.new("UICorner")
                            bgCorner.CornerRadius = UDim.new(1, 0)
                            bgCorner.Parent = bgCircle
                            local arcCircle = Instance.new("Frame")
                            arcCircle.BackgroundTransparency = 1
                            arcCircle.Size = UDim2.new(1, 0, 1, 0)
                            arcCircle.Parent = spinnerContainer
                            local arcStroke = Instance.new("UIStroke")
                            arcStroke.Color = Colors.accent
                            arcStroke.Thickness = 4
                            arcStroke.Transparency = 0
                            arcStroke.Parent = arcCircle
                            local arcCorner = Instance.new("UICorner")
                            arcCorner.CornerRadius = UDim.new(1, 0)
                            arcCorner.Parent = arcCircle
                            local spinTween = TweenService:Create(spinnerContainer,
                                TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
                                { Rotation = 360 }
                            )
                            spinTween:Play()
                            local loadingText = Instance.new("TextLabel")
                            loadingText.Name = "LoadingText"
                            loadingText.BackgroundTransparency = 1
                            loadingText.AnchorPoint = Vector2.new(0.5, 0)
                            loadingText.Position = UDim2.new(0.5, 0, 0, 130)
                            loadingText.Size = UDim2.new(1, 0, 0, 25)
                            loadingText.Font = Enum.Font.GothamBold
                            loadingText.Text = message or "Loading information"
                            loadingText.TextColor3 = Colors.textPrimary
                            loadingText.TextSize = 16
                            loadingText.Parent = mainContainer
                            local hintText = Instance.new("TextLabel")
                            hintText.Name = "HintText"
                            hintText.BackgroundTransparency = 1
                            hintText.AnchorPoint = Vector2.new(0.5, 0)
                            hintText.Position = UDim2.new(0.5, 0, 0, 160)
                            hintText.Size = UDim2.new(1, 0, 0, 20)
                            hintText.Font = Enum.Font.Gotham
                            hintText.Text = "Please wait a moment"
                            hintText.TextColor3 = Colors.textSecondary
                            hintText.TextSize = 12
                            hintText.Parent = mainContainer
                        end
                        loadingOverlay.Visible = true
                    else
                        if inputFrame then inputFrame.Visible = true end
                        if verifyButton then verifyButton.Visible = true end
                        if getLinkButton then getLinkButton.Visible = true end
                        if iconFrame then iconFrame.Visible = true end
                        if title then title.Visible = true end
                        if subtitle then subtitle.Visible = true end
                        local loadingOverlay = container:FindFirstChild("LoadingOverlay")
                        if loadingOverlay then loadingOverlay:Destroy() end
                    end
                end

                setupAnimations()
                animateEntrance()
                return self.gui
            end
        end
    end

    local UI = {}
    UI.__index = UI

    function UI.new(options)
        local self = setmetatable({}, UI)
        self.options = options or {}
        self.title = self.options.title or "Key Verification System"
        self.subtitle = self.options.subtitle or "Powered by Junkie Development"
        self.description = self.options.description or "Please complete the key verification to continue"
        self.lastRequestTime = 0
        self.requestCooldown = 15
        self.maxAttempts = 5
        self.currentAttempts = 0
        self.player = Players.LocalPlayer
        self.gui = nil
        self.hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        self._connections = {}
        return self
    end

    UI.createUI = function(self)
        local UIFactory = loadUIFactory()
        if UIFactory then
            local uiBuilder = UIFactory(Colors, Players, TweenService, UserInputService, Lighting)
            if uiBuilder then
                uiBuilder(self)
            else
                error("UI builder initialization failed")
                return
            end
        else
            error("Failed to load UI factory")
            return
        end

        -- closeButton отключён: окно нельзя закрыть без валидного ключа

        if self.elements and self.elements.getLinkButton then
            table.insert(self._connections, self.elements.getLinkButton.MouseButton1Click:Connect(function()
                self:handleGetLink()
            end))
        end
        if self.elements and self.elements.verifyButton then
            table.insert(self._connections, self.elements.verifyButton.MouseButton1Click:Connect(function()
                self:handleVerifyKey()
            end))
        end
        if self.elements and self.elements.keyInput then
            table.insert(self._connections, self.elements.keyInput.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    self:handleVerifyKey()
                end
            end))
        end
        return self.gui
    end

    function UI:close()
        getgenv().UI_CLOSED = true
        for _, conn in ipairs(self._connections or {}) do
            pcall(function() conn:Disconnect() end)
        end
        self._connections = {}
        if self.gui then self.gui:Destroy() end
        return getgenv().SCRIPT_KEY
    end

    function UI:handleGetLink()
        local secureGetKeyLink = Junkie.get_key_link()
        if not secureGetKeyLink then
            self:updateStatus("System not initialized", Colors.error, 3)
            return
        end
        local link = secureGetKeyLink
        if link then
            if setclipboard then
                setclipboard(link)
                self:updateStatus("Link copied to clipboard!", Colors.success, 3)
            else
                self:updateStatus("Get link: " .. link, Colors.primary, 10)
            end
        else
            self:updateStatus("Failed to get link", Colors.error, 3)
        end
    end

    function UI:handleVerifyKey()
        local key = self.elements.keyInput.Text:gsub("%s+", "")
        if key == "" then
            self:updateStatus("Please enter a key", Colors.error, 3)
            self:shakeInput()
            return
        end
        if self.setButtonLoading then
            self:setButtonLoading(self.elements.verifyButton, "Verifying", true)
        end
        self:updateStatus("Verifying...", Colors.primary, 0)
        if self.elements.keyInput.Interactable ~= nil then
            self.elements.keyInput.Interactable = false
        end

        local result = Junkie.check_key(key)

        -- Только KEY_VALID пропускает. KEYLESS игнорируется.
        if result and result.valid and result.message == "KEY_VALID" then
            saveVerifiedKey(key)
            self:updateStatus("Key verified!", Colors.success, 0)
            if self.animateSuccess then self:animateSuccess() end
            task.wait(1.5)
            getgenv().SCRIPT_KEY = key
            self:close()
            return
        else
            self:updateStatus("Invalid key", Colors.error, 3)
            if self.shakeInput then self:shakeInput() end
            if self.setButtonLoading then
                self:setButtonLoading(self.elements.verifyButton, "Verify Key", false)
            end
            if self.elements.keyInput.Interactable ~= nil then
                self.elements.keyInput.Interactable = true
            end
        end
    end

    local options = {
        title = "Bloomware | Key System",
        subtitle = "Steal An Egg — Key Verification",
        description = "Please enter your key to continue"
    }

    local ui = UI.new(options)
    ui:createUI()

    if ui.setLoadingState then
        ui:setLoadingState(true, "Checking verification...")
    end

    local savedKey = loadVerifiedKey()
    local keyToCheck = savedKey

    -- Пробуем только сохранённый ключ. Никакого KEYLESS.
    if keyToCheck and keyToCheck ~= "" and keyToCheck ~= "KEYLESS" then
        local result = Junkie.check_key(keyToCheck)
        if result and result.valid and result.message == "KEY_VALID" then
            if ui.showSuccess then ui:showSuccess("Saved Key Verified ✓") end
            getgenv().SCRIPT_KEY = keyToCheck
            if ui.close then ui:close() end
            task.wait(0.5)
            return keyToCheck
        end
        clearSavedKey()
    end

    if ui.setLoadingState then
        ui:setLoadingState(false)
    end

    -- Ждём ручного ввода ключа. Окно нельзя закрыть.
    while true do
        task.wait(0.1)
        local k = getgenv().SCRIPT_KEY
        if k and k ~= "" and k ~= "KEYLESS" then
            if ui.close then pcall(function() ui:close() end) end
            pcall(function()
                local cg = game:GetService("CoreGui")
                for _, g in ipairs(cg:GetChildren()) do
                    if g.Name == "JunkieKeySystemUI" then g:Destroy() end
                end
                local blur = game:GetService("Lighting"):FindFirstChild("JunkieUIBlur")
                if blur then blur:Destroy() end
            end)
            task.wait(0.5)
            return k
        end
    end
end)()

-- Если ключ не получен — не запускаем чит
if not SCRIPT_KEY or SCRIPT_KEY == "" then
    warn("[Bloomware] Key verification failed or cancelled. Script not loaded.")
    return
end

-- Принудительная зачистка окна key-системы перед запуском Bloomware
pcall(function()
    local cg = game:GetService("CoreGui")
    for _, g in ipairs(cg:GetChildren()) do
        if g.Name == "JunkieKeySystemUI" then g:Destroy() end
    end
    local blur = game:GetService("Lighting"):FindFirstChild("JunkieUIBlur")
    if blur then blur:Destroy() end
end)
task.wait(0.3)

--конец ключ системы

do
    local prev = _G.Bloomware
    if prev and type(prev.Unload) == "function" then pcall(prev.Unload) end
end

local HUB = { conns = {}, drawings = {}, highlights = {}, dead = false }
_G.Bloomware = HUB

local function track(conn) table.insert(HUB.conns, conn); return conn end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end; return d end

-- ==============================================================================
-- SERVICES
-- ==============================================================================
local Players             = game:GetService("Players")
local RS                  = game:GetService("ReplicatedStorage")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local Workspace           = game:GetService("Workspace")
local Lighting            = game:GetService("Lighting")
local TeleportService     = game:GetService("TeleportService")
local VirtualUser         = game:GetService("VirtualUser")
local TweenService        = game:GetService("TweenService")
local HttpService         = game:GetService("HttpService")
local CoreGui             = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local function GetCamera()
    return Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")
end

-- Instant ProximityPrompt
pcall(function()
    local pps = game:GetService("ProximityPromptService")
    track(pps.PromptButtonHoldBegan:Connect(function(prompt, player)
        if player == LP and tostring(prompt) == "CarryAreaEgg" then
            prompt.HoldDuration = 0
        end
    end))
end)

-- Anti-Robux Prompt Shield
pcall(function()
    track(CoreGui.ChildAdded:Connect(function(child)
        if child.Name == "PurchasePrompt" then
            task.wait(0.04)
            pcall(function()
                local cancel = child:FindFirstChild("CancelButton", true)
                if cancel and cancel:IsA("GuiButton") then
                    pcall(function() cancel.MouseButton1Click:Fire() end)
                end
            end)
        end
    end))
end)

-- ==============================================================================
-- ==============================================================================
-- CUSTOM BEAUTIFUL UI (Bloomware Design System v2)
-- ===============================================================================
local UI = {}
UI.Theme = {
    Background = Color3.fromRGB(10, 11, 17),
    Surface = Color3.fromRGB(17, 19, 28),
    Surface2 = Color3.fromRGB(23, 25, 37),
    Surface3 = Color3.fromRGB(29, 32, 47),
    Accent = Color3.fromRGB(255, 82, 168),
    Accent2 = Color3.fromRGB(154, 90, 255),
    Text = Color3.fromRGB(245, 247, 255),
    TextDim = Color3.fromRGB(153, 159, 180),
    Success = Color3.fromRGB(74, 224, 143),
    Error = Color3.fromRGB(255, 92, 110),
    Warning = Color3.fromRGB(255, 184, 74),
    Stroke = Color3.fromRGB(45, 49, 67),
    Input = Color3.fromRGB(12, 14, 21),
}

UI.Presets = {
    Obsidian = {
        Background = Color3.fromRGB(10, 11, 17), Surface = Color3.fromRGB(17, 19, 28), Surface2 = Color3.fromRGB(23, 25, 37),
        Surface3 = Color3.fromRGB(29, 32, 47), Accent = Color3.fromRGB(255, 82, 168), Accent2 = Color3.fromRGB(154, 90, 255),
        Text = Color3.fromRGB(245, 247, 255), TextDim = Color3.fromRGB(153, 159, 180), Stroke = Color3.fromRGB(45, 49, 67), Input = Color3.fromRGB(12, 14, 21),
    },
    Midnight = {
        Background = Color3.fromRGB(7, 12, 22), Surface = Color3.fromRGB(12, 20, 34), Surface2 = Color3.fromRGB(17, 28, 46),
        Surface3 = Color3.fromRGB(24, 39, 62), Accent = Color3.fromRGB(76, 170, 255), Accent2 = Color3.fromRGB(89, 102, 255),
        Text = Color3.fromRGB(239, 246, 255), TextDim = Color3.fromRGB(142, 161, 190), Stroke = Color3.fromRGB(36, 58, 86), Input = Color3.fromRGB(8, 14, 24),
    },
    Crimson = {
        Background = Color3.fromRGB(17, 9, 12), Surface = Color3.fromRGB(28, 14, 18), Surface2 = Color3.fromRGB(42, 20, 26),
        Surface3 = Color3.fromRGB(57, 26, 33), Accent = Color3.fromRGB(255, 74, 98), Accent2 = Color3.fromRGB(255, 128, 74),
        Text = Color3.fromRGB(255, 244, 247), TextDim = Color3.fromRGB(186, 147, 155), Stroke = Color3.fromRGB(82, 41, 50), Input = Color3.fromRGB(19, 9, 13),
    },
    Ocean = {
        Background = Color3.fromRGB(7, 15, 19), Surface = Color3.fromRGB(10, 24, 31), Surface2 = Color3.fromRGB(14, 34, 44),
        Surface3 = Color3.fromRGB(18, 44, 57), Accent = Color3.fromRGB(45, 210, 205), Accent2 = Color3.fromRGB(66, 141, 255),
        Text = Color3.fromRGB(235, 253, 252), TextDim = Color3.fromRGB(137, 173, 178), Stroke = Color3.fromRGB(30, 69, 78), Input = Color3.fromRGB(7, 18, 24),
    },
    Violet = {
        Background = Color3.fromRGB(13, 10, 20), Surface = Color3.fromRGB(21, 16, 32), Surface2 = Color3.fromRGB(31, 23, 47),
        Surface3 = Color3.fromRGB(42, 30, 62), Accent = Color3.fromRGB(168, 100, 255), Accent2 = Color3.fromRGB(255, 96, 196),
        Text = Color3.fromRGB(247, 241, 255), TextDim = Color3.fromRGB(163, 148, 186), Stroke = Color3.fromRGB(62, 45, 88), Input = Color3.fromRGB(16, 11, 24),
    },
    Emerald = {
        Background = Color3.fromRGB(7, 15, 12), Surface = Color3.fromRGB(11, 24, 19), Surface2 = Color3.fromRGB(16, 35, 27),
        Surface3 = Color3.fromRGB(21, 47, 36), Accent = Color3.fromRGB(69, 222, 148), Accent2 = Color3.fromRGB(75, 181, 255),
        Text = Color3.fromRGB(237, 255, 246), TextDim = Color3.fromRGB(144, 179, 160), Stroke = Color3.fromRGB(32, 71, 54), Input = Color3.fromRGB(7, 19, 13),
    },
}

UI.Scale = 1
UI.Compact = false
UI.SearchText = ""
UI.ToggleKey = Enum.KeyCode.RightControl
UI.CurrentPreset = "Obsidian"
UI.Rows = {}
UI.Sections = {}
UI.OpenSection = nil
UI.ThemeObjects = {}
UI._customHex = {}

local function Create(class, props, children)
    local themeRole = props and props.ThemeRole
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" and k ~= "ThemeRole" then obj[k] = v end
    end
    if children then for _, c in ipairs(children) do c.Parent = obj end end
    if props and props.Parent then obj.Parent = props.Parent end
    if themeRole then
        obj:SetAttribute("BloomThemeRole", themeRole)
        table.insert(UI.ThemeObjects, obj)
    end
    return obj
end

local function Tween(obj, props, dur, style, dir)
    if typeof(obj) ~= "Instance" then return end
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.22, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function hexToColor3(hex, fallback)
    if type(hex) ~= "string" then return fallback end
    hex = hex:gsub("#", "")
    if #hex ~= 6 or not hex:match("^[%x]+$") then return fallback end
    local r = tonumber(hex:sub(1,2), 16); local g = tonumber(hex:sub(3,4), 16); local b = tonumber(hex:sub(5,6), 16)
    return Color3.fromRGB(r, g, b)
end

local function color3ToHex(c)
    return string.format("#%02X%02X%02X", math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5))
end

local guiParent = (gethui and gethui()) or CoreGui
local ScreenGui = Create("ScreenGui", {
    Name = "BloomwareUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = guiParent
})

local ScaleObject = Create("UIScale", { Scale = UI.Scale, Parent = ScreenGui })

local Main = Create("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5,0.5), Size = UDim2.fromScale(0.82,0.80), Position = UDim2.fromScale(0.5,0.5),
    BackgroundColor3 = UI.Theme.Background, BorderSizePixel = 0, Parent = ScreenGui, ThemeRole = "Background"
})
Create("UISizeConstraint", { MinSize = Vector2.new(700, 460), MaxSize = Vector2.new(1100, 760), Parent = Main })
Create("UICorner", { CornerRadius = UDim.new(0, 18), Parent = Main })
Create("UIStroke", { Color = UI.Theme.Stroke, Thickness = 1.3, Parent = Main, ThemeRole = "Stroke" })

local TopBar = Create("Frame", { Size = UDim2.new(1,0,0,58), BackgroundColor3 = UI.Theme.Surface, BorderSizePixel = 0, Parent = Main, ThemeRole = "Surface" })
Create("UICorner", { CornerRadius = UDim.new(0,18), Parent = TopBar })
Create("Frame", { Size = UDim2.new(1,0,0,18), Position = UDim2.new(0,0,1,-18), BackgroundColor3 = UI.Theme.Surface, BorderSizePixel = 0, Parent = TopBar, ThemeRole = "Surface" })

local LogoDot = Create("Frame", { Size = UDim2.fromOffset(10,10), Position = UDim2.new(0,18,0.5,-5), BackgroundColor3 = UI.Theme.Accent, BorderSizePixel = 0, Parent = TopBar, ThemeRole = "Accent" })
Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = LogoDot })
local TitleLabel = Create("TextLabel", { Size = UDim2.new(0,300,1,0), Position = UDim2.new(0,36,0,0), BackgroundTransparency = 1, Text = "Bloomware", TextColor3 = UI.Theme.Text, TextSize = 17, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar, ThemeRole = "Text" })
local SubLabel = Create("TextLabel", { Size = UDim2.new(0,300,0,18), Position = UDim2.new(0,36,0,31), BackgroundTransparency = 1, Text = "STEAL AN EGG  •  V2 UI", TextColor3 = UI.Theme.TextDim, TextSize = 9, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar, ThemeRole = "TextDim" })

local SearchBox = Create("TextBox", {
    Size = UDim2.new(0,220,0,34), Position = UDim2.new(1,-360,0.5,-17), BackgroundColor3 = UI.Theme.Input, BorderSizePixel = 0,
    Text = "", PlaceholderText = "Search current tab...", PlaceholderColor3 = UI.Theme.TextDim, TextColor3 = UI.Theme.Text, TextSize = 12,
    Font = Enum.Font.Gotham, ClearTextOnFocus = false, Parent = TopBar, ThemeRole = "Input"
})
Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = SearchBox })
Create("UIStroke", { Color = UI.Theme.Stroke, Thickness = 1, Parent = SearchBox, ThemeRole = "Stroke" })

local CompactBtn = Create("TextButton", { Size = UDim2.fromOffset(34,34), Position = UDim2.new(1,-132,0.5,-17), BackgroundColor3 = UI.Theme.Surface2, Text = "≡", TextColor3 = UI.Theme.Text, TextSize = 19, Font = Enum.Font.GothamBold, Parent = TopBar, ThemeRole = "Surface2" })
Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = CompactBtn })
local MinBtn = Create("TextButton", { Size = UDim2.fromOffset(34,34), Position = UDim2.new(1,-90,0.5,-17), BackgroundColor3 = UI.Theme.Surface2, Text = "—", TextColor3 = UI.Theme.Text, TextSize = 17, Font = Enum.Font.GothamBold, Parent = TopBar, ThemeRole = "Surface2" })
Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = MinBtn })
local CloseBtn = Create("TextButton", { Size = UDim2.fromOffset(34,34), Position = UDim2.new(1,-48,0.5,-17), BackgroundColor3 = Color3.fromRGB(80,28,40), Text = "×", TextColor3 = UI.Theme.Text, TextSize = 20, Font = Enum.Font.GothamBold, Parent = TopBar })
Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = CloseBtn })

local Sidebar = Create("Frame", { Size = UDim2.new(0,190,1,-72), Position = UDim2.new(0,10,0,64), BackgroundColor3 = UI.Theme.Surface, BorderSizePixel = 0, Parent = Main, ThemeRole = "Surface" })
Create("UICorner", { CornerRadius = UDim.new(0,14), Parent = Sidebar })
Create("UIPadding", { PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8), PaddingBottom = UDim.new(0,10), Parent = Sidebar })
local SideLayout = Create("UIListLayout", { Padding = UDim.new(0,7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Sidebar })

local Content = Create("ScrollingFrame", {
    Size = UDim2.new(1,-215,1,-78), Position = UDim2.new(0,205,0,68), BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 4, ScrollBarImageColor3 = UI.Theme.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0,0,0,0), Parent = Main
})
Create("UIPadding", { PaddingTop = UDim.new(0,2), PaddingBottom = UDim.new(0,14), PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,8), Parent = Content })
local ContentLayout = Create("UIListLayout", { Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Content })

local StatusPill = Create("Frame", { Size = UDim2.fromOffset(130,28), Position = UDim2.new(1,-292,0.5,-14), BackgroundColor3 = UI.Theme.Surface2, BorderSizePixel = 0, Parent = TopBar, ThemeRole = "Surface2" })
Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = StatusPill })
local StatusDot = Create("Frame", { Size = UDim2.fromOffset(7,7), Position = UDim2.new(0,10,0.5,-4), BackgroundColor3 = UI.Theme.Success, BorderSizePixel = 0, Parent = StatusPill })
Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = StatusDot })
local StatusText = Create("TextLabel", { Size = UDim2.new(1,-25,1,0), Position = UDim2.new(0,24,0,0), BackgroundTransparency = 1, Text = "SYSTEM ONLINE", TextColor3 = UI.Theme.TextDim, TextSize = 9, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = StatusPill, ThemeRole = "TextDim" })

local Tabs, CurrentTab, tabCount = {}, nil, 0
local function ClearContent()
    for _, c in ipairs(Content:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    table.clear(UI.Rows); table.clear(UI.Sections)
    UI.OpenSection = nil
end

local function applyThemeToObject(obj)
    if not obj or not obj.Parent then return end
    local role = obj:GetAttribute("BloomThemeRole")
    local t = UI.Theme
    if role == "Background" then obj.BackgroundColor3 = t.Background
    elseif role == "Surface" then obj.BackgroundColor3 = t.Surface
    elseif role == "Surface2" then obj.BackgroundColor3 = t.Surface2
    elseif role == "Surface3" then obj.BackgroundColor3 = t.Surface3
    elseif role == "Input" then obj.BackgroundColor3 = t.Input
    elseif role == "Accent" then obj.BackgroundColor3 = t.Accent
    elseif role == "Accent2" then obj.BackgroundColor3 = t.Accent2
    elseif role == "Text" then obj.TextColor3 = t.Text
    elseif role == "TextDim" then obj.TextColor3 = t.TextDim
    elseif role == "Stroke" then obj.Color = t.Stroke end
end

function UI.ApplyTheme(theme)
    if type(theme) ~= "table" then return end
    for k,v in pairs(theme) do if UI.Theme[k] ~= nil then UI.Theme[k] = v end end
    for _, obj in ipairs(UI.ThemeObjects) do pcall(applyThemeToObject, obj) end
    if StatusDot then StatusDot.BackgroundColor3 = UI.Theme.Success end
    if CloseBtn then CloseBtn.BackgroundColor3 = Color3.fromRGB(80,28,40) end
    if Content then Content.ScrollBarImageColor3 = UI.Theme.Accent end
    if UI.RefreshVisuals then pcall(UI.RefreshVisuals) end
end

function UI.ApplyPreset(name)
    local preset = UI.Presets[name]
    if not preset then return false end
    UI.CurrentPreset = name
    UI.ApplyTheme(preset)
    if UI._themeSelector then UI._themeSelector.Set(name) end
    return true
end

local function RegisterRow(frame, text)
    table.insert(UI.Rows, {Frame = frame, Text = string.lower(text or "")})
end

function UI.RefreshSearch()
    local q = string.lower(UI.SearchText or ""):gsub("^%s+", ""):gsub("%s+$", "")
    for _, row in ipairs(UI.Rows) do
        row.Frame.Visible = (q == "" or row.Text:find(q,1,true) ~= nil)
    end
    for _, section in ipairs(UI.Sections) do
        local any = (q == "")
        for _, row in ipairs(UI.Rows) do
            if row.Section == section.Frame and row.Frame.Visible then any = true; break end
        end
        section.Frame.Visible = any
        if section.IsOpen() then
            local target = section.Layout.AbsoluteContentSize.Y + 12
            section.Body.Size = UDim2.new(1,0,0,target)
            section.Frame.Size = UDim2.new(1,0,0,46+target)
        end
    end
end

local function SwitchTab(name)
    if CurrentTab == name then return end
    CurrentTab = name
    for n,data in pairs(Tabs) do
        local btn = data.Button
        if n == name then
            Tween(btn,{BackgroundColor3=UI.Theme.Accent},0.18)
            btn.TextColor3 = Color3.new(1,1,1)
        else
            Tween(btn,{BackgroundColor3=UI.Theme.Surface2},0.18)
            btn.TextColor3 = UI.Theme.TextDim
        end
    end
    ClearContent()
    if Tabs[name] and type(Tabs[name].Build) == "function" then Tabs[name].Build() end
    Content.CanvasPosition = Vector2.zero
    UI.RefreshSearch()
end

local function AddTab(name, icon)
    tabCount += 1
    local fullText = tostring(icon or "") .. "   " .. name
    local btn = Create("TextButton", { Size = UDim2.new(1,0,0,39), BackgroundColor3 = UI.Theme.Surface2, Text = fullText, TextColor3 = UI.Theme.TextDim, TextSize = 12, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, Parent = Sidebar, ThemeRole = "Surface2", LayoutOrder = tabCount })
    btn:SetAttribute("FullText", fullText)
    Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = btn })
    Tabs[name] = {Button=btn}
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    btn.MouseEnter:Connect(function() if CurrentTab ~= name then Tween(btn,{BackgroundColor3=UI.Theme.Surface3},0.12) end end)
    btn.MouseLeave:Connect(function() if CurrentTab ~= name then Tween(btn,{BackgroundColor3=UI.Theme.Surface2},0.12) end end)
    return Tabs[name]
end

local function Section(title, subtitle)
    local section = Create("Frame", { Size = UDim2.new(1,0,0,46), BackgroundColor3 = UI.Theme.Surface, BorderSizePixel=0, Parent = Content, ThemeRole="Surface" })
    Create("UICorner", {CornerRadius=UDim.new(0,12), Parent=section})
    Create("UIStroke", {Color=UI.Theme.Stroke, Thickness=1, Parent=section, ThemeRole="Stroke"})
    local header = Create("TextButton", {Size=UDim2.new(1,0,0,46), BackgroundTransparency=1, Text="", Parent=section})
    local titleObj = Create("TextLabel", {Size=UDim2.new(1,-50,0,20), Position=UDim2.new(0,14,0,6), BackgroundTransparency=1, Text=title, TextColor3=UI.Theme.Text, TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, Parent=section, ThemeRole="Text"})
    local subObj = Create("TextLabel", {Size=UDim2.new(1,-50,0,16), Position=UDim2.new(0,14,0,25), BackgroundTransparency=1, Text=subtitle or "", TextColor3=UI.Theme.TextDim, TextSize=9, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, Parent=section, ThemeRole="TextDim"})
    local arrow = Create("TextLabel", {Size=UDim2.fromOffset(25,25), Position=UDim2.new(1,-36,0.5,-12), BackgroundTransparency=1, Text="⌄", TextColor3=UI.Theme.Accent, TextSize=15, Font=Enum.Font.GothamBold, Parent=section, ThemeRole="Accent"})
    local body = Create("Frame", {Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,0,46), BackgroundTransparency=1, ClipsDescendants=true, Parent=section})
    local layout = Create("UIListLayout", {Padding=UDim.new(0,7), SortOrder=Enum.SortOrder.LayoutOrder, Parent=body})
    Create("UIPadding", {PaddingTop=UDim.new(0,7), PaddingBottom=UDim.new(0,4), Parent=body})
    local expanded = false
    local function setOpen(v)
        expanded = v
        arrow.Text = expanded and "⌃" or "⌄"
        local target = expanded and (layout.AbsoluteContentSize.Y + 12) or 0
        Tween(body,{Size=UDim2.new(1,0,0,target)},0.2)
        Tween(section,{Size=UDim2.new(1,0,0,46+target)},0.2)
    end
    header.MouseButton1Click:Connect(function() setOpen(not expanded) end)
    local record = {Frame=section, Body=body, Layout=layout, SetOpen=setOpen, IsOpen=function() return expanded end}
    table.insert(UI.Sections, record)
    section:SetAttribute("SectionName", string.lower(title))
    return record
end

local ActiveSection = nil
local function ControlParent()
    if ActiveSection then
        ActiveSection.SetOpen(true)
        return ActiveSection.Body
    end
    return Content
end

local function rowFrame(height)
    return Create("Frame", {Size=UDim2.new(1,-12,0,height), BackgroundColor3=UI.Theme.Surface2, BorderSizePixel=0, Parent=ControlParent(), ThemeRole="Surface2"})
end

local function Toggle(name, default, callback)
    local state = default == true
    local f = rowFrame(UI.Compact and 46 or 54)
    Create("UICorner", {CornerRadius=UDim.new(0,10), Parent=f})
    Create("UIStroke", {Color=UI.Theme.Stroke, Thickness=1, Parent=f, ThemeRole="Stroke"})
    local label = Create("TextLabel", {Size=UDim2.new(1,-85,0,20), Position=UDim2.new(0,14,0,9), BackgroundTransparency=1, Text=name, TextColor3=UI.Theme.Text, TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, Parent=f, ThemeRole="Text"})
    local hint = Create("TextLabel", {Size=UDim2.new(1,-85,0,16), Position=UDim2.new(0,14,0,29), BackgroundTransparency=1, Text=state and "ACTIVE" or "INACTIVE", TextColor3=state and UI.Theme.Success or UI.Theme.TextDim, TextSize=8, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, Parent=f, ThemeRole=state and "Accent" or "TextDim"})
    local sw = Create("Frame", {Size=UDim2.fromOffset(48,26), Position=UDim2.new(1,-62,0.5,-13), BackgroundColor3=state and UI.Theme.Accent or UI.Theme.Input, Parent=f, ThemeRole=state and "Accent" or "Input"})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=sw})
    local knob = Create("Frame", {Size=UDim2.fromOffset(20,20), Position=state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10), BackgroundColor3=Color3.new(1,1,1), Parent=sw})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=knob})
    local btn = Create("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=f})
    local function set(v, fire)
        state = v == true
        Tween(sw,{BackgroundColor3=state and UI.Theme.Accent or UI.Theme.Input},0.16)
        Tween(knob,{Position=state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)},0.16)
        hint.Text = state and "ACTIVE" or "INACTIVE"; hint.TextColor3 = state and UI.Theme.Success or UI.Theme.TextDim
        if fire and callback then pcall(callback,state) end
    end
    btn.MouseButton1Click:Connect(function() set(not state,true) end)
    RegisterRow(f,name); UI.Rows[#UI.Rows].Section = ActiveSection and ActiveSection.Frame or nil
    return {Set=function(v) set(v,false) end, Get=function() return state end}
end

local function Slider(name,min,max,default,suffix,callback)
    local value = tonumber(default) or min
    local f = rowFrame(UI.Compact and 64 or 70)
    Create("UICorner", {CornerRadius=UDim.new(0,10), Parent=f})
    Create("UIStroke", {Color=UI.Theme.Stroke, Thickness=1, Parent=f, ThemeRole="Stroke"})
    local label = Create("TextLabel", {Size=UDim2.new(1,-28,0,20), Position=UDim2.new(0,14,0,8), BackgroundTransparency=1, Text=name, TextColor3=UI.Theme.Text, TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, Parent=f, ThemeRole="Text"})
    local valLabel = Create("TextLabel", {Size=UDim2.new(0,110,0,20), Position=UDim2.new(1,-124,0,8), BackgroundTransparency=1, Text=tostring(value)..(suffix or ""), TextColor3=UI.Theme.Accent, TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, Parent=f, ThemeRole="Accent"})
    local track = Create("Frame", {Size=UDim2.new(1,-28,0,7), Position=UDim2.new(0,14,0,44), BackgroundColor3=UI.Theme.Input, Parent=f, ThemeRole="Input"})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=track})
    local fill = Create("Frame", {Size=UDim2.new((value-min)/math.max(max-min,0.001),0,1,0), BackgroundColor3=UI.Theme.Accent, Parent=track, ThemeRole="Accent"})
    Create("UICorner", {CornerRadius=UDim.new(1,0), Parent=fill})
    local dragging = false
    local function setFromX(x,fire)
        local rel = math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
        value = min + (max-min)*rel
        if math.abs(max-min) > 1000 then value = math.floor(value+0.5) else value = math.floor(value*100+0.5)/100 end
        fill.Size = UDim2.new(rel,0,1,0); valLabel.Text=tostring(value)..(suffix or "")
        if fire and callback then pcall(callback,value) end
    end
    track.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; setFromX(input.Position.X,true) end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X,true) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    RegisterRow(f,name); UI.Rows[#UI.Rows].Section=ActiveSection and ActiveSection.Frame or nil
    return {Set=function(v) value=math.clamp(tonumber(v) or min,min,max); local rel=(value-min)/math.max(max-min,0.001); fill.Size=UDim2.new(rel,0,1,0); valLabel.Text=tostring(value)..(suffix or "") end, Get=function() return value end}
end

local function Button(name,primary,callback)
    local f = Create("TextButton", {Size=UDim2.new(1,-12,0,42), BackgroundColor3=primary and UI.Theme.Accent or UI.Theme.Surface2, Text=name, TextColor3=Color3.new(1,1,1), TextSize=12, Font=Enum.Font.GothamBold, Parent=ControlParent(), ThemeRole=primary and "Accent" or "Surface2", AutoButtonColor=false})
    Create("UICorner", {CornerRadius=UDim.new(0,10), Parent=f}); Create("UIStroke",{Color=UI.Theme.Stroke,Thickness=1,Parent=f,ThemeRole="Stroke"})
    local base = primary and function() return UI.Theme.Accent end or function() return UI.Theme.Surface2 end
    f.MouseEnter:Connect(function() Tween(f,{BackgroundColor3=UI.Theme.Surface3},0.12) end)
    f.MouseLeave:Connect(function() Tween(f,{BackgroundColor3=base()},0.12) end)
    f.MouseButton1Click:Connect(function() Tween(f,{Size=UDim2.new(1,-16,0,40)},0.08); task.delay(0.08,function() if f.Parent then Tween(f,{Size=UDim2.new(1,-12,0,42)},0.10) end end); if callback then pcall(callback) end end)
    RegisterRow(f,name); UI.Rows[#UI.Rows].Section=ActiveSection and ActiveSection.Frame or nil
    return f
end

local function Dropdown(name,options,default,callback)
    local selected = default or options[1] or ""
    local open=false
    local f = rowFrame(44); Create("UICorner",{CornerRadius=UDim.new(0,10),Parent=f}); Create("UIStroke",{Color=UI.Theme.Stroke,Thickness=1,Parent=f,ThemeRole="Stroke"})
    local label=Create("TextLabel",{Size=UDim2.new(1,-54,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=name.."  •  "..tostring(selected),TextColor3=UI.Theme.Text,TextSize=11,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,Parent=f,ThemeRole="Text"})
    local arrow=Create("TextLabel",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-38,0.5,-15),BackgroundTransparency=1,Text="⌄",TextColor3=UI.Theme.Accent,TextSize=15,Font=Enum.Font.GothamBold,Parent=f,ThemeRole="Accent"})
    local list=Create("Frame",{Size=UDim2.new(1,0,0,#options*32),Position=UDim2.new(0,0,1,0),BackgroundColor3=UI.Theme.Surface3,BorderSizePixel=0,Parent=f,ThemeRole="Surface3",ZIndex=20})
    Create("UICorner",{CornerRadius=UDim.new(0,10),Parent=list})
    for i,opt in ipairs(options) do
        local ob=Create("TextButton",{Size=UDim2.new(1,0,0,32),Position=UDim2.new(0,0,0,(i-1)*32),BackgroundTransparency=1,Text="  "..tostring(opt),TextColor3=UI.Theme.TextDim,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=list,ThemeRole="TextDim",ZIndex=21})
        ob.MouseButton1Click:Connect(function() selected=opt; label.Text=name.."  •  "..tostring(selected); open=false; f.Size=UDim2.new(1,-12,0,44); list.Visible=false; arrow.Text="⌄"; if callback then pcall(callback,selected) end end)
        ob.MouseEnter:Connect(function() Tween(ob,{BackgroundColor3=UI.Theme.Surface2},0.10) end)
        ob.MouseLeave:Connect(function() Tween(ob,{BackgroundColor3=UI.Theme.Surface3},0.10) end)
    end
    list.Visible=false
    local hit=Create("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,Text="",Parent=f,ZIndex=10})
    hit.MouseButton1Click:Connect(function() open=not open; list.Visible=open; arrow.Text=open and "⌃" or "⌄"; Tween(f,{Size=open and UDim2.new(1,-12,0,48+#options*32) or UDim2.new(1,-12,0,44)},0.18) end)
    RegisterRow(f,name.." "..table.concat(options," ")); UI.Rows[#UI.Rows].Section=ActiveSection and ActiveSection.Frame or nil
    return {Set=function(v) selected=v; label.Text=name.."  •  "..tostring(v) end, Get=function() return selected end}
end

local function MultiDropdown(name,options,callback)
    local selected={}; local open=false
    local f=rowFrame(44); Create("UICorner",{CornerRadius=UDim.new(0,10),Parent=f}); Create("UIStroke",{Color=UI.Theme.Stroke,Thickness=1,Parent=f,ThemeRole="Stroke"})
    local label=Create("TextLabel",{Size=UDim2.new(1,-54,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=name.."  •  0 selected",TextColor3=UI.Theme.Text,TextSize=11,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,Parent=f,ThemeRole="Text"})
    local arrow=Create("TextLabel",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-38,0.5,-15),BackgroundTransparency=1,Text="⌄",TextColor3=UI.Theme.Accent,TextSize=15,Font=Enum.Font.GothamBold,Parent=f,ThemeRole="Accent"})
    local list=Create("Frame",{Size=UDim2.new(1,0,0,#options*31),Position=UDim2.new(0,0,1,0),BackgroundColor3=UI.Theme.Surface3,BorderSizePixel=0,Parent=f,ThemeRole="Surface3"})
    Create("UICorner",{CornerRadius=UDim.new(0,10),Parent=list})
    local function update()
        local c=0; for _ in pairs(selected) do c+=1 end; label.Text=name.."  •  "..c.." selected"
        if callback then pcall(callback,selected) end
    end
    for i,opt in ipairs(options) do
        local ob=Create("TextButton",{Size=UDim2.new(1,0,0,31),Position=UDim2.new(0,0,0,(i-1)*31),BackgroundTransparency=1,Text="☐  "..tostring(opt),TextColor3=UI.Theme.TextDim,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=list,ThemeRole="TextDim",ZIndex=21})
        ob.MouseButton1Click:Connect(function() if selected[opt] then selected[opt]=nil; ob.Text="☐  "..tostring(opt) else selected[opt]=true; ob.Text="☑  "..tostring(opt); ob.TextColor3=UI.Theme.Text end; update() end)
    end
    list.Visible=false
    local hit=Create("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,Text="",Parent=f,ZIndex=10})
    hit.MouseButton1Click:Connect(function() open=not open; list.Visible=open; arrow.Text=open and "⌃" or "⌄"; Tween(f,{Size=open and UDim2.new(1,-12,0,48+#options*31) or UDim2.new(1,-12,0,44)},0.18) end)
    RegisterRow(f,name.." "..table.concat(options," ")); UI.Rows[#UI.Rows].Section=ActiveSection and ActiveSection.Frame or nil
    return {Get=function() return selected end,Set=function(t) selected=t or {}; update() end,Clear=function() table.clear(selected); update() end}
end

local function InfoCard(title,text)
    local f=Create("Frame",{Size=UDim2.new(1,-12,0,64),BackgroundColor3=UI.Theme.Surface3,BorderSizePixel=0,Parent=ControlParent(),ThemeRole="Surface3"}); Create("UICorner",{CornerRadius=UDim.new(0,10),Parent=f})
    Create("TextLabel",{Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,12,0,8),BackgroundTransparency=1,Text=title,TextColor3=UI.Theme.Accent,TextSize=10,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=f,ThemeRole="Accent"})
    Create("TextLabel",{Size=UDim2.new(1,-24,0,32),Position=UDim2.new(0,12,0,28),BackgroundTransparency=1,Text=text,TextColor3=UI.Theme.TextDim,TextSize=10,Font=Enum.Font.Gotham,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,Parent=f,ThemeRole="TextDim"})
    RegisterRow(f,title.." "..text); UI.Rows[#UI.Rows].Section=ActiveSection and ActiveSection.Frame or nil
    return f
end

local NotifHolder=Create("Frame",{Size=UDim2.fromOffset(320,1),AutomaticSize=Enum.AutomaticSize.Y,Position=UDim2.new(1,-336,0,74),BackgroundTransparency=1,Parent=ScreenGui})
Create("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Top,Parent=NotifHolder})

local function Notify(title,content,kind,dur)
    kind=kind or "Info"; dur=dur or 2.8
    local color=UI.Theme.Accent; if kind=="Success" then color=UI.Theme.Success elseif kind=="Error" then color=UI.Theme.Error elseif kind=="Warning" then color=UI.Theme.Warning end
    local n=Create("Frame",{Size=UDim2.new(1,0,0,70),BackgroundColor3=UI.Theme.Surface,BorderSizePixel=0,Parent=NotifHolder,ThemeRole="Surface"}); Create("UICorner",{CornerRadius=UDim.new(0,12),Parent=n}); Create("UIStroke",{Color=color,Thickness=1.3,Parent=n})
    Create("Frame",{Size=UDim2.fromOffset(4,48),Position=UDim2.new(0,0,0.5,-24),BackgroundColor3=color,BorderSizePixel=0,Parent=n});
    Create("TextLabel",{Size=UDim2.new(1,-24,0,22),Position=UDim2.new(0,14,0,9),BackgroundTransparency=1,Text=title,TextColor3=color,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=n});
    Create("TextLabel",{Size=UDim2.new(1,-24,0,30),Position=UDim2.new(0,14,0,32),BackgroundTransparency=1,Text=content,TextColor3=UI.Theme.TextDim,TextSize=10,Font=Enum.Font.Gotham,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Parent=n,ThemeRole="TextDim"})
    n.BackgroundTransparency=1; Tween(n,{BackgroundTransparency=0},0.18)
    task.delay(dur,function() if n.Parent then Tween(n,{BackgroundTransparency=1},0.18); task.wait(0.2); if n.Parent then n:Destroy() end end end)
end

local function safeCallback(fn)
    return function(...) local ok,err=pcall(fn,...); if not ok then Notify("Bloomware", "Error: "..tostring(err), "Error", 4) end end
end

local function setCompact(v)
    UI.Compact=v==true
    local target = UI.Compact and 76 or 190
    Tween(Sidebar,{Size=UDim2.new(0,target,1,-72)},0.22)
    Tween(Content,{Position=UDim2.new(0,target+25,0,68),Size=UDim2.new(1,-(target+35),1,-78)},0.22)
    for name,data in pairs(Tabs) do
        data.Button.Text = UI.Compact and tostring(name:sub(1,1)) or data.Button:GetAttribute("FullText") or data.Button.Text
        data.Button.TextXAlignment = UI.Compact and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    end
end

local dragging=false; local dragStart; local startPos
TopBar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=input.Position; startPos=Main.Position end end)
TopBar.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
track(UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then local d=input.Position-dragStart; Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end end))
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() UI.SearchText=SearchBox.Text; UI.RefreshSearch() end)
CompactBtn.MouseButton1Click:Connect(function() setCompact(not UI.Compact) end)
local minimized=false
MinBtn.MouseButton1Click:Connect(function() minimized=not minimized; Sidebar.Visible=not minimized; Content.Visible=not minimized; SearchBox.Visible=not minimized; StatusPill.Visible=not minimized; CompactBtn.Visible=not minimized; Main.Size=minimized and UDim2.fromScale(0.82,0.11) or UDim2.fromScale(0.82,0.80) end)
CloseBtn.MouseButton1Click:Connect(function() HUB.Unload() end)
track(UserInputService.InputBegan:Connect(function(input,gp) if not gp and input.KeyCode==UI.ToggleKey then Main.Visible=not Main.Visible end end))

local function ApplyScale(v)
    UI.Scale=math.clamp(tonumber(v) or 1,0.75,1.35); ScaleObject.Scale=UI.Scale
end

UI.ApplyScale=ApplyScale
UI.SetToggleKey=function(name)
    local map={RightControl=Enum.KeyCode.RightControl,LeftAlt=Enum.KeyCode.LeftAlt,Insert=Enum.KeyCode.Insert,Home=Enum.KeyCode.Home,F6=Enum.KeyCode.F6}
    UI.ToggleKey=map[name] or Enum.KeyCode.RightControl
end
UI.SetCustomHex=function(slot,hex)
    local c=hexToColor3(hex,UI.Theme[slot])
    if c then
        UI.Theme[slot]=c
        UI._customHex[slot]=color3ToHex(c)
        UI.CurrentPreset="Custom"
        UI.ApplyTheme({[slot]=c})
        if UI._themeSelector then UI._themeSelector.Set("Custom") end
        return true
    end
    return false
end


-- CLIENT AC NEUTRALIZER
-- ==============================================================================
local function bypassClientDetections()
    if typeof(filtergc) ~= "function" or typeof(debug) ~= "table" or typeof(debug.getupvalues) ~= "function" then
        return false, "no filtergc"
    end
    local ok, fn = pcall(function()
        return filtergc("function", { Constants = { "gmatch", "GetFullName" } }, true)
    end)
    if not ok or type(fn) ~= "function" then return false, "filter miss" end
    local setMeta = (typeof(setrawmetatable) == "function" and setrawmetatable) or (typeof(setmetatable) == "function" and setmetatable)
    if not setMeta then return false, "no setmeta" end
    local blocked = 0
    local okUv, ups = pcall(debug.getupvalues, fn)
    if not okUv or type(ups) ~= "table" then return false, "no upvalues" end
    for _, tbl in pairs(ups) do
        if typeof(tbl) == "table" then
            local okSet = pcall(setMeta, tbl, { __newindex = function() end })
            if okSet then blocked = blocked + 1 end
        end
    end
    return blocked > 0, blocked
end
pcall(bypassClientDetections)

pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local setmeta = setrawmetatable or setmetatable
    local getmeta = getrawmetatable or getmetatable
    if getgc and setmeta then
        for _, obj in ipairs(getgc(true)) do
            if typeof(obj) == "table" and not (getmeta and getmeta(obj)) then
                local mainrun = false
                for _, v in pairs(obj) do
                    if v == obj then mainrun = true break end
                end
                if mainrun then
                    for _, v in pairs(obj) do
                        if typeof(v) == "number" and v >= 1 and v <= 3 and obj[v] == nil then
                            pcall(setmeta, obj, { __newindex = function() end })
                            break
                        end
                    end
                end
            end
        end
    end
end)

pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local setconstant = setconstant or (debug and debug.setconstant)
    local islclosure = islclosure or function(Function) return not pcall(setfenv, getfenv(Function)) end
    if getgc and getconstants and setconstant then
        for _, Function in ipairs(getgc(true)) do
            if typeof(Function) == "function" and islclosure(Function) then
                local ok, Source = pcall(debug.info, Function, "s")
                if ok and type(Source) == "string" and Source:find("ReplicatedFirst", 1, true) and Source:find("UGI", 1, true) then
                    local okC, Constants = pcall(getconstants, Function)
                    if okC and type(Constants) == "table" then
                        for Index, Constant in next, Constants do
                            if type(Constant) == "string" and Constant == "Humanoid" then
                                pcall(setconstant, Function, Index, "")
                            end
                        end
                    end
                end
            end
        end
    end
end)

pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local islclosure = islclosure or function(fn) return not pcall(setfenv, getfenv(fn)) end
    local HookFn = hookfunction or replaceclosure or hookfunc
    if getgc and getconstants and HookFn and debug and debug.getstack and debug.setstack then
        for _, fn in ipairs(getgc(true)) do
            if typeof(fn) == "function" and islclosure(fn) then
                local ok, consts = pcall(getconstants, fn)
                if ok and type(consts) == "table" and table.find(consts, "X-14") then
                    local cb = nil
                    cb = HookFn(fn, function(...)
                        local stack = debug.getstack(1)
                        if type(stack) == "table" then
                            for idx, val in pairs(stack) do
                                if val == "X-14" then pcall(debug.setstack, 1, idx, nil) end
                            end
                        end
                        if cb then return cb(...) end
                    end)
                end
            end
        end
    end
end)

pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local islclosure = islclosure or function(v) return not pcall(setfenv, getfenv(v)) end
    local getupvalues = getupvalues or (debug and debug.getupvalues)
    local getupvalue = getupvalue or (debug and debug.getupvalue)
    local setupvalue = setupvalue or (debug and debug.setupvalue)
    local clonefunction = clonefunction or function(f) return function(...) return f(...) end end
    if getgc and getupvalues and getupvalue and setupvalue then
        for _, v in ipairs(getgc(true)) do
            if typeof(v) == "function" and islclosure(v) then
                local ok, upvs = pcall(getupvalues, v)
                if ok and upvs and #upvs == 19 then
                    local ok2, u2 = pcall(getupvalue, v, 2)
                    if ok2 and typeof(u2) == "function" then
                        local old = clonefunction(u2)
                        pcall(setupvalue, v, 2, function(a, b)
                            if b and typeof(b) == "table" then pcall(setmetatable, b, {}) end
                            return old(a, b)
                        end)
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- CHARACTER HELPERS
-- ==============================================================================
local function findChar() return LP.Character end
local function findHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function findHRP()
    local ch = LP.Character
    return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart or ch:FindFirstChildWhichIsA("BasePart"))
end

-- ==============================================================================
-- BAC TELEMETRY + EVIDENCE SCRUBBER
-- ==============================================================================
local bxor = bit32.bxor
local function isGuid(n)
    return #n==36 and n:sub(9,9)=="-" and n:sub(14,14)=="-" and n:sub(19,19)=="-" and n:sub(24,24)=="-" and n:gsub("-",""):match("^%x+$")~=nil
end
local remoteSet, anyRemote = {}, nil
local function scanRemotes()
    for _, s in ipairs(game:GetChildren()) do
        local ok, list = pcall(s.GetDescendants, s)
        if ok and list then
            for _, o in ipairs(list) do
                if o:IsA("RemoteEvent") and isGuid(o.Name) then
                    remoteSet[o] = true
                    anyRemote = anyRemote or o
                end
            end
        end
    end
end
scanRemotes()

local function parseCounter(v)
    if type(v) ~= "string" then return end
    local n = v:match("^X%-(%d+)$")
    return n and tonumber(n)
end
local function looksLikeState(t, r)
    if type(t) ~= "table" then return false end
    local hR, hM = false, false
    local ok = pcall(function()
        for _, v in pairs(t) do
            if v == r then hR = true
            elseif type(v) == "string" and v:match("^X%-%d+$") then hM = true end
        end
    end)
    return ok and hR and hM
end
local function findState(r)
    for l=2,24 do
        local _, fn = pcall(debug.info, l, "f")
        if type(fn) == "function" then
            local _, ups = pcall(debug.getupvalues, fn)
            if type(ups) == "table" then
                for _, v in pairs(ups) do
                    if looksLikeState(v, r) then return v end
                    if type(v) == "table" then
                        local nested
                        pcall(function()
                            for _, x in pairs(v) do
                                if looksLikeState(x, r) then nested = x; return end
                            end
                        end)
                        if nested then return nested end
                    end
                end
            end
        end
    end
end
local function mapState(st, a1, a2)
    local m = {}
    for k, v in pairs(st) do
        if type(v) == "string" then
            if v:match("^X%-%d+$") then m.marker = m.marker or k
            elseif a1 and v == a1 then m.arg1 = m.arg1 or k
            elseif a2 and v == a2 then m.arg2 = m.arg2 or k end
        end
    end
    return m
end
local model = nil
local function digits(n) n = n % 1000; return math.floor(n/100), math.floor(n/10)%10, n%10 end
local function encode(m, c)
    local d1, d2, d3 = digits(c)
    return m.prefix .. string.char(bxor(d1, m.k1), bxor(d2, m.k2), bxor(d3, m.k3))
end
local function learn(r, a1, a2)
    local st = findState(r)
    if not st then return end
    local map = mapState(st, a1, a2)
    if not map.marker then return end
    local c = parseCounter(rawget(st, map.marker))
    if not c then return end
    local d1, d2, d3 = digits(c)
    local m = {
        state = st, map = map, remote = r,
        prefix = a1:sub(1, 9),
        k1 = bxor(a1:byte(10), d1),
        k2 = bxor(a1:byte(11), d2),
        k3 = bxor(a1:byte(12), d3),
        offset = c - os.time(),
        arg2 = a2
    }
    if encode(m, c) == a1 then return m end
end
local function liveCounter(m)
    if m.state and m.map.marker then
        local _, raw = pcall(rawget, m.state, m.map.marker)
        local c = parseCounter(raw)
        if c and math.abs((c - os.time()) - m.offset) <= 5 then return c end
    end
    return os.time() + m.offset
end
local function refreshArg2(m)
    if m.state and m.map.arg2 then
        local _, v = pcall(rawget, m.state, m.map.arg2)
        if type(v) == "string" then m.arg2 = v end
    end
    return m.arg2
end

local HookFn = hookfunction or replaceclosure or hookfunc or detour_function
if anyRemote and HookFn then
    local oldFire
    oldFire = HookFn(anyRemote.FireServer, function(self, ...)
        local args = table.pack(...)
        if not remoteSet[self] then return oldFire(self, unpack(args, 1, args.n)) end
        local a1 = args[1]
        if type(a1) == "string" and #a1 == 12 then
            if not model then model = learn(self, a1, args[2])
            else
                local c = parseCounter(rawget(model.state, model.map.marker))
                if c and encode(model, c) ~= a1 then
                    local m = learn(self, a1, args[2])
                    if m then m.spoofed = model.spoofed; model = m end
                end
            end
            return oldFire(self, unpack(args, 1, args.n))
        end
        if model and type(a1) == "string" and #a1 == 4 then
            local c = liveCounter(model)
            args[1] = encode(model, c)
            args[2] = refreshArg2(model)
            model.spoofed = (model.spoofed or 0) + 1
            return oldFire(self, unpack(args, 1, math.max(args.n, 2)))
        end
        return oldFire(self, unpack(args, 1, args.n))
    end)
end

task.spawn(function()
    while not HUB.dead do
        task.wait(10)
        local alive = false
        for r in pairs(remoteSet) do
            if r:IsDescendantOf(game) then alive = true; break end
        end
        if not alive then
            table.clear(remoteSet)
            anyRemote = nil
            model = nil
            scanRemotes()
        end
    end
end)

-- Evidence Scrubber
task.spawn(function()
    if not getgc then return end
    local st = nil
    local function findIntegrityTable()
        local ok, objs = pcall(getgc, true)
        if ok and objs then
            for _, o in pairs(objs) do
                if type(o) == "table" then
                    local hit = false
                    pcall(function()
                        hit = (rawget(o, "ValidationLocked") ~= nil and rawget(o, "Evidence") ~= nil)
                            or (rawget(o, "ThreatLevel") ~= nil and rawget(o, "LastObservedSample") ~= nil)
                    end)
                    if hit then return o end
                end
            end
        end
        return nil
    end
    track(LP.CharacterAdded:Connect(function()
        task.wait(1)
        st = findIntegrityTable()
    end))
    while not HUB.dead do
        if not st then st = findIntegrityTable() end
        if st then
            pcall(function()
                local ev = rawget(st, "Evidence")
                if type(ev) == "table" then
                    if (tonumber(ev.Speed) or 0) > 0 then rawset(ev, "Speed", 0) end
                    if (tonumber(ev.Teleport) or 0) > 0 then rawset(ev, "Teleport", 0) end
                    if (tonumber(ev.Flight) or 0) > 0 then rawset(ev, "Flight", 0) end
                end
                if rawget(st, "ThreatLevel") ~= "Trusted" then rawset(st, "ThreatLevel", "Trusted") end
                if rawget(st, "ValidationLocked") == true then rawset(st, "ValidationLocked", false) end
                if rawget(st, "FirstSuspiciousAt") ~= nil then rawset(st, "FirstSuspiciousAt", nil) end
                if rawget(st, "KickQueued") == true then rawset(st, "KickQueued", false) end
                if rawget(st, "TamperScore") ~= nil then rawset(st, "TamperScore", 0) end
                if rawget(st, "InvalidHeartbeatCount") ~= nil then rawset(st, "InvalidHeartbeatCount", 0) end
                local los = rawget(st, "LastObservedSample")
                if los ~= nil then
                    if rawget(st, "LastGameplayTrustedSample") == nil then rawset(st, "LastGameplayTrustedSample", los) end
                    if rawget(st, "LastValidatedSample") == nil then rawset(st, "LastValidatedSample", los) end
                    if rawget(st, "LastValidatedGroundedSample") == nil then rawset(st, "LastValidatedGroundedSample", los) end
                    if rawget(st, "LastConfirmedGroundSample") == nil then rawset(st, "LastConfirmedGroundSample", los) end
                    if rawget(st, "LastGoodSample") == nil then rawset(st, "LastGoodSample", los) end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- ==============================================================================
-- GAME MODULES
-- ==============================================================================
local EggState, PlotState, AreasData, RarityData, AssetsData, EggToolDisplay, AreaEggSlotIdentity
pcall(function() EggState = require(RS.Client.EggState) end)
pcall(function() PlotState = require(RS.Client.PlotState) end)
pcall(function() AreasData = require(RS.Data.Areas) end)
pcall(function() RarityData = require(RS.Data.Rarity) end)
pcall(function() AssetsData = require(RS.Data.Assets) end)
local SaveModule
pcall(function() SaveModule = require(RS.Shared.Save) end)
pcall(function() EggToolDisplay = require(RS.Shared.Eggs.EggToolDisplay) end)
pcall(function()
    AreaEggSlotIdentity = (RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("Util") and require(RS.Shared.Util.AreaEggSlotIdentity))
        or (RS:FindFirstChild("Util") and require(RS.Util.AreaEggSlotIdentity))
        or (RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("Utils") and require(RS.Shared.Utils.AreaEggSlotIdentity))
end)

local function GetNetRemote(name)
    local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
    return net and net:FindFirstChild(name)
end
local function GetLocalSlot()
    if PlotState and PlotState.ResolveLocalSlot then
        local ok, slot = pcall(PlotState.ResolveLocalSlot)
        if ok and slot then return slot end
    end
    return 1
end
local function GetLocalPlotCenter()
    local plotObj = PlotState and PlotState.ResolvePlot and PlotState.ResolvePlot()
    local pt = plotObj and plotObj.CenterPoint and (typeof(plotObj.CenterPoint) == "Vector3" and plotObj.CenterPoint or (plotObj.CenterPoint:IsA("BasePart") and plotObj.CenterPoint.Position))
    if pt then return Vector3.new(pt.X, math.max(pt.Y, 70.4), pt.Z), CFrame.new(pt.X, math.max(pt.Y, 70.4), pt.Z) end
    return Vector3.new(464.7, 70.4, -364.0), CFrame.new(464.7, 70.4, -364.0)
end

-- ==============================================================================
-- MOVEMENT / STEAL ENGINE
-- ==============================================================================
local MAIN_ROAD_Z = -364.5
local stealMovementMethod = "Tween Glide"
local avoidTrapsEnabled = true
local autoClaimMonsterChests = false
local autoFeedMonster = false

local function instantTP(cframe)
    local root = findHRP()
    if not root then return end
    root.CFrame = cframe
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function heartbeatTP(cframeTarget, holdTime)
    local root = findHRP()
    if not root then return end
    local char = LP.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
        end
    end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = findHRP()
        if r and r.Parent then
            r.CFrame = cframeTarget
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    task.wait(holdTime or 0.25)
    if conn then conn:Disconnect() end
    local r2 = findHRP()
    if r2 then
        r2.CFrame = cframeTarget
        r2.AssemblyLinearVelocity = Vector3.zero
        r2.AssemblyAngularVelocity = Vector3.zero
    end
end

local BYPASS_FLOAT_HEIGHT = 6.7
local BYPASS_LEG_OFFSET = Vector3.new(0, -6.7, 0)
local BYPASS_TP_OFFSET = Vector3.new(0, 6.7, 0)

local function bypassReturnTP(safeCFrame, holdTime)
    local hrp = findHRP()
    if not hrp then return false end
    local targetPart = Workspace:FindFirstChild("SpawnLocation", true)
    if not targetPart or not targetPart:IsA("BasePart") then
        heartbeatTP(safeCFrame, holdTime or 0.3)
        return true
    end
    pcall(function() targetPart.CanCollide = false end)
    local char = LP.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
        end
    end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = findHRP()
        if not r or not r.Parent then return end
        pcall(function() targetPart.CFrame = r.CFrame * CFrame.new(BYPASS_LEG_OFFSET) end)
        r.CFrame = safeCFrame + BYPASS_TP_OFFSET
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        pcall(function() targetPart.CFrame = safeCFrame end)
    end)
    task.wait(holdTime or 0.35)
    if conn then conn:Disconnect() end
    local r2 = findHRP()
    if r2 then
        r2.CFrame = safeCFrame
        r2.AssemblyLinearVelocity = Vector3.zero
        r2.AssemblyAngularVelocity = Vector3.zero
    end
    return true
end

local function restoreCollisions()
    local char = LP.Character
    if not char or not char.Parent then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = true
        end
    end
end

local function NeutralizeTraps()
    local debris = Workspace:FindFirstChild("__DEBRIS")
    if not debris then return end
    for _, d in ipairs(debris:GetChildren()) do
        if d.Name == "PlayerTrap" and d:GetAttribute("Owner") ~= LP.Name then
            if d:IsA("BasePart") then d.CanTouch = false; d.CanQuery = false end
            for _, c in ipairs(d:GetChildren()) do
                if c:IsA("BasePart") then
                    c.CanTouch = false; c.CanQuery = false
                    if c.Name == "Hitbox" then c.CFrame = CFrame.new(0, -999, 0) end
                end
            end
            local tt = d:FindFirstChildWhichIsA("TouchTransmitter", true)
            if tt then pcall(function() tt:Destroy() end) end
        end
    end
end

local glideSpeed = 750
local function MoveToPoint(target, speed, easeOut)
    local hrp = findHRP()
    if not hrp or not target then return false end
    local start = hrp.Position
    local dist = (target - start).Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    speed = math.clamp(tonumber(speed) or glideSpeed or 750, 50, 750)
    local t0 = os.clock()
    local totalDist = dist
    while not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        local curPos = hrp.Position
        local toTarget = target - curPos
        local remain = toTarget.Magnitude
        if remain < 1.0 then break end
        local stepSpeed = speed
        if easeOut then
            local progress = 1 - math.clamp(remain / totalDist, 0, 1)
            stepSpeed = math.max(speed * (1 - progress * 0.8), 35)
        end
        local step = math.min(stepSpeed * dt, remain)
        local dir = toTarget.Unit
        local nextPos = curPos + dir * step
        hrp.CFrame = CFrame.lookAt(nextPos, nextPos + dir)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if os.clock() - t0 > (totalDist / 50 + 5) then break end
    end
    hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function FlyToPoint(target, speed, easeOut)
    local hrp = findHRP()
    if not hrp or not target then return false end
    local start = hrp.Position
    local dist = (target - start).Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    speed = math.clamp(tonumber(speed) or glideSpeed or 750, 50, 750)
    local moveTime = math.max(dist / speed, 0.02)
    if easeOut then moveTime = moveTime * 1.25 end
    local t0 = os.clock()
    local delta = target - start
    local dir = delta.Magnitude > 0.001 and delta.Unit or Vector3.new(1, 0, 0)
    while os.clock() - t0 < moveTime and not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        local linearAlpha = math.clamp((os.clock() - t0) / moveTime, 0, 1)
        local a = linearAlpha
        if easeOut then a = math.sin(linearAlpha * (math.pi / 2)) end
        local cur = start:Lerp(target, a)
        hrp.CFrame = CFrame.lookAt(cur, cur + dir)
        local curSpeed = speed
        if easeOut then curSpeed = math.max(speed * (1 - linearAlpha * 0.8), 35) end
        hrp.AssemblyLinearVelocity = Vector3.new(dir.X * curSpeed, math.clamp(dir.Y * curSpeed, -15, 150), dir.Z * curSpeed)
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

local SAFE_BOUNDARY_X = 580
local SAFE_ZONE_SPEED = 245

local function TravelRoadPath(targetPos, speed, isApproach)
    local hrp = findHRP()
    if not hrp or not targetPos then return false end
    if avoidTrapsEnabled then pcall(NeutralizeTraps) end
    local startPos = hrp.Position
    local safeY = math.max(startPos.Y, targetPos.Y, 70.4)
    local isReturningToBase = (targetPos.X < 560)
    if isReturningToBase and startPos.X > SAFE_BOUNDARY_X then
        local p1 = Vector3.new(startPos.X, safeY, MAIN_ROAD_Z)
        MoveToPoint(p1, speed, false)
        local pSafeApproach = Vector3.new(SAFE_BOUNDARY_X, safeY, MAIN_ROAD_Z)
        MoveToPoint(pSafeApproach, speed, false)
        local pBaseRoad = Vector3.new(targetPos.X, safeY, MAIN_ROAD_Z)
        MoveToPoint(pBaseRoad, SAFE_ZONE_SPEED, false)
        local pPen = targetPos + Vector3.new(0, 1.2, 0)
        MoveToPoint(pPen, SAFE_ZONE_SPEED, isApproach == true)
        return true
    else
        local p1 = Vector3.new(startPos.X, safeY, MAIN_ROAD_Z)
        local p2 = Vector3.new(targetPos.X, safeY, MAIN_ROAD_Z)
        local p3 = targetPos + Vector3.new(0, 1.2, 0)
        MoveToPoint(p1, speed, false)
        MoveToPoint(p2, speed, false)
        MoveToPoint(p3, speed, isApproach == true)
        return true
    end
end

local function TravelFlyDirect(targetPos, speed, isApproach)
    local hrp = findHRP()
    if not hrp or not targetPos then return false end
    if avoidTrapsEnabled then pcall(NeutralizeTraps) end
    local startPos = hrp.Position
    local isReturningToBase = (targetPos.X < 560)
    local flyAltitude = math.max(startPos.Y, targetPos.Y, 70.4) + 28
    if isReturningToBase and startPos.X > SAFE_BOUNDARY_X then
        local pSky1 = Vector3.new(startPos.X, flyAltitude, startPos.Z)
        local pSkySafe = Vector3.new(SAFE_BOUNDARY_X, flyAltitude, MAIN_ROAD_Z)
        FlyToPoint(pSky1, speed, false)
        FlyToPoint(pSkySafe, speed, false)
        local pGroundSafe = Vector3.new(SAFE_BOUNDARY_X, 70.4, MAIN_ROAD_Z)
        FlyToPoint(pGroundSafe, SAFE_ZONE_SPEED, false)
        local pBaseRoad = Vector3.new(targetPos.X, 70.4, MAIN_ROAD_Z)
        MoveToPoint(pBaseRoad, SAFE_ZONE_SPEED, false)
        local pPen = targetPos + Vector3.new(0, 1.2, 0)
        MoveToPoint(pPen, SAFE_ZONE_SPEED, isApproach == true)
        return true
    else
        local totalDist = (targetPos - startPos).Magnitude
        if totalDist < 25 then
            FlyToPoint(Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z), speed, isApproach == true)
            return true
        end
        local pSky1 = Vector3.new(startPos.X, flyAltitude, startPos.Z)
        local pSky2 = Vector3.new(targetPos.X, flyAltitude, targetPos.Z)
        local pGround = Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z)
        FlyToPoint(pSky1, speed, false)
        FlyToPoint(pSky2, speed, false)
        FlyToPoint(pGround, speed, isApproach == true)
        return true
    end
end

local function TravelSafeWalk(targetPos)
    local hum = findHum()
    local hrp = findHRP()
    if not hum or not hrp or not targetPos then return false end
    if avoidTrapsEnabled then pcall(NeutralizeTraps) end
    local startPos = hrp.Position
    local p1 = Vector3.new(startPos.X, startPos.Y, MAIN_ROAD_Z)
    local p2 = Vector3.new(targetPos.X, targetPos.Y, MAIN_ROAD_Z)
    local p3 = targetPos + Vector3.new(0, 1.2, 0)
    for _, pt in ipairs({ p1, p2, p3 }) do
        if HUB.dead then break end
        hum:MoveTo(pt)
        local t0 = os.clock()
        while (hrp.Position - pt).Magnitude > 4.5 and os.clock() - t0 < 5 and not HUB.dead do
            task.wait(0.05)
        end
    end
    return true
end

local function TravelToDestination(targetPos, speed, isApproach)
    if stealMovementMethod == "Fly Glide" then
        return TravelFlyDirect(targetPos, speed, isApproach)
    elseif stealMovementMethod == "Safe Walk" then
        return TravelSafeWalk(targetPos)
    else
        return TravelRoadPath(targetPos, speed, isApproach)
    end
end

-- ==============================================================================
-- RARITY / AREA DATA
-- ==============================================================================
local RARITY_SCORE_MAP = {
    ["Titan"] = 1100, ["Divine"] = 1000, ["Transcendent"] = 1000, ["Superior"] = 1000,
    ["Eternal"] = 900, ["Limited"] = 900, ["Secret"] = 800, ["Exotic"] = 800,
    ["Cosmic"] = 700, ["Exclusive"] = 700, ["Admin"] = 700, ["Mythic"] = 600,
    ["Mythical"] = 600, ["Prismatic"] = 600, ["Rainbow"] = 600, ["Squishy God"] = 600,
    ["BrainrotGod"] = 600, ["Legendary"] = 500, ["Epic"] = 400, ["Rare"] = 300,
    ["SuperRare"] = 200, ["Celestial"] = 200, ["Uncommon"] = 200, ["Basic"] = 100, ["Common"] = 100,
}

local AREA_COORDINATES = {
    ["Base / Plot"] = Vector3.new(491.7, 70.4, -364.4),
    ["Stands & Shops"] = Vector3.new(539.5, 68.0, -364.5),
    ["Forest"] = Vector3.new(596.0, 68.0, -328.0),
    ["Lake"] = Vector3.new(744.0, 68.5, -408.0),
    ["Desert"] = Vector3.new(948.0, 69.5, -323.0),
    ["Jungle"] = Vector3.new(1188.0, 68.5, -408.0),
    ["Snow"] = Vector3.new(1492.0, 69.0, -315.0),
    ["Volcano"] = Vector3.new(1882.0, 68.0, -398.0),
    ["Abyss Ocean"] = Vector3.new(2280.0, 68.0, -326.0),
    ["Prehistoric"] = Vector3.new(2812.0, 69.0, -398.0),
    ["Cosmic"] = Vector3.new(3390.0, 68.0, -324.0),
    ["Cherry Blossom"] = Vector3.new(4028.0, 68.5, -396.0),
    ["Titan Temple"] = Vector3.new(4796.0, 69.5, -328.0),
    ["Monster Event"] = Vector3.new(539.5, 68.0, -411.3),
    ["Dragon Event"] = Vector3.new(539.5, 68.0, -318.0),
}

local AREA_NAMES = { "Forest", "Lake", "Desert", "Jungle", "Snow", "Volcano", "Abyss Ocean", "Prehistoric", "Cosmic", "Cherry Blossom", "Titan Temple", "Monster Event", "Dragon Event" }
local RARITY_NAMES = { "Titan", "Divine", "Superior", "Eternal", "Limited", "Secret", "Exotic", "Cosmic", "Exclusive", "Mythic", "Rainbow", "Squishy God", "Legendary", "Epic", "Rare", "Uncommon", "Common" }
local MUTATION_FILTERS = { "Normal Only", "Mutated Only", "Parasite / Infested", "Rainbow Only", "Gold Only", "Silver Only", "Monstrous" }

-- ==============================================================================
-- AUTOMATION STATE
-- ==============================================================================
local autoStealEnabled = false
local autoJumpEnabled = true
local rareEggHunter = true
local stealParasiteOnly = false
local stealBigEggsOnly = false
local selectedStealRarities = {}
local selectedStealAreas = {}
local selectedMutationTypes = {}
local stealDelay = 1.5
local ignoredEggs = {}
local savedReturnCFrame = nil
local autoHatchEnabled = false
local autoPlantEnabled = false
local hatchCheckDelay = 2.0
local autoUpgradeBase = false
local autoUpgradeTreadmill = false
local autoTrainSpeed = false
local autoBuyTrails = false
local autoEquipBestPets = false
local autoClaimRewards = false
local autoSellPets = false
local autoSellEggs = false
local selectedSellPetRarities = {}
local selectedSellEggRarities = {}
local DEFAULT_LOW_TIER_SELL = { ["Common"] = true, ["Uncommon"] = true, ["Rare"] = true, ["Epic"] = true, ["Legendary"] = true, ["Mythic"] = true }
local SELL_REQUEST_DELAY = 0.1
local instantPickupEnabled = true
local noKnockbackEnabled = true
local batAuraEnabled = false
local batAuraRadius = 20
local batAuraDelay = 0.2
local antiRagdollEnabled = true

local function getSellRarityFilter(selected)
    if not selected or next(selected) == nil then return DEFAULT_LOW_TIER_SELL end
    return selected
end

-- ==============================================================================
-- EGG CORE LOGIC
-- ==============================================================================
local function GetEggRarityInfo(egg)
    if not egg then return "Common", 100 end
    if egg.Rarity then
        local r = egg.Rarity
        local name = type(r) == "table" and (r.DisplayName or r._id or r.Name) or tostring(r)
        local score = RARITY_SCORE_MAP[name] or (type(r) == "table" and tonumber(r.RarityNumber) and r.RarityNumber * 100) or 100
        return name, score
    end
    local cat = egg.AssetCategory or egg.Category or egg.Name
    if cat and AssetsData then
        local assetsDir = AssetsData.Directory or AssetsData
        local aInfo = assetsDir[cat]
        if aInfo and aInfo.Rarity then
            local r = aInfo.Rarity
            local name = type(r) == "table" and (r.DisplayName or r._id or r.Name) or tostring(r)
            local score = RARITY_SCORE_MAP[name] or (type(r) == "table" and tonumber(r.RarityNumber) and r.RarityNumber * 100) or 100
            return name, score
        end
    end
    local areaData = AreasData and (AreasData.Directory or AreasData) and (AreasData.Directory or AreasData)[egg.AreaId]
    local rarity = areaData and areaData.Rarity
    local rarityId = (type(rarity) == "table" and (rarity._id or rarity.DisplayName or rarity.Name)) or (type(rarity) == "string" and rarity) or "Common"
    local raritiesTable = RarityData and (RarityData.Rarities or RarityData) or {}
    local rInfo = raritiesTable[rarityId] or {}
    local rarityDisplayName = (type(rInfo) == "table" and (rInfo.DisplayName or rInfo._id)) or (type(rarity) == "table" and rarity.DisplayName) or rarityId or "Common"
    local baseScore = RARITY_SCORE_MAP[rarityDisplayName] or RARITY_SCORE_MAP[rarityId] or (type(rarity) == "table" and tonumber(rarity.RarityNumber) and rarity.RarityNumber * 100) or 100
    return rarityDisplayName, baseScore
end

local function isRarityAllowed(rarityName, filter)
    if not filter or type(filter) ~= "table" then return true end
    local count = 0
    for _ in pairs(filter) do count = count + 1 end
    if count == 0 then return true end
    if filter[rarityName] == true then return true end
    local rLower = string.lower(tostring(rarityName))
    for k, v in pairs(filter) do
        if type(v) == "string" and string.lower(v) == rLower then return true
        elseif type(k) == "string" and string.lower(k) == rLower and v == true then return true end
    end
    return false
end

local function isAreaAllowed(areaId, filter)
    if not filter or type(filter) ~= "table" then return true end
    local count = 0
    for _ in pairs(filter) do count = count + 1 end
    if count == 0 then return true end
    if filter[areaId] == true then return true end
    local aLower = string.lower(tostring(areaId))
    for k, v in pairs(filter) do
        if type(v) == "string" and string.lower(v) == aLower then return true
        elseif type(k) == "string" and string.lower(k) == aLower and v == true then return true end
    end
    return false
end

local function isMutationAllowed(muts, record, filter)
    local isParasite = (record and record.HasParasite == true)
        or (type(muts) == "table" and (table.find(muts, "Parasite") or table.find(muts, "Monstrous")))
        or (record and (record.BaseMutation == "Parasite" or record.BaseMutation == "Monstrous"))
    if stealParasiteOnly and not isParasite then return false end
    if not filter or type(filter) ~= "table" then return true end
    local count = 0
    for _ in pairs(filter) do count = count + 1 end
    if count == 0 then return true end
    local hasMut = type(muts) == "table" and #muts > 0
    local allowed = false
    for _, opt in pairs(filter) do
        if type(opt) == "string" then
            if opt == "Normal Only" and not hasMut and not isParasite then allowed = true
            elseif opt == "Mutated Only" and (hasMut or isParasite) then allowed = true
            elseif (opt == "Parasite / Infested" or opt == "Monstrous") and isParasite then allowed = true
            elseif opt == "Silver Only" and type(muts) == "table" and table.find(muts, "Silver") then allowed = true
            elseif opt == "Gold Only" and type(muts) == "table" and (table.find(muts, "Gold") or table.find(muts, "Golden")) then allowed = true
            elseif opt == "Rainbow Only" and type(muts) == "table" and table.find(muts, "Rainbow") then allowed = true end
        end
    end
    return allowed
end

local function isBigEgg(record)
    if not record then return false end
    local scale = tonumber(record.AssetScale) or 1
    local nestScale = tonumber(record.NestScale) or 1
    return scale >= 1.35 or nestScale >= 1.0
end

local function GetMatchingFieldEggs(areasFilter, raritiesFilter, mutationsFilter)
    if not EggState or not EggState.ReadFieldEggs then return {} end
    local ok, snapshot = pcall(EggState.ReadFieldEggs)
    if not ok or not snapshot or not snapshot.Records then return {} end
    local matched = {}
    for _, record in ipairs(snapshot.Records) do
        if record.State == "Slot" and record.BoundsCFrame then
            local isIgnored = ignoredEggs[record.Uid] and (os.clock() - ignoredEggs[record.Uid] < 2.5)
            if not isIgnored and (not stealBigEggsOnly or isBigEgg(record)) then
                local areaOk = isAreaAllowed(record.AreaId, areasFilter)
                local rarityName, baseScore = GetEggRarityInfo(record)
                local rarityOk = isRarityAllowed(rarityName, raritiesFilter)
                local muts = record.Mutations or {}
                local mutOk = isMutationAllowed(muts, record, mutationsFilter)
                if areaOk and rarityOk and mutOk then
                    local mutBonus = 0
                    for _, m in ipairs(muts) do
                        if m == "Rainbow" then mutBonus = mutBonus + 35
                        elseif m == "Gold" or m == "Golden" then mutBonus = mutBonus + 20
                        elseif m == "Silver" then mutBonus = mutBonus + 10 end
                    end
                    if record.HasParasite == true or (type(muts) == "table" and (table.find(muts, "Parasite") or table.find(muts, "Monstrous"))) then
                        mutBonus = mutBonus + 800
                    end
                    if isBigEgg(record) then mutBonus = mutBonus + 600 end
                    table.insert(matched, { record = record, rarity = rarityName, score = baseScore + mutBonus })
                end
            end
        end
    end
    if #matched > 1 then
        table.sort(matched, function(a, b) return a.score > b.score end)
    end
    return matched
end

local function EnsureSavedReturnPosition()
    if not savedReturnCFrame then
        local hrp = findHRP()
        if hrp then savedReturnCFrame = hrp.CFrame end
    end
end

local function isPlayerCarryingEgg()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local dropGui = pg and pg:FindFirstChild("DropHeldEgg")
    if dropGui and dropGui.Enabled == true then return true end
    local char = LP.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Model") and (t.Name:lower():find("egg") or t:GetAttribute("Uid") or t:GetAttribute("AssetCategory")) then return true end
            if t:IsA("Tool") then
                if EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then return true end
                if t:GetAttribute("IsEgg") == true or t:GetAttribute("Uid") ~= nil or t:GetAttribute("AssetCategory") ~= nil then return true end
                local tName = t.Name:lower()
                if tName:find("egg") or (tName ~= "bat" and tName ~= "defaulttool" and not tName:find("bat") and not tName:find("slap") and not tName:find("coil") and not tName:find("potion") and not tName:find("lantern")) then
                    return true
                end
            end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then return true end
        end
    end
    return false
end

local function PlantAllCarriedEggsInPen()
    local toolsToPlant = {}
    for _, t in ipairs(LP.Character:GetChildren()) do
        if t:IsA("Tool") and EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then
            local uid = EggToolDisplay.GetToolUid(t)
            if uid then table.insert(toolsToPlant, uid) end
        end
    end
    for _, t in ipairs(LP.Backpack:GetChildren()) do
        if t:IsA("Tool") and EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then
            local uid = EggToolDisplay.GetToolUid(t)
            if uid then table.insert(toolsToPlant, uid) end
        end
    end
    local plantedCount = 0
    for _, eggUid in ipairs(toolsToPlant) do
        for attempt = 1, 3 do
            local offset = CFrame.new(math.random(-6, 6), 0, math.random(-6, 6))
            local ok, res = pcall(function()
                if EggState and EggState.PlantEgg then return EggState.PlantEgg(eggUid, offset) end
                return false
            end)
            if ok and res then plantedCount = plantedCount + 1 break end
            task.wait(0.1)
        end
    end
    return plantedCount
end

local function StealSpecificEggRobust(targetItem)
    local record = targetItem.record or targetItem
    if not record or not record.Uid or not record.BoundsCFrame then return false end
    if EggState and EggState.ReadFieldEggs then
        local ok, snap = pcall(EggState.ReadFieldEggs)
        if ok and snap and snap.Records then
            local stillThere = false
            for _, r in ipairs(snap.Records) do
                if r.Uid == record.Uid and r.State == "Slot" then stillThere = true; record = r; break end
            end
            if not stillThere then return false end
        end
    end
    local hrp = findHRP()
    if not hrp then return false end
    EnsureSavedReturnPosition()
    local targetPos = record.BoundsCFrame.Position
    local speed = math.clamp(tonumber(glideSpeed) or 750, 50, 750)
    local isInstantTP = (stealMovementMethod == "Anti Guard")
    TravelToDestination(targetPos + Vector3.new(0, 1.2, 0), speed, true)
    if hrp then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.2, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    task.wait(isInstantTP and 0.25 or 0.5)

    local slotKey = nil
    if AreaEggSlotIdentity and AreaEggSlotIdentity.LooksLikeFirstAreaUid and AreaEggSlotIdentity.LooksLikeFirstAreaUid(record.Uid) then
        slotKey = AreaEggSlotIdentity.SlotKey(record.AreaId, record.NestId)
    end
    local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
    local carryRemote = net and net:FindFirstChild("RF/EggWorld/AskFieldEggCarry")
    if carryRemote then pcall(function() carryRemote:InvokeServer({ Uid = record.Uid, FirstAreaSlotKey = slotKey }) end) end
    pcall(function() if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end end)

    local prompt = nil
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Name == "CarryAreaEgg" and d.Enabled then
            local act = (d.ActionText or ""):lower()
            local obj = (d.ObjectText or ""):lower()
            if not act:find("skip") and not act:find("robux") and not obj:find("skip") and not obj:find("robux") then
                local p = d.Parent
                if p:IsA("Attachment") then p = p.Parent end
                if p and (p.Position - hrp.Position).Magnitude < 14 then prompt = d; break end
            end
        end
    end
    if prompt then
        prompt.HoldDuration = 0
        pcall(function() fireproximityprompt(prompt) end)
        pcall(function() fireproximityprompt(prompt, 0) end)
    end

    local safePlotCenter = GetLocalPlotCenter()
    local safeCFrame = CFrame.new(safePlotCenter + Vector3.new(0, 1.2, 0))
    local tPickup = os.clock()
    local carried = false
    local instantFired = false
    local conns = {}
    local function fireInstantNow()
        if instantFired then return end
        instantFired = true
        carried = true
        task.spawn(function()
            bypassReturnTP(safeCFrame, 0.35)
            pcall(restoreCollisions)
            pcall(PlantAllCarriedEggsInPen)
        end)
    end
    if isInstantTP then
        local char = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        pcall(function()
            if char then table.insert(conns, char.ChildAdded:Connect(function() if isPlayerCarryingEgg() then fireInstantNow() end end)) end
            if bp then table.insert(conns, bp.ChildAdded:Connect(function() if isPlayerCarryingEgg() then fireInstantNow() end end)) end
            if pg then
                table.insert(conns, pg.ChildAdded:Connect(function(c) if c.Name == "DropHeldEgg" then fireInstantNow() end end))
                local dg = pg:FindFirstChild("DropHeldEgg")
                if dg then table.insert(conns, dg:GetPropertyChangedSignal("Enabled"):Connect(function() if dg.Enabled then fireInstantNow() end end)) end
            end
        end)
    end
    local maxWait = isInstantTP and 1.2 or 1.5
    while os.clock() - tPickup < maxWait and not HUB.dead do
        if carried or instantFired then carried = true; break end
        if isPlayerCarryingEgg() then carried = true; break end
        pcall(function() if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end end)
        if prompt then prompt.HoldDuration = 0; pcall(function() fireproximityprompt(prompt) end) end
        task.wait(isInstantTP and 0.03 or 0.08)
    end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end

    if not carried then
        ignoredEggs[record.Uid] = os.clock()
        if isInstantTP then bypassReturnTP(safeCFrame, 0.2); restoreCollisions() end
        return false
    end

    do
        local guardHitEnabled = true
        if guardHitEnabled and carried then
            local tGuardStart = os.clock()
            local startHealth = 100
            local hum0 = findHum()
            if hum0 then startHealth = hum0.Health end
            local wasHit = false
            while os.clock() - tGuardStart < 4.0 and not HUB.dead do
                if not isPlayerCarryingEgg() then wasHit = true; break end
                local h = findHum()
                if h then
                    local hs = h:GetState()
                    if h.Health < startHealth - 1.5 or hs == Enum.HumanoidStateType.Physics or hs == Enum.HumanoidStateType.Ragdoll or hs == Enum.HumanoidStateType.FallingDown then
                        wasHit = true
                        local tPost = os.clock()
                        while os.clock() - tPost < 0.85 and not HUB.dead do
                            if not isPlayerCarryingEgg() then break end
                            task.wait(0.05)
                        end
                        break
                    end
                end
                task.wait(0.05)
            end
            if wasHit or not isPlayerCarryingEgg() then
                task.wait(0.65)
                do
                    local tRag = os.clock()
                    while os.clock() - tRag < 3.2 and not HUB.dead do
                        local h = findHum()
                        if not h then break end
                        local hs = h:GetState()
                        if hs ~= Enum.HumanoidStateType.Physics and hs ~= Enum.HumanoidStateType.Ragdoll and hs ~= Enum.HumanoidStateType.FallingDown then break end
                        pcall(function() h:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                        task.wait(0.12)
                    end
                    task.wait(0.35)
                end
                local hrpNow = findHRP()
                if hrpNow and (hrpNow.Position - targetPos).Magnitude > 14 then
                    pcall(function()
                        hrpNow.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.8, 0))
                        hrpNow.AssemblyLinearVelocity = Vector3.zero
                        hrpNow.AssemblyAngularVelocity = Vector3.zero
                    end)
                    task.wait(0.35)
                end
                do
                    local tStand = os.clock()
                    while os.clock() - tStand < 1.5 and not HUB.dead do
                        local h = findHum()
                        if h and h:GetState() ~= Enum.HumanoidStateType.Physics and h:GetState() ~= Enum.HumanoidStateType.Ragdoll then break end
                        task.wait(0.08)
                    end
                end
                do
                    local tGuardSleep = os.clock()
                    while os.clock() - tGuardSleep < 4.5 and not HUB.dead do
                        local guardAsleep = false
                        pcall(function()
                            local areasRoot = Workspace:FindFirstChild("__OBJECTS") and Workspace.__OBJECTS:FindFirstChild("Areas") and Workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
                            local guardModel = nil
                            if areasRoot and record.AreaId then
                                local areaFolder = areasRoot:FindFirstChild(record.AreaId)
                                if areaFolder then
                                    guardModel = areaFolder:FindFirstChild("Guard") or areaFolder:FindFirstChild("ForestGuardAuthored") or areaFolder:FindFirstChildWhichIsA("Model", true)
                                end
                            end
                            if not guardModel then
                                local nearest, nd = nil, 1e9
                                for _, m in ipairs(Workspace:GetDescendants()) do
                                    if m:IsA("Model") and m.Name:lower():find("guard") and m.PrimaryPart then
                                        local d = (m.PrimaryPart.Position - targetPos).Magnitude
                                        if d < nd and d < 90 then nd = d; nearest = m end
                                    end
                                end
                                guardModel = nearest
                            end
                            if guardModel then
                                local alert = guardModel:GetAttribute("Alert") or guardModel:GetAttribute("Alerted") or guardModel:GetAttribute("IsAlerted") or guardModel:GetAttribute("Chasing")
                                local sleeping = guardModel:GetAttribute("Sleeping") or guardModel:GetAttribute("IsSleeping") or guardModel:GetAttribute("Asleep") or guardModel:GetAttribute("Sleep")
                                local state = guardModel:GetAttribute("State")
                                if sleeping == true then guardAsleep = true
                                elseif alert == false or alert == nil then
                                    local hum = guardModel:FindFirstChildOfClass("Humanoid")
                                    local hrpG = guardModel.PrimaryPart or guardModel:FindFirstChild("HumanoidRootPart") or guardModel:FindFirstChildWhichIsA("BasePart", true)
                                    local eggPoint = guardModel:FindFirstChild("EggPoint", true)
                                    if hrpG and eggPoint then
                                        local distToHome = (hrpG.Position - eggPoint.Position).Magnitude
                                        if distToHome < 7 and (not hum or hum.MoveDirection.Magnitude < 0.12) then guardAsleep = true
                                        elseif distToHome < 12 and os.clock() - tGuardSleep > 1.2 and (not hum or hum.MoveDirection.Magnitude < 0.15) then guardAsleep = true end
                                    elseif state and tostring(state):lower():find("sleep") then guardAsleep = true
                                    elseif alert == nil and sleeping == nil and state == nil then
                                        if os.clock() - tGuardSleep > 1.6 then guardAsleep = true end
                                    elseif alert == false then guardAsleep = true end
                                end
                                if not guardAsleep then
                                    local alertGui = guardModel:FindFirstChild("Alert", true)
                                    if alertGui and alertGui:IsA("BillboardGui") and alertGui.Enabled == false then guardAsleep = true end
                                end
                            else
                                if os.clock() - tGuardSleep > 1.4 then guardAsleep = true end
                            end
                        end)
                        if guardAsleep then break end
                        task.wait(0.14)
                    end
                    task.wait(0.08)
                end
                task.wait(0.08)
                pcall(function() if carryRemote then carryRemote:InvokeServer({ Uid = record.Uid, FirstAreaSlotKey = slotKey }) end end)
                pcall(function() if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end end)
                task.wait(0.08)
                local prompt2 = nil
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Name == "CarryAreaEgg" and d.Enabled then
                        local p = d.Parent
                        if p and p:IsA("Attachment") then p = p.Parent end
                        if p then
                            local dist = (p.Position - (findHRP() and findHRP().Position or targetPos)).Magnitude
                            if dist < 16 then
                                local act = (d.ActionText or ""):lower()
                                if not act:find("skip") and not act:find("robux") then prompt2 = d; break end
                            end
                        end
                    end
                end
                if prompt2 then
                    prompt2.HoldDuration = 0
                    pcall(function() fireproximityprompt(prompt2) end)
                    pcall(function() fireproximityprompt(prompt2, 0) end)
                end
                local tPickup2 = os.clock()
                while os.clock() - tPickup2 < 2.2 and not HUB.dead do
                    if isPlayerCarryingEgg() then carried = true; break end
                    pcall(function() if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end end)
                    if prompt2 then pcall(function() fireproximityprompt(prompt2) end) end
                    task.wait(0.06)
                end
                if isPlayerCarryingEgg() then carried = true end
                if isPlayerCarryingEgg() then
                    task.wait(0.12)
                    isInstantTP = false
                end
            end
        end
    end

    if isInstantTP then
        if not instantFired then
            bypassReturnTP(safeCFrame, 0.35)
            task.spawn(function()
                pcall(restoreCollisions)
                pcall(PlantAllCarriedEggsInPen)
            end)
        end
    else
        if speed > 250 then
            local hrpNow = findHRP()
            local curPos = hrpNow and hrpNow.Position or targetPos
            local toBase = safePlotCenter - curPos
            local distBase = toBase.Magnitude
            if distBase > 45 then
                local stagePos = safePlotCenter - toBase.Unit * 35
                stagePos = Vector3.new(stagePos.X, math.max(stagePos.Y, 70.4), stagePos.Z)
                TravelToDestination(stagePos, speed, false)
                local hrp2 = findHRP()
                if hrp2 then hrp2.AssemblyLinearVelocity = Vector3.zero; hrp2.AssemblyAngularVelocity = Vector3.zero end
                task.wait(0.35)
            end
            TravelToDestination(safePlotCenter, 240, true)
        else
            TravelToDestination(safePlotCenter, speed, true)
        end
    end

    local tDeliver = os.clock()
    while os.clock() - tDeliver < 1.5 and isPlayerCarryingEgg() and not HUB.dead do task.wait(0.08) end
    PlantAllCarriedEggsInPen()

    local char = LP.Character
    local h = char and char:FindFirstChild("HumanoidRootPart")
    local hu = char and char:FindFirstChildOfClass("Humanoid")
    if h then
        h.CFrame = CFrame.new(safePlotCenter.X, math.max(safePlotCenter.Y, 70.4), safePlotCenter.Z)
        h.AssemblyLinearVelocity = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero
    end
    if hu then
        hu.PlatformStand = false
        hu.AutoRotate = true
        pcall(function() hu:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    return carried or isPlayerCarryingEgg()
end

local function HatchAllReadyEggs()
    if not EggState or not EggState.ReadOwnedEggs then return 0 end
    local ok, snapshot = pcall(EggState.ReadOwnedEggs, LP.UserId)
    if not ok or not snapshot then return 0 end
    local count = 0
    local records = snapshot.Records or snapshot
    if typeof(records) == "table" then
        for uid, eggData in pairs(records) do
            if typeof(eggData) == "table" then
                local isReady = false
                if EggState.IsReadyToHatch then isReady = EggState.IsReadyToHatch(eggData)
                else isReady = eggData.Placement ~= nil end
                if isReady then
                    pcall(function()
                        if EggState.BeginHatch then EggState.BeginHatch(uid) end
                        task.wait(0.05)
                        if EggState.FinishHatch then EggState.FinishHatch(uid) end
                        count = count + 1
                    end)
                end
            end
        end
    end
    return count
end

local function StealBestEggOnce()
    pcall(HatchAllReadyEggs)
    local eggs = GetMatchingFieldEggs(selectedStealAreas, selectedStealRarities, selectedMutationTypes)
    if #eggs == 0 then return false end
    return StealSpecificEggRobust(eggs[1])
end

-- ==============================================================================
-- BASE / REWARDS / COMBAT HELPERS
-- ==============================================================================
local function UpgradeHomesteadBase()
    local re1 = GetNetRemote("RE/Homestead/AskNearbyPurchase")
    if re1 then pcall(function() re1:FireServer() end) end
    local re2 = GetNetRemote("RE/Homestead/AskBaseTierRaise")
    if re2 then pcall(function() re2:FireServer() end) end
end
local function UpgradeTreadmillTier()
    local rf = GetNetRemote("RF/Treadmill/AskTierRaise")
    if rf then pcall(function() rf:InvokeServer() end) end
end
local function EquipBestPets()
    local rf = GetNetRemote("RF/Haul/WearBest") or GetNetRemote("RF/PenRoster/ConfirmEquipBestBadge")
    if rf then pcall(function() rf:InvokeServer() end) end
end
local function GetMyMonsterPosition()
    local myMonster = Workspace:FindFirstChild("MonsterParasiteMonsters") and Workspace.MonsterParasiteMonsters:FindFirstChild("Monster_" .. LP.UserId)
    if myMonster then
        local pos = (myMonster.PrimaryPart and myMonster.PrimaryPart.Position) or myMonster:GetPivot().Position
        return pos
    end
    local standPad = Workspace:FindFirstChild("Stands") and Workspace.Stands:FindFirstChild("Pads") and Workspace.Stands.Pads:FindFirstChild("Monster")
    if standPad then return standPad.Position end
    return Vector3.new(545.1, 68.0, -413.4)
end
local function ClaimMonsterChests()
    pcall(function()
        local rf1 = GetNetRemote("RF/MonsterParasite/AskChestClaim")
        if rf1 then rf1:InvokeServer() end
        local rf2 = GetNetRemote("RF/MonsterParasite/AskChestTake")
        if rf2 then rf2:InvokeServer() end
    end)
end
local function FeedMonsterParasite()
    local rf = GetNetRemote("RF/MonsterParasite/AskFeed")
    if not rf then return false end
    local hrp = findHRP()
    if not hrp then return false end
    local mPos = GetMyMonsterPosition()
    local dist = (hrp.Position - mPos).Magnitude
    local savedSpot = nil
    if dist > 12 then
        savedSpot = hrp.CFrame
        TravelToDestination(mPos + Vector3.new(0, 1.2, 0), glideSpeed or 200, true)
        task.wait(0.08)
    end
    local ok, res = pcall(function() return rf:InvokeServer() end)
    if savedSpot then
        task.wait(0.1)
        TravelToDestination(savedSpot.Position, glideSpeed or 200, true)
        local h = findHRP()
        if h then h.CFrame = savedSpot end
    end
    return ok and res
end
local function ClaimAllAvailableRewards()
    pcall(function()
        local rf1 = GetNetRemote("RF/AwayEarnings/AskCollect")
        if rf1 then rf1:InvokeServer() end
    end)
    pcall(function()
        local rf2 = GetNetRemote("RF/Codex/AskRedeemAll")
        if rf2 then rf2:InvokeServer() end
    end)
    pcall(function()
        local rf3 = GetNetRemote("RF/GroupPerk/RedeemPerk")
        if rf3 then rf3:InvokeServer() end
    end)
    pcall(ClaimMonsterChests)
end

local function SetupInstantPickup(enabled)
    instantPickupEnabled = enabled
end
local function SetNoKnockback(enabled)
    noKnockbackEnabled = enabled
    if enabled then
        pcall(function()
            local rigSync = GetNetRemote("RE/RigSync/Refresh")
            if rigSync and getconnections then
                for _, conn in ipairs(getconnections(rigSync.OnClientEvent)) do
                    pcall(function() conn:Disconnect() end)
                end
            end
        end)
    end
end

local function SellSelectedPets()
    local re = GetNetRemote("RE/PetSatchel/SellPet")
    if not re or not SaveModule then return end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    local inv = save and save.Inventory
    if type(inv) ~= "table" then return end
    for uid, petData in pairs(inv) do
        if type(petData) == "table" and not petData.Locked then
            local rName = petData.Rarity or "Common"
            if isRarityAllowed(rName, getSellRarityFilter(selectedSellPetRarities)) then
                pcall(function() re:FireServer(uid) end)
                task.wait(0.08)
            end
        end
    end
end

local function SellSelectedEggs()
    if not SaveModule then return end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    if not save then return end
    local inv = save.EggInventory
    if type(inv) ~= "table" then return end
    local wear = GetNetRemote("RF/EggWorld/AskWearTool")
    local sell = GetNetRemote("RE/PetSatchel/SellPet")
    if not wear or not sell then return end
    for uid, eggData in pairs(inv) do
        if type(eggData) == "table" and not eggData.Placement and not eggData.Locked then
            local rName = GetEggRarityInfo(eggData)
            if isRarityAllowed(rName, getSellRarityFilter(selectedSellEggRarities)) then
                pcall(function() wear:InvokeServer(uid) end)
                pcall(function() sell:FireServer({ uid }) end)
                task.wait(SELL_REQUEST_DELAY)
            end
        end
    end
end

local function DeleteOwnPetRenders()
    local count = 0
    local function sweep(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                pcall(function() child:Destroy(); count = count + 1 end)
            end
        end
    end
    sweep(Workspace:FindFirstChild("Pets"))
    sweep(Workspace:FindFirstChild("RenderedPets"))
    return count
end

-- ==============================================================================
-- WORKER LOOPS
-- ==============================================================================
task.spawn(function()
    while not HUB.dead do
        if autoStealEnabled then pcall(StealBestEggOnce) end
        task.wait(stealDelay)
    end
end)

-- Авто-прыжок каждые 3 секунды при включённом Auto Steal
task.spawn(function()
    while not HUB.dead do
        if autoStealEnabled and autoJumpEnabled then
            local hum = findHum()
            if hum then
                pcall(function()
                    hum.Jump = true
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end
        task.wait(3)
    end
end)

task.spawn(function()
    while not HUB.dead do
        if autoHatchEnabled then pcall(HatchAllReadyEggs) end
        if autoPlantEnabled then pcall(PlantAllCarriedEggsInPen) end
        task.wait(hatchCheckDelay)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoUpgradeBase then pcall(UpgradeHomesteadBase) end
        if autoUpgradeTreadmill then pcall(UpgradeTreadmillTier) end
        if autoEquipBestPets then pcall(EquipBestPets) end
        if autoClaimRewards then pcall(ClaimAllAvailableRewards) end
        if autoClaimMonsterChests then pcall(ClaimMonsterChests) end
        if autoFeedMonster then pcall(FeedMonsterParasite) end
        if autoSellPets then pcall(SellSelectedPets) end
        if autoSellEggs then pcall(SellSelectedEggs) end
        task.wait(2.5)
    end
end)
task.spawn(function()
    local batRe = GetNetRemote("RE/BatSwing/Trigger")
    while not HUB.dead do
        if batAuraEnabled and batRe then
            local hrp = findHRP()
            if hrp then
                local foundNearby = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if oHrp and (oHrp.Position - hrp.Position).Magnitude <= batAuraRadius then
                            foundNearby = true; break
                        end
                    end
                end
                if foundNearby then pcall(function() batRe:FireServer() end) end
            end
        end
        task.wait(batAuraDelay)
    end
end)
task.spawn(function()
    local debris = Workspace:FindFirstChild("__DEBRIS")
    if debris then
        track(debris.ChildAdded:Connect(function(child)
            if avoidTrapsEnabled and child.Name == "PlayerTrap" then
                task.wait(0.05)
                if child:GetAttribute("Owner") ~= LP.Name then
                    if child:IsA("BasePart") then child.CanTouch = false end
                    for _, c in ipairs(child:GetChildren()) do
                        if c:IsA("BasePart") then c.CanTouch = false end
                    end
                end
            end
        end))
    end
    while not HUB.dead do
        if avoidTrapsEnabled or autoStealEnabled then pcall(NeutralizeTraps) end
        task.wait(1.5)
    end
end)

-- ==============================================================================
-- ESP (Drawing + Billboard)
-- ==============================================================================
local esp = {
    enabled = false, eggs = true, traps = false, players = false, guards = false,
    rareEggsOnly = false, showPetIcons = true, maxDistance = 800,
    eggColor = Color3.fromRGB(255, 200, 50), rareEggColor = Color3.fromRGB(255, 60, 220),
    trapColor = Color3.fromRGB(255, 60, 60), playerColor = Color3.fromRGB(100, 220, 100),
}
local hasDrawing = type(Drawing) == "table" and type(Drawing.new) == "function"
local trackedEspObjects = {}
local espBillboards = {}
local espContainer = nil

local function getEspContainer()
    if espContainer and espContainer.Parent then return espContainer end
    local p = (gethui and gethui()) or CoreGui or LP:FindFirstChild("PlayerGui") or Workspace
    pcall(function()
        for _, c in ipairs(p:GetChildren()) do
            if c:IsA("Folder") and c.Name == "Bloomware_Esp" then c:Destroy() end
        end
    end)
    espContainer = Instance.new("Folder")
    espContainer.Name = "Bloomware_Esp"
    pcall(function() espContainer.Parent = p end)
    return espContainer
end

local function updateEggBillboard(key, pos, icon)
    local bb = espBillboards[key]
    if not bb or not bb.gui or not bb.gui.Parent then
        local holder = getEspContainer()
        local part = Instance.new("Part")
        part.Name = "EspAnchor"
        part.Size = Vector3.new(1,1,1)
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CFrame = CFrame.new(pos)
        part.Parent = holder
        local gui = Instance.new("BillboardGui")
        gui.Name = "EggIcon"
        gui.Adornee = part
        gui.Size = UDim2.fromOffset(28, 28)
        gui.StudsOffset = Vector3.new(-2.2, 1.2, 0)
        gui.AlwaysOnTop = true
        gui.Parent = part
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.fromScale(1,1)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = icon or ""
        img.Parent = gui
        bb = { part = part, gui = gui, img = img }
        espBillboards[key] = bb
    else
        bb.part.CFrame = CFrame.new(pos)
        bb.img.Image = icon or ""
        bb.gui.Enabled = (icon ~= nil and icon ~= "")
    end
    return bb
end

local function createDrawingObject()
    if not hasDrawing then return {} end
    local o = {}
    o.name = trackDrawing(Drawing.new("Text"))
    o.name.Size = 13; o.name.Center = true; o.name.Outline = true; o.name.Visible = false
    o.dist = trackDrawing(Drawing.new("Text"))
    o.dist.Size = 11; o.dist.Center = true; o.dist.Outline = true; o.dist.Visible = false
    return o
end

track(RunService.RenderStepped:Connect(function()
    if HUB.dead or not esp.enabled then
        for _, obj in pairs(trackedEspObjects) do
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
        for _, bb in pairs(espBillboards) do if bb.gui then bb.gui.Enabled = false end end
        return
    end
    local hrp = findHRP()
    local myPos = hrp and hrp.Position or Vector3.zero
    local renderItems = {}
    local activeBbKeys = {}
    if esp.eggs and EggState and EggState.ReadFieldEggs then
        local ok, snap = pcall(EggState.ReadFieldEggs)
        if ok and snap and snap.Records then
            for _, egg in ipairs(snap.Records) do
                if egg.State == "Slot" and egg.BoundsCFrame then
                    local pos = egg.BoundsCFrame.Position
                    local dist = (pos - myPos).Magnitude
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        local muts = egg.Mutations or {}
                        local isRare = #muts > 0
                        if not esp.rareEggsOnly or isRare then
                            local mutText = isRare and (" [" .. table.concat(muts, ",") .. "]") or ""
                            local rName = GetEggRarityInfo(egg)
                            local label = (egg.AssetCategory or "Egg") .. " (" .. rName .. ")" .. mutText
                            local cat = egg.AssetCategory
                            local aInfo = AssetsData and (AssetsData.Directory or AssetsData) and (AssetsData.Directory or AssetsData)[cat]
                            local petIcon = aInfo and (aInfo.Icon or (aInfo.Egg and aInfo.Egg.Icon)) or ""
                            local itemColor = isRare and esp.rareEggColor or esp.eggColor
                            table.insert(renderItems, { Key = egg.Uid, Pos = pos, Name = label, Color = itemColor, Dist = dist })
                            if esp.showPetIcons and petIcon ~= "" then
                                activeBbKeys[egg.Uid] = true
                                updateEggBillboard(egg.Uid, pos, petIcon)
                            end
                        end
                    end
                end
            end
        end
    end
    if esp.traps then
        local debris = Workspace:FindFirstChild("__DEBRIS")
        if debris then
            for _, trap in ipairs(debris:GetChildren()) do
                if trap.Name == "PlayerTrap" and trap:IsA("BasePart") then
                    local pos = trap.Position
                    local dist = (pos - myPos).Magnitude
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        local owner = trap:GetAttribute("Owner") or "Enemy"
                        table.insert(renderItems, { Key = trap, Pos = pos + Vector3.new(0, 1.5, 0), Name = "[TRAP] @" .. owner, Color = esp.trapColor, Dist = dist })
                    end
                end
            end
        end
    end
    if esp.players then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if oHrp then
                    local dist = (oHrp.Position - myPos).Magnitude
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        table.insert(renderItems, { Key = p, Pos = oHrp.Position, Name = p.DisplayName .. " (@" .. p.Name .. ")", Color = esp.playerColor, Dist = dist })
                    end
                end
            end
        end
    end
    for k, bb in pairs(espBillboards) do
        if not activeBbKeys[k] and bb.gui then bb.gui.Enabled = false end
    end
    local cam = GetCamera()
    local activeKeys = {}
    for _, item in ipairs(renderItems) do
        activeKeys[item.Key] = true
        local obj = trackedEspObjects[item.Key]
        if not obj then obj = createDrawingObject(); trackedEspObjects[item.Key] = obj end
        local screenPos, onScreen = nil, false
        if cam then screenPos, onScreen = cam:WorldToViewportPoint(item.Pos) end
        if onScreen and hasDrawing and screenPos then
            if obj.name then
                obj.name.Text = item.Name
                obj.name.Position = Vector2.new(screenPos.X, screenPos.Y - 14)
                obj.name.Color = item.Color
                obj.name.Visible = true
            end
            if obj.dist then
                obj.dist.Text = math.floor(item.Dist) .. " studs"
                obj.dist.Position = Vector2.new(screenPos.X, screenPos.Y + 2)
                obj.dist.Color = Color3.fromRGB(220, 220, 220)
                obj.dist.Visible = true
            end
        else
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
    end
    for k, obj in pairs(trackedEspObjects) do
        if not activeKeys[k] then
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
    end
end))

-- Fullbright
local fullbrightEnabled = false
local defaultAmbient = Lighting.Ambient
local defaultOutdoor = Lighting.OutdoorAmbient
local defaultBrightness = Lighting.Brightness
local defaultClockTime = Lighting.ClockTime
local function SetFullbright(v)
    fullbrightEnabled = v
    if v then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = defaultAmbient
        Lighting.OutdoorAmbient = defaultOutdoor
        Lighting.Brightness = defaultBrightness
        Lighting.ClockTime = defaultClockTime
    end
end

-- Movement modifiers
local walkSpeedEnabled = false
local walkSpeedVal = 24
local jumpPowerEnabled = false
local jumpPowerVal = 60
local flying = false
local flySpeed = 60
local antiAFK = false

local function ApplyWalkSpeed(v)
    walkSpeedVal = v
    local hum = findHum()
    if hum and walkSpeedEnabled then hum.WalkSpeed = v end
end
local function ApplyJumpPower(v)
    jumpPowerVal = v
    local hum = findHum()
    if hum and jumpPowerEnabled then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end
track(RunService.Stepped:Connect(function()
    if HUB.dead then return end
    local hum = findHum()
    if hum then
        if walkSpeedEnabled then hum.WalkSpeed = walkSpeedVal end
        if jumpPowerEnabled then hum.UseJumpPower = true; hum.JumpPower = jumpPowerVal end
    end
end))
track(UserInputService.JumpRequest:Connect(function()
    if HUB.dead then return end
    local hum = findHum()
    if hum then hum.Jump = true; hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

local function startFly()
    if flying then return end
    local hrp = findHRP()
    local hum = findHum()
    if not (hrp and hum) then return end
    flying = true
    hrp.Anchored = true
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1,1,1) * 1e5
    bodyGyro.P = 1e5
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    HUB._fly = {
        hrp = hrp, gyro = bodyGyro,
        conn = track(RunService.RenderStepped:Connect(function(dt)
            if not flying or HUB.dead then return end
            local cam = GetCamera()
            if not cam then return end
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            flatLook = flatLook.Magnitude > 0.001 and flatLook.Unit or Vector3.new(0,0,-1)
            local flatRight = Vector3.new(right.X, 0, right.Z)
            flatRight = flatRight.Magnitude > 0.001 and flatRight.Unit or Vector3.new(1,0,0)
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + flatLook end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - flatLook end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - flatRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + flatRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + dir.Unit * flySpeed * math.min(dt, 0.1) end
            bodyGyro.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
        end))
    }
end
local function stopFly()
    flying = false
    local f = HUB._fly
    if f then
        pcall(function() f.conn:Disconnect() end)
        pcall(function() f.hrp.Anchored = false end)
        pcall(function() f.gyro:Destroy() end)
        HUB._fly = nil
    end
end
local antiAfkConn = nil
local function SetAntiAFK(v)
    antiAFK = v
    if v and not antiAfkConn then
        antiAfkConn = track(LP.Idled:Connect(function()
            if antiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end))
    elseif not v and antiAfkConn then
        pcall(function() antiAfkConn:Disconnect() end)
        antiAfkConn = nil
    end
end

track(RunService.Heartbeat:Connect(function()
    if HUB.dead or not antiRagdollEnabled then return end
    local hum = findHum()
    if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end))

-- ==============================================================================
-- BUILD UI TABS
-- ==============================================================================
local EggsTab = AddTab("Eggs", "🥚")
local BaseTab = AddTab("Base", "🏠")
local CombatTab = AddTab("Combat", "⚔")
local PlayerTab = AddTab("Player", "◉")
local SettingsTab = AddTab("Settings", "⚙")

local function beginSection(title, subtitle)
    local section = Section(title, subtitle)
    ActiveSection = section
    section.SetOpen(true)
    return section
end

EggsTab.Build = function()
    local s=beginSection("Auto Steal", "Targeting, movement and egg filters")
    Toggle("Auto Steal Eggs", false, function(v) autoStealEnabled=v; if v then EnsureSavedReturnPosition() end; Notify("Auto Steal",v and "Enabled" or "Disabled",v and "Success" or "Info") end)
    Toggle("Auto Jump While Stealing (3s)", true, function(v) autoJumpEnabled=v end)
    Dropdown("Steal Movement Method", {"Tween Glide","Fly Glide","Safe Walk","Anti Guard"}, "Tween Glide", function(v) stealMovementMethod=v end)
    Toggle("Steal Infested / Parasite Only", false, function(v) stealParasiteOnly=v end)
    Toggle("Instant Prompt Pickup", true, function(v) SetupInstantPickup(v) end)
    Toggle("Rare Egg Hunter (Highest First)", true, function(v) rareEggHunter=v end)
    MultiDropdown("Filter by Rarity", RARITY_NAMES, function(sel) selectedStealRarities=sel end)
    MultiDropdown("Filter by Area", AREA_NAMES, function(sel) selectedStealAreas=sel end)
    MultiDropdown("Filter by Mutation", MUTATION_FILTERS, function(sel) selectedMutationTypes=sel end)
    Slider("Glide / Travel Speed",50,750,750," studs/s",function(v) glideSpeed=v end)
    Slider("Steal Delay Gap",0.5,10,1.5,"s",function(v) stealDelay=v end)
    Button("Steal Best Available Egg Once",true,safeCallback(function() local ok=StealBestEggOnce(); Notify("Steal Egg",ok and "Target selected" or "No matching egg found",ok and "Success" or "Info") end))

    s=beginSection("Auto Hatch & Plant", "Automate ready eggs and pen placement")
    Toggle("Auto Hatch Ready Eggs",false,function(v) autoHatchEnabled=v end)
    Toggle("Auto Place Egg (Base Pen)",false,function(v) autoPlantEnabled=v end)
    Slider("Hatch Check Delay",0.5,10,2.0,"s",function(v) hatchCheckDelay=v end)
    Button("Hatch All Ready Eggs Now",true,safeCallback(function() Notify("Hatch","Hatched "..HatchAllReadyEggs().." egg(s)","Success") end))
    Button("Place Carried Eggs in Pen Now",false,safeCallback(function() Notify("Plant","Planted "..PlantAllCarriedEggsInPen().." egg(s)","Success") end))

    s=beginSection("Egg Tracker ESP", "Visual tracking and distance limits")
    Toggle("Egg ESP Enabled",false,function(v) esp.enabled=v end)
    Toggle("Show 3D Pet Image Badges",true,function(v) esp.showPetIcons=v end)
    Toggle("Trap ESP",false,function(v) esp.traps=v end)
    Toggle("Show Mutated / Rare Only",false,function(v) esp.rareEggsOnly=v end)
    Slider("Max ESP Distance",100,2500,800," studs",function(v) esp.maxDistance=v end)
end

BaseTab.Build = function()
    local s=beginSection("Homestead & Treadmill","Upgrades and base progression")
    Toggle("Auto Upgrade Base / Plot",false,function(v) autoUpgradeBase=v end)
    Toggle("Auto Upgrade Treadmill Tier",false,function(v) autoUpgradeTreadmill=v end)
    Button("Upgrade Base Now",true,safeCallback(function() UpgradeHomesteadBase(); Notify("Base","Upgrade requested","Success") end))
    Button("Upgrade Treadmill Now",false,safeCallback(function() UpgradeTreadmillTier(); Notify("Treadmill","Upgrade requested","Success") end))
    s=beginSection("Pets & Satchel","Loadout management")
    Toggle("Auto Equip Best Pets",false,function(v) autoEquipBestPets=v end)
    Button("Equip Best Pets Now",true,safeCallback(function() EquipBestPets(); Notify("Pets","Best loadout equipped","Success") end))
    s=beginSection("Auto Sell","Choose which rarities can be sold")
    Toggle("Auto Sell Low-Tier Pets",false,function(v) autoSellPets=v end)
    MultiDropdown("Filter Pet Sell Rarities",RARITY_NAMES,function(sel) selectedSellPetRarities=sel end)
    Toggle("Auto Sell Low-Tier Eggs",false,function(v) autoSellEggs=v end)
    MultiDropdown("Filter Egg Sell Rarities",RARITY_NAMES,function(sel) selectedSellEggRarities=sel end)
    Button("Sell Selected Pets Now",true,safeCallback(function() SellSelectedPets(); Notify("Sales","Sold matching pets","Success") end))
    Button("Sell Selected Eggs Now",false,safeCallback(function() SellSelectedEggs(); Notify("Sales","Sold matching eggs","Success") end))
    s=beginSection("Events & Bosses","Monster event controls")
    Toggle("Auto Claim Monster Chests",false,function(v) autoClaimMonsterChests=v end)
    Toggle("Auto Feed Monster Parasite",false,function(v) autoFeedMonster=v end)
    Button("Claim Monster Chest Now",true,safeCallback(function() ClaimMonsterChests(); Notify("Monster","Chest claim requested","Success") end))
    Button("Feed Monster Parasite Now",false,safeCallback(function() FeedMonsterParasite(); Notify("Monster","Feed requested","Success") end))
    s=beginSection("Rewards","Claim available rewards")
    Toggle("Auto Claim Away Earnings & Codex",false,function(v) autoClaimRewards=v end)
    Button("Claim All Rewards Now",true,safeCallback(function() ClaimAllAvailableRewards(); Notify("Rewards","All available rewards requested","Success") end))
end

CombatTab.Build = function()
    local s=beginSection("Bat & Slap Aura","Combat radius and timing")
    Toggle("Bat / Slap Aura",false,function(v) batAuraEnabled=v end)
    Slider("Aura Radius",5,50,20," studs",function(v) batAuraRadius=v end)
    Slider("Swing Delay",0.05,1.0,0.2,"s",function(v) batAuraDelay=v end)
    Button("Swing Bat Once",true,safeCallback(function() local re=GetNetRemote("RE/BatSwing/Trigger"); if re then re:FireServer() end; Notify("Bat","Swing triggered","Info") end))
    s=beginSection("Defense & Guards","Defensive toggles")
    Toggle("Anti-Trap (Full Immunity)",true,function(v) avoidTrapsEnabled=v; if v then pcall(NeutralizeTraps) end end)
    Toggle("No Knockback / Ragdoll Immunity",true,function(v) SetNoKnockback(v) end)
    Toggle("Anti-Ragdoll (Quick Standup)",true,function(v) antiRagdollEnabled=v end)
end

PlayerTab.Build = function()
    local s=beginSection("Movement","Movement modifiers and flight")
    Toggle("Enable WalkSpeed",false,function(v) walkSpeedEnabled=v; if not v then local hum=findHum(); if hum then hum.WalkSpeed=16 end end end)
    Slider("WalkSpeed Value",16,10000,24," studs/s",function(v) ApplyWalkSpeed(v) end)
    Toggle("Enable JumpPower",false,function(v) jumpPowerEnabled=v; if not v then local hum=findHum(); if hum then hum.JumpPower=50 end end end)
    Slider("JumpPower Value",50,300,60,"",function(v) ApplyJumpPower(v) end)
    Toggle("Smooth Fly (WASD + Space/Shift)",false,function(v) if v then startFly() else stopFly() end end)
    Slider("Fly Speed",20,250,60," studs/s",function(v) flySpeed=v end)
    Toggle("Anti-AFK",false,function(v) SetAntiAFK(v) end)
    s=beginSection("Area Travel","Fast travel to known areas")
    local areaKeys={}; for k in pairs(AREA_COORDINATES) do table.insert(areaKeys,k) end; table.sort(areaKeys)
    local selectedAreaTp="Base / Plot"
    Dropdown("Select Area",areaKeys,"Base / Plot",function(v) selectedAreaTp=v end)
    Button("Travel to Selected Area",true,safeCallback(function() local pos=AREA_COORDINATES[selectedAreaTp]; if selectedAreaTp=="Base / Plot" then pos=GetLocalPlotCenter() end; if pos then Notify("Travel","Traveling to "..selectedAreaTp,"Info"); TravelRoadPath(pos,glideSpeed or 200); Notify("Travel","Arrived at "..selectedAreaTp,"Success") end end))
    s=beginSection("Visuals & Performance","Client-side visual and performance controls")
    Toggle("Fullbright",false,function(v) SetFullbright(v) end)
    Button("Delete Own Pet Renders (FPS)",true,safeCallback(function() Notify("Performance","Removed "..DeleteOwnPetRenders().." pet model(s)","Success") end))
end

SettingsTab.Build = function()
    local s=beginSection("Appearance","Live UI theme system")
    local themeSelector = Dropdown("Theme Preset", {"Obsidian","Midnight","Crimson","Ocean","Violet","Emerald","Custom"}, UI.CurrentPreset, function(v) if v~="Custom" then UI.ApplyPreset(v) end end)
    UI._themeSelector = themeSelector
    Slider("UI Scale",75,135,math.floor(UI.Scale*100),"%",function(v) ApplyScale(v/100) end)
    Toggle("Compact Sidebar",UI.Compact,function(v) setCompact(v) end)
    Dropdown("UI Toggle Key", {"RightControl","LeftAlt","Insert","Home","F6"}, "RightControl", function(v) UI.SetToggleKey(v) end)
    InfoCard("Preset themes","Choose a preset above. Custom mode lets you edit individual palette slots with hex values.")

    s=beginSection("Custom Theme","Use #RRGGBB values")
    local customSlots={"Background","Surface","Surface2","Surface3","Accent","Accent2","Text","TextDim","Input"}
    for _,slot in ipairs(customSlots) do
        local f=Create("Frame",{Size=UDim2.new(1,-12,0,42),BackgroundColor3=UI.Theme.Surface2,BorderSizePixel=0,Parent=ControlParent(),ThemeRole="Surface2"}); Create("UICorner",{CornerRadius=UDim.new(0,10),Parent=f})
        Create("TextLabel",{Size=UDim2.new(0.42,0,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=slot,TextColor3=UI.Theme.Text,TextSize=11,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,Parent=f,ThemeRole="Text"})
        local box=Create("TextBox",{Size=UDim2.new(0,150,0,30),Position=UDim2.new(1,-162,0.5,-15),BackgroundColor3=UI.Theme.Input,BorderSizePixel=0,Text=UI._customHex[slot] or color3ToHex(UI.Theme[slot]),PlaceholderText="#RRGGBB",TextColor3=UI.Theme.Text,TextSize=11,Font=Enum.Font.Code,ClearTextOnFocus=false,Parent=f,ThemeRole="Input"}); Create("UICorner",{CornerRadius=UDim.new(0,8),Parent=box})
        box.FocusLost:Connect(function() local ok=UI.SetCustomHex(slot,box.Text); if ok then box.Text=color3ToHex(UI.Theme[slot]); Notify("Theme","Updated "..slot,"Success") else box.Text=color3ToHex(UI.Theme[slot]); Notify("Theme","Invalid hex for "..slot,"Error") end end)
        RegisterRow(f,slot); UI.Rows[#UI.Rows].Section=s.Frame
    end
    Button("Reset Custom Palette",false,function() UI.ApplyPreset("Obsidian") end)
    s=beginSection("Interface","Convenience options")
    Button("Hide / Show UI",true,function() Main.Visible=not Main.Visible end)
    Button("Clear Search",false,function() SearchBox.Text=""; UI.SearchText=""; UI.RefreshSearch() end)
    Button("Unload Bloomware",false,safeCallback(function() HUB.Unload() end))
    InfoCard("Bloomware v2.0 UI","Responsive window • Search • Collapsible sections • Theme presets • Custom palette • Compact mode • UI scaling")
end

-- Default tab
SwitchTab("Eggs")

-- Init defensive features
pcall(function() if avoidTrapsEnabled then NeutralizeTraps() end end)
pcall(function() if instantPickupEnabled then SetupInstantPickup(true) end end)
pcall(function() if noKnockbackEnabled then SetNoKnockback(true) end end)

-- Unload
HUB.Unload = function()
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    HUB.conns = {}
    for _, d in ipairs(HUB.drawings) do pcall(function() d:Remove() end) end
    HUB.drawings = {}
    stopFly()
    SetFullbright(false)
    local hum = findHum()
    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    pcall(function() ScreenGui:Destroy() end)
    _G.Bloomware = nil
end

Notify("Bloomware", "Steal An Egg utility loaded successfully!", "Success", 3.5)
