-- FavoriteMount — what is in my bags?
-- Mounts of this expansion are ordinary bag items, so the bags are scanned for
-- items of the mount item class. Whether one flies is not exposed by any API,
-- so it is read from the riding skill the item demands: 225 and above is a
-- flying mount, below that it walks. A manual override per item always wins
-- (`/fm fly` / `/fm ground` while hovering an item), because a heuristic that
-- cannot be corrected is worse than no heuristic.

local FM = FavoriteMount

local MOUNT_CLASS_ID = 15 -- Miscellaneous
local MOUNT_SUBCLASS_ID = 5 -- Mount
local FLYING_SKILL = 225 -- expert riding: the first flying tier
local NUM_BAGS = 4 -- backpack (0) plus four bag slots

FM.Mounts = {}

local cache = { fly = {}, ground = {}, unknown = {} }
local dirty = true

-- container API: the modern namespace on this client, legacy globals as a
-- fallback so a future (or older) build cannot break the scan
local function NumSlots(bag)
	if C_Container and C_Container.GetContainerNumSlots then
		return C_Container.GetContainerNumSlots(bag) or 0
	end
	return (GetContainerNumSlots and GetContainerNumSlots(bag)) or 0
end

local function ItemID(bag, slot)
	if C_Container and C_Container.GetContainerItemID then
		return C_Container.GetContainerItemID(bag, slot)
	end
	return GetContainerItemID and GetContainerItemID(bag, slot) or nil
end

-- a hidden tooltip is the only way to read an item's skill requirement
local scanner = CreateFrame("GameTooltip", "FavoriteMountScanner", nil, "GameTooltipTemplate")
scanner:SetOwner(UIParent, "ANCHOR_NONE")

-- highest number in parentheses anywhere in the tooltip — that is the required
-- skill value ("Requires Riding (225)"), and being a number it reads the same
-- in every language
local function RequiredSkill(itemID)
	scanner:ClearLines()
	scanner:SetHyperlink("item:" .. itemID)
	local best = 0
	for i = 1, scanner:NumLines() do
		local line = _G["FavoriteMountScannerTextLeft" .. i]
		local text = line and line:GetText()
		if text then
			local value = tonumber(text:match("%((%d+)%)") or "")
			if value and value > best then
				best = value
			end
		end
	end
	return best
end

-- "fly" | "ground" | nil (item data not cached yet, ask again later)
local function Classify(itemID)
	local override = FM.db and FM.db.mountType[itemID]
	if override then
		return override
	end
	local skill = RequiredSkill(itemID)
	if skill == 0 then
		return nil -- tooltip not populated yet
	end
	return (skill >= FLYING_SKILL) and "fly" or "ground"
end

-- is this bag item a mount? Returns false while the item is uncached, and the
-- caller schedules a rescan for that case.
local function IsMountItem(itemID)
	local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID = GetItemInfo(itemID)
	if not classID then
		return false, true -- uncached
	end
	return classID == MOUNT_CLASS_ID and subclassID == MOUNT_SUBCLASS_ID, false
end

local rescanTimer

local function ScheduleRescan()
	if rescanTimer then
		return
	end
	rescanTimer = C_Timer.NewTimer(1.5, function()
		rescanTimer = nil
		FM.Mounts.Invalidate()
		if FM.Macro and FM.Macro.Update then
			FM.Macro.Update()
		end
	end)
end

function FM.Mounts.Invalidate()
	dirty = true
end

-- rebuild the fly/ground lists from the bags
local function Scan()
	wipe(cache.fly)
	wipe(cache.ground)
	wipe(cache.unknown)
	local retry = false
	for bag = 0, NUM_BAGS do
		for slot = 1, NumSlots(bag) do
			local itemID = ItemID(bag, slot)
			if itemID then
				local isMount, uncached = IsMountItem(itemID)
				if uncached then
					retry = true
				elseif isMount and not (FM.db and FM.db.excluded[itemID]) then
					local kind = Classify(itemID)
					if kind == "fly" then
						cache.fly[#cache.fly + 1] = itemID
					elseif kind == "ground" then
						cache.ground[#cache.ground + 1] = itemID
					else
						cache.unknown[#cache.unknown + 1] = itemID
						retry = true
					end
				end
			end
		end
	end
	-- stable order regardless of bag layout, so the random pick is the only
	-- thing that varies between clicks
	table.sort(cache.fly)
	table.sort(cache.ground)
	dirty = false
	if retry then
		ScheduleRescan()
	end
end

local function Ensure()
	if dirty then
		Scan()
	end
end

-- itemIDs of the requested kind ("fly" | "ground")
function FM.Mounts.List(kind)
	Ensure()
	return cache[kind] or {}
end

function FM.Mounts.Unknown()
	Ensure()
	return cache.unknown
end

-- a random mount of the requested kind, nil when there is none
function FM.Mounts.Random(kind)
	local list = FM.Mounts.List(kind)
	if #list == 0 then
		return nil
	end
	return list[math.random(#list)]
end

FM.RegisterEvent("BAG_UPDATE_DELAYED", function()
	FM.Mounts.Invalidate()
	if FM.Macro and FM.Macro.Update then
		FM.Macro.Update()
	end
end)

FM.RegisterEvent("GET_ITEM_INFO_RECEIVED", function()
	if dirty or #cache.unknown > 0 then
		ScheduleRescan()
	end
end)
