class_name StateMachine
extends Node

var current_blend_position = Vector2.ZERO
var holding_weapon = false
var velocity = 0

@export var animation_tree : AnimationTree

@onready var camera = $"../Armature/Skeleton3D/Neck/Camera3D"
@onready var state_chart = $"../StateChart"
@onready var hand = $"../Armature/Skeleton3D/Arm/Hand"
@onready var Warrior = $"../../Warrior"
@onready var animation_player = $"../AnimationPlayer"

func _ready() -> void:
	animation_tree["parameters/is_dead/transition_request"] = "false"
	animation_tree["parameters/is_hurt/transition_request"] = "false"
	animation_tree["parameters/holding_weapon_jump/transition_request"] = "false"
	animation_tree["parameters/holding_weapon/transition_request"] = "false"
	animation_tree["parameters/holding_weapon_death/transition_request"] = "false"
	animation_tree["parameters/holding_weapon_hurt/transition_request"] = "false"
	animation_tree["parameters/on_floor/transition_request"] = "true"

func _on_moving_state_physics_processing(_delta: float) -> void:
	var camera_transform = camera.global_transform.basis
	var forward = -camera_transform.z.normalized()  # Camera's forward vector
	var right = camera_transform.x.normalized()    # Camera's right vector
	var relative_velocity = right * velocity.x + forward * velocity.z
	
	relative_velocity.y = 0

	if relative_velocity.length() > 0:
		relative_velocity = relative_velocity.normalized()
	var target_blend_position = Vector2(relative_velocity.x, relative_velocity.z)
	current_blend_position = current_blend_position.lerp(target_blend_position, 0.1)  # Adjust smoothness with 0.1
	if holding_weapon:
		animation_tree.set("parameters/Weapon Movement/blend_position", current_blend_position)
	else:
		animation_tree.set("parameters/Movement/blend_position", current_blend_position)



func _on_idle_state_physics_processing(_delta: float) -> void:
	current_blend_position = current_blend_position.lerp(Vector2.ZERO, 0.1)

	if holding_weapon:
		animation_tree.set("parameters/Weapon Movement/blend_position", current_blend_position)
	else:
		animation_tree.set("parameters/Movement/blend_position", current_blend_position)

	if current_blend_position.length() <= 0.01:
		current_blend_position = Vector2.ZERO  # Snap to zero to avoid lingering updates


func _on_on_jump_taken() -> void:
	animation_tree["parameters/on_floor/transition_request"] = "false"
	if holding_weapon:
		animation_tree["parameters/holding_weapon_jump/transition_request"] = "true"
	else:
		animation_tree["parameters/holding_weapon_jump/transition_request"] = "false"


func _on_on_grounded_taken() -> void:
	animation_tree["parameters/on_floor/transition_request"] = "true"


func _on_is_holding_weapon_state_physics_processing(_delta: float) -> void:
	# Trigger attack animation if a weapon is equipped
	if Input.is_action_just_pressed("Attack"):
		animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_not_holding_weapon_state_physics_processing(_delta: float) -> void:
	if holding_weapon:
		animation_tree["parameters/holding_weapon/transition_request"] = "true"
		state_chart.send_event("pickup_weapon")
