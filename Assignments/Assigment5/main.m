clear; close all;
% compute chamfer scores for a specific scale
scale = 0.95;
template = read_gray('template.gif');
image = read_gray('clutter1.bmp');
%resized = imresize(image, s, 'bilinear');

if scale >= 1
    scaled_image = imresize(image, 1/scale, 'bilinear');
    %temp_result = imresize(temp_result, size(image), 'bilinear');
else
    scaled_image = image;
    template = imresize(template, scale, 'bilinear');
end

[thetas, e1]= canny4(scaled_image,1.4,1, 7, 14);
resized_dt = bwdist(e1);

chamfer_scores = imfilter(resized_dt, double(template), 'symmetric');
[rows, cols] = size(chamfer_scores);
[minVal, index] = min(chamfer_scores(:));
[r,c] = ind2sub(size(chamfer_scores),index);

[h,w] = size(template);
h2 = floor(h/2);
w2 = floor(w/2);
        % Get edge points from template
% Width and height of template
%[rows,cols] = find(t1);
%rows = rows - (h2+1) + r;
%cols = cols - (w2+1) + c;
%figure(3);
%hold on
%plot(cols,rows,'r.');

for i = 1:5
    [minVal, index] = min(chamfer_scores(:));
    [r,c] = ind2sub(size(chamfer_scores),index);
    fprintf('Minimum value = %f at (r,c)=(%d,%d)\n', minVal, r,c);
    if((r-h2) <0)
        h0 = 0;
    else
        h0 = r-h2;
    end
    if ((r+h2) > rows)
        h1 = rows;
    else
        h1 = (r+h2);
    end
    
    if((c- w2) < 0)
        w0 = 0;
    else
        w0 = (c- w2);
    end
    
    if((c+ w2) > cols)
        w1 = cols;
    else
        w1 = (c +w2);
    end
    chamfer_scores(h0:h1,w0:w1) = realmax;
    image = draw_rectangle2(image, r, c, h,w);
end

figure(4); imshow(image, []);

%% Evaluation
template = read_gray('template.gif');
color_image = double(imread('clutter1.bmp'));
[thetas, edge_image]= canny4(read_gray('clutter1.bmp'),1.4,1.35, 7, 14);

tic; [scores, result_image] = skin_chamfer_search(color_image, edge_image, template, 1, 3); toc;

figure(4); imshow(result_image, []);


%% Eval without skin

template = read_gray('template.gif');
[thetas, edge_image]= canny4(read_gray('clutter1.bmp'),1.4,1.35, 7, 14);

tic; [scores, result_image] = chamfer_search(edge_image, template, 1, 3); toc;

figure(4); imshow(result_image, []);

