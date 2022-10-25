close all; clf; clc; clear;
base = eye(4);
ball = PlaceObject("Red_Ball.ply",[0 -0.35 1.3]);
PlaceObject("environment_SnC.ply",[0,0,0]);
ur3 = UR3(base);
move = Move();
q1 = ur3.model.getpos;
gripperOffset = 0.2;
T2 = transl([0 -0.20 1.1])%*trotx(pi/2)*trotz(pi/2); -0.05 -0.02
move.OneArm_T2(ur3,q1,T2,2,50,0);