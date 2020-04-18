extends Button
class_name TitleSceenButton

export(String, FILE, "*.tscn,*.scn") var scene_to_load = ""
export(bool) var quit = false
onready var sound_focus = $Sounds/FocusChange
onready var sound_select = $Sounds/OptionSelect
var ignore_once = false

func _pressed():
	sound_select.play()
	

func _on_OptionSelect_finished():
	if quit:
		get_tree().quit()
		return
		
	get_tree().change_scene(scene_to_load)


func _on_TitleScreenButton_mouse_entered():
	grab_focus()


func _on_TitleScreenButton_focus_entered():
	if not ignore_once:
		sound_focus.play()
	ignore_once = false
