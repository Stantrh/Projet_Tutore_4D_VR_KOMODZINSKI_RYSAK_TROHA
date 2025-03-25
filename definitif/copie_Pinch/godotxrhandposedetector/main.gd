extends Node3D

var ui1: bool = false
var ui2: bool = false
var ui3 : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	WorldInfo.camera = $XROrigin3D/XRCamera3D
	#$CanvasLayerViewport.object_controlled = $HypercubeOS.get_children()[1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $HypercubeR1P1 :
		if $HypercubeR1P1.child_instantiated:
			$HypercubeR1P1.child_instantied.is_rotate = true
	if $HypercubeR1P2 :
		if $HypercubeR1P2.child_instantiated:
			$HypercubeR1P2.child_instantied.is_rotate = true
			$HypercubeR1P2.child_instantied.axe_a = 1
	if $HypercubeR1P3:
		if $HypercubeR1P3.child_instantiated:
			$HypercubeR1P3.child_instantied.is_rotate = true
			$HypercubeR1P3.child_instantied.axe_a = 2
	if $HypercubeR2P1:
		if $HypercubeR2P1.child_instantiated:
			$HypercubeR2P1.child_instantied.is_rotate = true
			$HypercubeR2P1.child_instantied.is_double_rotate = true
	if $HypercubeR2P2 :
		if $HypercubeR2P2.child_instantiated:
			$HypercubeR2P2.child_instantied.is_rotate = true
			$HypercubeR2P2.child_instantied.is_double_rotate = true
			$HypercubeR2P2.child_instantied.axe_a = 1
	if $HypercubeR2P3:
		if $HypercubeR2P3.child_instantiated:
			$HypercubeR2P3.child_instantied.is_rotate = true
			$HypercubeR2P3.child_instantied.is_double_rotate = true
			$HypercubeR2P3.child_instantied.axe_a = 2
