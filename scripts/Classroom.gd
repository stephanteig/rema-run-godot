extends Node2D

const TILE := 64

var navarende_index: int = 0
var alle_akseptert: bool = false

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
	GameState.start_timer()
	GameState.timer_ferdig.connect(_tid_ute)
	await get_tree().create_timer(1.5).timeout
	_vis_neste_bestilling()

func _bygg_klasserom() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.22, 0.35, 0.28)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var gulv := ColorRect.new()
	gulv.color = Color(0.55, 0.45, 0.35)
	gulv.position = Vector2(0, 200)
	gulv.size = Vector2(1280, 520)
	add_child(gulv)

	var tavle_ramme := ColorRect.new()
	tavle_ramme.color = Color(0.4, 0.28, 0.18)
	tavle_ramme.position = Vector2(292, 32)
	tavle_ramme.size = Vector2(696, 156)
	add_child(tavle_ramme)

	var tavle := ColorRect.new()
	tavle.color = Color(0.1, 0.25, 0.15)
	tavle.position = Vector2(300, 40)
	tavle.size = Vector2(680, 140)
	add_child(tavle)

	for rad in range(3):
		for kol in range(5):
			var pult := ColorRect.new()
			pult.color = Color(0.6, 0.48, 0.3)
			pult.position = Vector2(100 + kol * 220, 280 + rad * 120)
			pult.size = Vector2(160, 60)
			add_child(pult)

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

	info_label = Label.new()
	info_label.text = ""
	info_label.add_theme_font_size_override("font_size", 20)
	info_label.add_theme_color_override("font_color", Color.WHITE)
	info_label.position = Vector2(400, 670)
	add_child(info_label)

	interaksjon_hint = Label.new()
	interaksjon_hint.text = "[E] Aksepter bestilling"
	interaksjon_hint.add_theme_font_size_override("font_size", 22)
	interaksjon_hint.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	interaksjon_hint.position = Vector2(450, 640)
	interaksjon_hint.visible = false
	add_child(interaksjon_hint)

func _plasser_karakterer() -> void:
	spiller_sprite = Sprite2D.new()
	var spr_tex: Texture2D
	match GameState.karakter_id:
		"kristine": spr_tex = load("res://assets/char_klasse_f.png")
		"hemmelig":  spr_tex = load("res://assets/char_kassedame.png")
		_:           spr_tex = load("res://assets/char_sondre.png")
	spiller_sprite.texture = spr_tex
	spiller_sprite.scale = Vector2(0.8, 0.8)
	spiller_sprite.position = Vector2(640, 500)
	add_child(spiller_sprite)

	var mathias := Sprite2D.new()
	mathias.texture = load("res://assets/char_mathias.png")
	mathias.scale = Vector2(0.8, 0.8)
	mathias.position = spiller_sprite.position + Vector2(90, 0)
	add_child(mathias)
	_legg_til_navnetag(mathias, "Mathias")

	laerer_sprite = Sprite2D.new()
	laerer_sprite.texture = load("res://assets/char_laerer.png")
	laerer_sprite.scale = Vector2(0.9, 0.9)
	laerer_sprite.position = Vector2(640, 160)
	add_child(laerer_sprite)

	var poses := [Vector2(200, 450), Vector2(850, 420), Vector2(500, 560)]
	var teksturer := ["char_klasse_f", "char_klasse_m", "char_klasse_f"]
	for i in range(3):
		var k := Sprite2D.new()
		k.texture = load("res://assets/" + teksturer[i] + ".png")
		k.scale = Vector2(0.75, 0.75)
		k.position = poses[i]
		k.modulate.a = 0.3
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
	var Varer = load("res://scripts/data/Varer.gd")
	GameState.min_drikke = Varer.tilfeldig_energidrikk()
	GameState.handleliste = Varer.generer_handleliste(GameState.min_drikke, 3)

func _vis_laerer_ballong(tekst: String) -> void:
	if laerer_ballong:
		laerer_ballong.queue_free()
	laerer_ballong = _lag_taleballong(tekst, laerer_sprite.position + Vector2(-80, -90))
	add_child(laerer_ballong)

func _vis_neste_bestilling() -> void:
	if navarende_index >= 3:
		_alle_akseptert()
		return

	var vare_index := navarende_index + 1
	if vare_index >= GameState.handleliste.size():
		_alle_akseptert()
		return

	var vare = GameState.handleliste[vare_index]
	var k_node: Sprite2D = klass_noder[navarende_index]
	k_node.modulate.a = 1.0

	if klass_ballonger[navarende_index] != null:
		klass_ballonger[navarende_index].queue_free()
	var ballong_tekst: String = "Kan du kjope\n" + str(vare.navn) + "?"
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
	var timer_lbl := get_node_or_null("TimerLabel")
	if timer_lbl:
		timer_lbl.text = GameState.get_tid_tekst()
		if GameState.tid_igjen < 30.0:
			timer_lbl.add_theme_color_override("font_color", Color.RED)
		elif GameState.tid_igjen < 120.0:
			timer_lbl.add_theme_color_override("font_color", Color.ORANGE)

func _unhandled_input(event: InputEvent) -> void:
	if alle_akseptert or navarende_index >= klass_noder.size():
		return
	var trykket: bool = Input.is_action_just_pressed("ui_accept") or \
		(event is InputEventKey and event.keycode == KEY_E and event.pressed and not event.echo)
	if trykket:
		_aksepter_bestilling()

func _aksepter_bestilling() -> void:
	navarende_index += 1
	_vis_neste_bestilling()

func _tid_ute() -> void:
	GameState.fail_grunn = "Tiden er ute!"
	get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
