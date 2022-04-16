filename = '../data/test01.jpg';
gray = read_gray(filename);

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

%dx = imrotate(dy, 90, 'bilinear', 'loose')
%dy = imrotate(dx, 15, 'bilinear', 'loose');

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

angle = 90
angle = mod(abs(angle), 180)
tolerance = 90

left_angle = angle - tolerance
if (left_angle < 0); left_angle = left_angle + 180; end;
right_angle = angle + tolerance
if (right_angle > 180); right_angle = 0; end;

if((angle - tolerance) < 0)
    result_oriented = ((thetas_2 > 0 & thetas_2 <= right_angle) | (thetas_2 <= 180 & thetas_2 >= left_angle))
else
    result_oriented = (thetas_2 > left_angle & thetas_2 <= right_angle)
end
result_oriented = imclose(result_oriented, [1,1,1; 1,1,1; 1,1,1])
figure(8); imshow(result_oriented, []);
[labels, number] = bwlabel(result_oriented, 8);

counters = zeros(1,number);
distances = zeros(1,number)
for i = 1:number
    component_image = (labels == i);
    [x, y] = find(labels == i);
    counters(i) = sum(component_image(:));
    distances(i) = max((sqrt( (x - x(1) ).^2 + (y - y(1)).^2)))
end

% find the id of the largest component
[M,N] = size(gray)
[area, id] = max(distances);  
road = (labels == id);
figure(9); imshow(road, []);
road_angle = road .* thetas_2
angles = road_angle(road_angle >0)
% compute the average angle
angle = mean(angles)
[x, y] = find(road > 0) 
% cimpute the max distance from point0 to pointN to trace the line
distances = sqrt( (x - x(1) ).^2 + (y - y(1)).^2)
max_distance = max(distances)
max_distance_idx = find(distances == max_distance)
figure(10);
imshow(gray,[])
hold on
axis on;
y2 =y(max_distance_idx) 
y1=y(1)
x2 = x(max_distance_idx)
x1=x(1)
drawLine([y1,x1], [y2 , x2])
hold off
%figure(5); imshow(oriented_edges(gray, 1.4, 4, 0, 15), []);
%figure(6); imshow(oriented_edges(gray, 1.4, 4, 45, 15), []);
%figure(7); imshow(oriented_edges(gray, 1.4, 4, 90, 15), []);
%figure(8); imshow(oriented_edges(gray, 1.4, 4, 135, 15), []);
%%
filename = '../data/road2.bmp';
gray = read_gray(filename);
[M,N] = size(gray)
rhoResolution=10
D = sqrt((M - 1)^2 + (N - 1)^2);
q = ceil(D/rhoResolution);
nrho = 2*D/rhoResolution + 1;
rho_vector = linspace(-D, D, nrho);
thetas = (0:10:180)
[thetas_canny,result] = canny4(gray,1.4,1,4,8)
thetas_canny =  thetas_canny .* result

counter = zeros(size(rho_vector,2),size(thetas,2))
[rows,cols] = size(result);
serials = find(result == 1)

for i = 1:size(serials,1)
    [row, col] = ind2sub([rows,cols], serials(i))
    for theta = 1:size(thetas,2)
        rho = ( col*cos(deg2rad(theta)) + row*sin(deg2rad(theta)) )
        [minvalue, minidx] = min(abs(rho_vector - rho))
        counter(minidx, theta) = counter(minidx, theta) +1
    end
end

max_rho = max(max(counter))
[rho_indices, theta_indices] = find(counter == max_rho);

rho = rho_vector(rho_indices)
theta = (thetas(theta_indices))
x = int16(rho * cos(deg2rad(theta)))
y = int16(rho * sin(deg2rad(theta)))
%%

%%draw
figure(1) 

imshow(gray,[]);
xlim([-N N])
axis on;
grid on;
hold on
A= double([x y])
B = double([1 1])
drawLine(B,A)

midX = mean(A(1), B(2) )
midY = mean(A(2), B(2))
hold on;
plot(midX, midY, 'r*', 'LineWidth', 2, 'MarkerSize', 25);
% Get the slope
slope = (B(2)-A(2)) / (B(1)- A(1))
% For perpendicular line, slope = -1/slope
slope = -1/slope
% Point slope formula (y-yp) = slope * (x-xp)
% y = slope * (x - midX) + midY
% Compute y at some x, for example at x=300
y = slope * (x - midX) + midY
plot([0, midX], [y, midY],'Color','r','LineWidth',2)

if(theta + 90 > 180)
    angle = (theta + 90) -180
else
    angle = theta + 90
end

p1 = double([y x])
p2 = double([y + cos(angle)*100,x + sin(angle)*100])

plot(p1, p2, 'Color','r','LineWidth',2)

set(gca, 'ydir', 'reverse')
hold off
%%
 
filename = '../data/road2.bmp';
gray = read_gray(filename);

X = road_orientation(gray)
figure; imshow(X)
%%

RGB = imread('../data/road2.bmp');
I  = im2gray(RGB);
%Extract edges.

BW = edge(I,'canny');
%Calculate Hough transform.

[H,T,R] = hough(BW,'RhoResolution',0.5,'Theta',-90:0.5:89);
%Display the original image and the Hough matrix.

subplot(2,1,1);
imshow(RGB);
title('gantrycrane.png');
subplot(2,1,2);
imshow(imadjust(rescale(H)),'XData',T,'YData',R,...
      'InitialMagnification','fit');
title('Hough transform of gantrycrane.png');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
colormap(gca,hot);


