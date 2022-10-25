classdef BallLoading < handle
    % This is for User interface
    % The purpose of this class is to ask the user
    %       1. How many balls to be loaded on the simulation, at least one
    %       ball should be loaded
    %       2. Choose the colour of the ball
    %       3. Finally, the racket moves towards the ball
    
    properties
        %> Number of ball
        ballsCount = 2;      
        %Initial location of balls
        red_ball_offset = transl([-0.25 -1 0.9267]);
        blue_ball_offset = transl([-0.25 -1.05 0.9267]);
        
        ballE;
        workspaceDimensions;        
        base_location = [0.2 0.2 0];
    end
       
    methods
<<<<<<< HEAD
        %% strucktos
        function self = BallLoading(base_location,colour)
            hold on; 
            switch colour
                case 'red'
                    self.ballE = PlaceObject("Red_Ball.ply", [base_location(1) base_location(2) base_location(3)]);
                case 'blue'
                    self.ballE = PlaceObject("Blue_Ball.ply", [base_location(1) base_location(2) base_location(3)]);                    
            end
            
            
            
            %Create balls required
%             for i = 1:1:self.ballsCount
%                 
%                 self.ballE{i} = self.GetBallModel(['ball', num2str(i)]);
%                 
%                  Default spawn
%                 self.ballE{i}.base = transl(base_location(1) + (0.09*i) - 0.09, base_location(2), base_location(3)) * trotx(0) * troty(0) * trotz(0);
%                 if i == 2 % need to consider the size of the ball
%                     self.ballE{i}.base = transl(base_location(1) + -0.1, ...
%                     base_location(2), base_location(3));
%                 end
%                 if i == 3 % need to consider the size of the ball 
%                     self.ballE{i}.base = transl(base_location(1) + -0.05, ...
%                     base_location(2), base_location(3));
%                 end
%             end
=======
        %% strucktors
        function self = BallLoading
            
            self.workspaceDimensions = [-0.6 0.6 -2 0.5 0 2];
            self.red_ball_offset();
            self.blue_ball_offset();
            
            %Create balls required
            for i = 1:1:self.ballsCount
                
                self.ballE{i} = self.GetBallModel(['ball', num2str(i)]);
                
                 % Default spawn
                self.ballE{i}.base = transl([0.15 -0.4 0.9267]);

            end
>>>>>>> 1cb6f061505595f2fdaa4d34c2da4393c0f5dedd
        end
    end    
    
     methods (Static)
         %%Get Ball ply
         function model = GetBallModel(name)
             if nargin < 1
                 name = 'Ball';
             end            
%              if ballsCount = 1
             [faceData, vertexData] = plyread('Red_Ball.ply','tri');
              %Get them to spawn with Z facing down?
             L1 = Link('alpha',0,'a',0.0001,'d',0,'offset',0); 
             model = SerialLink(L1,'name',name);
             model.faces = {faceData,[]};
%             vertexData(:,2) = vertexData(:,2) + 0.4;
             model.points = {vertexData * rotx(0) * roty(0) * rotz(0),[]};
%              end
         end
         function uploadCorrectColour(self,colour)
         end
     end
end