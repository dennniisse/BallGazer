close all; clf; clc; clear;
base = eye(4);
PlaceObject("environment_SnC.ply",[-0.4 -0.4 1.5]);
ur3 = UR3(base);
move = Move();
q1 = ur3.model.getpos;
T2 = transl([-0.4 -0.4 1.5])*trotx(pi/2)*trotz(pi/2);
move.OneArm_T2(ur3,q1,T2,2,50,0);