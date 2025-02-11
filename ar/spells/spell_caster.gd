extends Node3D


const FIREBALL := preload("res://ar/spells/fireball.tscn")


@onready var controller : XRController3D = get_parent()

# In-spell flag
var _in_spell : bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle spell poses
	if controller.is_button_pressed("fireball"):
		# On rising-edge trigger spell
		if not _in_spell:
			_in_spell = true
			var fireball := FIREBALL.instantiate()
			fireball.global_transform = global_transform
			fireball.top_level = true
			add_child(fireball)
	else:
		# Clear spell if not active
		_in_spell = false
