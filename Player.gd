extends Area2D

signal hit

@export var speed = 400
@export var dash_attack_distance: float = 400
@export var dash_attack_speed: float = 2000
@export var dash_attack_charge_time: float = 1
@export var dash_attack_ghost_delay_time: float = 0.1
@export var attack_scene: PackedScene

var screen_size
var is_charging_dash_attack: bool = false
var dash_attack_enabled: bool = true
var dash_attack_ready: bool = false
var dash_attacking: bool = false
var dash_attack_charge: float = float()
var dash_attack_elapsed_distance: float = float()
var dash_attack_direction: Vector2
var velocity: Vector2 = Vector2.ZERO
var ghost_sprite: AnimatedSprite2D
var player_sprite: AnimatedSprite2D
var melee_weapon_sprite: AnimatedSprite2D
var player_hitbox: CollisionShape2D
var attacking: bool = false
var attack_queued: bool = false
var attack_queued_direction: float
var played_charge_up_sound: bool = false
var is_dead: bool = false
var attack_reversed: bool = false

func start(pos):
	is_dead = false	
	position = pos
	show()
	player_hitbox.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	ghost_sprite = get_node("DashGhostSprite2D")
	player_sprite = get_node("PlayerSprite2D")
	melee_weapon_sprite = get_node("MeleeAttackSprite2D")
	player_hitbox = get_node("PlayerCollision2D")
	hide()

func handle_charge_up(delta, direction_vector):
	dash_attack_charge += delta
	if dash_attack_charge >= dash_attack_ghost_delay_time:
		ghost_sprite.modulate = Color(1, 1, 1, 0.4)
		ghost_sprite.position = direction_vector * dash_attack_distance
		if not played_charge_up_sound:
			played_charge_up_sound = true
			$DashGhostSprite2D/DashAttackChargeUp.play()
	
	dash_attack_ready = dash_attack_charge >= dash_attack_charge_time
	if dash_attack_ready:
		ghost_sprite.modulate = Color(1,0.5,0.5,0.4)
		player_sprite.modulate = Color(1,0.5,0.5)

func handle_player_animation_direction(vector):
	if vector.x != 0:
		player_sprite.animation = "RunSide"
		player_sprite.flip_h = vector.x < 0
	if vector.y < 0 and abs(vector.x) < abs(vector.y):
		player_sprite.animation = "RunBack"
	if vector.y > 0 and abs(vector.x) < abs(vector.y):
		player_sprite.animation = "RunFront"

func handle_ghost_animation_direction(vector):
	if vector.x != 0:
		ghost_sprite.animation = "Side"
		ghost_sprite.flip_h = vector.x < 0
	if vector.y < 0 and abs(vector.x) < abs(vector.y):
		ghost_sprite.animation = "Back"
	if vector.y > 0 and abs(vector.x) < abs(vector.y):
		ghost_sprite.animation = "Front"
	

func handle_normal_movement():
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	if Input.is_action_pressed("move_down"):
		velocity.y = 1
	if Input.is_action_pressed("move_up"):
		velocity.y = -1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		player_sprite.play()
	else:
		player_sprite.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dead:
		return

	velocity = Vector2.ZERO
	var mouse_direction: Vector2 = (get_global_mouse_position() - position).normalized()
	ghost_sprite.modulate = Color(1, 1, 1, 0)
	player_hitbox.set_deferred("disabled", false)
	if is_charging_dash_attack:
		handle_charge_up(delta, mouse_direction)
		handle_player_animation_direction(mouse_direction)		
		handle_ghost_animation_direction(mouse_direction)
	elif dash_attacking:
		player_hitbox.set_deferred("disabled", true)
		if dash_attack_elapsed_distance <= dash_attack_distance:
			velocity = dash_attack_direction * dash_attack_speed
		else:
			dash_attacking = false
		handle_player_animation_direction(velocity)			
	elif not attacking:
		is_charging_dash_attack = false
		handle_normal_movement()
		handle_player_animation_direction(velocity)
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	dash_attack_elapsed_distance += (velocity * delta).length()
	
	
func trigger_dash_attack():
	played_charge_up_sound = false
	is_charging_dash_attack = false
	if dash_attack_ready:
		$DashCooldown.start()
		dash_attack_enabled = false
		dash_attack_elapsed_distance = 0
		dash_attack_ready = false
		dash_attacking = true
		dash_attack_direction = (get_global_mouse_position() - position).normalized()

func trigger_charge_dash_attack():
	is_charging_dash_attack = true
	dash_attack_charge = float()

func attack_finished():
	attacking = false
	if attack_queued:
		trigger_melee_attack(attack_queued_direction)
		attack_queued = false

func trigger_next_attack(direction: float):
	attack_queued_direction = direction
	attack_queued = true

func trigger_melee_attack(direction: float):
	attacking = true
	var attack = attack_scene.instantiate()
	melee_weapon_sprite.connect("animation_finished", attack.end_attack)
	melee_weapon_sprite.show()
	melee_weapon_sprite.play("blackStick")
	attack_reversed = !attack_reversed
	melee_weapon_sprite.flip_h = attack_reversed
	melee_weapon_sprite.rotation = direction-PI/2
	$MeleeAttackSprite2D/SwordSwoosh.pitch_scale = randf_range(0.5, 2)
	$MeleeAttackSprite2D/SwordSwoosh.play()
	
	if not dash_attacking:
		attack.hide()
	else:
		$DashGhostSprite2D/DashAttackWhoosh.play()
	# Choose the starting position of the attack
	attack.position = Vector2.from_angle(direction) * 50
	# Set the attack's direction to aim at the player
	attack.rotation = direction
	
	# Spawn the attack
	add_child(attack)

func _input(event):
	if is_dead:
		return
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
			if dash_attack_enabled:
				trigger_charge_dash_attack()
		elif (event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
			trigger_dash_attack()
			if dash_attack_charge < dash_attack_ghost_delay_time or dash_attacking or !dash_attack_enabled:
				var direction = self.position.angle_to_point(event.position)
				if not attacking:
					trigger_melee_attack(direction)
				else:
					trigger_next_attack(direction)
				


func _on_body_entered(body):
	hide()
	hit.emit()
	player_hitbox.set_deferred("disabled", true)


func kill():
	is_dead = true
	


func _on_dash_cooldown_timeout():
	dash_attack_enabled = true
	player_sprite.modulate = Color(1, 1, 1, 1)
	$DashCooldown/Recharge.play()
