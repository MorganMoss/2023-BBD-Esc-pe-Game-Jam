extends Area2D

signal hit

@export var speed = 400
@export var attack_scene: PackedScene

var screen_size

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "RunSide"
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y < 0:
		$AnimatedSprite2D.animation = "RunBack"
	elif velocity.y > 0:
		$AnimatedSprite2D.animation = "RunFront"

func _input(event):
	if event is InputEventMouseButton:
		# Create a new instance of the Attack scene
		var attack = attack_scene.instantiate()
		
		# Choose the starting position of the attack
		attack.position = Vector2.ZERO
		
		# Set the attack's direction to aim at the player
		var direction = self.position.angle_to_point(event.position)
		attack.rotation = direction
		
		# Spawn the attack
		add_child(attack)

func _on_body_entered(body):
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)
