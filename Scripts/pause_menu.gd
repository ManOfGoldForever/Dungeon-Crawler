extends Control

@onready var main = $"../"

func _on_resume_pressed() -> void:
	main.PauseMenu()

func _on_quit_pressed() -> void:
	var player_id = multiplayer.get_unique_id()
	print("deleting id:" + str(player_id))
	main.exit_game(player_id)
	get_tree().quit()
