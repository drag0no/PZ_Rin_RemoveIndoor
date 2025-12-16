require "RemoveIndoor_Logic"
require "RemoveIndoor_UI"

function RI_MOD.OnServerCommand(module, command, args)
    if module ~= "RemoveIndoor" then return end

    if command == "IndoorRemovedDataUpdate" then
        RI_MOD.Log("Client received IndoorRemovedDataUpdate")
        RI_MOD.WorkData.removed = args
        RI_MOD.ClientProcessAllRemovedIndoorData(RI_MOD.WorkData.removed)
    end
end

function RI_MOD.OnGridSquareLoad(sq)
    local x, y, z = sq:getX(), sq:getY(), sq:getZ()
    local coordKey = RI_MOD.GetCoordKey(x ,y, z)
    if not RI_MOD.WorkData.removed[coordKey] then
        return
    end

    RI_MOD.ClientProcessGridSquareLoad(x, y, z)
end

function RI_MOD.OnClientLoad()
    RI_MOD.Log("Client requested IndoorRemovedDataUpdate")
    sendClientCommand(getPlayer(), "RemoveIndoor", "IndoorRemovedDataUpdate", nil)
    Events.OnTick.Remove(RI_MOD.OnClientLoad)
end

RI_MOD.InitWorkData()

Events.OnServerCommand.Add(RI_MOD.OnServerCommand)
Events.LoadGridsquare.Add(RI_MOD.OnGridSquareLoad)
Events.OnTick.Add(RI_MOD.OnClientLoad)