function [current_error, result , best_error] = optimize_cascade(responses, error_rate)


minVal = min(responses(:));
maxVal = max(responses(:));
step = (maxVal -minVal)/70;
result = 0;
best_error = size(responses(responses < 0 ),1);
current_error = best_error;
max_errors = floor(size(responses,1) * error_rate);

for threshold = maxVal:-step:minVal
    %evaluations = evaluate(size(responses,2), boosted_classifiers, responses, threshold);
    error = size(responses(responses <= threshold ),1);
    if( error > max_errors )
        if (error < best_error)
            best_error = error;
            result = threshold;
        end
    else
        break;
    end
end

end
