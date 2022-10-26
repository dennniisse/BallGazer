%% run roscore
% rosinit
% roslaunch realsense2_camera rs_camera.launch filters:=pointcloud


classdef CameraClass < handle
    properties (Access = private)
        red = 1;
        green = 2;
        blue = 3;
        selectedColour = 1; % default
        ballCentroid = [0 0 0] % test[0.35, -0.2, 1.125];
        rgbData; rgbScaled;
        depthData;
        boundBox;
        fx; fy; cx; cy; % parameters
        cam2ur3dist = 1100; % in cm, transfer into real world coordinates
    end
    
    
    methods
        % constructorcam
        function self = CameraClass()
            self.getCameraParam();
            self.getDepthData();
            self.ColourDetection();
%             self.plotDepthImage();
            self.autoDepthSelection();
        end
        
        function RecalculateLocation(self)
            % Test
            %             self.selectColour();
            %             self.ballCentroid = [0.35, 0.2, 1.125];
            self.getDepthData();
            self.ColourDetection();
            self.autoDepthSelection();
        end
        % user selects colour
        function [colour_selected] = selectColour(self)
            opts.Interpreter = 'tex';
            opts.Default = 'Red';
            quest = 'Select colour to identify';
            colour = questdlg(quest, 'Colour Selection', 'Random', 'Red','Blue', opts);
            
            switch colour
                case 'Random'
                    val = round(1+(2-1).*rand(1,1));
                    if val == 2
                        self.selectedColour = self.blue;
                        colour = 'RANDOM = BLUE';
                    elseif val == 1
                        self.selectedColour = self.red;
                        colour = 'RANDOM = RED';
                    end
                    
                case 'Red'
                    self.selectedColour = self.red;
                    colour = 'RED';
                    
                case 'Blue'
                    self.selectedColour = self.blue;
                    colour = 'BLUE';
            end
            
            colour_selected = self.selectedColour;
            f = msgbox(["The selected colour is: ", colour])';
            waitfor(f);
            
        end
        
        function ColourDetection(self)
            self.selectedColour = self.selectColour();
            % subscribe to ros topic, in this case we want the raw coloured
            % image
            rgbSub = rossubscriber('/camera/color/image_raw');
            % next read the incoming messages for the next 10 seconds from
            % the topic we subscribed to
            rgbMsg = receive(rgbSub,10);
            % transform the message into a readable image
            self.rgbData = readImage(rgbMsg);
            self.rgbScaled = readImage(rgbMsg); % note we don't to sclae it anymore as the images are aligned
            %             self.rgbScaled = imresize(self.rgbData, size(self.depthData));
            % open figure to display the image on and display the image
            figure('NumberTitle', 'off', 'Name', 'RGB Image');
            imshow(self.rgbScaled);
            hold on; axis on;
            % select the colour
            rgb2bw_img = imsubtract(self.rgbScaled(:,:,self.selectedColour), rgb2gray(self.rgbScaled));
            % use a meadian filter to filter out noise
            rgb2bw_img = medfilt2(rgb2bw_img, [3 3]);
            % transform into a binary black and white image
            rgb2bw_img = im2bw(rgb2bw_img,0.18);
            % Removes connected components (objects) that have fewer than P
            % pixels, basically another form of noise filtering
            rgb2bw_img = bwareaopen(rgb2bw_img,300);
            % returns label matrix that contains labels for 8-connected objects
            bw = bwlabel(rgb2bw_img, 8);
            % using the labels, can return the measurement for the set of
            % properties for each 8 connected object in the bw_img, we get
            % the centroid and location for bounding box
            stats = regionprops(bw, 'BoundingBox', 'Centroid');
            % then plot the bounding box using the data from stats
            for object = 1:length(stats)
                self.boundBox = stats(object).BoundingBox;
                self.ballCentroid = stats(object).Centroid;
                rectangle('Position',self.boundBox,'EdgeColor','r','LineWidth',2)
                plot(self.ballCentroid(1),self.ballCentroid(2), '-m+')
                a=text(self.ballCentroid(1)+15,self.ballCentroid(2), strcat('X: ', num2str(round(self.ballCentroid(1))), ' Y: ', num2str(round(self.ballCentroid(2)))));
                set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'black');
            end
            self.ballCentroid(1) = round(self.ballCentroid(1)); %disp(self.ballCentroid(1))
            self.ballCentroid(2) = round(self.ballCentroid(2)); %disp(self.ballCentroid(2))
            hold off;
        end
        % returns the x y z location of the ball
        function [ballLocation] = GetLocation(self)
            z = self.ballCentroid(3); 
            % u v to real world parameters
            x = (self.ballCentroid(1)-self.cx)*z / self.fx;
            x = x / 100;% cm 2 m
            y = (self.ballCentroid(2)-self.cy)*z / self.fy;
            y = y / 100;% to m
            z = self.cam2ur3dist - self.ballCentroid(3); % ur3 base is the 0 0 0 of the real world
            z = z / 100; % to m
            ballLocation = [x y z];
        end
        
        
        function getDepthData(self)
            depthSub = rossubscriber('/camera/aligned_depth_to_color/image_raw');
            depthMsg = receive(depthSub,10);
            self.depthData = readImage(depthMsg);
            %             figure('NumberTitle', 'off', 'Name', 'Depth Image');
            %             imshow(self.depthData);
            %             hold on; axis on;
            %
            %             hold off;
        end
        
        function plotDepthImage(self)
            figure('NumberTitle', 'off', 'Name', 'Depth Image');
            imshow(self.depthData);
            hold on; plot(self.ballCentroid(1),self.ballCentroid(2),'-m+');
            axis on; axis equal;
            hold off;
        end
        
        function autoDepthSelection(self)
            hold off;
            self.ballCentroid(3) = self.depthData(self.ballCentroid(2),self.ballCentroid(1));
            figure('NumberTitle', 'off', 'Name', 'Depth Image');
            imshow(self.depthData);
            pause(1); % needed to give matlab time to register
            hold on; axis on; hold on;      
            rectangle('Position',self.boundBox,'EdgeColor','r','LineWidth',2)
            plot(self.ballCentroid(1),self.ballCentroid(2), '-m+')
            a=text(self.ballCentroid(1)+15,self.ballCentroid(2), strcat('X: ', num2str(round(self.ballCentroid(1))), ' Y: ', num2str(round(self.ballCentroid(2))), ' Z: ', num2str(round(self.ballCentroid(3)))));
            set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'white');           
            hold off;
            pause(1);
            %             disp(['figis',num2str(self.ballCentroid(3))]);
        end
        function manualDepthSelection(self)
            f = msgbox('Find depth, input box will pop up in 15 seconds')';
            pause(15);
            delete(f);
            prompt = {'Enter the depth obtained from the depth map in mm'};
            dlgtitle = 'Depth (mm)';
            answer = inputdlg(prompt,dlgtitle);
            self.ballCentroid(3) = str2num(answer{1});
            f = msgbox(["Depth value is: ", num2str(self.ballCentroid(3))])';
            waitfor(f);
        end
        
        function [colour] = getColour(self)
            colour = self.selectedColour;
        end
        
        function getCameraParam(self)            
            depthIntrinsicSub = rossubscriber('/camera/aligned_depth_to_color/camera_info');
            dIntrinsic = receive(depthIntrinsicSub,2);
            self.fx = dIntrinsic.K(1);
            self.fy = dIntrinsic.K(5);
            self.cx = dIntrinsic.K(3);
            self.cy = dIntrinsic.K(6);
        end 
        
    end
    
end