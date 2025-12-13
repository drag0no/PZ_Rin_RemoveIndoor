local function RILog(msg)
    print("ClearIndoor: " .. tostring(msg))
end

-- Clear interior metadata for a single grid square (defensive)
local function clearSquareInternal(x, y, z)
    if not x or not y or not z then
        return false, "invalid coordinates"
    end

    local cell = getCell()
    if not cell then
        return false, "getCell unavailable"
    end

    local sq = cell:getGridSquare(x, y, z)
    if not sq then
        return false, "no grid square at " .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(z)
    end

    -- Attempt to set square exterior if API exists
    if type(sq.setIsExterior) == "function" then
        sq:setIsExterior(true)
        RILog(("%d,%d,%d: setIsExterior(true)"):format(x, y, z))
    end

    -- Attempt to clear room reference if API exists
    if type(sq.getRoom) == "function" and type(sq.setRoom) == "function" then
        local ok, room = pcall(function() return sq:getRoom() end)
        if ok and room then
            sq:setRoom(nil)
            RILog(("%d,%d,%d: setRoom(nil)"):format(x, y, z))
        end
    end

    -- Defensive removal of objects that look like room markers
    if type(sq.getObjects) == "function" then
        local ok, objs = pcall(function() return sq:getObjects() end)
        if ok and objs then
            for i = objs:size() - 1, 0, -1 do
                local obj = objs:get(i)
                if obj then
                    local name
                    if type(obj.getName) == "function" then
                        name = obj:getName()
                    end
                    local lname = name and tostring(name):lower() or ""
                    -- remove objects whose name contains "room" or "interior" or "lightnode"
                    if lname:find("room") or lname:find("interior") or lname:find("lightnode") then
                        -- attempt to remove via available APIs
                        local removed = false
                        if type(obj.removeFromSquare) == "function" then
                            obj:removeFromSquare()
                            removed = true
                        elseif type(objs.remove) == "function" then
                            objs:remove(i)
                            removed = true
                        end
                        if removed then
                            RILog(("%d,%d,%d: removed object '%s'"):format(x, y, z, tostring(name)))
                        end
                    end
                end
            end
        end
    end

    return true
end

-- Global function callable from server console to clear an area rectangle
function clearIndoorArea(minX, minY, maxX, maxY, z)
    -- Validate numeric inputs
    if not (minX and minY and maxX and maxY and z) then
        RILog("missing parameters. Usage: clearIndoorArea(minX, minY, maxX, maxY, z)")
        return false
    end

    -- Ensure min <= max
    if minX > maxX then minX, maxX = maxX, minX end
    if minY > maxY then minY, maxY = maxY, minY end

    RILog(("Starting clearIndoorArea for rectangle %d,%d to %d,%d at z=%d"):format(minX, minY, maxX, maxY, z))

    local total = 0
    for x = minX, maxX do
        for y = minY, maxY do
            local ok, err = pcall(function() return clearSquareInternal(x, y, z) end)
            if ok then
                total = total + 1
            else
                RILog(("%d,%d,%d: FAILED at: %s"):format(x, y, z, tostring(err)))
            end
        end
    end

    RILog(("clearIndoorArea finished. Squares processed: %d"):format(total))
    return true
end

local function onClientCommand(module, command, playerObj, args)
    if module ~= "RemoveIndoor" then return end

    if command == "ClearIndoorArea" then
        clearIndoorArea(args.minX, args.minY, args.maxX, args.maxY, args.z)
    end
end

Events.OnClientCommand.Add(onClientCommand)
