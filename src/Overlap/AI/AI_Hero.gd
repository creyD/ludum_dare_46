extends Node
const PrioQueue = preload("prio_queue.gd") # Relative pat

enum{
	BOSS,
	TORCH,
	MINION,
	RED,
	BLUE,
	GREEN,
	HEART,
	BONFIRE,
	BARREL,
	TERMINAL_SYMBOL
}

enum{
	LENGTH,
	WAY
}

enum{
	DAMAGE,
	SLOW,
	WALL,
	FIELD
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

var Grid = []
var used_Flags = []

var numbers = [0,0,0,0,0,0,0,0,0]
var prios = [7,6,5,4,3,2,0,0,4]

var totalPrioTurn = 0
var executesTurn = false
var abortProb = 0.01

#calculates  the sum of all present prios
func calcTotalPrio():
	var sum = 0
	var i = BOSS
	while i != TERMINAL_SYMBOL:
		if(numbers[i]>0):
			sum += prios[i]
		i=i+1
	return sum
	
#calculates the relative porio
func calcRelPrio(index, sum):
	return prios[index]/sum
	
#calucaltes the prio table of all enemies[0,1)
func calcPrioTable():
	var table = [0,0,0,0,0,0,0,0,0]
	var lower = 0
	var sum = calcTotalPrio()
	
	var i = 0;
	while i != TERMINAL_SYMBOL:
		lower += calcRelPrio(i, sum)
		table[i] = lower
		i = i+1
		
	return table

#updates heart and bonfire prio
func adjustPrio(currentHealth, maxHealth):
	var prioVal = 10 - (currentHealth/maxHealth)*10
	var bonfire = prioVal
	var hearts = prioVal -1
	if(hearts < 0):
		hearts = 0
	prios[BONFIRE]=bonfire
	prios[HEART]=hearts

#return the enemie which will be attacked
func calcEnemy():
	var table = calcPrioTable()
	var number = randf()
	var i = 0
	while table[i] > number:
		i=i+1
	return i
	
func getTargetField(currentField):
	return [0,0]
	pass
	#todo
	
#returns a move
func getMoveDescription(myPosition : Vector2, targetPositions):
	var way = AStar(myPosition, targetPositions[0])

	#TODO choose enemie with loest distance
	return 0
	

func getFieldState(position):
	#todo
	pass
	
func getCost(field):
	# var cost = 0
	# for i in Feld[position.x][position.y]:
	#		match i:
	#			DAMAGE : cost += damage*prios[BONFIRE]*3
	#			SLOW : cost += 2
	#
	#return cost
	return 0
	
#return an heurestic of distance
# curr - current position
# targ - atarget position
func h(curr, target):
	return min(abs(target[0]-curr[0]),abs(target[0]-curr[0]))		
	
# currCost - currentCost
# target - position of the field to move to
func g(currCost, target):
	return currCost +  getCost(target)

#returns the list of adjacent nodes	
func adjacent(currentPosition):
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
		if(used_Flags[next[0]][next[1]]==true):
			continue
		if(Grid[next[0]][next[1]][0]!=WALL):
			adj.append([STEP, Vector2(next[0],next[1])])
			
	for next in pot_adj_roll:
		if(next[0]<0):
			continue
		if(next[0]>13):
			continue
		if(next[1]<0):
			continue
		if(next[1]>6):
			continue
		if(used_Flags[next[0]][next[1]]==true):
			continue
		if(Grid[next[0]][next[1]][0]!=WALL):
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
		
		#check if reached
		if(node[2][0]==target[0] and node[2][1]==target[1]):
			return  [node[4], 0]#todo map movement]
			
		#set flag
		used_Flags[node[2][0]][node[2][1]] = true
		var adj_list = adjacent(node[2])
		for i in adj_list:
			var move_cost = 0
			if(i[0]==STEP):
				move_cost = 1
			else:
				move_cost = 2
			
			var g_val = g(node[1]+move_cost, i[1])
			var h_val = h(i[1], target)
		
			#[g+h(x), g(x), current, from, kind]
			var new_node = [g_val+h_val, g_val,i[1], node, i[0]]
			Q.insert(new_node)
			
	return [NOTHING, 0]

func makeMove():
	match ExecutionState:
		EXECUTING:
			pass
		AI_MOVE:
			var field = [0.1*prios[BONFIRE], 1]
			var decision = randf()
			var i = 0
			while field[i] > decision:
				i=i+1
			if(i==0):
				var targetField = getTargetField(currentField)
				
			else:
				pass
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
