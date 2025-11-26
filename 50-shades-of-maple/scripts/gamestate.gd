extends Node

# Global variables
var soundEffectLevel :float= 0.05
var JWT = ""
var menuChapter
var curChapter
var curChapterSolved = false

# Constants
const chapters = {
	"Basics" : {
		"Intro" : {
			"text" :"[h]Velkommen til Maple[/h][br][br]Maple er et matematikprogram, der kan hjælpe med at løse de matematiske problemer, du står over for i skolen.[br][br]Til højre er der en boks, som kan køre maple kode. For at komme videre, skriv [c]2+2[/c] og klik submit.",
			"correct_answers" : ["4"],
			"id" : 1
		},
		"Aritmetik" : {
			"dependency" : ["Intro"],
			"text" : "I dette forløb skal du lærer om de forskelige basale matematiske operatorer, det er blandet andet multiplikation, division, addition, potens osv.[br][br]Der er forskellige måder at tilføje en matematisk operator på, og det varierer også for hvilket operator du har med at gøre. For addition er det et simpelt +, det samme gælder division (/), subtraktion (-) og multiplikation (*). For potens trykker man på tasten shirt + ¨ så du får ^. Kvadratrod kan du skrive med sqrt(værdi) eller finde funktionen under expressions i Maple.[br][br]Skriv [c]sqrt(5+5*10/2+5²-6)[/c] for at komme videre.",
			"correct_answers" : ["7"],
			"id" : 2
		},
		"Variabler" : {
			"dependency" : ["Aritmetik"],
			"text" : "I dette forløb skal du lære om variabler. Variabler er en fanstastisk funktion Maple har at byde på. En variable giver et tegn, bogstav eller andet symbol en givet værdi. Det kan bruges på et meget avanceret nieavue men også et helt simpelt nieavue.[br][br]De tre mest grundlæggende funktioner du skal bruge en variable er til defination af værdier, punkter og vektorer. Du definerer en variable ved at skrive [c]a:=5[/c], nu har du altså givet a værdien 5. Hvis du ikke tilføjer noget efter 5, så gengiver Maple værdien, men hvis du istdet skriver [c]a:=5:[/c] så gengiver Maple ikke værdien. Du kan nu burge a som en helt normal værdi i et matematik felt.[br][br]De to andre grundlæggende funktioner du kan bruge variabler til, er definering af punkter og vektorer. Et punkt givet ved P(5,2) kan defineres som [c]P:=[5,2][/c], altså med firkantede paranteser. En vektorgivet ved v=(2,8) defineres som [c]v:=<2,8>:[/c], altså større end, mindre end tegn. Hvis du arbejder i 3D, kan du nemt tilføje et z-koordinat efter y-koordinatet.[br][br]Du skal nu tildele to variabler værdier hvis sum giver 27.",
			"correct_answers" : ["27"],
			"id" : 3
		}
	},
	"Funktioner" : {
		
	},
	"Units" : {
		
	}
}

const API_URL = "http://139.59.130.153:3000"  
const API_KEY = "x-api-key: crazyVildAPIKEYIDevelopment!"
var headers = ["Content-Type: application/json", Gamestate.API_KEY]

# User data
var username = ""
var user_id = ""

var userChapterStates = {}

var last_scene = []
var scene_index = 0
# functions
func change_scene(scene):
	last_scene.append(get_tree().current_scene.scene_file_path)
	scene_index = last_scene.size()
	get_tree().change_scene_to_file(scene)


func go_back():
	scene_index = scene_index - 1
	get_tree().change_scene_to_file(last_scene[scene_index])

func clear_scene_history():
	last_scene = []
	scene_index = 0

func get_current_chapter():
	return chapters[menuChapter][curChapter]
