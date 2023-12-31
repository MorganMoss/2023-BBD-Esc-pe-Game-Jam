extends Node

@export var mob_scene: PackedScene
@export var bullet_scene: PackedScene
@export var slime_bullet_scene: PackedScene
@export var level2_scene: PackedScene
@export var mob_cap: int
@export var waves: int = 2
@export var wave_mob_cap_multiplier: int = 2

var score
var mob_count
var kill_count
var current_wave: int
var current_mob_cap: int

signal on_game_over()

# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	mob_count = 0
	kill_count = 0
	current_mob_cap = mob_cap
	current_wave = 1
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$Music.play()
	$HUD.hide_button()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("bullets", "queue_free")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $GreenSlime:
		$SlimePath/SlimeSpawnLocation.progress_ratio += delta/16
		$GreenSlime.position = $SlimePath/SlimeSpawnLocation.position

func game_over():
	on_game_over.emit()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	current_wave = 1
	current_mob_cap = mob_cap
	

func _on_mob_timer_timeout():
	if mob_count < current_mob_cap:
		# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()

		# Choose a random location on Path2D.
		var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
		mob_spawn_location.progress_ratio = randf()

		# Set the mob's direction perpendicular to the path direction.
		var direction = mob_spawn_location.rotation + PI / 2

		# Set the mob's position to a random location.
		mob.position = mob_spawn_location.position

		# Add some randomness to the direction.
		direction += randf_range(-PI / 4, PI / 4)

		# Choose the velocity for the mob.
		var velocity = Vector2(randf_range(50.0, 150.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)

		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
		mob_count += 1


func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func spawn_bullet(position):
	if $Player:
		# Create a new instance of the Bullet scene
		var bullet = bullet_scene.instantiate()
		
		# Choose the starting position of the bullet as the Mob's position
		var bullet_spawn_location = position
		bullet.position = bullet_spawn_location
		
		# Set the bullet's direction to aim at the player
		var direction = position.angle_to_point($Player.position)
		bullet.rotation = direction
		
		# Set the velocity of the bullet
		var velocity = Vector2(100.0, 0.0)
		bullet.linear_velocity = velocity.rotated(direction)
		
		# Spawn the bullet
		add_child(bullet)
		
func spawn_slime_bullet(position, direction):
	if $Player:
		# Create a new instance of the Bullet scene
		var slime_bullet = slime_bullet_scene.instantiate()
		
		# Choose the starting position of the bullet as the Mob's position
		var bullet_spawn_location = position
		slime_bullet.position = bullet_spawn_location
		
		# Set the bullet's direction to aim at the player
		slime_bullet.rotation = direction
		
		# Set the velocity of the bullet
		var velocity = Vector2(100.0, 0.0)
		slime_bullet.linear_velocity = velocity.rotated(direction)
		
		# Spawn the bullet
		add_child(slime_bullet)


func on_attack(body: Node):
	body.queue_free()
	if body.get_groups()[0] == "mobs":
		kill_count += 1
		if kill_count == mob_cap and current_wave > waves:
			$ScoreTimer.stop()
			$MobTimer.stop()
			$HUD.show_message("Level 1 Clear!")
			$WinTimer.start()
		elif kill_count == current_mob_cap:
			current_wave += 1
			current_mob_cap += current_mob_cap*wave_mob_cap_multiplier
			$HUD.show_message("Wave " + str(current_wave))


func on_attack_area(area: Area2D):
	area.queue_free()
	if area.get_groups()[0] == "slimes":
		kill_count += 1
		if kill_count == mob_cap:
			$ScoreTimer.stop()
			$MobTimer.stop()
			$HUD.show_message("Level 1 Clear!")
			$WinTimer.start()


func _on_win_timer_timeout():
	get_tree().change_scene_to_packed(level2_scene)
