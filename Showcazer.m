%% 41014 SPR2022 - Ball Gazers
%  Ashwin COBURN (12963690)
%  Denisse FERNANDEZ (13214489)
%  Hee CHAN-KWON (xxxxxxxx)

close all
clf
clc
hold on;
% set(0,'DefaultFigureWindowStyle','docked');

disp('ENVIRONMENT SPAWNING...');
PlaceObject("enviornment_SnC.ply",[0,0,0]);
% disp('ENVIRONMENT SPAWNING...');
test = UR3([0,0,0.9397]);

