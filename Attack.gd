extends Area2D

signal attack(body)

@export var speed = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.from_angle(self.rotation)
	self.position += velocity*delta*speed


func _on_body_entered(body):
	print("Ah")
	get_node("/root/Main").on_attack(body)


func _on_attack_timer_timeout():
	queue_free()
