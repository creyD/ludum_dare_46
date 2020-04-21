extends Node

var _dialogues = []

func _ready():
	_dialogues.append([
		"Hero: I... I... I need to go pee",
		"Boss: After this you won't need to pee ever again!"
	])
	_dialogues.append([
		"Hero: I've come to slay you, you beast!",
		"Boss: Well then... step forward!"
	])
	_dialogues.append([
		"Hero: You've killed so many, but you won't kill me!",
		"Boss: We'll see about that!"
	])

func get_dialogue(id):
	return _dialogues[id]
