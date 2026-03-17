extends Node2D

const TILE := 32
const MAP_BREDDE := 80
const MAP_HOYDE  := 18
const KART_PX := MAP_BREDDE * TILE

const SKOLE_MAAL_X := 3
const VEI_START_X := 22
const VEI_SLUTT_X := 28
const BRO_Y_MIN := 3
const BRO_Y_MAX := 5

var spiller: CharacterBody2D
var mathias_node: Node2D
var kamera: Camera2D
var biler: Array = []
var kolliderte_med_bil: bool = false
var spiller_hastighet := 160.0

func _ready() -> void:
	var kar = load("res://scripts/data/Karakterer.gd").new().KARAKTERER.get(GameState.karakter_id, {})
	if kar.has("hastighet"):
		spiller_hastighet = kar.hastighet

	_bygg_kart()
	_plasser_spiller()  # spawn ved Rema
	_plasser_mathias()
	_bygg_kamera()
	if GameState.vanskelighet == "vanskelig":
		_spawn_biler()
	_bygg_hud()

	GameState.timer_ferdig.connect(_tid_ute)

func _bygg_kart() -> void:
	for tile_x in range(MAP_BREDDE):
		for tile_y in range(MAP_HOYDE):
			var rect := ColorRect.new()
			rect.color = _tile_farge(tile_x, tile_y)
			rect.position = Vector2(tile_x * TILE, tile_y * TILE)
			rect.size = Vector2(TILE, TILE)
			add_child(rect)

	# Rema-markering
	var rema_lbl := Label.new()
	rema_lbl.text = "REMA\n1000"
	rema_lbl.add_theme_font_size_override("font_size", 18)
	rema_lbl.add_theme_color_override("font_color", Color.WHITE)
	rema_lbl.position = Vector2(65 * TILE, 7 * TILE)
	add_child(rema_lbl)

	# Skole-markering (maalet)
	var skole_lbl := Label.new()
	skole_lbl.text = "GLEMMEN\n(MAAL!)"
	skole_lbl.add_theme_font_size_override("font_size", 14)
	skole_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	skole_lbl.position = Vector2(5, 80)
	add_child(skole_lbl)

func _tile_farge(tx: int, ty: int) -> Color:
	if ty < 2 or ty >= MAP_HOYDE - 2: return Color(0.36, 0.6, 0.25)
	if tx >= VEI_START_X and tx <= VEI_SLUTT_X:
		if GameState.vanskelighet == "vanskelig": return Color(0.3, 0.3, 0.3)
		if ty >= BRO_Y_MIN and ty <= BRO_Y_MAX: return Color(0.55, 0.48, 0.38)
		return Color(0.35, 0.35, 0.35)
	return Color(0.72, 0.72, 0.68)

func _plasser_spiller() -> void:
	spiller = CharacterBody2D.new()
	spiller.position = Vector2(66 * TILE, 9 * TILE)  # Start ved Rema

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	col.shape = shape
	spiller.add_child(col)

	var spr := Sprite2D.new()
	var tex_key := "char_sondre"
	if GameState.karakter_id == "kristine": tex_key = "char_klasse_f"
	elif GameState.karakter_id == "hemmelig": tex_key = "char_kassedame"
	spr.texture = load("res://assets/" + tex_key + ".png")
	spr.scale = Vector2(0.35, 0.35)
	spiller.add_child(spr)
	add_child(spiller)

func _plasser_mathias() -> void:
	mathias_node = Node2D.new()
	mathias_node.position = spiller.position + Vector2(80, 0)
	var spr := Sprite2D.new()
	spr.texture = load("res://assets/char_mathias.png")
	spr.scale = Vector2(0.32, 0.32)
	mathias_node.add_child(spr)
	var lbl := Label.new()
	lbl.text = "Mathias"
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.position = Vector2(-25, -45)
	mathias_node.add_child(lbl)
	add_child(mathias_node)

func _bygg_kamera() -> void:
	kamera = Camera2D.new()
	kamera.limit_left = 0; kamera.limit_right = KART_PX
	kamera.limit_top = 0; kamera.limit_bottom = MAP_HOYDE * TILE
	spiller.add_child(kamera)

func _spawn_biler() -> void:
	var bil_rader := [4, 6, 8, 10]
	var retninger := [1, -1, 1, -1]
	for i in range(4):
		for _j in range(3):
			var bil := ColorRect.new()
			bil.color = [Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN][i]
			bil.size = Vector2(48, 28)
			bil.position = Vector2(randf_range(0, KART_PX), bil_rader[i] * TILE + 2)
			bil.set_meta("fart", [120.0, 90.0, 150.0, 80.0][i] * retninger[i])
			add_child(bil)
			biler.append(bil)

func _bygg_hud() -> void:
	var hud := CanvasLayer.new()
	add_child(hud)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7); bg.position = Vector2(10, 10); bg.size = Vector2(180, 48)
	hud.add_child(bg)
	var lbl := Label.new()
	lbl.name = "TimerHUD"; lbl.text = GameState.get_tid_tekst()
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.add_theme_color_override("font_color", Color.WHITE); lbl.position = Vector2(20, 18)
	hud.add_child(lbl)
	var hint := Label.new()
	hint.text = "Tilbake til skolen!"
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2)); hint.position = Vector2(450, 15)
	hud.add_child(hint)

func _process(delta: float) -> void:
	var hud_lbl := get_node_or_null("TimerHUD")
	if hud_lbl: hud_lbl.text = GameState.get_tid_tekst()

	var fart := spiller_hastighet * GameState.get_hastighet_multiplikator()
	var dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):    dir.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):  dir.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):  dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"): dir.x += 1
	if dir.length() > 0: dir = dir.normalized()
	spiller.velocity = dir * fart
	spiller.move_and_slide()
	spiller.position.x = clamp(spiller.position.x, 0, KART_PX)
	spiller.position.y = clamp(spiller.position.y, 16, (MAP_HOYDE - 1) * TILE)

	if GameState.vanskelighet == "vanlig":
		var tx := int(spiller.position.x / TILE)
		var ty := int(spiller.position.y / TILE)
		if tx >= VEI_START_X and tx <= VEI_SLUTT_X:
			if ty < BRO_Y_MIN or ty > BRO_Y_MAX:
				spiller.position.x = (VEI_SLUTT_X + 1) * TILE

	mathias_node.position.x += (spiller.position.x + 80 - mathias_node.position.x) * 0.08
	mathias_node.position.y += (spiller.position.y + 8  - mathias_node.position.y) * 0.08

	if GameState.vanskelighet == "vanskelig":
		for bil in biler:
			var f: float = bil.get_meta("fart")
			bil.position.x += f * delta
			if f > 0 and bil.position.x > KART_PX + 60: bil.position.x = -60
			elif f < 0 and bil.position.x < -60: bil.position.x = KART_PX + 60
		if not kolliderte_med_bil:
			var sr := Rect2(spiller.position - Vector2(12,12), Vector2(24,24))
			for bil in biler:
				if sr.intersects(Rect2(bil.position, bil.size)):
					kolliderte_med_bil = true
					spiller.modulate = Color.RED
					var tw := create_tween()
					tw.tween_property(spiller, "modulate", Color.WHITE, 0.5)
					spiller.position.x = (VEI_SLUTT_X + 2) * TILE
					await get_tree().create_timer(0.3).timeout
					kolliderte_med_bil = false
					break

	# Nadd skolen?
	if spiller.position.x <= SKOLE_MAAL_X * TILE:
		_tilbake_i_tide()

func _tilbake_i_tide() -> void:
	var tid_brukt := GameState.timer_maks - GameState.tid_igjen
	GameState.lagre_rekord(tid_brukt)
	GameState.stopp_timer()
	get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")

func _tid_ute() -> void:
	GameState.fail_grunn = "Tiden er ute!"
	get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
