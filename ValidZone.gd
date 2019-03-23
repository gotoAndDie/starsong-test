extends Area2D


func _ready():
	connect("body_exited", self, "body_exited")
	pass

func body_exited(body):
	print(body)
	if body.has_method("out"):
		body.out()
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
