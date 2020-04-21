extends Button
class_name TitleSceenButton

export(String, FILE, "*.tscn,*.scn") var scene_to_load = ""
export(bool) var quit = false
var ignore_once = false


func _pressed():
	SoundControler.pub_play_effect("res://Menus/Sounds/menu_option_select.ogg",0)
	if quit:
		get_tree().quit()
		return

	get_tree().change_scene(scene_to_load)


func _on_TitleScreenButton_mouse_entered():
	grab_focus()


func _on_TitleScreenButton_focus_entered():
	if not ignore_once:
		SoundControler.pub_play_effect("res://Menus/Sounds/menu_focus_change.ogg",0)
	ignore_once = false
