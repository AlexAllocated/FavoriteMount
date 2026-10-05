-- FavoriteMount — where may I fly?
-- This client has no dependable flight check: the [flyable] macro condition
-- does not exist here and the matching API cannot be trusted either. So the
-- answer comes from an explicit table — but of MAP IDS, which read the same in
-- every language. The zone NAMES further down are only a fallback for the case
-- where the map API answers nothing at all; they cannot cover every locale and
-- are not supposed to. Everything unknown counts as ground-only, which is the
-- safe direction to be wrong in: you get a ground mount instead of a failed
-- cast. `/fm zone` prints what the addon currently sees, map id included.

local FM = FavoriteMount

-- flight zones that are not simply "the whole continent"
local FLYABLE_MAPS = {
	[1957] = true, -- Isle of Quel'Danas (2.4), the one flight zone outside Outland
}

-- standing anywhere on such a continent means flying is allowed
local FLYABLE_CONTINENTS = {
	[1945] = true, -- Outland (TBC Classic UI map ID)
}

-- Fallback only, for a client that gives us no map id. Add a locale by adding
-- its spellings; an unknown name simply means "no flying here".
local FLYABLE_NAMES = {
	-- Outland, enUS
	["Hellfire Peninsula"] = true, ["Zangarmarsh"] = true,
	["Terokkar Forest"] = true, ["Nagrand"] = true,
	["Blade's Edge Mountains"] = true, ["Netherstorm"] = true,
	["Shadowmoon Valley"] = true, ["Shattrath City"] = true,
	["Isle of Quel'Danas"] = true,
	-- deDE
	["Höllenfeuerhalbinsel"] = true, ["Zangarmarschen"] = true,
	["Wald von Terokkar"] = true, ["Schergrat"] = true,
	["Nethersturm"] = true, ["Schattenmondtal"] = true,
	["Shattrath"] = true, ["Insel von Quel'Danas"] = true,
	["Insel von Quel’Danas"] = true, -- typographic apostrophe variant
	-- frFR
	["Péninsule des Flammes infernales"] = true, ["Marécage de Zangar"] = true,
	["Forêt de Terokkar"] = true, ["Montagnes Tranchantes"] = true,
	["Raz-de-Néant"] = true, ["Vallée d'Ombrelune"] = true,
	["Ville de Shattrath"] = true, ["Île de Quel'Danas"] = true,
}

local FLYABLE_CONTINENT_NAMES = {
	["Outland"] = true, ["Scherbenwelt"] = true, ["Outreterre"] = true,
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

function FM.Zones.MapID()
	if not C_Map or not C_Map.GetBestMapForUnit then
		return nil
	end
	return C_Map.GetBestMapForUnit("player")
end

-- walks the map chain outward from the player, looking for a flight zone or a
-- flight continent. Only a "yes" is trusted from here; anything else falls
-- through to the names below.
local function MapSaysFly()
	local mapID = FM.Zones.MapID()
	local guard = 0 -- a malformed map chain must not spin forever
	while mapID and mapID ~= 0 and guard < 12 do
		guard = guard + 1
		if FLYABLE_MAPS[mapID] then
			return true
		end
		local info = C_Map.GetMapInfo(mapID)
		if not info then
			return false
		end
		-- the continent is the outermost thing worth asking: a subzone we never
		-- listed still answers correctly through its parents
		if info.mapType == Enum.UIMapType.Continent then
			return FLYABLE_CONTINENTS[mapID] or false
		end
		mapID = info.parentMapID
	end
	return false
end

-- the continent name, for /fm. The decision above uses the id, not this.
function FM.Zones.Continent()
	local mapID = FM.Zones.MapID()
	local guard = 0
	while mapID and mapID ~= 0 and guard < 12 do
		guard = guard + 1
		local info = C_Map.GetMapInfo(mapID)
		if not info then
			return nil
		end
		if info.mapType == Enum.UIMapType.Continent then
			return info.name
		end
		mapID = info.parentMapID
	end
	return nil
end

-- under a roof? No mount comes out there, and travel form needs open sky —
-- which leaves cat form (or ghost wolf) as the only way to beat a walk.
function FM.Zones.Indoors()
	return (IsIndoors and IsIndoors()) or false
end

-- may I use a flying mount right now? Indoors and instances are excluded
-- outright: flight fails there regardless of the zone.
function FM.Zones.CanFly()
	if FM.Zones.Indoors() then
		return false, "indoors"
	end
	if IsInInstance and IsInInstance() then
		return false, "instance"
	end
	if MapSaysFly() then
		return true, FM.Zones.Current()
	end
	-- The map chain did not say yes — either it has no answer, or an id here is
	-- wrong. The names get asked anyway: they can only ever ADD a flight zone,
	-- never take one away, so a mistake in the table above cannot ground a
	-- character who could fly before.
	local zone = FM.Zones.Current()
	if zone and FLYABLE_NAMES[zone] then
		return true, zone
	end
	local continent = FM.Zones.Continent()
	if continent and FLYABLE_CONTINENT_NAMES[continent] then
		return true, continent
	end
	return false, zone
end

-- for /fm zone and diagnostics
function FM.Zones.Describe()
	local canFly, why = FM.Zones.CanFly()
	return FM.Zones.Current(), FM.Zones.Continent(), canFly, why
end
