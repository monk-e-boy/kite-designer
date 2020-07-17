extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var is_moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
func _input(event):
	var camera_drag = true
	var mouse_sens = 1.0
	if event is InputEventMouseButton:
		if (event.is_pressed() and event.button_index == BUTTON_LEFT):
			is_moving = true
		else:
			is_moving = false
	
	if event is InputEventMouseMotion and is_moving:
	
			#if event is InputEventMouseMotion and camera_drag:
			#$FocusPoint.rotate_object_local(Vector3(0,0,0), event.relative.y * PI/360)
			#$FocusPoint.rotate_object_local(Vector3(0,0,0), event.relative.x * PI/360)
			var tmp = self.get_position_in_parent()
			self.rotate_object_local(Vector3(0,0,0), deg2rad(3))
			self.look_at(Vector3(0,0,0), Vector3(0,0,0))
			#self.rotate_y(deg2rad(event.relative.x*mouse_sens))
