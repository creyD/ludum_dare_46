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

var numbers = [0,0,0,0,0,0,0,0,0,0]
var prios = [7,0,6,5,4,3,2,0,0,4]

var totalPrioTurn = 0
var executesTurn = false
var abortProb = 0.01

var targetField = [0,0]
var targetFieldUsed = false
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

#updates heart and bonfire prio
func adjustPrio(currentHealth, maxHealth):
	var prioVal = 10 - (currentHealth/maxHealth)*10
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
	while table[i] <= number:
		i += 1
	return i

#returns a move
func getMoveDescription(myPosition : Vector2, targetPositions):
	return AStar(myPosition, targetPositions)


func getCost(field):
	var cost = 0
	for i in grid.prio_grid[field.x][field.y]:
			match i:
				Grid.Kind.DAMAGE: 
					cost += prios[Grid.kind.BONFIRE] * 6
				Grid.Kind.SLOW: 
					cost += 2
	return cost
	
#return an heurestic of distance
# curr - current position
# targ - a target position
func h(curr, target):
	return min(abs(target[0]-curr[0]),abs(target[0]-curr[0]))		
	
# currCost - currentCost
# target - position of the field to move to
func g(currCost, target):
	return currCost +  getCost(target)

# Returns the list of adjacent nodes	
func adjacent(currentPosition, can_roll = false):
	var adj := []
	#adj.append([STEP, Vector2(0,0)])
	var p = currentPosition
	var pot_adj_step = 	[[p[0]-1, p[1]-1],	[p[0]-1, p[1]-0],	[p[0]-1, p[1]+1],
						 [p[0]+0, p[1]-1],						[p[0]+0, p[1]+1],
						 [p[0]+1, p[1]-1],	[p[0]+1, p[1]+0],	[p[0]+1, p[1]+1]]
						
	var pot_adj_roll =	[[p[0]-2, p[1]-2],	[p[0]-2, p[1]-0],	[p[0]-2, p[1]+2],
						 [p[0]+0, p[1]-2],						[p[0]+0, p[1]+2],
						 [p[0]+2, p[1]-2],	[p[0]+2, p[1]+0],	[p[0]+2, p[1]+2]]
						
	for next in pot_adj_step:
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
			adj.append([STEP, Vector2(next[0],next[1])])

	if not can_roll:
		return adj

	for next in pot_adj_roll:
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
			adj.append([ROLL, Vector2(next[0],next[1])])
	
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
			var move_cost = 0
			if (i[0] == STEP):
				move_cost = 1
			else:
				move_cost = 2
			
			var g_val = g(node[1]+move_cost, i[1])
			var h_val = h(i[1], target)
		
			#[g+h(x), g(x), current, from, kind]
			var new_node = [g_val+h_val, g_val,i[1], node[2], i[0]]
			Q.insert(new_node)
			
	return [NOTHING, [0,0]]


func makeMove(delta):
	pass
	if ExecutionState == AI_MOVE:
		var currentPosition = grid._pixel_to_grid_coords(global_position)
		var enemyKind = calcEnemyKind()
		var targetField = grid.get_nearest(currentPosition, enemyKind)
		var MoveAdvice = getMoveDescription(currentPosition, targetField)
		print(MoveAdvice)
		ExecutionState = EXECUTING
		pass
	elif ExecutionState == EXECUTING:
		if(targetFieldUsed):
			pass
			var cur = grid._pixel_to_grid_coords(global_position)
			var distance = sqrt(pow(cur[0]-targetField[0],2)+ pow(cur[1]-targetField[1],2))
			if(distance<0.5):
				targetFieldUsed = false
				ExecutionState = AI_MOVE
	pass


# API Interface for ai_hero -> methods are handled in player.gd
func attac(direction, delta):
	pass


func roll(direction, delta):
	pass


func run(direction, delta):
	pass
