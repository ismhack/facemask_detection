%
% Function expectes an edge image
%

function [scores, result_image] = chamfer_search(edge_image, template, scale, number_of_results)

template = template >0;
if scale >= 1
    scaled_image = imresize(edge_image, 1/scale, 'bilinear');
else
    scaled_image = edge_image;
    template = imresize(template, scale, 'bilinear');
end

result_image = scaled_image;

%[thetas, e1]= canny4(scaled_image,1.4,1, 7, 14);
resized_dt = bwdist(scaled_image);

chamfer_scores = imfilter(resized_dt, double(template), 'symmetric');
scores = chamfer_scores;
[rows, cols] = size(chamfer_scores);
[h,w] = size(template);
h2 = floor(h/2);
w2 = floor(w/2);

for i = 1:number_of_results
    [minVal, index] = min(chamfer_scores(:));
    [r,c] = ind2sub(size(chamfer_scores),index);
    fprintf('Minimum value = %f at (r,c)=(%d,%d)\n', minVal, r,c);
    if((r-h2) <0)
        h0 = 1;
    else
        h0 = r-h2;
    end
    if ((r+h2) > rows)
        h1 = rows;
    else
        h1 = (r+h2);
    end
    
    if((c- w2) < 0)
        w0 = 1;
    else
        w0 = (c- w2);
    end
    
    if((c+ w2) > cols)
        w1 = cols;
    else
        w1 = (c +w2);
    end
    chamfer_scores(h0:h1,w0:w1) = realmax;
    result_image = draw_rectangle2(result_image, r, c, h,w);
end

result_image = logical(result_image);

%figure(4); imshow(result_image);


