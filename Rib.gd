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
		
	return ret

var p = 0.9
var d = 0.01

func render(surface_tool, tube_faces):
	self.p += self.d
	if p > 1.2:
		self.d *= -1
	if p < 0.7:
		self.d *= -1
		
	var a = Vector3(0.1, self.p, -0.7)
	var b = Vector3(0, 0.2, 1.5)
	
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
		
	var points = self.find_intersects(a, b, tube_faces)
	for p in points:
		surface_tool.add_color(Color8(255,0,0))
		surface_tool.add_vertex(p)
		surface_tool.add_vertex(p+Vector3(0,0.2,0))
	
