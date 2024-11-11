extends Spatial


export var Selected : int

signal update_check

# Called when the node enters the scene tree for the first time.
func _ready():
	var checkQuantity = .get_child_count()
	for i in checkQuantity:
		get_child(i).connect("checkp_area_entered", self, "_checkpoint")


func _checkpoint():
	emit_signal("update_check")
	print("Selected")
