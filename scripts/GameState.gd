extends Node

# Spillvalg
var vanskelighet: String = "vanlig"   # "vanlig" | "vanskelig"
var karakter_id: String = "sondre"    # "sondre" | "kristine" | "hemmelig"

# Handleliste
var handleliste: Array = []           # [{navn, kategori, hentet, er_min}, ...]
var min_drikke: String = ""

# Tilstand
var har_id: bool = true
var aktive_powerups: Array = []       # ["speed", "id", "baguette", "beast"]
var speed_boost_slutt: float = 0.0
var beast_slutt: float = 0.0

# Timer
var timer_maks: float = 600.0
var tid_igjen: float = 600.0
var timer_aktiv: bool = false

# Statistikk
var fail_grunn: String = ""
var personlig_rekord: float = 0.0

signal timer_ferdig
signal powerup_hentet(type: String)

func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://saves.cfg") == OK:
		personlig_rekord = cfg.get_value("rekord", "beste_tid", 0.0)

func _process(delta: float) -> void:
	if not timer_aktiv:
		return
	tid_igjen -= delta
	if tid_igjen <= 0.0:
		tid_igjen = 0.0
		timer_aktiv = false
		emit_signal("timer_ferdig")

func start_timer() -> void:
	tid_igjen = timer_maks
	timer_aktiv = true

func stopp_timer() -> void:
	timer_aktiv = false

func get_tid_tekst() -> String:
	var minutter := int(tid_igjen / 60)
	var sekunder := int(tid_igjen) % 60
	return "%02d:%02d" % [minutter, sekunder]

func reset() -> void:
	handleliste = []
	min_drikke = ""
	aktive_powerups = []
	speed_boost_slutt = 0.0
	beast_slutt = 0.0
	fail_grunn = ""
	har_id = (vanskelighet == "vanlig")
	tid_igjen = timer_maks
	timer_aktiv = false

func legg_til_powerup(type: String) -> void:
	if type not in aktive_powerups:
		aktive_powerups.append(type)
	emit_signal("powerup_hentet", type)

func har_powerup(type: String) -> bool:
	return type in aktive_powerups

func get_hastighet_multiplikator() -> float:
	var mult := 1.0
	var tid_na := Time.get_ticks_msec() / 1000.0
	if har_powerup("speed") and tid_na < speed_boost_slutt:
		mult *= 1.6
	if har_powerup("beast") and tid_na < beast_slutt:
		mult *= 2.0
	if har_powerup("baguette"):
		mult *= 1.1
	return mult

func lagre_rekord(tid_brukt: float) -> void:
	if personlig_rekord == 0.0 or tid_brukt < personlig_rekord:
		personlig_rekord = tid_brukt
		var cfg := ConfigFile.new()
		cfg.set_value("rekord", "beste_tid", personlig_rekord)
		cfg.save("user://saves.cfg")

func alle_varer_hentet() -> bool:
	for vare in handleliste:
		if not vare.hentet:
			return false
	return true

func antall_hentet() -> int:
	var n := 0
	for vare in handleliste:
		if vare.hentet:
			n += 1
	return n
