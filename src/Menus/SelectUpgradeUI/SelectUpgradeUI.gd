extends Control

const DrNDrPre = preload("res://Menus/DragNDrop/DragNDropUI.gd")
var DrNDr 


func _ready():
	DrNDr = get_tree().current_scene.get_node("CanvasLayer").get_node("DragNDropUI")
	
	

func starting():
	var randcards = [0,0,0]
	
	randcards[0] = randi() % DrNDrPre.cards.EMPTY
	while(DrNDr.usedCards[0]!=randcards[0] &&\
		 DrNDr.usedCards[1]!=randcards[0] &&\
		 DrNDr.usedCards[2]!=randcards[0] &&\
		 DrNDr.usedCards[3]!=randcards[0] &&\
		 DrNDr.usedCards[4]!=randcards[0]):
		randcards[1] = randi() % DrNDrPre.cards.EMPTY
	while(randcards[0] == randcards[1] &&\
		 DrNDr.usedCards[0]!=randcards[1] &&\
		 DrNDr.usedCards[1]!=randcards[1] &&\
		 DrNDr.usedCards[2]!=randcards[1] &&\
		 DrNDr.usedCards[3]!=randcards[1] &&\
		 DrNDr.usedCards[4]!=randcards[1]):
		randcards[1] = randi() % DrNDrPre.cards.EMPTY
		randcards[2] = randi() % DrNDrPre.cards.EMPTY
	while(randcards[0] == randcards[2] && randcards[1] == randcards[2] &&\
		 DrNDr.usedCards[0]!=randcards[2] &&\
		 DrNDr.usedCards[1]!=randcards[2] &&\
		 DrNDr.usedCards[2]!=randcards[2] &&\
		 DrNDr.usedCards[3]!=randcards[2] &&\
		 DrNDr.usedCards[4]!=randcards[2]):
		randcards[2] = randi() % DrNDrPre.cards.EMPTY
	var shownCards = []
	for i in range(2):
		match randcards[i]:
			DrNDrPre.cards.BANANA:
				shownCards.append(load("res://Objects/Banana/BananaCard.tscn").instance())
			DrNDrPre.cards.BARRIERE:
				shownCards.append(load("res://Objects/Barriere/BarrierCard.tscn").instance())
			DrNDrPre.cards.BARREL:
				shownCards.append(load("res://Objects/Barrel/BarrelCard.tscn").instance())
			DrNDrPre.cards.TORCH:
				shownCards.append(load("res://Objects/Torch/TorchCard.tscn").instance())
			DrNDrPre.cards.BEAR:
				shownCards.append(load("res://Objects/Traps/Bear/BearCard.tscn").instance())
			DrNDrPre.cards.FLAME:
				shownCards.append(load("res://Objects/Traps/Flame/FlameCard.tscn").instance())
			DrNDrPre.cards.SPIKE:
				shownCards.append(load("res://Objects/Traps/Spike/SpikeCard.tscn").instance())
			DrNDrPre.cards.SLIME:
				shownCards.append(load("res://Objects/Slime/SlimeCard.tscn").instance())
	for i in range(2):
		$Cards.add_child(shownCards[i])
	shownCards[0].global_position = Vector2(100,150)
	shownCards[1].global_position = Vector2(200,150)
	shownCards[2].global_position = Vector2(300,150)
	
	
func _on_Button_pressed():
	Engine.time_scale=1
	self.hide()
	pass # Replace with function body.

