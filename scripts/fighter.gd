extends CharacterBody2D
class_name Fighter

signal strike(attacker: Fighter, damage: int, reach: float)

var fighter_name := "Fighter"
var character_id := "tux"
var player_id := 1
var is_cpu := false
var facing := 1.0

var max_health := 100
var health := 100

const SPEED := 340.0
const JUMP_SPEED := -720.0
const GRAVITY := 1800.0
const GROUND_Y := 560.0
const PUNCH_DAMAGE := 7
const KICK_DAMAGE := 10
const PUNCH_REACH := 105.0
const KICK_REACH := 125.0

var attack_cooldown := 0.0
var attack_flash := 0.0
var crouching := false
var stunned := 0.0
var ai_timer := 0.0
var ai_choice := 0

func setup(display_name: String, id: int, cpu: bool, style_id: String = "tux") -> void:
	fighter_name = display_name
	player_id = id
	is_cpu = cpu
	character_id = style_id
	health = max_health
	queue_redraw()

func reset_fighter(start_position: Vector2) -> void:
	position = start_position
	velocity = Vector2.ZERO
	health = max_health
	facing = 1.0 if start_position.x < 640.0 else -1.0
	attack_cooldown = 0.0
	attack_flash = 0.0
	stunned = 0.0
	crouching = false
	queue_redraw()

func _physics_process(delta: float) -> void:
	if stunned > 0.0:
		stunned -= delta
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if attack_flash > 0.0:
		attack_flash -= delta
		queue_redraw()

	var grounded := position.y >= GROUND_Y
	if grounded:
		position.y = GROUND_Y
		velocity.y = 0.0
	else:
		velocity.y += GRAVITY * delta

	if stunned <= 0.0:
		if is_cpu:
			_process_cpu(delta)
		else:
			_process_player(grounded)

	move_and_slide()
	position.x = clamp(position.x, 100.0, 1180.0)
	if position.y > GROUND_Y:
		position.y = GROUND_Y
		velocity.y = 0.0
	if attack_flash <= 0.0:
		queue_redraw()

func _process_player(grounded: bool) -> void:
	var left := false
	var right := false
	var jump := false
	var down := false
	var punch := false
	var kick := false

	if player_id == 1:
		left = Input.is_key_pressed(KEY_A)
		right = Input.is_key_pressed(KEY_D)
		jump = Input.is_key_pressed(KEY_W)
		down = Input.is_key_pressed(KEY_S)
		punch = Input.is_key_pressed(KEY_J)
		kick = Input.is_key_pressed(KEY_K)
		if Input.get_connected_joypads().has(0):
			var axis := Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
			left = left or axis < -0.35
			right = right or axis > 0.35
			jump = jump or Input.is_joy_button_pressed(0, JOY_BUTTON_Y)
			punch = punch or Input.is_joy_button_pressed(0, JOY_BUTTON_A)
			kick = kick or Input.is_joy_button_pressed(0, JOY_BUTTON_B)

	var direction := float(right) - float(left)
	velocity.x = move_toward(velocity.x, direction * SPEED, 70.0)
	if direction != 0.0:
		facing = sign(direction)

	crouching = down and grounded
	if crouching:
		velocity.x *= 0.55
	if jump and grounded and not crouching:
		velocity.y = JUMP_SPEED
	if punch:
		_try_attack(PUNCH_DAMAGE, PUNCH_REACH, 0.24)
	elif kick:
		_try_attack(KICK_DAMAGE, KICK_REACH, 0.32)

func _process_cpu(delta: float) -> void:
	var opponents := get_tree().get_nodes_in_group("fighters")
	var target: Fighter = null
	for node in opponents:
		if node != self and node is Fighter:
			target = node
			break
	if target == null:
		return

	var distance := target.position.x - position.x
	var abs_distance := abs(distance)
	facing = 1.0 if distance >= 0.0 else -1.0
	if abs_distance > 150.0:
		velocity.x = move_toward(velocity.x, facing * SPEED * 0.68, 45.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 80.0)

	ai_timer -= delta
	if ai_timer <= 0.0:
		ai_timer = randf_range(0.25, 0.7)
		ai_choice = randi_range(0, 3)
	if abs_distance < 145.0 and ai_choice <= 1:
		_try_attack(KICK_DAMAGE if ai_choice == 1 else PUNCH_DAMAGE, KICK_REACH if ai_choice == 1 else PUNCH_REACH, 0.3)
	elif abs_distance > 250.0 and ai_choice == 2 and position.y >= GROUND_Y:
		velocity.y = JUMP_SPEED

func _try_attack(damage: int, reach: float, recovery: float) -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = recovery
	attack_flash = 0.12
	strike.emit(self, damage, reach)

func take_damage(amount: int, knockback: float) -> void:
	if health <= 0:
		return
	health = max(0, health - amount)
	stunned = 0.16
	velocity.x += knockback
	queue_redraw()

func _draw() -> void:
	var body := Color("#161b22")
	var belly := Color("#f2f4f8")
	var accent := Color("#f59e0b")
	var outline := Color("#05070a")

	match character_id:
		"gnu":
			_draw_gnu(Color("#7b8794"), Color("#f4f1e8"), Color("#b7791f"), outline)
			return
		"beastie":
			_draw_beastie(Color("#b91c1c"), Color("#f3e8d0"), Color("#f97316"), outline)
			return
		"puffy":
			_draw_puffy(Color("#2563eb"), Color("#dbeafe"), accent, outline)
			return

	_draw_tux(body, belly, accent, Color.WHITE, outline)

func _draw_tux(body: Color, belly: Color, accent: Color, eye: Color, outline: Color) -> void:
	draw_circle(Vector2(0, -65), 54, outline)
	draw_circle(Vector2(0, -65), 49, body)
	draw_circle(Vector2(0, -48), 38, belly)
	var beak_x := 48.0 * facing
	draw_colored_polygon(PackedVector2Array([Vector2(beak_x, -66), Vector2(beak_x + 32.0 * facing, -56), Vector2(beak_x, -46)]), accent)
	draw_circle(Vector2(19.0 * facing, -80), 9, eye)
	draw_circle(Vector2(22.0 * facing, -80), 4, outline)
	draw_circle(Vector2(0, 15), 52, outline)
	draw_circle(Vector2(0, 15), 47, body)
	draw_circle(Vector2(0, 22), 35, belly)
	_draw_limbs(body, accent)

func _draw_gnu(body: Color, belly: Color, accent: Color, outline: Color) -> void:
	draw_circle(Vector2(0, -65), 50, outline)
	draw_circle(Vector2(0, -65), 46, body)
	draw_circle(Vector2(0, -42), 34, belly)
	draw_line(Vector2(-24, -92), Vector2(-45, -125), body, 13)
	draw_line(Vector2(24, -92), Vector2(45, -125), body, 13)
	draw_line(Vector2(-45, -125), Vector2(-65, -112), body, 8)
	draw_line(Vector2(45, -125), Vector2(65, -112), body, 8)
	draw_circle(Vector2(18.0 * facing, -78), 8, Color.WHITE)
	draw_circle(Vector2(21.0 * facing, -78), 4, outline)
	draw_circle(Vector2(48.0 * facing, -57), 18, belly)
	draw_circle(Vector2(0, 15), 51, outline)
	draw_circle(Vector2(0, 15), 46, body)
	draw_circle(Vector2(0, 20), 34, belly)
	_draw_limbs(body, accent)

func _draw_beastie(body: Color, belly: Color, accent: Color, outline: Color) -> void:
	draw_circle(Vector2(0, -64), 52, outline)
	draw_circle(Vector2(0, -64), 47, body)
	draw_circle(Vector2(0, -45), 35, belly)
	draw_line(Vector2(-30, -96), Vector2(-55, -132), body, 16)
	draw_line(Vector2(30, -96), Vector2(55, -132), body, 16)
	draw_line(Vector2(-55, -132), Vector2(-70, -145), accent, 9)
	draw_line(Vector2(55, -132), Vector2(70, -145), accent, 9)
	draw_circle(Vector2(18 * facing, -78), 8, Color.WHITE)
	draw_circle(Vector2(21 * facing, -78), 4, outline)
	draw_circle(Vector2(0, 15), 52, outline)
	draw_circle(Vector2(0, 15), 47, body)
	draw_circle(Vector2(0, 21), 35, belly)
	_draw_limbs(body, accent)

func _draw_puffy(body: Color, belly: Color, accent: Color, outline: Color) -> void:
	draw_circle(Vector2(0, -65), 52, outline)
	draw_circle(Vector2(0, -65), 47, body)
	draw_circle(Vector2(0, -45), 34, belly)
	draw_circle(Vector2(-45, -78), 18, body)
	draw_circle(Vector2(45, -78), 18, body)
	draw_circle(Vector2(18 * facing, -80), 8, Color.WHITE)
	draw_circle(Vector2(21 * facing, -80), 4, outline)
	draw_line(Vector2(42 * facing, -58), Vector2(78 * facing, -45), accent, 15)
	draw_circle(Vector2(0, 15), 52, outline)
	draw_circle(Vector2(0, 15), 47, body)
	draw_circle(Vector2(0, 21), 35, belly)
	_draw_limbs(body, accent)

func _draw_limbs(body: Color, accent: Color) -> void:
	var arm_y := -2.0 if not crouching else 10.0
	draw_line(Vector2(-34, arm_y), Vector2(-65, arm_y + 18), body, 18)
	draw_line(Vector2(34, arm_y), Vector2(65, arm_y + 18), body, 18)
	if attack_flash > 0.0:
		draw_line(Vector2(35.0 * facing, -5), Vector2(105.0 * facing, -18), accent, 13)
		draw_circle(Vector2(112.0 * facing, -20), 9, accent)
	draw_line(Vector2(-22, 54), Vector2(-30, 86), accent, 18)
	draw_line(Vector2(22, 54), Vector2(30, 86), accent, 18)
