

%% test find_bounding_box
result = []
for i=[40, 58, 75] 
filename = '../data/walkstraight/frame0000.tif'
[sequence_name, frame] = parse_frame_name(filename)
frame_name= make_frame_name(sequence_name, i)
[t, b, l, r] = find_bounding_box(frame_name)
result = [result; [t, b, l, r] ]
end

%%

%% test person_present
M = containers.Map()
for i=50:51
filename = '../data/walkstraight/frame0000.tif'
[sequence_name, frame] = parse_frame_name(filename)
frame_name= make_frame_name(sequence_name, i)
result = person_present(frame_name)
M(frame_name) = result
end
values(M)
%%

%%test person_speed

speed = person_speed('../data/walkstraight/frame0035.tif', '../data/walkstraight/frame0090.tif')

%%

%% test person_pose

for i=[56 , 78]
filename = '../data/walkstraight/frame0000.tif'
[sequence_name, frame] = parse_frame_name(filename)
frame_name= make_frame_name(sequence_name, i)
result = person_pose(frame_name)
end

%%