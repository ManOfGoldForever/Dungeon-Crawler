extends Node3D

@onready var pause_menu = $PauseMenu
var paused = false
var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		PauseMenu()

func PauseMenu():
	if paused:
		pause_menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Warrior.can_move = true
	else:
		pause_menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Warrior.can_move = false
	paused = !paused


func _on_host_pressed() -> void:
	peer.create_server(1027)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	$CanvasLayer.hide()
	add_player()


func _on_join_pressed() -> void:
	peer.create_client("127.0.0.1", 1027)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	var spawn_position: Vector3
	
	# Set spawn position for both players
	if id == 1:  # Host (or player 1)
		spawn_position = Vector3(0, 1, 0)  # Or wherever you'd like the spawn location to be
	else:  # For joining player
		spawn_position = Vector3(0, 2, 0)  # Could be updated to match a better logic
	
	player.transform.origin = spawn_position
	call_deferred("add_child", player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player", id)

@rpc("any_peer", "call_local")
func _del_player(id):
	var node = get_node_or_null(str(id))
	if node:
		node.queue_free()
