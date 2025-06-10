extends Resource

class_name Tile

enum Constraint {OPEN, CLOSE}

@export var id: int
@export var edges: Array[Constraint]
@export var debug_str = ""
@export var scene: PackedScene
