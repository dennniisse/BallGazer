classdef UR3 < handle
    %when accessing properties in the functions make sure to do self.<property>"
    properties
        manipulator;
        endEffector;
    end
    properties(Access = private)
        workspace = [-0.6 0.6 -0.6 0.6 0 0.8];
        steps = 50;
        baseUR3 = eye(4);
        
        %%%%%%%%%%%%%%%%%%% Move it function
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
        %% (Constructor)
        function self = UR3()
            pause(1);
            hold on;
            % Plot Robot
            self.GetUR3Robot();
            % Colour Robot
            self.PlotAndColourRobot();
            % Initialise animate delay to 0
            self.GetRacketEE();
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UR3 Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% GetUR3Robot
        function GetUR3Robot(self)
            disp('Creating UR3');
            pause(0.001);
            name = ['UR3',datestr(now,'yyyymmddTHHMMSSFFF')];
            % dh = [THETA D A ALPHA SIGMA OFFSET]
            L(1) = Link('d',0.1519,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            L(2) = Link('d',0,'a',-0.24365,'alpha',0,'qlim', deg2rad([-360 360]), 'offset',0);
            L(3) = Link('d',0,'a',-0.21325,'alpha',0,'qlim', deg2rad([-360 360]), 'offset', 0);
            L(4) = Link('d',0.11235,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            L(5) = Link('d',0.08535,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360,360]), 'offset',0);
            L(6) = Link('d',0.0819,'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset', 0);
            
            L(1).qlim = [-360 360]*pi/180;
            L(2).qlim = [-360 360]*pi/180;
            L(3).qlim = [-360 360]*pi/180;
            L(4).qlim = [-360 360]*pi/180;
            L(5).qlim = [-360 360]*pi/180;
            L(6).qlim = [-360 360]*pi/180;
            
            
            self.manipulator = SerialLink(L,'name',name);
            
             % Obtain 3D model of UR3
            for linkIndex = 1:self.manipulator.n
                [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['ur3_',num2str(linkIndex),'.ply'],'tri'); %#ok<AGROW>
                self.manipulator.faces{linkIndex + 1} = faceData;
                self.manipulator.points{linkIndex + 1} = vertexData;
            end
            
            % Plot UR3 as 3D
            q = zeros(1,6);
            self.manipulator.plot3d(q,'workspace',self.workspace);
            if isempty(findobj(get(gca,'Children'),'Type','Light'))
                camlight
            end
            % Colour UR3
            for linkIndex = 0:self.manipulator.n
                handles = findobj('Tag', self.manipulator.name); 
                h = get(handles,'UserData'); 
                try
                    h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ... 
                        , plyData{linkIndex+1}.vertex.green ...                                         
                        , plyData{linkIndex+1}.vertex.blue]/255;
                    h.link(linkIndex+1).Children.FaceColor = 'interp';
                catch ME_1
                    disp(ME_1);
                    continue;
                end
            end
        end

        %% Plot and Colour Racket
        function GetRacketEE(self)
            % Create links
            disp('Creating Racket');
            name = ['RacketEE',datestr(now,'yyyymmddTHHMMSSFFF')];
            L = Link('d', 0,'a', 0 ,'alpha', 0 , 'qlim', 0 , 'offset', 0 );
            self.endEffector = SerialLink(L,'name',name);
            % Find end effector base
            self.endEffector.base = self.manipulator.fkine(self.manipulator.getpos());
            
            % Plot and colour end effector
            for linkIndex = 1:self.endEffector.n
                [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['ur3_0.ply'],'tri'); %#ok<AGROW>
                self.endEffector.faces{linkIndex + 1} = faceData;
                self.endEffector.points{linkIndex + 1} = vertexData;
            end
            q = zeros(1,1);
            self.endEffector.plot3d(q,'workspace',self.workspace);
            handles = findobj('Tag', self.endEffector.name); 
            h = get(handles,'UserData'); 
            try
                h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ...
                    , plyData{linkIndex+1}.vertex.green ...                                         
                    , plyData{linkIndex+1}.vertex.blue]/255;
                h.link(linkIndex+1).Children.FaceColor = 'interp';
            catch ME_1
                disp(ME_1);
            end
        end
        %% PlotEnvironment
        function PlotEnvironment(self)
            disp('Plotting Environment');
            offset = -0.67; %adjusting the height of environment so UR3 is placed on top of the table
            [f,v,data] = plyread('Environment.ply','tri');
            vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            % Plot the environment, account for any changes in the UR3's base
            trisurf(f,v(:,1)+ self.baseUR3(1)...
                , v(:,2) + self.baseUR3(2)...
                , v(:,3) + offset + self.baseUR3(3)...
                ,'FaceVertexCData',vertexColours,'EdgeColor','interp','EdgeLighting','flat');
            
            hold on;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Move Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    end
end