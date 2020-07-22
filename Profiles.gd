extends MeshInstance

export(SpatialMaterial) var material
#var yaml = preload("res://addons/godot-yaml/gdyaml.gdns").new()
var points = []

var points1 = [
	[0.0,  0.0],
	[20,  -12],
	[30,  -12],
	[50,   0.0],
	[50,   10],
	[30,   22],
	[20,   22],
	[0,    10],
	[0,    0]
]

# TODO - flatten shows errors
var points2 = [
	[0.000000,0.000000],
	[0,-8],
	[20,-12],
	[40,-16],
	[60,0]
]


var points12 = [
	[0.000000,0.000000],
	[-50,3],
	[-60,0]
]


var points3 = [
	[0.000000,0.000000],
	[30,-9],
	[60,0]
]

var points7 = [
	[0.000000,0.000000],
	[5,0],
	[5,2],
	[20,8.062000],
	[50,0],
	[50,-5],
	[55,-5],
	[55,0],
	[80,-8],
	[90,0],
	[100.000000,0.000000]
]

var points6 = [
	[100.000000,0.000000],
	[95.023000,0.881000],
	[90.049000,1.739000],
	[85.070000,2.618000],
	[80.084000,3.492000],
	[75.089000,4.344000],
	[70.087000,5.153000],
	[65.076000,5.899000],
	[60.057000,6.562000],
	[55.031000,7.125000],
	[50.000000,7.567000],
	[44.964000,7.894000],
	[39.924000,8.062000],
	[34.882000,8.059000],
	[29.840000,7.872000],
	[24.800000,7.499000],
	[19.765000,6.929000],
	[14.735000,6.138000],
	[9.718000,5.063000],
	[7.218000,4.379000],
	[4.727000,3.544000],
	[2.257000,2.460000],
	[1.041000,1.719000],
	[0.567000,1.320000],
	[0.336000,1.071000],
	[0.000000,0.000000],
	[0.664000,-0.871000],
	[0.933000,-1.040000],
	[1.459000,-1.291000],
	[2.743000,-1.716000],
	[5.273000,-2.280000],
	[7.782000,-2.685000],
	[10.282000,-2.995000],
	[15.265000,-3.446000],
	[20.235000,-3.745000],
	[25.200000,-3.919000],
	[30.160000,-3.984000],
	[35.111800,-3.939000],
	[40.076000,-3.778000],
	[45.035000,-3.514000],
	[50.000000,-3.164000],
	[54.969000,-2.745000],
	[59.943000,-2.278000],
	[64.924000,-1.799000],
	[69.913000,-1.265000],
	[74.911000,-0.764000],
	[79.916000,-0.308000],
	[84.930000,0.074000],
	[89.951000,0.329000],
	[94.977000,0.330000],
	[100.000000,0.000000]
]

var kite = {
	"le-tube": true,
	"center-y": 1.0
}

var atts = []

var profiles = []

class Profile:
	var points = []
	var atts = {}
	func _init(pts, atts):
		self.points = get_vectors(pts, atts)
		self.atts = atts
	
	func mirror():
		for i in range(points.size()):
			points[i].x *= -1


	func get_vectors(pts, atts):
		var center_y = 1#kite["center-y"]
		
		var tmp = []
		for p in pts:
			tmp.append(Vector3(0,p[1],p[0]))
			
		# flip Z
		for i in range(tmp.size()):
			tmp[i] *= Vector3(1,1,-1)
		
		# normalise (0-1)
		for i in range(tmp.size()):
			tmp[i] /= Vector3(1,100.0,100.0)
	
		# SCALE
		for i in range(tmp.size()):
			tmp[i] *= Vector3(0, atts["height"], atts["length"])
		
		# AoA
		for i in range(tmp.size()):
			tmp[i] = tmp[i].rotated(Vector3(1,0,0), deg2rad(atts["AoA"]))
			
		# sweep
		for i in range(tmp.size()):
			tmp[i] += Vector3(0, 0, atts["sweep"])
			
		# rotate around Z -> C shaped kite
		for i in range(tmp.size()):
			tmp[i] = tmp[i].rotated(Vector3(0,0,1), deg2rad(atts["angle"]))
			
		# Push RIGHT
		for i in range(tmp.size()):
			tmp[i] += Vector3(atts["distance"],0,0)
			
		# rotate DOWN
		for i in range(tmp.size()):
			tmp[i] = tmp[i].rotated(Vector3(0,0,1), deg2rad(atts["offset-y-angle"]))
		
		# TRANSLATE Y ... we are
		for i in range(tmp.size()):
			tmp[i] += Vector3(0,center_y,0)
	
		return tmp


func load_atts():
	var file = File.new()
	file.open("user://kite.txt", File.READ)
	
	atts = []
	var default = {
		"length": 1,
		"height": 1,
		"AoA": 0,
		"angle": -50,
		"sweep": 0,
		"distance": 1,
		"offset-y-angle": -10,
		"cone-angle": 5
	}
	var prof_att = {}
	var at = false
	#for line in file.get_line():
	while !file.eof_reached():
		var line = file.get_line()

		if at and not line.find("#")==0:
			var tmp = []
			var t1 = line.strip_edges()
			if t1.length() > 0:
				var t2 = line.split(":")
				tmp.append(t2[0].strip_edges())
				tmp.append(t2[1].strip_edges())
				#points.append(tmp)
				print(tmp)
				prof_att[tmp[0]] = float(tmp[1])
		
		if at and line.length()==0:
			atts.append(prof_att)
			prof_att = default.duplicate()
			
		if at and line.find("\t") == -1 and line.length()>0:
			at = false
			print(line + " END END")
			
		if line=="atts:":
			at = true
			prof_att = default.duplicate()
			print("proflie attributes:")
			
	file.close()


func load_profile():
	var file = File.new()
	file.open("user://kite.txt", File.READ)
	
	points = []
	var prof = false
	#for line in file.get_line():
	while !file.eof_reached():
		var line = file.get_line()

		if prof:
			print(line)
			var tmp = []
			var t1 = line.strip_edges()
			if t1.length() > 0:
				var t2 = line.split(",")
				tmp.append(float(t2[0]))
				tmp.append(float(t2[1]))
				points.append(tmp)
			
		if line=="profile:":
			prof = true
			print("profile:")
			
		if line=="":
			prof = false
			
	file.close()
	
	
func load_kite():
	var file = File.new()
	file.open("user://kite.txt", File.READ)
	file.close()
	#return content


func go():
	load_profile()
	load_atts()
	
	# atts[0] is the middle of the kite
	for i in range(1, atts.size()):
		atts[i]["distance"] += atts[i-1]["distance"]
		atts[i]["offset-y-angle"] += atts[i-1]["offset-y-angle"]
	
	for attribute in atts:
		profiles.append(Profile.new(points.duplicate(), attribute))
	
	# LEFT SIDE OF KITE is a mirror of the right - skip the middle profile
#	for i in range(1, atts.size()):
#		var tmp = Profile.new(points.duplicate(), atts[i])
#		tmp.mirror()
#		profiles.push_front(tmp)


func get_draw_profiles():
	var p = profiles.duplicate()
	# LEFT SIDE OF KITE is a mirror of the right - skip the middle profile
	for i in range(1, atts.size()):
		var tmp = Profile.new(points.duplicate(), atts[i])
		tmp.mirror()
		p.push_front(tmp)
		
	return p


func _init():
	go()


# Called when the node enters the scene tree for the first time.
func _ready():
	var surface_tool = SurfaceTool.new()
	var mesh = Mesh.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	surface_tool.set_material(material)

	for profile in get_draw_profiles():
		prof2(surface_tool, profile)
	
	surface_tool.generate_normals()
	surface_tool.commit(mesh)
	self.set_mesh(mesh)


func get_vectors(pts, atts):
	var center_y = 2.0
	
	var tmp = []
	for p in pts:
		tmp.append(Vector3(0,p[1],p[0]))
		
	# flip Z
	for i in range(tmp.size()):
		tmp[i] *= Vector3(1,1,-1)
	
	# normalise (0-1)
	for i in range(tmp.size()):
		tmp[i] /= Vector3(1,100.0,100.0)

	# SCALE
	for i in range(tmp.size()):
		tmp[i] *= Vector3(0, atts["height"], atts["length"])
		
	# AoA
	for i in range(tmp.size()):
		tmp[i] = tmp[i].rotated(Vector3(1,0,0), deg2rad(atts["AoA"]))
		
	# sweep
	for i in range(tmp.size()):
		tmp[i] += Vector3(0, 0, atts["sweep"])
		
	# rotate around Z -> C shaped kite
	for i in range(tmp.size()):
		tmp[i] = tmp[i].rotated(Vector3(0,0,1), deg2rad(atts["angle"]))
	
	# Push RIGHT
	for i in range(tmp.size()):
		tmp[i] += Vector3(atts["distance"],0,0)

	# rotate DOWN
	for i in range(tmp.size()):
		tmp[i] = tmp[i].rotated(Vector3(0,0,1), deg2rad(atts["offset-y-angle"]))
	
	# TRANSLATE Y ... we are
#	for i in range(tmp.size()):
#		tmp[i] += Vector3(0,center_y,0)
	
	return tmp


func prof(st:SurfaceTool, pts, atts):
	
	var tmp = get_vectors(pts, atts)
	
	for i in range(tmp.size()-1):
		st.add_vertex(tmp[i])
		st.add_vertex(tmp[i+1])
		
	st.add_vertex(tmp[-1])
	st.add_vertex(tmp[0])


func prof2(st:SurfaceTool, profile):
	
	#var tmp = get_vectors(pts, atts)
	var tmp = profile.points
	
	for i in range(tmp.size()-1):
		st.add_vertex(tmp[i])
		st.add_vertex(tmp[i+1])
		
	st.add_vertex(tmp[-1])
	st.add_vertex(tmp[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
