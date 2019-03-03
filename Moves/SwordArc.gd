extends Area2D

var remain = 0
var theCollision
var direction
var hitslist = []

func _init():
	connect("body_entered", self, "collision")

func start(disp):
	print("Sword generated")
	direction = disp
	position = Vector2(disp,0)
	remain = 0.3

func _physics_process(delta):
	if remain <= 0:
		position = Vector2(9999,9999)
	else:
		remain = remain - delta
	#theCollision = move_and_collide(Vector2(0,0))
	#if theCollision != null:
	#	collision(theCollision.get_collider())
		
func collision(body):
	# origin, type, damage, direction, force, stun, flystun
	if hitslist.find(body) == -1 && body.has_method("hit") && body != get_parent():
		if direction > 0: # right
			body.hit(get_parent(), "sword", 5, 45, 200, 0.1, 0.1)
		else: #left
			body.hit(get_parent(), "sword", 5, -45, 200, 0.1, 0.1)
	hitslist.append(body)