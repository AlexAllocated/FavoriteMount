-- Run from the repository root: lua tests/regressions.lua
local noop = function() end
local body, fly, item, spell, combat = nil, true, nil, "Summon Charger", false
local events = {}
FavoriteMount = {
    db = { macroCreated = true },
    L = setmetatable({}, { __index = function(_, k) return k end }),
    Print = noop, RegisterEvent = function(k, f) events[k] = f end,
    Forms = { InForm = function() return false end, For = function() return nil, 0 end },
    Steeds = { For = function(s) return s == "ground" and spell or nil, 100 end },
    Zones = { Indoors = function() return false end, CanFly = function() return fly end },
    Mounts = { Random = function(k) return k == "ground" and item or nil end,
        Speed = function() return 60 end },
}
IsMounted = function() return false end
IsSwimming = function() return false end
InCombatLockdown = function() return combat end
GetMacroIndexByName = function() return 1 end
EditMacro = function(_, _, _, text) body = text end
GetItemInfo = function() return "Bag mount" end
dofile("Macro.lua")

FavoriteMount.Macro.Update()
assert(body == "#showtooltip\n/cast Summon Charger", "class mount must work without a flying mount")
item = 123
FavoriteMount.Macro.Update()
assert(body:find("Summon Charger", 1, true), "ground fallback must compare spell and item speeds")
fly, spell = false, nil
FavoriteMount.Macro.Update()
assert(body:find("item:123", 1, true))
item, combat = nil, true
FavoriteMount.Macro.Update()
assert(body:find("item:123", 1, true), "do not edit macros during combat")
combat = false
events.PLAYER_REGEN_ENABLED()
assert(body == "#showtooltip", "an excluded/unavailable mount must leave no stale action")
-- TBC map IDs must work without the English/German/French name fallback.
local mapID, indoors, instance = 1944, false, false
Enum = { UIMapType = { Continent = 2 } }
GetRealZoneText = function() return "Полуостров Адского Пламени" end
GetZoneText = GetRealZoneText
IsIndoors = function() return indoors end
IsInInstance = function() return instance end
C_Map = {
    GetBestMapForUnit = function() return mapID end,
    GetMapInfo = function(id)
        if id == 1944 then return { parentMapID = 1945, mapType = 3 } end
        if id == 1945 then return { name = "Запределье", parentMapID = 946, mapType = 2 } end
        if id == 1941 then return { parentMapID = 1415, mapType = 3 } end
        if id == 1415 then return { name = "Восточные королевства", mapType = 2 } end
    end,
}
dofile("Zones.lua")
assert(FavoriteMount.Zones.CanFly(), "Outland must be flyable on other client languages")
indoors = true
assert(not FavoriteMount.Zones.CanFly(), "map IDs must not allow flight indoors")
indoors, instance = false, true
assert(not FavoriteMount.Zones.CanFly(), "map IDs must not allow flight in an instance")
instance, mapID = false, 1941
assert(not FavoriteMount.Zones.CanFly(), "other Classic continents remain ground-only")
print("FavoriteMount regressions passed")
