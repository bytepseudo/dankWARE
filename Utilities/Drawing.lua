local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local Camera = Workspace.CurrentCamera

local Drawings = {
    Objects = {}
}

Drawings.AddDrawing = function(Type, Properties)
    local DrawingObject = Drawing.new(Type)

    for Property, Value in pairs(Properties) do
        DrawingObject[Property] = Value
    end

    return DrawingObject
end

return Drawings
