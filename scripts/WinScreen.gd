extends Node2D

func _ready() -> void:
	var tid_brukt := GameState.timer_maks - GameState.tid_igjen
	var er_rekord := (GameState.personlig_rekord > 0 and tid_brukt <= GameState.personlig_rekord)

	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.18, 0.1)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	# Tittel
	var tittel := Label.new()
	tittel.text = "Tilbake i tide!"
	tittel.add_theme_font_size_override("font_size", 72)
	tittel.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	tittel.position = Vector2(640 - 320, 80)
	add_child(tittel)

	# Ny rekord
	if er_rekord:
		var rekord_lbl := Label.new()
		rekord_lbl.text = "NY REKORD!"
		rekord_lbl.add_theme_font_size_override("font_size", 48)
		rekord_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		rekord_lbl.position = Vector2(640 - 180, 170)
		add_child(rekord_lbl)

	# Tid
	var min_igjen := int(GameState.tid_igjen) / 60
	var sek_igjen := int(GameState.tid_igjen) % 60
	var tid_lbl := Label.new()
	tid_lbl.text = "Tid igjen: %02d:%02d" % [min_igjen, sek_igjen]
	tid_lbl.add_theme_font_size_override("font_size", 36)
	tid_lbl.add_theme_color_override("font_color", Color.WHITE)
	tid_lbl.position = Vector2(640 - 150, 240)
	add_child(tid_lbl)

	if GameState.personlig_rekord > 0:
		var pr_min := int(GameState.personlig_rekord) / 60
		var pr_sek := int(GameState.personlig_rekord) % 60
		var pr_lbl := Label.new()
		pr_lbl.text = "Personlig rekord: %02d:%02d" % [pr_min, pr_sek]
		pr_lbl.add_theme_font_size_override("font_size", 22)
		pr_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		pr_lbl.position = Vector2(640 - 155, 295)
		add_child(pr_lbl)

	# Vareliste
	var liste_tittel := Label.new()
	liste_tittel.text = "Kjopte varer:"
	liste_tittel.add_theme_font_size_override("font_size", 22)
	liste_tittel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	liste_tittel.position = Vector2(400, 340)
	add_child(liste_tittel)

	for i in range(GameState.handleliste.size()):
		var vare = GameState.handleliste[i]
		var lbl := Label.new()
		lbl.text = ("[OK] " if vare.hentet else "[--] ") + vare.navn
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.add_theme_color_override("font_color", Color(0.5,0.9,0.5) if vare.hentet else Color(0.9,0.4,0.4))
		lbl.position = Vector2(400, 370 + i * 28)
		add_child(lbl)

	# Spill igjen-knapp
	var btn := _lag_knapp("Spill igjen", Vector2(350, 600))
	btn.pressed.connect(func():
		GameState.reset()
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	add_child(btn)

func _lag_knapp(tekst: String, pos: Vector2) -> Button:
	var btn := Button.new()
	btn.text = tekst; btn.position = pos; btn.size = Vector2(240, 70)
	btn.add_theme_font_size_override("font_size", 26)
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.8, 0.0, 0.0)
	s.corner_radius_top_left = 8; s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8; s.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", s)
	var sh := s.duplicate() as StyleBoxFlat
	sh.bg_color = Color(1.0, 0.2, 0.2)
	btn.add_theme_stylebox_override("hover", sh)
	return btn
