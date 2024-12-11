local RunService = game:GetService('RunService')

local PositionText = dankWARE.Utilities.Drawing:AddDrawing('Text', {
    Visible = true,
    Position = Vector2.new(960, 960),
    Center = true,
    Outline = true,
    Color = Color3.new(1, 1, 1),
    OutlineColor = Color3.new(0, 0, 0),
    Text = 'Position: 0, 0, 0'
})

RunService.RenderStepped:Connect(function()
    PositionText.Text = `Position: {tostring(game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position)}`
end)
