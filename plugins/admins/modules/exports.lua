export("HasFlags", function(playerid, flags)
    local player = GetPlayer(playerid)
    if not player then return false end
    for i = 1, string.len(flags) do
        local flagPerm = flagsPermissions[flags:sub(i, i)]
        if not PlayerHasFlag(player, flagPerm) then return false end
    end
    return true
end)

export("HasAdminGroup", function(playerid, group)
    local player = GetPlayer(playerid)
    if not player then return false end
    return (player:GetVar("admin.group") == group)
end)

export("GetImmunity", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return 0 end
    return player:GetVar("admin.immunity")
end)

export("GetAdminGroup", function(playerid)
    local player = GetPlayer(playerid)
    if not player then return "none" end
    return player:GetVar("admin.group")
end)