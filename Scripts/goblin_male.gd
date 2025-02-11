extends CharacterBody3D


@export var speed = 5.0
@export var jump_velocity = 4.5
@export var gravity = -9.8

@onready var animation_player = $AnimationPlayer

var dead = false

func _on_health_health_depleted() -> void:
	dead = true
	animation_player.play("Death", 1)
	
	


func _on_hurt_box_received_damage(_damage: int) -> void:
	if not dead:
		animation_player.play("RecieveHit")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Death":
		queue_free()
