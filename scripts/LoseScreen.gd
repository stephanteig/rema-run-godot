extends Node2D

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.18, 0.05, 0.05)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var tittel := Label.new()
	tittel.text = GameState.fail_grunn if GameState.fail_grunn != "" else "For sent!"
	tittel.add_theme_font_size_override("font_size", 72)
	tittel.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
	tittel.position = Vector2(640 - 350, 160)
	add_child(tittel)

	var min_tap := int(GameState.tid_igjen / 60)
	var sek_tap := int(GameState.tid_igjen) % 60
	var tid_igjen_lbl := Label.new()
	tid_igjen_lbl.text = "Tid igjen da du tapte: %02d:%02d" % [min_tap, sek_tap]
	tid_igjen_lbl.add_theme_font_size_override("font_size", 28)
	tid_igjen_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	tid_igjen_lbl.position = Vector2(640 - 230, 300)
	add_child(tid_igjen_lbl)

	var hint := Label.new()
	hint.text = "Oev deg litt... eller velg lettere vanskelighetsgrad"
	hint.add_theme_font_size_override("font_size", 20)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	hint.position = Vector2(640 - 310, 380)
	add_child(hint)

	var btn := _lag_knapp("Prov igjen", Vector2(520, 530))
	btn.pressed.connect(func():
		GameState.reset()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	add_child(btn)

func _lag_knapp(tekst: String, pos: Vector2) -> Button:
	var btn := Button.new()
	btn.text = tekst
	btn.position = pos
	btn.size = Vector2(240, 70)
	btn.add_theme_font_size_override("font_size", 26)
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.8, 0.0, 0.0)
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8
	s.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", s)
	return btn
