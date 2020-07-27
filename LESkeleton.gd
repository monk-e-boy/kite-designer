extends MeshInstance

export(SpatialMaterial) var material

var angle = 1

class KPlane:
	var pos = Vector3(0,0,0)
	var rot_x = 0
	var rot_y = 0
	var rot_z = 0
	var p1
	var p2
	var p3
	var v1
	var v2
	var v3
	
	# clockwise order
	func _init(v1, v2, v3):
		self.v1 = v1
		self.v2 = v2
		self.v3 = v3

	func __init(pos, rot_x, rot_y, rot_z):
		self.pos = pos
		self.rot_x = rot_x
		self.rot_y = rot_y
		self.rot_z = rot_z
		
		p1 = Vector3(0,1,0)
		p2 = Vector3(0,-1,2)
		p3 = Vector3(0,-1,-2)
		
		p1 = p1.rotated(Vector3(0,0,1), deg2rad(rot_z))
		p2 = p2.rotated(Vector3(0,0,1), deg2rad(rot_z))
		p3 = p3.rotated(Vector3(0,0,1), deg2rad(rot_z))
		
		#p1 = p1.rotated(Vector3(0,1,0), rot_y)
		#p2 = p2.rotated(Vector3(0,1,0), rot_y)
		#p3 = p3.rotated(Vector3(0,1,0), rot_y)
		
		p1 += pos
		p2 += pos
		p3 += pos
	
	func intersects_ray(line, direction):
		var plane = Plane(v1, v2, v3)
		var intersects = plane.intersects_ray(line, direction)
		return intersects
	
	func render(surface_tool):
		surface_tool.add_color(Color(1, 0, 0, 1));
		surface_tool.add_vertex(v1)
		surface_tool.add_vertex(v2)
		
		surface_tool.add_vertex(v2)
		surface_tool.add_vertex(v3)
		
		surface_tool.add_vertex(v3)
		surface_tool.add_vertex(v1)


class LESection:
	var pos = Vector3(0,0,0)
	var end = Vector3(0,0,0)
	
	func _init(pos, end):
		self.pos = pos
		self.end = end
		
	func get_mid_angle(sec2: LESection, surface_tool):
		var a = self.pos
		var b = self.end
		var c = sec2.end
	
		# HACK - SKELETON HACK
		surface_tool.add_color(Color8(147, 0, 150));
		surface_tool.add_vertex(a)
		surface_tool.add_vertex(b)
		
		surface_tool.add_vertex(b)
		surface_tool.add_vertex(c)
	
		# b points towards the joint - flip b so it points away
		# move both vectors to the origin
		var v1 = (b-a) * -1
		var v2 = c-b
		var end = v1 + v2
		surface_tool.add_vertex(b)
		surface_tool.add_vertex(end+b)
		
		var cross = v1.cross(v2)
		surface_tool.add_vertex(b)
		surface_tool.add_vertex(b+cross)
		
		return KPlane.new(b+cross, b, b+end) # clockwise order
		
	func render(surface_tool):
		surface_tool.add_color(Color(0, 0, 0, 1));
		surface_tool.add_vertex(self.pos)
		surface_tool.add_vertex(self.end)


#func _ready():
func _process(delta):
	var surface_tool = SurfaceTool.new()
	var mesh = Mesh.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	
	var mat = SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true
	mat.flags_unshaded = true
	surface_tool.set_material(mat)
	
	
	var line = Vector3(0,1,0)
	var direction = Vector3(1,0,0)
	#surface_tool.add_vertex(line)
	#surface_tool.add_vertex(line+direction*5)
	var x = Vector3(1,0,0)
	var rot_z = -25.0
	var rot_y = 45.0
	
	
	
	
	#var p = KPlane.new(line + direction, 0, 0, rot_z)
	#p.render(surface_tool)
	
	#var plane = Plane(p1, p2, p3)
	#var intersects = p.intersects_ray(line, direction)
	
	#surface_tool.add_vertex(line)
	#surface_tool.add_vertex(intersects)
	
	var sec1 = LESection.new(line, line+direction)
	sec1.render(surface_tool)
	
	# waggle the angle between -90 and +90 degrees
	angle += 0.05
	var deg = sin(angle) * 90
	var tmp = Vector3(1,0,0)
	tmp = tmp.rotated(Vector3(0,1,0), deg2rad(deg))
	
	var sec2 = LESection.new(line+direction, line+direction+tmp)
	sec2.render(surface_tool)
	
	var plane = sec1.get_mid_angle(sec2, surface_tool)
	plane.render(surface_tool)
	
	var inters = []
	var count = 20
	for i in range(count):
		var c = Vector3(0,0.2,0)
		c = c.rotated(Vector3(1,0,0), deg2rad(i * (360.0/count)))
		c += line
		#surface_tool.add_vertex(c)
		#surface_tool.add_vertex(c+direction*5)
		
		var inter = plane.intersects_ray(c, direction)
		if false:
			surface_tool.add_vertex(c)
			surface_tool.add_vertex(inter)
		inters.append(inter)
		
	for i in range(inters.size()-1):
		surface_tool.add_vertex(inters[i])
		surface_tool.add_vertex(inters[i+1])
		
	surface_tool.add_vertex(inters[0])
	surface_tool.add_vertex(inters[-1])
	
	#
	#
#	section(surface_tool, intersects, rot_z)
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
