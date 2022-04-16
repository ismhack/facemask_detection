function [evaluations, thresholded] = evaluate_cascade(test_data, boosted_classifiers,weak_classifiers, threshold )

evaluations = zeros(size(test_data,3),size(boosted_classifiers,2)) -1;
thresholded = zeros(size(test_data,3),size(boosted_classifiers,2));
 for i =1: size(test_data,3)
    upto=1;
    response=0;
    for j = 1:size(boosted_classifiers,2)
        boosted = boosted_classifiers(j);
        linear_size = size(boosted,1);
        for weak_classifier = upto:linear_size
            classifier_index = boosted.classifiers(weak_classifier, 1);
            classifier_alpha = boosted.classifiers(weak_classifier, 2);
            classifier_threshold = boosted.classifiers(weak_classifier, 3);
            classifier = weak_classifiers{classifier_index};
            response1 = eval_weak_classifier(classifier, test_data(:,:,i));
            if (response1 > classifier_threshold)
                response2 = 1;
            else
                response2 = -1;
            end
            response = response + classifier_alpha * response2;
        end
        upto = linear_size +1;
            
        evaluations(i, j) = response;
    end
 end

for i = 1:size(boosted_classifiers,2)

        thresholded(:, i) = evaluations(:,i) > threshold(i); 
end

end