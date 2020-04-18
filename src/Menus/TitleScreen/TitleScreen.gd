extends Control
class_name TitleScreen

onready var new_game_button = $"VBoxContainer/NewGameButton"

func _ready():
	new_game_button.grab_focus()


func _on_Startup_startup_finished():
	pass # Replace with function body.
