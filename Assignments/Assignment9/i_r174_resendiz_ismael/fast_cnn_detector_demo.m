function [result, boxes] = fast_cnn_detector_demo(image, scales, model, face_filter, result_number)

result = find_template(image, face_filter, scales, 1, 10);

result = sortrows(result, 5, 'descend','ComparisonMethod','real');

[rows, cols] = size(image);
[trows, tcols] = size(face_filter);
window = zeros(trows, tcols);
boxes = zeros(result_number,6);

for i = 1:10

    window = image(result(i,1):result(i,2), result(i,3): result(i,4));
    score = model.predict(window);
    result(i,6) = score(2);
end


for i = 1:result_number
    image = draw_rectangle1(image, result(i,1), result(i,2), result(i,3), result(i,4));
    boxes(i,:) = result(i,:);
end
result =  image;