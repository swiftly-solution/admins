local adminsCommands = {
    add = function(playerid, args, argc, silent)
        if argc < 5 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_admins add <steamid> <username> <immunity> <flags> [group]")
        end

        local steamid = args[2]
        local username = args[3]
        local immunity = math.max(tonumber(args[4]) or 0, 0)
        local flags = args[5]
        local group = args[6] or "none"

        if admins[steamid] then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.is_already_admin_steamid"):gsub("{STEAMID}", steamid))
        end

        if not HasValidFlags(flags) then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_flags"))
        end

        if group ~= "none" and not groupMapFlags[group] then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_group"))
        end

        for i=1,#adminsRawList do
            if adminsRawList[i].username == username then
                return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.username_already_exists"):gsub("{USERNAME}", username))
            end
        end

        db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.admins"))):Insert({ steamid = steamid, username = username, ["`group`"] = (group == "none" and "NULL" or group), flags = flags, immunity = immunity }):Execute()

        local flgs = (group == "none" and "" or groupMapFlags[group])..flags
        local giveFlags = {}
        for j=1,flgs:len() do
            local flag = flgs:sub(j,j)
            if flagsPermissions[flag] then
                table.insert(giveFlags, flagsPermissions[flag])
            end
        end
        admins[steamid] = CalculateFlags(giveFlags)

        if group ~= "none" then adminGroups[steamid] = group end
        adminImmunities[steamid] = immunity
        table.insert(adminsRawList, {
            steamid = steamid,
            username = username,
            group = (group == "none" and "NULL" or group),
            flags = flags,
            immunity = immunity,
        })

        local findPlayers = FindPlayersByTarget(steamid, false)
        for i=1,#findPlayers do
            if findPlayers[i] then
                LoadAdmin(findPlayers[i])
            end
        end

        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.added_succesfully"):gsub("{STEAMID}", steamid):gsub("{USERNAME}", username):gsub("{IMMUNITY}", immunity):gsub("{GROUP}", group):gsub("{FLAGS}", flags))
    end,
    edit = function(playerid, args, argc, silent)
        if argc < 4 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_admins edit <steamid> <username/immunity/flags/group> <value>")
        end

        local steamid = args[2]
        local option = args[3]
        local value = (option == "immunity" and math.max(tonumber(args[4]) or 0, 0) or args[4])

        if not admins[steamid] then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.not_an_admin_steamid"):gsub("{STEAMID}", steamid))
        end

        if option == "username" then
            for i=1,#adminsRawList do
                if adminsRawList[i].username == value then
                    return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.username_already_exists"):gsub("{USERNAME}", value))
                end
            end

            for i=1,#adminsRawList do
                if adminsRawList[i].steamid == steamid then
                    adminsRawList[i].username = value
                    break
                end
            end


            db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.admins"))):Update({ username = value }):Where("steamid", "=", steamid):Execute()
        elseif option == "immunity" then
            for i=1,#adminsRawList do
                if adminsRawList[i].steamid == steamid then
                    adminsRawList[i].immunity = value
                    break
                end
            end
            adminImmunities[steamid] = value

            local findPlayers = FindPlayersByTarget(steamid, false)
            for i=1,#findPlayers do
                if findPlayers[i] then
                    LoadAdmin(findPlayers[i])
                end
            end

            db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.admins"))):Update({ immunity = value }):Where("steamid", "=", steamid):Execute()
        elseif option == "flags" then
            if value == "none" then value = "" end
            if not HasValidFlags(value) then
                return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_flags"))
            end

            for i=1,#adminsRawList do
                if adminsRawList[i].steamid == steamid then
                    adminsRawList[i].flags = value
                    break
                end
            end

            local flgs = value
            if adminGroups[steamid] and groupMapFlags[adminGroups[steamid]] then
				flgs = groupMapFlags[adminGroups[steamid]] .. flgs
			end

            local giveFlags = {}
			for j=1,flgs:len() do
				local flag = flgs:sub(j,j)
				if flagsPermissions[flag] then
					table.insert(giveFlags, flagsPermissions[flag])
				end
			end

            admins[steamid] = CalculateFlags(giveFlags)
            db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.admins"))):Update({ flags = value }):Where("steamid", "=", steamid):Execute()

            local findPlayers = FindPlayersByTarget(steamid, false)
            for i=1,#findPlayers do
                if findPlayers[i] then
                    LoadAdmin(findPlayers[i])
                end
            end
        elseif option == "group" then
            if not groupMapFlags[value] and value ~= "none" then
                return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_group"))
            end

            local flgs = ""
            for i=1,#adminsRawList do
                if adminsRawList[i].steamid == steamid then
                    adminsRawList[i].group = value
                    flgs = adminsRawList[i].flags
                    break
                end
            end

            adminGroups[steamid] = value

            if adminGroups[steamid] and groupMapFlags[adminGroups[steamid]] then
				flgs = groupMapFlags[adminGroups[steamid]] .. flgs
			end

            local giveFlags = {}
			for j=1,flgs:len() do
				local flag = flgs:sub(j,j)
				if flagsPermissions[flag] then
					table.insert(giveFlags, flagsPermissions[flag])
				end
			end

            admins[steamid] = CalculateFlags(giveFlags)

            db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.admins"))):Update({ ["`group`"] = value }):Where("steamid", "=", steamid):Execute()

            local findPlayers = FindPlayersByTarget(steamid, false)
            for i=1,#findPlayers do
                if findPlayers[i] then
                    LoadAdmin(findPlayers[i])
                end
            end
        else
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_admins edit <steamid> <username/immunity/flags/group> <value>")
        end

        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.edit_succesfully"):gsub("{STEAMID}", steamid):gsub("{OPTION}", option):gsub("{VALUE}", value))
    end,
    list = function(playerid, args, argc, silent)
        if #adminsRawList == 0 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_admins_list"))
        end

        local adminShow = {
            { "id", "steamid", "username", "group", "flags", "immunity" }
        }
        for i=1,#adminsRawList do
            if type(adminsRawList[i]) == "table" then
                local newtbl = {
                    string.format("%02d.", #adminShow),
                    adminsRawList[i].steamid,
                    adminsRawList[i].username,
                    adminsRawList[i].group or "NULL",
                    adminsRawList[i].flags,
                    tostring(adminsRawList[i].immunity)
                }

                adminShow[#adminShow + 1] = newtbl
			end
        end
        print(CreateTextTable(adminShow))
    end,
    remove = function(playerid, args, argc, silent)
        if argc < 2 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_admins remove <steamid>")
        end

        local steamid = args[2]
        if not admins[steamid] then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.not_an_admin_steamid"):gsub("{STEAMID}", steamid))
        end

        admins[steamid] = nil
        adminImmunities[steamid] = nil
        adminGroups[steamid] = nil
        for i=1,#adminsRawList do
            if adminsRawList[i].steamid == steamid then
                table.remove(adminsRawList, i)
                break
            end
        end

        db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.admins"))):Delete():Where("steamid", "=", steamid):Execute()

        local findPlayers = FindPlayersByTarget(steamid, false)
        for i=1,#findPlayers do
            if findPlayers[i] then
                LoadAdmin(findPlayers[i])
            end
        end

        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.remove"):gsub("{STEAMID}", steamid))
    end,
    reload = function(playerid, args, argc, silent)
        ReloadServerAdmins()

        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.reload"))
    end
}

local groupsCommands = {
    add = function(playerid, args, argc, silent)
        if argc < 4 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_groups add <name> <display name> <flags>")
        end

        local name = args[2]
        local display_name = args[3]
        local flags = args[4]

        if groupMapFlags[name] then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.group_exists"):gsub("{NAME}", name))
        end

        if not HasValidFlags(flags) then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_flags"))
        end

        db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.groups"))):Insert({ groupname = name, group_displayname = display_name, flags = flags }):Execute()

        ReloadServerAdmins()

        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.group_added"):gsub("{NAME}", name):gsub("{DISPLAYNAME}", display_name):gsub("{FLAGS}", flags))
    end,
    edit = function(playerid, args, argc, silent)
        if argc < 4 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_groups edit <name> <displayname/flags> <value>")
        end

        local name = args[2]
        local option = args[3]
        local value = args[4]

        if not groupMapFlags[name] then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_group_exists"):gsub("{NAME}", name))
        end

        if option == "displayname" then
            db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.groups"))):Update({ group_displayname = value }):Where("groupname", "=", name):Execute()
        elseif option == "flags" then
            if not HasValidFlags(value) then
                return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.invalid_flags"))
            end

            db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.groups"))):Update({ flags = value }):Where("groupname", "=", name):Execute()
        else
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_groups edit <name> <displayname/flags> <value>")
        end

        ReloadServerAdmins()

        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.group_edit_succesfully"):gsub("{NAME}", name):gsub("{OPTION}", option):gsub("{VALUE}", value))
    end,
    list = function(playerid, args, argc, silent)
        if #groups == 0 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_groups_list"))
        end

        local groupShow = {
            { "ID", "Group Name", "Display Name", "Flags" }
        }
        for i=1,#groups do
            if type(groups[i]) == "table" then
               	table.insert(groupShow, {
                    string.format("%02d.", #groupShow),
                    groups[i].groupname,
                    groups[i].group_displayname,
                    groups[i].flags:len() == 0 and "-" or groups[i].flags
                })
            end
        end
        print(CreateTextTable(groupShow))
    end,
    remove = function(playerid, args, argc, silent)
        if argc < 2 then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_groups remove <name>")
        end

        local name = args[2]

        if not groupMapFlags[name] then
            return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_group_exists"):gsub("{NAME}", name))
        end

        db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.groups"))):Delete():Where("groupname", "=", name):Execute()

        ReloadServerAdmins()

        ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.remove_group"):gsub("{NAME}", name))
    end
}

commands:Register("admins", function(playerid, args, argc, silent)
    if playerid ~= -1 then return end

    if argc < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_admins <add/edit/list/remove/reload>")
    end

    local option = args[1]
    if not adminsCommands[option] then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_admins <add/edit/list/remove/reload>") end

    adminsCommands[option](playerid, args, argc, silent)
end)

commands:Register("groups", function(playerid, args, argc, silent)
    if playerid ~= -1 then return end

    if argc < 1 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_groups <add/edit/list/remove>")
    end

    local option = args[1]
    if not groupsCommands[option] then return ReplyToCommand(playerid, config:Fetch("admins.prefix"), "Syntax: sw_groups <add/edit/list/remove>") end

    groupsCommands[option](playerid, args, argc, silent)
end)