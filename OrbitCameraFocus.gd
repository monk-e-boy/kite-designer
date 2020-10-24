extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(ev):
	if not ev is InputEventKey:
		return
		
	if ev.scancode == KEY_W and not ev.echo:
		self.transform.origin.y += 0.07

	if ev.scancode == KEY_S and not ev.echo:
		self.transform.origin.y -= 0.07

	if ev.scancode == KEY_D and not ev.echo:
		self.transform.origin.x += 0.07

	if ev.scancode == KEY_A and not ev.echo:
		self.transform.origin.x -= 0.07
