extends Node

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

var numbers = [0,0,0,0,0,0,0,0,0]
var prios = [7,6,5,4,3,2,0,0,4]

var totalPrioTurn = 0
var executesTurn = false
var abortProb = 0.01

func calcTotalPrio():
	var sum = 0
	var i = BOSS
	while i != TERMINAL_SYMBOL:
		if(numbers[i]>0):
			sum += prios[i]
		i=i+1
	return sum
	
func calcRelPrio(index, sum):
	return prios[index]/sum
	
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

func adjustPrio(currentHealth, maxHealth):
	var prioVal = 10 - (currentHealth/maxHealth)*10
	var bonfire = prioVal
	var hearts = prioVal -1
	if(hearts < 0):
		hearts = 0
	prios[BONFIRE]=bonfire
	prios[HEART]=hearts

func calcEnemie():
	var table = calcPrioTable()
	var number = randf()
	var i = TERMINAL_SYMBOL-1
	while table[i] > number:
		i=i-1
	return i
	
func getMoveDescription(myPosition : Vector2, targetPositions):
	var way = AStar(myPosition, targetPositions[0])

	for i in range(1, targetPositions.size()):
		var tmp_way = AStar(myPosition, targetPositions[i])
		if(tmp_way[LENGTH] < way[LENGTH]):
			way = tmp_way
	return way[WAY]
	
func h(curr, targ):
	return sqrt(pow(curr,2)+pow(targ,2))	
	
func h(curr, position):
		
	
func AStar(source, target):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	prios[BOSS] = 1
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
