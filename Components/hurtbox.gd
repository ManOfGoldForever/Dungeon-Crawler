class_name HurtBox
extends Area3D

signal received_damage(damage: int)

@export var health: Health

func _ready():
	connect("area_entered", on_area_entered)

func on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null:
		health.health -= hitbox.damage
		received_damage.emit(hitbox.damage)
