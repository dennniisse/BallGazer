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
        end
        %% PlotAndColourRobot
        function PlotAndColourRobot(self)
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
        function Move(self)
        end
    end
end