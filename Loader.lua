getgenv().dankWARE = {
    Source = 'https://raw.githubusercontent.com/bytepseudo/dankWARE/main/',
    Utilities = {},

    Games = {
        ['3039388345'] = {Name = 'Shinjuku, 2006', Path = 'Games/Shinjuku6.lua'},
        ['4483381582'] = {Name = 'Shinjuku, 1988', Path = 'Games/Shinjuku8.lua'},
        ['9896617899'] = {Name = 'Miami 1986', Path = 'Games/Crimewave.lua'},
        ['4483381587'] = {Name = 'Baseplate', Path = 'Games/Baseplate.lua'}
    }
}

function GetFile(File)
    return game:HttpGet(`{dankWARE.Source}{File}`)
end

function LoadScript(Script)
    return loadstring(GetFile(Script))()
end

function GetGameData()
    for Id, Data in pairs(dankWARE.Games) do
        if tostring(game.PlaceId) == Id then
            return Data
        end
    end

    return false
end

dankWARE.Game = GetGameData()

dankWARE.Utilities.Drawing = LoadScript('Utilities/Drawing.lua')
dankWARE.Utilities.Interface = LoadScript('Utilities/UI.lua')

if dankWARE.Game then
    dankWARE.StartTime = tick()
    LoadScript(dankWARE.Game.Path)
else
    dankWARE.Utilities.Interface:Toast({Title = 'Unsupported Game', Duration = 2, Color = Color3.new(0.808, 0.161, 0.173, 0)})
end
