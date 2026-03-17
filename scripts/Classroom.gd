extends Node2D

const TILE := 64  # classroom tile size (bigger for readability)

var ventende_bestillinger: Array = []  # indekser til klassekamerater som venter
var navarende_index: int = 0
var alle_akseptert: bool = false
var spiller_pos: Vector2
var ballonger: Array = []  # aktive taleballonger

# Nodes
var spiller_sprite: Sprite2D
var laerer_sprite: Sprite2D
var info_label: Label
var interaksjon_hint: Label
var laerer_ballong: PanelContainer
var klass_noder: Array = []
var klass_ballonger: Array = []

func _ready() -> void:
	_bygg_klasserom()
	_plasser_karakterer()
	_generer_handleliste()
	_vis_laerer_ballong("10 minutters pause!")

	# Start global timer
	GameState.start_timer()
	GameState.timer_ferdig.connect(_tid_ute)

	# Bygg handleliste-panel
	await get_tree().create_timer(1.5).timeout
	_vis_neste_bestilling()

func _bygg_klasserom() -> void:
	# Bakgrunn
	var bg := ColorRect.new()
	bg.color = Color(0.22, 0.35, 0.28)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	# Gulv
	var gulv := ColorRect.new()
	gulv.color = Color(0.55, 0.45, 0.35)
	gulv.position = Vector2(0, 200)
	gulv.size = Vector2(1280, 520)
	add_child(gulv)

	# Tavle
	var tavle := ColorRect.new()
	tavle.color = Color(0.1, 0.25, 0.15)
	tavle.position = Vector2(300, 40)
	tavle.size = Vector2(680, 140)
	add_child(tavle)
	var tavle_ramme := ColorRect.new()
	tavle_ramme.color = Color(0.4, 0.28, 0.18)
	tavle_ramme.position = Vector2(292, 32)
	tavle_ramme.size = Vector2(696, 156)
	add_child(tavle_ramme)
	move_child(tavle_ramme, get_child_count() - 2)

	# Pulter (3 rader × 5 pulter)
	for rad in range(3):
		for kol in range(5):
			var pult := ColorRect.new()
			pult.color = Color(0.6, 0.48, 0.3)
			pult.position = Vector2(100 + kol * 220, 280 + rad * 120)
			pult.size = Vector2(160, 60)
			add_child(pult)

	# Timer-display øverst venstre
	var timer_panel := ColorRect.new()
	timer_panel.color = Color(0.0, 0.0, 0.0, 0.6)
	timer_panel.position = Vector2(10, 10)
	timer_panel.size = Vector2(180, 48)
	add_child(timer_panel)

	var timer_lbl := Label.new()
	timer_lbl.name = "TimerLabel"
	timer_lbl.text = "10:00"
	timer_lbl.add_theme_font_size_override("font_size", 28)
	timer_lbl.add_theme_color_override("font_color", Color.WHITE)
	timer_lbl.position = Vector2(20, 18)
	add_child(timer_lbl)

	# Info-label nederst
	info_label = Label.new()
	info_label.text = ""
	info_label.add_theme_font_size_override("font_size", 20)
	info_label.add_theme_color_override("font_color", Color.WHITE)
	info_label.position = Vector2(400, 670)
	add_child(info_label)

	# Interaksjonshint
	interaksjon_hint = Label.new()
	interaksjon_hint.text = "[E] Aksepter bestilling"
	interaksjon_hint.add_theme_font_size_override("font_size", 22)
	interaksjon_hint.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	interaksjon_hint.position = Vector2(450, 640)
	interaksjon_hint.visible = false
	add_child(interaksjon_hint)

func _plasser_karakterer() -> void:
	# Spiller (Sondre eller valgt karakter)
	spiller_sprite = Sprite2D.new()
	var spr_tex: Texture2D = load("res://assets/char_sondre.png")
	if GameState.karakter_id == "kristine":
		spr_tex = load("res://assets/char_klasse_f.png")
	elif GameState.karakter_id == "hemmelig":
		spr_tex = load("res://assets/char_kassedame.png")
	spiller_sprite.texture = spr_tex
	spiller_sprite.scale = Vector2(0.8, 0.8)
	spiller_pos = Vector2(640, 500)
	spiller_sprite.position = spiller_pos
	add_child(spiller_sprite)

	# Mathias (bestevenn)
	var mathias := Sprite2D.new()
	mathias.texture = load("res://assets/char_mathias.png")
	mathias.scale = Vector2(0.8, 0.8)
	mathias.position = spiller_pos + Vector2(90, 0)
	add_child(mathias)
	_legg_til_navnetag(mathias, "Mathias")

	# Laerer
	laerer_sprite = Sprite2D.new()
	laerer_sprite.texture = load("res://assets/char_laerer.png")
	laerer_sprite.scale = Vector2(0.9, 0.9)
	laerer_sprite.position = Vector2(640, 160)
	add_child(laerer_sprite)

	# 3 klassekamerater som skal komme med bestillinger
	var poses := [Vector2(200, 450), Vector2(850, 420), Vector2(500, 560)]
	var teksturer := ["char_klasse_f", "char_klasse_m", "char_klasse_f"]
	for i in range(3):
		var k := Sprite2D.new()
		k.texture = load("res://assets/" + teksturer[i] + ".png")
		k.scale = Vector2(0.75, 0.75)
		k.position = poses[i]
		k.modulate.a = 0.3  # synker inn gradvis
		add_child(k)
		klass_noder.append(k)
		klass_ballonger.append(null)

func _legg_til_navnetag(node: Node2D, navn: String) -> void:
	var lbl := Label.new()
	lbl.text = navn
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.position = node.position + Vector2(-20, -65)
	add_child(lbl)

func _generer_handleliste() -> void:
	var varer_data = load("res://scripts/data/Varer.gd")
	GameState.min_drikke = varer_data.tilfeldig_energidrikk()
	GameState.handleliste = varer_data.generer_handleliste(GameState.min_drikke, 3)

func _vis_laerer_ballong(tekst: String) -> void:
	if laerer_ballong:
		laerer_ballong.queue_free()
	laerer_ballong = _lag_taleballong(tekst, laerer_sprite.position + Vector2(-80, -90))
	add_child(laerer_ballong)

func _vis_neste_bestilling() -> void:
	if navarende_index >= min(3, GameState.handleliste.size() - 1):
		# Alle akseptert
		_alle_akseptert()
		return

	var vare_index := navarende_index + 1  # hopp over index 0 (spillerens egen drikke)
	if vare_index >= GameState.handleliste.size():
		_alle_akseptert()
		return

	var vare = GameState.handleliste[vare_index]
	var k_node = klass_noder[navarende_index]
	k_node.modulate.a = 1.0

	# Vis taleballong over klassekamerat
	if klass_ballonger[navarende_index] != null:
		klass_ballonger[navarende_index].queue_free()
	var ballong_tekst := "Kan du kjope\n" + vare.navn + "?"
	var ballong := _lag_taleballong(ballong_tekst, k_node.position + Vector2(-60, -90))
	add_child(ballong)
	klass_ballonger[navarende_index] = ballong

	interaksjon_hint.visible = true
	info_label.text = "Trykk [E] for aa akseptere bestillingen"

func _alle_akseptert() -> void:
	alle_akseptert = true
	interaksjon_hint.visible = false
	info_label.text = "Dere loper ut!"
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/Outdoor.tscn")

func _lag_taleballong(tekst: String, pos: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = pos

	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.2, 0.2, 0.2)
	panel.add_theme_stylebox_override("panel", style)

	var lbl := Label.new()
	lbl.text = tekst
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(150, 0)
	panel.add_child(lbl)

	return panel

func _process(_delta: float) -> void:
	# Oppdater timer
	var timer_lbl := get_node_or_null("TimerLabel")
	if timer_lbl:
		timer_lbl.text = GameState.get_tid_tekst()
		if GameState.tid_igjen < 30.0:
			timer_lbl.add_theme_color_override("font_color", Color.RED)
		elif GameState.tid_igjen < 120.0:
			timer_lbl.add_theme_color_override("font_color", Color.ORANGE)

	# E-tast
	if Input.is_action_just_pressed("ui_accept") or Input.is_physical_key_just_pressed(KEY_E):
		if not alle_akseptert and navarende_index < klass_noder.size():
			_aksepter_bestilling()

func _aksepter_bestilling() -> void:
	var vare_index := navarende_index + 1
	if vare_index < GameState.handleliste.size():
		# Bestillingen er allerede i lista fra _generer_handleliste
		pass
	navarende_index += 1
	_vis_neste_bestilling()

func _tid_ute() -> void:
	GameState.fail_grunn = "Tiden er ute!"
	get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
