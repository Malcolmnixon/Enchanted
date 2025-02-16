extends AnimatableBody3D


const VELOCITY := 4.0

const DAMAGE_RANGE := 0.8


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
			# Trigger explosion
			_explode()
			_hit = true
			_expire = 2.0

	# Free if expired
	if _hit and _expire <= 0.0:
		queue_free()


func _explode() -> void:
	# Perform explision
	%TrailParticles.emitting = false
	%ExplosionParticles.emitting = true
	%ExplosionSound.play()

	var kill_list := get_tree().get_nodes_in_group("destructible")
	for k in kill_list:
		if global_position.distance_to(k.global_position) < DAMAGE_RANGE:
			k.damage()
		
	
	
	
