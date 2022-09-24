%% Still in development!
%Version 2.1
%To add optional inputs see https://au.mathworks.com/help/matlab/ref/inputparser.html

%%  Movement Class
%   Control one or two arms simultaneously and their end effectors
%   e.g.- Input Robot Arm, initial joint angles and final transform

classdef Move < handle
    properties
        %>Robot Models
        model_Arm1; model_EE1; model_Arm2; model_EE2;
        
        %>Gripper Mode ['Open' 'Close' 'Ignore']
        expectedgripmode = {'Open','Close','Ignore'};
        gripModeEE1 = 'Ignore'; gripModeEE2 = 'Ignore'; %default

        %>Initial Joint Angles
        q1_Arm1; q1_Arm2;

        %>Final Transform
        T2_Arm1; T2_Arm2;

        %Interpolation Method ['jtraj','ctraj','TVP']
        expectedInterp = {'jtraj','ctraj','TVP'};
        interpMethod_Arm1 = 'ctraj'; %default
        interpMethod_EE1 = 'ctraj'; 
        interpMethod_Arm2 = 'ctraj'; 
        interpMethod_EE2 = 'ctraj';

        %>Animation Steps
        steps_Arm1; steps_EE1; steps_Arm2; steps_EE2;

        %>Animation Pause
        pause_Arm1; pause_EE1; pause_Arm2; pause_EE2;

        %>Final Joint Values (For After)
        qMatrixFinal_Arm1;
        qMatrixFinal_EE1;
        qMatrixFinal_Arm2;
        qMatrixFinal_EE2;

        %>Decision Variables
        oneOrTwo = 1; %One or two arms loaded?
        isthere_EE1 = false; %move End Effector for Arm 1
        isthere_Arm2 = false; %move End Effector for Arm 1
        isthere_EE2 = false; %move End Effector for Arm 1

        %> workspace
        workspace = [-0.6 0.6 -0.6 0.6 -0.2 1.1];   
        
    end
    
    methods%% Class for UR3 robot simulation
        function self = Move(model_Arm1,q1_Arm1,T2_Arm1,varargin)       
            %%Input Parser
            p = inputParser;

            %Arm 1 Inputs
            addRequired(p,'model_Arm1',model_Arm1);
            addRequired(p,'q1_Arm1',q1_Arm1);
            addRequired(p,'T2_Arm1',T2_Arm1);
            addParameter(p,'interpMethod_Arm1',interpMethod_Arm1,...
                 @(x) any(validatestring(x,expectedinterpMethod)));
            
            %End Effector 1 Inputs
            addParameter(p,'model_EE1',model_Arm2);
            addParameter(p,'q1_EE1',model_Arm2);
            addParameter(p,'T2_EE1',model_Arm2);
            addParameter(p,'gripModeEE1',gripModeEE1,...
                 @(x) any(validatestring(x,expectedgripmode)));

            %Parse the information through
            parse(model_Arm1,q1_Arm1,T2_Arm1,varargin{:});
            
            %%Decision Making for Movement Function
            %Check if End Effector 1 Exists
            if exist('model_EE1','class') == 1 
                isthere_EE1 = true; 
            end
            
            MoveOneArm(self,model_Arm1,model_EE1,gripMode_EE1,q1_EE1,q1_Arm1,T2_Arm2,steps_Arm1,interpMethod_Arm1,Pause_Arm1,Pause_EE1);
        end
        
        function [qMatrixArm(steps,:),qMatrixEE(steps,:)] = MoveOneArm(self,robotArm,robotEE,gripMode,qEE1,q1,T2,steps,interpMethod,armPause,eePause)
        
            T1 = robotArm.model.fkine(q1Arm);        
            q2 = robotArm.model.ikcon(T2,q1); %Consider joint limits and initial joint angles
            
            if interpMethod == 'jtraq'
                qMatrixArm = jtraj(q1,q2,correction_steps); %jtraj
            elseif interpMethod == 'ctraq'
                trajectory = ctraj(T1,T2,c_movement_steps); %ctraj pt1
                qMatrixArm = dumE.model.ikcon(trajectory); %ctraj pt2
            elseif interpMethod == 'TVP'
                qMatrixArm = self.TVP(q1,q2,c_movement_steps); %TVP
            end
            
            %Plot & Update Robots
            for i = 1:1:steps
                location_EE = robotArm.model.fkine(qMatrixArm(i,:)); %Get new EE location
                robotEE.base = robotArm.model.ikcon(location_EE); %Apply new EE location
                if
                robotArm.model.animate(qMatrixArm(i,:)); %Animate both
                robotArm.model.animate(qMatrixArm(i,:));
                robotArm.model.animate(qMatrixArm(i,:));
                robotArm.model.animate(qMatrixArm(i,:));
        
                pause(animation_pause);
                end
            disp('Complete!');
            end
        end
        
        %% Trapezoidal Velocity Profile Function 
        %Input: (q1,q2,steps)
        %Output: qMatrix
        function qFunctionMatrix = TVP(self,q_a,q_b,steps_function)
            s = lspb(0,1,steps_function); % First, create the scalar function
            qFunctionMatrix = nan(steps_function,7); % Create memory allocation for variables
                 for i = 1:1:steps_function
                     qFunctionMatrix(i,:) = (1-s(i))*q_a + s(i)*q_b;    % Generate interpolated joint angles
                 end
        end       
    end
end
