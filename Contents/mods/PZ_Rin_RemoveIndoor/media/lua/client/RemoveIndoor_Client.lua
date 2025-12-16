require "RemoveIndoor_Logic"
require "RemoveIndoor_UI"

function RI_MOD.OnServerCommand(module, command, args)
    if module ~= "RemoveIndoor" then return end

    if command == "IndoorRemovedDataUpdate" then
        RI_MOD.ClientProcessRemovedIndoorData(args)
    end
end

function RI_MOD.OnClientLoad()
    RI_MOD.InitWorkData()
    RI_MOD.Log("Client requested IndoorRemovedDataUpdate")
    sendClientCommand(getPlayer(), "RemoveIndoor", "IndoorRemovedDataUpdate", nil)
    Events.OnTick.Remove(RI_MOD.OnClientLoad)
end

Events.OnFillWorldObjectContextMenu.Add(RI_MOD.OnFillWorldObjectContextMenu)
Events.OnServerCommand.Add(RI_MOD.OnServerCommand)
Events.OnTick.Add(RI_MOD.OnClientLoad)