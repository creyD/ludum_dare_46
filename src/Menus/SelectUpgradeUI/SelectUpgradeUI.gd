extends Control

const DrNDrPre = preload("res://Menus/DragNDrop/DragNDropUI.gd")
var DrNDr 
var cardPositions = [Vector2(100,150),Vector2(200,150),Vector2(300,150)]
var randcards = [0,0,0]
var showCards = true
var shownCards = []
var allowChoosCards = false

func _ready():
	DrNDr = get_tree().current_scene.get_node("CanvasLayer").get_node("DragNDropUI")
	
	

func starting():
	if (showCards):
		randcards[0] = randi() % DrNDrPre.cards.EMPTY
		while(DrNDr.usedCards[0]==randcards[0] or
			 DrNDr.usedCards[1]==randcards[0] or
			 DrNDr.usedCards[2]==randcards[0] or
			 DrNDr.usedCards[3]==randcards[0] or
			 DrNDr.usedCards[4]==randcards[0]):
			randcards[0] = randi() % DrNDrPre.cards.EMPTY
		randcards[1] = randi() % DrNDrPre.cards.EMPTY
		while(randcards[0] == randcards[1] or
			 DrNDr.usedCards[0]==randcards[1] or
			 DrNDr.usedCards[1]==randcards[1] or
			 DrNDr.usedCards[2]==randcards[1] or
			 DrNDr.usedCards[3]==randcards[1] or
			 DrNDr.usedCards[4]==randcards[1]):
			randcards[1] = randi() % DrNDrPre.cards.EMPTY
		randcards[2] = randi() % DrNDrPre.cards.EMPTY
		while(randcards[0] == randcards[2] or randcards[1] == randcards[2] or
			 DrNDr.usedCards[0]==randcards[2] or
			 DrNDr.usedCards[1]==randcards[2] or
			 DrNDr.usedCards[2]==randcards[2] or
			 DrNDr.usedCards[3]==randcards[2] or
			 DrNDr.usedCards[4]==randcards[2]):
			randcards[2] = randi() % DrNDrPre.cards.EMPTY
	
		print(randcards)
		for i in range(3):
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
				#DrNDrPre.cards.SLIME:
					#shownCards.append(load("res://Objects/Slime/SlimeCard.tscn").instance())
		for i in range(3):
			$Cards.add_child(shownCards[i])
		shownCards[0].set_begin (cardPositions[0])
		shownCards[1].set_begin (cardPositions[1])
		shownCards[2].set_begin (cardPositions[2])
		
		for i in range(3):
			shownCards[i].canNotPlace = true 
			shownCards[i].margin_bottom = shownCards[i].margin_top+32
			shownCards[i].margin_right = shownCards[i].margin_left+32
		var i = 0
		allowChoosCards = true
	else:
		pass
	
func _input(event):
	if((event is InputEventMouseButton) && allowChoosCards):
		for card in range(3):
			if(event.global_position[0] >= cardPositions[card][0] &&
				event.global_position[0] >= cardPositions[card][0]+32 &&
				event.global_position[1] >= cardPositions[card][1] &&
				event.global_position[1] >= cardPositions[card][1]+32):
					for i in range(5):
						if (DrNDr.usedCards[i] == DrNDrPre.cards.EMPTY):
							DrNDr.usedCards[i] = randcards[card]
							Engine.time_scale=1
							allowChoosCards = false
							self.hide()
							if (i == 4):
								showCards = false
							for j in range(3):
								shownCards[j].queue_free()
							return


func _on_Button_pressed():
	Engine.time_scale=1
	self.hide()
	pass # Replace with function body.

