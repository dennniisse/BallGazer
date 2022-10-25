classdef Controller
    % Based on Week 11 Starter as this provides Windows/Ubuntu support
    % No Rumble Support on Xbox 360 Controller
    % Written for Xbox 360 Controller
    
    properties(Constant)
        %Buttons
        A = 1;
        B = 2;
        X = 3;
        Y = 4;
        BumperLeft = 5;
        BumperRight = 6;
        BACK = 7;
        START = 8;
        Joy_Click_Left = 9;
        Joy_Click_Right = 10;

        %Axis
        %Deadzone is roughly 0.2
        Joy_X_Axes_Left = 1; %-1 to 1
        Joy_Y_Axes_Left = 2; %-1 to 1
        Triggers = 3; % -0.996 to 0.996
        Joy_X_Axes_Right = 4; %-1 to 1
        Joy_Y_Axes_Right = 5; %-1 to 1

        %Povs
        DPad_UP = [0 360];
        DPad_RIGHT = 90;
        DPad_DOWN = 180;
        DPad_LEFT = 270;
        
    end
    
    properties
        id;
        joy;
        joy_info;
        
        %Players
        player = [false false false false];

    end
    
    methods
        function self = Controller(id) %%Input: XYZRPY, meters & radians
            %%Setup joystick
            self.id = id; % NOTE: may need to change if multiple joysticks present
            self.player(id) = true;
            disp(['Player ', num2str(id)]);

            self.joy = vrjoystick(self.id,'forcefeedback'); %Try force feedback
            self.joy_info = caps(self.joy); % print joystick information


            fprintf('Your joystick has:\n');
            fprintf(' - %i buttons\n',self.joy_info.Buttons);
            fprintf(' - %i axes\n', self.joy_info.Axes);
            fprintf(' - %i povs\n', self.joy_info.POVs);
            pause(2);
            
            %%UNCOMMENT HERE TO TEST CONTROLLER! (IN CLASS FILE)
%             self.TestController();
         end

        function TestController(self)
            %%Week 11 Starter Code + Force Feedback Test
            while(1)
    
                % Read joystick buttons
                [axes, buttons, povs] = read(self.joy);
                %c = caps(joy);

                % Print buttons/axes info to command window
                str = sprintf('--------------\n');
                for i = 1:self.joy_info.Buttons
                    str = [str sprintf('Button[%i]:%i\n',i,buttons(i))];
                end
                for i = 1:self.joy_info.Axes 
                    str = [str sprintf('Axes[%i]:%1.3f\n',i,axes(i))]; 
                end
                for i = 1:self.joy_info.POVs
                    str = [str sprintf('Povs[%i]:%1.3f\n',i,povs(i))]; 
                end
                str = [str sprintf('--------------\n')];
                fprintf('%s',str);
 
                %Try ForceFeedback
                try force(self.joy,1,1); 
                catch disp('Trying to Vibrate, no Force Feedback Available!');
                end 

                pause(0.05);  
%                 pause(1); 

            end
        end
        
        function [axes, buttons, povs] = ReadController(self)
            % Read joystick buttons
            [axes, buttons, povs] = read(self.joy);
        end
        
    end
end

