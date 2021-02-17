function speed = person_speed(filename1, filename2)

[sequence_name1, frame1] = parse_frame_name(filename1)
[sequence_name2, frame2] = parse_frame_name(filename2)


%End the program if there is no frame to detemrine montion
if (frame1  <0) || (frame1 > 124) || (frame2  <0) || (frame2 > 124) 
   return 
end

%calculate person boundaries
[t1, b1, l1, r1] = find_bounding_box(filename1)
[t2, b2, l2, r2] = find_bounding_box(filename2)
time = abs(frame1 - frame2)

C = abs([t1, b1, l1, r1] - [t2, b2, l2, r2] )/time

%distance_left = abs(l1 - l2)
%distance_right = abs(r1 -r2)
%distance_top = abs(t1 -t2)
%distance_bottom = abs(b1 -b2)
%speed = mean( (distance_left/time), (distance_rigth/time), (distance_top/time). (distance_bottom/time))

speed = mean(C)
