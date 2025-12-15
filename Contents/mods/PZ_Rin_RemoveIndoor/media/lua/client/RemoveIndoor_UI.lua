RemoveIndoor = RemoveIndoor or { coords = {} }

local function coords1ToString()
    local coords = RemoveIndoor.coords
    return string.format("%d,%d,%d", coords.x1, coords.y1, coords.z1)
end

local function coords2ToString()
    local coords = RemoveIndoor.coords
    return string.format("%d,%d,%d", coords.x2, coords.y2, coords.z2)
end

local function isCoord1Set()
    return RemoveIndoor.coords.x1 and RemoveIndoor.coords.y1 and RemoveIndoor.coords.z1
end

local function isCoord2Set()
    return RemoveIndoor.coords.x2 and RemoveIndoor.coords.y2 and RemoveIndoor.coords.z2
end

local function isOneSet()
    return isCoord1Set() or isCoord2Set()
end

local function isAllSet()
    return RemoveIndoor.coords.x1 and RemoveIndoor.coords.y1 and RemoveIndoor.coords.z1 and
            RemoveIndoor.coords.x2 and RemoveIndoor.coords.y2 and RemoveIndoor.coords.z2
end

local function normalizeCoords()
    if not isAllSet() then
        return
    end
    if RemoveIndoor.coords.x1 > RemoveIndoor.coords.x2 then
        RemoveIndoor.coords.x1, RemoveIndoor.coords.x2 = RemoveIndoor.coords.x2, RemoveIndoor.coords.x1
    end
    if RemoveIndoor.coords.y1 > RemoveIndoor.coords.y2 then
        RemoveIndoor.coords.y1, RemoveIndoor.coords.y2 = RemoveIndoor.coords.y2, RemoveIndoor.coords.y1
    end
end

local function getCoordinates(flootObject)
    return flootObject:getX(), flootObject:getY(), flootObject:getZ()
end

local function isPlayerAdmin(player)
    if not isClient() then
        return true
    end
    if isClient() then
        return player:isAdmin()
    end
    if isServer() then
        return player:getAccessLevel() == "admin"
    end
    return false
end

local function saySquare(player)
    if not isAllSet() then
        return
    end
    player:Say(getText("Tooltip_RemoveIndoor_ChosenCoordinate")
            .. (RemoveIndoor.coords.x2 - RemoveIndoor.coords.x1 + 1)
            .. " x "
            .. (RemoveIndoor.coords.y2 - RemoveIndoor.coords.y1 + 1))
end

function RemoveIndoor.OnFillWorldObjectContextMenu(_, _context, _worldObjects, _)
    local player = getPlayer();
    if not isPlayerAdmin(player) then
       return;
    end

    local removeIndoorOption = _context:addOption(getText("Tooltip_RemoveIndoor_Option"), worldobjects);

    local subMenu = ISContextMenu:getNew(_context);
	_context:addSubMenu(removeIndoorOption, subMenu);

    local coordinate1 = getText("Tooltip_RemoveIndoor_SetCoordinate1")
    if isCoord1Set() then
        coordinate1 = coordinate1 .. ": " .. coords1ToString()
    end

    local coordinate2 = getText("Tooltip_RemoveIndoor_SetCoordinate2")
    if isCoord2Set() then
        coordinate2 = coordinate2 .. ": " .. coords2ToString()
    end

    subMenu:addOption(coordinate1, _worldObjects, function()
        local coords = RemoveIndoor.coords
        coords.x1, coords.y1, coords.z1 = getCoordinates(_worldObjects[1])
        normalizeCoords()
        saySquare(player)
    end)

    subMenu:addOption(coordinate2, _worldObjects, function()
        local coords = RemoveIndoor.coords
        coords.x2, coords.y2, coords.z2 = getCoordinates(_worldObjects[1])
        normalizeCoords()
        saySquare(player)
    end)

    if isOneSet() then
        subMenu:addOption(getText("Tooltip_RemoveIndoor_CancelSelect"), _worldObjects, function()
            RemoveIndoor.coords = {}
        end)
    end

    if isAllSet() then
        subMenu:addOption(getText("Tooltip_RemoveIndoor_RemoveExec"), _worldObjects, function()
            local coords = RemoveIndoor.coords
            if coords.z1 ~= coords.z2 then
                player:Say(getText("Tooltip_RemoveIndoor_CancelDiffZ"))
                return
            end

            local args = { minX = coords.x1, minY = coords.y1, maxX = coords.x2, maxY = coords.y2, z = coords.z1 }
            sendClientCommand(player, "RemoveIndoor", "ClearIndoorArea", args)

            player:Say(getText("Tooltip_RemoveIndoor_RemoveSay"))
            RemoveIndoor.coords = {}
        end)
    end
end

Events.OnFillWorldObjectContextMenu.Add(RemoveIndoor.OnFillWorldObjectContextMenu)
