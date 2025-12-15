-- Handle the command from a client (requires the client to send the command and the player to have rights)
local function onClientCommand(module, command, playerObj, args)
    if module ~= "RemoveIndoor" then return end

    local isSinglePlayer = not isMP
    local isAdmin = isClient() and playerObj and playerObj:getAccessLevel() == "admin"
    if not (isSinglePlayer or isAdmin) then
        RILog("Unauthorized attempt to use ClearIndoorArea command.")
        return
    end

    if command == "ClearIndoorArea" then
        -- Validate and convert arguments received from the client (they come as strings/numbers from the client args table)
        local minX = tonumber(args.minX)
        local minY = tonumber(args.minY)
        local maxX = tonumber(args.maxX)
        local maxY = tonumber(args.maxY)
        local z = tonumber(args.z)

        clearIndoorArea(minX, minY, maxX, maxY, z)
    end
end

Events.OnClientCommand.Add(onClientCommand)
