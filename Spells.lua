-- FavoriteMount — what does this character actually know?
-- Every class spell the addon cares about is identified by its id, never by
-- its name: the name is whatever the client's language happens to call it. The
-- spellbook, however, only reports names — so the two are matched here once
-- and kept. Ask for an id, get the name to put in the macro, or nil when the
-- character has not learned it.

local FM = FavoriteMount

FM.Spells = {}

local book = {} -- localized name -> true, everything this character knows
local scanned = false

local function Scan()
	wipe(book)
	for tab = 1, GetNumSpellTabs() do
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		for i = offset + 1, offset + numSpells do
			local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
			if name then
				book[name] = true
			end
		end
	end
	scanned = true
end

-- the localized name of a spell this character knows, nil otherwise
function FM.Spells.Name(spellID)
	if not spellID then
		return nil
	end
	if not scanned then
		Scan()
	end
	local name = GetSpellInfo(spellID)
	if name and book[name] then
		return name
	end
	return nil
end

-- the spellbook changed; the next question rebuilds it
local function Invalidate()
	scanned = false
	if FM.Macro and FM.Macro.Update then
		FM.Macro.Update() -- a form or steed just learned belongs in the macro
	end
end

-- SPELLS_CHANGED covers learning and unlearning alike here. (LEARNED_SPELL_IN_TAB
-- does not exist on this client — registering it throws.)
FM.RegisterEvent("PLAYER_LOGIN", Invalidate)
FM.RegisterEvent("SPELLS_CHANGED", Invalidate)
