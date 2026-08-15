-- FavoriteMount — druid travel forms
-- Forms beat mounts where mounts cannot go: water, and shifting is instant. A
-- druid gets aquatic form while swimming, flight form where flying is allowed,
-- and travel form as the ground option — each only if actually learned. Names
-- come from the client via the spell id, so no localized string is hardcoded.

local FM = FavoriteMount

-- base spell ids; ranks resolve through the spellbook scan below
local FORM_SPELLS = {
	travel = 783,
	aquatic = 1066,
	flight = 33943,
	swiftFlight = 40120,
}

FM.Forms = {}

local known = {} -- [key] = localized spell name

local function IsDruid()
	return select(2, UnitClass("player")) == "DRUID"
end

-- every spell name in the player's spellbook, so "do I know this form?" never
-- depends on a hardcoded translation
local function ScanSpellbook()
	local names = {}
	for tab = 1, GetNumSpellTabs() do
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		for i = offset + 1, offset + numSpells do
			local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
			if name then
				names[name] = true
			end
		end
	end
	return names
end

function FM.Forms.Refresh()
	wipe(known)
	if not IsDruid() then
		return
	end
	local book = ScanSpellbook()
	for key, spellID in pairs(FORM_SPELLS) do
		local name = GetSpellInfo(spellID)
		if name and book[name] then
			known[key] = name
		end
	end
end

-- the form to use for a situation, or nil when the druid cannot (or should
-- not) shift: "swim" | "fly" | "ground"
function FM.Forms.For(situation)
	if not IsDruid() then
		return nil
	end
	if situation == "swim" then
		return known.aquatic
	end
	if situation == "fly" then
		return known.swiftFlight or known.flight
	end
	return known.travel
end

function FM.Forms.Known()
	return known
end

-- am I standing in one of the travel forms? Forms show up as a buff on the
-- player, and the names were resolved from the client — no stance-index
-- guessing, whose meaning differs between game versions.
function FM.Forms.InForm()
	if not IsDruid() or not next(known) then
		return false
	end
	local wanted = {}
	for _, name in pairs(known) do
		wanted[name] = true
	end
	for i = 1, 40 do
		local name = UnitBuff("player", i)
		if not name then
			break
		end
		if wanted[name] then
			return true
		end
	end
	return false
end

FM.RegisterEvent("PLAYER_LOGIN", FM.Forms.Refresh)
FM.RegisterEvent("SPELLS_CHANGED", FM.Forms.Refresh)
FM.RegisterEvent("LEARNED_SPELL_IN_TAB", FM.Forms.Refresh)
