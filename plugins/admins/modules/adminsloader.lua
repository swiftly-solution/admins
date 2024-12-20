groupMapFlags = {}

AddEventHandler("OnPluginStart", function(event)
	db = Database(tostring(config:Fetch("admins.connection_name")))
	if not db:IsConnected() then return EventResult.Continue end

	db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.admins"))):Create({
		steamid = "string|max:128|unique",
		username = "string|max:128|unique",
		["`group`"] = "string|nullable",
		flags = "string|nullable",
		immunity = "integer|default:0"
	}):Execute()

	db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.groups"))):Create({
		groupname = "string|max:128|unique",
		group_displayname = "string",
		flags = "string"
	}):Execute()

	GroupsLoader()
	return EventResult.Continue
end)

function GroupsLoader(cb)
	if not db:IsConnected() then return end

	groups = {}
	admins = {}
	adminImmunities = {}
	adminGroups = {}
	groupMapFlags = {}
	adminsRawList = {}

	db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.groups"))):Select({}):Execute(function (err, result)
		if #err > 0 then return print("ERROR: " .. err) end
		groups = result

		for i = 1, #result do
			if type(result[i]) == "table" then
				groupMapFlags[result[i].groupname] = result[i].flags
			end
		end

		LoadAdmins(cb)
	end)
end

function CalculateFlags(flags)
	local flg = 0

	for i = 1, #flags do
		if flags[i] == ADMFLAG_ROOT then
			flg = flg | ADMFLAG_RESERVATION
			flg = flg | ADMFLAG_GENERIC
			flg = flg | ADMFLAG_KICK
			flg = flg | ADMFLAG_BAN
			flg = flg | ADMFLAG_UNBAN
			flg = flg | ADMFLAG_SLAY
			flg = flg | ADMFLAG_CHANGEMAP
			flg = flg | ADMFLAG_CONVARS
			flg = flg | ADMFLAG_CONFIG
			flg = flg | ADMFLAG_CHAT
			flg = flg | ADMFLAG_VOTE
			flg = flg | ADMFLAG_PASSWORD
			flg = flg | ADMFLAG_RCON
			flg = flg | ADMFLAG_CHEATS
			flg = flg | ADMFLAG_ROOT
		else
			flg = (flg | flags[i])
		end
	end

	return flg
end

function LoadAdmins(cb)

	db:QueryBuilder():Table(tostring(config:Fetch("admins.tablenames.admins"))):Select({}):Execute(function (err, result)
		if #err > 0 then return print("ERROR: " .. err) end
		for i = 1, #result do
			if type(result[i]) == "table" then
				if result[i].immunity < 0 then
					logger:Write(LogType_t.Warning, "Immunity for '" .. result[i].steamid .. "' can't be negative, automatically setting it to 0")
					result[i].immunity = 0
				end

				if result[i].group and groupMapFlags[result[i].group] then
					adminGroups[result[i].steamid] = result[i].group
					result[i].flags = groupMapFlags[result[i].group] .. result[i].flags
				end

				local giveFlags = {}
				for j = 1, result[i].flags:len() do
					local flag = result[i].flags:sub(j, j)
					if flagsPermissions[flag] then
						table.insert(giveFlags, flagsPermissions[flag])
					else
						logger:Write(LogType_t.Warning, "Invalid flag for '" .. result[i].steamid .. "': '" .. flag .. "'")
					end
				end

				local calculatedFlags = CalculateFlags(giveFlags)
				giveFlags = {}

				admins[result[i].steamid] = calculatedFlags
				adminImmunities[result[i].steamid] = result[i].immunity
				table.insert(adminsRawList, result[i])
			end
		end

		if type(cb) == "function" then
			cb()
		end

		local out, _ = FetchTranslation("admins.admins_loaded"):gsub("{COUNT}", #adminsRawList)
		print(out)
	end)
end

function LoadAdmin(player)
	player:SetVar("admin.flags", 0)
	player:SetVar("admin.immunity", 0)
	player:SetVar("admin.group", "None")

	local steamid = tostring(player:GetSteamID())
	if admins[steamid] then
		player:SetVar("admin.flags", admins[steamid])
		player:SetVar("admin.immunity", adminImmunities[steamid])
		if adminGroups[steamid] then player:SetVar("admin.group", adminGroups[steamid]) end
	end
end

function ReloadServerAdmins()
	GroupsLoader(function()
		for i = 0, playermanager:GetPlayerCap() - 1, 1 do
			local player = GetPlayer(i)
			if not player then goto continue end
			if player:IsFakeClient() then goto continue end
			LoadAdmin(player)
			::continue::
		end
	end)
end

function HasValidFlags(flags)
	for i = 1, string.len(flags) do
		if not flagsPermissions[flags:sub(i, i)] then return false end
	end
	return true
end

AddEventHandler("OnPlayerConnectFull", function(event)
	local playerid = event:GetInt("userid")
	local player = GetPlayer(playerid)
	if not player then return end

	LoadAdmin(player)
end)

AddEventHandler("OnClientDisconnect", function(event, playerid)
	local player = GetPlayer(playerid)
	if not player then return end

	player:SetVar("admin.flags", 0)
	player:SetVar("admin.immunity", 0)
	player:SetVar("admin.group", "None")
end)

---@param event Event
---@param playerid number
---@param target string
AddEventHandler("FindPlayerByTarget", function(event, playerid, target)
	local str = target:sub(1, 1)
	if str == "@" then
		local group = target:sub(2):lower()
		local playerGroup = exports[GetCurrentPluginName()]:GetAdminGroup(playerid):lower()
		event:SetReturn(group == playerGroup)
	end
end)
