local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local Camera = Workspace.CurrentCamera

local Drawings = {
    Objects = {}
}

function Drawings:AddDrawing(Type, Properties)
    local DrawingObject = Drawing.new(Type)

    for Property, Value in pairs(Properties) do
        DrawingObject[Property] = Value
    end

    return DrawingObject
end

function Drawings:AddObject(Instance, Options)
    if self.Objects[Instance] then return end

    local Object = self.Objects[Instance] = {}

    Object.Connection = nil

    local Text = self:AddDrawing('Text', {
        Text = Options.Text,
        Visible = Options.Visible,
        Center = Options.Center,
        Outline = Options.Outline,
        Color = Options.Color,
        OutlineColor = Options.OutlineColor
    })

    print('balls')

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