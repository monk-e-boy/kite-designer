extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	# DrawLine3D.DrawLine(Vector3(0, 0, 0), Vector3(1, 2, 0), Color(0, 0, 1))
	var Cam = get_viewport().get_camera()
	var ScreenPointStart = null
	var ScreenPointEnd = null
	
#	for x in range(9):
#		ScreenPointStart = Cam.unproject_position(Vector3(2*x, 0, 50))
#		ScreenPointEnd = Cam.unproject_position(Vector3(2*x, 0, -50))
#		draw_line(ScreenPointStart, ScreenPointEnd, Color(0.5,0.5,0.5,1), 1)

	ScreenPointStart = Cam.unproject_position(Vector3(0, 0, 5))
	ScreenPointEnd = Cam.unproject_position(Vector3(0, 0, -5))
#	draw_line(ScreenPointStart, ScreenPointEnd, Color(0.5,1,0.5,1), 2)
#
#	for x in range(9):
#		ScreenPointStart = Cam.unproject_position(Vector3(-10*x, 0, 50))
#		ScreenPointEnd = Cam.unproject_position(Vector3(-10*x, 0, -50))
#		draw_line(ScreenPointStart, ScreenPointEnd, Color(0.5,0.5,0.5,1), 1)
	
	#draw_line(Vector2(0,0), Vector2(100,100), Color(0,1,0,1))
