function a = person_present(filename)

a = []
fd = 2
[sequence_name, frame] = parse_frame_name(filename)

%End the program if there is no frame to detemrine montion
if (frame - fd) <0 || (frame + fd) > 124 
   return 
end

%Read the frame in gray scale
gray = read_gray(filename)

[sequence_name, frame] = parse_frame_name(filename)

previous_frame_name= make_frame_name(sequence_name, frame - fd)
next_frame_name = make_frame_name(sequence_name, frame + fd)

%read the gray scale of previous and next frames
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

%at least 1500 pixels connected to detrmine a person is present in the frame 
person_threshold = 1500

if(area > person_threshold)
    
    a = 1
else
    a = 0

end
