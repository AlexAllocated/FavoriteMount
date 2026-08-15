-- FavoriteMount — where may I fly?
-- This client has no dependable flight check: the [flyable] macro condition
-- does not exist here and the matching API cannot be trusted either. So the
-- answer comes from an explicit zone table, matched against the zone name the
-- client reports. Everything not listed counts as ground-only, which is the
-- safe direction to be wrong in: you get a ground mount instead of a failed
-- cast. `/fm zone` prints what the addon currently sees.

local FM = FavoriteMount

-- Flight zones of this expansion, by localized zone name. Add a locale by
-- adding its spellings — an unknown name simply means "no flying here".
local FLYABLE = {
	-- Outland
	["Hellfire Peninsula"] = true, ["Höllenfeuerhalbinsel"] = true,
	["Zangarmarsh"] = true, ["Zangarmarschen"] = true,
	["Terokkar Forest"] = true, ["Wald von Terokkar"] = true,
	["Nagrand"] = true,
	["Blade's Edge Mountains"] = true, ["Schergrat"] = true,
	["Netherstorm"] = true, ["Nethersturm"] = true,
	["Shadowmoon Valley"] = true, ["Schattenmondtal"] = true,
	["Shattrath City"] = true, ["Shattrath"] = true,
	-- 2.4 island
	["Isle of Quel'Danas"] = true, ["Insel von Quel'Danas"] = true,
	["Insel von Quel’Danas"] = true, -- typographic apostrophe variant
}

-- continent names, used only when the zone itself is unknown (new subzone,
-- another locale): standing anywhere on this continent means flying is allowed
local FLYABLE_CONTINENT = {
	["Outland"] = true, ["Scherbenwelt"] = true,
}

FM.Zones = {}

-- the zone name the client reports for the player's current position
function FM.Zones.Current()
	local zone = GetRealZoneText()
	if not zone or zone == "" then
		zone = GetZoneText()
	end
	return zone
end

-- the continent name, resolved by walking up the map chain (locale-safe ids
-- are not stable across clients, so the NAME is compared — same as the zones)
function FM.Zones.Continent()
	if not C_Map or not C_Map.GetBestMapForUnit then
		return nil
	end
	local mapID = C_Map.GetBestMapForUnit("player")
	local guard = 0 -- a malformed map chain must not spin forever
	while mapID and guard < 12 do
		guard = guard + 1
		local info = C_Map.GetMapInfo(mapID)
		if not info then
			return nil
		end
		if info.mapType == Enum.UIMapType.Continent then
			return info.name
		end
		mapID = info.parentMapID
		if mapID == 0 then
			return nil
		end
	end
	return nil
end

-- may I use a flying mount right now? Indoors and instances are excluded
-- outright: flight fails there regardless of the zone.
function FM.Zones.CanFly()
	if IsIndoors and IsIndoors() then
		return false, "indoors"
	end
	if IsInInstance and IsInInstance() then
		return false, "instance"
	end
	local zone = FM.Zones.Current()
	if zone and FLYABLE[zone] then
		return true, zone
	end
	-- unknown zone: fall back to the continent, so a subzone we never listed
	-- (or a locale we do not ship) still flies where flying is allowed
	if zone and not FLYABLE[zone] then
		local continent = FM.Zones.Continent()
		if continent and FLYABLE_CONTINENT[continent] then
			return true, continent
		end
	end
	return false, zone
end

-- for /fm zone and diagnostics
function FM.Zones.Describe()
	local canFly, why = FM.Zones.CanFly()
	return FM.Zones.Current(), FM.Zones.Continent(), canFly, why
end
