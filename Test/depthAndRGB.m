clc; clear; clf;
red = 1;
green = 2;
blue = 3;

depthSub = rossubscriber('/camera/depth/image_rect_raw');
depthMsg = receive(depthSub,10);
depthData = readImage(depthMsg);


rgbSub = rossubscriber('/camera/color/image_raw');
rgbMsg = receive(rgbSub,10); 
rgbData = readImage(rgbMsg);
rgbScaled = rgbData;%imresize(rgbData, size(depthData));
figure(1);
title('RGB');
imshow(rgbScaled);
axis on; 
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
Z = depthData(X:Y)
hold off;

figure(2)
title('Depth');
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

depthIntrinsicSub = rossubscriber('/camera/depth/camera_info');
depthIntrinsic = receive(depthIntrinsicSub,2);
fx_depth = depthIntrinsic.K(1);
fy_depth = depthIntrinsic.K(5);
cx_depth = depthIntrinsic.K(3);
cy_depth = depthIntrinsic.K(6);

