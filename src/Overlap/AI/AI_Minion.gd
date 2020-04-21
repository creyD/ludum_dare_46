extends KinematicBody2D

class_name Minion

const Grid = preload("res://Maps/Grid.gd")

var grid
var lock = Mutex.new()

enum{
	STEP,
	NOTHING
}

enum{
	EXECUTING,
	AI_MOVE
}

var ExecutionState = AI_MOVE
var ai_movement_state = NOTHING

var numbers = [0,0,0,0,0,0,0,0,0,0]
var prios = [0,7,0,0,0,0,0,0,3,0]

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

	var move = STEP
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

func movement_decider_ai(target, kindOfStep, delta):
	var currentPosition = grid._pixel_to_grid_coords(global_position)

	run(Vector2(target[0]-currentPosition[0], target[1]-currentPosition[1]), delta*4)
	targetFieldCur = target
	ai_movement_state = STEP

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

func run(direction, delta):
	pass

#todo
