class_name  MathUtils

static func pick_random_xz_vector(radius_min=1.0, radius_max=1.0):
	return Vector3.RIGHT.rotated(Vector3.UP, randf_range(0, deg_to_rad(360))) * randf_range(radius_min, radius_max)


static func create_matrix(size, fill):
	var matrix = []
	for i in range(size.y):
		var row = []
		for j in range(size.x):
			row.append(null)
		matrix.append(row)
	
	return matrix
