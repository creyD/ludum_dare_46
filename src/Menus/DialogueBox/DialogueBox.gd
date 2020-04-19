extends Control
class_name DialougeBox

export(int, 0, 100) var dialogue_identifier := 0 setget set_dialogue_identifier
signal started
signal finished

var _dialogue_pos = -1
onready var dialogues := $Dialogues
var _dialogue = []

onready var label = $Label
onready var animation_player = $AnimationPlayer

var first_action = true

func _physics_process(delta):
	if Input.is_action_just_pressed("skip"):
		if(first_action):
			set_dialogue_identifier(dialogue_identifier)
			update_text()
			first_action != first_action
		next()

func set_dialogue_identifier(val):
	dialogue_identifier = val
	_dialogue = dialogues.get_dialogue(val)
	animation_player.play("begin_dialouge")
	yield(animation_player, "animation_finished")
	_dialogue_pos = 0


func update_text():
	print(_dialogue[_dialogue_pos])
	label.text = _dialogue[_dialogue_pos]
	animation_player.play("next_line")
	yield(animation_player, "animation_finished")


func next():
	_dialogue_pos += 1
	if(_dialogue_pos>=_dialogue.size()):
		_dialogue_pos = 0
	update_text()
