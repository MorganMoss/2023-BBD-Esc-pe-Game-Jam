extends RigidBody2D

var enemy_sprite: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_sprite = get_node("enemySprite2D")
	handle_animation_direction(linear_velocity)
	$ShootTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_shoot_timer_timeout():
	get_node("/root/Main").spawn_bullet(self.position)

func handle_animation_direction(vector):
	if vector.x != 0:
		enemy_sprite.animation = "side"
		enemy_sprite.flip_h = vector.x < 0
	if vector.y < 0 and abs(vector.x) < abs(vector.y):
		enemy_sprite.animation = "back"
	if vector.y > 0 and abs(vector.x) < abs(vector.y):
		enemy_sprite.animation = "front"
