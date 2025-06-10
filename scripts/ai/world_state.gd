extends Node

var shared_scope: Blackboard

func _ready() -> void:
	shared_scope = Blackboard.new()
	shared_scope.set_var(&"global_targets", [])
	shared_scope.set_var(&"world_event", null)
	
	SignalBus.WorldEvent.connect(on_world_event)
	
func on_world_event(where):
	shared_scope.set_var(&"world_event", where)
	call_deferred(&"clear")

func clear():
	shared_scope.set_var(&"world_event", null)

func _physics_process(delta: float) -> void:
	DebugDraw2D.set_text(name, "world_event: %s" % shared_scope.get_var(&"world_event", null, false), 64)
