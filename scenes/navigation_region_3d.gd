extends NavigationRegion3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	navigation_mesh.set_agent_radius(4.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
