extends Node3D

func enable_hitbox():
	get_node("HitBox/CollisionShape3D").set_deferred("disabled", false)

func disable_hitbox():
	get_node("HitBox/CollisionShape3D").set_deferred("disabled", true)
