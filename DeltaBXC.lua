-- DeltaBXC UI Library by user request
local DeltaBXC = {}
DeltaBXC.__index = DeltaBXC

local UserInputService = game:GetService("UserInputService")

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

function DeltaBXC.new(title, size)
    local self = setmetatable({}, DeltaBXC)
    self.tabs = {}

    -- Main UI frame
    self.mainFrame = create("Frame", {
        Size = UDim2.new(0, size.X, 0, size.Y),
        Position = UDim2.new(0.5, -size.X / 2, 0.5, -size.Y / 2),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0,
        Parent = game:GetService("CoreGui"),
        Name = "DeltaBXCUI"
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = self.mainFrame})

    -- Title bar
    self.titleBar = create("TextLabel", {
        Text = title or "DeltaBXC",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(45, 45, 60),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = self.mainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = self.titleBar})

    -- Tab bar
    self.tabBar = create("Frame", {
        Size = UDim2.new(0, 120, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        Parent = self.mainFrame
    })

    -- Content area
    self.contentArea = create("Frame", {
        Size = UDim2.new(1, -120, 1, -30),
        Position = UDim2.new(0, 120, 0, 30),
        BackgroundTransparency = 1,
        Parent = self.mainFrame
    })

    -- Dragging support (mobile + desktop)
    self.dragging = false
    self.dragInput = nil
    self.dragStart = nil
    self.startPos = nil

    local function update(input)
        local delta = input.Position - self.dragStart
        self.mainFrame.Position = UDim2.new(0, self.startPos.X.Offset + delta.X, 0, self.startPos.Y.Offset + delta.Y)
    end

    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = true
            self.dragStart = input.Position
            self.startPos = self.mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == self.dragInput and self.dragging then
            update(input)
        end
    end)

    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            self.dragInput = input
        end
    end)

    return self
end

function DeltaBXC:Tab(name)
    local tabBtn = create("TextButton", {
        Text = name,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, (#self.tabs) * 45 + 10),
        BackgroundColor3 = Color3.fromRGB(60, 60, 90),
        TextColor3 = Color3.fromRGB(220, 220, 230),
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        Parent = self.tabBar,
        AutoButtonColor = false,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = tabBtn})

    local contentFrame = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.contentArea,
        Visible = false,
    })

    local layout = Instance.new("UIListLayout", contentFrame)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local padding = Instance.new("UIPadding", contentFrame)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)

    tabBtn.MouseButton1Click:Connect(function()
        if self.currentTab then
            self.currentTab.frame.Visible = false
            self.currentTab.button.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 130)
        contentFrame.Visible = true
        self.currentTab = {button = tabBtn, frame = contentFrame}
    end)

    if #self.tabs == 0 then
        tabBtn:MouseButton1Click()
    end

    local tabObject = {}

    function tabObject:Textbox(placeholder, callback)
        local textbox = create("TextBox", {
            Size = UDim2.new(0, 200, 0, 30),
            PlaceholderText = placeholder or "Enter text...",
            Text = "",
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(230, 230, 255),
            BackgroundColor3 = Color3.fromRGB(50, 50, 70),
            ClearTextOnFocus = true,
            Parent = contentFrame
        })
        create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = textbox})

        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(textbox.Text)
            end
        end)

        return textbox
    end

    function tabObject:Button(text, callback)
        local btn = create("TextButton", {
            Text = text or "Button",
            Size = UDim2.new(0, 140, 0, 35),
            BackgroundColor3 = Color3.fromRGB(100, 60, 160),
            TextColor3 = Color3.fromRGB(230, 230, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            Parent = contentFrame
        })
        create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = btn})

        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return btn
    end

    function tabObject:Dropdown(label, options, callback)
        local container = create("Frame", {
            Size = UDim2.new(0, 200, 0, 40),
            BackgroundColor3 = Color3.fromRGB(50, 50, 70),
            Parent = contentFrame
        })
        create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = container})

        local title = create("TextLabel", {
            Text = label or "Dropdown",
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, -18),
            TextColor3 = Color3.fromRGB(230, 230, 255),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            Parent = container
        })

        local scroll = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, #options * 100, 0, 40),
            ScrollBarThickness = 2,
            ScrollingDirection = Enum.ScrollingDirection.X,
            BackgroundTransparency = 1,
            Parent = container
        })

        local layout = Instance.new("UIListLayout", scroll)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, opt in ipairs(options) do
            local btn = create("TextButton", {
                Text = tostring(opt),
                Size = UDim2.new(0, 90, 0, 30),
                BackgroundColor3 = Color3.fromRGB(100, 60, 160),
                TextColor3 = Color3.fromRGB(240, 240, 255),
                Font = Enum.Font.Gotham,
                TextSize = 14,
                Parent = scroll
            })
            create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})

            btn.MouseButton1Click:Connect(function()
                if callback then callback(opt) end
            end)
        end

        return container
    end

    table.insert(self.tabs, tabObject)
    return tabObject
end

return DeltaBXC
