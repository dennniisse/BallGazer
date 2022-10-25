classdef UR3 < handle
    properties
        %> Robot model
        model;
        racket;
        offsetTable = 0.9392;
        %> workspace
        workspace = [-2 2 -2 2 0 2];   
        base_location = [0 0 0];
      
    end
    
    methods%% Class for UR3 robot simulation
        function self = UR3(base_location)
            
            disp('Spawning UR3...');
            
            if 1 > nargin
                disp('Warning! No Base Location Specified');
                disp('Base Location set to Origin.');
                self.base_location = [0 0 0];
            end
            
            self.GetUR3Robot();
            self.getEnvironment();
            disp(['Base of UR3(XYZ):','[',num2str(self.model.base(1,4)),' ', num2str(self.model.base(2,4)),' ',num2str(self.model.base(3,4)),']']);
            drawnow
            disp('Complete!');
        end

        %% GetUR3Robot
        % Given a name (optional), create and return a UR3 robot model
        function GetUR3Robot(self)
            pause(0.001);
            name = ['UR3_',datestr(now,'yyyymmddTHHMMSSFFF')];
            L1 = Link('d',0.1519,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            L2 = Link('d',0,'a',-0.24365,'alpha',0,'qlim', deg2rad([-360 360]), 'offset',0);
            L3 = Link('d',0,'a',-0.21325,'alpha',0,'qlim', deg2rad([-360 360]), 'offset', 0);
            L4 = Link('d',0.11235,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            L5 = Link('d',0.08535,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360,360]), 'offset',0);
            %             L6 = Link('d',(0.0819 + 0.092),'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset', 0);
            L6 = Link('d',0.0819,'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset', 0);
%             L7 = Link('d', 0, 'a', 0, 'alpha', 0, 'qlim',[0 0],'offset',0);
            self.model = SerialLink([L1 L2 L3 L4 L5 L6],'name',name);
            self.model.delay = 0;
            self.model.base = self.model.base * transl(self.base_location(1), self.base_location(2), (self.base_location(3)+self.offsetTable));
            %             self.model.base = self.model.base * trotx(pi/2) * troty(pi/2);
            
            for linkIndex = 0:self.model.n
                [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['ur3_',num2str(linkIndex),'.ply'],'tri'); %#ok<AGROW>
                self.model.faces{linkIndex + 1} = faceData;
                self.model.points{linkIndex + 1} = vertexData;
            end
            
            % Display robot
            starting_q_UR3 = [0 deg2rad(270) 0 deg2rad(270) 0 0]; %Set Starting Pose
            self.model.plot3d(starting_q_UR3(1,:),'noarrow','workspace',self.workspace);
            if isempty(findobj(get(gca,'Children'),'Type','Light'))
                camlight
            end
            self.model.delay = 0;
            
            % Try to correctly colour the arm (if colours are in ply file data)
            for linkIndex = 0:self.model.n
                handles = findobj('Tag', self.model.name);
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
            
            hold on;
        end
        
%         function getRacket(self)
%             L(1) = Link([0 0 0 0 1 0]);
%             self.racket = SerialLink(L);
%             
%             for linkIndex = 1:self.racket.n
%                 [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['pingpong.ply'],'tri'); %#ok<AGROW>
%                 self.racket.faces{linkIndex + 1} = faceData;
%                 self.racket.points{linkIndex + 1} = vertexData;
%             end
%             eeBase = self.model.fkine(self.model.getpos);
%             eeBase = eeBase(1:3,4)';
%             self.racket.base = self.racket.base * transl([eeBase(1) eeBase(2) eeBase(3)]) * trotx(pi/2) * trotz(pi/2);
%             self.racket.plot3d(zeros(1,self.racket.n),'workspace',self.workspace);
%             self.racket.delay = 0;
%             
%             for linkIndex = 0:1
%                 handles = findobj('Tag', self.racket.name);
%                 h = get(handles,'UserData');
%                 try
%                     h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ...
%                         , plyData{linkIndex+1}.vertex.green ...
%                         , plyData{linkIndex+1}.vertex.blue]/255;
%                     h.link(linkIndex+1).Children.FaceColor = 'interp';
%                 catch ME_1
%                     continue;
%                 end
%             end
%             hold on;
%         end
        
        function getEnvironment(self)
            [f,v,data] = plyread('environment_SnC.ply','tri');
            vertexColours = [data.vertex.red, data.vertex.green, data.vertex.blue] / 255;
            % Plot the environment, account for any changes in the UR3's base
            trisurf(f,v(:,1)+ self.base_location(1)...
                , v(:,2) + self.base_location(2)...
                , v(:,3) + self.base_location(3)...
                ,'FaceVertexCData',vertexColours,'EdgeColor','interp','EdgeLighting','flat');
            
            hold on;
        end
        
%         function update_gripper(self,eeBase)
%             eeBase = eeBase(1:3,4)';
%             disp(['eeBase: ', num2str(eeBase)]);
%             self.racket.base = self.racket.base * transl([eeBase(1) eeBase(2) eeBase(3)]) * trotx(pi/2) * trotz(pi/2);
%         end
    end
end