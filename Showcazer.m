%% 41014 SPR2022 - Ball Gazers
%  Ashwin COBURN (12963690)
%  Denisse FERNANDEZ (13214489)
%  Hee CHAN-KWON (13006010)

close all
clf
clc
hold on;
% set(0,'DefaultFigureWindowStyle','docked');

%% Setup
%%Controller Class Variables
%Buttons
A = 1;
B = 2;
X = 3;
Y = 4;
BumperLeft = 5;
BumperRight = 6;
BACK = 7;
START = 8;
Joy_Click_Left = 9;
Joy_Click_Right = 10;
    
%Axis
%Deadzone is roughly 0.2 for axis
Joy_X_Axes_Left = 1; %-1 to 1
Joy_Y_Axes_Left = 2; %-1 to 1
Triggers = 3; % -0.996 to 0.996
Joy_X_Axes_Right = 4; %-1 to 1
Joy_Y_Axes_Right = 5; %-1 to 1
    
%Povs
DPad_UP = [0 360];
DPad_RIGHT = 90;
DPad_DOWN = 180;
DPad_LEFT = 270;

%%Movement Class Variables
jtraj = 1;
ctraj = 2;
TVP = 3;
steps_Arm_jtraj = 60;
steps_Arm_ctraj = 50;
steps_Arm_TVP = 50;
steps_Gripper_jtraj = 5;
steps_Controller = 10; %For experiments
animationPause = 0.02;
IRB120JointAnglesAmount = 6;
UR3JointAnglesAmount = 6;

%ROS Variables
jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};
connectionStatus = true; %SET TO FALSE WHEN IMPLEMENTING
IP = '192.168.0.253';


%Spawn Stuff
% disp('ENVIRONMENT SPAWNING...');
% PlaceObject("environment_SnC.ply",[0,0,0]);
%UR3_base_location = [0,0,0.9397];
UR3_base_location = [0,0,0];

%Restart ROS
try
rosshutdown;
catch
end

% % Initialise ROS
% disp(['ROS: Connecting to ',IP,'...']);
% rosinit(IP); % Assuming a UTS Pi, otherwise please change this
% jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
% 
% disp('ROS: Connected to UR3!');
% pause(2); % Pause to give time for a message to appear

%Spawn UR3
Jack = UR3(UR3_base_location); %Need to add starting pose option

%% SEND MOVEMENT COMMANDS HERE
%Set UR3 Joint Limits to Match Real UR3
q1 = Jack.model.getpos();
% q2 = ROS_UR3.CurrentJointState(jointStateSubscriber)
% q1 = Move.OneArm_q2(Jack,q1,q2,TVP,3,animationPause,false); %Steps set to 1

% T2 = transl(-0.4,-0.4, 1.5); %Remember base Z is 0.9
% T2 = transl(0.00,-0.45, 0.005)*trotx(pi);
T2 = transl(-0.225,0, 0.005)*trotx(pi);
%Move Virtual UR3 to Particular Transform
q2 = Move.OneArm_T2(Jack,q1,T2,TVP,100,animationPause);



%Move Real UR3 to Match
% bufferSeconds = 1;
% durationSeconds = 6;
% pause(2);

% q2 = deg2rad([0 -90 0 -90 0 0]);
% ROS_UR3.SendJointAngles(q2,durationSeconds,bufferSeconds,jointStateSubscriber);
% pause(6);
% q2 = deg2rad([10 -80 10 -80 10 10]);
% ROS_UR3.SendJointAngles(q2,durationSeconds,bufferSeconds,jointStateSubscriber);
% pause(6);
% q2 = deg2rad([20 -70 20 -70 -30 -30]);
% ROS_UR3.SendJointAngles(q2,durationSeconds,bufferSeconds,jointStateSubscriber);
% pause(6);

%% TEST

nextJointState_123456 = q2;


disp('ROS: Sending Joint States 1');
            %Joint Names
            jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};
            %Get Current Joint State
            currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
            currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];
            pause(2); % Pause to give time for a message to appear
            %Create Client & Goal for rosactionclient
            [client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
    
            %Set Goal
            goal.Trajectory.JointNames = jointNames;
            goal.Trajectory.Header.Seq = 1;
            goal.Trajectory.Header.Stamp = rostime('Now','system');
            goal.GoalTimeTolerance = rosduration(0.05);
            
            startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
            startJointSend.Positions = currentJointState_123456;
            startJointSend.TimeFromStart = rosduration(0);     
                  
            endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
            endJointSend.Positions = nextJointState_123456;
            endJointSend.TimeFromStart = rosduration(durationSeconds);
            
            goal.Trajectory.Points = [startJointSend; endJointSend];
            
%             pause(2);

            
            %Send Command
            goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
            sendGoal(client,goal);  

%             pause(20);
%% RESET

nextJointState_123456 = deg2rad([0 -90 0 -90 0 0]);
disp('ROS: Sending Joint States 2');
            %Joint Names
            jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};
            %Get Current Joint State
            currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
            currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];
            pause(2); % Pause to give time for a message to appear
            %Create Client & Goal for rosactionclient
            [client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
    
            %Set Goal
            goal.Trajectory.JointNames = jointNames;
            goal.Trajectory.Header.Seq = 1;
            goal.Trajectory.Header.Stamp = rostime('Now','system');
            goal.GoalTimeTolerance = rosduration(0.05);
            
            startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
            startJointSend.Positions = currentJointState_123456;
            startJointSend.TimeFromStart = rosduration(0);     
                  
            endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
            endJointSend.Positions = nextJointState_123456;
            endJointSend.TimeFromStart = rosduration(durationSeconds);
            
            goal.Trajectory.Points = [startJointSend; endJointSend];
            
%             pause(2);
            
            %Send Command
            goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
            sendGoal(client,goal);  

             %% 3
            nextJointState_123456 = deg2rad([20 -70 20 -70 -30 -30]);

           
% disp('ROS: Sending Joint States 3');
%             %Joint Names
%             jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};
%             %Get Current Joint State
%             currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
%             currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];
%             pause(2); % Pause to give time for a message to appear
%             %Create Client & Goal for rosactionclient
%             [client, goal] = rosactionclient('/scaled_pos_joint_traj_controller/follow_joint_trajectory');
%     
%             %Set Goal
%             goal.Trajectory.JointNames = jointNames;
%             goal.Trajectory.Header.Seq = 1;
%             goal.Trajectory.Header.Stamp = rostime('Now','system');
%             goal.GoalTimeTolerance = rosduration(0.05);
%             
%             startJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
%             startJointSend.Positions = currentJointState_123456;
%             startJointSend.TimeFromStart = rosduration(0);     
%                   
%             endJointSend = rosmessage('trajectory_msgs/JointTrajectoryPoint');
%             endJointSend.Positions = nextJointState_123456;
%             endJointSend.TimeFromStart = rosduration(durationSeconds);
%             
%             goal.Trajectory.Points = [startJointSend; endJointSend];
%             
% %             pause(2);
%             
%             %Send Command
%             goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
%             sendGoal(client,goal);  
% 
% 
