-- DeltaBXC UI Library (fixed with explicit checks)

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

    -- Create ScreenGui container for UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeltaBXCUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    self.screenGui = screenGui

    -- Main container frame inside ScreenGui
    local container = create("Frame", {
        Size = UDim2.new(0, size.X, 0, size.Y),
        Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        BorderSizePixel = 0,
        Parent = screenGui
    })
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = container})
    self.container = container

    local titleBar = create("TextLabel", {
        Text = title or "DeltaBXC",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(45, 45, 60),
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = container
    })
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = titleBar})
    self.titleBar = titleBar

    local tabBar = create("Frame", {
        Size = UDim2.new(0, 120, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        Parent = container
    })
    self.tabBar = tabBar

    local contentArea = create("Frame", {
        Size = UDim2.new(1, -120, 1, -30),
        Position = UDim2.new(0, 120, 0, 30),
        BackgroundTransparency = 1,
        Parent = container
    })
    self.contentArea = contentArea

    -- Dragging variables
    self.dragging = false
    self.dragInput = nil
    self.dragStart = nil
    self.startPos = nil

    local function update(input)
        local delta = input.Position - self.dragStart
        container.Position = UDim2.new(0, self.startPos.X.Offset + delta.X, 0, self.startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = true
            self.dragStart = input.Position
            self.startPos = container.Position

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

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            self.dragInput = input
        end
    end)

    return self
end

function DeltaBXC:Tab(name)
    -- Ensure tabBar exists
    assert(self.tabBar and self.contentArea, "UI not properly initialized")

    local tabBtn = Instance.new("TextButton")
    tabBtn.Text = name or "Tab"
    tabBtn.Size = UDim2.new(1, -20, 0, 40)
    tabBtn.Position = UDim2.new(0, 10, 0, (#self.tabs)*45 + 10)
    tabBtn.BackgroundColor3 = Color3.fromRGB(60,60,90)
    tabBtn.TextColor3 = Color3.fromRGB(220,220,230)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 16
    tabBtn.Parent = self.tabBar
    tabBtn.AutoButtonColor = false
    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 8)
    uicorner.Parent = tabBtn

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible = false
    contentFrame.Parent = self.contentArea

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = contentFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0,10)
    padding.PaddingLeft = UDim.new(0,10)
    padding.PaddingRight = UDim.new(0,10)
    padding.Parent = contentFrame

    tabBtn.MouseButton1Click:Connect(function()
        if self.currentTab then
            self.currentTab.frame.Visible = false
            self.currentTab.button.BackgroundColor3 = Color3.fromRGB(60,60,90)
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(90,90,130)
        contentFrame.Visible = true
        self.currentTab = {button = tabBtn, frame = contentFrame}
    end)

    if #self.tabs == 0 then
        tabBtn:MouseButton1Click()
    end

    local tabObject = {}

    function tabObject:Textbox(placeholder, callback)
        local textbox = Instance.new("TextBox")
        textbox.Size = UDim2.new(0, 200, 0, 30)
        textbox.PlaceholderText = placeholder or "Enter text..."
        textbox.Text = ""
        textbox.Font = Enum.Font.Gotham
        textbox.TextSize = 16
        textbox.TextColor3 = Color3.fromRGB(230,230,255)
        textbox.BackgroundColor3 = Color3.fromRGB(50,50,70)
        textbox.ClearTextOnFocus = true
        textbox.Parent = contentFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = textbox

        textbox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                callback(textbox.Text)
            end
        end)

        return textbox
    end

    function tabObject:Button(text, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text or "Button"
        btn.Size = UDim2.new(0, 140, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(100, 60, 160)
        btn.TextColor3 = Color3.fromRGB(230, 230, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Parent = contentFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return btn
    end

    function tabObject:Dropdown(label, options, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 200, 0, 40)
        container.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        container.Parent = contentFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = container

        local title = Instance.new("TextLabel")
        title.Text = label or "Dropdown"
        title.Size = UDim2.new(1, 0, 0, 14)
        title.Position = UDim2.new(0, 0, 0, -18)
        title.TextColor3 = Color3.fromRGB(230, 230, 255)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamSemibold
        title.TextSize = 14
        title.Parent = container

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.CanvasSize = UDim2.new(0, #options * 100, 0, 40)
        scroll.ScrollBarThickness = 2
        scroll.ScrollingDirection = Enum.ScrollingDirection.X
        scroll.BackgroundTransparency = 1
        scroll.Parent = container

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll

        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Text = tostring(opt)
            btn.Size = UDim2.new(0, 90, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(100, 60, 160)
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Parent = scroll

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                if callback then
                    callback(opt)
                end
            end)
        end

        return container
    end

    table.insert(self.tabs, tabObject)
    return tabObject
end

return DeltaBXC
