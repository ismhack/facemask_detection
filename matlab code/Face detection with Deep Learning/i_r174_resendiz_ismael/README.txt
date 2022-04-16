Ismael Resendiz Robles (i_r174)
A04929062

Assignment 9

Task 1: Train and evaluate a convolutional neural network (CNN)
Description: Loads the faces1000.mat and nonfaces1000.mat, combines the dataset, shuffles and split 70-30 for training and testing respectively.
Training of the CNN, which contains of 3 Convolutional layers. The first layer contains a filter size [3 3] sequenced by a batch normalization layer, a 
Relu activation layer and a max pooling with 2 pixel stride. Next, two layers contain the same structure than the first, except that the filter in the
Convolutional layer is [2 2] and the third group does not contain a max pooling. After the third convolution group, the network has a set of fully connected 
layes starting with 32, 16 and 2 neurons. The network ends with a softmax and a classification layer. The network was trained with 6 epochs and an initial 
learning rate 0f 0.01. The training accuracy obtained is 99.3% and 98.7% for testing.


Task 2: function cnn_detector_demo
Function signature: 
[result, boxes] = cnn_detector_demo(image, scales, model, face_size, result_number)
Returns: result is the original image with a bounding box of the detected faces. Boxes are the top, bottom, left and right points to draw the bounding boxes.

Description: Detect if there exists faces in a given gray scale image, and returns an image with the bounding box of the faces detected.

Test: Tested with file vjm.bmp and is able to detect the 3 faces shown in ~ 92 seconds. 

Task 3: function fast_cnn_detector_demo
Function signature: [result, boxes] = fast_cnn_detector_demo(image, scales, model, face_filter, result_number)
Returns: result is the original image with a bounding box of the detected faces. Boxes are the top, bottom, left and right points to draw the bounding boxes.
Description: Uses template matching to detect faces in the image. Such like in the assignment 6, it look all windows of size of the face_filter in the image and evaluates if there
is a face by calculating the normalized correlation. The template search takes the 10 best results and input them into the CNN model to evaluate the accuracy of the of these windows.
This approach improved the performance of task 2 noticeable by allowing face detection in less than a second and the same accuracy.
This method does not take the face_size parameter, but the face_filter template provided in the assignment.
