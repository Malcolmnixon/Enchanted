extends AnimatableBody3D


const MOSS_FLOWER := preload("res://ar/objects/moss_flower.tscn")

const GRASS := preload("res://ar/objects/yard_grass.tscn")



const VELOCITY := 4.0


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
			# Spawn plant at the collision point
			_spawn_plant(collision)

			# Stop emitting and let expire
			%TrailParticles.emitting = false
			_hit = true
			_expire = 2.0

	# Free if expired
	if _hit and _expire <= 0.0:
		queue_free()


# Spawn a plant at the collision point
func _spawn_plant(collision : KinematicCollision3D) -> void:
	# Get the collision point and normal
	var pos := collision.get_position()
	var normal := collision.get_normal()

	# Construct the transform
	var q := Quaternion(Vector3.UP, normal)
	var b := Basis(q).rotated(normal, randf_range(-PI, PI))
	var xform := Transform3D(b, pos)

	# Pick the plant (should use normal for this)
	var scene : PackedScene
	if normal.dot(Vector3.UP) > 0.8:
		scene = GRASS
	else:
		scene = MOSS_FLOWER

	# Spawn the plant
	var plant := scene.instantiate()
	get_parent().add_child(plant)
	plant.top_level = true
	plant.global_transform = xform
