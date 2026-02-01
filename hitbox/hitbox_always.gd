extends Area2D

@export var damage:float=5

func _physics_process(delta: float) -> void:
	var hurtboxes:Array=get_overlapping_areas()
	for h in hurtboxes:
		h.damage+=damage
		h.get_damage.emit()
