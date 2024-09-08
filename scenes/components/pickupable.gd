@tool
extends Node3D

signal picked_up(player: Player)

@export var pickup_sound: AudioStream  # Sound to play when picked up
@export var pickup_effect: PackedScene  # Optional scene to instantiate on pickup (like particles)
@export var disappear_on_pickup: bool = true  # If true, the pickup will disappear after being collected
@export var area: Area3D

var _has_been_picked: bool = false

func _ready() -> void:
	if not area:
		push_error("PickupComponent requires an Area3D to function!")
		return
		
	# Connect the body_entered signal of the Area3D to handle pickups
	area.body_entered.connect(_on_body_entered)

# Called when the object is picked up
func on_pickup(player: Player) -> void:
	if _has_been_picked:
		return
	
	_has_been_picked = true

	# Emit the signal so other objects can react to this event
	emit_signal("picked_up", player)

	# Declare sound_player outside the conditional block
	var sound_player: AudioStreamPlayer3D

	# Play pickup sound
	if pickup_sound:
		sound_player = AudioStreamPlayer3D.new()
		sound_player.stream = pickup_sound
		add_child(sound_player)
		sound_player.play()

	# Optional effect (like particles)
	if pickup_effect:
		var effect_instance = pickup_effect.instantiate()
		add_child(effect_instance)

	# Handle disappearance if required
	if disappear_on_pickup:
		# If sound was played, wait for the sound to finish, then remove the node
		if sound_player:
			await sound_player.finished
		queue_free()

# Function for detecting player collision via the Area3D node
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		on_pickup(body)

func _get_configuration_warnings() -> PackedStringArray:
	if not area:
		return PackedStringArray(["PickupComponent requires an Area3D to be assigned for it to work. Please assign an Area3D."])
	return PackedStringArray([])
