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

var inters = []
var points = []

func build(list_tube_faces):
	self.inters = []
	var rib_section_radius = 0.1

	for ang in range(0, 360, 30):
	
		#
		# TODO: build spokes correctly, they are not placed
		#       along the profile and are NOT moved correctly
		#
		var spoke = Vector3(0, rib_section_radius, 0)
		spoke = spoke.rotated(Vector3(0,0,1), deg2rad(ang))
		var spoke_end = spoke + Vector3(0.4, 0.9, -0.7)

		#
		# Shoot lazers from spoke ends into the LE tubes
		# measure where the lazers hit
		#
		var lazer = Vector3(0, 0.2, 1.5)
		var inter = {
			'start'     : spoke_end,
			'direction' : lazer,
			'intersect' : false
		}
		
		for tube_faces in list_tube_faces:
			var tmp = self.find_intersects(spoke_end, lazer, tube_faces)
			if len(tmp) > 0:
				inter['intersect'] = tmp[0]
			
		inters.append(inter)
		
# highlight the end of the rib where it connects to the LE
func render_end_highlight(surface_tool, tube_faces):
	for pos in len(self.inters)-1:
		surface_tool.add_color(Color8(255,0,255))
		
		#surface_tool.add_vertex(i['start']+i['direction'])
		if self.inters[pos]['intersect'] and self.inters[pos+1]['intersect']:
			surface_tool.add_vertex(self.inters[pos]['intersect'])
			surface_tool.add_vertex(self.inters[pos+1]['intersect'])
			
	# COMPLETE CIRCLE
	if self.inters[-1]['intersect'] and self.inters[0]['intersect']:
		surface_tool.add_vertex(self.inters[-1]['intersect'])
		surface_tool.add_vertex(self.inters[0]['intersect'])

func render(surface_tool, tube_faces):
	
	for i in self.inters:
		surface_tool.add_color(Color8(70,70,70))
		#surface_tool.add_color(Color8(255,0,255))
		surface_tool.add_vertex(i['start'])
		#surface_tool.add_vertex(i['start']+i['direction'])
		if i['intersect']:
			surface_tool.add_vertex(i['intersect'])
		else:
			# NO INTERSECTION found - show lazer shooting
			# off into the distance. Good User Experience
			surface_tool.add_vertex(i['start']+i['direction'])
			
	self.render_end_highlight(surface_tool, tube_faces)

	
	var line1 = tube_faces[0][0]
	var line2 = tube_faces[0][1]
	
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
	
