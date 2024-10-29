print('called')

local Dankware = getgenv().Dankware or {}

Dankware.Source = 'https://raw.githubusercontent.com/bytepseudo/Dankware/main/'

Dankware.Games = {
    ['3039388345'] = {Name = 'Shinjuku, 2006', Path = 'Games/Shinjuku6'},
    ['4483381582'] = {Name = 'Shinjuku, 1988', Path = 'Games/Shinjuku8'},
    ['4483381587'] = {Name = 'Baseplate', Path = 'Games/Baseplate'}
}

function GetFile(File)
    local url = Dankware.Source .. File .. '.lua'  -- Add ".lua" if not in the paths
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        print("Successfully fetched:", url)
        return result
    else
        warn("Failed to fetch file:", url)
        return nil
    end
end

function LoadScript(Script)
    local scriptContent = GetFile(Script)
    if scriptContent then
        return loadstring(scriptContent, Script)()
    else
        warn("Failed to load script:", Script)
    end
end

function GetGameData()
    for Id, Data in pairs(Dankware.Games) do
        if tostring(game.PlaceId) == Id then
            return Data
        end
    end

    return { Name = 'Unsupported Game', Path = nil }
end

-- Loading UI and Game Data
Dankware.Utilities = Dankware.Utilities or {}
Dankware.Utilities.UI = LoadScript('Utilities/UI')
Dankware.Game = GetGameData()

print("Game Name:", Dankware.Game.Name)
