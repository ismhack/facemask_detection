function X = road_orientation_figure(gray)

dx = [
   -1 0 1;
   -2 0 2;
   -1 0 1;
   ];
dx = dx / 8

sigma = 1.4
blur_size = round(ceil(sigma) * 6 + 1);
blur_window = fspecial('gaussian', blur_size, sigma);
b1 = imfilter(gray, blur_window, 'same', 'symmetric');

dy = dx';  % dy is the transpose of dx

% compute dx, dy, and gradient norms
dxb1 = imfilter(b1, dx, 'same', 'symmetric');
dyb1 = imfilter(b1, dy, 'same', 'symmetric');
gradient = (dxb1 .^2 + dyb1 .^2).^0.5;

thetas =  atan2(dyb1, dxb1);  %correct, angles increase clockwise

% convert orientations to [0 180] range.
thetas = (thetas) / pi * 180;
thetas(thetas < 0) = thetas(thetas < 0) + 180;
thetas(thetas > 180) = 0;

thinned = nonmaxsup(gradient, thetas, 1.3);   
result = hysthresh(thinned, 4, 8); % result of canny algorithm

% extracting angles of the result elements
thetas_2 =  thetas .* result

% direction that is perpendicular to the gradient
thetas_2(thetas_2 ~= 0) = thetas_2(thetas_2 ~= 0) + 90; 

% convert orientations to [0 180] range.
thetas_2(thetas_2 < 0) = thetas_2(thetas_2 < 0) + 180;
thetas_2(thetas_2 > 180) = thetas_2(thetas_2 > 180) - 180;

result_oriented = thetas_2 > 0

result_oriented = imclose(result_oriented, [1,1,1; 1,1,1; 1,1,1])
[labels, number] = bwlabel(result_oriented, 8);

distances = zeros(1,number)
for i = 1:number
  
    [x, y] = find(labels == i);
  
    distances(i) = max((sqrt( (x - x(1) ).^2 + (y - y(1)).^2)))
end
% find the id of the largest component
[area, id] = max(distances);  
road = (labels == id);
road_angle = road .* thetas_2
angles = road_angle(road_angle >0)
% compute the average angle
angle = mean(angles)
% cimpute the max distance from point0 to pointN to trace the line
[x, y] = find(road > 0) 
distances = sqrt( (x - x(1) ).^2 + (y - y(1)).^2)
max_distance = max(distances)
max_distance_idx = find(distances == max_distance)
figure(1);
imshow(gray,[])
hold on
axis on;
y2 =y(max_distance_idx) 
y1=y(1)
x2 = x(max_distance_idx)
x1=x(1)
drawLine([y1,x1], [y2 , x2])
hold off
%output the figure
F = getframe(gcf);
[X, Map] = frame2im(F);