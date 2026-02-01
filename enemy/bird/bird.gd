extends Enemy

enum State{
	NULL,IDLE,WALK,DIE
}
var current_state:State=State.NULL
var speed=100

func _physics_process(delta: float) -> void:
	if is_hurted:
		is_hurted=false
		hp-=%Hurtbox.damage
		effect_num(%Hurtbox.damage)
		%Hurtbox.damage=0
		%AnimationPlayer2.play("hurt")
		print(hp)
	velocity.x=0
	#1/3.状态判断
	var next_state=current_state
	if hp<=0:next_state=State.DIE
	else:
		match current_state:
			State.NULL:next_state=State.IDLE
			State.IDLE:
				if %Timer.is_stopped():next_state=State.WALK
			State.WALK:
				if %Timer.is_stopped():next_state=State.IDLE
	#2/3.状态切换
	if next_state==current_state:pass
	else:
		match current_state:
			State.IDLE:pass
		match next_state:
			State.IDLE:
				%AnimationPlayer.play("idle")
				%Timer.start(0.8)
			State.WALK:
				%AnimationPlayer.play("walk")
				if Global.player:
					var diff=Global.player.position.x-position.x;
					direction=-1 if diff<0 else 1
				%Timer.start(0.1)
			State.DIE:%AnimationPlayer.play("die")
		current_state=next_state
	#3/3.状态运行
	match current_state:
		State.WALK:
			velocity.x=direction*speed
	
	move_and_slide()


func _on_hurtbox_get_damage() -> void:
	is_hurted=true
