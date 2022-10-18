classdef RacketEE < handle
    properties
        %> Robot model
        model;
        eeBase = [0 0 0];
        %> workspace
        workspace = [-0.6 0.6 -0.6 0.6 -0.2 1.1];
        
    end
    
    methods%% Class for RacketEE robot simulation
        function self = RacketEE(eeBase) 
            self.eeBase = eeBase;
            self.GetRacketEERobot();
            
            disp(['eeBase: ',num2str(self.eeBase)]);
        end
        
        %% GetRacketEERobot
        % Given a name (optional), create and return a RacketEE robot model
        function GetRacketEERobot(self)
            L(1) = Link([0 0 0 0 1 0]);
            self.model = SerialLink(L);
            
            for linkIndex = 1:self.model.n
                [ faceData, vertexData, plyData{linkIndex + 1} ] = plyread(['pingpong.ply'],'tri'); %#ok<AGROW>
                self.model.faces{linkIndex + 1} = faceData;
                self.model.points{linkIndex + 1} = vertexData;
            end
            % gripper open as wide as possible
            self.model.base = self.model.base * transl([self.eeBase(1) self.eeBase(2) self.eeBase(3)]);
            self.model.plot3d(zeros(1,self.model.n),'workspace',self.workspace);
            
            %             self.model.teach();
            %             if isempty(findobj(get(gca,'Children'),'Type','Light'))
            %                 camlight
            %             end
            
            for linkIndex = 0:1
                handles = findobj('Tag', self.model.name);
                h = get(handles,'UserData');
                try
                    h.link(linkIndex+1).Children.FaceVertexCData = [plyData{linkIndex+1}.vertex.red ...
                        , plyData{linkIndex+1}.vertex.green ...
                        , plyData{linkIndex+1}.vertex.blue]/255;
                    h.link(linkIndex+1).Children.FaceColor = 'interp';
                catch ME_1
                    %                     disp(ME_1);
                    continue;
                end
            end
            
        end
        
    end
end
