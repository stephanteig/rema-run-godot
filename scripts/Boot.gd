extends Node2D

func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.18)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var lbl := Label.new()
	lbl.text = "Laster..."
	lbl.add_theme_font_size_override("font_size", 48)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.position = Vector2(580, 330)
	add_child(lbl)

	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
