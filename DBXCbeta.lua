-- DeltaBXC2 - Fixed tabs 

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local DeltaBXC2 = {}
DeltaBXC2.__index = DeltaBXC2

local theme = {
	background = Color3.fromRGB(25, 25, 35),
	tab = Color3.fromRGB(40, 40, 60),
	tab_selected = Color3.fromRGB(60, 60, 90),
	text = Color3.fromRGB(240, 240, 255),
	button = Color3.fromRGB(120, 60, 180),
	toggle_on = Color3.fromRGB(0, 200, 100),
	toggle_off = Color3.fromRGB(100, 100, 100),
	selector = Color3.fromRGB(90, 60, 140),
}

local function new(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	return inst
end

local function addUICorner(inst, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = inst
end

function DeltaBXC2.new(title, size)
	local self = setmetatable({}, DeltaBXC2)

	local gui = new("ScreenGui", {
		Name = "DeltaBXC2_UI",
		ResetOnSpawn = false,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	local main = new("Frame", {
		Size = UDim2.new(0, size.X, 0, size.Y),
		Position = UDim2.new(0.5, -size.X / 2, 0.5, -size.Y / 2),
		BackgroundColor3 = theme.background,
		Parent = gui,
	})
	addUICorner(main, 10)

	local titleBar = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = theme.tab,
		Text = title or "DeltaBXC2",
		TextColor3 = theme.text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		Parent = main,
	})

	local sidebar = new("Frame", {
		Size = UDim2.new(0, 120, 1, -30),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = theme.tab,
		Parent = main,
	})
	addUICorner(sidebar, 8)

	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.Padding = UDim.new(0, 6)
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.Parent = sidebar

	local contentHolder = new("Frame", {
		Size = UDim2.new(1, -120, 1, -30),
		Position = UDim2.new(0, 120, 0, 30),
		BackgroundTransparency = 1,
		Parent = main,
	})

	self._gui = gui
	self._main = main
	self._sidebar = sidebar
	self._contentHolder = contentHolder
	self._tabs = {}
	self._activeTab = nil

	-- Dragging logic for main window
	do
		local dragging, dragStart, startPos
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	function self:CreateTab(name)
		local btn = new("TextButton", {
			Text = name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = theme.tab,
			TextColor3 = theme.text,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			Parent = self._sidebar,
			AutoButtonColor = false,
		})
		addUICorner(btn, 6)

		local frame = new("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 6,
			Parent = self._contentHolder,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		})

		local layout = Instance.new("UIListLayout", frame)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 6)
		local padding = Instance.new("UIPadding", frame)
		padding.PaddingLeft = UDim.new(0, 10)
		padding.PaddingTop = UDim.new(0, 10)
		padding.PaddingRight = UDim.new(0, 10)

		self._tabs[name] = {
			Button = btn,
			Frame = frame
		}

		btn.MouseButton1Click:Connect(function()
			self:SelectTab(name)
		end)

		if not self._activeTab then
			self:SelectTab(name)
		end

		local tabAPI = {}

		function tabAPI:CreateButton(text, callback)
			local btn = new("TextButton", {
				Text = text or "Button",
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = theme.button,
				TextColor3 = theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				Parent = frame,
				AutoButtonColor = false,
			})
			addUICorner(btn, 8)
			btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
			return btn
		end

		function tabAPI:CreateTextbox(placeholder, callback)
			local box = new("TextBox", {
				Text = "",
				PlaceholderText = placeholder or "Enter text...",
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = theme.tab_selected,
				TextColor3 = theme.text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = frame,
			})
			addUICorner(box, 8)
			box.FocusLost:Connect(function(enterPressed)
				if enterPressed and callback then
					callback(box.Text)
				end
			end)
			function box:GetValue()
				return box.Text
			end
			function box:SetValue(v)
				box.Text = v
			end
			return box
		end

		function tabAPI:CreateToggle(text, default, callback)
			local state = default or false

			local holder = new("Frame", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,
				Parent = frame,
			})

			new("TextLabel", {
				Text = text or "Toggle",
				Size = UDim2.new(0.75, 0, 1, 0),
				BackgroundTransparency = 1,
				TextColor3 = theme.text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			local toggleBtn = new("TextButton", {
				Size = UDim2.new(0, 40, 0, 24),
				Position = UDim2.new(1, -45, 0.5, -12),
				BackgroundColor3 = state and theme.toggle_on or theme.toggle_off,
				Text = "",
				Parent = holder,
				AutoButtonColor = false,
			})
			addUICorner(toggleBtn, 12)

			local function update(val)
				state = val
				toggleBtn.BackgroundColor3 = state and theme.toggle_on or theme.toggle_off
				if callback then
					callback(state)
				end
			end

			toggleBtn.MouseButton1Click:Connect(function()
				update(not state)
			end)

			function toggleBtn:SetValue(v)
				update(v)
			end
			function toggleBtn:GetValue()
				return state
			end

			return toggleBtn
		end

		function tabAPI:CreateSelector(label, list, callback)
			local current = 1
			local container = new("Frame", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundColor3 = theme.selector,
				Parent = frame,
			})
			addUICorner(container, 8)

			new("TextLabel", {
				Text = label or "Select",
				Size = UDim2.new(1, 0, 0, 14),
				BackgroundTransparency = 1,
				TextColor3 = theme.text,
				Font = Enum.Font.GothamSemibold,
				TextSize = 14,
				Parent = container,
			})

			local left = new("TextButton", {
				Text = "<",
				Size = UDim2.new(0, 30, 0, 18),
				Position = UDim2.new(0, 5, 0, 14),
				BackgroundColor3 = theme.tab,
				TextColor3 = theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				Parent = container,
			})
			addUICorner(left, 6)

			local right = new("TextButton", {
				Text = ">",
				Size = UDim2.new(0, 30, 0, 18),
				Position = UDim2.new(1, -35, 0, 14),
				BackgroundColor3 = theme.tab,
				TextColor3 = theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				Parent = container,
			})
			addUICorner(right, 6)

			local display = new("TextLabel", {
				Text = list[1],
				Size = UDim2.new(1, -80, 0, 18),
				Position = UDim2.new(0, 40, 0, 14),
				BackgroundColor3 = theme.tab_selected,
				TextColor3 = theme.text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = container,
			})
			addUICorner(display, 6)

			local function update()
				display.Text = list[current]
				if callback then
					callback(list[current])
				end
			end

			left.MouseButton1Click:Connect(function()
				current = (current - 2) % #list + 1
				update()
			end)

			right.MouseButton1Click:Connect(function()
				current = current % #list + 1
				update()
			end)

			return {
				GetValue = function()
					return list[current]
				end,
				SetValue = function(i)
					if type(i) == "number" and list[i] then
						current = i
						update()
					end
				end,
			}
		end

		return tabAPI
	end

	function self:SelectTab(name)
		for tabName, tabData in pairs(self._tabs) do
			local selected = (tabName == name)
			tabData.Frame.Visible = selected
			tabData.Button.BackgroundColor3 = selected and theme.tab_selected or theme.tab
		end
		self._activeTab = name
	end

	return self
end

return DeltaBXC2
