function [t, b, l, r] = find_bounding_box(filename)

t=0,b=0,l=0,r=0
%frame distance
fd = 5

[sequence_name, frame] = parse_frame_name(filename)

%End the program if there is no frame to detemrine montion
if (frame - fd) <0 || (frame + fd) > 124 
   return 
end

previous_frame_name= make_frame_name(sequence_name, frame - fd)
next_frame_name = make_frame_name(sequence_name, frame + fd)

%Read frames in gray scale
gray = read_gray(filename)
previous_frame = read_gray(previous_frame_name)
next_frame = read_gray(next_frame_name)

%take the absolute difference from previous and next frames
diff1 = abs(gray - previous_frame)
diff2 = abs(gray - next_frame)

motion = min(diff1, diff2)

threshold = 10; 
thresholded = (motion > threshold); 
%figure
%imshow(thresholded, []);

[labels, number] = bwlabel(thresholded, 8);
%figure 
%imshow(labels, []);

% find the largest connected component
% create an array of counters, one for each connected component.
counters = zeros(1,number);
for i = 1:number
    % for each i, we count the number of pixels equal to i in the labels
    % matrix
    % first, we create a component image, that is 1 for pixels belonging to
    % the i-th connected component, and 0 everywhere else.
    component_image = (labels == i);
    
    % now, we count the non-zero pixels in the component image.
    counters(i) = sum(component_image(:));
end

% find the id of the largest component
[area, id] = max(counters);    
person = (labels == id);
% display motion detected area
%figure(1); imshow(person, []);

%convert sequencial index to row col indexes.
[row,col] = ind2sub(size(person),find(person > 0))

t = min(row); b = max(row)
l = min(col); r = max(col)

%read image frame and draw bounding box
frame = imread(filename)
frame_with_box = draw_rectangle(frame,[255,255,0], t, b, l, r)

figure; imshow(frame_with_box);



