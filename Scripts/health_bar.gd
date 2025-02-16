extends ProgressBar

@export var player_health: Health
@export var player_hurtbox: HurtBox

func _ready() -> void:
	player_hurtbox.received_damage.connect(update)
	update()

func update():
	var health = player_health.health
	var max_health = player_health.max_health
	value = health * 100 / max_health
