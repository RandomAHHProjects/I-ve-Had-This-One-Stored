-- Extended Compact Rayfield-like UI Library with macOS-style exit buttons and dropdown tabs + WalkSpeed Example

local UILib = {}
UILib.__index = UILib

function UILib:MakeWindow(config)
    local self = setmetatable({}, UILib)

    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    ScreenGui.Name = "CompactRayfieldUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 480, 0, 300)
    Main.Position = UDim2.new(0.5, -240, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundTransparency = 1

    -- macOS-style buttons
    local function createMacButton(color, xOffset, onClick)
        local btn = Instance.new("TextButton", TitleBar)
        btn.Size = UDim2.new(0, 14, 0, 14)
        btn.Position = UDim2.new(0, xOffset, 0.5, -7)
        btn.BackgroundColor3 = color
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        btn.MouseButton1Click:Connect(onClick)
    end

    createMacButton(Color3.fromRGB(255, 95, 86), 8, function()
        ScreenGui:Destroy()
    end)

    createMacButton(Color3.fromRGB(255, 189, 46), 28, function()
        Main.Visible = not Main.Visible
    end)

    createMacButton(Color3.fromRGB(39, 201, 63), 48, function()
        Main.Size = UDim2.new(0, 480, 0, Main.Size.Y.Offset == 300 and 500 or 300)
    end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, -30)
    Sidebar.Position = UDim2.new(0, 0, 0, 30)
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Sidebar.BorderSizePixel = 0
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

    local TabLayout = Instance.new("UIListLayout", Sidebar)
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local PageContainer = Instance.new("Folder", Main)
    PageContainer.Name = "Pages"

    function self:CreateDropdownTab(name, options)
        local tabFrame = Instance.new("Frame")
        tabFrame.Size = UDim2.new(1, -10, 0, 30)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Parent = Sidebar

        local dropdownButton = Instance.new("TextButton", tabFrame)
        dropdownButton.Size = UDim2.new(1, 0, 1, 0)
        dropdownButton.Text = "<" .. name .. ">"
        dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.TextSize = 14
        dropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Instance.new("UICorner", dropdownButton).CornerRadius = UDim.new(0, 6)

        local optionsFrame = Instance.new("Frame", Sidebar)
        optionsFrame.Size = UDim2.new(1, -10, 0, #options * 28)
        optionsFrame.Visible = false
        optionsFrame.BackgroundTransparency = 1

        local layout = Instance.new("UIListLayout", optionsFrame)
        layout.Padding = UDim.new(0, 2)

        dropdownButton.MouseButton1Click:Connect(function()
            optionsFrame.Visible = not optionsFrame.Visible
        end)

        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton", optionsFrame)
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Text = opt.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            btn.MouseButton1Click:Connect(function()
                for _, p in pairs(PageContainer:GetChildren()) do
                    p.Visible = false
                end
                opt.Page.Visible = true
            end)
        end

        return {
            AddPage = function(name)
                local page = Instance.new("ScrollingFrame", PageContainer)
                page.Size = UDim2.new(1, -150, 1, -40)
                page.Position = UDim2.new(0, 150, 0, 35)
                page.CanvasSize = UDim2.new(0, 0, 0, 0)
                page.ScrollBarThickness = 4
                page.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                page.BorderSizePixel = 0
                page.Visible = false
                Instance.new("UICorner", page).CornerRadius = UDim.new(0, 8)

                local list = Instance.new("UIListLayout", page)
                list.Padding = UDim.new(0, 4)

                local tabOption = {Name = name, Page = page}
                table.insert(options, tabOption)

                return {
                    CreateButton = function(data)
                        local btn = Instance.new("TextButton", page)
                        btn.Size = UDim2.new(1, -10, 0, 25)
                        btn.Text = data.Name
                        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        btn.TextColor3 = Color3.new(1, 1, 1)
                        btn.Font = Enum.Font.GothamBold
                        btn.TextSize = 14
                        btn.BorderSizePixel = 0
                        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
                        btn.MouseButton1Click:Connect(data.Callback)
                    end
                }
            end
        }
    end

    -- WalkSpeed dropdown tab and pages
    local wsTab = self:CreateDropdownTab("Movement", {})
    local presetsPage = wsTab:AddPage("Presets")
    local customPage = wsTab:AddPage("Custom Speed")

    local speeds = {
        {Name = "Slow (10)", Value = 10},
        {Name = "Default (16)", Value = 16},
        {Name = "Fast (50)", Value = 50},
        {Name = "Super (100)", Value = 100},
    }

    for _, speed in ipairs(speeds) do
        presetsPage:CreateButton({
            Name = speed.Name,
            Callback = function()
                local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = speed.Value
                end
            end
        })
    end

    customPage:CreateButton({
        Name = "Enter Custom Speed",
        Callback = function()
            local player = game.Players.LocalPlayer
            local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
            gui.Name = "CustomSpeedPrompt"

            local frame = Instance.new("Frame", gui)
            frame.Size = UDim2.new(0, 200, 0, 100)
            frame.Position = UDim2.new(0.5, -100, 0.5, -50)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            frame.BorderSizePixel = 0
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

            local box = Instance.new("TextBox", frame)
            box.PlaceholderText = "Enter speed"
            box.Position = UDim2.new(0.5, -80, 0, 20)
            box.Size = UDim2.new(0, 160, 0, 25)
            box.BackgroundColor3 = Color3.fromRGB(45,45,45)
            box.TextColor3 = Color3.new(1,1,1)
            box.Font = Enum.Font.Gotham
            box.TextSize = 14
            Instance.new("UICorner", box).CornerRadius = UDim.new(0,5)

            local apply = Instance.new("TextButton", frame)
            apply.Text = "Apply"
            apply.Position = UDim2.new(0.5, -40, 0, 55)
            apply.Size = UDim2.new(0, 80, 0, 25)
            apply.BackgroundColor3 = Color3.fromRGB(70,130,180)
            apply.TextColor3 = Color3.new(1,1,1)
            apply.Font = Enum.Font.GothamBold
            apply.TextSize = 14
            Instance.new("UICorner", apply).CornerRadius = UDim.new(0,5)

            apply.MouseButton1Click:Connect(function()
                local speed = tonumber(box.Text)
                if speed then
                    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
                    if hum then hum.WalkSpeed = speed end
                    gui:Destroy()
                end
            end)
        end
    })

    return self
end

return UILib
