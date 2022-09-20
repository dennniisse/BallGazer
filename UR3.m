classdef UR3 < handle
    %when accessing properties in the functions make sure to do
    %"self.<property>"
    properties
        model
        environment = false; %toggle
        stepRads %CalculateAndPlotWorkspace, input value: radians to iterate through
        robotBase = eye(4);
    end
    properties(Access = private)
        workspace = [-0.6 0.6 -0.6 0.6 0 0.8];
        baseUR3 = zeros(1,3); %user input, used to update model.base locations
        endEffectorBase = eye(4); %location of endEffectorBase
        gripper;
        % brick variables
        brickLocation = zeros(9,3);
        wallLocation = zeros(9,3);
        bric;
        maximumReach;
        volume
        steps = 50;
        
    end
    
    methods
        %% (Constructor)
        function self = BonusQUR3()
            pause(1);
            self.baseUR3 = self.robotBase(1:3,4)'; 
            hold on;
            % Plot Robot
            self.GetUR3Robot();
            % Colour Robot
            self.PlotAndColourRobot();    
            % Initialise animate delay to 0
            self.model.delay = 0;
        end
        
        %% GetUR3Robot 
        function GetUR3Robot(self)
            disp('Creating UR3');
            pause(0.001);
            name = ['Assessment1_13214489',datestr(now,'yyyymmddTHHMMSSFFF')];
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
            
            
            self.model = SerialLink(L,'name',name);
        end
        %% PlotAndColourRobot
        % Given a robot index, add the glyphs (vertices and faces) and
        % colour them in if data is available
        function PlotAndColourRobot(self)
            %% Obtain 3D model of UR3
            for linkIndex = 1:self.model.n
                [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['ur3_',num2str(linkIndex),'.ply'],'tri'); %#ok<AGROW>
                self.model.faces{linkIndex + 1} = faceData;
                self.model.points{linkIndex + 1} = vertexData;
                
            end
            
            %% Plot UR3 as 3D
            % plot3d(UR3,0,'noarrow','workspace',workspace);
            q = zeros(1,6);
%             q = [0 -90*pi/180 -45*pi/180 20*pi/180 -90*pi/180 -90*pi/180 0];
            self.model.plot3d(q,'workspace',self.workspace);
            % UR3.teach();
            % Note the function below will make the graphics sharper
            if isempty(findobj(get(gca,'Children'),'Type','Light'))
                camlight
            end
            %% Colour UR3
            for linkIndex = 0:self.model.n
                handles = findobj('Tag', self.model.name); %findobj: find graphics objects with
                                                    %specific properties
                                                    %'Tag': a property name, therefore
                                                    %it's finding objects whose Tag is
                                                    %UR3
                                                    %h will return the all objects in
                                                    %the hierarchy that have their Tag
                                                    %property set to value 'UR3'
                h = get(handles,'UserData');        %get: returns the value for 'UserData'.
                                                    %h is a structure (see OneNote or
                                                    %print onto cmd)
                try
                    h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ... %%as h is a structure we access h.link and iterate
                        , plyData{linkIndex+1}.vertex.green ...                                         %%through each link and obtain its colour
                        , plyData{linkIndex+1}.vertex.blue]/255;
                    h.link(linkIndex+1).Children.FaceColor = 'interp';
                catch ME_1
                    disp(ME_1);
                    continue;
                end
            end
            
        end
        %% PlotEnvironment
        function PlotEnvironment(self)
            disp('Plotting Environment');
            offset = -0.67; %adjusting the height of environment so UR3 is placed on top of the table
            [f,v,data] = plyread('Environment2.ply','tri');
            vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            % Plot the environment, account for any changes in the UR3's base
            trisurf(f,v(:,1)+ self.baseUR3(1)...
                , v(:,2) + self.baseUR3(2)...
                , v(:,3) + offset + self.baseUR3(3)...
                ,'FaceVertexCData',vertexColours,'EdgeColor','interp','EdgeLighting','flat');   
            
            hold on;
        end      
          
        
    end
end
