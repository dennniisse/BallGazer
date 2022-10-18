classdef LoadingBall < handle
    % This is for User interface
    % The purpose of this class is to ask the user
    %       1. How many balls to be loaded on the simulation, at least one
    %       ball should be loaded
    %       2. Choose the colour of the ball
    %       3. Finally, the racket moves towards the ball
    
    properties (Constants)
        %> Max height is for plotting of the workspace
        maxHeight = 1;
        
        %> Minimum number of ball
        ballsCount = 1;
        
        %Initial location of the ball, for testing, set the ball location
        % at (0 0 0)
         ball_offset = transl([0 0 0]);
    end
    
    methods
        %% strucktos
        function self = Balls(base_location)
            
            self.workspaceDimensions = [-2.5 2.5 -2 2.5 0 3];
            
            %Create balls required
            for i = 1:1:ballsCount
                
                self.ballE{i} = self.GetBallModel(['ball', num2str(i)]);
                
                 % Default spawn
                self.ballE{i}.base = transl(base_location(1) + (0.09*i) - 0.09, ...
                base_location(2), base_location(3)) * trotx(0) * troty(0) * trotz(0);
                if i == 2 % need to consider the size of the ball (JUST PASTED FROM ASHWIN'S CODE)
                    self.ballE{i}.base = transl(base_location(1) + -0.1, ...
                    base_location(2), base_location(3));
                end
                if i == 3 % need to consider the size of the ball (JUST PASTED FROM ASHWIN'S CODE)
                    self.ballE{i}.base = transl(base_location(1) + -0.05, ...
                    base_location(2), base_location(3));
                end
            end
        end
        
     methods (Static)
         %%Get Ball ply
         function model = GetBallModel(name)
             if nargin < 1
                 name = 'Ball';
             end
             
             [faceData, vertexData] = plyread(