local UserInputService = game:GetService("UserInputService")

local DeltaBXC = {}
DeltaBXC.__index = DeltaBXC

-- Utility function for creating instances with properties
local function newInstance(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

function DeltaBXC.new(title, size)
    local self = setmetatable({}, DeltaBXC)

    -- ScreenGui container
    local screenGui = newInstance("ScreenGui", {
        Name = "DeltaBXC_UI",
        ResetOnSpawn = false,
        Parent = game:GetService("CoreGui"),
    })

    -- Main window frame
    local window = newInstance("Frame", {
        Size = UDim2.new(0, size.X, 0, size.Y),
        Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
        BackgroundColor3 = Color3.fromRGB(30,30,40),
        Parent = screenGui,
    })
    newInstance("UICorner", {Parent = window, CornerRadius = UDim.new(0, 12)})

    -- Title bar for dragging
    local titleBar = newInstance("TextLabel", {
        Text = title or "DeltaBXC",
        Size = UDim2.new(1,0,0,32),
        BackgroundColor3 = Color3.fromRGB(45,45,60),
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = window,
    })
    newInstance("UICorner", {Parent = titleBar, CornerRadius = UDim.new(0, 12)})

    -- Left tab container
    local tabContainer = newInstance("Frame", {
        Size = UDim2.new(0, 140, 1, -32),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(40,40,60),
        Parent = window,
    })
    newInstance("UICorner", {Parent = tabContainer, CornerRadius = UDim.new(0, 8)})

    -- Tab buttons list layout
    local tabButtonLayout = newInstance("UIListLayout", {Parent = tabContainer})
    tabButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabButtonLayout.Padding = UDim.new(0, 6)

    -- Content area container
    local contentContainer = newInstance("Frame", {
        Size = UDim2.new(1, -140, 1, -32),
        Position = UDim2.new(0, 140, 0, 32),
        BackgroundTransparency = 1,
        Parent = window,
    })

    -- Dragging support
    do
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            window.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
        end
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = window.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        titleBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
    end

    -- Store tabs and current selection
    self.screenGui = screenGui
    self.window = window
    self.tabContainer = tabContainer
    self.contentContainer = contentContainer
    self.tabButtonLayout = tabButtonLayout
    self.tabs = {}
    self.currentTab = nil

    return self
end

function DeltaBXC:CreateTab(name)
    assert(type(name) == "string", "Tab name must be a string")
    local tab = {}

    -- Tab button
    local tabButton = newInstance("TextButton", {
        Text = name,
        Size = UDim2.new(1, -12, 0, 38),
        BackgroundColor3 = Color3.fromRGB(55,55,85),
        TextColor3 = Color3.fromRGB(220,220,255),
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        Parent = self.tabContainer,
        AutoButtonColor = false,
    })
    newInstance("UICorner", {Parent = tabButton, CornerRadius = UDim.new(0, 10)})

    -- Content frame
    local contentFrame = newInstance("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(100,100,150),
        BackgroundTransparency = 1,
        Parent = self.contentContainer,
    })
    contentFrame.Visible = false
    contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- Layout inside content frame
    local layout = newInstance("UIListLayout", {Parent = contentFrame})
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    local padding = newInstance("UIPadding", {Parent = contentFrame})
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)

    -- Select tab function
    local function select()
        if self.currentTab then
            self.currentTab.content.Visible = false
            self.currentTab.button.BackgroundColor3 = Color3.fromRGB(55,55,85)
        end
        tabButton.BackgroundColor3 = Color3.fromRGB(90,90,130)
        contentFrame.Visible = true
        self.currentTab = {button = tabButton, content = contentFrame}
    end

    tabButton.MouseButton1Click:Connect(select)

    -- Auto-select first tab
    if #self.tabs == 0 then
        select()
    end

    -- Elements API on tab
    function tab:CreateButton(text, callback)
        local btn = newInstance("TextButton", {
            Text = text or "Button",
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(120, 60, 180),
            TextColor3 = Color3.fromRGB(240, 240, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            Parent = contentFrame,
        })
        newInstance("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 12)})
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        return btn
    end

    function tab:CreateTextbox(placeholder, callback)
        local textbox = newInstance("TextBox", {
            PlaceholderText = placeholder or "Enter text...",
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(60, 60, 90),
            TextColor3 = Color3.fromRGB(220, 220, 240),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            ClearTextOnFocus = true,
            Parent = contentFrame,
        })
        newInstance("UICorner", {Parent = textbox, CornerRadius = UDim.new(0, 10)})
        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(textbox.Text)
            end
        end)
        return textbox
    end

    function tab:CreateToggle(text, default, callback)
        local toggleFrame = newInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            Parent = contentFrame,
        })

        local label = newInstance("TextLabel", {
            Text = text or "Toggle",
            Size = UDim2.new(0.75, 0, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(220, 220, 240),
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = toggleFrame,
        })

        local toggleBtn = newInstance("TextButton", {
            Size = UDim2.new(0, 40, 0, 24),
            Position = UDim2.new(1, -45, 0.5, -12),
            BackgroundColor3 = default and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(100, 100, 100),
            AutoButtonColor = false,
            Parent = toggleFrame,
            Text = "",
        })
        newInstance("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(0, 12)})

        local toggled = default or false

        local function updateState(state)
            toggled = state
            toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(100, 100, 100)
            if callback then
                callback(toggled)
            end
        end

        toggleBtn.MouseButton1Click:Connect(function()
            updateState(not toggled)
        end)

        return toggleFrame
    end

    function tab:CreateDropdown(label, options, callback)
        local container = newInstance("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Color3.fromRGB(50, 50, 80),
            Parent = contentFrame,
        })
        newInstance("UICorner", {Parent = container, CornerRadius = UDim.new(0, 10)})

        local title = newInstance("TextLabel", {
            Text = label or "Dropdown",
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(230, 230, 255),
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            Parent = container,
        })

        local scroll = newInstance("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 14),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollingDirection = Enum.ScrollingDirection.X,
            Parent = container,
        })

        local layout = newInstance("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = scroll,
            Padding = UDim.new(0, 6),
        })

        -- Add option buttons
        for _, option in ipairs(options) do
            local btn = newInstance("TextButton", {
                Text = tostring(option),
                Size = UDim2.new(0, 100, 1, 0),
                BackgroundColor3 = Color3.fromRGB(100, 60, 160),
                TextColor3 = Color3.fromRGB(240, 240, 255),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Parent = scroll,
                AutoButtonColor = false,
            })
            newInstance("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 8)})

            btn.MouseButton1Click:Connect(function()
                if callback then callback(option) end
            end)
        end

        return container
    end

    -- Register this tab
    table.insert(self.tabs, tab)

    return tab
end

return DeltaBXC
