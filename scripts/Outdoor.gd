extends Node2D

const TILE := 32
const MAP_BREDDE := 80   # tiles
const MAP_HOYDE  := 18   # tiles
const KART_PX_BREDDE := MAP_BREDDE * TILE  # 2560

# Soner (i tile-koordinater x)
const SKOLE_X := 2
const VEI_START_X := 22
const VEI_SLUTT_X := 28
const BRO_Y_MIN := 3
const BRO_Y_MAX := 5
const REMA_X := 65

var spiller: CharacterBody2D
var mathias_node: Node2D
var kamera: Camera2D
var biler: Array = []
var spiller_ved_inngang: bool = false
var kolliderte_med_bil: bool = false
var bil_gruppe: Node2D

# Spillerdata
var spiller_hastighet: float = 160.0
var tilbake_til_x: float = 0.0  # for bilovertakling

func _ready() -> void:
	var kar = load("res://scripts/data/Karakterer.gd").new().KARAKTERER.get(GameState.karakter_id, {})
	if kar.has("hastighet"):
		spiller_hastighet = kar.hastighet

	_bygg_kart()
	_plasser_spiller()
	_plasser_mathias()
	_bygg_kamera()
	if GameState.vanskelighet == "vanskelig":
		_spawn_biler()
	_bygg_hud()

	GameState.timer_ferdig.connect(_tid_ute)

func _bygg_kart() -> void:
	# Bakgrunn-farger etter sone
	for tile_x in range(MAP_BREDDE):
		for tile_y in range(MAP_HOYDE):
			var px := tile_x * TILE
			var py := tile_y * TILE
			var farge := _tile_farge(tile_x, tile_y)
			var rect := ColorRect.new()
			rect.color = farge
			rect.position = Vector2(px, py)
			rect.size = Vector2(TILE, TILE)
			add_child(rect)

	# Rema-inngang (markert med rod stripe)
	var inngang := ColorRect.new()
	inngang.color = Color(0.8, 0.0, 0.0)
	inngang.position = Vector2(REMA_X * TILE, 5 * TILE)
	inngang.size = Vector2(TILE * 3, TILE * 6)
	add_child(inngang)

	var inngang_lbl := Label.new()
	inngang_lbl.text = "REMA\n1000"
	inngang_lbl.add_theme_font_size_override("font_size", 20)
	inngang_lbl.add_theme_color_override("font_color", Color.WHITE)
	inngang_lbl.position = Vector2(REMA_X * TILE + 10, 6 * TILE)
	add_child(inngang_lbl)

	# Skole-merking
	var skole_lbl := Label.new()
	skole_lbl.text = "GLEMMEN VGS"
	skole_lbl.add_theme_font_size_override("font_size", 14)
	skole_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	skole_lbl.position = Vector2(10, 100)
	add_child(skole_lbl)

func _tile_farge(tx: int, ty: int) -> Color:
	# Grass langs topp og bunn
	if ty < 2 or ty >= MAP_HOYDE - 2:
		return Color(0.36, 0.6, 0.25)
	# Vei (hard modus)
	if tx >= VEI_START_X and tx <= VEI_SLUTT_X:
		if GameState.vanskelighet == "vanskelig":
			return Color(0.3, 0.3, 0.3)
		else:
			# Bro i vanlig modus
			if ty >= BRO_Y_MIN and ty <= BRO_Y_MAX:
				return Color(0.55, 0.48, 0.38)
			return Color(0.35, 0.35, 0.35)
	# Fortau
	return Color(0.72, 0.72, 0.68)

func _plasser_spiller() -> void:
	spiller = CharacterBody2D.new()
	spiller.position = Vector2(SKOLE_X * TILE + TILE / 2, 9 * TILE)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	col.shape = shape
	spiller.add_child(col)

	var spr := Sprite2D.new()
	spr.name = "Sprite"
	var tex_key := "char_sondre"
	if GameState.karakter_id == "kristine": tex_key = "char_klasse_f"
	elif GameState.karakter_id == "hemmelig": tex_key = "char_kassedame"
	spr.texture = load("res://assets/" + tex_key + ".png")
	spr.scale = Vector2(0.35, 0.35)
	spiller.add_child(spr)

	add_child(spiller)
	tilbake_til_x = spiller.position.x

func _plasser_mathias() -> void:
	mathias_node = Node2D.new()
	mathias_node.position = spiller.position + Vector2(-80, 0)

	var spr := Sprite2D.new()
	spr.texture = load("res://assets/char_mathias.png")
	spr.scale = Vector2(0.32, 0.32)
	mathias_node.add_child(spr)

	var nav_lbl := Label.new()
	nav_lbl.text = "Mathias"
	nav_lbl.add_theme_font_size_override("font_size", 12)
	nav_lbl.add_theme_color_override("font_color", Color.WHITE)
	nav_lbl.position = Vector2(-25, -45)
	mathias_node.add_child(nav_lbl)

	add_child(mathias_node)

func _bygg_kamera() -> void:
	kamera = Camera2D.new()
	kamera.limit_left = 0
	kamera.limit_right = KART_PX_BREDDE
	kamera.limit_top = 0
	kamera.limit_bottom = MAP_HOYDE * TILE
	spiller.add_child(kamera)

func _spawn_biler() -> void:
	bil_gruppe = Node2D.new()
	add_child(bil_gruppe)

	var bil_rader := [4, 6, 8, 10]
	var retninger := [1, -1, 1, -1]
	var farter := [120, 90, 150, 80]
	var farger := [Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN]

	for i in range(4):
		for _j in range(3):
			var bil := ColorRect.new()
			bil.color = farger[i]
			bil.size = Vector2(48, 28)
			var start_x := randf_range(0, KART_PX_BREDDE) if retninger[i] == 1 else randf_range(0, KART_PX_BREDDE)
			bil.position = Vector2(start_x, bil_rader[i] * TILE + 2)
			bil.set_meta("fart", farter[i] * retninger[i])
			bil_gruppe.add_child(bil)
			biler.append(bil)

func _bygg_hud() -> void:
	# Timer (oeverst venstre, fast paa skjerm via CanvasLayer)
	var hud := CanvasLayer.new()
	add_child(hud)

	var timer_bg := ColorRect.new()
	timer_bg.color = Color(0.0, 0.0, 0.0, 0.7)
	timer_bg.position = Vector2(10, 10)
	timer_bg.size = Vector2(160, 48)
	hud.add_child(timer_bg)

	var timer_lbl := Label.new()
	timer_lbl.name = "TimerHUD"
	timer_lbl.text = GameState.get_tid_tekst()
	timer_lbl.add_theme_font_size_override("font_size", 28)
	timer_lbl.add_theme_color_override("font_color", Color.WHITE)
	timer_lbl.position = Vector2(20, 18)
	hud.add_child(timer_lbl)

	var hint := Label.new()
	hint.name = "HintLabel"
	hint.text = ""
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	hint.position = Vector2(480, 670)
	hud.add_child(hint)

func _process(delta: float) -> void:
	_oppdater_timer_hud()
	_beveg_spiller(delta)
	_oppdater_mathias()
	if GameState.vanskelighet == "vanskelig":
		_beveg_biler(delta)
		_sjekk_bil_kollisjon()
	_sjekk_rema_inngang()

func _oppdater_timer_hud() -> void:
	var lbl := get_node_or_null("TimerHUD")
	if lbl:
		lbl.text = GameState.get_tid_tekst()

func _beveg_spiller(delta: float) -> void:
	var fart := spiller_hastighet * GameState.get_hastighet_multiplikator()
	var retning := Vector2.ZERO

	if Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		retning.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		retning.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		retning.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		retning.x += 1

	if retning.length() > 0:
		retning = retning.normalized()

	spiller.velocity = retning * fart
	spiller.move_and_slide()

	# Behold innenfor kart
	spiller.position.x = clamp(spiller.position.x, 0, KART_PX_BREDDE)
	spiller.position.y = clamp(spiller.position.y, 16, (MAP_HOYDE - 1) * TILE)

	# Vanlig modus: bloker vei-sonen (bare bro er apen)
	if GameState.vanskelighet == "vanlig":
		var tx := int(spiller.position.x / TILE)
		var ty := int(spiller.position.y / TILE)
		if tx >= VEI_START_X and tx <= VEI_SLUTT_X:
			if ty < BRO_Y_MIN or ty > BRO_Y_MAX:
				spiller.position.x = (VEI_START_X - 1) * TILE

func _oppdater_mathias() -> void:
	var maal_x := spiller.position.x - 80
	var maal_y := spiller.position.y + 10
	mathias_node.position.x += (maal_x - mathias_node.position.x) * 0.08
	mathias_node.position.y += (maal_y - mathias_node.position.y) * 0.08

func _beveg_biler(delta: float) -> void:
	for bil in biler:
		var fart: float = bil.get_meta("fart")
		bil.position.x += fart * delta
		if fart > 0 and bil.position.x > KART_PX_BREDDE + 60:
			bil.position.x = -60
		elif fart < 0 and bil.position.x < -60:
			bil.position.x = KART_PX_BREDDE + 60

func _sjekk_bil_kollisjon() -> void:
	if kolliderte_med_bil:
		return
	var spiller_rect := Rect2(spiller.position - Vector2(12, 12), Vector2(24, 24))
	for bil in biler:
		var bil_rect := Rect2(bil.position, bil.size)
		if spiller_rect.intersects(bil_rect):
			kolliderte_med_bil = true
			_bil_treff()
			return

func _bil_treff() -> void:
	# Send tilbake til starten av veikryssingen
	var tween := create_tween()
	spiller.modulate = Color.RED
	tween.tween_property(spiller, "modulate", Color.WHITE, 0.5)
	spiller.position.x = (VEI_START_X - 2) * TILE
	await get_tree().create_timer(0.3).timeout
	kolliderte_med_bil = false

func _sjekk_rema_inngang() -> void:
	if spiller.position.x >= REMA_X * TILE:
		get_tree().change_scene_to_file("res://scenes/Store.tscn")

func _tid_ute() -> void:
	GameState.fail_grunn = "Tiden er ute!"
	get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
