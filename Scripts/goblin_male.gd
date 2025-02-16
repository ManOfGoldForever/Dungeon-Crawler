extends CharacterBody3D

@export var speed = 3.0
@export var jump_velocity = 4.5
@export var gravity = -9.8
@export var attack_range = 2.5

@onready var hitbox_collision = $HitBox/CollisionShape3D
@onready var nav_agent = $NavigationAgent3D
@onready var animation_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree

var state_machine
var dead = false

func _ready() -> void:
	state_machine = anim_tree.get("parameters/playback")

func _on_health_health_depleted() -> void:
	dead = true
	animation_player.play("Death", 1)

func _process(_delta: float) -> void:
	if dead:
		return
	match state_machine.get_current_node():
		"Run":
			var closest_player = get_closest_player()
			if closest_player:
				# Move towards the closest player
				var player_pos = closest_player.global_transform.origin
				nav_agent.set_target_position(player_pos)
				var next_nav_point = nav_agent.get_next_path_position()
				velocity = (next_nav_point - global_transform.origin).normalized() * speed
				look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"Punch":
			var closest_player = get_closest_player()
			var player_pos = closest_player.global_transform.origin
			look_at(Vector3(player_pos.x, global_position.y, player_pos.z), Vector3.UP)
	anim_tree.set("parameters/conditions/punch", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	anim_tree.get("parameters/playback")
	move_and_slide()

func get_closest_player() -> Node:
	var closest_player = null
	var shortest_distance = INF
	var current_position = global_transform.origin

	# Iterate through all players in the "Player" group
	for player in get_tree().get_nodes_in_group("Player"):
		var distance = current_position.distance_to(player.global_transform.origin)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_player = player

	return closest_player

func _on_hurt_box_received_damage(_damage: int) -> void:
	if not dead:
		animation_player.play("RecieveHit")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Death":
		queue_free()

func _target_in_range() -> bool:
	var closest_player = get_closest_player()
	if closest_player:
		return global_transform.origin.distance_to(closest_player.global_transform.origin) < attack_range
	return false

func _hit_finished():
	var closest_player = get_closest_player()
	if global_position.distance_to(closest_player.global_position) < attack_range + 1.0:
		var dir = global_position.direction_to(closest_player.global_position)
		#animation_player.hit(dir)
		hitbox_collision.disabled = false

func _hitbox_off():
	hitbox_collision.disabled = true
