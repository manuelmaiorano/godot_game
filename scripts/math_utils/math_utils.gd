class_name  MathUtils

static func pick_random_xz_vector():
	return Vector3.RIGHT.rotated(Vector3.UP, randf_range(0, deg_to_rad(360)))
