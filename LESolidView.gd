extends MeshInstance


export(SpatialMaterial) var material
#var surface_tool = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var parent = get_node("..")
	var leading_edge = parent.leading_edge
	
	#
	#
	var mesh = Mesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_material(self.material)
	#
	#
	var index = 0
	var selected_face = 0
	var tube_faces = leading_edge.get_tube_faces(selected_face)

	for c in len(tube_faces):
		var line1 = tube_faces[c]
		var line2 = []
		
		if not c == len(tube_faces)-1:
			line2 = tube_faces[c+1]
		else:
			line2 = tube_faces[0]
			
		var s = surface_tool
		
		# Top Left triangle
		# +----+
		# |   /
		# | /
		# +
		#
		s.add_vertex(line1[0])	;	s.add_index(index)	;	index += 1
		s.add_vertex(line1[1])	;	s.add_index(index)	;	index += 1
		s.add_vertex(line2[0])	;	s.add_index(index)	;	index += 1
		# Bottom Right triangle
		#      +
		#    / |
		#  /   |
		# +----+
		s.add_vertex(line1[1])	;	s.add_index(index)	;	index += 1
		s.add_vertex(line2[1])	;	s.add_index(index)	;	index += 1
		s.add_vertex(line2[0])	;	s.add_index(index)	;	index += 1
		

	surface_tool.generate_normals()
	
	surface_tool.commit(mesh)
	self.set_mesh(mesh)

