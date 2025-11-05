extends Control

@onready var InfoMenu = $InfoMenu
@onready var BlurOverlay = $BlurOverlay

func _ready():
	queue_redraw()
	InfoMenu.visible=false
	BlurOverlay.visible=false

#Buttons
func _on_info_button_pressed() -> void:
	InfoMenu.visible=not InfoMenu.visible
	BlurOverlay.visible=true
	Sound.play_sound("ButtonClicked")

func _on_close_info_button_pressed() -> void:
	InfoMenu.visible=false
	BlurOverlay.visible=false
	Sound.play_sound("ButtonClicked")

func _on_close_button_pressed() -> void:
	Sound.play_sound("ButtonClicked")
	get_tree().quit()
