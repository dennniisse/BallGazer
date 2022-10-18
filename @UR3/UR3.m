classdef UR3 < handle
    properties
        %> Robot model
        model;
        
        %> workspace
        workspace = [-1 1 -1 1 0 1.5];   
        
        base_location = [0 0 0];
      
    end
    
    methods%% Class for UR3 robot simulation
        function self = UR3(base_location)
            
            disp('Spawning UR3...');
            
            if 1 > nargin
                disp('Warning! No Base Location Specified');
                disp('Base Location set to Origin.');
                base_location = [0 0 0];
            end
            
            self.GetUR3Robot(base_location);
            self.PlotAndColourRobot();
            disp(['Base of UR3(XYZ)']);
                display([num2str(self.model.base(1,4)),'  ', ...
                num2str(self.model.base(2,4)),'  ', ...
                num2str(self.model.base(3,4))]);
  
            drawnow
            disp('Complete!');
        end

        %% GetUR3Robot
        % Given a name (optional), create and return a UR3 robot model
        function GetUR3Robot(self,base_location)
            self.base_location = base_location;
            pause(0.001);
            name = ['UR3_',datestr(now,'yyyymmddTHHMMSSFFF')];
            L1 = Link('d',0.1519,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]), 'offset',0);
            L2 = Link('d',0,'a',-0.24365,'alpha',0,'qlim', deg2rad([-360 360]), 'offset',0);
            L3 = Link('d',0,'a',-0.21325,'alpha',0,'qlim', deg2rad([-360 360]), 'offset', 0);
            L4 = Link('d',0.11235,'a',0,'alpha',pi/2,'qlim',deg2rad([-360 360]),'offset', 0);
            L5 = Link('d',0.08535,'a',0,'alpha',-pi/2,'qlim',deg2rad([-360,360]), 'offset',0);
%             L6 = Link('d',(0.0819 + 0.092),'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset', 0);
            L6 = Link('d',0.0819,'a',0,'alpha',0,'qlim',deg2rad([-360,360]), 'offset', 0);
             
            self.model = SerialLink([L1 L2 L3 L4 L5 L6],'name',name);
            self.model.base = self.model.base * transl(base_location(1), base_location(2), base_location(3));
%             self.model.base = self.model.base * trotx(pi/2) * troty(pi/2);
        end

        %% PlotAndColourRobot
        % Given a robot index, add the glyphs (vertices and faces) and
        % colour them in if data is available 
        function PlotAndColourRobot(self)%robot,workspace)
            for linkIndex = 0:self.model.n
                [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['ur3link_',num2str(linkIndex),'.ply'],'tri'); %#ok<AGROW>                
                self.model.faces{linkIndex + 1} = faceData;
%                 if linkIndex == self.model.n
%                     vertexData(:,3) = vertexData(:,3) - 0.092; %Offset End Effector
%                 end
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
        end        
    end
end
