clc; clear; clf;
red = 1;
green = 2;
blue = 3;

depthSub = rossubscriber('/camera/aligned_depth_to_color/image_raw');%('/camera/depth/image_rect_raw');
depthMsg = receive(depthSub,10);
depthData = readImage(depthMsg);


rgbSub = rossubscriber('/camera/color/image_raw');
rgbMsg = receive(rgbSub,10); 
rgbData = readImage(rgbMsg);
rgbScaled = readImage(rgbMsg); %imresize(rgbData, size(depthData));
figure('NumberTitle', 'off', 'Name', 'RGB Image');
hold on;

imshow(rgbScaled);
axis on; axis equal;
hold on;
diff_im = imsubtract(rgbScaled(:,:,red), rgb2gray(rgbScaled)); % filter for the colour
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
X = round(bc(1))
Y = round(bc(2))
Z = depthData(Y,X)
hold off;
figure('NumberTitle', 'off', 'Name', 'Depth Image');
imshow(depthData);
hold on;
plot(bc(1),bc(2), '-m+')
axis on;

% get rgb data noting that K according to sensor_msgs documentation 
% K = [fx  0 cx 0 fy cy 0  0  1]
rgbIntrinsicSub = rossubscriber('/camera/color/camera_info');
rgbIntrinsic = receive(rgbIntrinsicSub,2);
fx_rgb = rgbIntrinsic.K(1);
fy_rgb = rgbIntrinsic.K(5);
cx_rgb = rgbIntrinsic.K(3);
cy_rgb = rgbIntrinsic.K(6);

depthIntrinsicSub = rossubscriber('/camera/aligned_depth_to_color/camera_info');
dIntrinsic = receive(depthIntrinsicSub,2);
fx_d = dIntrinsic.K(1);
fy_d = dIntrinsic.K(5);
cx_d = dIntrinsic.K(3);
cy_d = dIntrinsic.K(6);

% sub = rossubscriber('/camera/extrinsics/depth_to_color');
% extrinsics  = receive(exSub,0.5);
% alignRGBDD(depthData, rgbData,...
%     fx_d, fy_d, cx_d, cy_d,...
%     fx_rgb, fy_rgb, cx_rgb, cy_rgb,...
%     extrinsics)
