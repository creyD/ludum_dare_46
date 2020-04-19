extends StaticBody2D

var GreenDrop = 0.5
var BlueDrop = 0.4
var RedDrop = 0.2
var Heart = 0.2

func offset_vec():
	var offset = 16
	return Vector2((randf()-0.5)*offset, (randf()-0.5)*offset)

func _on_Hurtbox_area_entered(area):
	queue_free()
	var GreenRubies = load("res://Objects/Rubies/Green.tscn")
	var BlueRubies = load("res://Objects/Rubies/Blue.tscn")
	var RedRubies = load("res://Objects/Rubies/Red.tscn")
	var Hearts = load("res://Objects/Heart/Heart.tscn")
	
	#index of ysort
	var world = get_tree().current_scene.get_child(2)
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
	
