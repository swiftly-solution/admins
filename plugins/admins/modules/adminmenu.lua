admin_menu_options = {}

commands:Register("admin", function(playerid, args, argc, silent)
    if playerid == -1 then return end
    local player = GetPlayer(playerid)
    if not player then return end

    if not PlayerHasFlag(player, ADMFLAG_GENERIC) then
        return ReplyToCommand(player, config:Fetch("admins.prefix"), FetchTranslation("admins.no_permission"))
    end
    if #admin_menu_options <= 0 then 
        return ReplyToCommand(player, config:Fetch("admins.prefix"), FetchTranslation("admins.menu.empty"))
    end

    player:ShowMenu("admin_menu")
end)

function RegenerateAdminMenu()
    local amenu = {}
    for i=1,#admin_menu_options do
        table.insert(amenu, { FetchTranslation(admin_menu_options[i].translation), admin_menu_options[i].command })
    end 
    menus:Unregister("admin_menu")
    menus:Register("admin_menu", FetchTranslation("admins.admin_menu_title"), config:Fetch("admins.amenucolor"), amenu)
end

AddEventHandler("OnPluginStart", function(event)
    RegenerateAdminMenu()
end)

export("RegisterMenuCategory", function(translation, command)
    local id = uuid()
    table.insert(admin_menu_options, { id = id, translation = translation, command = (command or "") })
    RegenerateAdminMenu()
    return id
end)

export("UnregisterMenuCategory", function(id)
    for i=1,#admin_menu_options do
        if admin_menu_options[i].id == id then
            table.remove(admin_menu_options, i)
            RegenerateAdminMenu()
            return true
        end
    end

    return false
end)