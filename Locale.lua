-- FavoriteMount — localization
-- The English text is the key; untranslated keys fall through unchanged, so a
-- client in any language stays readable even when nobody has translated it
-- yet. Nothing the addon DECIDES depends on this file: zones are matched by
-- map id and spells by id, and only what you read is translated here.

local FM = FavoriteMount

local L = setmetatable({}, {
	__index = function(_, key)
		return key
	end,
})
FM.L = L

local locale = GetLocale()

if locale == "deDE" then
	L["can't touch macros in combat"] = "Makros lassen sich im Kampf nicht ändern"
	L["macro '%s' created — drag it from the macro window onto a button"] =
		"Makro '%s' erstellt — zieh es aus dem Makrofenster auf eine Taste"
	L["macro '%s' updated — drag it from the macro window onto a button"] =
		"Makro '%s' aktualisiert — zieh es aus dem Makrofenster auf eine Taste"
	L["no free macro slot — delete a macro and run '/fm macro'"] =
		"Kein freier Makroplatz — lösch ein Makro und ruf '/fm macro' auf"
	L["zone"] = "Zone"
	L["continent"] = "Kontinent"
	L["map"] = "Karte"
	L["flying allowed here"] = "Fliegen hier erlaubt"
	L["ground only here"] = "hier nur Bodenmounts"
	L["next click"] = "nächster Klick"
	L["flying mounts"] = "Flugmounts"
	L["ground mounts"] = "Bodenmounts"
	L["unclassified (still loading, or tell me with /fm fly | /fm ground)"] =
		"nicht zugeordnet (lädt noch, oder sag es mit '/fm fly' bzw. '/fm ground')"
	L["druid forms"] = "Druidenformen"
	L["own mount"] = "eigenes Reittier"
	L["own spell or mount: %s"] = "eigener Zauber oder Reittier: %s"
	L["always"] = "immer der Zauber"
	L["whichever is faster"] = "was schneller ist"
	L["dismount"] = "absteigen"
	L["cancel form"] = "Form verlassen"
	L["swimming"] = "am Schwimmen"
	L["%s (nothing better in the bags)"] = "%s (nichts Besseres im Beutel)"
	L["no mount in the bags"] = "kein Reittier im Beutel"
	L["hover a mount in your bags first"] = "fahr zuerst über ein Reittier im Beutel"
	L["%s counts as a flying mount now"] = "%s zählt jetzt als Flugmount"
	L["%s counts as a ground mount now"] = "%s zählt jetzt als Bodenmount"
	L["%s is excluded now"] = "%s wird jetzt übersprungen"
	L["%s is included again"] = "%s wird wieder verwendet"
	L["create or repair the macro"] = "Makro anlegen oder reparieren"
	L["classify the hovered mount by hand"] =
		"das Reittier unter dem Zeiger von Hand einordnen"
	L["never (or again) use the hovered mount"] =
		"das Reittier unter dem Zeiger überspringen (oder wieder verwenden)"
	L["always use your class spell, or take whatever is faster"] =
		"immer den Klassenzauber, oder was schneller ist"
	L["unknown command '%s' — /fm help"] = "unbekannter Befehl '%s' — /fm help"
elseif locale == "frFR" then
	L["can't touch macros in combat"] = "impossible de modifier une macro en combat"
	L["macro '%s' created — drag it from the macro window onto a button"] =
		"macro '%s' créée — faites-la glisser de la fenêtre des macros sur un bouton"
	L["macro '%s' updated — drag it from the macro window onto a button"] =
		"macro '%s' mise à jour — faites-la glisser de la fenêtre des macros sur un bouton"
	L["no free macro slot — delete a macro and run '/fm macro'"] =
		"aucun emplacement de macro libre — supprimez une macro puis lancez '/fm macro'"
	L["zone"] = "zone"
	L["continent"] = "continent"
	L["map"] = "carte"
	L["flying allowed here"] = "vol autorisé ici"
	L["ground only here"] = "montures terrestres seulement ici"
	L["next click"] = "prochain clic"
	L["flying mounts"] = "montures volantes"
	L["ground mounts"] = "montures terrestres"
	L["unclassified (still loading, or tell me with /fm fly | /fm ground)"] =
		"non classées (chargement en cours, ou dites-le avec '/fm fly' ou '/fm ground')"
	L["druid forms"] = "formes de druide"
	L["own mount"] = "monture de classe"
	L["own spell or mount: %s"] = "sort de classe ou monture : %s"
	L["always"] = "toujours le sort"
	L["whichever is faster"] = "le plus rapide"
	L["dismount"] = "descendre"
	L["cancel form"] = "quitter la forme"
	L["swimming"] = "en train de nager"
	L["%s (nothing better in the bags)"] = "%s (rien de mieux dans les sacs)"
	L["no mount in the bags"] = "aucune monture dans les sacs"
	L["hover a mount in your bags first"] =
		"survolez d'abord une monture dans vos sacs"
	L["%s counts as a flying mount now"] = "%s compte désormais comme monture volante"
	L["%s counts as a ground mount now"] = "%s compte désormais comme monture terrestre"
	L["%s is excluded now"] = "%s est désormais ignorée"
	L["%s is included again"] = "%s est de nouveau utilisée"
	L["create or repair the macro"] = "créer ou réparer la macro"
	L["classify the hovered mount by hand"] = "classer à la main la monture survolée"
	L["never (or again) use the hovered mount"] =
		"ignorer (ou réutiliser) la monture survolée"
	L["always use your class spell, or take whatever is faster"] =
		"toujours le sort de classe, ou le plus rapide"
	L["unknown command '%s' — /fm help"] = "commande inconnue '%s' — /fm help"
end
