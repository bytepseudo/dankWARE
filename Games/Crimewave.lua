loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/adoniscries/refs/heads/main/Source.lua'))()

print('were back baby!')

local Players = game:GetService('Players')
local Teams = game:GetService('Teams')
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

local FovCircle = dankWARE.Utilities.Drawing:AddDrawing('Circle', {ZIndex = 4})
local FovOutlineCircle = dankWARE.Utilities.Drawing:AddDrawing('Circle', {Color = Color3.new(0, 0, 0), ZIndex = 3})

local CombatText = dankWARE.Utilities.Drawing:AddDrawing('Text', {
    Visible = true,
    Size = 16,
    Position = Vector2.new(960, 960),
    Center = true,
    Outline = true,
    Color = Color3.new(1, 1, 1),
    OutlineColor = Color3.new(0, 0, 0),
    Text = 'Enabled: false, Target: None'
})

local RaycastParams = RaycastParams.new()
RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Workspace.Folder.SafeZones}
RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist

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
            FovSection:Slider({Name = 'Thickness', Flag = 'Combat/Fov/Thickness', Min = 1, Max = 5, Value = 1.5, Precise = 1, Unit = ''})
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

            local TeamsDropdownList = {}

            for _, Team in pairs(Teams:GetChildren()) do
                table.insert(TeamsDropdownList, {Name = Team.Name, Mode = 'Toggle', Value = false})
            end

            FilterSection:Button({Name = 'Refresh Teams', Callback = function()
                TeamsDropdownList = {}

                for _, Team in pairs(Teams:GetChildren()) do
                    table.insert(TeamsDropdownList, {Name = Team.Name, Mode = 'Toggle', Value = false})
                end

                TeamsDropdown:Clear()
                TeamsDropdown:BulkAdd(TeamsDropdownList)
            end})

            local TeamsDropdown = FilterSection:Dropdown({Name = 'Teams', Flag = 'Combat/Filter/Teams', List = TeamsDropdownList})
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

function AliveCheck(Player)
    if Player and Player.Character then
        local Humanoid = Player.Character:FindFirstChild('Humanoid')

        if Humanoid and Humanoid.Health > 0 then
            return true
        end
    end

    return false
end

function IsVisible(Position)
	local Vector, OnScreen = Camera:WorldToScreenPoint(Position)

	if OnScreen then
		local Origin = Camera.CFrame.Position
		local Direction = (Position - Origin).Unit * (Position - Origin).Magnitude

		return Workspace:Raycast(Origin, Direction, RaycastParams)
	end

	return false
end

function GetClosestFromMouse()
    local ClosestPlayer = nil
    local ClosestDistance = math.huge

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and AliveCheck(Player) then
            local Limb = Player.Character:FindFirstChild(Window.Flags['Combat/Filter/Aimpart'][1])

            if Limb then
                local Vector, OnScreen = Camera:WorldToScreenPoint(Limb.Position)

                if OnScreen then
                    local MouseLocation = UserInputService:GetMouseLocation()
                    local Distance = (Vector2.new(MouseLocation.X, MouseLocation.Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude

                    if Distance <= Window.Flags['Combat/Fov/Size'] then
                        if Distance < ClosestDistance then
                            ClosestDistance = Distance
                            ClosestPlayer = Player
                        end
                    end
                end
            end
        end
    end

    return ClosestPlayer, ClosestDistance
end

function AimAt(Aimpart, Sensitivity)
    if not Aimpart then return end
    local MouseLocation = UserInputService:GetMouseLocation()

    mousemoverel(
        (Aimpart.X - MouseLocation.X) * Sensitivity,
        (Aimpart.Y - MouseLocation.Y) * Sensitivity
    )
end

function FilterCheck(Player)
    local VisibleCheck = Window.Flags['Combat/Filter/Visible']
    local FriendCheck = Window.Flags['Combat/Filter/Friendly']
    local TeamCheck = Window.Flags['Combat/Filter/Team']

    local Aimpart = Player.Character:FindFirstChild(Window.Flags['Combat/Filter/Aimpart'][1])

    if not Aimpart then return false end

    if VisibleCheck then
        local Visible = IsVisible(Aimpart.Position)

        if not (Visible and Visible.Instance:IsDescendantOf(Player.Character)) then
            return false
        end
    end

    if FriendCheck then
        if table.find(Window.Flags['Combat/Filter/Friends'], Player.Name) then
            return false
        end
    end

    if TeamCheck then
        if Player.Team == LocalPlayer.Team then
            return false
        end

        if table.find(Window.Flags['Combat/Filter/Teams'], Player.Team) then
            print('target is on friendly team!')
            return false
        end
    end

    return IsValid
end

RunService.RenderStepped:Connect(function()
    local MouseLocation = UserInputService:GetMouseLocation()

    FovCircle.Visible = Window.Flags['Combat/Fov/Visible']
    FovOutlineCircle.Visible = Window.Flags['Combat/Fov/Visible']

    FovCircle.Radius = Window.Flags['Combat/Fov/Size']
    FovOutlineCircle.Radius = Window.Flags['Combat/Fov/Size']

    FovCircle.Color = Window.Flags['Combat/Fov/Color'][6]

    FovCircle.Filled = Window.Flags['Combat/Fov/Filled']

    FovCircle.Transparency = Window.Flags['Combat/Fov/Transparency']
    FovOutlineCircle.Transparency = Window.Flags['Combat/Fov/Transparency']

    FovCircle.NumSides = Window.Flags['Combat/Fov/Sides']
    FovOutlineCircle.NumSides = Window.Flags['Combat/Fov/Sides']

    FovCircle.Thickness = Window.Flags['Combat/Fov/Thickness']
    FovOutlineCircle.Thickness = Window.Flags['Combat/Fov/Thickness'] + 2

    FovCircle.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)
    FovOutlineCircle.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)

    CombatText.Text = `Enabled: {Window.Flags['Combat/Aimbot/Enabled']}, Target: {TargetPlayer or None}`
end)

RunService.RenderStepped:Connect(function()
    if Window.Flags['Combat/Aimbot/Enabled'] then
        local Player, Distance = GetClosestFromMouse()
        
        if Player then
            if FilterCheck(Player) then
                TargetPlayer = Player
                TargetLimb = Player.Character[Window.Flags['Combat/Filter/Aimpart'][1]]
            else
                TargetPlayer = nil
                TargetLimb = nil
            end
        else 
            TargetPlayer = nil 
            TargetLimb = nil
        end

        if Window.Flags['Combat/Aimbot/Enabled'] then
            local Aimpart = TargetPlayer and TargetLimb

            if Aimpart then
                if table.find(Window.Flags['Combat/Aimbot/Method'], 'Angles') then
                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Aimpart.Position)
                    AimAt(ScreenPosition, Window.Flags['Combat/Aimbot/Sensitivity'] / 100)
                end
            end
        end
    else
        TargetPlayer = nil
        TargetLimb = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if Window.Flags['Miscellaneous/Character/JumpCooldown'] then
        local Connections = getconnections(LocalPlayer.Character.Humanoid.Changed)
        Connections[1]:Disable()
    end
end)

local OldIndex; OldIndex = hookmetamethod(game, '__index', function(Self, Index)
    if checkcaller() then return OldIndex(Self, Index) end

    if Self == Mouse then
        if Window.Flags['Combat/Aimbot/Enabled'] and table.find(Window.Flags['Combat/Aimbot/Method'], 'Redirect') and math.random(100) <= Window.Flags['Combat/Aimbot/Chance'] then
            if TargetPlayer and TargetPlayer.Character then

                if TargetLimb then
                    if string.find(Index:lower(), 'target') then
                        return TargetLimb
                    elseif string.find(Index:lower(), 'hit') then
                        return TargetLimb.CFrame
                    end
                end
            end
        end
    end

    return OldIndex(Self, Index)
end)

local EndTime = math.floor((tick() - dankWARE.StartTime) * 10) / 10
dankWARE.Utilities.Interface:Toast({Title = `Loaded in {EndTime} seconds`, Duration = 1.5, Color = Color3.new(0.0902, 0.65098, 0.92941, 0)})
