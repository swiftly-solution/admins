admin_menu_options = {}

commands:Register("admin", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end

    if not PlayerHasFlag(player, ADMFLAG_GENERIC) then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.no_permission"))
    end
    if #admin_menu_options <= 0 then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.menu.empty"))
    end

    if not RegenerateAdminMenu(playerid) then
        return ReplyToCommand(playerid, config:Fetch("admins.prefix"), FetchTranslation("admins.menu.empty"))
    end

    player:HideMenu()
    player:ShowMenu("admin_menu_" .. playerid)
end)

function RegenerateAdminMenu(playerid)
    local amenu = {}
    for i = 1, #admin_menu_options do
        if exports[GetCurrentPluginName()]:HasFlags(playerid, admin_menu_options[i].flag) then
            table.insert(amenu, { FetchTranslation(admin_menu_options[i].translation), admin_menu_options[i].command })
        end
    end

    if #amenu <= 0 then return false end

    menus:RegisterTemporary("admin_menu_" .. playerid, FetchTranslation("admins.admin_menu_title"),
        config:Fetch("admins.amenucolor"), amenu)

    return true
end

export("RegisterMenuCategory", function(translation, command, flag)
    local id = uuid()
    table.insert(admin_menu_options, { id = id, translation = translation, command = (command or ""), flag = flag })
    return id
end)

export("UnregisterMenuCategory", function(id)
    for i = 1, #admin_menu_options do
        if admin_menu_options[i].id == id then
            table.remove(admin_menu_options, i)
            return true
        end
    end

    return false
end)
