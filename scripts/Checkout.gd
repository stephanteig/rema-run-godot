extends Node2D

var pris: int = 0
var id_sjekk_utfort: bool = false

func _ready() -> void:
	pris = randi_range(45, 189)
	_bygg_ui()
	GameState.timer_ferdig.connect(_tid_ute)
	await get_tree().create_timer(0.5).timeout
	_start_kassedialog()

func _bygg_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.12, 0.2)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	# Kassedame sprite
	var kassedame := Sprite2D.new()
	kassedame.texture = load("res://assets/char_kassedame.png")
	kassedame.scale = Vector2(1.2, 1.2)
	kassedame.position = Vector2(640, 350)
	add_child(kassedame)

	# Mathias (stille ved siden av)
	var mathias := Sprite2D.new()
	mathias.texture = load("res://assets/char_mathias.png")
	mathias.scale = Vector2(0.8, 0.8)
	mathias.position = Vector2(800, 420)
	add_child(mathias)

	# Spiller-sprite
	var spiller_spr := Sprite2D.new()
	var tex_key := "char_sondre"
	if GameState.karakter_id == "kristine": tex_key = "char_klasse_f"
	elif GameState.karakter_id == "hemmelig": tex_key = "char_kassedame"
	spiller_spr.texture = load("res://assets/" + tex_key + ".png")
	spiller_spr.scale = Vector2(0.9, 0.9)
	spiller_spr.position = Vector2(480, 430)
	add_child(spiller_spr)

	# Timer HUD
	var timer_bg := ColorRect.new()
	timer_bg.color = Color(0.0, 0.0, 0.0, 0.7)
	timer_bg.position = Vector2(10, 10)
	timer_bg.size = Vector2(160, 48)
	add_child(timer_bg)
	var timer_lbl := Label.new()
	timer_lbl.name = "TimerLabel"
	timer_lbl.text = GameState.get_tid_tekst()
	timer_lbl.add_theme_font_size_override("font_size", 28)
	timer_lbl.add_theme_color_override("font_color", Color.WHITE)
	timer_lbl.position = Vector2(20, 18)
	add_child(timer_lbl)

func _start_kassedialog() -> void:
	_vis_kassedame_tekst("Hei! Det blir " + str(pris) + " kr.")
	await get_tree().create_timer(2.0).timeout
	_sjekk_id()

func _vis_kassedame_tekst(tekst: String) -> void:
	# Fjern gammel ballong
	for child in get_children():
		if child.name == "KasseBallong":
			child.queue_free()

	var panel := PanelContainer.new()
	panel.name = "KasseBallong"
	panel.position = Vector2(400, 180)

	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.3)
	style.content_margin_left = 20; style.content_margin_right = 20
	style.content_margin_top = 12; style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)

	var lbl := Label.new()
	lbl.text = tekst
	lbl.add_theme_font_size_override("font_size", 24)
	lbl.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.custom_minimum_size = Vector2(380, 0)
	panel.add_child(lbl)
	add_child(panel)

func _sjekk_id() -> void:
	# Beast potion hopper over ID-sjekk helt
	if GameState.har_powerup("beast"):
		_vis_kassedame_tekst("Klart! Betaling godkjent!")
		await get_tree().create_timer(1.5).timeout
		_betal_ok()
		return

	# Sjansebassert ID-sjekk
	var kar = load("res://scripts/data/Karakterer.gd").new().KARAKTERER.get(GameState.karakter_id, {})
	var sjanse: float = kar.get("id_sjekk_sjanse", 0.33)
	if randf() < sjanse:
		_vis_kassedame_tekst("Har du legitimasjon?")
		await get_tree().create_timer(1.5).timeout
		_handter_id_sjekk()
	else:
		_vis_kassedame_tekst("Det er " + str(pris) + " kr.")
		await get_tree().create_timer(1.2).timeout
		_betal_ok()

func _handter_id_sjekk() -> void:
	if GameState.har_id or GameState.har_powerup("id"):
		# Vis godkjent
		_vis_resultat_bilde("ui_godkjent")
		_vis_kassedame_tekst("Alt i orden! Betaling godkjent")
		await get_tree().create_timer(2.0).timeout
		_betal_ok()
	else:
		# Vis avvist
		_vis_resultat_bilde("ui_avvist")
		_vis_kassedame_tekst("Avvist! Du hadde ikke legitimasjon")
		await get_tree().create_timer(2.5).timeout
		GameState.fail_grunn = "Avvist! Ingen legitimasjon"
		get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")

func _vis_resultat_bilde(asset_key: String) -> void:
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/" + asset_key + ".png")
	spr.position = Vector2(640, 520)
	spr.scale = Vector2(1.5, 1.5)
	add_child(spr)

func _betal_ok() -> void:
	get_tree().change_scene_to_file("res://scenes/Return.tscn")

func _process(_delta: float) -> void:
	var lbl := get_node_or_null("TimerLabel")
	if lbl:
		lbl.text = GameState.get_tid_tekst()

func _tid_ute() -> void:
	GameState.fail_grunn = "Tiden er ute!"
	get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
