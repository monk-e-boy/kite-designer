extends MeshInstance

# Cull Mode - None (show back and front)
# Unshaded
# Transparent
export(SpatialMaterial) var material


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var parent = get_node("..")
	var leading_edge = parent.leading_edge
	var section = leading_edge.get_highlight_plane_section()
	if not section:
		return
		
	var plane = section.plane
	
	#
	#
	var mesh = Mesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_material(self.material)
	#
	#
	var index = 0
	var s = surface_tool
	
	
	var p1 = plane.v1-plane.v2
	p1 = p1.normalized()
	var p2 = plane.v3-plane.v2
	p2 = p2.normalized()
	var p3 = p1 * -1
	var p4 = p2 * -1
	
	var c = Color8(255,255,0)
	surface_tool.add_color(c)
	
	# square
	surface_tool.add_vertex(plane.v2+p1)	;	s.add_index(index)	;	index += 1
	surface_tool.add_vertex(plane.v2+p2)	;	s.add_index(index)	;	index += 1
	surface_tool.add_vertex(plane.v2+p3)	;	s.add_index(index)	;	index += 1
	
	surface_tool.add_vertex(plane.v2+p3)	;	s.add_index(index)	;	index += 1
	surface_tool.add_vertex(plane.v2+p4)	;	s.add_index(index)	;	index += 1
	surface_tool.add_vertex(plane.v2+p1)	;	s.add_index(index)	;	index += 1
	
	surface_tool.generate_normals()
	
	surface_tool.commit(mesh)
	self.set_mesh(mesh)
