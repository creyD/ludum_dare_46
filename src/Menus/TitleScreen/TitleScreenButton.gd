extends Button
class_name TitleSceenButton

export(String, FILE, "*.tscn,*.scn") var scene_to_load = ""
export(bool) var quit = false

func _pressed():
	if quit:
		get_tree().quit()
		return
		
	get_tree().change_scene(scene_to_load)
