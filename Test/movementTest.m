close all; clf; clc; clear;
base = eye(4);
PlaceObject("Red_Ball.ply",[0 -0.3 1.5]);
ur3 = UR3(base);
move = Move();
q1 = ur3.model.getpos;
gripperOffset = 0.2;
T2 = transl([0 -0.25 1.3])%*trotx(pi/2)*trotz(pi/2);
move.OneArm_T2(ur3,q1,T2,2,50,0);