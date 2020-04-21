extends Node2D

var cur_line = -1
var text = [
	"Hello, my friend.",
	"Sorry, I am a bit shy...",
	"But I need your help.",
	"Everyday new \"heroes\" come into my chamber",
	"and try to kill me.",
	"I'm not strong and sometimes I worry",
	"they might actually succeed.",
	"Please help me defend myself.",
	"You can use these cards of mine.",
	"And after every hero you defeat",
	"I will give you a new one.",
	"I will give you multiple options even.",
	"So you can choose and collect!",
	"Im counting on you!"
]
onready var label = $CanvasLayer/CenterContainer/HBoxContainer/Label
onready var finished_indicator = $CanvasLayer/CenterContainer/HBoxContainer/VBoxContainer/FinishedIndicator

export(String, FILE, "*.tscn,*.scn") var scene_to_load = ""


func _ready():
	next()


func _physics_process(delta):
	if Input.is_action_just_pressed("dialogue_advance"):
		next()


func next():
	finished_indicator.modulate = Color(1, 1, 1, 0)
	cur_line += 1

	if cur_line >= text.size():
		get_tree().change_scene(scene_to_load)
		return

	var line = text[cur_line]

	label.text = line
	$Tween.interpolate_property(label, "percent_visible",
	0, 1, 0.05 * len(line))
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	finished_indicator.modulate = Color(1, 1, 1, 1)
