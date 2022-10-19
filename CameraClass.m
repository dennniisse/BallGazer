%% run roscore
% rosinit
% roslaunch realsense2_camera rs_camera.launch filters:=pointcloud


classdef CameraClass < handle
    properties (Access = private)
        red = 1;
        green = 2;
        blue = 3;
        selectedColour = 1;
        ballCentroid = [0 0 0];
        rgbData; rgbScaled;
        depthData;
    end

    
    methods
        % constructorcam
        function self = CameraClass()
%             self.getDepthData();
%             self.ColourDetection();
%             self.plotDepthImage();
%             self.manualDepthSelection();
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
            self.rgbScaled = imresize(self.rgbData, size(self.depthData));
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
                boundBox = stats(object).BoundingBox;
                self.ballCentroid = stats(object).Centroid;
                rectangle('Position',boundBox,'EdgeColor','r','LineWidth',2)
                plot(self.ballCentroid(1),self.ballCentroid(2), '-m+')
                a=text(self.ballCentroid(1)+15,self.ballCentroid(2), strcat('X: ', num2str(round(self.ballCentroid(1))), ' Y: ', num2str(round(self.ballCentroid(2)))));
                set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'black');
            end
            
            hold off;
        end
        % returns the x y z location of the ball
        function [x y z] = GetLocation(self)
            x = self.ballCentroid(1);
            y = self.ballCentroid(2);
            z = self.ballCentroid(3);
        end
        
        
        function getDepthData(self)
            depthSub = rossubscriber('/camera/depth/image_rect_raw');
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
            hold on; axis on;
            
            hold off;
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
        
    end
    
end