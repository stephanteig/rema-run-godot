extends Node

const KARAKTERER := {
	"sondre": {
		"navn": "Sondre",
		"beskrivelse": "Den vanlige — balansert og pålitelig",
		"hastighet": 160.0,
		"id_sjekk_sjanse": 0.33,
		"stat_fart": 3,
		"stat_flaks": 3,
		"farge": Color(0.3, 0.8, 0.78),
	},
	"kristine": {
		"navn": "Kristine",
		"beskrivelse": "Speedrunneren — rask men uheldig",
		"hastighet": 210.0,
		"id_sjekk_sjanse": 0.50,
		"stat_fart": 5,
		"stat_flaks": 1,
		"farge": Color(1.0, 0.42, 0.42),
	},
	"hemmelig": {
		"navn": "????",
		"beskrivelse": "Villkortet — treg men ekstremt heldig",
		"hastighet": 130.0,
		"id_sjekk_sjanse": 0.10,
		"stat_fart": 2,
		"stat_flaks": 5,
		"farge": Color(0.61, 0.35, 0.71),
	},
}

static func get_karakter(id: String) -> Dictionary:
	return KARAKTERER.get(id, KARAKTERER["sondre"])
