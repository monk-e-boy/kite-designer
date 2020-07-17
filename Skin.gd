extends MeshInstance

export(SpatialMaterial) var material

var current_index = 0;
var vertex_count = 0;
var debug_vecs = []
var debug_vec_pairs = []
var strips = []

enum Side {a, b, c}

# the canopy is made of many strips
class Strip:
	var left = []
	var right = []
	var label = ""
	func _init(left, right, label):
		self.left = left.duplicate()
		self.right = right.duplicate()
		self.label = label

	func flatten_strip():
		var vec_pairs = []
		var tmp = Tri2.new(left[0], right[0], left[1])
		tmp.flatten()
		tmp.align_to(deg2rad(90) - tmp.get_side_angle(Side.c), Vector3(0,0,0))
		#self.vertex_count = tmp.draw(surface_tool, self.vertex_count)
		vec_pairs += tmp.outline()
	
		var tmp_b = Tri2.new(left[1], right[0], right[1])
		tmp_b.flatten()
		#tmp_b.align_to(tmp.get_side_angle(Side.c), tmp.v0)
		tmp_b.align_to(tmp.get_side_angle(Side.b) + deg2rad(180), tmp.v2)
		#self.vertex_count = tmp.draw(surface_tool, self.vertex_count)
		vec_pairs += tmp_b.outline()
	
		var prev = tmp_b
		var faces = left.size()
		for i in range(1,faces-1):
			var tmp_c = Tri2.new(left[i], right[i], left[i+1])
			tmp_c.flatten()
			tmp_c.align_to(prev.get_side_angle(Side.c), prev.v0)
			#self.vertex_count = tmp.draw(surface_tool, self.vertex_count)
			vec_pairs += tmp_c.outline()
			
			prev = tmp_c
			
			var tmp_d = Tri2.new(left[i+1], right[i], right[i+1])
			tmp_d.flatten()
			tmp_d.align_to(prev.get_side_angle(Side.b) + deg2rad(180), prev.v2)
			#self.vertex_count = tmp.draw(surface_tool, self.vertex_count)
			vec_pairs += tmp_d.outline()
			
			prev = tmp_d
			
		return vec_pairs


class Tri2:
	# original Vectors
	var ov0 = null
	var ov1 = null
	var ov2 = null
	# flattened vects
	var v0 = null
	var v1 = null
	var v2 = null
	
	func _init(a, b, c):
		self.ov0 = a
		self.ov1 = b
		self.ov2 = c
	
	# returns a triangle with:
	#  - side a aligned to X axis (Y == 0)
	#  - v0 at 0,0,0
	func flatten():
		# https://en.wikipedia.org/wiki/Solution_of_triangles#Three_sides_given_.28SSS.29
		# get length of sides
		var a = self.length(self.ov0, self.ov1)
		var b = self.length(self.ov1, self.ov2)
		var c = self.length(self.ov2, self.ov0)
		
		# internal angles:
		#var alpha = acos( ((b*b)+(c*c)-(a*a)) / (2*b*c) )
		var beta  = acos( ((a*a)+(c*c)-(b*b)) / (2*a*c) )
		#var gamma = deg2rad(180.0) - alpha - beta
		
		#var aa = rad2deg(alpha)
		#var bb = rad2deg(beta)
		#var cc = rad2deg(gamma)
		
		self.v0 = Vector3(0,0,0)
		self.v1 = Vector3(a,0,0)
		self.v2 = Vector3(c,0,0)
		self.v2 = self.v2.rotated(Vector3(0,1,0), beta)

	# assume v0 = 0,0,0
	func align_to(angle, position: Vector3):
		self.v0 = self.v0.rotated(Vector3(0,1,0), angle)
		self.v1 = self.v1.rotated(Vector3(0,1,0), angle)
		self.v2 = self.v2.rotated(Vector3(0,1,0), angle)
		self.v0 += position
		self.v1 += position
		self.v2 += position
		
	# side can be a, b, or c
	# returns angle in relation to X
	func get_side_angle(side):
		match side:
			Side.a:
				# Move to ORIGIN
				var tmp = self.v1 - self.v0
				return tmp.angle_to(Vector3(1,0,0))
			Side.b:
				# Move to ORIGIN
				var tmp = self.v2 - self.v1
				return tmp.angle_to(Vector3(1,0,0))
			Side.c:
				# Move to ORIGIN
				var tmp = self.v2 - self.v0
				var angle = tmp.angle_to(Vector3(1,0,0))
				if self.v2[2] > self.v0[2]:
					# look at Z to see if we reverse angle
					angle *= -1
				return angle

		return 0
		
	func length(a, b):
		var tmp = b-a
		return tmp.length()
	
	func draw(surface_tool, vertex_count):
		surface_tool.add_vertex(self.v0)
		surface_tool.add_vertex(self.v1)
		surface_tool.add_vertex(self.v2)
		
		surface_tool.add_index(vertex_count)
		surface_tool.add_index(vertex_count+1)
		surface_tool.add_index(vertex_count+2)
		return vertex_count + 3
		
	func outline():
		var vec_pairs = []
		vec_pairs.append([self.v0, self.v1])
		vec_pairs.append([self.v1, self.v2])
		vec_pairs.append([self.v2, self.v0])
		
		var tmp = (self.v1 - self.v0) / 2.0
		vec_pairs.append([self.v0 + tmp, self.v0 + tmp + Vector3(0,0,0.05)])
		
		return vec_pairs
		





class Triangle:
	var v0 = null
	var v1 = null
	var v2 = null
	
	func _init(a, b, c):
		self.v0 = a
		self.v1 = b
		self.v2 = c
		
	#  2
	#  |\
	#  | \
	#  |  \
	#  |___\
	#  0    1
	func flatten_tri_a():
		# move to ORIGIN
		var tmp = self.v0
		self.v0 -= tmp
		self.v1 -= tmp
		self.v2 -= tmp
		
		var angle = 0
		# angle to X - rotate Z
		var tmp_vec = Vector3(self.v1[0], self.v1[1], 0)
		angle = tmp_vec.angle_to(Vector3(1,0,0))
		if self.v1[1] > 0:
			# we want to down up to X plane
			angle *= -1
		var xxx1 = rad2deg(angle)
		self.v1 = self.v1.rotated(Vector3(0,0,1), angle)
		self.v2 = self.v2.rotated(Vector3(0,0,1), angle)
		
		# angle to Z - rotate X
		tmp_vec = Vector3(self.v2[0], self.v2[1], 0)
		angle = tmp_vec.angle_to(Vector3(1,0,0))
		if self.v1[1] > 0:
			# we want to down up to X plane
			angle *= -1
		angle = self.v2.angle_to(Vector3(0,0,-1))
		self.v2 = self.v2.rotated(Vector3(1,0,0), -angle)


	# 2_____1
	#  \   |
	#   \  |
	#    \ |
	#     \|
	#      0
	func flatten_tri_b():
		# move to ORIGIN
		var tmp = self.v0
		self.v0 -= tmp
		self.v1 -= tmp
		self.v2 -= tmp
		
		var angle = 0
		var tmp_vec = Vector3(0,0,0)
		
		# Align 0 - 1 to the Z
		tmp_vec = Vector3(self.v1[0], 0, self.v1[2])
		angle = tmp_vec.angle_to(Vector3(0,0,-1))
		var xxx1 = rad2deg(angle)
		self.v1 = self.v1.rotated(Vector3(0,1,0), angle)
		self.v2 = self.v2.rotated(Vector3(0,1,0), angle)
		
		# angle to Z - rotate X - ignore the x value, otherwise
		# we are measureing a diag ang
		tmp_vec = Vector3(0, self.v1[1], self.v1[2])
		angle = tmp_vec.angle_to(Vector3(0,0,-1))
			
		var xxx = rad2deg(angle)
		self.v1 = self.v1.rotated(Vector3(1,0,0), -angle)
		self.v2 = self.v2.rotated(Vector3(1,0,0), -angle)
		
		# angle to X - rotate Z
		tmp_vec = Vector3(self.v2[0], self.v2[1], 0)
		angle = tmp_vec.angle_to(Vector3(-1,0,0))
		self.v2 = self.v2.rotated(Vector3(0,0,1), angle)



	# find the angle of a side - compared to X axis
	func get_angle(side):
		var vec = self.v1 - self.v0
		return vec.angle_to(Vector3(1,0,0))
		
	func add(v : Vector3):
		self.v0 += v
		self.v1 += v
		self.v2 += v

	func draw(surface_tool, vertex_count):
		surface_tool.add_vertex(self.v0)
		surface_tool.add_vertex(self.v1)
		surface_tool.add_vertex(self.v2)
		
		surface_tool.add_index(vertex_count)
		surface_tool.add_index(vertex_count+1)
		surface_tool.add_index(vertex_count+2)
		return vertex_count + 3
		
	func outline(debug_vecs):
		debug_vecs.append(self.v0)
		debug_vecs.append(self.v1)
		debug_vecs.append(self.v2)

	

func _ready():
	var surface_tool = SurfaceTool.new()
	
	var mesh = Mesh.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_material(material)
	
#	var pts = self.get_parent().points
#	var atts = self.get_parent().atts
	var j = 0
	
	#for a in range(atts.size()-1):
	for a in range(self.get_parent().profiles.size()-1):
#		var left = self.get_parent().get_vectors(pts, atts[a])
#		var right = self.get_parent().get_vectors(pts, atts[a+1])
		var left = self.get_parent().profiles[a].points
		var right = self.get_parent().profiles[a+1].points
	
		var faces = left.size()
		for i in range(faces):
			surface_tool.add_vertex(left[i])
			surface_tool.add_vertex(right[i])
			self.vertex_count += 2
	
		# draw the faces - each face is two triangles
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
	
		# START NEW STRIP
		j += 2
		var strip = Strip.new(left, right, "A")
		# debug_vec_pairs += strip_a.flatten_strip()
		strips.append(strip)


	#
	#
	#
	# MIRROR
	#
	#

#	for a in range(atts.size()-1):
#	#for a in range(2):
#		var right = self.get_parent().get_vectors(pts, atts[a])
#		for i in range(right.size()):
#			right[i].x *= -1
#		
#		var left = self.get_parent().get_vectors(pts, atts[a+1])
#		for i in range(left.size()):
#			left[i].x *= -1
#		
#		var faces = left.size()
#		for i in range(faces):
#			surface_tool.add_vertex(left[i])
#			surface_tool.add_vertex(right[i])
#			self.vertex_count += 2
#	
#		# draw the faces - each face is two triangles
#		for i in range(faces-1):
#			# top triangle
#			surface_tool.add_index(j)
#			surface_tool.add_index(j+1)
#			surface_tool.add_index(j+2)
#			# bottom triangle
#			surface_tool.add_index(j+1)
#			surface_tool.add_index(j+3)
#			surface_tool.add_index(j+2)
#			j += 2
	
#		# START NEW STRIP
#		j += 2
#		var strip = Strip.new(left, right, "A")
#		# debug_vec_pairs += strip_a.flatten_strip()
#		strips.append(strip)


	#
	#
	#
	surface_tool.generate_normals()
	surface_tool.index()
	
	surface_tool.commit(mesh)
	self.set_mesh(mesh)




# flatten both
func flatten_triangle_pair(t1, t2, surface_tool):
	# -- A --
	var triangle = t1
	triangle = flatten_tri_a(triangle)
	draw_triangle(surface_tool, triangle)
	debug_vecs.append(triangle[0])
	debug_vecs.append(triangle[1])
	debug_vecs.append(triangle[2])
	
	# Move to origin
	var vec = triangle[2] - triangle[1]
	var ang = vec.angle_to(Vector3(0,0,1))
	var pos = triangle[1]
	
	# -- B --
	triangle = t2
	triangle = flatten_tri_b(triangle)
	# HACK
	
	# Takes side and rotates to ang
	var vec_b = triangle[2] - triangle[0]
	var ang_b = vec.angle_to(Vector3(0,0,1))
	
	# Triangle [0] is at 0,0,0.
	# Rotate the other 2 points around Y to match join
	# vertext on prev triangle
	var tmp_angle = ang_b-ang
	triangle[1] = triangle[1].rotated(Vector3(0,1,0), tmp_angle)
	triangle[2] = triangle[2].rotated(Vector3(0,1,0), tmp_angle)
	
	# move triangle to join prev along specified vertex
	triangle[0] += pos
	triangle[1] += pos
	triangle[2] += pos
	
	draw_triangle(surface_tool, triangle)
	
	debug_vecs.append(triangle[0])
	debug_vecs.append(triangle[1])
	debug_vecs.append(triangle[2])
	
	# where the next triangle will attach
	return [triangle[2], triangle[1]]
	

func draw_triangle(surface_tool, triangle):
	surface_tool.add_vertex(triangle[0])
	surface_tool.add_vertex(triangle[1])
	surface_tool.add_vertex(triangle[2])
	
	surface_tool.add_index(self.vertex_count)
	surface_tool.add_index(self.vertex_count+1)
	surface_tool.add_index(self.vertex_count+2)
	self.vertex_count += 3

	
#  2
#  |\
#  | \
#  |  \
#  |___\
#  0    1
func flatten_tri_a(triangle):
	# move to ORIGIN
	var tmp = triangle[0]
	for i in range(3):
		triangle[i] -= tmp
	
	var angle = 0
	# angle to X - rotate Z
	var tmp_vec = Vector3(triangle[1][0], triangle[1][1], 0)
	angle = tmp_vec.angle_to(Vector3(1,0,0))
	if triangle[1][1] > 0:
		# we want to down up to X plane
		angle *= -1
	var xxx1 = rad2deg(angle)
	triangle[1] = triangle[1].rotated(Vector3(0,0,1), angle)
	triangle[2] = triangle[2].rotated(Vector3(0,0,1), angle)
	
	# rotate X
	#
	# TODO - fix this so angle is 2D like above
	#
	angle = triangle[2].angle_to(Vector3(0,0,-1))
	triangle[2] = triangle[2].rotated(Vector3(1,0,0), -angle)

	return triangle

# 2_____1
#  \   |
#   \  |
#    \ |
#     \|
#      0
func flatten_tri_b(triangle):
	# move to ORIGIN
	var tmp = triangle[0]
	for i in range(3):
		triangle[i] -= tmp
	
	var angle = 0
	var tmp_vec = Vector3(0,0,0)
	
	# Align 0 - 1 to the Z
	tmp_vec = Vector3(triangle[1][0], 0, triangle[1][2])
	angle = tmp_vec.angle_to(Vector3(0,0,-1))
	var xxx1 = rad2deg(angle)
	triangle[1] = triangle[1].rotated(Vector3(0,1,0), angle)
	triangle[2] = triangle[2].rotated(Vector3(0,1,0), angle)
	
	# angle to Z - rotate X - ignore the x value, otherwise
	# we are measureing a diag ang
	tmp_vec = Vector3(0, triangle[1][1], triangle[1][2])
	angle = tmp_vec.angle_to(Vector3(0,0,-1))
		
	var xxx = rad2deg(angle)
	triangle[1] = triangle[1].rotated(Vector3(1,0,0), -angle)
	triangle[2] = triangle[2].rotated(Vector3(1,0,0), -angle)
	
	# angle to X - rotate Z
	tmp_vec = Vector3(triangle[2][0], triangle[2][1], 0)
	angle = tmp_vec.angle_to(Vector3(-1,0,0))
	triangle[2] = triangle[2].rotated(Vector3(0,0,1), angle)

	return triangle


func _on_CheckButton_toggled(button_pressed):
	var tmp = get_node("/root/Spatial/GUI/GridContainer/CheckButton")
	self.visible = button_pressed
	print(self.visible)
