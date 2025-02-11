extends AnimatableBody3D


const VELOCITY := 2.5


var _hit : bool = false
var _expire : float = 3.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update expiration timer
	_expire -= delta
	
	# Process if not hit
	if not _hit:
		# Move the fireball and update expiration time
		var collision := move_and_collide(-global_basis.z * VELOCITY * delta)

		# Handle collision or flight-expiration
		if collision or _expire <= 0.0:
			# Stop emitting and let expire
			%GPUParticles3D.emitting = false
			_hit = true
			_expire = 1.0

	# Free if expired
	if _hit and _expire <= 0.0:
		queue_free()
