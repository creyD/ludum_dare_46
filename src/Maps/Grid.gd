extends Node

const Kind = preload("res://Overlap/Kind.gd") # Relative path
onready var aStar_node = AStar.new()

var path_start_position : Vector2= Vector2() setget _set_path_start_position
var path_end_position : Vector2 = Vector2() setget _set_path_end_position

var obstacles = []
var _point_path = []
var _half_cell_size = Vector2()

var object_grid : Array = []
var prio_grid : Array = []
var time_passed := 0.0
var offset
export(float, 0, 42.0) var refresh_rate = 0.4

func _point_coors(point : Vector2):
	return 14*point.y+point.x

func _ready():
	var walls = get_tree().current_scene.get_node("FloorTileMap")
	offset = walls.global_position


	for x in range(14):
		object_grid.push_back([])
		prio_grid.push_back([])
		for y in range(7):
			object_grid[x].push_back([Kind.FIELD])
			prio_grid[x].push_back([Kind.TERMINAL_SYMBOL])

	
	for tile in walls.get_used_cells():
		if(is_in_coord(tile)):
			object_grid[tile.x][tile.y][0] = Kind.WALL
			obstacles.push_back(Vector2(tile.x, tile.y))

	var walkableCells = []
	for y in range(7):
		for x in range(14):
			if object_grid[x][y][0] == Kind.FIELD:
				walkableCells.push_back(Vector2(x,y))
				var Index = _point_coors(Vector2(x,y))
				aStar_node.add_point(Index, Vector3(x,y,0.0))
	
	#add points	straight		
	for point in walkableCells:
		var point_index = _point_coors(point)
		
		var points_relative_str = PoolVector2Array([
			Vector2(point.x + 1, point.y),	
			Vector2(point.x - 1, point.y),	
			Vector2(point.x , point.y + 1),	
			Vector2(point.x , point.y - 1)
		])
		for point_rel in points_relative_str:
			var point_relative_index = _point_coors(point_rel)
			
			if point_rel == point or not is_in_coord(point_rel):
				continue
			if not aStar_node.has_point(point_relative_index):
				continue
			aStar_node.connect_points(point_index, point_relative_index, true)
			
	#diagonal
	for point in walkableCells:
		var point_index = _point_coors(point)
		
		var points_relative_dia = PoolVector2Array([
			Vector2(point.x + 1, point.y + 1), Vector2(point.x, point.y + 1), Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y + 1), Vector2(point.x, point.y + 1), Vector2(point.x - 1, point.y),
			Vector2(point.x + 1, point.y - 1), Vector2(point.x, point.y - 1), Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y - 1), Vector2(point.x, point.y - 1), Vector2(point.x - 1, point.y)
		])
			
		for i in range(points_relative_dia.size()/3):
			var p_targ = points_relative_dia[i*3]
			var p_ch1 = points_relative_dia[i*3+1]
			var p_ch2 = points_relative_dia[i*3+2]
			
			var p_targ_c = _point_coors(p_targ)
			var p_ch1_c = _point_coors(p_targ)
			var p_ch2_c = _point_coors(p_targ)
			
			if p_targ == point or not is_in_coord(p_targ) and not aStar_node.has_point(p_targ_c):
				continue
			if p_ch1 == point or not is_in_coord(p_ch1) and not aStar_node.has_point(p_ch1_c):
				continue
			if p_ch2 == point or not is_in_coord(p_ch2) and not aStar_node.has_point(p_ch2_c):
				continue
				
			aStar_node.connect_points(point_index, p_targ_c, true)
	
	
func recalculate_path():
	_point_path = []
	var start_index = _point_coors(path_start_position)
	var end_index = _point_coors(path_end_position)
	_point_path = aStar_node.get_point_path(start_index, end_index)

func _reset_grids():
	for x in range(14):
		for y in range(7):
			while (object_grid[x][y].size() != 1):
				object_grid[x][y].pop_back()
			while (prio_grid[x][y].size() != 1):
				prio_grid[x][y].pop_back()


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

func get_fields_around(point):
	var points_relative_str = PoolVector2Array([
		Vector2(point.x + 1, point.y + 1),
		Vector2(point.x - 1, point.y + 1), 
		Vector2(point.x + 1, point.y - 1),
		Vector2(point.x - 1, point.y - 1)
	])
	var point_list = []
	for point_rel in points_relative_str:
		var point_relative_index = _point_coors(point_rel)		
		if point_rel == point or not is_in_coord(point_rel):
			continue
		if not aStar_node.has_point(point_relative_index):
			continue
		point_list.push_back(point_rel)
	return point_list
		

func _update_grid():
	_reset_grids()
	var world = get_tree().current_scene.get_node("YSort")
	for node in world.get_children():
		var node_kind = node.get_node("Kind")
		var grid_corrds = _pixel_to_grid_coords(node.global_position)
		if (is_in_coord(grid_corrds)):
			if(node_kind.general != Kind.FIELD and node_kind.general != Kind.WALL):
				object_grid[grid_corrds.x][grid_corrds.y].push_back(node_kind.general)
			prio_grid[grid_corrds.x][grid_corrds.y].push_back(node_kind.kind)
	
	for y in range(7):
		for x in range(14):
			var index = _point_coors(Vector2(x,y))
			var scale = 1.0
			for val in object_grid[x][y]:
				match val:
					Kind.DAMAGE:
						scale += 16
					Kind.HEALING:
						scale -= 8
					Kind.SLOW:
						scale += 8
			var neighboor_list = get_fields_around(Vector2(x,y))
			for neighboor in neighboor_list:
				for val in object_grid[neighboor.x][neighboor.y]:
					match val:
						Kind.DAMAGE:
							scale += 16
						Kind.HEALING:
							scale -= 8
						Kind.SLOW:
							scale += 8
			if(scale<0):
				scale = 0
			aStar_node.set_point_weight_scale(index, scale)

func _physics_process(delta):
	if(time_passed > refresh_rate):
		time_passed -= refresh_rate
		_update_grid()
	time_passed += delta


func is_in_coord(point):
	if point[0]<0 || point[0]>13:
		return false
	if point[1]<0 || point[1]>6:
		return false
	return true

func _set_path_start_position(value : Vector2):
	if value in obstacles:
		return
	if not is_in_coord(value):
		return
	
	path_start_position = value



func _set_path_end_position(value : Vector2):
	if value in obstacles:
		return
	if not is_in_coord(value):
		return
	
	path_end_position = value
