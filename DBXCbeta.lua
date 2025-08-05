-- DeltaBXC2 Full UI Library with Save/Load, Multi-Select Dropdowns & Notifications

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local DeltaBXC2 = {}
DeltaBXC2.__index = DeltaBXC2

local CONFIG_FOLDER = "DeltaBXC2Configs"

local theme = {
	background = Color3.fromRGB(25, 25, 35),
	tab = Color3.fromRGB(40, 40, 60),
	tab_selected = Color3.fromRGB(60, 60, 90),
	text = Color3.fromRGB(240, 240, 255),
	button = Color3.fromRGB(120, 60, 180),
	toggle_on = Color3.fromRGB(0, 200, 100),
	toggle_off = Color3.fromRGB(100, 100, 100),
	selector = Color3.fromRGB(90, 60, 140),
	notify_bg = Color3.fromRGB(35, 35, 50),
	notify_info = Color3.fromRGB(70, 130, 180),
	notify_warn = Color3.fromRGB(180, 130, 70),
	notify_error = Color3.fromRGB(180, 70, 70),
}

local function new(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	return inst
end

-- Prevent multiple UI instances
if Players.LocalPlayer.PlayerGui:FindFirstChild("DeltaBXC2_UI") then
	Players.LocalPlayer:Kick("Already loaded DeltaBXC2 UI.")
	return
end

function DeltaBXC2.new(title, size)
	local self = setmetatable({}, DeltaBXC2)

	-- Root UI
	local gui = new("ScreenGui", {
		Name = "DeltaBXC2_UI",
		ResetOnSpawn = false,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})

	-- Main Frame
	local main = new("Frame", {
		Size = size or UDim2.new(0, 480, 0, 320),
		Position = UDim2.new(0.5, -(size and size.X.Offset or 240), 0.5, -(size and size.Y.Offset or 160)),
		BackgroundColor3 = theme.background,
		Parent = gui,
	})
	new("UICorner", {Parent = main, CornerRadius = UDim.new(0, 10)})

	-- Title Bar
	local titleBar = new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = theme.tab,
		Text = title or "DeltaBXC2",
		TextColor3 = theme.text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		Parent = main,
	})
	new("UICorner", {Parent = titleBar, CornerRadius = UDim.new(0, 10)})

	-- Sidebar
	local sidebar = new("Frame", {
		Size = UDim2.new(0, 120, 1, -30),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundColor3 = theme.tab,
		Parent = main,
	})
	new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 8)})
	local sidebarLayout = new("UIListLayout", {
		Parent = sidebar,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	})

	-- Content Frame
	local content = new("Frame", {
		Size = UDim2.new(1, -120, 1, -30),
		Position = UDim2.new(0, 120, 0, 30),
		BackgroundTransparency = 1,
		Parent = main,
	})

	self._gui = gui
	self._main = main
	self._tabs = {}
	self._content = content
	self._active = nil
	self._configFolder = CONFIG_FOLDER

	-- Drag logic for main frame
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

	-- Notification system
	self._notifications = {}
	self._notifGui = nil

	-- Private method: Create notification UI
	function self:_createNotification(title, message, duration, ntype)
		duration = duration or 3
		ntype = ntype or "info"
		if not self._notifGui then
			self._notifGui = new("ScreenGui", {
				Name = "DeltaBXC2_Notifications",
				Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
			})
		end

		local colors = {
			info = theme.notify_info,
			warn = theme.notify_warn,
			error = theme.notify_error,
		}

		local notifFrame = new("Frame", {
			Size = UDim2.new(0, 300, 0, 80),
			Position = UDim2.new(0.5, -150, 1, -90 - (#self._notifications * 90)),
			BackgroundColor3 = theme.notify_bg,
			Parent = self._notifGui,
		})
		new("UICorner", {Parent = notifFrame, CornerRadius = UDim.new(0, 10)})

		local titleLabel = new("TextLabel", {
			Text = title,
			Size = UDim2.new(1, -20, 0, 24),
			Position = UDim2.new(0, 10, 0, 8),
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			TextColor3 = colors[ntype] or theme.text,
			BackgroundTransparency = 1,
			Parent = notifFrame,
		})

		local msgLabel = new("TextLabel", {
			Text = message,
			Size = UDim2.new(1, -20, 0, 44),
			Position = UDim2.new(0, 10, 0, 32),
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = theme.text,
			BackgroundTransparency = 1,
			TextWrapped = true,
			Parent = notifFrame,
		})

		table.insert(self._notifications, notifFrame)

		-- Animate fade-in
		for _, obj in pairs({notifFrame, titleLabel, msgLabel}) do
			obj.BackgroundTransparency = 1
			if obj:IsA("TextLabel") then
				obj.TextTransparency = 1
			end
		end

		for _, obj in pairs({notifFrame, titleLabel, msgLabel}) do
			local tween = TweenService:Create(obj, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0,
				TextTransparency = 0,
			})
			tween:Play()
		end

		-- Fade out and cleanup
		delay(duration, function()
			for _, obj in pairs({notifFrame, titleLabel, msgLabel}) do
				local tween = TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					BackgroundTransparency = 1,
					TextTransparency = 1,
				})
				tween:Play()
			end
			wait(0.5)
			notifFrame:Destroy()
			for i, v in ipairs(self._notifications) do
				if v == notifFrame then
					table.remove(self._notifications, i)
					break
				end
			end
			-- Reposition remaining notifications
			for i, v in ipairs(self._notifications) do
				v.Position = UDim2.new(0.5, -150, 1, -90 - ((i - 1) * 90))
			end
		end)
	end

	function self:Notify(title, message, duration, ntype)
		self:_createNotification(title, message, duration, ntype)
	end

	-- Save config to workspace or file system
	function self:Save(configName, folderName)
		folderName = folderName or self._configFolder
		configName = tostring(configName or "default")
		local success, result = pcall(function()
			local data = {}
			-- Collect values from tabs' children (textbox, toggle, selector)
			for _, tab in pairs(self._tabs) do
				local tabData = {}
				for _, child in pairs(tab.frame:GetChildren()) do
					if child:IsA("TextBox") then
						tabData[child.Name] = child.Text
					elseif child:IsA("TextButton") and child:GetAttribute("IsToggle") then
						tabData[child.Name] = child:GetAttribute("ToggleState")
					elseif child:GetAttribute and child:GetAttribute("IsSelector") then
						tabData[child.Name] = child:GetAttribute("SelectorValue")
					end
				end
				data[tab.name] = tabData
			end
			local jsonData = HttpService:JSONEncode(data)

			-- Try to save in file system, fallback to workspace
			if writefile and isfolder then
				if not isfolder(folderName) then
					makefolder(folderName)
				end
				writefile(folderName .. "/" .. configName .. ".json", jsonData)
			else
				-- fallback: workspace
				local folder = workspace:FindFirstChild(folderName) or Instance.new("Folder", workspace)
				folder.Name = folderName
				local configFile = folder:FindFirstChild(configName) or Instance.new("StringValue", folder)
				configFile.Name = configName
				configFile.Value = jsonData
			end
			return true
		end)
		if not success then
			self:Notify("Save Error", tostring(result), 4, "error")
		else
			self:Notify("Config Saved", configName, 2, "info")
		end
	end

	-- Load config from workspace or file system
	function self:Load(configName, folderName)
		folderName = folderName or self._configFolder
		configName = tostring(configName or "default")
		local success, result = pcall(function()
			local jsonData = nil
			if readfile and isfolder then
				if isfolder(folderName) and pcall(function()
					jsonData = readfile(folderName .. "/" .. configName .. ".json")
				end) then
					-- loaded from file
				else
					error("Config file not found")
				end
			else
				-- fallback workspace
				local folder = workspace:FindFirstChild(folderName)
				if folder then
					local configFile = folder:FindFirstChild(configName)
					if configFile and configFile:IsA("StringValue") then
						jsonData = configFile.Value
					else
						error("Config file not found in workspace")
					end
				else
					error("Config folder not found in workspace")
				end
			end
			local data = HttpService:JSONDecode(jsonData)
			for tabName, tabData in pairs(data) do
				local tab = self._tabs[tabName]
				if tab then
					for _, child in pairs(tab.frame:GetChildren()) do
						local key = child.Name
						if tabData[key] ~= nil then
							if child:IsA("TextBox") then
								child.Text = tabData[key]
							elseif child:IsA("TextButton") and child:GetAttribute("IsToggle") then
								local val = tabData[key]
								child:SetAttribute("ToggleState", val)
								child.BackgroundColor3 = val and theme.toggle_on or theme.toggle_off
								child.Text = val and "ON" or "OFF"
							elseif child:GetAttribute and child:GetAttribute("IsSelector") then
								local selVal = tabData[key]
								if child:SetAttribute then
									child:SetAttribute("SelectorValue", selVal)
									child.Text = selVal
								end
							end
						end
					end
				end
			end
		end)
		if not success then
			self:Notify("Load Error", tostring(result), 4, "error")
		else
			self:Notify("Config Loaded", configName, 2, "info")
		end
	end

	function self:CreateTab(name)
		-- Sidebar Button
		local tabBtn = new("TextButton", {
			Text = name,
			Size = UDim2.new(1, 0, 0, 40),
			BackgroundColor3 = theme.tab,
			TextColor3 = theme.text,
			Font = Enum.Font.Gotham,
			TextSize = 14,
			Parent = sidebar,
			AutoButtonColor = false,
		})
		new("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 6)})

		-- Content Frame
		local tabFrame = new("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
			ScrollBarThickness = 4,
			Parent = content,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		})

		local layout = new("UIListLayout", {
			Parent = tabFrame,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		})
		new("UIPadding", {
			Parent = tabFrame,
			PaddingLeft = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		})

		-- Tab selection logic
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
		tab.frame = tabFrame
		tab.name = name

		-- Button element
		function tab:CreateButton(text, callback)
			local btn = new("TextButton", {
				Text = text or "Button",
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = theme.button,
				TextColor3 = theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 16,
				Parent = self.frame,
				AutoButtonColor = false,
			})
			new("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 8)})
			btn.MouseButton1Click:Connect(function()
				if callback then
					callback()
				end
			end)
			return btn
		end

		-- TextBox element
		function tab:CreateTextbox(placeholder, callback)
			local box = new("TextBox", {
				Name = HttpService:GenerateGUID(false),
				Text = "",
				PlaceholderText = placeholder or "Enter text...",
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundColor3 = theme.tab_selected,
				TextColor3 = theme.text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				Parent = self.frame,
			})
			new("UICorner", {Parent = box, CornerRadius = UDim.new(0, 8)})

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

		-- Toggle element
		function tab:CreateToggle(text, default, callback)
			local state = default or false

			local holder = new("Frame", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,
				Parent = self.frame,
			})

			local label = new("TextLabel", {
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
				Name = HttpService:GenerateGUID(false),
				Size = UDim2.new(0, 40, 0, 24),
				Position = UDim2.new(1, -45, 0.5, -12),
				BackgroundColor3 = state and theme.toggle_on or theme.toggle_off,
				Text = "",
				Parent = holder,
				AutoButtonColor = false,
			})
			new("UICorner", {Parent = toggleBtn, CornerRadius = UDim.new(0, 12)})

			toggleBtn:SetAttribute("IsToggle", true)
			toggleBtn:SetAttribute("ToggleState", state)

			local function updateVisual()
				toggleBtn.BackgroundColor3 = state and theme.toggle_on or theme.toggle_off
			end

			toggleBtn.MouseButton1Click:Connect(function()
				state = not state
				toggleBtn:SetAttribute("ToggleState", state)
				updateVisual()
				if callback then
					callback(state)
				end
			end)

			function holder:GetValue()
				return state
			end
			function holder:SetValue(v)
				state = v and true or false
				toggleBtn:SetAttribute("ToggleState", state)
				updateVisual()
			end

			updateVisual()
			return holder
		end

		-- Dropdown (single or multi-select)
		function tab:CreateDropdown(labelText, options, multiSelect)
			options = options or {}
			multiSelect = multiSelect or false
			local selected = {}

			local holder = new("Frame", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Parent = self.frame,
			})

			local label = new("TextLabel", {
				Text = labelText or "Dropdown",
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundTransparency = 1,
				TextColor3 = theme.text,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = holder,
			})

			local dropdownBtn = new("TextButton", {
				Size = UDim2.new(0.5, -4, 1, 0),
				Position = UDim2.new(0.5, 4, 0, 0),
				Text = "...",
				BackgroundColor3 = theme.selector,
				TextColor3 = theme.text,
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				Parent = holder,
				AutoButtonColor = false,
			})
			new("UICorner", {Parent = dropdownBtn, CornerRadius = UDim.new(0, 8)})

			local listFrame = new("Frame", {
				Size = UDim2.new(0, 150, 0, 0),
				Position = UDim2.new(0, 0, 1, 4),
				BackgroundColor3 = theme.tab,
				Visible = false,
				ClipsDescendants = true,
				Parent = holder,
			})
			new("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0, 8)})
			local layout = new("UIListLayout", {
				Parent = listFrame,
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			local padding = new("UIPadding", {
				Parent = listFrame,
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
			})

			-- Adjust height based on options count
			local function updateListSize()
				local count = #options
				listFrame.Size = UDim2.new(0, 150, 0, count * 30 + 12)
			end
			updateListSize()

			-- Create option buttons
			for i, option in ipairs(options) do
				local optBtn = new("TextButton", {
					Text = option,
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = theme.tab,
					TextColor3 = theme.text,
					Font = Enum.Font.Gotham,
					TextSize = 14,
					Parent = listFrame,
					AutoButtonColor = false,
				})
				new("UICorner", {Parent = optBtn, CornerRadius = UDim.new(0, 6)})

				optBtn.MouseButton1Click:Connect(function()
					if multiSelect then
						if selected[option] then
							selected[option] = nil
							optBtn.BackgroundColor3 = theme.tab
						else
							selected[option] = true
							optBtn.BackgroundColor3 = theme.toggle_on
						end
						-- Update dropdown button text
						local keys = {}
						for k in pairs(selected) do
							table.insert(keys, k)
						end
						if #keys == 0 then
							dropdownBtn.Text = "..."
						else
							dropdownBtn.Text = table.concat(keys, ", ")
						end
					else
						-- single select
						for _, btn in pairs(listFrame:GetChildren()) do
							if btn:IsA("TextButton") then
								btn.BackgroundColor3 = theme.tab
							end
						end
						selected = {}
						selected[option] = true
						optBtn.BackgroundColor3 = theme.toggle_on
						dropdownBtn.Text = option
						listFrame.Visible = false
					end
				end)
			end

			dropdownBtn.MouseButton1Click:Connect(function()
				listFrame.Visible = not listFrame.Visible
			end)

			-- Hide dropdown if click outside
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if not gameProcessed and listFrame.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
					if not holder:IsAncestorOf(input.Target) then
						listFrame.Visible = false
					end
				end
			end)

			function holder:GetValue()
				local keys = {}
				for k in pairs(selected) do
					table.insert(keys, k)
				end
				if multiSelect then
					return keys
				else
					return keys[1]
				end
			end
			function holder:SetValue(vals)
				if type(vals) == "table" then
					selected = {}
					for _, val in pairs(vals) do
						selected[val] = true
					end
				else
					selected = {}
					if vals then
						selected[vals] = true
					end
				end
				-- Update UI colors and dropdown text
				for _, btn in pairs(listFrame:GetChildren()) do
					if btn:IsA("TextButton") then
						if selected[btn.Text] then
							btn.BackgroundColor3 = theme.toggle_on
						else
							btn.BackgroundColor3 = theme.tab
						end
					end
				end
				local keys = {}
				for k in pairs(selected) do
					table.insert(keys, k)
				end
				if #keys == 0 then
					dropdownBtn.Text = "..."
				else
					dropdownBtn.Text = multiSelect and table.concat(keys, ", ") or keys[1]
				end
			end

			dropdownBtn:SetAttribute("IsSelector", true)
			dropdownBtn:SetAttribute("SelectorValue", "")

			return holder
		end

		self._tabs[name] = tab
		return tab
	end

	function DeltaBXC2:Destroy()
		if self._gui then
			self._gui:Destroy()
			self._gui = nil
		end
		if self._notifGui then
			self._notifGui:Destroy()
			self._notifGui = nil
		end
	end

	return self
end

return DeltaBXC2
