extends Node2D

const TILE := 32
const KOLS := 40
const RADER := 20

var soner := {}
var powerup_sprites := []
var exclamation_sprites: Dictionary = {}

var spiller: CharacterBody2D
var mathias_node: Node2D
var kamera: Camera2D
var spiller_hastighet := 160.0

var i_sone: String = ""
var meksikaner_node: Node2D = null

func _ready() -> void:
	var kar: Dictionary = load("res://scripts/data/Karakterer.gd").new().KARAKTERER.get(GameState.karakter_id, {})
	if kar.has("hastighet"):
		spiller_hastighet = kar.hastighet

	_bygg_butikk()
	_plasser_spiller()
	_plasser_mathias()
	_bygg_kamera()
	_plasser_powerups()
	_bygg_hud()
	GameState.timer_ferdig.connect(_tid_ute)

func _bygg_butikk() -> void:
	# Gulv — skiftervis tile_floor_store og tile_floor_store_alt (sjakkbrettmønster)
	for x in range(KOLS):
		for y in range(RADER):
			var floor_key := "tile_floor_store" if (x + y) % 2 == 0 else "tile_floor_store_alt"
			_lag_tile_bilde(x, y, floor_key)

	# Vegger
	for x in range(KOLS):
		_lag_tile_bilde(x, 0, "tile_wall_store")
		_lag_tile_bilde(x, RADER - 1, "tile_wall_store")
	for y in range(1, RADER - 1):
		_lag_tile_bilde(0, y, "tile_wall_store")
		_lag_tile_bilde(KOLS - 1, y, "tile_wall_store")

	# Kjoleskap (venstre, x=1)
	for y in range(1, 4):
		_lag_tile_bilde(1, y, "tile_fridge_brus")
	_lag_sone_rect("Brus", 1, 1, 2, 3)

	for y in range(4, 9):
		_lag_tile_bilde(1, y, "tile_fridge_energi")
	_lag_sone_rect("Energidrikker", 1, 4, 2, 8)

	# Topp hyller
	for x in range(5, 12):
		_lag_tile_bilde(x, 1, "tile_zone_notter")
	_lag_sone_rect("Nøtter", 5, 1, 11, 2)

	for x in range(12, 28):
		_lag_tile_bilde(x, 1, "tile_zone_snacks")
	_lag_sone_rect("Snacks", 12, 1, 27, 2)

	for x in range(28, 35):
		_lag_tile_bilde(x, 1, "tile_zone_brod")

	# U-form hyller (midten)
	for x in range(8, 18):
		_lag_tile_bilde(x, 5, "tile_shelf_horiz")
		_lag_tile_bilde(x, 10, "tile_shelf_horiz")
	for y in range(5, 11):
		_lag_tile_bilde(8, y, "tile_shelf_vert")
		_lag_tile_bilde(17, y, "tile_shelf_vert")

	# Tyggis (innsiden av venstre arm)
	for y in range(6, 10):
		_lag_tile_bilde(9, y, "tile_zone_tyggis")
	_lag_sone_rect("Tyggis", 9, 6, 10, 9)

	# Bunn av U (dekorativt gulv)
	for x in range(10, 16):
		_lag_tile(x, 9, Color(0.65, 0.55, 0.42))

	# DAGLIGVARER-tekst
	var dag_lbl := Label.new()
	dag_lbl.text = "DAGLIGVARER"
	dag_lbl.add_theme_font_size_override("font_size", 14)
	dag_lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	dag_lbl.position = Vector2(10 * TILE, 7 * TILE)
	add_child(dag_lbl)

	# Baguette sone
	for x in range(24, 28):
		_lag_tile_bilde(x, 7, "tile_zone_baguette")
	_lag_sone_rect("Baguetter", 24, 7, 27, 8)

	# Kasser (nede til venstre)
	_lag_tile_bilde(3, 16, "tile_kasse_open")
	var kassedame := Sprite2D.new()
	kassedame.texture = load("res://assets/char_kassedame.png")
	kassedame.scale = Vector2(0.45, 0.45)
	kassedame.position = Vector2(3 * TILE + 16, 15 * TILE)
	add_child(kassedame)
	for x in range(5, 9):
		_lag_tile_bilde(x, 16, "tile_kasse_closed")

	# Inngang (bunn)
	for x in range(19, 22):
		_lag_tile_bilde(x, RADER - 1, "tile_entrance")

func _lag_tile(tx: int, ty: int, farge: Color) -> void:
	var rect := ColorRect.new()
	rect.color = farge
	rect.position = Vector2(tx * TILE, ty * TILE)
	rect.size = Vector2(TILE, TILE)
	add_child(rect)

func _lag_tile_bilde(tx: int, ty: int, asset_key: String) -> void:
	var tex = load("res://assets/" + asset_key + ".png")
	if not tex:
		_lag_tile(tx, ty, Color(0.5, 0.5, 0.8))
		return
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.position = Vector2(tx * TILE + TILE / 2, ty * TILE + TILE / 2)
	spr.scale = Vector2(float(TILE) / spr.texture.get_width(), float(TILE) / spr.texture.get_height())
	add_child(spr)

func _lag_sone_rect(kategori: String, x1: int, y1: int, x2: int, y2: int) -> void:
	soner[kategori] = Rect2(x1 * TILE, y1 * TILE, (x2 - x1 + 1) * TILE, (y2 - y1 + 1) * TILE)

func _plasser_spiller() -> void:
	spiller = CharacterBody2D.new()
	spiller.position = Vector2(20 * TILE, (RADER - 2) * TILE)

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 20)
	col.shape = shape
	spiller.add_child(col)

	var spr := Sprite2D.new()
	match GameState.karakter_id:
		"kristine": spr.texture = load("res://assets/char_klasse_f.png")
		"hemmelig":  spr.texture = load("res://assets/char_kassedame.png")
		_:           spr.texture = load("res://assets/char_sondre.png")
	spr.scale = Vector2(0.32, 0.32)
	spiller.add_child(spr)
	add_child(spiller)

func _plasser_mathias() -> void:
	mathias_node = Node2D.new()
	mathias_node.position = spiller.position + Vector2(-60, 0)

	var spr := Sprite2D.new()
	spr.texture = load("res://assets/char_mathias.png")
	spr.scale = Vector2(0.30, 0.30)
	mathias_node.add_child(spr)

	var lbl := Label.new()
	lbl.text = "Mathias"
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.position = Vector2(-22, -40)
	mathias_node.add_child(lbl)
	add_child(mathias_node)

func _bygg_kamera() -> void:
	kamera = Camera2D.new()
	kamera.limit_left = 0
	kamera.limit_right = KOLS * TILE
	kamera.limit_top = 0
	kamera.limit_bottom = RADER * TILE
	spiller.add_child(kamera)

func _plasser_powerups() -> void:
	var powerup_data := [
		{"asset": "item_energy_can_powerup", "pos": Vector2(6 * TILE, 13 * TILE),  "type": "speed"},
		{"asset": "item_id_kort",            "pos": Vector2(14 * TILE, 13 * TILE), "type": "id"},
		{"asset": "item_baguette",           "pos": Vector2(22 * TILE, 12 * TILE), "type": "baguette"},
		{"asset": "item_beast_potion",       "pos": Vector2(30 * TILE, 8 * TILE),  "type": "beast"},
	]
	for p in powerup_data:
		var spr := Sprite2D.new()
		spr.texture = load("res://assets/" + p.asset + ".png")
		spr.scale = Vector2(0.7, 0.7)
		spr.position = p.pos
		spr.set_meta("powerup_type", p.type)
		spr.set_meta("aktiv", true)
		add_child(spr)
		powerup_sprites.append(spr)

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

	var liste_bg := ColorRect.new()
	liste_bg.color = Color(0.1, 0.1, 0.15, 0.92)
	liste_bg.position = Vector2(1070, 10)
	liste_bg.size = Vector2(200, 260)
	hud.add_child(liste_bg)

	var liste_tittel := Label.new()
	liste_tittel.text = "HANDLELISTE"
	liste_tittel.add_theme_font_size_override("font_size", 14)
	liste_tittel.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	liste_tittel.position = Vector2(1078, 16)
	hud.add_child(liste_tittel)

	_oppdater_handleliste_hud(hud)

	var hint := Label.new()
	hint.name = "Hint"
	hint.text = ""
	hint.add_theme_font_size_override("font_size", 20)
	hint.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	hint.position = Vector2(400, 665)
	hud.add_child(hint)

	var feedback := Label.new()
	feedback.name = "Feedback"
	feedback.text = ""
	feedback.add_theme_font_size_override("font_size", 24)
	feedback.add_theme_color_override("font_color", Color(0.2, 1.0, 0.3))
	feedback.position = Vector2(400, 620)
	hud.add_child(feedback)

func _oppdater_handleliste_hud(hud: CanvasLayer) -> void:
	for child in hud.get_children():
		if child.name.begins_with("Vare_"):
			child.queue_free()

	var y_start := 38
	for i in range(GameState.handleliste.size()):
		var vare = GameState.handleliste[i]
		var lbl := Label.new()
		lbl.name = "Vare_" + str(i)
		lbl.text = ("[X] " if vare.hentet else "[ ] ") + str(vare.navn)
		lbl.add_theme_font_size_override("font_size", 13)
		var farge: Color
		if vare.get("er_min", false):
			farge = Color(0.5, 0.9, 0.5) if vare.hentet else Color(1.0, 0.4, 0.4)
		else:
			farge = Color(0.5, 0.9, 0.5) if vare.hentet else Color.WHITE
		lbl.add_theme_color_override("font_color", farge)
		lbl.position = Vector2(1078, y_start + i * 22)
		lbl.size.x = 190.0
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hud.add_child(lbl)

func _process(delta: float) -> void:
	_oppdater_timer()
	_beveg_spiller(delta)
	_oppdater_mathias()
	_oppdater_exclamation()
	_sjekk_sone()
	_sjekk_powerups()

func _oppdater_timer() -> void:
	var lbl := get_node_or_null("HUD/TimerHUD")
	if not lbl:
		return
	lbl.text = GameState.get_tid_tekst()
	if GameState.tid_igjen < 30.0:
		lbl.add_theme_color_override("font_color", Color.RED)
	elif GameState.tid_igjen < 120.0:
		lbl.add_theme_color_override("font_color", Color.ORANGE)

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
	spiller.position.x = clamp(spiller.position.x, float(TILE), float((KOLS - 1) * TILE))
	spiller.position.y = clamp(spiller.position.y, float(TILE), float((RADER - 1) * TILE))

func _oppdater_mathias() -> void:
	mathias_node.position.x += (spiller.position.x - 60.0 - mathias_node.position.x) * 0.08
	mathias_node.position.y += (spiller.position.y + 8.0 - mathias_node.position.y) * 0.08

func _sjekk_sone() -> void:
	i_sone = ""
	var spiller_rect := Rect2(spiller.position - Vector2(12, 12), Vector2(24, 24))
	for kat in soner:
		if soner[kat].intersects(spiller_rect):
			i_sone = kat
			break

	var hud := get_node_or_null("HUD")
	if not hud:
		return
	var hint := hud.get_node_or_null("Hint")
	if not hint:
		return
	if i_sone != "" and _har_vare_fra_kategori(i_sone):
		hint.text = "[E] Hent " + i_sone
	elif _er_ved_kasse() and GameState.alle_varer_hentet():
		hint.text = "[E] Ga til kassen"
	else:
		hint.text = ""

func _har_vare_fra_kategori(kat: String) -> bool:
	for vare in GameState.handleliste:
		if vare.kategori == kat and not vare.hentet:
			return true
	return false

func _unhandled_input(event: InputEvent) -> void:
	var e_drukt: bool = Input.is_action_just_pressed("ui_accept") or \
		(event is InputEventKey and event.keycode == KEY_E and event.pressed and not event.echo)
	if not e_drukt:
		return
	if i_sone != "":
		_hent_vare_fra_sone(i_sone)
	elif _er_ved_kasse():
		_gaa_til_kasse()

func _oppdater_exclamation() -> void:
	for kat in soner:
		var har_vare := _har_vare_fra_kategori(kat)
		var sone_rect: Rect2 = soner[kat]
		var sone_senter := sone_rect.position + sone_rect.size / 2

		if not exclamation_sprites.has(kat):
			var spr := Sprite2D.new()
			spr.texture = load("res://assets/ui_exclamation.png")
			spr.scale = Vector2(1.2, 1.2)
			spr.position = sone_senter + Vector2(0, -36)
			add_child(spr)
			exclamation_sprites[kat] = spr

		var spr: Sprite2D = exclamation_sprites[kat]
		var spiller_rect := Rect2(spiller.position - Vector2(60, 60), Vector2(120, 120))
		var naer_nok := spiller_rect.intersects(sone_rect)

		if har_vare and naer_nok:
			spr.visible = true
			spr.position.y = (sone_senter.y - 36) + sin(Time.get_ticks_msec() / 200.0) * 4.0
		else:
			spr.visible = false

func _hent_vare_fra_sone(kategori: String) -> void:
	for vare in GameState.handleliste:
		if vare.kategori == kategori and not vare.hentet:
			vare.hentet = true
			if exclamation_sprites.has(kategori):
				exclamation_sprites[kategori].visible = false
			_vis_feedback(str(vare.navn) + " hentet!")
			_oppdater_handleliste_hud(get_node("HUD"))
			if vare.navn == "Egg og reke":
				_spawn_meksikaner()
			return

func _vis_feedback(tekst: String) -> void:
	var hud := get_node_or_null("HUD")
	if not hud:
		return
	var lbl := hud.get_node_or_null("Feedback")
	if lbl:
		lbl.text = tekst
		lbl.modulate.a = 1.0
		var tween := create_tween()
		tween.tween_property(lbl, "modulate:a", 0.0, 2.0)

func _spawn_meksikaner() -> void:
	if meksikaner_node:
		meksikaner_node.queue_free()
	meksikaner_node = Node2D.new()
	meksikaner_node.position = Vector2(26 * TILE, 7 * TILE)

	var spr := Sprite2D.new()
	spr.texture = load("res://assets/char_meksikaner.png")
	spr.scale = Vector2(0.55, 0.55)
	meksikaner_node.add_child(spr)

	var ballong := Label.new()
	ballong.text = "Ay caramba!"
	ballong.add_theme_font_size_override("font_size", 18)
	ballong.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	ballong.position = Vector2(-30, -70)
	meksikaner_node.add_child(ballong)
	add_child(meksikaner_node)

	var tween := create_tween()
	tween.tween_property(meksikaner_node, "rotation", TAU, 3.0)
	tween.tween_callback(meksikaner_node.queue_free)

func _sjekk_powerups() -> void:
	var spiller_rect := Rect2(spiller.position - Vector2(16, 16), Vector2(32, 32))
	for pu in powerup_sprites:
		if not pu.get_meta("aktiv"):
			continue
		var pu_rect := Rect2(pu.position - Vector2(16, 16), Vector2(32, 32))
		if spiller_rect.intersects(pu_rect):
			_plukk_opp_powerup(pu)

func _plukk_opp_powerup(pu: Sprite2D) -> void:
	var type: String = pu.get_meta("powerup_type")
	pu.set_meta("aktiv", false)
	pu.visible = false
	var tid_na := Time.get_ticks_msec() / 1000.0
	match type:
		"speed":
			GameState.speed_boost_slutt = tid_na + 18.0
			GameState.legg_til_powerup("speed")
			_vis_feedback("SPEED BOOST i 18 sek!")
		"id":
			GameState.har_id = true
			GameState.legg_til_powerup("id")
			_vis_feedback("Legitimasjon plukket opp!")
		"baguette":
			GameState.legg_til_powerup("baguette")
			_vis_feedback("Bestevenn jubler! +10% fart")
		"beast":
			GameState.beast_slutt = tid_na + 12.0
			GameState.legg_til_powerup("beast")
			_vis_feedback("BEAST MODE i 12 sek! ID skippes!")

func _er_ved_kasse() -> bool:
	return spiller.position.x < 12 * TILE and spiller.position.y > 14 * TILE

func _gaa_til_kasse() -> void:
	if GameState.alle_varer_hentet():
		get_tree().change_scene_to_file("res://scenes/Checkout.tscn")
	else:
		_vis_feedback("Du mangler " + str(GameState.handleliste.size() - GameState.antall_hentet()) + " vare(r) enda!")

func _tid_ute() -> void:
	GameState.fail_grunn = "Tiden er ute!"
	get_tree().change_scene_to_file("res://scenes/LoseScreen.tscn")
