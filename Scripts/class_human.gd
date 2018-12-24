extends KinematicBody2D

signal dead
signal healt_loss

export (int) var max_speed   = 400
export (int) var climb_speed = 400
export (int) var acc_speed   = 350
export (int) var gravity     = 50
export (int) var jump        = 1000
var vec_mov = Vector2()

var fl_flipped = false