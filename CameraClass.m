%% run roscore
% rosinit
% roslaunch realsense2_camera rs_camera.launch filters:=pointcloud


classdef CameraClass < handle
    properties (Access = private)
        red = 1;
        green = 2;
        blue = 3;
        ballCentroid = [0 0 0];
    end
    
    methods
        % constructorcam
        function self = Camera
            ColourDetection();
        end
        % user selects colour
        function ColourDetection(self)
            % subscribe to ros topic, in this case we want the raw coloured
            % image
            sub = rossubscriber('/camera/color/image_raw');
            % next read the incoming messages for the next 10 seconds from
            % the topic we subscribed to
            msg = receive(sub,10);
            % transform the message into a readable image
            data = readImage(msg);
            % open figure to display the image on and display the image
            figure(1);
            imshow(data);
            hold on; 
            % select the colour 
            diff_im = imsubtract(data(:,:,self.blue), rgb2gray(data));
            % use a meadian filter to filter out noise
            diff_im = medfilt2(diff_im, [3 3]);
            % transform into a binary black and white image
            diff_im = im2bw(diff_im,0.18);
            %% %%%%%%%%%%%%%%%%%%%%%%%%% not sure what these do
            diff_im = bwareaopen(diff_im,300);
            
            bw = bwlabel(diff_im, 8);
            
            stats = regionprops(bw, 'BoundingBox', 'Centroid');
            
            for object = 1:length(stats)
                bb = stats(object).BoundingBox;
                self.ballCentroid = stats(object).Centroid;
                rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
                plot(self.ballCentroid(1),self.ballCentroid(2), '-m+')
                a=text(self.ballCentroid(1)+15,self.ballCentroid(2), strcat('X: ', num2str(round(self.ballCentroid(1))), ' Y: ', num2str(round(self.ballCentroid(2)))));
                set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'black');
            end
            %% %%%%%%%%%%%%%%%%%%%%%%%%%
            %%
            
        end
        % returns the x y z location of the ball 
        function [x y z] = GetLocation(self)
            x = self.ballCentroid(1);
            y = self.ballCentroid(2);
            z = self.ballCentroid(3);
        end
        
        function UpdateColour(self)
        end
        
        function DepthEstimation(self)
            
        end
        
    end
    
end