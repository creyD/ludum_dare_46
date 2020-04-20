extends StaticBody2D

export(int,1,10) var health = 1
var GreenDrop = 0.4
var BlueDrop = 0.5
var RedDrop = 0.8
var Heart = 0.2

func offset_vec():
	var offset = 16
	return Vector2((randf()-0.5)*offset, (randf()-0.5)*offset)

func _on_Hurtbox_area_entered(area):
	health -= area.damage
	if(health>0):
		return
	queue_free()
	var GreenRubies = load("res://Objects/Rubies/Green.tscn")
	var BlueRubies = load("res://Objects/Rubies/Blue.tscn")
	var RedRubies = load("res://Objects/Rubies/Red.tscn")
	var Hearts = load("res://Objects/Heart/Heart.tscn")
	
	#index of ysort
	var world = get_tree().current_scene.get_node("YSort")
	if(randf()<GreenDrop):
		var green = GreenRubies.instance()
		world.add_child(green)
		green.global_position = global_position+offset_vec()
	elif(randf()<BlueDrop):
		var blue = BlueRubies.instance()
		world.add_child(blue)
		blue.global_position = global_position+offset_vec()
	elif(randf()<RedDrop):
		var red = RedRubies.instance()
		world.add_child(red)
		red.global_position = global_position+offset_vec()
	if(randf()<Heart):
		var heart = Hearts.instance()
		world.add_child(heart)
		heart.global_position = global_position+offset_vec()
	
