extends Node2D

export(String, FILE, "*.tscn,*.scn") var restart_scene = ""
export(String, FILE, "*.tscn,*.scn") var title_screen = ""

func _on_Restart_pressed():
	get_tree().change_scene(restart_scene)
	SoundControler.pub_stop_effects()

func _on_TitleScreen_pressed():
	get_tree().change_scene(title_screen)
	SoundControler.pub_stop_effects()
