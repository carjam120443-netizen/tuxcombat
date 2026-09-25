extends Node2D

const FighterScene = preload("res://scripts/fighter.gd")
const CHARACTERS := [
	{"id": "tux", "name": "Tux", "description": "Linux penguin • balanced"},
	{"id": "gnu", "name": "GNU", "description": "GNU wildebeest • heavy"},
	{"id": "beastie", "name": "Beastie", "description": "BSD daemon • aggressive"},
	{"id": "puffy", "name": "Puffy", "description": "OpenBSD pufferfish • quick"}
]

var p1: Fighter
var p2: Fighter
var p1_bar: ProgressBar
var p2_bar: ProgressBar
var status_label: Label
var round_label: Label
var controls_label: Label
var selection_layer: CanvasLayer
var selection_label: Label
var selection_buttons: Array[Button] = []
var selected_index := 0
var selecting := true
var round_number := 1
var p1_rounds := 0
var p2_rounds := 0
var round_locked := false
var reset_timer := 0.0

func _ready() -> void:
	randomize()
	_create_selection_screen()
	queue_redraw()

func _create_selection_screen() -> void:
	selection_layer = CanvasLayer.new()
	add_child(selection_layer)

	var background := ColorRect.new()
	background.color = Color("#080d18")
	background.size = Vector2(1280, 720)
	selection_layer.add_child(background)

	var title := Label.new()
	title.text = "TUX COMBAT"
	title.position = Vector2(0, 70)
	title.size = Vector2(1280, 60)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	selection_layer.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "SELECT YOUR UNIX / LINUX FIGHTER"
	subtitle.position = Vector2(0, 135)
	subtitle.size = Vector2(1280, 35)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	selection_layer.add_child(subtitle)

	selection_label = Label.new()
	selection_label.position = Vector2(0, 575)
	selection_label.size = Vector2(1280, 40)
	selection_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_label.add_theme_font_size_override("font_size", 22)
	selection_layer.add_child(selection_label)

	for i in range(CHARACTERS.size()):
		var button := Button.new()
		button.text = "%s\n\n%s" % [CHARACTERS[i]["name"], CHARACTERS[i]["description"]]
		button.position = Vector2(70 + i * 300, 230)
		button.size = Vector2(250, 270)
		button.add_theme_font_size_override("font_size", 20)
		button.tooltip_text = "Choose %s" % CHARACTERS[i]["name"]
		button.pressed.connect(_select_character.bind(i))
		selection_layer.add_child(button)
		selection_buttons.append(button)

	_update_selection_visuals()

func _update_selection_visuals() -> void:
	for i in range(selection_buttons.size()):
		var button := selection_buttons[i]
		button.modulate = Color.WHITE if i == selected_index else Color(0.65, 0.68, 0.75, 1.0)
		if i == selected_index:
			button.text = "▶ %s ◀\n\n%s" % [CHARACTERS[i]["name"], CHARACTERS[i]["description"]]
		else:
			button.text = "%s\n\n%s" % [CHARACTERS[i]["name"], CHARACTERS[i]["description"]]
	selection_label.text = "Selected: %s   •   ← / → to choose   •   ENTER to fight" % CHARACTERS[selected_index]["name"]

func _input(event: InputEvent) -> void:
	if not selecting:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT:
			selected_index = (selected_index - 1 + CHARACTERS.size()) % CHARACTERS.size()
			_update_selection_visuals()
		elif event.keycode == KEY_RIGHT:
			selected_index = (selected_index + 1) % CHARACTERS.size()
			_update_selection_visuals()
		elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_start_game(selected_index)

func _select_character(index: int) -> void:
	selected_index = index
	_update_selection_visuals()
	_start_game(index)

func _start_game(player_choice: int) -> void:
	if not selecting:
		return
	selecting = false
	if selection_layer != null:
		selection_layer.queue_free()
	_create_ui()
	_create_fighters(player_choice)

func _create_fighters(player_choice: int) -> void:
	var player_data: Dictionary = CHARACTERS[player_choice]
	var cpu_choice := (player_choice + randi_range(1, CHARACTERS.size() - 1)) % CHARACTERS.size()
	var cpu_data: Dictionary = CHARACTERS[cpu_choice]

	p1 = FighterScene.new()
	p1.add_to_group("fighters")
	add_child(p1)
	p1.setup(player_data["name"], 1, false, player_data["id"])
	p1.strike.connect(_on_strike)

	p2 = FighterScene.new()
	p2.add_to_group("fighters")
	add_child(p2)
	p2.setup(cpu_data["name"], 2, true, cpu_data["id"])
	p2.strike.connect(_on_strike)

	controls_label.text = "P1: A/D move • W jump • S crouch • J punch • K kick   |   CPU: %s" % cpu_data["name"]
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
	controls_label.position = Vector2(250, 675)
	controls_label.size = Vector2(780, 30)
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.add_theme_font_size_override("font_size", 14)
	layer.add_child(controls_label)

func _process(delta: float) -> void:
	if selecting or p1 == null or p2 == null:
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
	if selecting:
		return
	draw_rect(Rect2(0, 0, 1280, 720), Color("#0b1020"))
	draw_rect(Rect2(0, 430, 1280, 290), Color("#121a2b"))
	for x in range(0, 1281, 80):
		draw_line(Vector2(x, 430), Vector2(x - 120, 720), Color("#1d2942"), 2)
	draw_line(Vector2(70, 620), Vector2(1210, 620), Color("#4f6b91"), 6)
	draw_string(ThemeDB.fallback_font, Vector2(80, 405), "OPEN-SOURCE ARENA", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#7dd3fc"))
	draw_string(ThemeDB.fallback_font, Vector2(1000, 405), "ROUND READY", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#a7f3d0"))
