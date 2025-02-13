extends Node3D


const FIREBALL := preload("res://ar/spells/fireball.tscn")

const LIGHTNING := preload("res://ar/spells/lightning.tscn")


@onready var controller : XRController3D = get_parent()

# Power level (1.0 is fully-charged)
var _power : float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle charging
	if controller.is_button_pressed("charge"):
		# Charge up
		_power = clampf(_power + delta, 0.0, 1.0)
		%PowerParticles.amount_ratio = _power

	# Skip if not charged up
	if _power < 0.8:
		return

	# Handle casting spell
	if controller.is_button_pressed("fireball"):
		# Spawn fireball
		_power = 0.0
		%PowerParticles.amount_ratio = 0.0
		_spawn_fireball()
	elif controller.is_button_pressed("lightning"):
		# Spawn lightning
		_power = 0.0
		%PowerParticles.amount_ratio = 0.0
		_spawn_lightning()


func _spawn_fireball() -> void:
	# Cast fireball
	var fireball := FIREBALL.instantiate()
	fireball.global_transform = global_transform
	fireball.top_level = true
	add_child(fireball)


func _spawn_lightning() -> void:
	# Cast fireball
	var lightning := LIGHTNING.instantiate()
	lightning.global_transform = global_transform
	lightning.top_level = true
	add_child(lightning)
