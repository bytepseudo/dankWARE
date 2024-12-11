local CombatText = dankWARE.Utilities.Drawing:AddDrawing('Text', {
    Visible = true,
    Position = Vector2.new(960, 960),
    Center = true,
    Outline = true,
    Color = Color3.new(1, 1, 1),
    OutlineColor = Color3.new(0, 0, 0),
    Text = 'Enabled: false, Target: None'
})

task.wait(5)
