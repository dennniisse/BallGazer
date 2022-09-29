%% Still in development!
%Only has Support for One Arm
%TVP NOT working
%Input Parser Removed

%Version 3.0

%%  Movement Class
%   Control one or two arms simultaneously and their end effectors
%   e.g.- Input Robot Arm, initial joint angles and final transform

classdef Move < handle
    properties (Constant)
        
%         jtraj = 1;
%         ctraj = 2;
%         TVP = 3;
    
    end
    
    properties %Also set defaults
        %>Robot Models
        model_Arm1; model_EE1; model_Arm2; model_EE2;
        
        %>Gripper Mode ['Open' 'Close' 'Ignore']
%         expectedgripmode = {'Open','Close','Ignore'};
        gripModeEE1 = 'Ignore'; gripModeEE2 = 'Ignore'; %default

        %>Initial Joint Angles
        q1_Arm1; q1_Arm2;

        %>Final Transform
        T2_Arm1; T2_Arm2;

        %>Interpolation Method ['jtraj','ctraj','TVP']
%         expectedInterp = {'jtraj','ctraj','TVP'};
        interpMethod_Arm1 = 'ctraj'; %default
        interpMethod_EE1 = 'ctraj'; 
        interpMethod_Arm2 = 'ctraj'; 
        interpMethod_EE2 = 'ctraj';

%         %>Animation Steps
        steps_Arm1=100; steps_EE1=100; steps_Arm2=100; steps_EE2=100;
% 
%         %>Animation Pause
        animationPause = 0.02;

        %>Final Joint Values Storage (For Next Movement)
        qMatrixFinal_Arm1 = 0;
        qMatrixFinal_EE1 = 0;
        qMatrixFinal_Arm2 = 0;
        qMatrixFinal_EE2 = 0;

        %>Decision Variables
        isthere_EE1 = false; %move End Effector for Arm 1
        isthere_Arm2 = false; %move Arm 2
        isthere_EE2 = false; %move End Effector for Arm 2

        %> workspace
        workspace = [-0.6 0.6 -0.6 0.6 -0.2 1.1];   
        
    end
    
    methods
        function self = Move()       
        disp('I like to move it move it');
        end
    end
    
    methods (Static)
        %% Move One Arm and EE
        %Moves the arm to a position, brings gripper with it
        function qMatrixFinal_Arm1 = OneArmT2(model_Arm1,model_EE1,q1_Arm1,T2_Arm1,interpMethod_Arm1,steps_Arm1,animationPause)
            
            T1_Arm1 = model_Arm1.model.fkine(q1_Arm1);        
            q2_Arm1 = model_Arm1.model.ikcon(T2_Arm1,q1_Arm1); %Consider joint limits and initial joint angles

            if interpMethod_Arm1 == 1
                qMatrixArm1 = jtraj(q1_Arm1,q2_Arm1,steps_Arm1); %jtraj
            elseif interpMethod_Arm1 == 2
                trajectory = ctraj(T1_Arm1,T2_Arm1,steps_Arm1); %ctraj pt1
                qMatrixArm1 = model_Arm1.model.ikcon(trajectory,q1_Arm1); %ctraj pt2
            elseif interpMethod_Arm1 == 3
                qMatrixArm1 = TVP(q1_Arm1,q2_Arm1,steps_Arm1); %TVP
            else
                disp('Invalid interpMethod!');
            end
            
            %Plot & Update Robots
            disp('Moving Arm...');
            for i = 1:1:steps_Arm1
                EE_pos = qMatrixArm1(i,:);
                model_Arm1.model.animate(qMatrixArm1(i,:)); %Animate Arm1
                model_EE1.update_gripper(model_Arm1.model.fkine(EE_pos)); %Update and Animate EE1
                pause(animationPause);
            end

            qMatrixFinal_Arm1 = qMatrixArm1(steps_Arm1,:); %Remember Last Q
            
            disp('Complete!');
        end
        
%         %% Return Current Joint Angles Function
%         function [qMatrixFinal_Arm1,qMatrixFinal_EE1,qMatrixFinal_Arm2,qMatrixFinal_EE2] = ReturnCurrentJointAngles()
%             
%             disp(num2str(self.qMatrixFinal_Arm1));
%             [qMatrixFinal_Arm1,qMatrixFinal_EE1,qMatrixFinal_Arm2,qMatrixFinal_EE2] = [self.qMatrixFinal_Arm1,self.qMatrixFinal_EE1,self.qMatrixFinal_Arm2,self.qMatrixFinal_EE2];
%         
%         end
    end
   
end
