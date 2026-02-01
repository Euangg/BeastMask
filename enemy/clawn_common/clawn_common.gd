extends Enemy

enum State{NULL,IDLE,MOVE,ATTACK,DIE}
var current_state:State=State.NULL
var battle_mode=false

var target_position:Vector2
var target:Node2D=null
var target_dir:float=0

func _physics_process(delta: float) -> void:
	if battle_mode:
		if current_state!=State.DIE:
			if is_hurted:
				is_hurted=false
				hp-=%Hurtbox.damage
				if hp<=70:%AnimationPlayer.play("danger")
				%Hurtbox.damage=0
				%AnimationPlayer2.play("hurt")
				print(hp)
		#1/3.状态判断
		var next_state=current_state
		if hp<=0:next_state=State.DIE
		else:
			match current_state:
				State.NULL:next_state=State.IDLE
				State.IDLE:
					if %TimerIdle.is_stopped():
						next_state=State.MOVE
				State.MOVE:
					if %TimerMove.is_stopped():next_state=State.ATTACK
					if position.distance_to(target_position)<=10:next_state=State.ATTACK
				State.ATTACK:
					if %TimerAttack.is_stopped():next_state=State.IDLE
		#2/3.状态切换
		if next_state==current_state:pass
		else:
			match current_state:
				pass
			match next_state:
				State.IDLE:
					velocity=Vector2.ZERO
					%TimerIdle.start()
				State.MOVE:
					target=Global.player
					target_dir=randf_range(0,TAU)
					%TimerMove.start()
				State.ATTACK:
					velocity=(target.position-position).normalized()*600
					%TimerAttack.start()
				State.DIE:%AnimationPlayer.play("die")
		current_state=next_state
		#3/3.状态运行
		match current_state:
			State.MOVE:
				target_position=target.position+600*Vector2.from_angle(target_dir)
				velocity=(target_position-position).normalized()*300
				move_and_slide()
			State.ATTACK:
				move_and_slide()
	else:
		velocity=(target_position-position).normalized()*100
		move_and_slide()
		if position.distance_to(target_position)<=5:
			print("battle!")
			battle_mode=true
			%Hurtbox.monitorable=true


func die():
	queue_free()
	dead.emit()
func _on_hurtbox_get_damage() -> void:is_hurted=true
