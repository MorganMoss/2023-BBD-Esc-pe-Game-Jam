extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$ShootTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_shoot_timer_timeout():
	if get_node("/root/Level2"):
		get_node("/root/Level2").spawn_big_bullet(self.position)
