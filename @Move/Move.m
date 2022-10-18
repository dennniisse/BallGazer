%%  Movement Class (Version 4.0)
%   Control one or two arms and their end effectors, anything that moves

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

        %> workspace
        workspace = [-0.6 0.6 -0.6 0.6 -0.2 1.1];   
        
    end
    
    methods
        function self = Move()       
        disp('Move.m: I like to move it move it!');
        disp('Move.m: Use my functions!');
        end
    end
    
    methods (Static)
        %% Move One Arm and EE [T2]
        %Moves the arm to a position, brings gripper with it
        function qMatrixFinal_Arm1 = OneArmAndEE_T2(model_Arm1,model_EE1,q1_Arm1,T2_Arm1,interpMethod_Arm1,steps_Arm1,animationPause)
            
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
        
        %% Move One Arm [T2]
        %Moves the arm to a position, no gripper robot attached
        function qMatrixFinal_Arm1 = OneArm_T2(model_Arm1,q1_Arm1,T2_Arm1,interpMethod_Arm1,steps_Arm1,animationPause)
            
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
                model_Arm1.model.animate(qMatrixArm1(i,:)); %Animate Arm1
                pause(animationPause);
            end

            qMatrixFinal_Arm1 = qMatrixArm1(steps_Arm1,:); %Remember Last Q
            
            disp('Complete!');
        end
        
        %% Move One Arm [q2]
        %Moves the arm to a position, no gripper robot attached
        function qMatrixFinal_Arm1 = OneArm_q2(model_Arm1,q1_Arm1,q2_Arm1,interpMethod_Arm1,steps_Arm1,animationPause,considerJointAngles)
            
            if considerJointAngles == true
                T1_Arm1 = model_Arm1.model.fkine(q1_Arm1);        
                T2_Arm1 = model_Arm1.model.fkine(q2_Arm1);
                q2_Arm1 = model_Arm1.model.ikcon(T2_Arm1,q1_Arm1); %Consider joint limits and initial joint angles
            else
                T1_Arm1 = model_Arm1.model.fkine(q1_Arm1);
                T2_Arm1 = model_Arm1.model.fkine(q2_Arm1);
            end

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
                model_Arm1.model.animate(qMatrixArm1(i,:)); %Animate Arm1
                pause(animationPause);
            end

            qMatrixFinal_Arm1 = qMatrixArm1(steps_Arm1,:); %Remember Last Q
            
            disp('Complete!');
        end
        
        %% Move One Arm [CONTROLLER]
        %Moves the arm to a position, no gripper robot attached
        function qMatrixFinal_Arm1 = OneArm_CONTROLLER(model_Arm1,q1_Arm1,interpMethod_Arm1,steps_Arm1,animationPause,axes,buttons,povs)
            
            %Copy Joint Angles
            q2_Arm1 = q1_Arm1;
            
            %Save Joint Limits
            qlimits = model_Arm1.model.qlim;
            
            %Controller Parameters
            B = 2;
            Joy_X_Axes_Left = 1; %-1 to 1
            Joy_Y_Axes_Left = 2; %-1 to 1
            Triggers = 3; % -0.996 to 0.996
            Joy_X_Axes_Right = 4; %-1 to 1
            Joy_Y_Axes_Right = 5; %-1 to 1
            Axes_Deadzone = 0.24; %Default 0.15 to 0.20
            Triggers_Deadzone = 0.1; %Unknown Default
            Joint_Movement_Amount = deg2rad(10); %3 is ok
            
            %RIGHT JOYSTICK: 
            %   X: Rotate Around Base (Joint 1)
            %   Y: Rotate Up/Down (Joint 2)
            if axes(Joy_X_Axes_Right)>= Axes_Deadzone
%                 disp('CW+');
                if q2_Arm1(1) + (axes(Joy_X_Axes_Right)/1)*Joint_Movement_Amount > qlimits(1,2)
                    disp('Joint 1 Limit Reached!');
                else
                    q2_Arm1(1) = q2_Arm1(1) + (axes(Joy_X_Axes_Right)/1)*Joint_Movement_Amount;
                end
            elseif axes(Joy_X_Axes_Right)<= -Axes_Deadzone
%                 disp('CCW-');
                if (q2_Arm1(1) + (axes(Joy_X_Axes_Right)/1)*Joint_Movement_Amount) < qlimits(1,1)
                    disp('Joint 1 Limit Reached!');
                else
                    q2_Arm1(1) = q2_Arm1(1) + (axes(Joy_X_Axes_Right)/1)*Joint_Movement_Amount;
                end         
            end
            if axes(Joy_Y_Axes_Right)>= Axes_Deadzone
%                 disp('Y+');
                if q2_Arm1(2) - (axes(Joy_Y_Axes_Right)/1)*Joint_Movement_Amount < qlimits(2,2)
                    disp('Joint 2 Limit Reached!');
                else
                    q2_Arm1(2) = q2_Arm1(2) - (axes(Joy_Y_Axes_Right)/1)*Joint_Movement_Amount;
                end
            elseif axes(Joy_Y_Axes_Right)<= -Axes_Deadzone
%                 disp('Y-');
                if q2_Arm1(2) - (axes(Joy_Y_Axes_Right)/1)*Joint_Movement_Amount > qlimits(2,1)
                    disp('Joint 2 Limit Reached!');
                else
                    q2_Arm1(2) = q2_Arm1(2) - (axes(Joy_Y_Axes_Right)/1)*Joint_Movement_Amount;
                end
            end
            
              %TRIGGERS: 
              %     L/R: Rotate Up/Down (Joint 3)
            if axes(Triggers)>= Triggers_Deadzone
%                 disp('Z-');
                if q2_Arm1(3) + (axes(Triggers)/1)*Joint_Movement_Amount > qlimits(3,2)
                    disp('Joint 3 Limit Reached!');
                else
                    q2_Arm1(3) = q2_Arm1(3) + (axes(Triggers)/1)*Joint_Movement_Amount;
                end
            elseif axes(Triggers)<= -Triggers_Deadzone
%                 disp('Z+');
                if q2_Arm1(3) + (axes(Triggers)/1)*Joint_Movement_Amount < qlimits(3,1)
                    disp('Joint 3 Limit Reached!');
                else
                    q2_Arm1(3) = q2_Arm1(3) + (axes(Triggers)/1)*Joint_Movement_Amount;
                end
            end
            
            %LEFT JOYSTICK: Rotate End Effector
            %   X: Rotate EE CW/CCW (Joint 4)
            %   Y: Rotate EE Up/Down (Joint 5)
            if axes(Joy_X_Axes_Left)>= Axes_Deadzone
%                 disp('R+');
                if q2_Arm1(4) - (axes(Joy_X_Axes_Left)/1)*Joint_Movement_Amount < qlimits(4,2)
                    disp('Joint 4 Limit Reached!');
                else
                    q2_Arm1(4) = q2_Arm1(4) - (axes(Joy_X_Axes_Left)/1)*Joint_Movement_Amount;
                end
            elseif axes(Joy_X_Axes_Left)<= -Axes_Deadzone
%                 disp('R-');
                if q2_Arm1(4) - (axes(Joy_X_Axes_Left)/1)*Joint_Movement_Amount > qlimits(4,1)
                    disp('Joint 4 Limit Reached!');
                else
                    q2_Arm1(4) = q2_Arm1(4) - (axes(Joy_X_Axes_Left)/1)*Joint_Movement_Amount;
                end
            end
            if axes(Joy_Y_Axes_Left)>= Axes_Deadzone
%                 disp('Y+');
                if q2_Arm1(5) + (axes(Joy_Y_Axes_Left)/1)*Joint_Movement_Amount > qlimits(5,2)
                    disp('Joint 5 Limit Reached!');
                else
                    q2_Arm1(5) = q2_Arm1(5) + (axes(Joy_Y_Axes_Left)/1)*Joint_Movement_Amount;
                end
                
            elseif axes(Joy_Y_Axes_Left)<= -Axes_Deadzone
%                 disp('Y-');
                if q2_Arm1(5) + (axes(Joy_Y_Axes_Left)/1)*Joint_Movement_Amount < qlimits(5,1)
                    disp('Joint 5 Limit Reached!');
                else
                    q2_Arm1(5) = q2_Arm1(5) + (axes(Joy_Y_Axes_Left)/1)*Joint_Movement_Amount;
                end
            end
            disp(['q2:', num2str(rad2deg(q2_Arm1))]);
            
            %Clear Selection and Reset Joint Angles
            if buttons(B) == 1
                disp('B: RESET Activated!');
                q2_Arm1 = zeros([1 numel(q1_Arm1)]);
                T2_Arm1 = model_Arm1.model.fkine(q2_Arm1);
                animationPause = 0.01;
                steps_Arm1 = 80;
            end
            
            %%Find Current Transform (Experimental not recommended)
            T1_Arm1 = model_Arm1.model.fkine(q1_Arm1);
            T2_Arm1 = model_Arm1.model.fkine(q2_Arm1);
            
            %Extract and Note Movement Information
%             disp('Current Movement (m/degrees):');
%             Arm1_Rotations1 = tr2rpy(T1_Arm1,'deg');
%             Arm1_Rotations2 = tr2rpy(T2_Arm1,'deg');
%             disp(['Roll = ', num2str(Arm1_Rotations1(1) - Arm1_Rotations2(1))]);
%             disp(['Pitch = ', num2str(Arm1_Rotations1(2) - Arm1_Rotations2(2))]);
%             disp(['Yaw = ', num2str(Arm1_Rotations1(3) - Arm1_Rotations2(3))]);
%             disp(['X = ', num2str(T1_Arm1(1,4) - T2_Arm1(1,4))]);
%             disp(['Y = ', num2str(T1_Arm1(2,4) - T2_Arm1(2,4))]);
%             disp(['Z = ', num2str(T1_Arm1(3,4) - T2_Arm1(3,4))]);          

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
%             disp('Moving Arm...');
            for i = 1:1:steps_Arm1
                model_Arm1.model.animate(qMatrixArm1(i,:)); %Animate Arm1
                pause(animationPause);
                pause(2);
            end

            qMatrixFinal_Arm1 = qMatrixArm1(steps_Arm1,:); %Remember Last Q
            
%             disp('Complete!');
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
