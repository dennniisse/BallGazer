%% 41014 SPR2022 - Ball Gazers
%  Ashwin COBURN (12963690)
%  Denisse FERNANDEZ (13214489)
%  HeeChan KWON (13006010)

close all
clf
clc
hold on;
% set(0,'DefaultFigureWindowStyle','docked');

disp('ENVIRONMENT SPAWNING...');
PlaceObject("environment_SnC.ply",[0,0,0]);
% disp('ENVIRONMENT SPAWNING...');
test = UR3([0,0,0.9397]);
% PlaceObject("Red_Ball.ply", [0.15 -0.4 0.9267]);
% PlaceObject("Blue_Ball.ply", [-0.15 -0.4 0.9267]);
PlaceObject("Red_Ball.ply", [-0.25 -1 0.9267]);
PlaceObject("Blue_Ball.ply", [-0.25 -1.05 0.9267]);

ball.uploadCorrectColour(s.getColour)

test.model.teach();