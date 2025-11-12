extends Control

@onready var InfoMenu = $InfoMenu
@onready var BlurOverlay = $BlurOverlay
@onready var SignUpWindow = $SignUpWindow
@onready var LoginWindow = $LoginWindow

var username = ""
var password = ""
var created = false

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

func _on_login_button_pressed() -> void:
	Sound.play_sound("ButtonClicked")

func _on_back_to_login_button_pressed() -> void:
	Sound.play_sound("ButtonClicked")
	SignUpWindow.visible=false
	LoginWindow.visible=true

func _on_go_to_sign_up_pressed() -> void:
	Sound.play_sound("ButtonClicked")
	SignUpWindow.visible=true
	LoginWindow.visible=false

func _on_sign_up_button_pressed() -> void:
	Sound.play_sound("ButtonClicked")

func _on_create_account_button_pressed() -> void:
	Sound.play_sound("ButtonClicked")
	SignUpWindow.visible=false
	LoginWindow.visible=true
