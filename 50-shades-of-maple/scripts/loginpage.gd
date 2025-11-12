extends Control

@onready var InfoMenu = $InfoMenu
@onready var BlurOverlay = $BlurOverlay
@onready var SignUpWindow = $SignUpWindow
@onready var LoginWindow = $LoginWindow
@onready var Requests = $HTTPRequest
@onready var Username = $"SignUpWindow/Username/Type your username"
@onready var Password = $"SignUpWindow/Password/Type your password"
@onready var UsernameLogin = $"LoginWindow/Username/Type your username"
@onready var PasswordLogin = $"LoginWindow/Password/Type your password"

func _ready():
	queue_redraw()
	InfoMenu.visible=false
	BlurOverlay.visible=false
	Requests.request_completed.connect(_on_request_complete)

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
	var headers = ["Content-Type: application/json", Gamestate.API_KEY]
	var data = {"username":UsernameLogin.text,"password":PasswordLogin.text}
	Requests.request(Gamestate.API_URL + "/login",headers,HTTPClient.METHOD_POST,JSON.stringify(data))
	

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
	var headers = ["Content-Type: application/json", Gamestate.API_KEY]
	var data = {"username":Username.text,"password":Password.text}
	Requests.request(Gamestate.API_URL + "/users",headers,HTTPClient.METHOD_POST,JSON.stringify(data))

func _on_request_complete(result,response_code,headers,body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	print(response_code)
	if json.has("token"):
		Gamestate.JWT_TOKEN = json["token"]
		get_tree().change_scene_to_file("res://instances/mainmenu.tscn")
	else:
		print("ERROR")
