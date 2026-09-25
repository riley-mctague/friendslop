extends Node3D

const PLAYER = preload("uid://ds25c7icm0guj")

var players: Array[CharacterBody3D] # keeps an array of all connected players 

func _ready() -> void:
	Networking.host_created.connect(on_host_created)


func on_host_created() -> void:
	# Spawn the server player
	spawn_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(spawn_player)


# The server spawns the player that just connected
func spawn_player(peer_id: int) -> void:
	var new_player:= PLAYER.instantiate() as CharacterBody3D # instantiate player
	new_player.name = str(peer_id) # unique identifier from Steam ID number
	add_child(new_player)
	initialize_player(new_player)


func initialize_player(player: CharacterBody3D) -> void:
	player.position = $SpawnPoint.position
	# Prevent players from colliding on spawn
	for other in players:
		player.add_collision_exception_with(other)
	players.append(player)


# Connect to host button signal
func _on_host_pressed() -> void:
	Networking.host_lobby()


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	# Detect other players and initialize them on the client end
	if node is CharacterBody3D:
		initialize_player(node)
