extends AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_animation = 'bullet_test'
	# Optionally, you can start playing the animation here
	play(current_animation)

func do_event() -> void:
		# Find all nodes in the "spawner" group
	var spawners = get_tree().get_nodes_in_group("spawner")
	
	# Call shoot_projectile() on each spawner
	for spawner in spawners:
		if spawner.has_method("shoot_projectile"):
			spawner.shoot_projectile()
