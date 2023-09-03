extends Area2D

signal attack(body)

@export var speed = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.from_angle(self.rotation)
	self.position += velocity*delta*speed


func _on_body_entered(body):
	get_node("/root/Level1").on_attack(body)


func end_attack():
	queue_free()
