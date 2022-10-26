%% Create a video device to acquire data from a camera, following code couldn't open RealSense camera as MATLAB doesn't support it
% camNum = 0; % 0: webcam, 2:, 4:, 6: OR 3:, 7:, 9:
% cam = webcam(['/dev/video',num2str(camNum)]);
% preview(cam);

%% Ontaining image from ROS topic
clc;
red = 1;
green = 2;
blue = 3;
sub = rossubscriber('/camera/color/image_raw'); % subscribe to the camera topic
msg = receive(sub,10); % read the incoming messages for the next 10 seconds
data = readImage(msg); % turn the message into an image 
% data = imread('balls.jpg'); 
figure(1); % open a new figure to display the image on
imshow(data); % display image 
hold on;
diff_im = imsubtract(data(:,:,red), rgb2gray(data)); % filter for the colour
% Use a median filter to filter out noise
diff_im = medfilt2(diff_im, [3 3]);

diff_im = im2bw(diff_im,0.18);

diff_im = bwareaopen(diff_im,300);

bw = bwlabel(diff_im, 8);

stats = regionprops(bw, 'BoundingBox', 'Centroid');

for object = 1:length(stats)
    bb = stats(object).BoundingBox;
    bc = stats(object).Centroid;
    rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
    plot(bc(1),bc(2), '-m+')
    a=text(bc(1)+15,bc(2), strcat('X: ', num2str(round(bc(1))), ' Y: ', num2str(round(bc(2)))));
    set(a, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'black');
end
bc = stats(object).Centroid;
disp(['Centroid',num2str(bc(1)),num2str(bc(2))]);
bc(1)
axis on;
hold off;