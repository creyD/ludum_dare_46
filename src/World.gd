extends Node2D

export(PackedScene) var HeroTemplate
export(Vector2) var Spawnpoint=Vector2(344,125)

func _ready():
	randomize()
	spawn_new_hero(Spawnpoint.x,Spawnpoint.y)
	pass # Replace with function body.

func hero_has_died():
	Engine.time_scale=0
	spawn_new_hero(Spawnpoint.x,Spawnpoint.y)
	$CanvasLayer/SelectUpgradeUI.show()


func spawn_new_hero(x:float,y:float):
	var hero = HeroTemplate.instance()
	hero.position=Vector2(x,y)
	$YSort.add_child(hero)
