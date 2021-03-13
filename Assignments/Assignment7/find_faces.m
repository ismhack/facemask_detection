function result = find_faces(image, scales, rotations, result_number, eigenface_number)

% function result = find_faces(image, scales, rotations, result_number, eigenface_number)
%
% first, find_faces identifies, for every position in the image, the 
% scale and rotation that maximize the normalized correlation with the
% average face. Then, the top results are re-ranked based on how well they
% match the top eigenfaces.

load face_filter;
load final_eigens;

[image_rows, image_columns] = size(image);

max_responses = ones(size(image)) * -10;
max_scales = ones(size(image)) * -10;

for rotation = rotations
    rotated = imrotate(face_filter, rotation, 'bilinear', 'crop');
    [responses, max_scales] = multiscale_correlation(image, rotated, scales);
    higher_maxes = (responses > max_responses);
    max_scales(higher_maxes) = max_scales(higher_maxes);
    max_responses(higher_maxes) = responses(higher_maxes);
end

preliminary_number = 50;
preliminary_results = zeros(preliminary_number, 8);
number = 1;
while number <= preliminary_number
    [value, vertical, horizontal] = image_maximum(max_responses);
    result_scale = max_scales(vertical, horizontal);
    box = make_bounding_box(vertical, horizontal, round(result_scale * size(face_filter)));
    
    top = max(box(1),1);
    bottom = min(box(2), image_rows);
    left = max(box(3), 1);
    right = min(box(4), image_columns);
    preliminary_results(number, 1:4) = [top, bottom, left, right];
    window = image(top:bottom, left:right);
    preliminary_results(number, 5) = value;
    preliminary_results(number, 6) = std(window(:));
    preliminary_results(number, 7) = pca_score(window, mean_face, eigenvectors, eigenface_number);

    % some threshold to eliminate uniform-texture areas
%    if (result(number, 6) > 15)
%        number = number+1;
%    end
    max_responses(top:bottom, left:right) = -1;
    number = number+1;
end

[values, indices] = sort(preliminary_results(:, 7), 'ascend');
top_indices = indices(1: result_number);
result = preliminary_results(top_indices, :);

