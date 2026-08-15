-- FavoriteMount — the mounts that are spells instead of items
-- A warlock's felsteed, a paladin's charger and a shaman's ghost wolf never
-- sit in a bag, so the bag scan in Mounts.lua cannot see them and a character
-- riding only on their class spell was left with a button that did nothing.
-- They are looked up by spell id and carry the same speed scale as everything
-- else, so the macro can weigh them against what is in the bags.

local FM = FavoriteMount

-- fastest first: the first one this character knows is the one to use
local CLASS_STEEDS = {
	WARLOCK = {
		{ id = 23161, speed = 100 }, -- Summon Dreadsteed
		{ id = 5784, speed = 60 },   -- Summon Felsteed
	},
	PALADIN = {
		{ id = 23214, speed = 100 }, -- Summon Charger
		{ id = 13819, speed = 60 },  -- Summon Warhorse
	},
}

-- ghost wolf is a shift, not a summon: slower than any real mount, and it is
-- therefore only chosen when nothing faster fits — but it works under a roof,
-- where a shaman has nothing else at all.
local GHOST_WOLF = { id = 2645, speed = 40 }

FM.Steeds = {}

local function PlayerClass()
	return select(2, UnitClass("player"))
end

-- the class's own mount for a situation ("swim" | "indoors" | "fly" |
-- "ground"), plus its speed. nil when this class has none, or none that works
-- here.
function FM.Steeds.For(situation)
	if situation == "swim" or situation == "fly" then
		return nil, 0 -- no class mount of this expansion swims or flies
	end
	local class = PlayerClass()
	if class == "SHAMAN" then
		local name = FM.Spells.Name(GHOST_WOLF.id)
		if name then
			return name, GHOST_WOLF.speed
		end
		return nil, 0
	end
	if situation == "indoors" then
		return nil, 0 -- a summoned steed is refused under a roof, like any mount
	end
	local steeds = CLASS_STEEDS[class]
	if not steeds then
		return nil, 0
	end
	for _, steed in ipairs(steeds) do
		local name = FM.Spells.Name(steed.id)
		if name then
			return name, steed.speed
		end
	end
	return nil, 0
end

-- name and speed of this character's class mount at all, for /fm
function FM.Steeds.Known()
	local name, speed = FM.Steeds.For("ground")
	return name, speed
end
