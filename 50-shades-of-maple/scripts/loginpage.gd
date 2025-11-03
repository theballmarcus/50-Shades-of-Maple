extends Control

@export var topRectSize = Vector2(1280,60)
@export var topRectColor = Color(0.114, 0.38, 0.627, 1.0)
@export var bottomRectSize = Vector2(1280,720)
@export var bottomRectColor = Color(0.271, 0.537, 0.784, 0.706)

func _ready():
	queue_redraw()

#Background
func _draw():
	draw_rect(Rect2(Vector2.ZERO,topRectSize),topRectColor)
	draw_rect(Rect2(Vector2(0,60),bottomRectSize),bottomRectColor)

#Buttons
func _on_info_button_pressed() -> void:
	pass # Replace with function body.

func _on_close_button_pressed() -> void:
	get_tree().quit()
