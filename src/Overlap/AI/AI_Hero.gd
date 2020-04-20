extends KinematicBody2D

class_name Hero

const PrioQueue = preload("prio_queue.gd") # Relative path
const Grid = preload("res://Maps/Grid.gd")

var grid

enum{
	STEP,
	ROLL,
	ATTAC,
	NOTHING
}

enum{
	EXECUTING,
	AI_MOVE
}

var ExecutionState = AI_MOVE
var ai_movement_state = NOTHING

var numbers = [0,0,0,0,0,0,0,0,0,0]
var prios = [7,0,6,5,4,3,2,1,1,4]

var targetFieldCur = [0,0]
var targetFieldUsed = false

var actionKind = Grid.Kind.TERMINAL_SYMBOL
var actionFieldUsed = false

var areaRefList = []

var threadTime = 0.6
var threadDelta = 0.0

#calculates  the sum of all present prios
func calcTotalPrio():
	var sum = 0
	var i = Grid.Kind.BOSS
	while i != Grid.Kind.TERMINAL_SYMBOL:
		if(numbers[i]>0):
			sum += prios[i]
		i += 1
	return sum
	
#calculates the relative porio
func calcRelPrio(index, sum) -> float:
	if(sum==0):
		return 0.0
	return float(prios[index])/float(sum)
	
#calucaltes the prio table of all enemies[0,1)
func calcPrioTable():
	var table = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
	numbers = grid.countTargets(numbers)
	var lower = 0.0
	var sum = calcTotalPrio()
	
	var i = 0;
	while i != Grid.Kind.TERMINAL_SYMBOL:
		if(numbers[i]!=0):
			lower += calcRelPrio(i, sum)
		table[i] = lower
		i += 1
		
	return table
#14+7 0.999
#updates heart and bonfire prio
func adjustPrio(currentHealth, maxHealth):
	var prioVal = 10.0 - (float(currentHealth)/float(maxHealth))*10.0
	var bonfire = prioVal + 1
	var hearts = prioVal 
	if(hearts < 0):
		hearts = 0
	prios[Grid.Kind.BONFIRE]=bonfire
	prios[Grid.Kind.HEART]=hearts

#return the enemie which will be attacked
func calcEnemyKind():
	var table = calcPrioTable()
	var number = randf()
	var i = 0
	while i!=Grid.Kind.TERMINAL_SYMBOL and table[i] <= number:
		i += 1
	return i

#returns a move
func getMoveDescription(myPosition : Vector2, targetPositions):
	return AStar(myPosition, targetPositions)


func getCost(field):
	var cost = 0
	for i in grid.object_grid[field.x][field.y]:
			match i:
				Grid.Kind.DAMAGE: 
					cost += 100
				Grid.Kind.SLOW: 
					cost += 1	
	return cost
	
#return an heurestic of distance
# curr - current position
# targ - a target position
func h_fn(curr, target):
	return 0	
	
# currCost - currentCost
# target - position of the field to move to
func g_fn(currCost, target):
	return currCost +  getCost(target)

# Returns the list of adjacent nodes	
func adjacent(currentPosition, can_roll = true):
	var adj := []
	#adj.append([STEP, Vector2(0,0)])
	var p = currentPosition
	var pot_adj_step =	[[p[0]-1, p[1]-1],	[p[0]-0, p[1]-1],	[p[0]+1, p[1]-1],
						 [p[0]-1, p[1]-0],						[p[0]+1, p[1]+0],
						 [p[0]-1, p[1]+1],	[p[0]+0, p[1]+1],	[p[0]+1, p[1]+1]]
						
	var pot_adj_roll =	[[p[0]-0, p[1]-2],
						 [p[0]-2, p[1]-0],[p[0]+2, p[1]+0],
						 [p[0]+0, p[1]+2]]
		
					
	for i in range(pot_adj_step.size()):
		var next = pot_adj_step[i]
		if(next[0]<0):
			continue
		if(next[0]>13):
			continue
		if(next[1]<0):
			continue
		if(next[1]>6):
			continue
		if(grid.used_grid[next[0]][next[1]]):
			continue
		if(grid._is_in_grid(Vector2(next[0], next[1])) ==false):
			continue	
		if(grid.object_grid[next[0]][next[1]][0]!=Grid.Kind.WALL):
			if(i==0):
				if(grid.object_grid[pot_adj_step[1][0]][pot_adj_step[1][1]][0]!=Grid.Kind.WALL &&
				   grid.object_grid[pot_adj_step[3][0]][pot_adj_step[3][1]][0]!=Grid.Kind.WALL):
					adj.append([STEP, Vector2(next[0],next[1]),1.1])
				continue
			if(i==2):
				if(grid.object_grid[pot_adj_step[1][0]][pot_adj_step[1][1]][0]!=Grid.Kind.WALL &&
				   grid.object_grid[pot_adj_step[4][0]][pot_adj_step[4][1]][0]!=Grid.Kind.WALL):
					adj.append([STEP, Vector2(next[0],next[1]),1.1])
				continue
			if(i==5):
				if(grid.object_grid[pot_adj_step[3][0]][pot_adj_step[3][1]][0]!=Grid.Kind.WALL &&
				   grid.object_grid[pot_adj_step[6][0]][pot_adj_step[6][1]][0]!=Grid.Kind.WALL):
					adj.append([STEP, Vector2(next[0],next[1]),1.1])
				continue
			if(i==7):
				if(grid.object_grid[pot_adj_step[4][0]][pot_adj_step[4][1]][0]!=Grid.Kind.WALL &&
				   grid.object_grid[pot_adj_step[6][0]][pot_adj_step[6][1]][0]!=Grid.Kind.WALL):
					adj.append([STEP, Vector2(next[0],next[1]),1.1])
				continue
			
			adj.append([STEP, Vector2(next[0],next[1]),1.0])


	for i in range(pot_adj_roll.size()):
		var next = pot_adj_roll[i]
		if(next[0]<0):
			continue
		if(next[0]>13):
			continue
		if(next[1]<0):
			continue
		if(next[1]>6):
			continue
		if(grid.used_grid[next[0]][next[1]]):
			continue
		if(grid._is_in_grid(Vector2(next[0], next[1])) == false):
			continue	
		if(grid.object_grid[next[0]][next[1]][0]!=Grid.Kind.WALL):
			if(i==0):
				if(grid.object_grid[next[0]+0][next[1]+1][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),1.0])
			if(i==1):
				if(grid.object_grid[next[0]+1][next[1]+0][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),1.0])
			if(i==2):
				if(grid.object_grid[next[0]-1][next[1]+0][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),1.0])
			if(i==3):
				if(grid.object_grid[next[0]+0][next[1]-1][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),1.0])
	
	return adj


func AStar(source, target):
	#swap rtarget and source, when target source istr reached, do inversxse step
	# node layout [g+h(x), g(x), current, from, kind]
	var tmp = source
	source = target
	target = tmp

	var Q = PrioQueue.new()
	Q.insert([0,0, [source[0], source[1]], [source[0], source[1]], NOTHING] )
	while !Q.empty():
		var node = Q.delMin()
		
		# Check if reached
		if(node[2][0] == target[0] and node[2][1] == target[1]):
			return  [node[4], node[3]] # 4 is kind | 3 is from
			
		# Set flag
		grid.used_grid[node[2][0]][node[2][1]] = true
		var adj_list = adjacent(node[2])
		var current_field = node[2]
		for i in adj_list:
			var move_cost = i[2]
			
			var g_val = g_fn(node[1]+move_cost, i[1])
			var h_val = h_fn(i[1], target)
		
			#[g+h(x), g(x), current, from, kind]
			var new_node = [g_val+h_val, g_val,i[1], node[2], i[0]]
			Q.insert(new_node)
			
	return [NOTHING, [0,0]]


func movement_calulcaotr():
	var currentPosition = grid._pixel_to_grid_coords(global_position)
		
	var enemyKind
	
	numbers = grid.countTargets(numbers)
	if(actionKind == grid.Kind.TERMINAL_SYMBOL || numbers[actionKind]==0 || actionFieldUsed==false):
		enemyKind = calcEnemyKind()
		actionKind = enemyKind
		actionFieldUsed = true
	else:
		enemyKind = actionKind
		
	if(enemyKind==Grid.Kind.TERMINAL_SYMBOL):
		return
		
	var targetField = grid.get_nearest(currentPosition, enemyKind)
	if(targetField==[-1,-1]):
		return
		
		
	var MoveAdvice = getMoveDescription(currentPosition, targetField)
	grid.reset_history()
	
	return MoveAdvice

func is_hittable():
	var length = areaRefList.size()
	if length == 0:
		return null
	return instance_from_id(areaRefList[0]).global_position

func hit_or_miss(target, current, delta):
	attac(Vector2(target[0]-current[0], target[1]-current[1]), delta*4)

func movement_decider_ai(target, kindOfStep, delta):
	var currentPosition = grid._pixel_to_grid_coords(global_position)
	var currentPixel = global_position
	var hitPixelTarget = is_hittable()
	
	if hitPixelTarget!=null:
		hit_or_miss(hitPixelTarget, currentPixel, delta*4)

	else:
		if(kindOfStep==STEP):
			run(Vector2(target[0]-currentPosition[0], target[1]-currentPosition[1]), delta*4)
			targetFieldCur = target
			targetFieldUsed = true
			ai_movement_state = STEP
		elif(kindOfStep==ROLL):
			roll(Vector2(target[0]-currentPosition[0], target[1]-currentPosition[1]), delta*4)
			targetFieldCur = target 
			targetFieldUsed = true
	ExecutionState = EXECUTING



func movement_execution(delta):
	var currentPixel = global_position
	var hitPixelTarget = is_hittable()
	
	if hitPixelTarget!=null:
		hit_or_miss(hitPixelTarget, currentPixel, delta*4)
		return
	
	if(targetFieldUsed):
		var cur = grid._pixel_to_grid_coords(global_position)
		var distance = sqrt(pow(cur[0]-targetFieldCur[0],2)+ pow(cur[1]-targetFieldCur[1],2))
		if(distance<0.1):
			targetFieldUsed = false
			ExecutionState = AI_MOVE
			var actionField = grid.get_nearest(cur, actionKind)
			if(targetFieldCur[0]==actionField[0]&&targetFieldCur[1]==actionField[1]):
				actionFieldUsed = false
		else:
			var currentPosition = grid._pixel_to_grid_coords(global_position)
			if(ai_movement_state==STEP):
				run(Vector2(targetFieldCur[0]-currentPosition[0], targetFieldCur[1]-currentPosition[1]), delta*4)
			elif(ai_movement_state==ROLL):
				run(Vector2(targetFieldCur[0]-currentPosition[0], targetFieldCur[1]-currentPosition[1]), delta*4)
	else:
		ExecutionState = AI_MOVE				
					
func reset_exeution_state(delta):					
	threadDelta = threadDelta + delta
	if(threadDelta>threadTime):
		ExecutionState = AI_MOVE
		actionFieldUsed = false	


					
func makeMove(delta):	
	if ExecutionState == AI_MOVE:
		threadDelta = 0
		var MoveAdvice = movement_calulcaotr()
		if(MoveAdvice==null):
			return
		var target = MoveAdvice[1]
		movement_decider_ai(target, MoveAdvice[0], delta)		
		
	elif ExecutionState == EXECUTING:
		movement_execution(delta)
		reset_exeution_state(delta)
		

# API Interface for ai_hero -> methods are handled in player.gd
func attac(direction, delta):
	pass


func roll(direction, delta):
	pass


func run(direction, delta):
	pass

#todo 
