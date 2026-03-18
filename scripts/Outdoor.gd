extends Node2D

const TILE := 32
const MAP_BREDDE := 80
const MAP_HOYDE  := 18
const KART_PX_BREDDE := MAP_BREDDE * TILE  # 2560

const SKOLE_X    := 2
const VEI_START_X := 22
const VEI_SLUTT_X := 28
const BRO_Y_MIN  := 3
const BRO_Y_MAX  := 5
const REMA_X     := 65

var spiller: CharacterBody2D
var mathias_node: Node2D
var kamera: Camera2D
var biler: Array = []
var kolliderte_med_bil: bool = false
var bil_gruppe: Node2D
var spiller_hastighet: float = 160.0

# Texture cache — last kvar tekstur berre éin gong
var _tex_cache: Dictionary = {}

func _ready() -> void:
	var kar: Dictionary = load("res://scripts/data/Karakterer.gd").new().KARAKTERER.get(GameState.karakter_id, {})
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

func _hent_tex(asset: String) -> Texture2D:
	if not _tex_cache.has(asset):
		_tex_cache[asset] = load("res://assets/" + asset + ".png")
	return _tex_cache[asset]

func _bygg_kart() -> void:
	# Forhaandslast alle tile-teksturar
	_hent_tex("tile_grass")
	_hent_tex("tile_pavement")
	_hent_tex("tile_road")
	_hent_tex("tile_bridge")

	for tile_x in range(MAP_BREDDE):
		for tile_y in range(MAP_HOYDE):
			_lag_tile_sprite(tile_x, tile_y)

	# Rema-markering
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

	var skole_lbl := Label.new()
	skole_lbl.text = "GLEMMEN VGS"
	skole_lbl.add_theme_font_size_override("font_size", 14)
	skole_lbl.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	skole_lbl.position = Vector2(10, 100)
	add_child(skole_lbl)

func _tile_asset(tx: int, ty: int) -> String:
	if ty < 2 or ty >= MAP_HOYDE - 2:
		return "tile_grass"
	if tx >= VEI_START_X and tx <= VEI_SLUTT_X:
		if GameState.vanskelighet == "vanlig" and ty >= BRO_Y_MIN and ty <= BRO_Y_MAX:
			return "tile_bridge"
		return "tile_road"
	return "tile_pavement"

func _lag_tile_sprite(tx: int, ty: int) -> void:
	var asset := _tile_asset(tx, ty)
	var tex: Texture2D = _hent_tex(asset)
	if not tex:
		var rect := ColorRect.new()
		rect.color = _tile_farge_fallback(tx, ty)
		rect.position = Vector2(tx * TILE, ty * TILE)
		rect.size = Vector2(TILE, TILE)
		add_child(rect)
		return
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.position = Vector2(tx * TILE + TILE / 2, ty * TILE + TILE / 2)
	spr.scale = Vector2(float(TILE) / tex.get_width(), float(TILE) / tex.get_height())
	add_child(spr)

func _tile_farge_fallback(tx: int, ty: int) -> Color:
	if ty < 2 or ty >= MAP_HOYDE - 2:
		return Color(0.36, 0.6, 0.25)
	if tx >= VEI_START_X and tx <= VEI_SLUTT_X:
		if GameState.vanskelighet == "vanskelig":
			return Color(0.3, 0.3, 0.3)
		if ty >= BRO_Y_MIN and ty <= BRO_Y_MAX:
			return Color(0.55, 0.48, 0.38)
		return Color(0.35, 0.35, 0.35)
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
	match GameState.karakter_id:
		"kristine": spr.texture = load("res://assets/char_klasse_f.png")
		"hemmelig":  spr.texture = load("res://assets/char_kassedame.png")
		_:           spr.texture = load("res://assets/char_sondre.png")
	spr.scale = Vector2(0.35, 0.35)
	spiller.add_child(spr)
	add_child(spiller)

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

	var bil_rader  := [4, 6, 8, 10]
	var retninger  := [1, -1, 1, -1]
	var farter     := [120.0, 90.0, 150.0, 80.0]
	var farger     := [Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN]

	for i in range(4):
		for _j in range(3):
			var bil := ColorRect.new()
			bil.color = farger[i]
			bil.size = Vector2(48, 28)
			bil.position = Vector2(randf_range(0.0, float(KART_PX_BREDDE)), bil_rader[i] * TILE + 2)
			bil.set_meta("fart", farter[i] * retninger[i])
			bil_gruppe.add_child(bil)
			biler.append(bil)

func _bygg_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
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
	hint.text = "Til REMA 1000 ->"
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
	var lbl := get_node_or_null("HUD/TimerHUD")
	if lbl:
		lbl.text = GameState.get_tid_tekst()

func _beveg_spiller(delta: float) -> void:
	var fart := spiller_hastighet * GameState.get_hastighet_multiplikator()
	var retning := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):    retning.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):  retning.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):  retning.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"): retning.x += 1
	if retning.length() > 0:
		retning = retning.normalized()
	spiller.velocity = retning * fart
	spiller.move_and_slide()
	spiller.position.x = clamp(spiller.position.x, 0.0, float(KART_PX_BREDDE))
	spiller.position.y = clamp(spiller.position.y, 16.0, float((MAP_HOYDE - 1) * TILE))

	if GameState.vanskelighet == "vanlig":
		var tx := int(spiller.position.x / TILE)
		var ty := int(spiller.position.y / TILE)
		if tx >= VEI_START_X and tx <= VEI_SLUTT_X:
			if ty < BRO_Y_MIN or ty > BRO_Y_MAX:
				spiller.position.x = float((VEI_START_X - 1) * TILE)

func _oppdater_mathias() -> void:
	mathias_node.position.x += (spiller.position.x - 80.0 - mathias_node.position.x) * 0.08
	mathias_node.position.y += (spiller.position.y + 10.0 - mathias_node.position.y) * 0.08

func _beveg_biler(delta: float) -> void:
	for bil in biler:
		var fart: float = bil.get_meta("fart")
		bil.position.x += fart * delta
		if fart > 0 and bil.position.x > KART_PX_BREDDE + 60:
			bil.position.x = -60.0
		elif fart < 0 and bil.position.x < -60:
			bil.position.x = float(KART_PX_BREDDE + 60)

func _sjekk_bil_kollisjon() -> void:
	if kolliderte_med_bil:
		return
	var spiller_rect := Rect2(spiller.position - Vector2(12, 12), Vector2(24, 24))
	for bil in biler:
		if spiller_rect.intersects(Rect2(bil.position, bil.size)):
			kolliderte_med_bil = true
			_bil_treff()
			return

func _bil_treff() -> void:
	spiller.modulate = Color.RED
	var tween := create_tween()
	tween.tween_property(spiller, "modulate", Color.WHITE, 0.5)
	spiller.position.x = float((VEI_START_X - 2) * TILE)
	await get_tree().create_timer(0.3).timeout
	kolliderte_med_bil = false

func _sjekk_rema_inngang() -> void:
	if spiller.position.x >= REMA_X * TILE:
		get_tree().change_scene_to_file("res://scenes/Store.tscn")

func _tid_ute() -> void:
	GameState.fail_grunn = "Tiden er ute!"
	get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
