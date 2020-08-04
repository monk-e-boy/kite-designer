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
	
	# draw a yellow representation of this plane
	func render(surface_tool):
		var p1 = v1-v2
		p1 = p1.normalized()
		var p2 = v3-v2
		p2 = p2.normalized()
		var p3 = p1 * -1
		var p4 = p2 * -1
		
		var c = Color8(255,255,0)
		surface_tool.add_color(c)
		# cross
		surface_tool.add_vertex(v2)
		surface_tool.add_vertex(v2+p1)
		
		surface_tool.add_vertex(v2)
		surface_tool.add_vertex(v2+p2)
		
		surface_tool.add_vertex(v2)
		surface_tool.add_vertex(v2+p3)
		
		surface_tool.add_vertex(v2)
		surface_tool.add_vertex(v2+p4)
		
		# square
		surface_tool.add_vertex(v2+p1)
		surface_tool.add_vertex(v2+p2)
		surface_tool.add_vertex(v2+p2)
		surface_tool.add_vertex(v2+p3)
		surface_tool.add_vertex(v2+p3)
		surface_tool.add_vertex(v2+p4)
		surface_tool.add_vertex(v2+p4)
		surface_tool.add_vertex(v2+p1)



class LESection:
	var point = Vector3(0,0,0)
	var direction = Vector3(0,0,0)
	var color = Color8(147, 0, 150)
	var spokes = []
	var ray = Vector3(0,0,0)
	var plane = null
	# intersects - I've named it inters because I'm an F1 fan
	var inters = []
	var parent = null
	var options = {
		'render-spokes': false,
		'render-rays': false,
		'render-inters': false,
		'render-plane': false
	}
	var tmp_v_perp = 0
	var tmp_new_angle = 0
	
	func _init(point, direction, parent, options):
		self.point = point
		self.direction = direction
		self.parent = parent
		for key in options:
			self.options[key] = options[key]
		#
		self.make_spokes()
		self.make_ray()
		#
		
	func get_mid_angle(sec: LESection):
		var a = self.point
		var b = self.point + self.direction
		var c = sec.point + sec.direction
	
		# HACK - SKELETON HACK
#		surface_tool.add_color(self.color);
#		surface_tool.add_vertex(a)
#		surface_tool.add_color(self.color)
#		surface_tool.add_vertex(b)
		
#		surface_tool.add_color(self.color)
#		surface_tool.add_vertex(b)
#		surface_tool.add_color(self.color)
#		surface_tool.add_vertex(c)
	
		# b points towards the joint - flip b so it points away
		# move both vectors to the origin
		var v1 = (b-a) * -1
		#surface_tool.add_color(Color8(0,0,0))
		#surface_tool.add_vertex(Vector3(0,0,0))
		#surface_tool.add_color(Color8(0,0,0))
		#surface_tool.add_vertex(v1)
		
		var v2 = c-b
		#surface_tool.add_color(Color8(0,0,0))
		#surface_tool.add_vertex(Vector3(0,0,0))
		#surface_tool.add_color(Color8(0,0,0))
		#surface_tool.add_vertex(v2)
		
		var end_n = v1.normalized() + v2.normalized()
		#surface_tool.add_color(Color8(255,0,0))
		#surface_tool.add_vertex(Vector3(0,0,0))
		#surface_tool.add_color(Color8(255,0,0))
		#surface_tool.add_vertex(end_n)
		
		var cross = v1.cross(v2)
		if cross==Vector3(0,0,0):
			#
			# WARNING - this does not work
			#
			# the two lines are in alignment - rotate by 90 deg
			var tmp = c-b
			# we rotate around z because
			end_n = tmp.rotated(Vector3(0,0,1), deg2rad(90))
			cross = tmp.rotated(Vector3(0,1,0), deg2rad(90))

		#return KPlane.new(b+end_n, b, b+cross) # clockwise order
		return KPlane.new(b+cross, b, b+end_n) # clockwise order
	
	# https://stackoverflow.com/questions/11132681/what-is-a-formula-to-get-a-vector-perpendicular-to-another-vector
	func get_perpendicular_vec():
		var x = self.direction.x
		var y = self.direction.y
		var z = self.direction.z
		var v_perp = Vector3(0,0,0)
		if z<x :
			v_perp = Vector3(y,-x,0)
		else:
			v_perp = Vector3(0,-z,y)
		return v_perp
		
	func get_end():
		return self.point+self.direction

	# used to generate the circle of the tube
	# this is then projected back onto the plane
	# using rays
	func make_spokes():
		
		# this vector is in a random direction
		var v_perp = self.get_perpendicular_vec()
		
		var dir_norm = self.direction.normalized()
		# WHY - we want to eliminate twist in the LE
		# if the ends are made up of 100 points, one end has point 0 at the bottom
		# the other end point 0 is at the top we will get a bow tie.
		#
		# TODO - Need to figure out what angle we want here
		#        Do we want the closes Z to the AoA ?
		# Point 0 projected down to the plane will hit the LE/profile join angle
		#
		var min_z = -100000
		var perp_rotated = 0
		var angle = 0
		for i in range(360):
			var c = v_perp.rotated(dir_norm, deg2rad(i))
			c = c.normalized()
			c *= 0.3
			if min_z < c.z:
				min_z = c.z
				perp_rotated = c
				angle = i
		
		self.tmp_v_perp = v_perp
		self.tmp_new_angle = perp_rotated
		v_perp = self.get_perpendicular_vec()
		#
		#
		#
		var spoke_count = self.parent.get_spoke_count()
		for i in range(1, spoke_count+1):
			#var tmp = (360.0 / spoke_count) * i
			var c = v_perp.rotated(dir_norm, deg2rad( angle + (360.0 / spoke_count) * i))
			c = c.normalized()
			c *= 0.2
			self.spokes.append(c)
	
	func make_ray():
		# flip the direction to point back towards the join
		# make it long enough to pierce the plane (* -3)
		# it is possible that the ray and plane do not intersect (strange angles)
		# with a short section length, a tight angle and a large tube diameter
		# the spokes may cross the plane, shooting the ray away from the plane
		# a designer would avoid this as the kite would be shit
		self.ray = self.direction * -3
		
	func intersects(plane:KPlane):
		# let's keep a reference to the plane
		self.plane = plane
		for spoke in self.spokes:
			var inter = plane.intersects_ray(
				self.get_end() + spoke,
				self.ray
			)
		
			self.inters.append(inter)
		
	func render(surface_tool):
		surface_tool.add_color(self.color)
		surface_tool.add_vertex(self.point)
		surface_tool.add_color(self.color)
		surface_tool.add_vertex(self.get_end())
		
		#
		# rotate the projected circle
		surface_tool.add_color(Color8(0,0,255))
		surface_tool.add_vertex(self.get_end())
		surface_tool.add_color(Color8(0,0,255))
		surface_tool.add_vertex(self.get_end() + self.tmp_v_perp)
		#
		surface_tool.add_color(Color8(0,0,0))
		surface_tool.add_vertex(self.get_end())
		surface_tool.add_color(Color8(0,0,0))
		surface_tool.add_vertex(self.get_end() + self.tmp_new_angle)
		#
		#
		#
		
		# the plane we are projecting the LE tube onto
		if self.options['render-plane'] and (not self.plane == null):
			self.plane.render(surface_tool)
		
		# spokes of the LE tube radius
		if self.options['render-spokes']:
			for spoke in self.spokes:
				# draw spokes
				surface_tool.add_color(Color8(255,0,0))
				surface_tool.add_vertex(self.get_end())
				surface_tool.add_color(Color8(255,0,0))
				surface_tool.add_vertex(self.get_end() + spoke)
		
		# the rays from the spokes we project onto the plane
		if self.options['render-rays']:
			for spoke in self.spokes:
				# draw rays
				surface_tool.add_color(Color8(253,71,3))
				surface_tool.add_vertex(self.get_end() + spoke)
				surface_tool.add_color(Color8(253,71,3))
				surface_tool.add_vertex(self.get_end() + spoke + ray)
		
		# the resulting LE tube end after projection
		if self.options['render-inters'] and self.inters.size():
			for i in range(inters.size()-1):
				# sometimes we don't get an intersect between the ray and
				# the plane (rare - see comment above)
				if inters[i] and inters[i+1]:
					surface_tool.add_color(Color8(255,0,0))
					surface_tool.add_vertex(self.inters[i])
					surface_tool.add_color(Color8(255,0,0))
					surface_tool.add_vertex(self.inters[i+1])
				
			if inters[0] and inters[-1]:
				surface_tool.add_color(Color8(255,0,0))
				surface_tool.add_vertex(self.inters[0])
				surface_tool.add_color(Color8(255,0,0))
				surface_tool.add_vertex(self.inters[-1])





class LE:
	var options = {}
	var spoke_count = 4
	var sections = []
	

	func _init(options):
		for key in options:
			self.options[key] = options[key]
		
		var point = Vector3(0,1,0)
		var direction = Vector3(0.5,0,0)
		var deg1 = -5
		direction = direction.rotated(Vector3(0,0,1), deg2rad(deg1))
		
		var x = Vector3(1,0,0)
		var rot_z = -25.0
		var rot_y = 45.0
	
		var sec1 = LESection.new(
			point,
			direction,
			self,
			{
				'render-spokes': false,
				'render-rays': false,
				'render-inters': true
			})
		# The intersection plane at the centre of the kite is a special case:
		var mid_plane = KPlane.new(Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,-1))
		sec1.intersects(mid_plane)
		
		self.sections.append(sec1)
	
		var sweep = 25
		var angle = deg1
		for i in range(5):
	
			var opts = {
					'angle': -7,
					'sweep': 0,
					'length': 0.5
				}
				
			self.add_section(
				self.sections[-1],
				angle,
				sweep,
				opts
				)
			
			angle += opts['angle']
		
		
	func add_section(previous_section, angle, sweep, options):
		
		var direction = Vector3(options['length'],0,0)
		direction = direction.rotated(Vector3(0,1,0), deg2rad(sweep + options['sweep']))
		direction = direction.rotated(Vector3(0,0,1), deg2rad(angle + options['angle']))
		var start = previous_section.get_end()
		
	
		var section = LESection.new(
			start,
			direction,
			self,
			{
				'render-spokes': false,
				'render-rays': false,
				'render-inters': true
			})
		
		var v_perp = section.get_perpendicular_vec()
		var plane = previous_section.get_mid_angle(section)
		section.intersects(plane)
		
		self.sections.append(section)


	func get_spoke_count():
		return self.spoke_count

	func render(surface_tool):
		# waggle the angle between -90 and +90 degrees
		#	angle += 0.014
		#	angle2 += 0.012
		#	angle3 += 0.009
		#var deg1 = sin(angle) * 120
		#var deg2 = sin(angle2) * 120
		#var deg3 = 90 + sin(angle3) * 90
		
		for s in self.sections:
			s.render(surface_tool)
		
		for i in range(self.sections.size()-1):
			for j in range(self.spoke_count):
				surface_tool.add_color(Color8(255,0,255))
				surface_tool.add_vertex(self.sections[i+0].inters[j])
				surface_tool.add_vertex(self.sections[i+1].inters[j])



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
