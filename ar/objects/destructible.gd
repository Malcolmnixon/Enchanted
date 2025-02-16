extends StaticBody3D


var _grown : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set the plant scale to zero and disable collision
	%Object.scale = Vector3.ZERO
	%Collision.disabled = true

	# Tween scaling the plant to full size
	var tween = get_tree().create_tween()
	tween.tween_property(%Object, "scale", Vector3.ONE, 1.0)
	tween.tween_callback(_on_grown)


# Called when fully grown
func _on_grown() -> void:
	# Enable collision
	%Collision.disabled = false
	_grown = true


func damage() -> void:
	# Cannot damage if not grown
	if not _grown:
		return

	# Disable collision
	%Collision.disabled = true
	_grown = false

	# Shrink and destroy
	var tween = get_tree().create_tween()
	tween.tween_property(%Object, "scale", Vector3.ZERO, 1.0)
	tween.tween_callback(queue_free)
