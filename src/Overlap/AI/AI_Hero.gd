extends KinematicBody2D

class_name Hero

const PrioQueue = preload("prio_queue.gd") # Relative path
const Grid = preload("res://Maps/Grid.gd")

var grid
var lock = Mutex.new()

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

var threadTime = 0.4
var threadDelta = 0.0

var hitDelta = 0.0
var hitTreshhold = 0.1

var aiDelta = 0.0
var aiTreshhold = 0.4

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
	var prioVal = 20.0 - (float(currentHealth)/float(maxHealth))*20.0
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
func getMoveDescription(myPosition : Vector2, targetPositions : Vector2):
	grid.path_start_position = myPosition
	grid.path_end_position = targetPositions
	grid.recalculate_path()
	if(grid._point_path.size()<=1):
		return [NOTHING, [0,0]]
	var to = grid._point_path[1]
	var from = grid._point_path[0]
	var p1 = pow(to[0]-from[0],2)
	var p2 = pow(to[1]-from[1],2)
	
	var norm = sqrt(p1+p2)
	var move = STEP
	if(norm > 1.0 && p1 != p2):
		move = ROLL
	return [move, grid._point_path[1]]



func movement_calulcaotr():
	var currentPosition = grid._pixel_to_grid_coords(global_position)
	var enemyKind
	
	numbers = grid.countTargets(numbers)
	if(actionKind == grid.Kind.TERMINAL_SYMBOL || numbers[actionKind]==0 || actionFieldUsed==false):
		enemyKind = calcEnemyKind()
		actionKind = enemyKind
		actionFieldUsed = true
		if(enemyKind==Grid.Kind.TERMINAL_SYMBOL):
			return
	else:
		enemyKind = actionKind
		
	var targetField = grid.get_nearest(currentPosition, enemyKind)
	if(targetField==[-1,-1]):
		return	
		
	return getMoveDescription(currentPosition, Vector2(targetField[0], targetField[1]))
	

func is_hittable():
	var length = areaRefList.size()
	if length == 0:
		return null
	return instance_from_id(areaRefList[0]).global_position

func hit_or_miss(target, current, delta):
	attac(Vector2(target[0]-current[0], target[1]-current[1]), delta*4)

func movement_decider_ai(target, kindOfStep, delta):
	var currentPosition = grid._pixel_to_grid_coords(global_position)
	
	hitDelta -= hitTreshhold
	var currentPixel = global_position
	var hitPixelTarget = is_hittable()
	
	if hitPixelTarget!=null && randf()<0.5:
		hit_or_miss(hitPixelTarget, currentPixel, delta*4)
	else:
		if(kindOfStep==STEP):
			run(Vector2(target[0]-currentPosition[0], target[1]-currentPosition[1]), delta*4)
			targetFieldCur = target
			ai_movement_state = STEP
		elif(kindOfStep==ROLL):
			roll(Vector2(target[0]-currentPosition[0], target[1]-currentPosition[1]), delta*4)
			
		targetFieldCur = target 	
		targetFieldUsed = true
			
	ExecutionState = EXECUTING



func movement_execution(delta):	
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
					
					
func reset_exeution_state(delta):					
	threadDelta = threadDelta + delta
	if(threadDelta>threadTime):
		ExecutionState = AI_MOVE
		actionFieldUsed = false	


					
func makeMove(delta):
	lock.lock()
	if ExecutionState == AI_MOVE:
		threadDelta = 0
		var MoveAdvice = movement_calulcaotr()
		if(MoveAdvice==null):
			return
		var target = MoveAdvice[1]
		movement_decider_ai(target, MoveAdvice[0], delta)		
		
	if ExecutionState == EXECUTING:
		movement_execution(delta)
		reset_exeution_state(delta)
	lock.unlock()

# API Interface for ai_hero -> methods are handled in player.gd
func attac(direction, delta):
	pass


func roll(direction, delta):
	pass


func run(direction, delta):
	pass

#todo 
