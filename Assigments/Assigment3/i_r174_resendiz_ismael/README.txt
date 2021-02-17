Ismael Resendiz Robles (i_r174)
A04929062

Assigment 3

Task 1: Oriented Edges  result_img = oriented_edges(img, sigma, threshold, direction, tolerance)
The function that takes in as an argument a color or grayscale image (that is a matrix of pixel values)
and returns an image that shows edge pixels with a certain orientation

Steps to determine the oriented edges
1) Apply Canny algorithm on the input image with the specified parameters
2) Extract the angles from the resulting image in step 1
3) Rotate angles 90 degrees and normalize to 0 - 180 degrees only
4) Calculate threshold angles based on the direction and tolerance parameters
5) Filter image where angles are within the threshold
6) Return image
Tests performed with frame0040.tif.


Task 2: Road orientation angle = road_orientation(image)
The function called  that takes as input a grayscale image (matrix of pixel values) of a straight road, and returns, as output, the orientation of that road in degrees
Steps to determine road angle
1) Same steps from task 1 but considering all edges and angles
2) Calculate connected components on 8 points
3) Apply close filter to reduce holes
4) Calculate the distance for all the connected components from the first pixel location
5) Get the greatest distance (component which have pixels far apart)
6) Extract angles of the component in step 5
6) return the average of that component angles
Tests performed with road1 - road9 sample data.

Task 3: Road orientation figure = road_orientation_figure(image)
Function that produce a figure showing the location of the road with a straight line going along the center of the road
Steps to determine road angle figure
1) Same than task 2
2) Determine coordinates of the two most separate pixels in distance
3) Plot the line crossing those 2 points
4) Return figure