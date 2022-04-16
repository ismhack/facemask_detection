Ismael Resendiz Robles (i_r174)
A04929062

Assignment 6

Task 1: task1.m computes an average two-image and an average three-image

Loads the Training('./training_data/') and Test data('./test_data/') and calculates the average of each image with symbol 2 and 3 in variables called average2 and average3 in the Matlab Workspace.
The script expects the training and test paths to exist in the same path where the file is located.
Last sections of this script, I used for testing task 2 and task 3 accuracy and performance.

Task 2: Detect Digit 
Function Signature
[row, col] = detect_digit(image, template)

Input params: The function expects a gray scale image and a template ( previously calculated in task 1).

Testing: Used random test images, the function correctly returned the location of the best matching position and it shows the original image, with a white 28x28 bounding box drawn centered on the best-matching position.

Task 3: Recognize Digit 
function Signature
digit = recognize_digit(image, average2, average3)

Input params: The function expects a gray scale image and a template for symbol 2 and 3 respectively. ( previously calculated in task 1).

Testing: Used all test images and the function has an accurate rate of 82.5% (Recognizes 33 images  out of 40), failing to recognize images that are slightly rotated or enlarged. 