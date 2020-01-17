extends Node2D

var initPos = Vector2(465, 100)

func _ready():
	get_node("player").target = get_node("player2")
	get_node("player2").target = get_node("player")