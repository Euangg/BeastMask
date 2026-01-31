extends Control

func _on_button_pressed() -> void:Global.switch_scene(Global.UI_THEME)

func _ready() -> void:Global.play_sfx(Global.SFX_PASS)
