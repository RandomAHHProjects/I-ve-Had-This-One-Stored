
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

	local Title = Instance.new("TextLabel", Main)
	Title.Size = UDim2.new(1, 0, 0, 30)
	Title.Text = config.Name or "RayfieldUI"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.BackgroundTransparency = 1

	local Sidebar = Instance.new("Frame", Main)
	Sidebar.Size = UDim2.new(0, 110, 1, -30)
	Sidebar.Position = UDim2.new(0, 0, 0, 30)
	Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	Sidebar.BorderSizePixel = 0
	Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

	local TabButtonsLayout = Instance.new("UIListLayout", Sidebar)
	TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabButtonsLayout.Padding = UDim.new(0, 5)

	local PageContainer = Instance.new("Folder", Main)
	PageContainer.Name = "Pages"

	function self:CreateTab(name)
		local TabPage = Instance.new("ScrollingFrame", PageContainer)
		TabPage.Visible = false
		TabPage.Size = UDim2.new(1, -120, 1, -40)
		TabPage.Position = UDim2.new(0, 115, 0, 35)
		TabPage.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		TabPage.BorderSizePixel = 0
		TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabPage.ScrollBarThickness = 4
		Instance.new("UICorner", TabPage).CornerRadius = UDim.new(0, 8)

		local layout = Instance.new("UIListLayout", TabPage)
		layout.Padding = UDim.new(0, 4)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		local TabBtn = Instance.new("TextButton", Sidebar)
		TabBtn.Size = UDim2.new(1, -10, 0, 30)
		TabBtn.Text = name
		TabBtn.TextColor3 = Color3.new(1, 1, 1)
		TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		TabBtn.BorderSizePixel = 0
		TabBtn.Font = Enum.Font.Gotham
		TabBtn.TextSize = 14
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

		TabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(PageContainer:GetChildren()) do
				p.Visible = false
			end
			TabPage.Visible = true
		end)

		local TabObject = {}

		function TabObject:CreateToggle(data)
			local Toggle = Instance.new("TextButton", TabPage)
			Toggle.Size = UDim2.new(1, -10, 0, 25)
			Toggle.Text = "⬜ " .. data.Name
			Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			Toggle.TextColor3 = Color3.new(1, 1, 1)
			Toggle.Font = Enum.Font.Gotham
			Toggle.TextSize = 14
			Toggle.BorderSizePixel = 0
			Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 5)

			local state = false
			Toggle.MouseButton1Click:Connect(function()
				state = not state
				Toggle.Text = (state and "✅ " or "⬜ ") .. data.Name
				if data.Callback then
					data.Callback(state)
				end
			end)
		end

		function TabObject:CreateButton(data)
			local Button = Instance.new("TextButton", TabPage)
			Button.Size = UDim2.new(1, -10, 0, 25)
			Button.Text = data.Name
			Button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
			Button.TextColor3 = Color3.new(1, 1, 1)
			Button.Font = Enum.Font.GothamBold
			Button.TextSize = 14
			Button.BorderSizePixel = 0
			Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)

			Button.MouseButton1Click:Connect(function()
				if data.Callback then
					data.Callback()
				end
			end)
		end

		return TabObject
	end

	return self
end

return UILib
