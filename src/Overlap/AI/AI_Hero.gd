extends KinematicBody2D

class_name Hero

const PrioQueue = preload("prio_queue.gd") # Relative path
const Grid = preload("res://Maps/Grid.gd")

var grid


enum{
	LENGTH,
	WAY
}

enum{
	STEP,
	ROLL,
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

var totalPrioTurn = 0
var executesTurn = false
var abortProb = 0.01

var targetFieldCur = [0,0]
var targetFieldUsed = false

var actionField = [0,0]
var actionFieldUsed = false

var threadTime = 0.4
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
	var prioVal = 40.0 - (float(currentHealth)/float(maxHealth))*40.0 
	var bonfire = prioVal
	var hearts = prioVal - 1
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
					cost += prios[Grid.Kind.BONFIRE] * 32
				Grid.Kind.SLOW: 
					cost += 1
	return cost
	
#return an heurestic of distance
# curr - current position
# targ - a target position
func h_fn(curr, target):
	return sqrt(pow(target[0]-curr[0],2)+pow(target[0]-curr[0],2))		
	
# currCost - currentCost
# target - position of the field to move to
func g_fn(currCost, target):
	return currCost +  getCost(target)

# Returns the list of adjacent nodes	
func adjacent(currentPosition, can_roll = true):
	var adj := []
	#adj.append([STEP, Vector2(0,0)])
	var p = currentPosition
	var pot_adj_step =	[[p[0]-1, p[1]-1],	[p[0]-1, p[1]-0],	[p[0]-1, p[1]+1],
						 [p[0]+0, p[1]-1],						[p[0]+0, p[1]+1],
						 [p[0]+1, p[1]-1],	[p[0]+1, p[1]+0],	[p[0]+1, p[1]+1]]
						
	var pot_adj_roll =	[[p[0]-2, p[1]-2],	[p[0]-2, p[1]-0],	[p[0]-2, p[1]+2],
						 [p[0]+0, p[1]-2],						[p[0]+0, p[1]+2],
						 [p[0]+2, p[1]-2],	[p[0]+2, p[1]+0],	[p[0]+2, p[1]+2]]
		
					
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
		if(grid.object_grid[next[0]][next[1]][0]!=Grid.Kind.WALL):
			continue
		if(grid.object_grid[next[0]][next[1]][0]!=Grid.Kind.WALL):
			if(i==0):
				if(grid.object_grid[next[0]+0][next[1]+1][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]+1][next[1]+0][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]+1][next[1]+1][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]+1][next[1]+2][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]+2][next[1]+1][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),2.1])
			if(i==1):
				if(grid.object_grid[next[0]+0][next[1]+1][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),2.0])
			if(i==2):
				if(grid.object_grid[next[0]-0][next[1]+1][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]-1][next[1]+0][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]-1][next[1]+1][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]-1][next[1]+2][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]-2][next[1]+1][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),2.1])
			if(i==3):
				if(grid.object_grid[next[0]+1][next[1]+0][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),2.0])
			if(i==4):
				if(grid.object_grid[next[0]-1][next[1]+0][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),2.0])
			if(i==5):
				if(grid.object_grid[next[0]+0][next[1]-1][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]+1][next[1]-0][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]+1][next[1]-1][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]+1][next[1]-2][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]+2][next[1]-1][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),2.1])
			if(i==6):
				if(grid.object_grid[next[0]+0][next[1]-1][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),2.0])
			if(i==7):
				if(grid.object_grid[next[0]-0][next[1]-1][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]-1][next[1]-0][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]-1][next[1]-1][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]-1][next[1]-2][0]!=Grid.Kind.WALL &&
				   grid.object_grid[next[0]-2][next[1]-1][0]!=Grid.Kind.WALL):
					adj.append([ROLL, Vector2(next[0],next[1]),2.1])
	
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
		for i in adj_list:
			var move_cost = i[2]
			
			var g_val = g_fn(node[1]+move_cost, i[1])
			var h_val = h_fn(i[1], target)
		
			#[g+h(x), g(x), current, from, kind]
			var new_node = [g_val+h_val, g_val,i[1], node[2], i[0]]
			Q.insert(new_node)
			
	return [NOTHING, [0,0]]



func makeMove(delta):
	
	#if(actionFieldUsed==true):
	#	var random = randf()
	#	if(random < mindChangeProbability):
	#		ExecutionState = AI_MOVE
	
	if ExecutionState == AI_MOVE:
		threadDelta = 0
		var currentPosition = grid._pixel_to_grid_coords(global_position)
		var calcNew = false
		var target
		var MoveAdvice
			
		if(actionFieldUsed==false):
			calcNew = true	
			
		if(calcNew==true):
			var enemyKind = calcEnemyKind()
			if(enemyKind==Grid.Kind.TERMINAL_SYMBOL):
				return
			target = grid.get_nearest(currentPosition, enemyKind)
			actionField = target
			actionFieldUsed = true
			MoveAdvice = getMoveDescription(currentPosition, target)
		else:
			MoveAdvice = getMoveDescription(currentPosition, actionField)
		grid.reset_history()
			
		target = MoveAdvice[1]
		if(MoveAdvice[0]==STEP):
			run(Vector2(target[0]-currentPosition[0], target[1]-currentPosition[1]), delta*4)
			targetFieldCur = target
			targetFieldUsed = true
			ai_movement_state = STEP
		elif(MoveAdvice[0]==ROLL):
			roll(Vector2(target[0]-currentPosition[0], target[1]-currentPosition[1]), delta*4)
			targetFieldCur = target 
			targetFieldUsed = true
		ExecutionState = EXECUTING
		
	elif ExecutionState == EXECUTING:
		if(targetFieldUsed):
			var cur = grid._pixel_to_grid_coords(global_position)
			var distance = sqrt(pow(cur[0]-targetFieldCur[0],2)+ pow(cur[1]-targetFieldCur[1],2))
			if(distance<0.4):
				targetFieldUsed = false
				ExecutionState = AI_MOVE
				if(targetFieldCur[0]==actionField[0]&&targetFieldCur[1]==actionField[1]):
					actionFieldUsed = false
			else:
				var currentPosition = grid._pixel_to_grid_coords(global_position)
				if(ai_movement_state==STEP):
					run(Vector2(targetFieldCur[0]-currentPosition[0], targetFieldCur[1]-currentPosition[1]), delta*4)
				elif(ai_movement_state==ROLL):
					run(Vector2(targetFieldCur[0]-currentPosition[0], targetFieldCur[1]-currentPosition[1]), delta*4)
		threadDelta = threadDelta + delta
		if(threadDelta>threadTime):
			ExecutionState = AI_MOVE
			actionFieldUsed = false

# API Interface for ai_hero -> methods are handled in player.gd
func attac(direction, delta):
	pass


func roll(direction, delta):
	pass


func run(direction, delta):
	pass
