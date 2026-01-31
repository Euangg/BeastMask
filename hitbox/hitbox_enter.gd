extends Area2D

@export var damage:float=5

func _ready() -> void:area_entered.connect(on_target_entered)

func on_target_entered(a:Hurtbox):
	a.damage+=damage
	a.get_damage.emit()
