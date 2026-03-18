extends Node2D

const TILE := 32
const MAP_BREDDE := 80
const MAP_HOYDE  := 18
const KART_PX := MAP_BREDDE * TILE  # 2560

const SKOLE_MAAL_X := 3
const VEI_START_X  := 22
const VEI_SLUTT_X  := 28
const BRO_Y_MIN    := 3
const BRO_Y_MAX    := 5

var spiller: CharacterBody2D
var mathias_node: Node2D
var kamera: Camera2D
var biler: Array = []
var kolliderte_med_bil: bool = false
var spiller_hastighet := 160.0

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
	_hent_tex("tile_grass")
	_hent_tex("tile_pavement")
	_hent_tex("tile_road")
	_hent_tex("tile_bridge")

	for tile_x in range(MAP_BREDDE):
		for tile_y in range(MAP_HOYDE):
			_lag_tile_sprite(tile_x, tile_y)

	var rema_lbl := Label.new()
	rema_lbl.text = "REMA\n1000"
	rema_lbl.add_theme_font_size_override("font_size", 18)
	rema_lbl.add_theme_color_override("font_color", Color.WHITE)
	rema_lbl.position = Vector2(65 * TILE, 7 * TILE)
	add_child(rema_lbl)

	var skole_lbl := Label.new()
	skole_lbl.text = "GLEMMEN\n(MAAL!)"
	skole_lbl.add_theme_font_size_override("font_size", 14)
	skole_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	skole_lbl.position = Vector2(5, 80)
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
	spiller.position = Vector2(66 * TILE, 9 * TILE)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(24, 24)
	col.shape = shape
	spiller.add_child(col)

	var anim_spr := AnimatedSprite2D.new()
	anim_spr.name = "AnimatedSprite2D"
	var frames := SpriteFrames.new()
	frames.add_animation("walk")
	frames.add_animation("idle")

	if GameState.karakter_id == "sondre" or GameState.karakter_id == "":
		var sheet := load("res://assets/char_sondre_walk_sheet.png")
		for i in range(4):
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(i * 64, 0, 64, 96)
			frames.add_frame("walk", atlas)
		var idle_atlas := AtlasTexture.new()
		idle_atlas.atlas = sheet
		idle_atlas.region = Rect2(0, 0, 64, 96)
		frames.add_frame("idle", idle_atlas)
	else:
		var tex: Texture2D
		match GameState.karakter_id:
			"kristine": tex = load("res://assets/char_klasse_f.png")
			"hemmelig":  tex = load("res://assets/char_kassedame.png")
			_:           tex = load("res://assets/char_sondre.png")
		frames.add_frame("walk", tex)
		frames.add_frame("idle", tex)

	frames.set_animation_speed("walk", 8)
	frames.set_animation_speed("idle", 1)
	anim_spr.sprite_frames = frames
	anim_spr.scale = Vector2(0.35, 0.35)
	spiller.add_child(anim_spr)
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
	kamera.limit_left = 0
	kamera.limit_right = KART_PX
	kamera.limit_top = 0
	kamera.limit_bottom = MAP_HOYDE * TILE
	spiller.add_child(kamera)

func _spawn_biler() -> void:
	var bil_rader  := [4, 6, 8, 10]
	var retninger  := [1, -1, 1, -1]
	var farter     := [120.0, 90.0, 150.0, 80.0]
	var farger     := [Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN]

	for i in range(4):
		for _j in range(3):
			var bil := ColorRect.new()
			bil.color = farger[i]
			bil.size = Vector2(48, 28)
			bil.position = Vector2(randf_range(0.0, float(KART_PX)), bil_rader[i] * TILE + 2)
			bil.set_meta("fart", farter[i] * retninger[i])
			add_child(bil)
			biler.append(bil)

func _bygg_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.position = Vector2(10, 10)
	bg.size = Vector2(180, 48)
	hud.add_child(bg)

	var lbl := Label.new()
	lbl.name = "TimerHUD"
	lbl.text = GameState.get_tid_tekst()
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.position = Vector2(20, 18)
	hud.add_child(lbl)

	var hint := Label.new()
	hint.text = "<- Tilbake til skolen!"
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	hint.position = Vector2(450, 15)
	hud.add_child(hint)

func _process(delta: float) -> void:
	_oppdater_timer_hud()
	_beveg_spiller(delta)
	_oppdater_mathias()
	if GameState.vanskelighet == "vanskelig":
		_beveg_biler(delta)
		_sjekk_bil_kollisjon()
	if spiller.position.x <= SKOLE_MAAL_X * TILE:
		_tilbake_i_tide()

func _oppdater_timer_hud() -> void:
	var lbl := get_node_or_null("HUD/TimerHUD")
	if lbl:
		lbl.text = GameState.get_tid_tekst()

func _beveg_spiller(delta: float) -> void:
	var fart := spiller_hastighet * GameState.get_hastighet_multiplikator()
	var dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):    dir.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):  dir.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):  dir.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"): dir.x += 1
	if dir.length() > 0:
		dir = dir.normalized()
	spiller.velocity = dir * fart
	spiller.move_and_slide()
	spiller.position.x = clamp(spiller.position.x, 0.0, float(KART_PX))
	spiller.position.y = clamp(spiller.position.y, 16.0, float((MAP_HOYDE - 1) * TILE))

	var anim := spiller.get_node_or_null("AnimatedSprite2D")
	if anim:
		if spiller.velocity.length() > 0:
			if not anim.is_playing() or anim.animation != "walk":
				anim.play("walk")
		else:
			anim.play("idle")

	if GameState.vanskelighet == "vanlig":
		var tx := int(spiller.position.x / TILE)
		var ty := int(spiller.position.y / TILE)
		if tx >= VEI_START_X and tx <= VEI_SLUTT_X:
			if ty < BRO_Y_MIN or ty > BRO_Y_MAX:
				spiller.position.x = float((VEI_SLUTT_X + 1) * TILE)

func _oppdater_mathias() -> void:
	mathias_node.position.x += (spiller.position.x + 80.0 - mathias_node.position.x) * 0.08
	mathias_node.position.y += (spiller.position.y + 8.0  - mathias_node.position.y) * 0.08

func _beveg_biler(delta: float) -> void:
	for bil in biler:
		var f: float = bil.get_meta("fart")
		bil.position.x += f * delta
		if f > 0 and bil.position.x > KART_PX + 60:
			bil.position.x = -60.0
		elif f < 0 and bil.position.x < -60:
			bil.position.x = float(KART_PX + 60)

func _sjekk_bil_kollisjon() -> void:
	if kolliderte_med_bil:
		return
	var sr := Rect2(spiller.position - Vector2(12, 12), Vector2(24, 24))
	for bil in biler:
		if sr.intersects(Rect2(bil.position, bil.size)):
			kolliderte_med_bil = true
			_bil_treff()
			return

func _bil_treff() -> void:
	spiller.modulate = Color.RED
	var tw := create_tween()
	tw.tween_property(spiller, "modulate", Color.WHITE, 0.5)
	spiller.position.x = float((VEI_SLUTT_X + 2) * TILE)
	await get_tree().create_timer(0.3).timeout
	kolliderte_med_bil = false

func _tilbake_i_tide() -> void:
	var tid_brukt := GameState.timer_maks - GameState.tid_igjen
	GameState.lagre_rekord(tid_brukt)
	GameState.stopp_timer()
	get_tree().change_scene_to_file("res://scenes/WinScreen.tscn")

func _tid_ute() -> void:
	GameState.fail_grunn = "Tiden er ute!"
	get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
