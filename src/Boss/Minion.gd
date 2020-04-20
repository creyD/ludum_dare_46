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
