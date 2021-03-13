%% PATH setup
addpath './training_data/';
addpath './test_data/';
load_mnist;
%% calc averages
[rows, cols, number] = size(mnist_digits) 
total2 = zeros(rows, cols);
total3 = zeros(rows, cols);
total2_count =0;
total3_count =0;
for i = 1:1:number
    image = mnist_digits(:,:,i);
    label = mnist_labels(i); 
    if label == 2
        total2 = total2 + image;
        total2_count = total2_count +1;
    end
    if label == 3
        total3 = total3 + image;
        total3_count = total3_count +1;
    end
end

average2 = total2 / total2_count;
average3 = total3 / total3_count;


%% TEST detect digit
test = read_gray('test40.bmp');
[row, col] = detect_digit(test, average3);

%% TEST recognize digit all test data
correct =0;
wrong=0;
for i = 1:40
    test = read_gray(['test' num2str(i,'%d') '.bmp']);
    digit = recognize_digit(test, average2, average3);
    if( i < 20)
        if( digit == 2)
            correct = correct +1;
        else
            wrong = wrong + 1;
            fprintf('failed test%d.bmp \n',i);
        end
    else
         if( digit == 3)
            correct = correct +1;
        else
            wrong = wrong + 1;
            fprintf('failed test%d.bmp \n',i);
         end
    end

end

fprintf('recognize_digit: Correct %d - Failed: %d - Accuracy: %.2f ', correct,wrong, (correct/40)* 100);
%%

