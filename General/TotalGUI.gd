extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_player_one_movement(movement_type):
	get_node("AddGUI/PlayerOneGUI/VBoxContainer/Movement").text = movement_type
func set_player_two_movement(movement_type):
	get_node("AddGUI/PlayerTwoGUI/VBoxContainer/Movement").text = movement_type