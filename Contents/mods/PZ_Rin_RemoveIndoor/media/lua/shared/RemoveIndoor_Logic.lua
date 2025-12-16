require "RemoveIndoor_Data"

local function getCoordKey(x, y, z)
    return x .. "," .. y .. "," .. z
end

local function addIndoorSquareRemoval(x, y, z, toSave)
    local coordKey = getCoordKey(x, y, z)
    local cell = getCell()
    if not cell then
        RI_MOD.Log(coordKey .. ": no cell")
        return
    end

    local sq = cell:getGridSquare(x, y, z)
    if not sq then
        RI_MOD.Log(coordKey .. ": unloaded chunk/square")
        return
    end

    local room = sq:getRoom()
    if room then
        sq:setRoom(nil)
        sq:setRoomID(-1)
        if toSave then
            RI_MOD.SaveData.removed[coordKey] = { x = x, y = y, z = z }
        end
        sq:RecalcAllWithNeighbours(false)
        RI_MOD.Log(coordKey .. ": setRoom(nil) & setRoomID(-1)")
    else
        RI_MOD.Log(coordKey .. ": no Room set")
    end
end

function RI_MOD.AddIndoorAreaRemoval(minX, minY, maxX, maxY, z)
    if not (minX and minY and maxX and maxY and z) then
        RI_MOD.Log("Missing parameters! Usage: AddIndoorAreaRemoval(minX, minY, maxX, maxY, z)")
        return false
    end

    if minX > maxX then minX, maxX = maxX, minX end
    if minY > maxY then minY, maxY = maxY, minY end

    RI_MOD.Log(("Starting AddIndoorAreaRemoval. Rectangle [%d,%d] to [%d,%d] at [z=%d]"):format(minX, minY, maxX, maxY, z))
    for x = minX, maxX do
        for y = minY, maxY do
            addIndoorSquareRemoval(x, y, z, true)
        end
    end
    return true
end

local function deleteIndoorSquareRemoval(x, y, z)
    local coordKey = getCoordKey(x, y, z)
    RI_MOD.SaveData.removed[coordKey] = nil
    RI_MOD.Log(coordKey .. ": RemoveIndoor deleted")
end

function RI_MOD.DeleteIndoorAreaRemoval(minX, minY, maxX, maxY, z)
    if not (minX and minY and maxX and maxY and z) then
        RI_MOD.Log("Missing parameters! Usage: DeleteIndoorAreaRemoval(minX, minY, maxX, maxY, z)")
        return false
    end

    if minX > maxX then minX, maxX = maxX, minX end
    if minY > maxY then minY, maxY = maxY, minY end

    RI_MOD.Log(("Starting DeleteIndoorAreaRemoval. Rectangle [%d,%d] to [%d,%d] at [z=%d]"):format(minX, minY, maxX, maxY, z))
    for x = minX, maxX do
        for y = minY, maxY do
            deleteIndoorSquareRemoval(x, y, z)
        end
    end
    return true
end

function RI_MOD.ClientProcessRemovedIndoorData(removed)
    if not removed then
        RI_MOD.Log("No IndoorRemovedData for Processing")
        return
    end

    RI_MOD.Log("Starting IndoorRemovedData Processing")
    for key, value in pairs(removed) do
        if value then
            addIndoorSquareRemoval(value.x, value.y, value.z, false)
        else
            RI_MOD.Log(key .. ": `nil` data for square")
        end
    end
end
