extends Control

var color1blue = Color(0.114, 0.38, 0.627, 1.0)
@onready var SettingsMenu = $SettingsMenu
@onready var InfoMenu = $InfoMenu
@onready var BlurOverlay = $BlurOverlay

func _ready():
	SettingsMenu.visible=false
	InfoMenu.visible=false
	BlurOverlay.visible=false

#Buttons
func _on_settings_button_pressed() -> void:
	SettingsMenu.visible=not SettingsMenu.visible
	BlurOverlay.visible=SettingsMenu.visible
	Sound.play_sound("ButtonClicked")

func _on_close_settings_button_pressed() -> void:
	SettingsMenu.visible=false
	BlurOverlay.visible=false
	Sound.play_sound("ButtonClicked")

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
