require "RemoveIndoor_Logic"

local function coords1ToString()
    local coords = RI_MOD.WorkData.coords
    return string.format("%d,%d,%d", coords.x1, coords.y1, coords.z1)
end

local function coords2ToString()
    local coords = RI_MOD.WorkData.coords
    return string.format("%d,%d,%d", coords.x2, coords.y2, coords.z2)
end

local function isCoord1Set()
    return RI_MOD.WorkData.coords.x1 and RI_MOD.WorkData.coords.y1 and RI_MOD.WorkData.coords.z1
end

local function isCoord2Set()
    return RI_MOD.WorkData.coords.x2 and RI_MOD.WorkData.coords.y2 and RI_MOD.WorkData.coords.z2
end

local function isOneSet()
    return isCoord1Set() or isCoord2Set()
end

local function isAllSet()
    return RI_MOD.WorkData.coords.x1 and RI_MOD.WorkData.coords.y1 and RI_MOD.WorkData.coords.z1 and
            RI_MOD.WorkData.coords.x2 and RI_MOD.WorkData.coords.y2 and RI_MOD.WorkData.coords.z2
end

local function clearCoords()
    RI_MOD.WorkData.coords = {}
end

local function normalizeCoords(player)
    if not isAllSet() then
        return
    end
    if RI_MOD.WorkData.coords.z1 ~= RI_MOD.WorkData.coords.z2 then
        player:Say(getText("Tooltip_RemoveIndoor_CancelDiffZ"))
        clearCoords()
        return
    end
    if RI_MOD.WorkData.coords.x1 > RI_MOD.WorkData.coords.x2 then
        RI_MOD.WorkData.coords.x1, RI_MOD.WorkData.coords.x2 = RI_MOD.WorkData.coords.x2, RI_MOD.WorkData.coords.x1
    end
    if RI_MOD.WorkData.coords.y1 > RI_MOD.WorkData.coords.y2 then
        RI_MOD.WorkData.coords.y1, RI_MOD.WorkData.coords.y2 = RI_MOD.WorkData.coords.y2, RI_MOD.WorkData.coords.y1
    end
    player:Say(getText("Tooltip_RemoveIndoor_ChosenCoordinate")
            .. (RI_MOD.WorkData.coords.x2 - RI_MOD.WorkData.coords.x1 + 1)
            .. " x "
            .. (RI_MOD.WorkData.coords.y2 - RI_MOD.WorkData.coords.y1 + 1))
end

local function getCoordinates(floorObject)
    return floorObject:getX(), floorObject:getY(), floorObject:getZ()
end

function RI_MOD.OnFillWorldObjectContextMenu(_, _context, _worldObjects, _)
    local player = getPlayer()
    if not (RI_MOD.IsSinglePlayer() or RI_MOD.IsServerAdmin(player)) then
        return;
    end

    local removeIndoorOption = _context:addOption(getText("Tooltip_RemoveIndoor_Option"), _worldObjects);

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
        local coords = RI_MOD.WorkData.coords
        coords.x1, coords.y1, coords.z1 = getCoordinates(_worldObjects[1])
        normalizeCoords(player)
    end)

    subMenu:addOption(coordinate2, _worldObjects, function()
        local coords = RI_MOD.WorkData.coords
        coords.x2, coords.y2, coords.z2 = getCoordinates(_worldObjects[1])
        normalizeCoords(player)
    end)

    if isOneSet() then
        subMenu:addOption(getText("Tooltip_RemoveIndoor_CancelSelect"), _worldObjects, function()
            clearCoords()
        end)
    end

    if isAllSet() then
        subMenu:addOption(getText("Tooltip_RemoveIndoor_RemoveExec"), _worldObjects, function()
            local coords = RI_MOD.WorkData.coords
            local args = { minX = coords.x1, minY = coords.y1, maxX = coords.x2, maxY = coords.y2, z = coords.z1 }
            sendClientCommand(player, "RemoveIndoor", "AddIndoorAreaRemoval", args)
            player:Say(getText("Tooltip_RemoveIndoor_RemoveSay"))
            clearCoords()
        end)

        subMenu:addOption(getText("Tooltip_RemoveIndoor_RevertExec"), _worldObjects, function()
            local coords = RI_MOD.WorkData.coords
            local args = { minX = coords.x1, minY = coords.y1, maxX = coords.x2, maxY = coords.y2, z = coords.z1 }
            sendClientCommand(player, "RemoveIndoor", "DeleteIndoorAreaRemoval", args)
            player:Say(getText("Tooltip_RemoveIndoor_RevertSay"))
            clearCoords()
        end)
    end
end
