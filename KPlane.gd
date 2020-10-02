#class KPlane:

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
