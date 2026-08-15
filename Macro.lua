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

-- what should the macro do right now? Returns the body and a short
-- description for /fm.
local function Build()
	-- already mounted or shifted: the click takes you back to your feet
	if IsMounted and IsMounted() then
		return "#showtooltip\n/dismount", "dismount"
	end
	if FM.Forms.InForm() then
		return "#showtooltip\n/cancelform", "cancel form"
	end

	local swimming = IsSwimming and IsSwimming()
	local canFly = FM.Zones.CanFly()
	local situation = swimming and "swim" or (canFly and "fly" or "ground")
	local form = FM.Forms.For(situation)

	if situation == "swim" then
		-- no mount works while swimming; only a druid has an answer here
		if form then
			return "#showtooltip\n/cast " .. form, form
		end
		return nil, "swimming"
	end

	local kind = (situation == "fly") and "fly" or "ground"
	local itemID = FM.Mounts.Random(kind)
	-- a druid shifts instead of summoning when asked to, or when nothing fits
	if form and (FM.db.preferForms or not itemID) then
		return "#showtooltip\n/cast " .. form, form
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
		return "#showtooltip\n/use item:" .. other, name .. " (no " .. kind .. " mount in the bags)"
	end
	return nil, "no mount in the bags"
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
	local body = Build()
	if not body then
		return -- nothing sensible to put in; leave the last body alone
	end
	if body == lastBody and exists and not verbose then
		return
	end
	if Write(body, verbose) then
		lastBody = body
	end
end

FM.RegisterEvent("PLAYER_LOGIN", function()
	-- the macro list is not reliably ready at login; a moment later it is
	C_Timer.After(3, function()
		FM.Macro.Update(not FM.db.macroCreated)
	end)
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
