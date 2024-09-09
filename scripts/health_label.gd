extends Label

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		player.health_changed.connect(_on_character_health_changed)

func _on_character_health_changed(health: int) -> void:
	text = "Health: %s" % health
