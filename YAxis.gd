extends MeshInstance

export(SpatialMaterial) var material

func _ready():
	var surface_tool = SurfaceTool.new()
	
	# TODO replace with self.get_mesh
	var mesh = Mesh.new()
	surface_tool.begin(Mesh.PRIMITIVE_LINES)
	surface_tool.set_material(material)
	
	surface_tool.add_vertex(Vector3(0,5,0))
	surface_tool.add_vertex(Vector3(0,-5,0))
	
	surface_tool.generate_normals()
	surface_tool.commit(mesh)
	self.set_mesh(mesh)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
