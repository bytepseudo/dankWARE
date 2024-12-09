local Dankware = getgenv().Dankware

Dankware = {
    Source = 'raw.githubusercontent.com/bytepseudo/dankWARE/main',

    Games = {
        ['3039388345'] = {Name = 'Shinjuku, 2006', Path = 'Games/Shinjuku6'},
        ['4483381582'] = {Name = 'Shinjuku, 1988', Path = 'Games/Shinjuku8'},
        ['4483381587'] = {Name = 'Baseplate', Path = 'Games/Baseplate'}
    }
}

function GetFile(File)
    return game:HttpGet(`{Dankware.Source}{File}`)
end

function LoadScript(Script)
    return loadstring(GetFile(Script), Script)()
end

function GetGameData()
    for Id, Data in pairs(Dankware.Games) do
        if tostring(game.PlaceId) == Id then
            return Data
        end
    end

    return 'Unsupported Game'
end

Dankware.Game = GetGameData()

print(Dankware.Game.Name)
