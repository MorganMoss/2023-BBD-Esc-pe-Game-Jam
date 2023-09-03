extends TileMap

@export var player: Node2D

signal player_on(layer_id: int, tile_id: int)

var tile_id



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = local_to_map(to_local(player.global_position))
	for layer in range(self.get_layers_count()):
		var cell = self.get_cell_source_id(layer, pos)
		if cell == null:
			continue
		else:
			player_on.emit(layer, cell)
