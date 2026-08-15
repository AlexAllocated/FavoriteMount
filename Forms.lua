-- FavoriteMount — druid travel forms
-- Forms beat mounts where mounts cannot go: water and roofs, and shifting is
-- instant. A druid gets aquatic form while swimming, cat form indoors, flight
-- form where flying is allowed and travel form as the ground option — each
-- only if actually learned. Names come from the client via the spell id, so no
-- localized string is hardcoded anywhere.

local FM = FavoriteMount

-- base spell ids; ranks resolve through the spellbook lookup in Spells.lua
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

local function IsDruid()
	return select(2, UnitClass("player")) == "DRUID"
end

-- the localized name of a form this druid knows, nil otherwise
local function KnownForm(key)
	if not IsDruid() then
		return nil
	end
	return (FM.Spells.Name(FORM_SPELLS[key])) -- parenthesised: one value, safe in and/or
end

-- the form to use for a situation ("swim" | "indoors" | "fly" | "ground"),
-- plus its speed so the caller can weigh it against a mount. nil when the
-- druid does not know a form that fits.
function FM.Forms.For(situation)
	local key
	if situation == "swim" then
		key = "aquatic"
	elseif situation == "indoors" then
		-- under a roof nothing else moves: mounts are refused and travel form
		-- needs open sky, while cat form shifts anywhere and can dash
		key = "cat"
	elseif situation == "fly" then
		key = KnownForm("swiftFlight") and "swiftFlight" or "flight"
	else
		key = "travel"
	end
	local name = KnownForm(key)
	if not name then
		return nil, 0
	end
	return name, FORM_SPEED[key]
end

-- [key] = localized name, for /fm
function FM.Forms.Known()
	local known = {}
	for key in pairs(FORM_SPELLS) do
		local name = KnownForm(key)
		if name then
			known[key] = name
		end
	end
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
local TRAVEL_FORMS = { "travel", "aquatic", "flight", "swiftFlight" }

function FM.Forms.InForm()
	if not IsDruid() then
		return false
	end
	local wanted = {}
	for _, key in ipairs(TRAVEL_FORMS) do
		local name = KnownForm(key)
		if name then
			wanted[name] = true
		end
	end
	if not next(wanted) then
		return false
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
