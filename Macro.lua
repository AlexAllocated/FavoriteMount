-- FavoriteMount — the macro IS the addon's interface
-- No hidden button, no indirection: the addon writes the actual command into
-- a macro called FavoriteMount, which you drag onto any button or keybind
-- yourself. The body is rewritten whenever the situation changes (zone, bags,
-- mount or form state) — always out of combat, which costs nothing because
-- mounting in combat is impossible anyway. `#showtooltip` makes the action
-- button show the icon of whatever is currently in there.

local FM = FavoriteMount

local MACRO_NAME = "FavoriteMount"
local MACRO_ICON = "Ability_Mount_RidingHorse"
local MAX_GLOBAL = 120
local MAX_PER_CHAR = 18

FM.Macro = {}

local lastBody -- avoid rewriting an unchanged macro on every event
local pending = false

-- the class's own answer for this situation: a druid form, or the warlock's,
-- paladin's or shaman's own spell. No class has both, so whichever exists wins
-- — and on the impossible tie, the faster one.
local function ClassSpell(situation)
	local form, formSpeed = FM.Forms.For(situation)
	local steed, steedSpeed = FM.Steeds.For(situation)
	if steed and (not form or steedSpeed > formSpeed) then
		return steed, steedSpeed
	end
	return form, formSpeed
end

-- what should the macro do right now? Returns the body and a short
-- description for /fm.
local function Build()
	-- already mounted or shifted: the click takes you back to your feet
	if IsMounted and IsMounted() then
		return "#showtooltip\n/dismount", FM.L["dismount"]
	end
	if FM.Forms.InForm() then
		return "#showtooltip\n/cancelform", FM.L["cancel form"]
	end

	local situation = "ground"
	if IsSwimming and IsSwimming() then
		situation = "swim"
	elseif FM.Zones.Indoors() then
		situation = "indoors"
	elseif FM.Zones.CanFly() then
		situation = "fly"
	end
	local spell, spellSpeed = ClassSpell(situation)

	-- water and roofs both rule out every mount there is, so only a class of
	-- its own has an answer: aquatic form to swim, cat form or ghost wolf to at
	-- least beat a walk under a roof
	if situation == "swim" or situation == "indoors" then
		if spell then
			return "#showtooltip\n/cast " .. spell, spell
		end
		if situation == "swim" then
			return nil, FM.L["swimming"]
		end
		-- nothing to shift into: try the ground answer anyway, since not every
		-- roof the client reports actually refuses a mount
		situation = "ground"
		spell, spellSpeed = ClassSpell(situation)
	end

	local kind = (situation == "fly") and "fly" or "ground"
	local itemID = FM.Mounts.Random(kind)
	if kind == "fly" and not spell and not itemID then
		kind = "ground"
		spell, spellSpeed = ClassSpell("ground")
		itemID = FM.Mounts.Random(kind)
	end
	-- own spell or bag mount? Whichever actually moves faster, and a tie goes
	-- to the spell: it is instant or free, and costs no bag slot. So swift
	-- flight form beats an epic drake and a charger beats an equally fast bag
	-- mount, while travel form's 40% loses to any ground mount — and with no
	-- fitting mount in the bags the spell goes regardless. '/fm forms'
	-- overrides all of that in favour of the class spell.
	local mountSpeed = 0
	if itemID then
		mountSpeed = FM.Mounts.Speed(itemID)
	end
	if spell and (not itemID or FM.db.alwaysForms or spellSpeed >= mountSpeed) then
		return "#showtooltip\n/cast " .. spell, spell
	end
	if itemID then
		local name = GetItemInfo(itemID) or ("item:" .. itemID)
		return "#showtooltip\n/use item:" .. itemID, name
	end
	-- nothing of the right kind in the bags: a ground mount in a flight zone
	-- still walks, which beats a macro that does nothing
	local other = FM.Mounts.Random(kind == "fly" and "ground" or "fly")
	if other then
		local name = GetItemInfo(other) or ("item:" .. other)
		return "#showtooltip\n/use item:" .. other,
			string.format(FM.L["%s (nothing better in the bags)"], name)
	end
	return nil, FM.L["no mount in the bags"]
end

function FM.Macro.Describe()
	local _, what = Build()
	return what
end

-- create the macro if it is missing, edit it otherwise. Per-character first
-- (its content IS character specific), the account-wide slots as fallback.
local function Write(body, verbose)
	local index = GetMacroIndexByName(MACRO_NAME)
	if index and index > 0 then
		EditMacro(index, MACRO_NAME, MACRO_ICON, body)
		if verbose then
			FM.Print(string.format(FM.L["macro '%s' updated — drag it from the macro window onto a button"], MACRO_NAME))
		end
		return true
	end
	local numGlobal, numChar = GetNumMacros()
	local perCharacter = (numChar or 0) < MAX_PER_CHAR
	if not perCharacter and (numGlobal or 0) >= (MAX_ACCOUNT_MACROS or MAX_GLOBAL) then
		FM.Print(FM.L["no free macro slot — delete a macro and run '/fm macro'"])
		return false
	end
	CreateMacro(MACRO_NAME, MACRO_ICON, body, perCharacter)
	FM.db.macroCreated = true
	FM.Print(string.format(FM.L["macro '%s' created — drag it from the macro window onto a button"], MACRO_NAME))
	return true
end

-- refresh the macro body for the current situation
function FM.Macro.Update(verbose)
	if not FM.db then
		return
	end
	if InCombatLockdown() then
		pending = true -- macros are frozen in combat; catch up when it ends
		return
	end
	-- an untouched macro must not be recreated: only write once the player
	-- asked for it (or it already exists)
	local exists = (GetMacroIndexByName(MACRO_NAME) or 0) > 0
	if not exists and not verbose and FM.db.macroCreated then
		return -- the player deleted it on purpose
	end
	local body = Build() or "#showtooltip"
	if body == lastBody and exists and not verbose then
		return
	end
	if Write(body, verbose) then
		lastBody = body
	end
end

-- water and roofs decide the whole answer — no mount works in either — but
-- entering the water fires no event at all, and the indoor event does not
-- catch every overhang. So both are sampled, and only a change reaches Update;
-- everything else here stays event driven.
local wasSwimming, wasIndoors

local function WatchSurroundings()
	local swimming = (IsSwimming and IsSwimming()) or false
	local indoors = FM.Zones.Indoors()
	if swimming ~= wasSwimming or indoors ~= wasIndoors then
		wasSwimming, wasIndoors = swimming, indoors
		FM.Macro.Update()
	end
end

FM.RegisterEvent("PLAYER_LOGIN", function()
	-- the macro list is not reliably ready at login; a moment later it is
	C_Timer.After(3, function()
		FM.Macro.Update(not FM.db.macroCreated)
	end)
	wasSwimming = (IsSwimming and IsSwimming()) or false
	wasIndoors = FM.Zones.Indoors()
	C_Timer.NewTicker(0.5, WatchSurroundings)
end)

for _, event in ipairs({
	"PLAYER_ENTERING_WORLD", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS",
	"ZONE_CHANGED_NEW_AREA", "UPDATE_SHAPESHIFT_FORM", "PLAYER_UPDATE_RESTING",
}) do
	FM.RegisterEvent(event, function()
		FM.Macro.Update()
	end)
end

-- mounting, dismounting and shifting all show up as an aura change on the player
FM.RegisterEvent("UNIT_AURA", function(unit)
	if unit == "player" then
		FM.Macro.Update()
	end
end)

FM.RegisterEvent("PLAYER_REGEN_ENABLED", function()
	if pending then
		pending = false
		FM.Macro.Update()
	end
end)
