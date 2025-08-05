-- DeltaBXC2 UI Library (Full Feature Set, No Notifications)
-- Features: Tabs, Textboxes, Toggles, Dropdowns, Side Selectors, Dragging, Close Button

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local DeltaBXC2 = {}
DeltaBXC2.__index = DeltaBXC2

local function new(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	return inst
end

local theme = {
	background = Color3.fromRGB(25, 25, 35),
	tab = Color3.fromRGB(40, 40, 60),
	tab_selected = Color3.fromRGB(60, 60, 90),
	text = Color3.fromRGB(240, 240, 255),
	button = Color3.fromRGB(120, 60, 180),
	toggle_on = Color3.fromRGB(0, 200, 100),
	toggle_off = Color3.fromRGB(100, 100, 100),
	selector = Color3.fromRGB(90, 60, 140),
	close_hover = Color3.fromRGB(200, 60, 60),
}

-- Prevent duplicates
if Players.LocalPlayer.PlayerGui:FindFirstChild("DeltaBXC2_UI") then
	Players.LocalPlayer:Kick("Already loaded DeltaBXC2 UI.")
	return
end

function DeltaBXC2.new(title)
	local self = setmetatable({}, DeltaBXC2)

	local gui = new("ScreenGui", {
		Name = "DeltaBXC2_UI",
		ResetOnSpawn = false,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	local main = new("Frame", {
		Size = UDim2.new(0, 500, 0, 350),
		Position = UDim2.new(0.5, -250, 0.5, -175),
		BackgroundColor3 = theme.background,
		Parent = gui,
	})
	new("UICorner", {Parent = main, CornerRadius = UDim.new(0, 8)})

	local topbar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = theme.tab,
		Parent = main,
	})
	new("UICorner", {Parent = topbar, CornerRadius = UDim.new(0, 8)})

	local titleLabel = new("TextLabel", {
		Text = title or "DeltaBXC2",
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		TextColor3 = theme.text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topbar,
	})

	local closeBtn = new("TextButton", {
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -32, 0, 0),
		Text = "X",
		TextColor3 = theme.text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		BackgroundTransparency = 1,
		Parent = topbar,
	})
	closeBtn.MouseEnter:Connect(function()
		closeBtn.BackgroundTransparency = 0
		closeBtn.BackgroundColor3 = theme.close_hover
	end)
	closeBtn.MouseLeave:Connect(function()
		closeBtn.BackgroundTransparency = 1
	end)
	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	-- Dragging
	do
		local dragging = false
		local dragStart, startPos

		topbar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		topbar.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	-- Sidebar
	local sidebar = new("Frame", {
		Size = UDim2.new(0, 120, 1, -32),
		Position = UDim2.new(0, 0, 0, 32),
		BackgroundColor3 = theme.tab,
		Parent = main,
	})
	new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 6)})
	new("UIListLayout", {
		Parent = sidebar,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	})

	-- Content
	local content = new("Frame", {
		Size = UDim2.new(1, -120, 1, -32),
		Position = UDim2.new(0, 120, 0, 32),
		BackgroundTransparency = 1,
		Parent = main,
	})

	self._gui = gui
	self._tabs = {}
	self._activeTab = nil

	function self:CreateTab(name)
		local tabBtn = new("TextButton", {
			Text = name,
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundColor3 = theme.tab,
			TextColor3 = theme.text,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			Parent = sidebar,
			AutoButtonColor = false,
		})
		new("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 6)})

		local tabFrame = new("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 4,
			Parent = content,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		})
		new("UIListLayout", {Parent = tabFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
		new("UIPadding", {
			Parent = tabFrame,
			PaddingTop = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		})

		tabBtn.MouseButton1Click:Connect(function()
			if self._activeTab then
				self._activeTab.btn.BackgroundColor3 = theme.tab
				self._activeTab.frame.Visible = false
			end
			tabBtn.BackgroundColor3 = theme.tab_selected
			tabFrame.Visible = true
			self._activeTab = {btn = tabBtn, frame = tabFrame}
		end)

		if not self._activeTab then
			tabBtn:MouseButton1Click()
		end

		local tab = {}

		function tab:Textbox(placeholder, callback)
			local box = new("TextBox", {
				Text = "",
				PlaceholderText = placeholder or "Enter text...",
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = theme.tab_selected,
				TextColor3 = theme.text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = tabFrame,
			})
			new("UICorner", {Parent = box, CornerRadius = UDim.new(0, 6)})

			box.FocusLost:Connect(function(enter)
				if enter and callback then
					callback(box.Text)
				end
			end)
			return box
		end

		function tab:Toggle(text, default, callback)
			local state = default or false

			local holder = new("Frame", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,
				Parent = tabFrame,
			})

			local label = new("TextLabel", {
				Text = text,
				Size = UDim2.new(0.7, 0, 1, 0),
				TextColor3 = theme.text,
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = holder,
			})

			local toggle = new("TextButton", {
				Size = UDim2.new(0, 40, 0, 24),
				Position = UDim2.new(1, -50, 0.5, -12),
				BackgroundColor3 = state and theme.toggle_on or theme.toggle_off,
				Text = "",
				Parent = holder,
				AutoButtonColor = false,
			})
			new("UICorner", {Parent = toggle, CornerRadius = UDim.new(0, 12)})

			toggle.MouseButton1Click:Connect(function()
				state = not state
				toggle.BackgroundColor3 = state and theme.toggle_on or theme.toggle_off
				if callback then callback(state) end
			end)

			return toggle
		end

		function tab:Dropdown(labelText, options, callback)
			local current = options[1] or ""
			local label = new("TextLabel", {
				Text = labelText or "Dropdown",
				Size = UDim2.new(1, 0, 0, 24),
				TextColor3 = theme.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				BackgroundTransparency = 1,
				Parent = tabFrame,
			})

			local holder = new("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = theme.selector,
				Parent = tabFrame,
			})
			new("UICorner", {Parent = holder, CornerRadius = UDim.new(0, 6)})

			local left = new("TextButton", {
				Text = "<",
				Size = UDim2.new(0, 30, 1, 0),
				BackgroundTransparency = 1,
				TextColor3 = theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				Parent = holder,
			})
			local center = new("TextLabel", {
				Text = current,
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.new(0, 30, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = theme.text,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				Parent = holder,
			})
			local right = new("TextButton", {
				Text = ">",
				Size = UDim2.new(0, 30, 1, 0),
				Position = UDim2.new(1, -30, 0, 0),
				BackgroundTransparency = 1,
				TextColor3 = theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				Parent = holder,
			})

			local index = 1
			local function update()
				current = options[index]
				center.Text = current
				if callback then callback(current) end
			end

			left.MouseButton1Click:Connect(function()
				index = (index - 2) % #options + 1
				update()
			end)
			right.MouseButton1Click:Connect(function()
				index = index % #options + 1
				update()
			end)

			update()
			return holder
		end

		self._tabs[name] = tab
		return tab
	end

	return self
end

return DeltaBXC2
