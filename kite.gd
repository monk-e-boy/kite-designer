extends MeshInstance

#
# UPDATED RARELY
#
#

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(SpatialMaterial) var material

# Called when the node enters the scene tree for the first time.
func _ready():
	var surface_tool = SurfaceTool.new()
	
	# TODO replace with self.get_mesh
	var mesh = Mesh.new()
	#var material = SpatialMaterial.new()
	#material.albedo_color = Color(1,0,0,1)
	#material.params_diffuse_mode = SpatialMaterial.DIFFUSE_BURLEY
	
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_material(material)
	
	# bottom left corner
	surface_tool.add_uv(Vector2(0,0))
	surface_tool.add_vertex(Vector3(-3,1,0))

	surface_tool.add_uv(Vector2(0.5,1))
	surface_tool.add_vertex(Vector3(0,3,0))

	surface_tool.add_uv(Vector2(1,0))
	surface_tool.add_vertex(Vector3(3,1,0))
	
	surface_tool.generate_normals()
	surface_tool.index()
	
	surface_tool.commit(mesh)
	self.set_mesh(mesh)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
