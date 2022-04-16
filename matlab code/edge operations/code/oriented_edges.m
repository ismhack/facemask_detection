function result_img = oriented_edges(image, sigma, threshold, direction, tolerance)

%check if image is color then convert to gray scale
if size(image,3)==3
    image = rgb2gray(image)
end

if tolerance < 0 | tolerance >90
    
    disp("Tolerance should be in the range [0 - 90]")
end

dx = [
   -1 0 1;
   -2 0 2;
   -1 0 1;
   ];
dx = dx / 8
dy = dx';  % dy is the transpose of dx

% Blur image
blur_size = round(ceil(sigma) * 6 + 1);
blur_window = fspecial('gaussian', blur_size, sigma);
b1 = imfilter(image, blur_window, 'same', 'symmetric');

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
% result of canny algorithm - edges in all angles
result = hysthresh(thinned, threshold, threshold * 2); 

% extracting angles of the result elements
thetas_2 =  thetas .* result

% direction that is perpendicular to the gradient
thetas_2(thetas_2 ~= 0) = thetas_2(thetas_2 ~= 0) + 90; 

% convert orientations to [0 180] range.
thetas_2(thetas_2 < 0) = thetas_2(thetas_2 < 0) + 180;
thetas_2(thetas_2 > 180) = thetas_2(thetas_2 > 180) - 180;
% computing image based on direction and tolerance params
angle = direction
angle = mod(abs(angle), 180)

left_angle = angle - tolerance
if (left_angle < 0); left_angle = left_angle + 180; end;
right_angle = angle + tolerance
if (right_angle > 180); right_angle = 0; end;

if((angle - tolerance) < 0)
    result_img = ((thetas_2 > 0 & thetas_2 <= right_angle) | (thetas_2 <= 180 & thetas_2 >= left_angle))
else
    result_img = (thetas_2 > left_angle & thetas_2 <= right_angle)
end