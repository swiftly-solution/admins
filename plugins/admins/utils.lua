function HasFlag(flags, flag)
	return ((flags & flag) == flag)
end

function PlayerHasFlag(player, flag)
	return HasFlag(player:GetVar("admin.flags") or 0, flag)
end