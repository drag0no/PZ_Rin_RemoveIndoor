RI_MOD = RI_MOD or {}

RI_DATAKEY = "RI_MOD"

function RI_MOD.Log(msg)
    print("Rin_RemoveIndoor: " .. tostring(msg))
end

function RI_MOD.IsSinglePlayer()
    return not isClient() and not isServer()
end

function RI_MOD.IsServerAdmin(player)
    if not player then return false end
    local access = player:getAccessLevel():lower()
    return access == "admin"
end

function RI_MOD.InitWorkData()
    RI_MOD.Log("Init WorkData")
    RI_MOD.WorkData = { coords = {}, removed = {} }
end

function RI_MOD.LoadSaveData()
    if isClient() then
        -- prevent client in multiplayer load local data
        return
    end

    RI_MOD.Log("ModData Load")
    RI_MOD.SaveData = ModData.getOrCreate(RI_DATAKEY)
    if RI_MOD.SaveData.removed then
        for key, _ in pairs(RI_MOD.SaveData.removed) do
            RI_MOD.Log(key .. ": IndoorRemovedData loaded")
        end
    else
        RI_MOD.SaveData.removed = {}
        RI_MOD.Log("No SavedData. Initilized a new one.")
        return
    end
end
