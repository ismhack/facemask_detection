function [row, col, result] = fast_pca_detect_digit(image, mean_digit, eigenvectors1, eigenvectors2, N)

% original size
[rows, cols] = size(image);
[trows, tcols] = size(mean_digit);

% resized 
image2 = imresize(image, [rows, cols]/2, 'bilinear');
mean_digit2 = imresize(mean_digit, [trows, tcols]/2, 'bilinear');
[rows2, cols2] = size(image2);
[trows2, tcols2] = size(mean_digit2);
window = zeros(trows2, tcols2);

preliminary_results = zeros(rows2*cols2, 3) + realmax;
for i = 1:rows2
    for j = 1:cols2
        xrow = i + trows2 -1;
        ycol = j + tcols2 -1;
        if xrow <= rows2 && ycol <= cols2
            window = image2(i: xrow, j: ycol);
            %figure(1); imshow(reshape(window, [trows, tcols]), []);
            temp = pca_score(window, mean_digit2, eigenvectors2, N);
            %fprintf('Checking window row:%d-%d  col:%d-%d,  result:%f.2 \n',i, xrow,j, ycol, temp);
            
             
               preliminary_results(i*j, 3) = temp;
               preliminary_results(i*j, 1) = ceil((i + xrow)/2);
               preliminary_results(i*j, 2) = ceil((j + ycol)/2);
           
        end
    end
end

A = sortrows(preliminary_results, 3);

%figure(1); imshow(draw_rectangle2(image2, preliminary_results(1,1), preliminary_results(1,2), trows2, tcols2), []);

B = A(1:5,:);
row=0;
col=0;
% restore center
result = realmax;
for i=1:5  
x = B(i,1)*2;
y = B(i,2)*2;
window = image(x - (trows/2):x + (trows/2) -1, y - (tcols/2):y + (tcols/2) -1);
[w, z, temp] = pca_detect_digit(window,mean_digit,eigenvectors1, N);
 if(temp < result)
     result = temp;
     row = x;
     col = y;
 end
end

