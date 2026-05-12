extends CanvasLayer

onready var energyBar:TextureRect = $Control/EnergyBar
onready var mapCursor:AnimatedSprite = $Control/mapCursorSprite
onready var labelPieces:Label = $Control/LabelPieces
onready var cardSprite: Sprite = $Control/CardSprite
onready var terminalWindow:Node2D = $TerminalWindow
onready var terminalMessage:Sprite = $TerminalWindow/Message
onready var livesBar:TextureRect = $Control/LivesBar

const BAR_HEIGHT:int = 10

const ROOMS = {
	"StartScreen": Vector2(384,197),
	
	"Level-a-1": Vector2(370,197),
	"Level-a-2": Vector2(377,197),
	"Level-a-3": Vector2(384,197),
	"Level-a-4": Vector2(391,197),
	"Level-a-5": Vector2(398,197),
	
	"Level-b-1": Vector2(370,202),
	"Level-b-2": Vector2(377,202),
	"Level-b-3": Vector2(384,202),
	"Level-b-4": Vector2(391,202),
	"Level-b-5": Vector2(398,202),
	
	"Level-c-1": Vector2(370,207),
	"Level-c-2": Vector2(377,207),
	"Level-c-3": Vector2(384,207),
	"Level-c-4": Vector2(391,207),
	"Level-c-5": Vector2(398,207),
	
	"Level-d-1": Vector2(370,212),
	"Level-d-2": Vector2(377,212),
	"Level-d-3": Vector2(384,212),
	"Level-d-4": Vector2(391,212),
	"Level-d-5": Vector2(398,212),
	
	"Level-blue-room": Vector2(398,212),
	"Level-red-room": Vector2(398,207),
	"Level-green-room": Vector2(377,207),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.UI = self
	
	VisualServer.set_default_clear_color(Color(0.0,0.0,0.0,1.0))
	
	Global.connect("energy_taken", self, "_on_energy_taken")
	Global.connect("piece_taken", self, "_on_piece_taken")
	Global.connect("card_taken", self, "_on_card_taken")
	Global.connect("life_taken", self, "_on_life_taken")
	
	update_room_ui()
	update_pieces_ui()
	update_energybar_ui()
	update_lives_ui()
	update_card()
	
	terminalWindow.visible = false
	
	
func open_terminal(msg)->void:
	terminalWindow.visible = true
	terminalMessage.frame = msg - 1
	AudioManager.open_terminal()
	
func close_terminal()->void:
	terminalWindow.visible = false
	AudioManager.close_terminal()

func update_pieces_ui()->void:
	labelPieces.text = str(Global.repair_pieces_taken_array.size())
	
	
func update_energybar_ui()->void:
	energyBar.rect_size.y = BAR_HEIGHT * Global.batteries_charged
	
func update_lives_ui()->void:
	livesBar.rect_size.y = 12 * Global.lives

func update_room_ui()->void:
	var room = owner.name
	mapCursor.position = ROOMS[room]
	
func _on_energy_taken()->void:
	energyBar.rect_size.y = BAR_HEIGHT * Global.batteries_charged
	
func _on_life_taken()->void:
	livesBar.rect_size.y = 12 * Global.lives
	
func _on_piece_taken()->void:
	update_pieces_ui()
	
func update_card()->void:
	if Global.current_card == "none":
		cardSprite.frame = 0
	elif Global.current_card == "green":
		cardSprite.frame = 1
	elif Global.current_card == "red":
		cardSprite.frame = 2
	elif Global.current_card == "blue":
		cardSprite.frame = 3
	
	
func _on_card_taken()->void:
		update_card()
#


