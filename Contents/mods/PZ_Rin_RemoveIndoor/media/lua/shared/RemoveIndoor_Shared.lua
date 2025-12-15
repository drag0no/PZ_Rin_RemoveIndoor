local function RILog(msg)
    print("ClearIndoor: " .. tostring(msg))
end

-- Clear interior metadata for a single grid square (robust version)
local function clearSquareInternal(x, y, z)
    -- Input validation is crucial
    if not (x and y and z) or type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        return false, "invalid or non-numeric coordinates"
    end

    local cell = getCell()
    if not cell then
        return false, "getCell unavailable"
    end

    local sq = cell:getGridSquare(x, y, z)
    if not sq then
        -- This is normal for unloaded chunks/squares. Just return success.
        return true
    end

    local isSquareChanged = false
    local coordStr = ("%d,%d,%d"):format(x, y, z)
    RILog((">> %s : Start clearing"):format(coordStr, removed_count))

    local room = sq:getRoom()
    if room then
        sq:setRoom(nil)
        sq:setRoomID(-1)
        isSquareChanged = true
        RILog(("  - %s : setRoom(nil)"):format(coordStr))
    end

    -- 5. Robustly remove *Wall/Floor/Furniture* objects that look like room markers.
    local removed_count = 0
    local objs = sq:getObjects()
    if objs then
        -- Iterate backwards for safe removal
        for i = objs:size() - 1, 0, -1 do
            local obj = objs:get(i)
            if obj and obj:getSprite() then
                local sprite = obj:getSprite()
                local sname = sprite:getName() or ""
                local lname = tostring(sname):lower()
                RILog(("  * %s : object found '%s'"):format(coordStr, sname))

                if lname:find("light") or lname:find("shadow") then
                    -- Use the safe removal function
                    sq.RemoveTileObject(obj)
                    removed_count = removed_count + 1
                    isSquareChanged = true
                    RILog(("    - %s : object removed '%s'"):format(coordStr, sname))
                else
                    RILog(("    + %s : object skipped '%s'"):format(coordStr, sname))
                end
            end
        end
    end
    RILog(("  - %s : Removed %d object(s)"):format(coordStr, removed_count))

    if isSquareChanged then
        sq:RecalcProperties()
        sq:RecalcAllWithNeighbours(true)
        RILog(("  - %s : Recalc done"):format(coordStr))
    end

    RILog(("<< %s : Finished clearing"):format(coordStr, removed_count))
    return true
end

-- Global function callable from server console to clear an area rectangle
function clearIndoorArea(minX, minY, maxX, maxY, z)
    -- Validate numeric inputs
    if not (minX and minY and maxX and maxY and z) then
        RILog("Missing parameters! Usage: clearIndoorArea(minX, minY, maxX, maxY, z)")
        return false
    end

    -- Ensure min <= max
    if minX > maxX then minX, maxX = maxX, minX end
    if minY > maxY then minY, maxY = maxY, minY end

    RILog(("Starting ClearIndoorArea. Rectangle [%d,%d] to [%d,%d] at [z=%d]"):format(minX, minY, maxX, maxY, z))

    local total = 0
    local success_count = 0
    local fail_count = 0
    for x = minX, maxX do
        for y = minY, maxY do
            total = total + 1
            -- pcall is a good safety measure, keep it
            local ok, err = pcall(function() return clearSquareInternal(x, y, z) end)
            if ok and err == true then -- err here is the return value of clearSquareInternal
                success_count = success_count + 1
            else
                fail_count = fail_count + 1
                RILog(("%d,%d,%d: FAILED at: %s"):format(x, y, z, tostring(err)))
            end
        end
    end

    RILog(("Finished ClearIndoorArea. Squares processed: %d [SUCCESS %d / %d FAILURE]"):format(total, success_count, fail_count))
    return true
end