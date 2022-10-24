classdef ROS_UR3 < handle
    %ROS_UR3 Interface Class - Based on Instructions from Subject Resources
    %Version 1: Buggy but works 1 or 2 times
    %Useful Functions:
    % rosshutdown
    % jointStateSubscriber.receive
    % rostopic echo /joint_states
    % rostopic list
    % jointStateSubscriber.LatestMessage
    % jointStateSubscriber.LatestMessage.Position
    % rostopic 

    %Get latest message that was received (if any)
    % scanMsg = laserSub.LatestMessage;
    %Wait for next message to arrive (blocking)
    % scanMsg = receive(laserSub);
    % scanMsg = receive(jointStateSubscriber);


    properties (Constant)
    end
    
    properties (Access = public)  
    end
    
    methods
        function self = ROS_UR3()
            disp(['ROS_UR3.m: Just wait until August 29, 1997',IP]);
        end
        
    end
    methods (Static) %Static = Does not need object
        function currentJointState_123456 = CurrentJointState(jointStateSubscriber)
            disp('ROS: Asking for Current Joint States...');    
            try 
                currentJointState_321456 = (jointStateSubscriber.LatestMessage.Position)'; % Note the default order of the joints is 3,2,1,4,5,6
                currentJointState_123456 = [currentJointState_321456(3:-1:1),currentJointState_321456(4:6)];
%                 disp(['ROS: States are: ',num2str(rad2deg(currentJointState_123456)),' (Degrees)']); 
             catch
                 disp('ROS ERROR: Reading From Latest Message');
            end
        end

        function SendJointAngles(nextJointState_123456,durationSeconds,bufferSeconds,jointStateSubscriber)
            disp('ROS: Sending Joint States...');
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
            
            pause(2);
            
            goal.Trajectory.Header.Stamp = jointStateSubscriber.LatestMessage.Header.Stamp + rosduration(bufferSeconds);
            sendGoal(client,goal);  

            pause(2);
        end
        

              %Commented Out As jointStateSubscriber needs to be run in main
%         function connectionStatus = Initialise(IP)
%             if nargin < 1 
%                 IP = '192.168.0.253'; %Set default UTS IP
%             end
%                         
%             disp(['ROS: Connecting to ',IP,'...']);
%             try 
%                 rosinit(IP); % Assuming a UTS Pi, otherwise please change this
%                 jointStateSubscriber = rossubscriber('joint_states','sensor_msgs/JointState');
%                 connectionStatus = true;
%                 disp('ROS: Connected to UR3!');
%                 pause(2); % Pause to give time for a message to appear
%             catch
%                 disp('ROS: No Connection!');
%                 connectionStatus = false;
%             end
%             self.IP = IP;
%             self.connectionStatus = connectionStatus;
%             self.jointStateSubscriber = jointStateSubscriber;
%         end


        
    end
end



