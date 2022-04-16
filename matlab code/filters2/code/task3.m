image = imread('../data/ocean2.jpg')
%figure(1); imshow(image);
%%
sky = (image > 186)
sky = imerode(sky, [0,1,0; 1,1,1; 0,1,0])
sky = get_component(sky, 1)
figure(2); imshow(sky);
%%
ocean = (image > 122 & image < 168 & image ~= 153)
ocean = imerode(ocean, [0,0,0; 0,1,0; 1,0,1])
rest1 = get_component(ocean, 1)
rest2 = get_component(ocean, 2)
rest3 = get_component(ocean, 3)
rest4 = get_component(ocean, 4)
%figure(4); imshow(rest2)
%figure(5); imshow(rest3)
%figure(6); imshow(rest4)
ocean = imdilate(rest1 | rest3 | rest4,[0,1,0; 0,1,0; 1,0,1])
figure(3); imshow(ocean);