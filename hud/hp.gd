extends Control

var father:Entity=null

func _ready() -> void:
	var f1=get_parent()
	if f1 is Entity:father=f1
	else:
		var f2=f1.get_parent()
		if f2 is Entity:father=f2


func _physics_process(delta: float) -> void:
	if father:
		%TextureProgressBar.value=father.hp
		if %TextureProgressBarBack.value==%TextureProgressBar.value:pass
		else:%TextureProgressBarBack.value=move_toward(%TextureProgressBarBack.value,%TextureProgressBar.value,50*delta)
