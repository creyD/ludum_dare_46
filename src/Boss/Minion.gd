extends Minion

var velocity := Vector2.ZERO

# This is how you export variables with ranges to the editor window
export(int, 0, 500) var ACCELERATION := 450
# Reference for the current player

onready var player_stats := $Stats
onready var debug_label := $DebugLabel

var damage_per_second := 0.0
var totaldamage := 0.0

var rollvector = Vector2.ZERO

func _debug_update():
	debug_label.text = str(player_stats.health) + "/" + str(player_stats.max_health) + " HP\n"

func _ready():
	grid = get_tree().current_scene.get_node("Grid")

# IMPORTANT: If you are using move_and_slide don't multiply by delta
# Godots physics system does that internally
# In move_and_collide(...) you have to multiply by delta.	
func move():
	move_and_slide(velocity)
	_animate(velocity)

func _physics_process(delta):
	totaldamage += damage_per_second * delta
	player_stats.speed += 10 * delta
	while (totaldamage > 1):
		totaldamage -= 1
		player_stats.health -= 1
	while (totaldamage <- 1):
		totaldamage += 1
		player_stats.health += 1
	_debug_update()
	
	run(Vector2.ZERO, delta)
	makeMove(delta)
	move()


func _on_Stats_no_health():
	queue_free()


func _on_Hurtbox_area_entered(area):
	player_stats.health -= area.damage
	damage_per_second += area.damage


func _on_Hurtbox_area_exited(area):
	damage_per_second -= area.damage
	
# API Interface for ai_hero
func run(direction, delta):
	direction = direction.normalized()
	rollvector = direction
	velocity = velocity.move_toward(player_stats.speed * rollvector, ACCELERATION * delta)
	
	if direction == Vector2.ZERO:
		pass
	else:
		pass

func _animate(vec):
	match get_nearest_diretion(vec):
		"up":
			$Sprite.flip_h=false
			$Sprite.play("up")
		"down":
			$Sprite.flip_h=false
			$Sprite.play("down")
		"right":
			$Sprite.flip_h=false
			$Sprite.play("right")
		"left":
			$Sprite.flip_h=true
			$Sprite.play("right")
	



func get_nearest_diretion(vec):
	var directions = {
		"up": Vector2(0, -1.1),
		"down": Vector2(0, 1.1),
		"left": Vector2(-1.0, 0),
		"right": Vector2(1.0, 0)
	}

	var nearest_direction = "left"
	var smallest_distance = 999999999

	for direction in directions.keys():
		var vector = directions.get(direction)
		var distance = vec.distance_to(vector)

		if distance < smallest_distance:
			nearest_direction = direction
			smallest_distance = distance

	return nearest_direction
