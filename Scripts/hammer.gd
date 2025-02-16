extends RigidBody3D


var dropped = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if dropped == true:
		apply_impulse(transform.basis.z, -transform.basis.z * 10)
		dropped = false
