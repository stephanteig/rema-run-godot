extends Node2D

var valgt_vanskelighet: String = "vanlig"
var valgt_karakter: String = "sondre"
var karakter_ids := ["sondre", "kristine", "hemmelig"]
var karakter_index := 0

# Last karakterdata én gang
var _alle_karakterer: Dictionary = load("res://scripts/data/Karakterer.gd").new().KARAKTERER

# UI-noder
var btn_vanlig: Button
var btn_vanskelig: Button
var karakter_label: Label
var karakter_beskrivelse: Label
var stat_fart_label: Label
var stat_flaks_label: Label
var karakter_sprite: TextureRect

func _ready() -> void:
	_bygg_ui()
	_oppdater_karakter_visning()

func _bygg_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.18)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var stripe := ColorRect.new()
	stripe.color = Color(0.8, 0.0, 0.0)
	stripe.size = Vector2(1280, 12)
	add_child(stripe)

	var tittel := Label.new()
	tittel.text = "REMA RUN"
	tittel.add_theme_font_size_override("font_size", 96)
	tittel.add_theme_color_override("font_color", Color.WHITE)
	tittel.position = Vector2(640 - 260, 50)
	add_child(tittel)

	var sub := Label.new()
	sub.text = "Energy Quest"
	sub.add_theme_font_size_override("font_size", 32)
	sub.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	sub.position = Vector2(640 - 100, 155)
	add_child(sub)

	# Vanskelighetsgrad
	var vansk_tittel := Label.new()
	vansk_tittel.text = "VANSKELIGHETSGRAD"
	vansk_tittel.add_theme_font_size_override("font_size", 22)
	vansk_tittel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vansk_tittel.position = Vector2(200, 230)
	add_child(vansk_tittel)

	btn_vanlig = _lag_knapp("VANLIG\n(Brorute + ID)", Vector2(200, 265), Color(0.0, 0.6, 0.2))
	btn_vanlig.pressed.connect(_velg_vanlig)
	add_child(btn_vanlig)

	btn_vanskelig = _lag_knapp("VANSKELIG\n(Bilrute, ingen ID)", Vector2(460, 265), Color(0.7, 0.1, 0.1))
	btn_vanskelig.pressed.connect(_velg_vanskelig)
	add_child(btn_vanskelig)

	_oppdater_vanskelighet_knapper()

	# Karaktervalg
	var kar_tittel := Label.new()
	kar_tittel.text = "VELG KARAKTER"
	kar_tittel.add_theme_font_size_override("font_size", 22)
	kar_tittel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	kar_tittel.position = Vector2(200, 390)
	add_child(kar_tittel)

	var pil_venstre := Button.new()
	pil_venstre.text = "<"
	pil_venstre.position = Vector2(200, 425)
	pil_venstre.size = Vector2(50, 60)
	pil_venstre.pressed.connect(_forrige_karakter)
	add_child(pil_venstre)

	var pil_hoyre := Button.new()
	pil_hoyre.text = ">"
	pil_hoyre.position = Vector2(530, 425)
	pil_hoyre.size = Vector2(50, 60)
	pil_hoyre.pressed.connect(_neste_karakter)
	add_child(pil_hoyre)

	karakter_sprite = TextureRect.new()
	karakter_sprite.position = Vector2(260, 415)
	karakter_sprite.size = Vector2(64, 96)
	karakter_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(karakter_sprite)

	karakter_label = Label.new()
	karakter_label.add_theme_font_size_override("font_size", 28)
	karakter_label.add_theme_color_override("font_color", Color.WHITE)
	karakter_label.position = Vector2(340, 420)
	add_child(karakter_label)

	karakter_beskrivelse = Label.new()
	karakter_beskrivelse.add_theme_font_size_override("font_size", 16)
	karakter_beskrivelse.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	karakter_beskrivelse.position = Vector2(340, 455)
	karakter_beskrivelse.size.x = 180.0
	karakter_beskrivelse.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(karakter_beskrivelse)

	stat_fart_label = Label.new()
	stat_fart_label.add_theme_font_size_override("font_size", 16)
	stat_fart_label.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	stat_fart_label.position = Vector2(340, 495)
	add_child(stat_fart_label)

	stat_flaks_label = Label.new()
	stat_flaks_label.add_theme_font_size_override("font_size", 16)
	stat_flaks_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	stat_flaks_label.position = Vector2(340, 515)
	add_child(stat_flaks_label)

	var start_btn := _lag_knapp("START ->", Vector2(490, 620), Color(0.8, 0.0, 0.0))
	start_btn.size = Vector2(300, 70)
	start_btn.add_theme_font_size_override("font_size", 32)
	start_btn.pressed.connect(_start_spill)
	add_child(start_btn)

	var bunn := Label.new()
	bunn.text = "Glemmen VGS - Medieproduksjon"
	bunn.add_theme_font_size_override("font_size", 14)
	bunn.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	bunn.position = Vector2(640 - 140, 700)
	add_child(bunn)

func _lag_knapp(tekst: String, pos: Vector2, farge: Color) -> Button:
	var btn := Button.new()
	btn.text = tekst
	btn.position = pos
	btn.size = Vector2(240, 80)
	btn.add_theme_font_size_override("font_size", 20)
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = farge
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_left = 8
	stylebox.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", stylebox)
	var stylebox_hover := stylebox.duplicate() as StyleBoxFlat
	stylebox_hover.bg_color = farge.lightened(0.2)
	btn.add_theme_stylebox_override("hover", stylebox_hover)
	return btn

func _velg_vanlig() -> void:
	valgt_vanskelighet = "vanlig"
	_oppdater_vanskelighet_knapper()

func _velg_vanskelig() -> void:
	valgt_vanskelighet = "vanskelig"
	_oppdater_vanskelighet_knapper()

func _oppdater_vanskelighet_knapper() -> void:
	if not btn_vanlig or not btn_vanskelig:
		return
	btn_vanlig.modulate.a = 1.0 if valgt_vanskelighet == "vanlig" else 0.45
	btn_vanskelig.modulate.a = 1.0 if valgt_vanskelighet == "vanskelig" else 0.45

func _forrige_karakter() -> void:
	karakter_index = (karakter_index - 1 + karakter_ids.size()) % karakter_ids.size()
	valgt_karakter = karakter_ids[karakter_index]
	_oppdater_karakter_visning()

func _neste_karakter() -> void:
	karakter_index = (karakter_index + 1) % karakter_ids.size()
	valgt_karakter = karakter_ids[karakter_index]
	_oppdater_karakter_visning()

func _oppdater_karakter_visning() -> void:
	var kar: Dictionary = _alle_karakterer.get(valgt_karakter, _alle_karakterer["sondre"])
	karakter_label.text = kar.navn
	karakter_beskrivelse.text = kar.beskrivelse
	stat_fart_label.text  = "Fart:  " + "*".repeat(kar.stat_fart)  + "-".repeat(5 - kar.stat_fart)
	stat_flaks_label.text = "Flaks: " + "*".repeat(kar.stat_flaks) + "-".repeat(5 - kar.stat_flaks)

	var tex_path := "res://assets/char_sondre.png"
	if valgt_karakter == "kristine":
		tex_path = "res://assets/char_klasse_f.png"
	elif valgt_karakter == "hemmelig":
		tex_path = "res://assets/char_kassedame.png"
	var tex = load(tex_path)
	if tex:
		karakter_sprite.texture = tex

func _start_spill() -> void:
	GameState.vanskelighet = valgt_vanskelighet
	GameState.karakter_id = valgt_karakter
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/Classroom.tscn")
