clc;
pointCloud = rosmessage('sensor_msgs/PointCloud2');
sub = rossubscriber('/camera/depth/color/points');
msg = receive(sub,30);
sizeData = size(msg.Data);
pointCloud.Data(1:sizeData,:) = msg.Data(:);
% copy the xyz, located in the .Fields 
pointCloud.Fields = msg.Fields;
pointCloud.Height = msg.Height;
pointCloud.Width = msg.Width;
pointCloud.PointStep = msg.PointStep;
pointCloud.RowStep = msg.RowStep;
xyz = readXYZ(pointCloud);
rgb = readRGB(pointCloud);
scatter3(pointCloud);

% dispairty map
% point cloud 
% 


% centroid from pixel
% ....
% centroid to real world coordinates