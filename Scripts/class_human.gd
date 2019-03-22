extends KinematicBody2D

signal dead
signal healt_loss

var max_speed   = 400
var climb_speed = 250
var acc_speed   = 1000
var gravity     = 50
var jump        = 600
var vec_mov = Vector2()

var fl_flipped = false