RemoveIndoor = RemoveIndoor or { coords = {} }

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

function RemoveIndoor.OnFillWorldObjectContextMenu(_player, _context, _worldObjects, _test)
    local player = getPlayer();
    if not isPlayerAdmin(player) then
       return;
    end

    local removeIndoorOption = _context:addOption(getText("Tooltip_RemoveIndoor_Option"), worldobjects);

    local subMenu = ISContextMenu:getNew(_context);
	_context:addSubMenu(removeIndoorOption, subMenu);

    local coordinate1 = getText("Tooltip_RemoveIndoor_SetCoordinate1")
    if RemoveIndoor.coords.x1 and RemoveIndoor.coords.y1 and RemoveIndoor.coords.z1 then
        coordinate1 = ("%s: %f, %f, %f").format(coordinate1, RemoveIndoor.coords.x1, RemoveIndoor.coords.y1, RemoveIndoor.coords.z1)
    end

    local coordinate2 = getText("Tooltip_RemoveIndoor_SetCoordinate2")
    if RemoveIndoor.coords.x2 and RemoveIndoor.coords.y2 and RemoveIndoor.coords.z2 then
        coordinate2 = ("%s: %f, %f, %f").format(coordinate2, RemoveIndoor.coords.x2, RemoveIndoor.coords.y2, RemoveIndoor.coords.z2)
    end

    subMenu:addOption(coordinate1, _worldObjects, function()
        local flootObject = _worldObjects[1]

        RemoveIndoor.coords.x1 = flootObject:getX()
        RemoveIndoor.coords.y1 = flootObject:getY()
        RemoveIndoor.coords.z1 = flootObject:getZ()

        if RemoveIndoor.coords.x2 and RemoveIndoor.coords.y2 and RemoveIndoor.coords.z2 then
            player:Say(getText("Tooltip_RemoveIndoor_ChosenCoordinate")
                .. (math.abs(RemoveIndoor.coords.x1 - RemoveIndoor.coords.x2) + 1)
                .. " x "
                .. (math.abs(RemoveIndoor.coords.y1 - RemoveIndoor.coords.y2) + 1))
        end
    end)

    subMenu:addOption(coordinate2, _worldObjects, function()
        local flootObject = _worldObjects[1]

        RemoveIndoor.coords.x2 = flootObject:getX()
        RemoveIndoor.coords.y2 = flootObject:getY()
        RemoveIndoor.coords.z2 = flootObject:getZ()

        if RemoveIndoor.coords.x1 and RemoveIndoor.coords.y1 and RemoveIndoor.coords.z1 then
            player:Say(getText("Tooltip_RemoveIndoor_ChosenCoordinate")
                .. (math.abs(RemoveIndoor.coords.x1 - RemoveIndoor.coords.x2) + 1)
                .. " x "
                .. (math.abs(RemoveIndoor.coords.y1 - RemoveIndoor.coords.y2) + 1))
        end
    end)

    if (RemoveIndoor.coords.x1 and RemoveIndoor.coords.y1 and RemoveIndoor.coords.z1) or (RemoveIndoor.coords.x2 and RemoveIndoor.coords.y2 and RemoveIndoor.coords.z2) then
        subMenu:addOption(getText("Tooltip_RemoveIndoor_CancelSelect"), _worldObjects, function()
            RemoveIndoor.coords = {}
        end)
    end

    if RemoveIndoor.coords.x1 and RemoveIndoor.coords.y1 and RemoveIndoor.coords.z1 and RemoveIndoor.coords.x2 and RemoveIndoor.coords.y2 and RemoveIndoor.coords.z2 then
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
