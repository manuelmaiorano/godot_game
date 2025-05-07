extends Node3D
class_name HealthBar

@onready var mesh: MeshInstance3D = %Mesh
var gradient

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat = mesh.get_active_material(0) as StandardMaterial3D
	var texture = mat.albedo_texture as GradientTexture1D
	gradient = texture.gradient as Gradient
	gradient.offsets[1] = 1


func set_health(health_percentage):
	gradient.offsets[1] = clamp(health_percentage, 0, 1)
