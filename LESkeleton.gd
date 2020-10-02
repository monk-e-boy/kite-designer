extends MeshInstance

export(SpatialMaterial) var material

var angle = 1
var angle2 = 1
var angle3 = 1

#func draw(v1, v2, colour=Color8(0,0,0)):
#	surface_tool.add_color(colour)
#	surface_tool.add_vertex(v1)
#	surface_tool.add_color(colour)
#	surface_tool.add_vertex(v2)

const KPlane = preload("KPlane.gd")
const LESection = preload("LESection.gd")
const LE = preload("LE_.gd")


var leading_edge = null
var surface_tool = null

func _ready():
	leading_edge = LE.new({})


func _process(delta):
	surface_tool = SurfaceTool.new()
	var mesh = Mesh.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	
	# set up the material so the lines can be coloured in code
	# and don't require lights to be seen
	var mat = SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true
	mat.flags_unshaded = true
	surface_tool.set_material(mat)
	
	#
	#
	leading_edge.render(surface_tool)
	#
	#
	
	#surface_tool.generate_normals()
	surface_tool.commit(mesh)
	self.set_mesh(mesh)



func section(surface_tool, intersects, rot_z):
	#var my_rot = -50
	var length = 1;
	var p1 = Vector3(0,length,0)
	p1 = p1.rotated(Vector3(0,0,1), deg2rad(rot_z-90))
	p1 += intersects
	
	surface_tool.add_vertex(intersects)
	surface_tool.add_vertex(p1)
	
	tube_end(surface_tool, p1, rot_z, 0.2)
	


func _ready__():
	
#	var x1 = Vector2(4,0).normalized()
#	var x2 = Vector2(0,4).normalized()
#	var angle = acos(x1.dot(x2)) / 2.0
#	var a2 = rad2deg(angle)

	var tmp = get_parent().tube_angle
	
	var surface_tool = SurfaceTool.new()
	var mesh = Mesh.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	surface_tool.set_material(material)
	
	
	var start = Vector3(0,1.5,0)
	var prev_angle = 0
	
	var a_start = start;
	for i in range(5):
		# TODO load/read rules on this section
		var section = Vector3(0.6,0,0) # <-- length of section
		var angle = prev_angle - 10
		
		var end = section.rotated(Vector3(0,0,1), deg2rad(angle)) + a_start
		surface_tool.add_vertex(a_start)
		surface_tool.add_vertex(end)
		
		# perpendicular bone
		var bone = section * 0.3
		bone = bone.rotated(Vector3(0,0,1), deg2rad(90.0 + angle + angle/2))
		surface_tool.add_vertex(end)
		surface_tool.add_vertex(end+bone)
		
		bone = bone.rotated(Vector3(0,0,1), deg2rad(180))
		surface_tool.add_vertex(end)
		surface_tool.add_vertex(end+bone)
		
		tube_end(surface_tool, end, angle + angle/2, 0.3)
		
		a_start = end
		prev_angle = angle

	
	surface_tool.generate_normals()
	surface_tool.commit(mesh)
	self.set_mesh(mesh)


func tube_end(surface_tool, tube_end: Vector3, tube_angle_z: float, radius: float):
	var p = Vector3(0,radius,0)
	var count = 20
	var angle = 360.0 / count
	
	var points = []
	for i in range(count):
		points.append(p.rotated(Vector3(1,0,0), deg2rad(angle*i)))
		
	for i in range(points.size()):
		points[i] = points[i].rotated(Vector3(0,0,1), deg2rad(tube_angle_z))
	
	for i in range(points.size()-1):
		surface_tool.add_vertex(tube_end+points[i])
		surface_tool.add_vertex(tube_end+points[i+1])
		
	surface_tool.add_vertex(tube_end+points[points.size()-1])
	surface_tool.add_vertex(tube_end+points[0])
	

#func _process(delta):
#	pass
