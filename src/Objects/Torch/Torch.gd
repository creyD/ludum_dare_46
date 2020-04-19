extends Node2D

export(int, 1, 5) var lifePoints = 3
export(int, 1, 30) var spawnRate = 5

var elapsedTime = 0.0

func _physics_process(delta):
	elapsedTime += delta
	#if(elapsedTime>=spawnRate):
	#	elapsedTime-=spawnRate
	#	var Minion = load("")
	#	var world = get_tree().current_scene.get_child(2)
	#	#TODO minions
	#	var minion = Minion.instance()
	#	world.add_child(minion)
	#	minion.global_position = global_position


func _on_Hurtbox_area_entered(area):
	lifePoints -= area.damage
	if(lifePoints<0):
		queue_free()
	pass
