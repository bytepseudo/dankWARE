loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua'))()

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')

local LocalPlayer = Players.LocalPlayer

local Camera = Workspace.Camera

local Mouse = LocalPlayer:GetMouse()

local Limbs = {'Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Arm', 'Right Arm'}
local HitSounds = {Neverlose = 6607204501, Skeet = 4817809188, Rust = 1255040462}

local TargetPlayer, TargetLimb = nil, nil

local HitSound = Instance.new('Sound', Camera)
HitSound.Volume = 3.3

local Fov = {
    Circle = dankWARE.Utilities.Drawing:AddDrawing('Circle', {
        ZIndex = 4
    }),
    OutlineCircle = dankWARE.Utilities.Drawing:AddDrawing('Circle', {
        ZIndex = 3
    })
}

local CombatText = dankWARE.Utilities.Drawing:AddDrawing('Text', {
    Visible = true,
    Size = 20
    Position = Vector2.new(960, 960),
    Center = true,
    Outline = true,
    Color = Color3.new(1, 1, 1),
    OutlineColor = Color3.new(0, 0, 0),
    Text = 'Enabled: false, Target: None'
})

local Window = dankWARE.Utilities.Interface:Window({Name = 'dankWARE', Enabled = true, Color = Color3.new(0.0902, 0.65098, 0.92941, 0), Size = UDim2.new(0,496,0,496), Position = UDim2.new(0.5,-248,0.5,-248)}) do
    local CombatTab = Window:Tab({Name = 'Combat'}) do
        local AimbotSection = CombatTab:Section({Name = 'Aimbot',Side = 'Left'}) do
            local Toggle = AimbotSection:Toggle({Name = 'Enabled', Flag = 'Combat/Aimbot/Enabled', HoldMode = true, Value = false, Callback = function(Toggle_Bool) end})

            local ToggleKeybind = Toggle:Keybind({Flag = 'Toggle/Keybind', Value = 'NONE', DoNotClear = false, Mouse = true, Callback = function(Key_String,Pressed_Bool,Toggle_Bool) end,
            Blacklist = {'W','A','S','D','Slash','Tab','Backspace','Escape','Space','Delete','Unknown','Backquote'}})

            AimbotSection:Dropdown({Name = 'Method', Flag = 'Combat/Aimbot/Method', List = {
                {Name = 'Angles', Mode = 'Toggle', Value = true}, {Name = 'Redirect', Mode = 'Toggle'}
            }})

            AimbotSection:Divider()

            AimbotSection:Slider({Name = 'Chance', Flag = 'Combat/Aimbot/Chance', Min = 0.1, Max = 100, Precise = 1, Unit = '', Value = 100})
            AimbotSection:Slider({Name = 'Sensitivity', Flag = 'Combat/Aimbot/Sensitivity', Min = 0, Max = 100, Precise = 1, Unit = '', Value = 20})
        end

        local FovSection = CombatTab:Section({Name = 'Fov', Side = 'Right'}) do
            FovSection:Toggle({Name = 'Visible', Flag = 'Combat/Fov/Visible', Value = false})
            FovSection:Toggle({Name = 'Filled', Flag = 'Combat/Fov/Filled', Value = false})

            FovSection:Slider({Name = 'Size', Flag = 'Combat/Fov/Size', Min = 5, Max = 600, Value = 60, Precise = 1, Unit = ''})
            FovSection:Slider({Name = 'Sides', Flag = 'Combat/Fov/Sides', Min = 1, Max = 60, Value = 60, Precise = 1, Unit = ''})
            FovSection:Slider({Name = 'Thickness', Flag = 'Combat/Fov/Thickness', Min = 1, Max = 5,Value = 1, Precise = 1, Unit = ''})
            FovSection:Slider({Name = 'Transparency', Flag = 'Combat/Fov/Transparency', Min = 0, Max = 1, Value = 1, Precise = 1, Unit = ''})

            FovSection:Colorpicker({Name = 'Color', Flag = 'Combat/Fov/Color', Value = {0, 0, 1, 0, false}})
        end

        local FilterSection = CombatTab:Section({Name = 'Filter', Side = 'Right'}) do
            FilterSection:Toggle({Name = 'Visible', Flag = 'Combat/Filter/Visible', Value = false})
            FilterSection:Toggle({Name = 'Friendly', Flag = 'Combat/Filter/Friendly', Value = false})
            FilterSection:Toggle({Name = 'Team', Flag = 'Combat/Filter/Team', Value = false})
        
            FilterSection:Slider({Name = 'Distance', Flag = 'Combat/Filter/Distance', Min = 1, Max = 1000, Value = 250, Precise = 1, Unit = ''})

            local DropdownLimbs = {}

            for _, Limb in pairs(Limbs) do
                if Limb == 'Head' then
                    table.insert(DropdownLimbs, {Name = Limb, Mode = 'Button', Value = true})
                else
                    table.insert(DropdownLimbs, {Name = Limb, Mode = 'Button', Value = false})
                end
            end

            FilterSection:Dropdown({Name = 'Aimpart', Flag = 'Combat/Filter/Aimpart', List = DropdownLimbs})
            FilterSection:Dropdown({Name = 'Friends', Flag = 'Combat/Filter/Friends', List = DropdownPlayers}):RefreshToPlayers(true)
        end
    end

    local MiscellaneousTab = Window:Tab({Name = 'Miscellaneous'}) do
        local CharacterSection = MiscellaneousTab:Section({Name = 'Character',Side = 'Left'}) do
            CharacterSection:Toggle({Name = 'Jump Cooldown', Flag = 'Miscellaneous/Character/JumpCooldown', Value = false, Callback = function(Value)
                local Connections = getconnections(LocalPlayer.Character.Humanoid.Changed)

                if Value then
                    Connections[1]:Disable()
                else
                    Connections[1]:Enable()
                end
            end})
        end

        local HitSection = MiscellaneousTab:Section({Name = 'Hit', Side = 'Right'}) do
            HitSection:Toggle({Name = 'Logs', Flag = 'Miscellaneous/Hit/Logs', Value = false})
            HitSection:Toggle({Name = 'Sounds', Flag = 'Miscellaneous/Hit/Sounds', Value = false})
            HitSection:Slider({Name = 'Window', Flag = 'Miscellaneous/Hit/Window', Min = 0, Max = 1, Precise = 1, Unit = '', Value = 0.2})
            HitSection:Dropdown({Name = 'Sound', Flag = 'Miscellaneous/Hit/Sound', List = DropdownLimbs})
        end
    end

    local OptionsTab = Window:Tab({Name = 'Settings'}) do
        local MenuSection = OptionsTab:Section({Name = 'Menu',Side = 'Left'}) do
            local UIToggle = MenuSection:Toggle({Name = 'UI Enabled', Flag = 'UI/Enabled', HoldMode = false, IgnoreFlag = true, Value = Window.Enabled, Callback = function(Bool) Window.Enabled = Bool end})
            UIToggle:Keybind({Value = 'RightControl', Flag = 'UI/Keybind', DoNotClear = true})
        end
    end
end

Window.Background.Image = ''
Window.Flags['Background/CustomImage'] = ''

RunService.RenderStepped:Connect(function()
    local MouseLocation = UserInputService:GetMouseLocation()

    Fov.Circle.Visible = Window.Flags['Combat/Fov/Visible']
    Fov.OutlineCircle.Visible = Window.Flags['Combat/Fov/Visible']

    Fov.Circle.Radius = Window.Flags['Combat/Fov/Size']
    Fov.OutlineCircle.Radius = Window.Flags['Combat/Fov/Visible']

    Fov.Circle.Color = Window.Flags['Combat/Fov/Color'][6]

    Fov.Circle.Filled = Window.Flags['Combat/Fov/Filled']

    Fov.Circle.Transparency = Window.Flags['Combat/Fov/Transparency']
    Fov.OutlineCircle.Transparency = Window.Flags['Combat/Fov/Transparency']

    Fov.Circle.NumSides = Window.Flags['Combat/Fov/Sides']
    Fov.OutlineCircle.NumSides = Window.Flags['Combat/Fov/Sides']

    Fov.Circle.Thickness = Window.Flags['Combat/Fov/Thickness'] + 2
    Fov.OutlineCircle.NumSides = Window.Flags['Combat/Fov/Sides']

    Fov.Circle.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)
    Fov.OutlineCircle.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)

    CombatText.Text = `Enabled: {Window.Flags['Combat/Aimbot/Enabled']}, Target: {TargetPlayer or None}`
end)

local EndTime = math.floor((tick() - dankWARE.StartTime) * 10) / 10
dankWARE.Utilities.Interface:Toast({Title = `Loaded in {EndTime} seconds`, Duration = 1.5, Color = Color3.new(0.0902, 0.65098, 0.92941, 0)})
