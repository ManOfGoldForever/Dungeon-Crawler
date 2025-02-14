extends Node3D



func enable_hitbox():
	get_node("HitBox").set_deferred("monitorable", true)
func disable_hitbox():
	get_node("HitBox").set_deferred("monitorable", true)
