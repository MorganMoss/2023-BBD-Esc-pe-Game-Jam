extends Area2D

@export var animation = 0
@export var direction = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var animations = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(animations[animation])
	$ShootTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_shoot_timer_timeout():
	if get_node("/root/Level1"):
		get_node("/root/Level1").spawn_slime_bullet(self.position, direction*(PI/2))
	elif get_node("/root/Level2"):
		get_node("/root/Level2").spawn_slime_bullet(self.position, direction*(PI/2))
