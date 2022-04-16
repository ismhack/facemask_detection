function digit = recognize_digit(image, average2, average3)

resultWith2 = normalized_correlation(image, average2);
resultWith3 = normalized_correlation(image, average3);

maxVal2 = max(resultWith2(:));
maxVal3 = max(resultWith3(:));

%fprintf('value of 2: %.4f -  value of 3: %.4f \n',maxVal2, maxVal3);

if( vpa(maxVal2) > vpa(maxVal3))
    digit = 2;
else
    digit = 3;
end
