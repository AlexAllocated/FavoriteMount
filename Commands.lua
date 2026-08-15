-- FavoriteMount — slash commands
-- `/fm` alone reports what the button would do right now; the rest is the
-- handful of knobs the automatic classification cannot decide for you.

local FM = FavoriteMount
local L = FM.L

local commands = {}

-- the item the cursor currently rests on, so corrections read naturally:
-- hover the mount in your bags, then type the command
local function HoveredItemID()
	local _, link = GameTooltip:GetItem()
	if not link then
		return nil
	end
	return tonumber(link:match("item:(%d+)"))
end

local function ItemName(itemID)
	return (GetItemInfo(itemID)) or ("item:" .. tostring(itemID))
end

commands["status"] = function()
	local zone, continent, canFly = FM.Zones.Describe()
	FM.Print(L["zone"] .. ": " .. tostring(zone)
		.. " (" .. L["continent"] .. ": " .. tostring(continent or "?") .. ") — "
		.. (canFly and ("|cff40ff40" .. L["flying allowed here"] .. "|r")
			or ("|cffffd100" .. L["ground only here"] .. "|r")))
	FM.PrintLine(L["next click"] .. ": " .. tostring(FM.Macro.Describe()))
	local fly, ground = FM.Mounts.List("fly"), FM.Mounts.List("ground")
	FM.PrintLine(L["flying mounts"] .. ": " .. #fly)
	for _, itemID in ipairs(fly) do
		FM.PrintLine("   " .. ItemName(itemID))
	end
	FM.PrintLine(L["ground mounts"] .. ": " .. #ground)
	for _, itemID in ipairs(ground) do
		FM.PrintLine("   " .. ItemName(itemID))
	end
	local unknown = FM.Mounts.Unknown()
	if #unknown > 0 then
		FM.PrintLine(L["unclassified (still loading, or tell me with /fm fly | /fm ground)"] .. ":")
		for _, itemID in ipairs(unknown) do
			FM.PrintLine("   " .. ItemName(itemID))
		end
	end
	local forms = {}
	for key, name in pairs(FM.Forms.Known()) do
		forms[#forms + 1] = key .. " (" .. name .. ")"
	end
	if #forms > 0 then
		table.sort(forms)
		FM.PrintLine(L["druid forms"] .. ": " .. table.concat(forms, ", "))
	end
end

commands["zone"] = commands["status"]

local function Classify(kind, message)
	local itemID = HoveredItemID()
	if not itemID then
		FM.Print(L["hover a mount in your bags first"])
		return
	end
	FM.db.mountType[itemID] = kind
	FM.Mounts.Invalidate()
	FM.Macro.Update()
	FM.Print(string.format(message, ItemName(itemID)))
end

commands["fly"] = function()
	Classify("fly", L["%s counts as a flying mount now"])
end

commands["ground"] = function()
	Classify("ground", L["%s counts as a ground mount now"])
end

commands["exclude"] = function()
	local itemID = HoveredItemID()
	if not itemID then
		FM.Print(L["hover a mount in your bags first"])
		return
	end
	if FM.db.excluded[itemID] then
		FM.db.excluded[itemID] = nil
		FM.Print(string.format(L["%s is included again"], ItemName(itemID)))
	else
		FM.db.excluded[itemID] = true
		FM.Print(string.format(L["%s is excluded now"], ItemName(itemID)))
	end
	FM.Mounts.Invalidate()
	FM.Macro.Update()
end

commands["forms"] = function()
	FM.db.preferForms = not FM.db.preferForms
	FM.Macro.Update()
	FM.Print(string.format(L["druid forms first: %s"], FM.db.preferForms and L["on"] or L["off"]))
end

commands["macro"] = function()
	FM.Macro.Update(true)
end

commands["help"] = function()
	FM.Print("/fm — " .. L["next click"])
	FM.PrintLine("/fm macro — create or repair the macro")
	FM.PrintLine("/fm fly | /fm ground — classify the hovered mount by hand")
	FM.PrintLine("/fm exclude — never (or again) use the hovered mount")
	FM.PrintLine("/fm forms — druids: forms before mounts")
end

SLASH_FAVORITEMOUNT1 = "/favoritemount"
SLASH_FAVORITEMOUNT2 = "/fm"
SlashCmdList["FAVORITEMOUNT"] = function(input)
	local cmd = (input or ""):match("^%s*(%S*)"):lower()
	if cmd == "" then
		commands["status"]()
		return
	end
	local handler = commands[cmd]
	if not handler then
		FM.Print("unknown command '" .. cmd .. "' — /fm help")
		return
	end
	local ok, err = pcall(handler)
	if not ok then
		FM.Print("error in '" .. cmd .. "': " .. tostring(err))
	end
end
