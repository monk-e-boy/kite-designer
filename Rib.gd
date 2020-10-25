extends Node


func _init():
	var x = 1

func find_intersects_edges(from, direction, edge1, edge2):
	var ret = []
	var intersection_point = false
	
	intersection_point = Geometry.ray_intersects_triangle(
		from, direction,
		edge1[0], edge1[1], edge2[0]
	)
	
	if intersection_point:
		ret.append(intersection_point)
		
	intersection_point = Geometry.ray_intersects_triangle(
		from, direction,
		edge1[1], edge2[1], edge2[0]
	)
	
	if intersection_point:
		ret.append(intersection_point)
		
	return ret

func find_intersects(from, direction, tube_faces):
	var ret = []
	var intersection_point = false
	
	# rotate around the tube finding triangles
	# and test each one
	for i in range(len(tube_faces)-1):
		var line1 = tube_faces[i]
		var line2 = tube_faces[i+1]
		ret += self.find_intersects_edges(from, direction, line1, line2)
	
	# COMPLETE THE CIRCLE / tube
	var line1 = tube_faces[len(tube_faces)-1]
	var line2 = tube_faces[0]
	ret += self.find_intersects_edges(from, direction, line1, line2)
	
	if len(ret) > 1:
		# multiple intersections (front and back)
		# choose closest to 'from'
		# TODO: loop over all items, not just first two
		#       more than two items is a possibility
		var d1 = from.distance_to(ret[0])
		var d2 = from.distance_to(ret[1])
		
		if d1 > d2:
			ret = [ret[1]]
		else:
			ret = [ret[0]]
		
	return ret

var ang = 0
var a = Vector3(0,0,0)
var b = Vector3(0,0,0)
var points = []

func build(tube_faces):
	var r = Vector3(0, 0.1, 0);
	r = r.rotated(Vector3(0,0,1), deg2rad(self.ang))
		
	self.a = r + Vector3(0.4, 0.9, -0.7)
	self.b = Vector3(0, 0.2, 1.5)
	
	self.points += self.find_intersects(self.a, self.b, tube_faces)


func render(surface_tool, tube_faces):
	#if self.ang < 362:
	self.ang += 2
	
	if self.ang > 362:
		self.ang = 0
		self.points = []
	
	# SEAM is PURPLE
	surface_tool.add_color(Color8(255,0,255))
	surface_tool.add_vertex(a)
	surface_tool.add_vertex(a+b)
	
	var line1 = tube_faces[0]
	var line2 = tube_faces[1]
	
	surface_tool.add_color(Color8(255,0,0))
	surface_tool.add_vertex(line1[0])
	surface_tool.add_vertex(line1[1])
	
	surface_tool.add_vertex(line1[0])
	surface_tool.add_vertex(line2[0])
	
	surface_tool.add_vertex(line1[1])
	surface_tool.add_vertex(line2[0])
	
#	var tmp = Geometry.ray_intersects_triangle(a, b, line1[0], line1[1], line2[0])
#	
#	if tmp:
#		surface_tool.add_color(Color8(255,0,0))
#		surface_tool.add_vertex(tmp)
#		surface_tool.add_vertex(tmp+Vector3(0,0.2,0))
#	else:
#		var x = 0
		
	
	for i in len(self.points)-1:
		surface_tool.add_color(Color8(255,0,0))
		surface_tool.add_vertex(self.points[i])
		surface_tool.add_vertex(self.points[i+1])
	
