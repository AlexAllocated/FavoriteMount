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
	cat = 768,
}

-- movement bonus in percent, on the same scale the mounts are measured on, so
-- the two can be compared: travel form is slower than any ground mount, plain
-- flight form matches a normal flyer, swift flight form matches an epic one.
-- Aquatic form has no rival — nothing else moves in water at all.
local FORM_SPEED = {
	travel = 40,
	aquatic = 0,
	flight = 60,
	swiftFlight = 280,
	cat = 30, -- feral swiftness when talented; dash on top, whenever you press it
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

-- the form to use for a situation ("swim" | "indoors" | "fly" | "ground"),
-- plus its speed so the caller can weigh it against a mount. nil when the
-- druid does not know a form that fits.
function FM.Forms.For(situation)
	if not IsDruid() then
		return nil, 0
	end
	local key
	if situation == "swim" then
		key = known.aquatic and "aquatic"
	elseif situation == "indoors" then
		-- under a roof nothing else moves: mounts are refused and travel form
		-- needs open sky, while cat form shifts anywhere and can dash
		key = known.cat and "cat"
	elseif situation == "fly" then
		key = (known.swiftFlight and "swiftFlight") or (known.flight and "flight")
	else
		key = known.travel and "travel"
	end
	if not key then
		return nil, 0
	end
	return known[key], FORM_SPEED[key]
end

function FM.Forms.Known()
	return known
end

-- am I standing in one of the travel forms? Forms show up as a buff on the
-- player, and the names were resolved from the client — no stance-index
-- guessing, whose meaning differs between game versions.
--
-- Cat form is deliberately left out: it is a combat form as much as a way to
-- get around, so it must not turn the button into a plain '/cancelform'.
-- Pressing it again while in cat form casts cat form once more, which the
-- game reads as unshifting — the same result, without the special case.
local TRAVEL_FORMS = { travel = true, aquatic = true, flight = true, swiftFlight = true }

function FM.Forms.InForm()
	if not IsDruid() or not next(known) then
		return false
	end
	local wanted = {}
	for key, name in pairs(known) do
		if TRAVEL_FORMS[key] then
			wanted[name] = true
		end
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
