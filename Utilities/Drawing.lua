local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local Camera = Workspace.CurrentCamera

local Drawings = {
    Objects = {}
}

function AddDrawing(Type, Properties)
    local DrawingObject = Drawing.new(Type)

    for Property, Value in pairs(Properties) do
        DrawingObject[Property] = Value
    end

    return DrawingObject
end

function Drawings.AddObject(Instance, Options)
    if Drawings.Objects[Instance] then return end

    local Object = Drawings.Objects[Instance] = {}

    Object.Connection = nil

    local Text = AddDrawing('Text', {
        Text = Options.Text
        Center = Options.Center,
        Outline = Options.Outline,
        Color = Options.Color,
        OutlineColor = Options.OutlineColor
    })

    Object.Connection = RunService.RenderStepped:Connect(function()
        if not Instance then
            Object.Connection:Disconnect()
            Object = nil
        end

        local ScreenPosition, OnScreen = Camera:WorldToScreenPoint(Instance.Position)

        if OnScreen then
            Text.Visible = true
            Text.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
        else
            Text.Visible = false
        end
    end)
end

return Drawings
