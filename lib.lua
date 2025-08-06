-- Load the external UI library
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomAHHProjects/I-ve-Had-This-One-Stored/refs/heads/main/lib.lua"))()
if not UILib then
    error("Failed to load UI library")
end

-- Create window
local Window = UILib:MakeWindow({
    Name = "Speed Presets",
    -- you can pass other settings if the lib supports it
})

-- Tab for WalkSpeed
local Tab = Window:CreateTab("WalkSpeed")

-- Preset toggle group
local presets = {
    {Name = "Slow (20)", Speed = 20},
    {Name = "Default (16)", Speed = 16},
    {Name = "Fast (100)", Speed = 100},
    {Name = "Turbo (200)", Speed = 200},
}

for _, preset in ipairs(presets) do
    Tab:CreateToggle({
        Name = preset.Name,
        Callback = function(state)
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                if state then
                    hum.WalkSpeed = preset.Speed
                else
                    -- revert to default if untoggled
                    hum.WalkSpeed = 16
                end
            end
        end
    })
end

-- Manual input for custom speed
Tab:CreateButton({
    Name = "Custom Speed",
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
