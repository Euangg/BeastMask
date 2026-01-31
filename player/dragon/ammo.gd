extends Node2D

var velocity:Vector2

func _physics_process(delta: float) -> void:
	position+=velocity*delta

func on_hit_target(_target):queue_free()

func _on_timer_timeout() -> void:queue_free()
