#main.gd Contents:
extends Node
 
const ID = "Catvalk.EmeraldCoastA" 
onready var Lure = get_node("/root/SulayreLure")
 
func _ready():
	  Lure.add_map(ID,"asdga", "mod://Scenes/EmeraldCoastA.tscn", "Emerald Coast A")
