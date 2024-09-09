@tool
extends MeshInstance3D

const PRISM_RADIUS = 0.5
const PRISM_HEIGHT = 1.0

var array_vertices = []
var array_indices = []
var vertex_dict = {}
var rotation_speed = 0.1 # Speed of rotation

func _ready():
	make_hexagon_prism()
	if Engine.is_editor_hint():
		set_process(true)

func _process(delta):
	if Engine.is_editor_hint():
		rotate_y(rotation_speed * delta)

func make_hexagon_prism():
	array_vertices.clear()
	array_indices.clear()
	vertex_dict.clear()
	
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate top and bottom vertices of the hexagon
	var top_vertices = []
	var bottom_vertices = []
	for i in range(6):
		var angle = i * (PI / 3)  # 60 degrees in radians
		var x = PRISM_RADIUS * cos(angle)
		var z = PRISM_RADIUS * sin(angle)
		var top_vertex = Vector3(x, PRISM_HEIGHT / 2, z)
		var bottom_vertex = Vector3(x, -PRISM_HEIGHT / 2, z)
		top_vertices.append(top_vertex)
		bottom_vertices.append(bottom_vertex)
	
	# Add center points for top and bottom faces
	var top_center = Vector3(0, PRISM_HEIGHT / 2, 0)
	var bottom_center = Vector3(0, -PRISM_HEIGHT / 2, 0)
	
	# Add top face triangles
	for i in range(6):
		var idx0 = _add_or_get_vertex(top_center)
		var idx1 = _add_or_get_vertex(top_vertices[i])
		var idx2 = _add_or_get_vertex(top_vertices[(i + 1) % 6])
		
		array_indices.append(idx0)
		array_indices.append(idx1)
		array_indices.append(idx2)
	
	# Add bottom face triangles
	for i in range(6):
		var idx0 = _add_or_get_vertex(bottom_center)
		var idx1 = _add_or_get_vertex(bottom_vertices[(i + 1) % 6])
		var idx2 = _add_or_get_vertex(bottom_vertices[i])
		
		array_indices.append(idx0)
		array_indices.append(idx1)
		array_indices.append(idx2)
	
	# Add side quads (as two triangles each)
	for i in range(6):
		var top_idx1 = _add_or_get_vertex(top_vertices[i])
		var top_idx2 = _add_or_get_vertex(top_vertices[(i + 1) % 6])
		var bottom_idx1 = _add_or_get_vertex(bottom_vertices[i])
		var bottom_idx2 = _add_or_get_vertex(bottom_vertices[(i + 1) % 6])
		
		# First triangle of quad
		array_indices.append(top_idx1)
		array_indices.append(bottom_idx1)
		array_indices.append(bottom_idx2)
		
		# Second triangle of quad
		array_indices.append(top_idx1)
		array_indices.append(bottom_idx2)
		array_indices.append(top_idx2)
	
	# Add vertices and indices to the SurfaceTool
	for vertex in array_vertices:
		surface_tool.add_vertex(vertex)
	for index in array_indices:
		surface_tool.add_index(index)
	
	# Generate normals
	surface_tool.generate_normals()
	
	# Commit the mesh
	var mesh = surface_tool.commit()
	self.mesh = mesh

func _add_or_get_vertex(vertex: Vector3) -> int:
	var key = vertex
	if vertex_dict.has(key):
		return vertex_dict[key]
	else:
		array_vertices.append(vertex)
		var index = array_vertices.size() - 1
		vertex_dict[key] = index
		return index
