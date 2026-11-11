--[[
    VoidLib v1.0
    Dark Orange UI Library
    UI components only; intended for a LocalScript in your own Roblox experience.
]]

local VoidLib = {}
VoidLib.__index = VoidLib

VoidLib.Version = "1.0.0"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local DEFAULT_THEME = {
    Background = Color3.fromRGB(16, 16, 18),
    Sidebar = Color3.fromRGB(22, 22, 25),
    Card = Color3.fromRGB(31, 31, 35),
    CardHover = Color3.fromRGB(42, 39, 36),
    Accent = Color3.fromRGB(255, 138, 36),
    AccentDark = Color3.fromRGB(204, 99, 20),
    Text = Color3.fromRGB(245, 245, 245),
    Muted = Color3.fromRGB(155, 155, 160),
    Border = Color3.fromRGB(52, 52, 57),
    Success = Color3.fromRGB(80, 190, 115),
    Danger = Color3.fromRGB(220, 80, 75),
}

local function merge(defaults, overrides)
    local result = {}
    for key, value in pairs(defaults) do
        result[key] = value
    end
    for key, value in pairs(overrides or {}) do
        result[key] = value
    end
    return result
end

local function create(className, props, parent)
    local object = Instance.new(className)
    for key, value in pairs(props or {}) do
        object[key] = value
    end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, parent)
end

local function stroke(parent, color, transparency)
    return create("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = 1
    }, parent)
end

local function tween(object, properties, duration)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        properties
    )
    animation:Play()
    return animation
end

local function safeCallback(callback, ...)
    if type(callback) ~= "function" then
        return
    end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)
        if not ok then
            warn("[VoidLib] Callback error: " .. tostring(err))
        end
    end)
end

local function addText(parent, text, size, color, font)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        Text = tostring(text or ""),
        TextColor3 = color,
        TextSize = size or 13,
        Font = font or Enum.Font.Gotham,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local function addIcon(parent, image, theme, size)
    if not image or image == "" then
        return nil
    end
    return create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Image = image,
        ImageColor3 = theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.fromOffset(size or 18, size or 18)
    }, parent)
end

local function playSound(parent, soundId, volume)
    if not soundId or soundId == "" then
        return
    end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = math.clamp(volume or 0.35, 0, 1)
    sound.Parent = parent
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    sound:Play()
end

local function makeDraggable(handle, target)
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = target.Position
            dragInput = input
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function VoidLib:CreateWindow(options)
    options = options or {}
    local player = Players.LocalPlayer
    assert(player, "VoidLib:CreateWindow must be called from a client LocalScript")

    local theme = merge(DEFAULT_THEME, options.Theme)
    local playerGui = player:WaitForChild("PlayerGui")

    local screen = create("ScreenGui", {
        Name = options.GuiName or "VoidLib",
        ResetOnSpawn = false,
        IgnoreGuiInset = options.IgnoreGuiInset == true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = options.DisplayOrder or 20
    }, playerGui)

    local scale = create("UIScale", {
        Scale = options.Scale or 1
    }, screen)

    local main = create("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(options.Width or 620, options.Height or 410),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, screen)
    corner(main, 12)
    stroke(main, theme.Border, 0.25)

    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0
    }, main)

    local title = addText(topbar, options.Name or "VoidLib", 16, theme.Text, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(17, 0)
    title.Size = UDim2.new(1, -115, 1, 0)

    local version = addText(topbar, "v" .. VoidLib.Version, 10, theme.Muted)
    version.TextXAlignment = Enum.TextXAlignment.Right
    version.Position = UDim2.new(1, -100, 0, 0)
    version.Size = UDim2.fromOffset(45, 48)

    local closeButton = create("TextButton", {
        Name = "Close",
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -40, 0, 9),
        BackgroundColor3 = theme.Card,
        Text = "×",
        TextColor3 = theme.Accent,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, topbar)
    corner(closeButton, 7)

    local minimizeButton = create("TextButton", {
        Name = "Minimize",
        Size = UDim2.fromOffset(25, 30),
        Position = UDim2.new(1, -72, 0, 9),
        BackgroundColor3 = theme.Card,
        Text = "—",
        TextColor3 = theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    }, topbar)
    corner(minimizeButton, 7)

    local sidebar = create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(9, 57),
        Size = UDim2.new(0, options.SidebarWidth or 155, 1, -66),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0
    }, main)
    corner(sidebar, 9)

    local tabPadding = create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    }, sidebar)

    local tabLayout = create("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, sidebar)

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, (options.SidebarWidth or 155) + 17, 0, 57),
        Size = UDim2.new(1, -(options.SidebarWidth or 155) - 26, 1, -66),
        BackgroundColor3 = theme.Sidebar,
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, main)
    corner(content, 9)

    local window = {
        ScreenGui = screen,
        Main = main,
        Theme = theme,
        Tabs = {},
        CurrentTab = nil,
        _destroyed = false
    }

    local function showTab(tab)
        if window.CurrentTab == tab then
            return
        end
        window.CurrentTab = tab

        for _, item in ipairs(window.Tabs) do
            item.Page.Visible = item == tab
            tween(item.Button, {
                BackgroundColor3 = item == tab and theme.Accent or theme.Card,
                TextColor3 = item == tab and Color3.new(1, 1, 1) or theme.Muted
            })
            if item.Icon then
                item.Icon.ImageColor3 = item == tab and Color3.new(1, 1, 1) or theme.Accent
            end
        end
    end

    local function updateCanvas(page, layout)
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 22)
    end

    function window:CreateTab(tabOptions)
        if type(tabOptions) == "string" then
            tabOptions = { Name = tabOptions }
        end
        tabOptions = tabOptions or {}

        local tabName = tabOptions.Name or ("Tab " .. tostring(#self.Tabs + 1))
        local tabButton = create("TextButton", {
            Name = "Tab_" .. tabName,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = theme.Card,
            Text = "",
            AutoButtonColor = false
        }, sidebar)
        corner(tabButton, 7)

        local icon = addIcon(tabButton, tabOptions.Icon, theme, 17)
        if icon then
            icon.Position = UDim2.new(0, 10, 0.5, -8)
        end

        local tabLabel = addText(tabButton, tabName, 12, theme.Muted, Enum.Font.GothamMedium)
        tabLabel.Position = UDim2.fromOffset(tabOptions.Icon and 36 or 12, 0)
        tabLabel.Size = UDim2.new(1, -(tabOptions.Icon and 43 or 20), 1, 0)

        local page = create("ScrollingFrame", {
            Name = "Page_" .. tabName,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        }, content)

        create("UIPadding", {
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingBottom = UDim.new(0, 12)
        }, page)

        local layout = create("UIListLayout", {
            Padding = UDim.new(0, 9),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, page)
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            updateCanvas(page, layout)
        end)

        local tab = {
            Name = tabName,
            Button = tabButton,
            Icon = icon,
            Page = page,
            Layout = layout
        }
        table.insert(self.Tabs, tab)

        tabButton.MouseButton1Click:Connect(function()
            playSound(screen, options.TabSound, options.SoundVolume)
            showTab(tab)
        end)
        tabButton.MouseEnter:Connect(function()
            if self.CurrentTab ~= tab then
                tween(tabButton, { BackgroundColor3 = theme.CardHover })
            end
        end)
        tabButton.MouseLeave:Connect(function()
            if self.CurrentTab ~= tab then
                tween(tabButton, { BackgroundColor3 = theme.Card })
            end
        end)

        local function addElement(height, elementName)
            local card = create("Frame", {
                Name = elementName or "Element",
                Size = UDim2.new(1, 0, 0, height),
                BackgroundColor3 = theme.Card,
                BorderSizePixel = 0
            }, page)
            corner(card, 8)
            return card
        end

        function tab:CreateSection(text)
            local section = addText(page, text or "Section", 11, theme.Accent, Enum.Font.GothamBold)
            section.Size = UDim2.new(1, 0, 0, 22)
            return section
        end

        function tab:CreateLabel(labelOptions)
            if type(labelOptions) == "string" then
                labelOptions = { Text = labelOptions }
            end
            labelOptions = labelOptions or {}
            local card = addElement(labelOptions.Height or 38, "Label")
            local label = addText(card, labelOptions.Text or "Label", 12, theme.Text)
            label.Position = UDim2.fromOffset(12, 0)
            label.Size = UDim2.new(1, -24, 1, 0)
            return card
        end

        function tab:CreateButton(buttonOptions)
            buttonOptions = buttonOptions or {}
            local card = addElement(buttonOptions.Height or 44, "Button")
            local button = create("TextButton", {
                Name = "Action",
                Position = UDim2.fromOffset(5, 5),
                Size = UDim2.new(1, -10, 1, -10),
                BackgroundColor3 = buttonOptions.Color or theme.CardHover,
                Text = "",
                AutoButtonColor = false
            }, card)
            corner(button, 6)

            local buttonIcon = addIcon(button, buttonOptions.Icon, theme, 18)
            if buttonIcon then
                buttonIcon.Position = UDim2.new(0, 10, 0.5, -9)
            end

            local label = addText(button, buttonOptions.Name or "Button", 12, theme.Text, Enum.Font.GothamMedium)
            label.Position = UDim2.fromOffset(buttonOptions.Icon and 39 or 12, 0)
            label.Size = UDim2.new(1, -(buttonOptions.Icon and 48 or 24), 1, 0)

            button.MouseEnter:Connect(function()
                tween(button, { BackgroundColor3 = theme.AccentDark })
                playSound(button, buttonOptions.HoverSound or options.HoverSound, options.SoundVolume)
            end)
            button.MouseLeave:Connect(function()
                tween(button, { BackgroundColor3 = buttonOptions.Color or theme.CardHover })
            end)
            button.Activated:Connect(function()
                playSound(button, buttonOptions.ClickSound or options.ClickSound, options.SoundVolume)
                safeCallback(buttonOptions.Callback)
            end)
            return card
        end

        function tab:CreateToggle(toggleOptions)
            toggleOptions = toggleOptions or {}
            local value = toggleOptions.Default == true
            local card = addElement(toggleOptions.Height or 44, "Toggle")

            local label = addText(card, toggleOptions.Name or "Toggle", 12, theme.Text, Enum.Font.GothamMedium)
            label.Position = UDim2.fromOffset(12, 0)
            label.Size = UDim2.new(1, -75, 1, 0)

            local switch = create("TextButton", {
                Size = UDim2.fromOffset(40, 22),
                Position = UDim2.new(1, -52, 0.5, -11),
                BackgroundColor3 = value and theme.Accent or theme.Border,
                Text = "",
                AutoButtonColor = false
            }, card)
            corner(switch, 20)

            local knob = create("Frame", {
                Size = UDim2.fromOffset(16, 16),
                Position = value and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0
            }, switch)
            corner(knob, 20)

            local function setValue(nextValue, fireCallback)
                value = nextValue == true
                tween(switch, { BackgroundColor3 = value and theme.Accent or theme.Border })
                tween(knob, { Position = value and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3) })
                if fireCallback ~= false then
                    safeCallback(toggleOptions.Callback, value)
                end
            end

            switch.Activated:Connect(function()
                playSound(switch, toggleOptions.ClickSound or options.ClickSound, options.SoundVolume)
                setValue(not value, true)
            end)

            local api = {}
            function api:Set(nextValue)
                setValue(nextValue, true)
            end
            function api:Get()
                return value
            end
            setValue(value, false)
            return api
        end

        function tab:CreateSlider(sliderOptions)
            sliderOptions = sliderOptions or {}
            local minimum = tonumber(sliderOptions.Min) or 0
            local maximum = tonumber(sliderOptions.Max) or 100
            if maximum <= minimum then
                maximum = minimum + 1
            end
            local value = math.clamp(tonumber(sliderOptions.Default) or minimum, minimum, maximum)
            local card = addElement(sliderOptions.Height or 62, "Slider")

            local label = addText(card, sliderOptions.Name or "Slider", 12, theme.Text, Enum.Font.GothamMedium)
            label.Position = UDim2.fromOffset(12, 5)
            label.Size = UDim2.new(1, -90, 0, 22)

            local valueLabel = addText(card, tostring(value), 11, theme.Accent, Enum.Font.GothamBold)
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Position = UDim2.new(1, -75, 0, 5)
            valueLabel.Size = UDim2.fromOffset(63, 22)

            local bar = create("TextButton", {
                Position = UDim2.new(0, 12, 0, 37),
                Size = UDim2.new(1, -24, 0, 8),
                BackgroundColor3 = theme.Border,
                Text = "",
                AutoButtonColor = false
            }, card)
            corner(bar, 8)

            local fill = create("Frame", {
                Size = UDim2.new((value - minimum) / (maximum - minimum), 0, 1, 0),
                BackgroundColor3 = theme.Accent,
                BorderSizePixel = 0
            }, bar)
            corner(fill, 8)

            local knob = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((value - minimum) / (maximum - minimum), 0, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0
            }, bar)
            corner(knob, 20)

            local function setFromX(x)
                local percent = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                value = minimum + (maximum - minimum) * percent
                if sliderOptions.Decimals == 0 then
                    value = math.floor(value + 0.5)
                elseif sliderOptions.Decimals then
                    local factor = 10 ^ sliderOptions.Decimals
                    value = math.floor(value * factor + 0.5) / factor
                end
                local alpha = (value - minimum) / (maximum - minimum)
                fill.Size = UDim2.new(alpha, 0, 1, 0)
                knob.Position = UDim2.new(alpha, 0, 0.5, 0)
                valueLabel.Text = tostring(value)
                safeCallback(sliderOptions.Callback, value)
            end

            local sliding = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    setFromX(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                    setFromX(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            local api = {}
            function api:Set(nextValue)
                value = math.clamp(tonumber(nextValue) or minimum, minimum, maximum)
                local alpha = (value - minimum) / (maximum - minimum)
                fill.Size = UDim2.new(alpha, 0, 1, 0)
                knob.Position = UDim2.new(alpha, 0, 0.5, 0)
                valueLabel.Text = tostring(value)
                safeCallback(sliderOptions.Callback, value)
            end
            function api:Get()
                return value
            end
            return api
        end

        function tab:CreateDropdown(dropdownOptions)
            dropdownOptions = dropdownOptions or {}
            local values = dropdownOptions.Options or {}
            local selected = dropdownOptions.Default
            local expanded = false
            local card = addElement( dropdownOptions.Height or 44, "Dropdown")

            local button = create("TextButton", {
                Position = UDim2.fromOffset(5, 5),
                Size = UDim2.new(1, -10, 1, -10),
                BackgroundColor3 = theme.CardHover,
                Text = "",
                AutoButtonColor = false,
                ClipsDescendants = true
            }, card)
            corner(button, 6)

            local label = addText(button, dropdownOptions.Name or "Dropdown", 12, theme.Text, Enum.Font.GothamMedium)
            label.Position = UDim2.fromOffset(10, 0)
            label.Size = UDim2.new(0.55, -10, 1, 0)

            local current = addText(button, tostring(selected or "Select"), 11, theme.Accent)
            current.TextXAlignment = Enum.TextXAlignment.Right
            current.Position = UDim2.new(0.55, 0, 0, 0)
            current.Size = UDim2.new(0.45, -28, 1, 0)

            local arrow = addText(button, "⌄", 17, theme.Muted, Enum.Font.GothamBold)
            arrow.TextXAlignment = Enum.TextXAlignment.Center
            arrow.Position = UDim2.new(1, -27, 0, 0)
            arrow.Size = UDim2.fromOffset(22, 34)

            local list = create("Frame", {
                Position = UDim2.new(0, 5, 1, 2),
                Size = UDim2.new(1, -10, 0, 0),
                BackgroundColor3 = theme.Sidebar,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 5
            }, card)
            corner(list, 6)
            stroke(list, theme.Border, 0.2)

            local listLayout = create("UIListLayout", {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder
            }, list)
            create("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4)
            }, list)

            local function choose(option)
                selected = option
                current.Text = tostring(option)
                list.Visible = false
                expanded = false
                card.Size = UDim2.new(1, 0, 0, dropdownOptions.Height or 44)
                safeCallback(dropdownOptions.Callback, option)
            end

            local function rebuild()
                for _, child in ipairs(list:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                for index, option in ipairs(values) do
                    local optionButton = create("TextButton", {
                        LayoutOrder = index,
                        Size = UDim2.new(1, 0, 0, 29),
                        BackgroundColor3 = theme.Card,
                        Text = tostring(option),
                        TextColor3 = theme.Text,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        AutoButtonColor = false,
                        ZIndex = 6
                    }, list)
                    corner(optionButton, 5)
                    optionButton.Activated:Connect(function()
                        choose(option)
                    end)
                end
                local listHeight = math.min(#values, dropdownOptions.MaxVisible or 5) * 32 + 8
                list.Size = UDim2.new(1, -10, 0, listHeight)
            end

            button.Activated:Connect(function()
                expanded = not expanded
                list.Visible = expanded
                card.Size = UDim2.new(1, 0, 0, expanded and ((dropdownOptions.Height or 44) + list.Size.Y.Offset + 5) or (dropdownOptions.Height or 44))
                arrow.Text = expanded and "⌃" or "⌄"
            end)
            rebuild()

            local api = {}
            function api:Set(option)
                for _, item in ipairs(values) do
                    if item == option then
                        choose(option)
                        return
                    end
                end
            end
            function api:Get()
                return selected
            end
            function api:Refresh(newValues)
                values = newValues or {}
                rebuild()
            end
            return api
        end

        function tab:CreateTextbox(textboxOptions)
            textboxOptions = textboxOptions or {}
            local card = addElement(textboxOptions.Height or 48, "Textbox")

            local label = addText(card, textboxOptions.Name or "Textbox", 11, theme.Muted)
            label.Position = UDim2.fromOffset(11, 2)
            label.Size = UDim2.new(1, -22, 0, 16)

            local input = create("TextBox", {
                Position = UDim2.fromOffset(8, 20),
                Size = UDim2.new(1, -16, 0, 23),
                BackgroundColor3 = theme.Sidebar,
                Text = textboxOptions.Default or "",
                PlaceholderText = textboxOptions.Placeholder or "Enter text...",
                PlaceholderColor3 = theme.Muted,
                TextColor3 = theme.Text,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left
            }, card)
            corner(input, 5)
            create("UIPadding", {
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7)
            }, input)

            input.FocusLost:Connect(function(enterPressed)
                if textboxOptions.Callback then
                    safeCallback(textboxOptions.Callback, input.Text, enterPressed)
                end
            end)

            local api = {}
            function api:Set(value)
                input.Text = tostring(value or "")
            end
            function api:Get()
                return input.Text
            end
            return api
        end

        if #self.Tabs == 1 then
            showTab(tab)
        end

        return tab
    end

    function window:Notify(notificationOptions)
        notificationOptions = notificationOptions or {}
        local holder = screen:FindFirstChild("Notifications")
        if not holder then
            holder = create("Frame", {
                Name = "Notifications",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 14),
                Size = UDim2.fromOffset(270, 300),
                BackgroundTransparency = 1
            }, screen)
            create("UIListLayout", {
                Padding = UDim.new(0, 8),
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder
            }, holder)
        end

        local item = create("Frame", {
            Size = UDim2.fromOffset(260, 66),
            BackgroundColor3 = theme.Card,
            BorderSizePixel = 0,
            BackgroundTransparency = 0.05
        }, holder)
        corner(item, 8)
        stroke(item, theme.Border, 0.15)

        local accent = create("Frame", {
            Size = UDim2.new(0, 3, 1, -16),
            Position = UDim2.fromOffset(7, 8),
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0
        }, item)
        corner(accent, 3)

        local heading = addText(item, notificationOptions.Title or "VoidLib", 12, theme.Text, Enum.Font.GothamBold)
        heading.Position = UDim2.fromOffset(18, 8)
        heading.Size = UDim2.new(1, -28, 0, 20)

        local message = addText(item, notificationOptions.Content or notificationOptions.Text or "", 11, theme.Muted)
        message.Position = UDim2.fromOffset(18, 29)
        message.Size = UDim2.new(1, -28, 0, 27)

        item.Position = UDim2.fromOffset(270, 0)
        tween(item, { Position = UDim2.fromOffset(0, 0) })

        task.delay(notificationOptions.Duration or 3, function()
            if item and item.Parent then
                tween(item, { BackgroundTransparency = 1 })
                task.wait(0.2)
                item:Destroy()
            end
        end)
    end

    function window:SetVisible(visible)
        main.Visible = visible == true
    end

    function window:Minimize()
        local minimized = false
        minimizeButton.Activated:Connect(function()
            minimized = not minimized
            sidebar.Visible = not minimized
            content.Visible = not minimized
            main.Size = minimized
                and UDim2.fromOffset(options.Width or 620, 48)
                or UDim2.fromOffset(options.Width or 620, options.Height or 410)
        end)
    end

    function window:Destroy()
        if self._destroyed then
            return
        end
        self._destroyed = true
        screen:Destroy()
    end

    closeButton.Activated:Connect(function()
        window:Destroy()
    end)

    closeButton.MouseEnter:Connect(function()
        tween(closeButton, { BackgroundColor3 = theme.Danger })
    end)
    closeButton.MouseLeave:Connect(function()
        tween(closeButton, { BackgroundColor3 = theme.Card })
    end)

    makeDraggable(topbar, main)

    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        scale.Scale = options.MobileScale or 0.88
    end

    return window
end

return VoidLib
