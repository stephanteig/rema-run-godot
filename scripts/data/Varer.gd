extends Node

const VARER := {
	"Nøtter":        ["Cashewnøtter", "Mandler", "Peanøtter", "Valnøtter", "Macadamia"],
	"Baguetter":     ["Egg og reke", "Skinke og ost", "Tun mayo", "Italiensk", "Vegetar"],
	"Brus":          ["Solo", "Pepsi Max", "Coca-Cola", "Fanta", "Sprite"],
	"Energidrikker": ["Battery", "Burn", "Raidero", "Fuse Tea", "Monster", "Celsius"],
	"Tyggis":        ["Stimorol", "Orbit", "Hubba Bubba", "Mentos gum"],
	"Snacks":        ["Cheez Doodles", "Maarud", "Sørlandschips", "Twist", "Smash", "Bugles"],
}

# Kategori → asset key (matches assets/ filenames without .png)
const KATEGORI_ASSET := {
	"Nøtter":        "item_notter",
	"Baguetter":     "item_baguette",
	"Brus":          "item_brus",
	"Energidrikker": "item_energidrikk",
	"Tyggis":        "item_tyggis",
	"Snacks":        "item_snacks",
}

# Kategori → zone tile key
const KATEGORI_SONE := {
	"Nøtter":        "tile_zone_notter",
	"Baguetter":     "tile_zone_baguette",
	"Brus":          "tile_fridge_brus",
	"Energidrikker": "tile_fridge_energi",
	"Tyggis":        "tile_zone_tyggis",
	"Snacks":        "tile_zone_snacks",
}

static func tilfeldig_vare(kategori: String) -> String:
	var liste: Array = VARER[kategori]
	return liste[randi() % liste.size()]

static func tilfeldig_energidrikk() -> String:
	return tilfeldig_vare("Energidrikker")

static func generer_handleliste(min_drikke: String, antall_bestillinger: int) -> Array:
	var liste := []
	# Spillerens egen drikke alltid først
	liste.append({"navn": min_drikke, "kategori": "Energidrikker", "hentet": false, "er_min": true})
	# Tilfeldig utvalg av andre kategorier (unngå Energidrikker igjen)
	var kategorier := ["Nøtter", "Baguetter", "Brus", "Tyggis", "Snacks"]
	kategorier.shuffle()
	for i in range(min(antall_bestillinger, kategorier.size())):
		var kat := kategorier[i]
		liste.append({
			"navn": tilfeldig_vare(kat),
			"kategori": kat,
			"hentet": false,
			"er_min": false
		})
	return liste
