-- DeltaExecutorUILib.lua
local DeltaExecutorUILib = {}
DeltaExecutorUILib.__index = DeltaExecutorUILib

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Utils
local function create(className, properties)
    local obj = Instance.new(className)
    for k,v in pairs(properties) do
        obj[k] = v
    end
    return obj
end

function DeltaExecutorUILib.new(title, size)
    local self = setmetatable({}, DeltaExecutorUILib)
    self.title = title or "Delta UI"
    self.size = size or Vector2.new(400, 300)

    -- Main ScreenGui
    self.screenGui = create("ScreenGui", {
        Name = "DeltaExecutorUILibGUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game:GetService("CoreGui")
    })

    -- Main Frame (window)
    self.mainFrame = create("Frame", {
        Size = UDim2.new(0, self.size.X, 0, self.size.Y),
        Position = UDim2.new(0.5, -self.size.X/2, 0.5, -self.size.Y/2),
        BackgroundColor3 = Color3.fromRGB(30, 30, 40),
        Parent = self.screenGui
    })
    self.mainFrame.ClipsDescendants = true

    -- Rounded corners UI
    local corner = create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.mainFrame})

    -- Title bar
    self.titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(45, 45, 60),
        Parent = self.mainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.titleBar})

    self.titleLabel = create("TextLabel", {
        Text = self.title,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = self.titleBar
    })

    -- Minimize & Exit buttons container
    self.btnContainer = create("Frame", {
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.titleBar
    })

    -- Minimize button
    self.minimizeBtn = create("TextButton", {
        Text = "-",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 40, 1, 0),
        Parent = self.btnContainer
    })

    -- Exit button
    self.exitBtn = create("TextButton", {
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(220, 80, 80),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        Parent = self.btnContainer
    })

    -- Left tab bar
    self.tabBar = create("Frame", {
        Size = UDim2.new(0, 120, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        Parent = self.mainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.tabBar})

    -- Container for tab buttons
    self.tabs = {}
    self.currentTab = nil

    -- Content area (right side)
    self.contentArea = create("Frame", {
        Size = UDim2.new(1, -120, 1, -30),
        Position = UDim2.new(0, 120, 0, 30),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        Parent = self.mainFrame
    })
    create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.contentArea})

    -- Drag logic (no clamps)
    self.dragging = false
    self.dragStart = Vector2.new()
    self.startPos = Vector2.new()

    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if self.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.dragStart
            local newPos = self.startPos + UDim2.new(0, delta.X, 0, delta.Y)
            self.mainFrame.Position = newPos
        end
    end)

    -- Minimize logic
    local minimized = false
    self.minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            self.contentArea.Visible = false
            self.tabBar.Visible = false
            self.mainFrame.Size = UDim2.new(self.mainFrame.Size.X.Scale, self.mainFrame.Size.X.Offset, 0, 30)
        else
            self.contentArea.Visible = true
            self.tabBar.Visible = true
            self.mainFrame.Size = UDim2.new(self.mainFrame.Size.X.Scale, self.size.X, 0, self.size.Y)
        end
    end)

    -- Exit logic
    self.exitBtn.MouseButton1Click:Connect(function()
        self.screenGui:Destroy()
    end)

    return self
end

-- Adds a new tab with a name and returns the content frame for you to add elements
function DeltaExecutorUILib:AddTab(name)
    local tabBtn = create("TextButton", {
        Text = name,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, (#self.tabs)*45 + 10),
        BackgroundColor3 = Color3.fromRGB(60, 60, 90),
        TextColor3 = Color3.fromRGB(220, 220, 230),
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        Parent = self.tabBar,
        AutoButtonColor = false,
        ClipsDescendants = true,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = tabBtn})

    local contentFrame = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.contentArea,
        Visible = false,
        ClipsDescendants = true,
    })

    -- Tab switch handler
    tabBtn.MouseButton1Click:Connect(function()
        if self.currentTab then
            self.currentTab.content.Visible = false
            self.currentTab.button.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        end
        tabBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 130)
        contentFrame.Visible = true
        self.currentTab = {button = tabBtn, content = contentFrame}
    end)

    table.insert(self.tabs, {button = tabBtn, content = contentFrame})

    -- Auto-select first tab
    if #self.tabs == 1 then
        tabBtn:MouseButton1Click()
    end

    return contentFrame
end

-- Create Button element
function DeltaExecutorUILib:CreateButton(parent, text, callback)
    local btn = create("TextButton", {
        Text = text or "Button",
        Size = UDim2.new(0, 140, 0, 35),
        BackgroundColor3 = Color3.fromRGB(100, 60, 160),
        TextColor3 = Color3.fromRGB(230, 230, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        Parent = parent
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = btn})

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)

    return btn
end

-- Create Toggle element
function DeltaExecutorUILib:CreateToggle(parent, text, initialState, callback)
    local frame = create("Frame", {
        Size = UDim2.new(0, 160, 0, 35),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local label = create("TextLabel", {
        Text = text or "Toggle",
        TextColor3 = Color3.fromRGB(220, 220, 230),
        Font = Enum.Font.Gotham,
        TextSize = 16,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    local toggleBtn = create("Frame", {
        Size = UDim2.new(0, 28, 0, 18),
        Position = UDim2.new(1, -30, 0.5, -9),
        BackgroundColor3 = initialState and Color3.fromRGB(120, 60, 180) or Color3.fromRGB(70, 70, 90),
        Parent = frame
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleBtn})

    local circle = create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = initialState and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(230, 230, 255),
        Parent = toggleBtn
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = circle})

    local toggled = initialState or false

    local function setToggle(state)
        toggled = state
        toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(120, 60, 180) or Color3.fromRGB(70, 70, 90)
        circle:TweenPosition(toggled and UDim2.new(1, -14, 0, 2) or UDim2.new(0, 2, 0, 2), "Out", "Quad", 0.2, true)
        if callback then
            callback(toggled)
        end
    end

    toggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setToggle(not toggled)
        end
    end)

    return frame, function() return toggled end
end

-- Create Textbox element
function DeltaExecutorUILib:CreateTextbox(parent, placeholder, callback)
    local textbox = create("TextBox", {
        Size = UDim2.new(0, 200, 0, 30),
        PlaceholderText = placeholder or "Enter text...",
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(230, 230, 255),
        BackgroundColor3 = Color3.fromRGB(50, 50, 70),
        ClearTextOnFocus = false,
        Parent = parent
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = textbox})

    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(textbox.Text)
        end
    end)

    return textbox
end

return DeltaExecutorUILib
