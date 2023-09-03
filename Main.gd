extends Node

@export var level1_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func new_game():
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	get_tree().change_scene_to_packed(level1_scene)
