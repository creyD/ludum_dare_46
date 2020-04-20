extends "res://Overlap/StateMachine/State.gd"

onready var animation_player = owner.get_node("AnimationPlayer")

func play_directional_animation(name, vec):
	var anim_name = name + get_nearest_diretion(vec)
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func get_base_anim_name(name):
	var base_name = name[0]
	for i in range(1, len(name)):
		if name[i] == name[i].to_upper():
			return base_name
		
		base_name += name[i]

func get_nearest_diretion(vec):
	var directions = {
		"Up": Vector2(0, -1.1),
		"Down": Vector2(0, 1.1),
		"Left": Vector2(-1.0, 0),
		"Right": Vector2(1.0, 0)
	}
	
	var nearest_direction = "Left"
	var smallest_distance = 999999999
	
	for direction in directions.keys():
		var vector = directions.get(direction)
		var distance = vec.distance_to(vector)
		
		if distance < smallest_distance:
			nearest_direction = direction
			smallest_distance = distance
	
	return nearest_direction
	
	
