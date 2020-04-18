extends Control
class_name TitleScreen

onready var new_game_button = $"VBoxContainer/NewGameButton"
onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("__INIT__")

func _on_Startup_startup_finished():
	new_game_button.ignore_once = true # Pauls russian solution for ignoring the first sound click in the titlescreen
	new_game_button.grab_focus()
	animation_player.play("show_buttons")
