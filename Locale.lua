-- FavoriteMount — localization
-- The English text is the key; untranslated keys fall through unchanged.

local FM = FavoriteMount

local L = setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})
FM.L = L

if GetLocale() ~= "deDE" then
	return
end

L["can't touch macros in combat"] = "Makros lassen sich im Kampf nicht ändern"
L["macro '%s' created — drag it from the macro window onto a button"] =
	"Makro '%s' erstellt — zieh es aus dem Makrofenster auf eine Taste"
L["macro '%s' updated — drag it from the macro window onto a button"] =
	"Makro '%s' aktualisiert — zieh es aus dem Makrofenster auf eine Taste"
L["no free macro slot — delete a macro and run '/fm macro'"] =
	"Kein freier Makroplatz — lösch ein Makro und ruf '/fm macro' auf"
L["zone"] = "Zone"
L["continent"] = "Kontinent"
L["flying allowed here"] = "Fliegen hier erlaubt"
L["ground only here"] = "hier nur Bodenmounts"
L["next click"] = "nächster Klick"
L["flying mounts"] = "Flugmounts"
L["ground mounts"] = "Bodenmounts"
L["unclassified (still loading, or tell me with /fm fly | /fm ground)"] =
	"nicht zugeordnet (lädt noch, oder sag es mit '/fm fly' bzw. '/fm ground')"
L["druid forms"] = "Druidenformen"
L["hover a mount in your bags first"] = "fahr zuerst über ein Reittier im Beutel"
L["%s counts as a flying mount now"] = "%s zählt jetzt als Flugmount"
L["%s counts as a ground mount now"] = "%s zählt jetzt als Bodenmount"
L["%s is excluded now"] = "%s wird jetzt übersprungen"
L["%s is included again"] = "%s wird wieder verwendet"
L["form or mount: %s"] = "Form oder Reittier: %s"
L["always"] = "immer die Form"
L["whichever is faster"] = "was schneller ist"
L["nothing excluded"] = "nichts ausgeschlossen"
