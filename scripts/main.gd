extends Node2D

const FighterScene = preload("res://scripts/fighter.gd")

var p1: Fighter
var p2: Fighter

var p1_bar: ProgressBar
var p2_bar: ProgressBar
var status_label: Label
var round_label: Label
var controls_label: Label

var round_number := 1
var p1_rounds := 0
var p2_rounds := 0
var round_locked := false
var reset_timer := 0.0

func _ready() -> void:
	randomize()
	_create_ui()
	_create_fighters()
	queue_redraw()

func _create_fighters() -> void:
	p1 = FighterScene.new()
	p1.add_to_group("fighters")
	add_child(p1)
	p1.setup("Tux", 1, false)
	p1.strike.connect(_on_strike)

	p2 = FighterScene.new()
	p2.add_to_group("fighters")
	add_child(p2)
	p2.setup("CPU", 2, true)
	p2.strike.connect(_on_strike)

	_reset_round()

func _create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	p1_bar = ProgressBar.new()
	p1_bar.position = Vector2(70, 55)
	p1_bar.size = Vector2(470, 28)
	p1_bar.max_value = 100
	p1_bar.show_percentage = false
	layer.add_child(p1_bar)

	p2_bar = ProgressBar.new()
	p2_bar.position = Vector2(740, 55)
	p2_bar.size = Vector2(470, 28)
	p2_bar.max_value = 100
	p2_bar.show_percentage = false
	layer.add_child(p2_bar)

	var title := Label.new()
	title.text = "TUX COMBAT"
	title.position = Vector2(515, 12)
	title.add_theme_font_size_override("font_size", 28)
	layer.add_child(title)

	round_label = Label.new()
	round_label.position = Vector2(570, 82)
	round_label.add_theme_font_size_override("font_size", 20)
	layer.add_child(round_label)

	status_label = Label.new()
	status_label.position = Vector2(360, 585)
	status_label.size = Vector2(560, 60)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 26)
	layer.add_child(status_label)

	controls_label = Label.new()
	controls_label.position = Vector2(300, 675)
	controls_label.size = Vector2(680, 30)
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.add_theme_font_size_override("font_size", 14)
	controls_label.text = "P1: A/D move • W jump • S crouch • J punch • K kick   |   CPU: arrows • O/P"
	layer.add_child(controls_label)

func _process(delta: float) -> void:
	if p1 == null or p2 == null:
		return

	p1_bar.value = p1.health
	p2_bar.value = p2.health
	round_label.text = "Round %d   •   %d - %d" % [round_number, p1_rounds, p2_rounds]

	if round_locked:
		reset_timer -= delta
		if reset_timer <= 0.0:
			if p1_rounds >= 2 or p2_rounds >= 2:
				round_number = 1
				p1_rounds = 0
				p2_rounds = 0
			else:
				round_number += 1
			_reset_round()
		return

	if p1.health <= 0 or p2.health <= 0:
		_end_round()

	queue_redraw()

func _on_strike(attacker: Fighter, damage: int, reach: float) -> void:
	if round_locked:
		return
	var target := p2 if attacker == p1 else p1
	var horizontal_distance := abs(target.position.x - attacker.position.x)
	var vertical_distance := abs(target.position.y - attacker.position.y)

	if horizontal_distance <= reach and vertical_distance < 100.0:
		var direction := sign(target.position.x - attacker.position.x)
		if direction == 0:
			direction = attacker.facing
		target.take_damage(damage, direction * 180.0)

func _end_round() -> void:
	round_locked = true
	reset_timer = 2.0

	var winner := p1 if p1.health > 0 else p2
	if winner == p1:
		p1_rounds += 1
	else:
		p2_rounds += 1

	if p1_rounds >= 2 or p2_rounds >= 2:
		status_label.text = "%s wins the match! 🐧" % winner.fighter_name
	else:
		status_label.text = "%s wins the round!" % winner.fighter_name

func _reset_round() -> void:
	round_locked = false
	status_label.text = "FIGHT!"
	p1.reset_fighter(Vector2(360, 560))
	p2.reset_fighter(Vector2(920, 560))

	await get_tree().create_timer(0.75).timeout
	if not round_locked:
		status_label.text = ""

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("#0b1020"))
	draw_rect(Rect2(0, 430, 1280, 290), Color("#121a2b"))

	for x in range(0, 1281, 80):
		draw_line(Vector2(x, 430), Vector2(x - 120, 720), Color("#1d2942"), 2)

	draw_line(Vector2(70, 620), Vector2(1210, 620), Color("#4f6b91"), 6)

	draw_string(ThemeDB.fallback_font, Vector2(80, 405), "OPEN-SOURCE ARENA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#7dd3fc"))
	draw_string(ThemeDB.fallback_font, Vector2(1000, 405), "ROUND READY", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#a7f3d0"))
