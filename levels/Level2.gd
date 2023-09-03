extends Node

@export var mob_scene: PackedScene
@export var bullet_scene: PackedScene
@export var big_bullet_scene: PackedScene
@export var mob_cap: int

var score
var kill_count

signal on_game_over()

# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	kill_count = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$Music.play()
	$HUD.hide_button()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	spawn_enemies()


func spawn_enemies():	
	for i in range(mob_cap):
		# Create a new instance of the Mob scene
		var mob = mob_scene.instantiate()
		
		# Calculate the direction for this mob
		var direction_vector = Vector2(200,200).rotated(i*2*PI/mob_cap)
		
		# Choose a position for the mob to spawn
		mob.position = direction_vector + $Player.position
		
		# Choose the mob's velocity
		mob.linear_velocity = direction_vector / 3
		
		# Spawn the mob
		add_child(mob)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func game_over():
	on_game_over.emit()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


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


func spawn_big_bullet(position):
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


func on_attack(body: Node):
	body.queue_free()
	if body.get_groups()[0] == "mobs":
		kill_count += 1
		if kill_count == mob_cap:
			$ScoreTimer.stop()
			$MobTimer.stop()
			$HUD.show_message("You win!")
