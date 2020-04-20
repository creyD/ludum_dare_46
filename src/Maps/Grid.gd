extends Node

const Kind = preload("res://Overlap/Kind.gd") # Relative path

var object_grid : Array = []
var prio_grid : Array = []
var used_grid : Array = []
var time_passed := 0.0
var offset
export(float, 0, 42.0) var refresh_rate = 0.0


func _draw_object_grid():
	for y in range(7):
		var stri = ""
		for x in range(14):
			stri += str(object_grid[x][y]) + " "
		print(stri)
	print()


func _draw_prio_grid():
	for y in range(7):
		var stri = ""
		for x in range(14):
			stri += str(prio_grid[x][y]) + " "
		print(stri)
	print()


func _reset_grids():
	for x in range(14):
		for y in range(7):
			while (object_grid[x][y].size() != 1):
				object_grid[x][y].pop_back()
			while (prio_grid[x][y].size() != 1):
				prio_grid[x][y].pop_back()


func _ready():

	var walls = get_tree().current_scene.get_node("FloorTileMap")
	offset = walls.global_position
	#todo put in grid_lul
	for x in range(14):
		object_grid.push_back([])
		prio_grid.push_back([])
		used_grid.push_back([])
		for y in range(7):
			object_grid[x].push_back([Kind.FIELD])
			prio_grid[x].push_back([Kind.TERMINAL_SYMBOL])
			used_grid[x].push_back(false)

	for tile in walls.get_used_cells():
		if(_is_in_grid(tile)):
			object_grid[tile.x][tile.y][0] = Kind.WALL

	_update_grid()


func reset_history():
	for x in range(14):
		for y in range(7):
			used_grid[x][y] = false


func countTargets(table):
	for i in range(table.size()):
		table[i]=0
	
	for x in range(14):
		for y in range(7):
			for i in prio_grid[x][y]:
				if i == Kind.TERMINAL_SYMBOL:
					continue
				table[i] += 1
	return table


func _pixel_to_grid_coords(pixel : Vector2) -> Vector2:
	var new_coords : Vector2
	new_coords.x = floor((pixel.x-offset.x) / 32.0)
	new_coords.y = floor((pixel.y-offset.y) / 32.0)
	return new_coords


func _is_in_grid(grid_coords : Vector2) -> bool:
	if(grid_coords.x < 0):
		return false
	if(grid_coords.x > 13):
		return false
	if(grid_coords.y < 0):
		return false
	if(grid_coords.y > 6):
		return false
	return true


func get_nearest(position, kind):
	var list = []
	for x in range(14):
		for y in range(7):
			for i in prio_grid[x][y]:
				if(i == kind):
					list.append([x, y])
	if list.size() == 0:
		return[-1,-1]
	var dist = []
	for field in list:
		var tmp = sqrt(pow(position[0] - field[0], 2) + pow(position[1] - field[1], 2))
		dist.append(tmp)
	var mini = 0
	for i in range(1, dist.size()):
		if(dist[i] < dist[mini]):
			mini = i
	return list[mini]


func _update_grid():
	_reset_grids()
	var world = get_tree().current_scene.get_node("../YSort")
	for node in world.get_children():
		var node_kind = node.get_node("Kind")
		var grid_corrds = _pixel_to_grid_coords(node.global_position)
		if (_is_in_grid(grid_corrds)):
			if(node_kind.general != Kind.FIELD and node_kind.general != Kind.WALL):
				object_grid[grid_corrds.x][grid_corrds.y].push_back(node_kind.general)
			prio_grid[grid_corrds.x][grid_corrds.y].push_back(node_kind.kind)


func _physics_process(delta):
	if(time_passed > refresh_rate):
		time_passed -= refresh_rate
		_update_grid()
	time_passed += delta
