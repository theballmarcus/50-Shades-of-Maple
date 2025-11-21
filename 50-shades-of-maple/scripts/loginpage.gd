extends Control

@onready var SignUpWindow = $SignUpWindow
@onready var LoginWindow = $LoginWindow
@onready var Requests = $HTTPRequest
@onready var Username = $"SignUpWindow/Username/Type your username"
@onready var Password = $"SignUpWindow/Password/Type your password"
@onready var UsernameLogin = $"LoginWindow/Username/Type your username"
@onready var PasswordLogin = $"LoginWindow/Password/Type your password"

var user_data = {}
var config

func _ready():
	queue_redraw()

	Requests.request_completed.connect(_on_request_complete)
	
	config = ConfigFile.new()
	var err = config.load("user://user_data.cfg")

	if err != OK:
		return
	# If token exists, try to validate it for auto-login flow
	var token = config.get_value("UserInfo", "JWT")
	if token != null:
		Gamestate.JWT = token
		Requests.request(Gamestate.API_URL + "/token/validate", Gamestate.headers + ["Authorization: Bearer " + token], HTTPClient.METHOD_GET)

func _on_login_button_pressed() -> void:
	Sound.play_sound("ButtonClicked")
	var data = {"username":UsernameLogin.text,"password":PasswordLogin.text}
	Requests.request(Gamestate.API_URL + "/login", Gamestate.headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	

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
	var data = {"username":Username.text,"password":Password.text}
	Requests.request(Gamestate.API_URL + "/users", Gamestate.headers, HTTPClient.METHOD_POST, JSON.stringify(data))

func _on_request_complete(result,response_code,headers,body):
	if result != OK:
		print("Request failed!")
		return
	
	var body_text = body.get_string_from_utf8()
	
	if response_code != 200:
		print("Response code:", response_code)
		print(body_text)
		return

	var json = JSON.parse_string(body_text)
	print(json)
	
	if json == null:
		return
	
	if json.has("token"):
		save_user_data(json)
		Gamestate.change_scene("res://instances/mainmenu.tscn")
		
	elif json.has("valid"):
		if json["valid"] == true:
			save_user_data(json)
			Gamestate.change_scene("res://instances/mainmenu.tscn")

	else:
		print("ERROR")
func save_user_data(json):
	if json.has("token"):
		Gamestate.JWT = json["token"]
		config.set_value("UserInfo","JWT", json["token"])
		
	if json.has("user"):
		if json["user"].has("name"):
			Gamestate.username = json["user"]["name"]
			config.set_value("UserInfo","username",  json["user"]["name"])
		if json["user"].has("id"):
			Gamestate.user_id =  json["user"]["id"]
			config.set_value("UserInfo","user_id",   json["user"]["id"])
			
	config.save("user://user_data.cfg")
