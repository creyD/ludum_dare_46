extends Node2D

export(int) var WinRounds= 10
export(PackedScene) var HeroTemplate
export(Vector2) var InitialSpawnPoint=Vector2(344,125)
export(Rect2) var SpawnBoxRange=Rect2(40,40,450,180)
export(float) var MinDistanceToBoss=100.0


var round_counter=0
var passed_final_Round=false

func _ready():
	randomize()
	var point = determine_spawnpoint()
	spawn_new_hero(point.x,point.y)
	#spawn_new_hero(InitialSpawnPoint.x,InitialSpawnPoint.y)


func determine_spawnpoint():
	var point = Vector2(rand_range(SpawnBoxRange.position.x,SpawnBoxRange.position.x+SpawnBoxRange.size.x),rand_range(SpawnBoxRange.position.y,SpawnBoxRange.position.y+SpawnBoxRange.size.y))
	while(point.distance_to($YSort/SlimeBoss.position)<MinDistanceToBoss):
		point = Vector2(rand_range(SpawnBoxRange.position.x,SpawnBoxRange.position.x+SpawnBoxRange.size.x),rand_range(SpawnBoxRange.position.y,SpawnBoxRange.position.y+SpawnBoxRange.size.y))
	return point
	

func hero_has_died():
	round_counter+=1
	if (round_counter>=WinRounds and passed_final_Round ==false):
		passed_final_Round=true
		$CanvasLayer/Win.show()
	
	Engine.time_scale=0
	var point = determine_spawnpoint()
	spawn_new_hero(point.x,point.y)
	$CanvasLayer/SelectUpgradeUI.show()
	$CanvasLayer/SelectUpgradeUI.starting()


func spawn_new_hero(x:float,y:float):
	var hero = HeroTemplate.instance()
	hero.position=Vector2(x,y)
	hero.name = "Player"
	$YSort.add_child(hero)


func _on_Win_pressed():
	if passed_final_Round:
		#TODO CHANGE SCENE TO WINSCREEN
		pass
	pass # Replace with function body.
