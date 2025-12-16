require "RemoveIndoor_Data"

function RI_MOD.GetCoordKey(x, y, z)
    return x .. "," .. y .. "," .. z
end

local function getSquare(x, y, z)
    local cell = getCell()
    if not cell then return nil end
    return cell:getGridSquare(x, y, z)
end

local function addIndoorSquareRemoval(x, y, z)
    local coordKey = RI_MOD.GetCoordKey(x, y, z)
    local sq = getSquare(x, y, z)
    if not sq then
        RI_MOD.Log(coordKey .. ": unloaded Chunk/Square")
        return
    end

    local room = sq:getRoom()
    if not room then
        RI_MOD.Log(coordKey .. ": no Room")
        return
    end

    RI_MOD.SaveData.removed[coordKey] = { x = x, y = y, z = z }
    RI_MOD.Log(coordKey .. ": RemoveIndoor added")
end

local function deleteIndoorSquareRemoval(x, y, z)
    local coordKey = RI_MOD.GetCoordKey(x, y, z)
    if not RI_MOD.SaveData.removed[coordKey] then
        RI_MOD.Log(coordKey .. ": Nothing to delete")
        return
    end

    RI_MOD.SaveData.removed[coordKey] = nil
    RI_MOD.Log(coordKey .. ": RemoveIndoor deleted")
end

local function execIndoorSquareRemoval(x, y, z)
    local coordKey = RI_MOD.GetCoordKey(x, y, z)
    local sq = getSquare(x, y, z)
    if not sq then
        RI_MOD.Log(coordKey .. ": unloaded Chunk/Square")
        return
    end

    local isOutside = sq:isOutside()
    local room = sq:getRoom()
    if room then
        sq:setRoom(nil)
        sq:setRoomID(-1)
        sq:RecalcAllWithNeighbours(false)
        RI_MOD.Log(("%s: setRoom(nil) & setRoomID(-1) / Outside: %s -> %s"):format(coordKey, tostring(isOutside), tostring(sq:isOutside())))
    else
        RI_MOD.Log(coordKey .. ": no Room")
    end
end

local function processIndoorAreaRemoval(minX, minY, maxX, maxY, z, callback, callerName)
    if not (minX and minY and maxX and maxY and z) then
        RI_MOD.Log(("Missing parameters! Usage: %s(minX, minY, maxX, maxY, z)"):format(callerName))
        return false
    end

    if minX > maxX then minX, maxX = maxX, minX end
    if minY > maxY then minY, maxY = maxY, minY end

    RI_MOD.Log(("Starting %s. Rectangle [%d,%d] to [%d,%d] at [z=%d]"):format(callerName, minX, minY, maxX, maxY, z))
    for x = minX, maxX do
        for y = minY, maxY do
            callback(x, y, z)
        end
    end
    return true
end

function RI_MOD.AddIndoorAreaRemoval(minX, minY, maxX, maxY, z)
    return processIndoorAreaRemoval(minX, minY, maxX, maxY, z, addIndoorSquareRemoval, "AddIndoorAreaRemoval")
end

function RI_MOD.DeleteIndoorAreaRemoval(minX, minY, maxX, maxY, z)
    return processIndoorAreaRemoval(minX, minY, maxX, maxY, z, deleteIndoorSquareRemoval, "DeleteIndoorAreaRemoval")
end

function RI_MOD.ClientProcessGridSquareLoad(x, y, z)
    execIndoorSquareRemoval(x, y, z)
end

function RI_MOD.ClientProcessAllRemovedIndoorData(removed)
    if not removed then
        RI_MOD.Log("No IndoorRemovedData for Processing")
        return
    end

    RI_MOD.Log("Starting all IndoorRemovedData Processing")
    for key, value in pairs(removed) do
        if value then
            execIndoorSquareRemoval(value.x, value.y, value.z)
        else
            RI_MOD.Log(key .. ": `nil` data for square")
        end
    end
end
