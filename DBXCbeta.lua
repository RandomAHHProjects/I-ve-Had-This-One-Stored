-- DeltaBXC2 UI Library (Full Features, draggable window, tabs, textboxes, toggles, dropdowns, side selectors, close button)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Prevent multiple instances:
if player.PlayerGui:FindFirstChild("DeltaBXC2_UI") then
    player:Kick("Already loaded DeltaBXC2 UI.")
    return
end

local theme = {
    background = Color3.fromRGB(20, 10, 30),
    tab = Color3.fromRGB(50, 30, 80),
    tab_selected = Color3.fromRGB(120, 50, 170),
    text = Color3.fromRGB(240, 220, 255),
    button = Color3.fromRGB(120, 50, 170),
    toggle_on = Color3.fromRGB(0, 200, 100),
    toggle_off = Color3.fromRGB(70, 70, 90),
    selector = Color3.fromRGB(90, 60, 140),
}

local function new(class, props)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    return inst
end

local DeltaBXC2 = {}
DeltaBXC2.__index = DeltaBXC2

function DeltaBXC2.new(title, size)
    local self = setmetatable({}, DeltaBXC2)

    -- Root GUI
    local gui = new("ScreenGui", {
        Name = "DeltaBXC2_UI",
        Parent = player:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
    })

    -- Main frame
    local main = new("Frame", {
        Size = size or UDim2.new(0, 520, 0, 360),
        Position = UDim2.new(0.5, -260, 0.5, -180),
        BackgroundColor3 = theme.background,
        Parent = gui,
    })
    new("UICorner", {Parent = main, CornerRadius = UDim.new(0, 14)})

    -- Top bar for dragging + close button
    local topBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.tab,
        Parent = main,
    })
    new("UICorner", {Parent = topBar, CornerRadius = UDim.new(0, 14)})

    local titleLabel = new("TextLabel", {
        Text = title or "DeltaBXC2 UI",
        Size = UDim2.new(0.8, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 14, 0, 0),
        Parent = topBar,
    })

    local closeBtn = new("TextButton", {
        Text = "✕",
        Size = UDim2.new(0, 40, 1, 0),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundColor3 = theme.button,
        TextColor3 = theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        AutoButtonColor = false,
        Parent = topBar,
    })
    new("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 14)})

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Sidebar for tabs
    local sidebar = new("Frame", {
        Size = UDim2.new(0, 140, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = theme.tab,
        Parent = main,
    })
    new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 14)})

    local sidebarLayout = new("UIListLayout", {
        Parent = sidebar,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
    })
    local sidebarPadding = new("UIPadding", {
        Parent = sidebar,
        PaddingTop = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    })

    -- Content area for tabs
    local content = new("Frame", {
        Size = UDim2.new(1, -140, 1, -36),
        Position = UDim2.new(0, 140, 0, 36),
        BackgroundTransparency = 1,
        Parent = main,
    })

    self._gui = gui
    self._main = main
    self._tabs = {}
    self._content = content
    self._active = nil

    -- Drag support for main window
    do
        local dragging = false
        local dragStartPos
        local frameStartPos

        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStartPos = input.Position
                frameStartPos = main.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStartPos
                main.Position = UDim2.new(
                    0,
                    frameStartPos.X.Offset + delta.X,
                    0,
                    frameStartPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- Tab creation
    function self:CreateTab(name)
        local tabBtn = new("TextButton", {
            Text = name,
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = theme.tab,
            TextColor3 = theme.text,
            Font = Enum.Font.Gotham,
            TextSize = 16,
            AutoButtonColor = false,
            Parent = sidebar,
        })
        new("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 12)})

        local tabFrame = new("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 6,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            VerticalScrollBarInset = Enum.ScrollBarInset.Always,
            Parent = content,
            Visible = false,
        })
        local tabLayout = new("UIListLayout", {
            Parent = tabFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
        })
        local tabPadding = new("UIPadding", {
            Parent = tabFrame,
            PaddingTop = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14),
        })

        tabBtn.MouseButton1Click:Connect(function()
            if self._active then
                self._active.btn.BackgroundColor3 = theme.tab
                self._active.frame.Visible = false
            end
            tabBtn.BackgroundColor3 = theme.tab_selected
            tabFrame.Visible = true
            self._active = {btn = tabBtn, frame = tabFrame}
        end)

        if not self._active then
            tabBtn:MouseButton1Click()
        end

        local tab = {}
        tab.name = name
        tab.frame = tabFrame

        -- Button element
        function tab:CreateButton(text, callback)
            local btn = new("TextButton", {
                Text = text or "Button",
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = theme.button,
                TextColor3 = theme.text,
                Font = Enum.Font.GothamBold,
                TextSize = 18,
                AutoButtonColor = false,
                Parent = tabFrame,
            })
            new("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 14)})

            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return btn
        end

        -- Textbox element
        function tab:CreateTextbox(placeholder, callback)
            local box = new("TextBox", {
                PlaceholderText = placeholder or "Enter text...",
                Text = "",
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = theme.tab_selected,
                TextColor3 = theme.text,
                Font = Enum.Font.Gotham,
                TextSize = 16,
                ClearTextOnFocus = false,
                Parent = tabFrame,
            })
            new("UICorner", {Parent = box, CornerRadius = UDim.new(0, 14)})

            box.FocusLost:Connect(function(enterPressed)
                if enterPressed and callback then
                    callback(box.Text)
                end
            end)

            function box:GetValue()
                return box.Text
            end
            function box:SetValue(val)
                box.Text = val
            end

            return box
        end

        -- Toggle element
        function tab:CreateToggle(text, default, callback)
            local state = default or false

            local holder = new("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Parent = tabFrame,
            })

            local label = new("TextLabel", {
                Text = text or "Toggle",
                Size = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.text,
                Font = Enum.Font.Gotham,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local toggleBtn = new("TextButton", {
                Size = UDim2.new(0, 40, 0, 24),
                Position = UDim2.new(1, -46, 0.5, -12),
                BackgroundColor3 = state and theme.toggle_on or theme.toggle_off,
                Text = "",
                AutoButtonColor = false,
                Parent = holder,
            })
            new("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(0, 12)})

            local function updateVisual()
                toggleBtn.BackgroundColor3 = state and theme.toggle_on or theme.toggle_off
            end

            toggleBtn.MouseButton1Click:Connect(function()
                state = not state
                updateVisual()
                if callback then callback(state) end
            end)

            function holder:GetValue()
                return state
            end
            function holder:SetValue(val)
                state = val and true or false
                updateVisual()
            end

            updateVisual()
            return holder
        end

        -- Dropdown (single select)
        function tab:CreateDropdown(labelText, options, callback)
            options = options or {}
            local selected = nil

            local holder = new("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                Parent = tabFrame,
            })

            local label = new("TextLabel", {
                Text = labelText or "Dropdown",
                Size = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.text,
                Font = Enum.Font.Gotham,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local dropdownBtn = new("TextButton", {
                Size = UDim2.new(0.5, -8, 1, 0),
                Position = UDim2.new(0.5, 8, 0, 0),
                Text = "...",
                BackgroundColor3 = theme.selector,
                TextColor3 = theme.text,
                Font = Enum.Font.GothamBold,
                TextSize = 20,
                AutoButtonColor = false,
                Parent = holder,
            })
            new("UICorner", {Parent = dropdownBtn, CornerRadius = UDim.new(0, 14)})

            local listFrame = new("Frame", {
                Size = UDim2.new(0, 180, 0, 0),
                Position = UDim2.new(0, 0, 1, 6),
                BackgroundColor3 = theme.tab,
                Visible = false,
                ClipsDescendants = true,
                Parent = holder,
            })
            new("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0, 14)})

            local layout = new("UIListLayout", {
                Parent = listFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            local padding = new("UIPadding", {
                Parent = listFrame,
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
            })

            local function updateListSize()
                listFrame.Size = UDim2.new(0, 180, 0, #options * 32 + 16)
            end
            updateListSize()

            for _, option in ipairs(options) do
                local optBtn = new("TextButton", {
                    Text = option,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = theme.tab,
                    TextColor3 = theme.text,
                    Font = Enum.Font.Gotham,
                    TextSize = 16,
                    AutoButtonColor = false,
                    Parent = listFrame,
                })
                new("UICorner", {Parent = optBtn, CornerRadius = UDim.new(0, 10)})

                optBtn.MouseButton1Click:Connect(function()
                    selected = option
                    dropdownBtn.Text = option
                    listFrame.Visible = false
                    if callback then
                        callback(option)
                    end
                end)
            end

            dropdownBtn.MouseButton1Click:Connect(function()
                listFrame.Visible = not listFrame.Visible
            end)

            -- Close dropdown if clicked outside
            UserInputService.InputBegan:Connect(function(input, processed)
                if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 and listFrame.Visible then
                    if not holder:IsAncestorOf(input.Target) then
                        listFrame.Visible = false
                    end
                end
            end)

            function holder:GetValue()
                return selected
            end
            function holder:SetValue(val)
                selected = val
                dropdownBtn.Text = val or "..."
            end

            dropdownBtn.Text = "..."

            return holder
        end

        -- Side-scroller selector element (left/right buttons cycling options)
        function tab:CreateSideSelector(labelText, options, callback)
            options = options or {}
            local selectedIndex = 1

            local holder = new("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Parent = tabFrame,
            })

            local label = new("TextLabel", {
                Text = labelText or "Selector",
                Size = UDim2.new(0.4, 0, 1, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.text,
                Font = Enum.Font.Gotham,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = holder,
            })

            local leftBtn = new("TextButton", {
                Text = "<",
                Size = UDim2.new(0, 36, 0, 36),
                Position = UDim2.new(0.4, 6, 0, 3),
                BackgroundColor3 = theme.selector,
                TextColor3 = theme.text,
                Font = Enum.Font.GothamBold,
                TextSize = 20,
                AutoButtonColor = false,
                Parent = holder,
            })
            new("UICorner", {Parent = leftBtn, CornerRadius = UDim.new(0, 12)})

            local rightBtn = new("TextButton", {
                Text = ">",
                Size = UDim2.new(0, 36, 0, 36),
                Position = UDim2.new(0.85, -42, 0, 3),
                BackgroundColor3 = theme.selector,
                TextColor3 = theme.text,
                Font = Enum.Font.GothamBold,
                TextSize = 20,
                AutoButtonColor = false,
                Parent = holder,
            })
            new("UICorner", {Parent = rightBtn, CornerRadius = UDim.new(0, 12)})

            local displayLabel = new("TextLabel", {
                Text = options[selectedIndex] or "...",
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0.5, 0, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.text,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = holder,
            })

            local function updateDisplay()
                displayLabel.Text = options[selectedIndex] or "..."
                if callback then
                    callback(options[selectedIndex], selectedIndex)
                end
            end

            leftBtn.MouseButton1Click:Connect(function()
                selectedIndex = selectedIndex - 1
                if selectedIndex < 1 then selectedIndex = #options end
                updateDisplay()
            end)

            rightBtn.MouseButton1Click:Connect(function()
                selectedIndex = selectedIndex + 1
                if selectedIndex > #options then selectedIndex = 1 end
                updateDisplay()
            end)

            function holder:GetValue()
                return options[selectedIndex], selectedIndex
            end
            function holder:SetValue(valueOrIndex)
                if type(valueOrIndex) == "number" then
                    selectedIndex = math.clamp(valueOrIndex, 1, #options)
                else
                    for i, v in ipairs(options) do
                        if v == valueOrIndex then
                            selectedIndex = i
                            break
                        end
                    end
                end
                updateDisplay()
            end

            updateDisplay()
            return holder
        end

        return tab
    end

    return self
end

return DeltaBXC2
