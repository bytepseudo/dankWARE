local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')

local Camera = Workspace.CurrentCamera

local Drawings = {
    Objects = {} -- Table to store created objects
}

-- Helper function to create a Drawing object
function Drawings:AddDrawing(Type, Properties)
    local DrawingObject = Drawing.new(Type)

    for Property, Value in pairs(Properties) do
        DrawingObject[Property] = Value
    end

    return DrawingObject
end

-- Function to add an object to track and display text
function Drawings:AddObject(Instance, Options)
    -- Debug: Check for nil values
    if not Instance then
        warn("[Drawings:AddObject] Instance is nil!")
        return
    end
    if not Options then
        warn("[Drawings:AddObject] Options are nil!")
        return
    end

    -- Prevent duplicate objects for the same Instance
    if self.Objects[Instance] then
        warn("[Drawings:AddObject] Object already exists for this Instance!")
        return
    end

    print("[Drawings:AddObject] Creating new object for instance:", Instance.Name)

    -- Create an object to store the Drawing and connection
    local Object = {}
    self.Objects[Instance] = Object

    -- Create the Text Drawing
    local Text = self:AddDrawing('Text', {
        Text = Options.Text or "Default Text",
        Visible = Options.Visible or false,
        Center = Options.Center or true,
        Outline = Options.Outline or true,
        Color = Options.Color or Color3.new(1, 1, 1),
        OutlineColor = Options.OutlineColor or Color3.new(0, 0, 0),
        Size = Options.Size or 18,
        Transparency = Options.Transparency or 1
    })
    Object.Text = Text

    -- RenderStepped connection to update the Drawing position
    Object.Connection = RunService.RenderStepped:Connect(function()
        if not Instance.Parent then
            -- If the Instance is removed, clean up
            print("[Drawings:AddObject] Instance removed, cleaning up:", Instance.Name)
            Text:Remove()
            Object.Connection:Disconnect()
            self.Objects[Instance] = nil
            return
        end

        -- Update the position of the text
        local ScreenPosition, OnScreen = Camera:WorldToScreenPoint(Instance.Position)
        if OnScreen then
            Text.Visible = true
            Text.Position = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
        else
            Text.Visible = false
        end
    end)

    print("[Drawings:AddObject] Object created successfully for instance:", Instance.Name)
end

-- Function to remove a specific object
function Drawings:RemoveObject(Instance)
    if not self.Objects[Instance] then
        warn("[Drawings:RemoveObject] No object exists for this Instance!")
        return
    end

    print("[Drawings:RemoveObject] Removing object for instance:", Instance.Name)

    local Object = self.Objects[Instance]
    Object.Text:Remove() -- Remove the Drawing
    Object.Connection:Disconnect() -- Disconnect the RenderStepped connection
    self.Objects[Instance] = nil
end

-- Function to clear all tracked objects
function Drawings:ClearAllObjects()
    print("[Drawings:ClearAllObjects] Clearing all objects...")
    for Instance, Object in pairs(self.Objects) do
        Object.Text:Remove()
        Object.Connection:Disconnect()
        self.Objects[Instance] = nil
    end
end

return Drawings
