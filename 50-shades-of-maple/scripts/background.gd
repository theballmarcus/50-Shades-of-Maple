extends Node
@onready var InfoMenu = $InfoMenu
@onready var BlurOverlay = $BlurOverlay
@onready var SettingsMenu = $SettingsMenu
@onready var AccountMenu = $AccountMenu
@onready var BackButton = $BackButton

var color1blue = Color(0.114, 0.38, 0.627, 1.0)

var config

func _ready():
	if Gamestate.scene_index == 0:
		BackButton.visible = false
	else:
		BackButton.visible = true		
		
	SettingsMenu.visible = false
	InfoMenu.visible = false
	AccountMenu.visible = false
	BlurOverlay.visible = false

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
	
func _on_back_button_pressed() -> void:
	Sound.play_sound("ButtonClicked")
	Gamestate.go_back()

func _on_account_button_pressed() -> void:
	AccountMenu.visible=not AccountMenu.visible
	BlurOverlay.visible=true
	Sound.play_sound("ButtonClicked")

func _on_account_close_button_pressed() -> void:
	AccountMenu.visible=false
	BlurOverlay.visible=false
	Sound.play_sound("ButtonClicked")

func _on_logout_button_pressed() -> void:
	Gamestate.JWT = "" # Replace with function body.
	config.erase_section("UserInfo")
	config.save("user://user_data.cfg")
	Gamestate.change_scene("res://instances/loginpage.tscn")
	Gamestate.clear_scene_history()
