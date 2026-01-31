extends Enemy

func _physics_process(delta: float) -> void:
	if is_hurted:
		is_hurted=false
		hp-=%Hurtbox.damage
		%Hurtbox.damage=0
		print(hp)
		if hp<=0:
			dead.emit()
			queue_free()

func _on_hurtbox_get_damage() -> void:
	is_hurted=true
