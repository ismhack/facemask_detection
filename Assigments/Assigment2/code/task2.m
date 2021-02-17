image = imread('../data/soccer_field4.jpg')
color = double(image);
%figure(1); imshow(color/255);
r = color(:,:, 1);
g = color(:,:, 2);
b = color(:,:, 3);

%%
green = ((g - r > 10) & (g - b > 0));
field = imerode(remove_holes(green), [0,1,0; 1,1,1; 0,1,0])
figure(1); imshow(field);

%%
red = ((r - g > 10) & (r - b > 10)) 
red_players = imerode((red & soccer_field),[0,1,0; 1,1,1; 0,1,0])
figure(2); imshow(red_players);

%%
blue = ((b - g > 10) & (b - r > 10))
blue_players = imerode((blue & soccer_field),[0,1,0; 1,1,1; 0,1,0])
figure(3); imshow(blue_players);