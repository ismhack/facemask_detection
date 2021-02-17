function pose = person_pose(filename)


%calculate person boundaries
[t, b, l, r] = find_bounding_box(filename)

%if the legs are extended(POSE 1) the area of the rectangle is larger for almost
%double. To simplify this the left and right borders difference are for
%about 40 pixels everything less than that is POSE 2

if abs(l-r) <60
    txt = 'POSE 2 \downarrow';
    pose = 2
else
    txt = 'POSE 1 \downarrow';
    pose = 1
end

t = text(l +r /2,t-10,txt,'HorizontalAlignment','right')
t.FontSize = 14; t.Color = [1,0,0] 