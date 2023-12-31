extends Area2D

signal attack(body)

@export var speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.from_angle(self.rotation)
	self.position += velocity*delta*speed


func _on_body_entered(body):
	if get_node("/root/Level1"):
		get_node("/root/Level1").on_attack(body)
	elif get_node("/root/Level2"):
		get_node("/root/Level2").on_attack(body)
		

func _on_area_entered(area):
	if get_node("/root/Level1"):
		get_node("/root/Level1").on_attack_area(area)
	elif get_node("/root/Level2"):
		get_node("/root/Level2").on_attack_area(area)

func end_attack():
	queue_free()
