Ismael Resendiz Robles (i_r174)
A04929062

Assigment 1

Task 1: Find Boxing Boundaries  [t, b, l, r] = find_bounding_box('walkstraight/frame0052.tif')
This function displays the bounding box when invoking it. It was tested with all frames, but works perfectly on frames 20 - 110.

Task 2: Person Present result = person_present('walkstraight/frame0052.tif')
This function returns 1 if the person is present in the frame and 0 otherwise.
The following are the steps to determine if the person is present or no
1) The function reads (if exists) the given file in gray scale, a previous sequence frame (i - 2) and a next frame sequence (i + 2),
2) Take the absolute differences from current with previous and next frames, and calculates the min of those 2 differences.
3) The min matrix values calculated are filtered with a threshold of 10 ( same than in the task 1 seen in class).
4) Caluculate the connected components in 8 directions. 
5) List the number of connected components(pixels) and assign a label. Then take the max element of the list.
6) The person detection is based on the number of pixeles found in the largest connected component from step 5)
  if the component has over 1500 pixels then the function returns 1, 0 otherwise.
  
Tests performed on this function shows to determine the person presence in frames 20-110 and not present in frame 0-19, 111-124.

Task 3: Person Speed speed = person_speed(filename1, filename2)
The function returns the average speed of pixels per frame.
following are the steps to determine the person speed:
1) Find the bounding boxes of both files calling the function in task 1
2) Calculate the distance of both bouding box (top1 -top2, bottom1-bottom2, etc...)
3) Calculate absolute frame difference between the two files (time)
4) Divide the distance from step 2 (D\time) over the time.
5) Calculate the mean (average) of previous step and return it.

Tests performed on this method shows that an average speed of 2 pixels per frame in the frames 35 - 90.

Task 4: Person Pose pose = person_pose(filename)
The function returns 1 when the person legs are extended otherwise 2. Also display the Pose category in the frame.
Based on the analisys  that if the legs are extended(POSE 1) the area of the rectangle is larger for almost
double thant when they are not extended (POSE 2). To simplify this, the left and right boundary box borders difference is for
about 40 pixels when completely extended legs compared when the legs are together. In the function, the threshold to identify POSE 1 
the pixel difference is at least 60 pixels else is POSE 2. I choosed 60 as threshold since any value greater than that the legs
are visually extended.

Tests performed on frames 48, 67, and 84 = POSE 1; frames 40, 58, 75, 56  78  = POSE 2;  
