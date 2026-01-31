extends Area2D

@export var damage:float
var hurtboxes:Array[Hurtbox]=[]

func _ready() -> void:area_entered.connect(on_target_entered)

func on_target_entered(a:Hurtbox):
	if a in hurtboxes:return
	a.damage+=damage
	a.get_damage.emit()
	hurtboxes.push_back(a)
