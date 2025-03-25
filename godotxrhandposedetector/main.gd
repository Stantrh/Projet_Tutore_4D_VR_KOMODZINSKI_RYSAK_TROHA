extends Node3D

var ui1: bool = false
var ui2: bool = false
var ui3 : bool = false
var interface : XRInterface
# Called when the node enters the scene tree for the first time.
func _ready():
	WorldInfo.camera = $XROrigin3D/XRCamera3D


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
	if $HypercubeSS :
		if $HypercubeSS.child_instantiated:
			$HypercubeSS.child_instantied.is_rotate = true
			$HypercubeSS.child_instantied.is_double_rotate = true
	if $HypercubeOS :
		if $HypercubeOS.child_instantiated:
			$HypercubeOS.child_instantied.is_rotate = true
			$HypercubeOS.child_instantied.is_double_rotate = true
			$HypercubeOS.child_instantied.axe_a = 1
	if $HypercubePF:
		if $HypercubePF.child_instantiated:
			$HypercubePF.child_instantied.is_rotate = true
			$HypercubePF.child_instantied.is_double_rotate = true
			$HypercubePF.child_instantied.axe_a = 2
