Ismael Resendiz Robles (i_r174)
A04929062

Assigment 2

Task 1: Remove Holes  C = remove_holes(binary_image)
The function assumes that the background contains a black pixel in (1,1). I returns a binary Image C with no holes.

Tests performed in all binary images in the data zip file attachment of this assigment.


Task 2: Soccer field, blue & red players
Steps to determine the soccer field:
1) Read image read, green and blue subcomponents.
2) Extract most green indexes from the image.
3) Remove holes from previous step image.
4) Use erosion to reduce the noise from step 2.

Steps to determine red players:
1) Extract the red most indexes from the image.
2) Using the previous soccer field image extract only the indexes of step 1) and soccer_field match.
3) Use erosion to smooth resulting image.

Determine blue playes:
same as above but using blue most indexes of the image.


Task 3: Ocean & Sky
Steps to determine the sky:
1) Read image and extract indexes where the values are close to the sky color in the picture(higher than 186).
2) Use erosion to smooth the extraction in previous step.
3) Get the largest connected component.

Steps to determine the ocean
1) Extract the image indexes where values are close to the ocean colors ( >122 & >168 ) Exclude 153 to reduce noise.
2) Use erosion to create holes on the mountains areas where they share similar colors with the ocean.
3) Get the largest connected components [1-4].
4) Join largest components 1,3,4. Exlcude 2.
5) Use blurring to reduce the amount of small holes. 

