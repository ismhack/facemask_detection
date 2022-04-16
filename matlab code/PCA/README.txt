Ismael Resendiz Robles (i_r174)
A04929062

Assignment 7

Task 1: task1.m Computes PCA for training images of digit "2". Displays the top 5 eigenvectors.

Loads the Training('./training_data/') and Test data('./test_data/') and computes PCA symbol 2 variables called eigenvectors2, eigenvalues2, and average2 in the Matlab Workspace. 
This script also computes the 14x14 eigenvectors to be use as part of task 4.
The script expects the training and test paths to exist in the same path where the file is located.
Last sections of this script, I used for testing task 3 and task 4 accuracy and performance.

Task 2: Computes PCA for training images of digit "3". Displays the top 5 eigenvectors.
Loads the Training('./training_data/') and Test data('./test_data/') and computes PCA for symbol 3, variables called eigenvectors3, eigenvalues3, and average3 in the Matlab Workspace. 
This script also computes the 14x14 eigenvectors to be use as part of task 4.
The script expects the training and test paths to exist in the same path where the file is located.
Last sections of this script, I used for testing task 3 and task 4 accuracy and performance.


Task 3: Recognize Digit with PCA
function Signature
[row, col, score] = pca_detect_digit(image, mean_digit, eigenvectors, N)

Input params: The function expects a gray scale image, a mean of digit "2" or "3" and the corresponding eigenvector matrix, and N number of eigenvectors to use. 
Testing: Used all test images and the function has an accurate rate of 100% (Recognizes 40 images out of 40). Average time taken per image is 0.3 seconds.

Task 4: Recognize Digit with PCA - Fast version
Function signature
[row, col] = fast_pca_detect_digit(image, mean_digit, eigenvectors1, eigenvectors2, N)

Input params: The function expects a gray scale image, a mean of digit "2" or "3" and the corresponding eigenvector matrix, N number of eigenvectors to use, and 14x14 eigenvectors matrix.
Similarly than task3, the function iterates through all the possible windows of the reduced mean of size(14x14), identifying the first 5 minimum scores and window areas. Then, pca_detect_digit function is invoked on the areas previously identified (5) which increases the processing speed noticeable and taking the lowest score as result. 
Testing: Used all test images and the function has an accurate rate of 100% (Recognizes 40 images out of 40) in some cases the bounding box is not 100 centered as in previous task. By running detection on a resized image the accuracy of the algorithm may be reduced. Average time taken per image is 0.08 seconds. 