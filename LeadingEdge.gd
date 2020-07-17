extends MeshInstance


export(SpatialMaterial) var material

# Called when the node enters the scene tree for the first time.
func _ready():
	var surface_tool = SurfaceTool.new()
	
	# TODO replace with self.get_mesh
	var mesh = Mesh.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	#surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	surface_tool.set_material(material)
	
	#sq(surface_tool, Vector3(-5,0,0), 0)
	#sq(surface_tool, Vector3(-3,0,0), 4)
	
	tube(surface_tool, Vector3(-5,-2,0), 9)
	
	surface_tool.generate_normals()
	surface_tool.index()
	
	surface_tool.commit(mesh)
	self.set_mesh(mesh)


func sq(surface_tool, pos: Vector3, i):
	#var i = surface_tool.get
	# top right - clockwise
	surface_tool.add_vertex(pos + Vector3(0,1,1))
	surface_tool.add_vertex(pos + Vector3(0,1,0))
	surface_tool.add_vertex(pos + Vector3(0,0,0))
	surface_tool.add_vertex(pos + Vector3(0,0,1))

	surface_tool.add_index(i+0)
	surface_tool.add_index(i+1)
	surface_tool.add_index(i+2)
	
	surface_tool.add_index(i+2)
	surface_tool.add_index(i+3)
	surface_tool.add_index(i+0)

# cylinder cut by plane is an ellipse:
# https://www.quora.com/You-have-a-cylindrical-water-bottle-diameter-1-1-unit-volume-of-water-inside-infinite-height-When-tilted-so-the-angle-it-makes-with-the-flat-ground-is-20-degrees-what-is-the-area-of-the-ellipse-the-waters-surface
#
# unroll a cylinder cut by a plane
# https://www.geogebra.org/m/FMy4E7f4
#
# SPOKE is like the spoke on a wagon wheel
#       we find one then rotate it 360 / faces angle
# PROFILE angle, looking from front, the angle of the
#       profile from vertical (middle of kite is vertical)

var start_pos = Vector3(0,0,0)
var start_profile_angle = 0;

func tube(surface_tool, pos: Vector3, i):
	var LE_curve = -10;
	var profile_angle = -20;  # depends on this tube LE_curve and the next
	var tube_length = 1.5;
	var tube_radius = 0.6
	
	var faces = 4
	var angle = 360.0/float(faces)
	
	var start = Vector3(0,tube_radius,0)
	var v = start
	
	var left = []
	var right = []
	
	
	for i in range(faces):
		left.append(v+Vector3(0,0,0))
		v = start.rotated(Vector3(1,0,0), deg2rad((i+1) * angle))
	
	start = Vector3(0,tube_radius,0)
	v = start
	var tube_length_v = Vector3(tube_length,0,0)
	for i in range(faces):
		v = v.rotated(Vector3(0,0,1), deg2rad(profile_angle))  # rotate to PROFILE angle
		v += tube_length_v                                     # move from ORIGIN to end of tube
		right.append(v)
		# get next SPOKE
		v = start.rotated(Vector3(1,0,0), deg2rad((i+1) * angle))
	
	var right_tmp = []
	for vec_r in right:
		right_tmp.append(vec_r.rotated(Vector3(0,0,1), deg2rad(LE_curve)))
	
	right = right_tmp
	
	for i in range(faces):
		surface_tool.add_vertex(left[i])
		surface_tool.add_vertex(right[i])
	
	# draw the faces - two triangles
	var j = 0
	for i in range(faces-1):
		# top triangle
		surface_tool.add_index(j)
		surface_tool.add_index(j+1)
		surface_tool.add_index(j+2)
		# bottom triangle
		surface_tool.add_index(j+1)
		surface_tool.add_index(j+3)
		surface_tool.add_index(j+2)
		j += 2
	
	# join the end of the tube to the start
	# top triangle
	surface_tool.add_index(0)
	surface_tool.add_index(1)
	surface_tool.add_index(faces * 2 - 1) # <-- right
	# bottom triangle
	surface_tool.add_index(0)
	surface_tool.add_index(faces * 2 - 1) # <-- left
	surface_tool.add_index(faces * 2 - 2) # <-- right



func tube_old4(surface_tool, pos: Vector3, i):
	
	var faces = 27
	var angle = 360.0/float(faces)
	
	var origin = Vector3(0,0,0)
	var start = Vector3(0,0.5,0.5)
	var v = start
	
	var left = []
	var right = []
	
	
	for i in range(faces):
		left.append(v+Vector3(-2,0,0))
		right.append(v+Vector3(2,0,0))
		v = start.rotated(Vector3(1,0,0), deg2rad((i+1) * angle))
	
	for i in range(faces):
		surface_tool.add_vertex(left[i])
		surface_tool.add_vertex(right[i])
	
	# draw the faces - two triangles
	var j = 0
	for i in range(faces-1):
		# top triangle
		surface_tool.add_index(j)
		surface_tool.add_index(j+1)
		surface_tool.add_index(j+2)
		# bottom triangle
		surface_tool.add_index(j+1)
		surface_tool.add_index(j+3)
		surface_tool.add_index(j+2)
		j += 2
	
	# join the end of the tube to the start
	# top triangle
	surface_tool.add_index(0)
	surface_tool.add_index(1)
	surface_tool.add_index(faces * 2 - 1) # <-- right
	# bottom triangle
	surface_tool.add_index(0)
	surface_tool.add_index(faces * 2 - 1) # <-- left
	surface_tool.add_index(faces * 2 - 2) # <-- right
	


func tube_old3(surface_tool, pos: Vector3, i):
	
	var faces = 30
	var angle = 360.0/float(faces)
	
	var origin = Vector3(0,0,0)
	var start = Vector3(0,0.5,0.5)
	var v = start
	
	var left = []
	var right = []
	
	
	for i in range(faces):
		left.append(v+Vector3(-2,0,0))
		right.append(v+Vector3(2,0,0))
		v = start.rotated(Vector3(1,0,0), deg2rad((i+1) * angle))
	
	surface_tool.add_vertex(origin+Vector3(-2,0,0))
	for vec in left:
		surface_tool.add_vertex(vec)
		
	for i in range(faces-1):
		surface_tool.add_index(0)
		surface_tool.add_index(i+2)
		surface_tool.add_index(i+1)

	surface_tool.add_index(0)
	surface_tool.add_index(1)
	surface_tool.add_index(faces)

	#
	surface_tool.add_vertex(right[0])
	surface_tool.add_index(2)
	surface_tool.add_index(1)
	surface_tool.add_index(faces+1)
	
	surface_tool.add_vertex(right[1])
	surface_tool.add_index(2)
	surface_tool.add_index(faces+1)
	surface_tool.add_index(faces+2)


	
func tube_old2(surface_tool, pos: Vector3, i):
	
	var faces = 4
	var angle = 360.0/float(faces)
	
	var origin = Vector3(0,0,0)
	var start = Vector3(0.5,0.5,0)
	var v = start
	
	var left = []
	var right = []
	
	
	for i in range(faces):
		left.append(v)
		right.append(v+Vector3(0,0,1))
		v = start.rotated(Vector3(0,0,1), deg2rad((i+1) * angle))
	
	surface_tool.add_vertex(origin)
	for vec in left:
		surface_tool.add_vertex(vec)
		
	for i in range(faces-1):
		surface_tool.add_index(0)
		surface_tool.add_index(i+2)
		surface_tool.add_index(i+1)

	surface_tool.add_index(0)
	surface_tool.add_index(1)
	surface_tool.add_index(faces)
	

func tube_old(surface_tool, pos: Vector3, i):
	
	var rad = 0;
	var angle = 45.0
	var tl = Vector3(-1,1,0)
	var origin = Vector3(0,0,0)
	
	var tr = tl.rotated(Vector3(0,0,1), rad)
	var br = tr.rotated(Vector3(0,0,1), rad)
	var bl = br.rotated(Vector3(0,0,1), rad)
	
	
	surface_tool.add_vertex(origin)
	surface_tool.add_vertex(tl)
	surface_tool.add_vertex(tr)
	surface_tool.add_vertex(br)
	surface_tool.add_vertex(bl)
	
	surface_tool.add_index(0)
	surface_tool.add_index(1)
	surface_tool.add_index(2)
	
	surface_tool.add_index(0)
	surface_tool.add_index(2)
	surface_tool.add_index(3)
	
	surface_tool.add_index(0)
	surface_tool.add_index(3)
	surface_tool.add_index(4)

	surface_tool.add_index(0)
	surface_tool.add_index(4)
	surface_tool.add_index(1)
	
	return
	
	var left = Vector3(0,0,0)
	var right = Vector3(0,0,0)
	
#	var angle = 0
	
	for i in range(1):

		surface_tool.add_vertex(left)
		surface_tool.add_vertex(right)
		
		
		angle += 10
#		var rad = deg2rad(angle)
	
		var a = left.rotated(Vector3(1,0,0), rad)
		var b = right.rotated(Vector3(1,0,0), rad)
	
		surface_tool.add_vertex(a)
		surface_tool.add_vertex(b)
		
		var offset = i * 4
	
		surface_tool.add_index(offset)
		surface_tool.add_index(offset+1)
		surface_tool.add_index(offset+2)
	
		#surface_tool.add_index(offset+1)
		#surface_tool.add_index(offset+3)
		#surface_tool.add_index(offset+2)
		
		
	#surface_tool.index()
	
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load():
	var file = File.new()
	file.open("user://save-files/kite-1.txt", File.READ)
	while not file.eof_reached():
		var line = file.get_line()
#		if line.begins_with("LE")
	file.close()
	
	
	#return content
