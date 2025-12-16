require "RemoveIndoor_Logic"

local function extractCoords(args)
    return tonumber(args.minX), tonumber(args.minY), tonumber(args.maxX), tonumber(args.maxY), tonumber(args.z)
end

local function isAdmin(playerObj)
    if not (RI_MOD.IsSinglePlayer() or RI_MOD.IsServerAdmin(playerObj)) then
        RI_MOD.Log("Unauthorized attempt to use ClearIndoorArea command.")
        return false
    end
    return true
end

local function sendIndoorRemovedData()
    RI_MOD.Log("Sent IndoorRemovedDataUpdate")
    if RI_MOD.IsSinglePlayer() then
        RI_MOD.OnServerCommand("RemoveIndoor", "IndoorRemovedDataUpdate", RI_MOD.SaveData.removed)
    else
        sendServerCommand("RemoveIndoor", "IndoorRemovedDataUpdate", RI_MOD.SaveData.removed)
    end
end

function RI_MOD.OnClientCommand(module, command, playerObj, args)
    if module ~= "RemoveIndoor" then return end

    if command == "AddIndoorAreaRemoval" and isAdmin(playerObj) then
        minX, minY, maxX, maxY, z = extractCoords(args)
        RI_MOD.AddIndoorAreaRemoval(minX, minY, maxX, maxY, z)
        sendIndoorRemovedData()
    elseif command == "DeleteIndoorAreaRemoval" and isAdmin(playerObj) then
        minX, minY, maxX, maxY, z = extractCoords(args)
        RI_MOD.DeleteIndoorAreaRemoval(minX, minY, maxX, maxY, z)
    elseif command == "IndoorRemovedDataUpdate" then
        sendIndoorRemovedData()
    end
end

function RI_MOD.OnServerLoad()
    RI_MOD.LoadSaveData()
end

Events.OnClientCommand.Add(RI_MOD.OnClientCommand)
Events.OnServerStarted.Add(RI_MOD.OnServerLoad) -- multi player
Events.OnLoad.Add(RI_MOD.OnServerLoad) -- single player
