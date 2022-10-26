%% 41014 SPR2022 - Ball Gazers
%  Ashwin COBURN (12963690)
%  Denisse FERNANDEZ (13214489)
%  HeeChan KWON (13006010)

close all
clf
clc
hold on;
% set(0,'DefaultFigureWindowStyle','docked');

%% Set Ball Locations & Enable ROS Here
enableROS = false;
overrideLocations = false; % comment false to use camera location, comment true to use preset location
redBallLocation = [0.35, 0.2, 1.125];
blueBallLocation = [0.35, -0.2, 1.125];

%% Run camera class and obtain the data of the environment
% Initialise camera functions
camera = CameraClass(); % create camera object, will record location of selected colour
hold off; 
figure(); hold on;
%% Variablesfigure(5); hold on; axis equal;

UR3_base_location = [0,0,1];
hold on; axis equal; axis on;
%ROS Variables
jointNames = {'shoulder_pan_joint','shoulder_lift_joint', 'elbow_joint', 'wrist_1_joint', 'wrist_2_joint', 'wrist_3_joint'};
IP = '192.168.0.253';
bufferSeconds = 1; %These will change
durationSeconds = 3; %These will change

%Movement Class Variables
jtraj = 1;
ctraj = 2;
TVP = 3;
steps_Arm_UR3 = 100;
animationPause = 0.01;

%Other Ball Variables
red = 1;
blue = 0;
ballChosen = red;
xOffset = -0.7;

%% Initialise ROS: if ROSinit for camera is runnning, shut it down, data is already recorded in the object class
if enableROS == true
    rosshutdown;
    disp(['ROS: Connecting to ',IP,'...']);
    try
        rosinit(IP); % Assuming a UTS Pi, otherwise please change this
        disp('ROS: Connected to UR3!');
        jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
        pause(2); % Pause to give time for a message to appear
    catch
        disp('ROS: No Connection! Please Try Again...');
        enableROS = false;
        pause;
    end
else
    jointStateSubscriber = 0;
end

%% Spawn Everything
hold on;
disp('Environment Spawning...');
PlaceObject("environment_SnC.ply",[0,0,0]);
disp('Complete!');
disp('Balls Spawning...');
redball_h = PlaceObject("Red_Ball.ply", redBallLocation);
blueball_h = PlaceObject("Blue_Ball.ply", blueBallLocation);
disp('Complete...');
Paddler = UR3(UR3_base_location);
%Set MATLAB UR3 to match Real UR3
if enableROS == true
    q1_UR3 = Paddler.model.getpos();
    q2_UR3 = ROS_UR3.CurrentJointState(jointStateSubscriber);
    q1_UR3 = Move.OneArm_q2(Paddler,q1_UR3,q2_UR3,TVP,2,animationPause,false,false,durationSeconds,bufferSeconds); %Steps set low on purpose
else
    q1_UR3 = Paddler.model.getpos();
end

%% Run
taskFinished = false;
while taskFinished == false
    ballChosen = camera.getColour;
    
    %     %%GUI Selection
    %     opts.Interpreter = 'tex';
    %     % Include the desired Default answer
    %     opts.Default = 'Red';
    %     % Use the TeX interpreter to format the question
    %     quest = 'Select Task or Target';
    %     answer = questdlg(quest, '41013 AS1', 'Red','Blue','Finish', opts);
    %
    %     switch answer
    %         case 'Blue'
    %             ballChosen = blue;
    %             disp('Ball Chosen: Blue');
    %         case 'Red'
    %             ballChosen = red;
    %             disp('Ball Chosen: Red');
    %         case 'Finish'
    %             taskFinished = true;
    %     end
    if taskFinished == false
        %% Get XYZ location of ball from realsense camera
        if overrideLocations == true % override Locations from camera class with preset values
            if ballChosen == blue
                ballLocation = transl(blueBallLocation);
            else %ballChosen == red
                ballLocation = transl(redBallLocation);
            end
        else % using camera class upload into world
            ballLocation = camera.GetLocation();
            ballLocation = transl([ballLocation(1) ballLocation(2) ballLocation(3)]);
            switch ballChosen
                case 1 % RED
                    delete(redball_h); hold on;
                    redball_h = PlaceObject("Red_Ball.ply", ballLocation(1:3,4)');
                case 3 %'BLUE'
                    delete(blueball_h); hold on;
                    blueball_h = PlaceObject("Blue_Ball.ply", ballLocation(1:3,4)');
            end
        end
        
        %% (2 Movements) Prepare and move the UR3 to Waypoint 1
        if ballLocation(2,4) >= 0
            q2_UR3 = [deg2rad(-178) deg2rad(-90) 0 deg2rad(-90) 0 0];
            q1_UR3 = Move.OneArm_q2(Paddler,q1_UR3,q2_UR3,TVP,steps_Arm_UR3,animationPause,false,enableROS,durationSeconds,bufferSeconds,jointStateSubscriber);
            T2_UR3 = transl(UR3_base_location(1) + 0.4,...     %X
                UR3_base_location(2) + 0.20,... %Y
                UR3_base_location(3) + 0.3) ... %Z
                *trotx(pi/2)*troty(pi/2);
        else
            q2_UR3 = [-1 deg2rad(-90) 0 deg2rad(-90) 0 0];
            q1_UR3 = Move.OneArm_q2(Paddler,q1_UR3,q2_UR3,TVP,steps_Arm_UR3,animationPause,false,enableROS,durationSeconds,bufferSeconds,jointStateSubscriber);
            T2_UR3 = transl(UR3_base_location(1) + 0.4,...     %X
                UR3_base_location(2) - 0.20,... %Y
                UR3_base_location(3) + 0.3) ... %Z
                *trotx(pi/2)*troty(pi/2);
        end
        q1_UR3 = Move.OneArm_T2(Paddler,q1_UR3,T2_UR3,TVP,steps_Arm_UR3,animationPause,enableROS,durationSeconds,bufferSeconds,jointStateSubscriber);
        
        %IR Waypoint: T2 = transl(-0.225,0, 0.005)*trotx(pi);
        %% Move the UR3 to next to Ball Location
        T2_UR3 = ballLocation*trotx(pi/2)*troty(deg2rad(30));
        % Y Offset
        %         T2_UR3 = T2_UR3 * transl(xOffset,0,0);
        
        q1_UR3 = Move.OneArm_T2(Paddler,q1_UR3,T2_UR3,TVP,steps_Arm_UR3,animationPause,enableROS,durationSeconds,bufferSeconds,jointStateSubscriber);
        
        %% Turn the UR3 Racket to Hit the Ball
        T2_UR3 = T2_UR3 * troty(deg2rad(90));
        
        q1_UR3 = Move.OneArm_T2(Paddler,q1_UR3,T2_UR3,TVP,steps_Arm_UR3,animationPause,enableROS,durationSeconds,bufferSeconds,jointStateSubscriber);
        
        %% Move the UR3 Back to Waypoint 1
        if ballLocation(2,4) >= 0
            T2_UR3 = transl(UR3_base_location(1) + 0.4,...     %X
                UR3_base_location(2) + 0.20,... %Y
                UR3_base_location(3) + 0.3) ... %Z
                *trotx(pi/2)*troty(pi/2);
        else
            T2_UR3 = transl(UR3_base_location(1) + 0.4,...     %X
                UR3_base_location(2) - 0.20,... %Y
                UR3_base_location(3) + 0.3) ... %Z
                *trotx(pi/2)*troty(pi/2);
        end
        
        q1_UR3 = Move.OneArm_T2(Paddler,q1_UR3,T2_UR3,TVP,steps_Arm_UR3,animationPause,enableROS,durationSeconds,bufferSeconds,jointStateSubscriber);
        %IR Waypoint: T2 = transl(-0.225,0, 0.005)*trotx(pi);
    end
    
        
    
        %%GUI Selection
    opts.Interpreter = 'tex';
    % Include the desired Default answer
    opts.Default = 'Reselect';
    % Use the TeX interpreter to format the question
    quest = 'Select Task or Target';
    answer = questdlg(quest, '41013 AS1', 'Reselect','Finish', opts);

    switch answer
        case 'Reselect'    
            camera.RecalculateLocation();
            ballChosen = camera.getColour;
        case 'Finish'
            taskFinished = true;
    end
    
end

%% Move the UR3 back to Starting Pose
q2_UR3 = [0 deg2rad(-90) 0 deg2rad(-90) 0 0];
q1_UR3 = Move.OneArm_q2(Paddler,q1_UR3,q2_UR3,TVP,steps_Arm_UR3,animationPause,false,enableROS,durationSeconds,bufferSeconds,jointStateSubscriber);