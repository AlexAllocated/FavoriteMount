-- FavoriteMount — core: namespace, saved variables, event dispatch, output.
-- One button decides what to summon: a random mount from your bags that suits
-- the zone you are standing in, or a druid form when that is the better (or
-- only) option. The zone decision comes from an explicit table in Zones.lua —
-- this client offers no reliable "can I fly here" API, so guessing is out.

local ADDON_NAME = ...

FavoriteMount = FavoriteMount or {}
local FM = FavoriteMount

FM.VERSION = "0.1.0"

local DB_DEFAULTS = {
	mountType = {}, -- [itemID] = "fly" | "ground": manual classification overrides
	excluded = {},  -- [itemID] = true: never summon this one
	preferForms = false, -- druids: forms before mounts even when a mount fits
	macroCreated = false,
}

-- event dispatch ---------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
local handlers = {}

function FM.RegisterEvent(event, handler)
	if not handlers[event] then
		handlers[event] = {}
		eventFrame:RegisterEvent(event)
	end
	table.insert(handlers[event], handler)
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
	for _, handler in ipairs(handlers[event]) do
		handler(...)
	end
end)

-- output -----------------------------------------------------------------------

function FM.Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff8ec9ffFavoriteMount|r: " .. tostring(msg))
end

function FM.PrintLine(msg)
	DEFAULT_CHAT_FRAME:AddMessage("  " .. tostring(msg))
end

-- lifecycle --------------------------------------------------------------------

FM.RegisterEvent("ADDON_LOADED", function(name)
	if name ~= ADDON_NAME then
		return
	end
	FavoriteMountDB = FavoriteMountDB or {}
	for key, value in pairs(DB_DEFAULTS) do
		if FavoriteMountDB[key] == nil then
			FavoriteMountDB[key] = value
		end
	end
	FM.db = FavoriteMountDB
end)
