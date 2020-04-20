extends Container

const Grid = preload("res://Maps/Grid.gd")
onready var grid = get_tree().current_scene.get_node("Grid")
onready var ysort = get_tree().current_scene.get_node("YSort")

#DropZone
#stuff can be dropped here
func can_drop_data(_pos, data):
	return typeof(data) == typeof(PackedScene)


func get_nearest_grid_pos(position):
	return Vector2(round(position.x / 32.0), round(position.y / 32.0))


func get_nearest_global_pos(position):
	return Vector2(round(position.x / 32.0) * 32, round(position.y / 32.0) * 32)


#what is to be done when data is dropped
func drop_data(_pos, data:PackedScene):
	var new_pos = get_nearest_grid_pos(_pos)

	if grid.object_grid[new_pos.x - 1][new_pos.y - 1].back() == Grid.Kind.FIELD:
		var child = data.instance()
		child.position = get_nearest_global_pos(_pos)

		ysort.add_child(child)
		grid._update_grid()
