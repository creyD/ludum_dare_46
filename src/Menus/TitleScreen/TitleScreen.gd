extends Control
class_name TitleScreen

signal startup_finished

export(int) var startup_finish_frame = 538

onready var new_game_button = $VBoxContainer/NewGameButton
onready var animation_player = $AnimationPlayer
onready var startup= $Startup

var finished_once := false


func _ready():
	startup.start()
	animation_player.play("__INIT__")
	SoundControler.pub_play_music("res://Menus/Sounds/menu_theme.ogg", false)


func _process(_delta):
	if not finished_once and Input.is_action_just_pressed("skip"):
		startup.animation = "loop"
		startup.frame = 0

	if startup.animation == "loop":
		if not finished_once:
			emit_signal("startup_finished")
			new_game_button.ignore_once = true # Pauls russian solution for ignoring the first sound click in the titlescreen
			new_game_button.grab_focus()
			animation_player.play("show_buttons")
			finished_once = true


func _exit_tree():
	SoundControler.pub_stop_music()
