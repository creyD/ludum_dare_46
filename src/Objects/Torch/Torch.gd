extends Node2D

export(int, 1, 5) var lifePoints = 3
export(float, 0, 30) var spawnRate = 5.0
var Minion = load("res://Boss/Minion.tscn")

var elapsedTime = 0.0

func offset_vec():
	var offset = 16
	return Vector2((randf()-0.5)*offset, (randf()-0.5)*offset)

func _physics_process(delta):
	elapsedTime += delta
	if(elapsedTime>=spawnRate):
		elapsedTime-=spawnRate
		var world = get_tree().current_scene.get_child(2)
		var minion = Minion.instance()
		world.add_child(minion)
		minion.global_position = global_position+offset_vec()


func _on_Hurtbox_area_entered(area):
	lifePoints -= area.damage
	if(lifePoints<=0):
		queue_free()
	pass
