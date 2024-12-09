local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')

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
    if not Instance then return end
    if not Options then return end

    if self.Objects[Instance] then return end

    local Object = {}
    self.Objects[Instance] = Object

    local Text = self:AddDrawing('Text', Options)
    
    Object.Text = Text
    Object.Enabled = Options.Visible

    Object.Connection = RunService.RenderStepped:Connect(function()
        if not Instance.Parent then
            Text:Remove()
            Object.Connection:Disconnect()
            self.Objects[Instance] = nil
            return
        end

        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Instance.Position)

        if Object.Enabled then
            Text.Visible = true
            Text.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
        else
            Text.Visible = false
        end
    end)

    return Text
end

function Drawings:RemoveObject(Instance)
    if not self.Objects[Instance] then return end

    local Object = self.Objects[Instance]
    Object.Text:Remove()
    Object.Connection:Disconnect()
    self.Objects[Instance] = nil
end

function Drawings:ClearAllObjects()
    for Instance, Object in pairs(self.Objects) do
        Object.Text:Remove()
        Object.Connection:Disconnect()
        self.Objects[Instance] = nil
    end
end

return Drawings
