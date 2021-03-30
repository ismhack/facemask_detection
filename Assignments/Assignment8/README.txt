Ismael Resendiz Robles (i_r174)
A04929062

Assignment 8

Task 1: function central_moment
Function Signature: 
result = central_moment(shape, i, j)
Description: Computes central moments i,j based on muij=Sum( (x-xc)^i * (y-yc)^j *I(x,y))

Task 2: function normalized_moment
Function signature: 
result = normalized_moment(shape, i, j)
Description: Computes normalized moments i,j based on nij= muij / (mu00^(1 + (i + j)/2)) for (i+j)>=1 else nij = muij / mu00

Task 3: function hu_moment
Function signature:
result = hu_moment(shape, m)
Description: Computes hu moment m based on the lecture formulas.

Task 4: Function classify_digit using central moments
Function signature:
result = classify_digit_cm(digit)

Input params: The function expects a binarized image(digit).
Description: The function computes the first 3 order central moments mu(0,0)-mu(1,1)-mu(2,0)-mu(1,2)-mu(0,2)-mu(2,1)-mu(3,0)-mu(0,3)
(These moments showed the best results of my testing) for first 5000 nmist_digits(binarized threshold >0) and stores it in a local file 'central_moments.txt',
so it does not process every time the function gets called.
Then, the digit image is binarized with a threshold greater than 0 and calculates the digit moments specified earlier.

The function checks each of the 5000 images moments against the digit image moment using the Euclidian distance, determines the smaller
distance and its corresponding label.

Output: classified label.

Test Results:

Tested with mnist_digits(5000:10000), and obtained an accuracy percentage of 72.5%. Below is the confusion matrix.

357	6	17	10	9	36	4	1	60	3
1	529	4	6	2	6	4	2	5	2
14	1	351	59	15	23	36	8	14	3
9	4	41	347	1	31	1	26	19	20
5	13	8	3	344	19	8	9	13	62
37	7	19	29	28	232	13	3	81	14
6	2	18	3	4	7	444	0	6	0
3	2	4	18	7	1	0	395	9	67
50	9	22	16	12	77	5	12	267	21
1	2	1	9	42	10	1	51	14	348

Note, the function expects the path './nmist_data' in the same folder where the function file is located.


Task 5: Function classify_digit using normalized moments
Function signature:
result = classify_digit_nm(digit)

Input params: The function expects a binarized image(digit).
Description: The function computes the first 3 order normalized moments n(0,0)-n(1,1)-n(2,0)-n(1,2)-n(0,2)-n(2,1)-n(3,0)-n(0,3)
(These moments showed the best results of my testing) for first 5000 nmist_digits (binarized threshold >0) and stores it in a local file 'normalized_moments.txt',
so it does not process every time the function gets called.
Then, the digit image is binarized with a threshold greater than 0 and calculates the digit moments specified earlier.

The function checks each of the 5000 images moments against the digit image moment using the Euclidian distance, determines the smaller
distance and its corresponding label.

Output: classified label.

Test Results:

Tested with mnist_digits(5000:10000), and obtained an accuracy percentage of 65.4%. Below is the confusion matrix.

356	1	34	13	13	49	5	0	28	4
0	538	4	4	0	7	6	0	2	0
42	3	269	70	12	48	60	4	14	2
22	8	50	289	6	51	4	27	29	13
22	0	13	2	248	50	11	15	50	73
59	4	25	42	42	206	5	5	59	16
9	6	35	2	6	7	417	0	8	0
2	4	7	24	19	6	0	361	10	73
45	2	12	42	30	44	3	6	273	34
3	1	2	6	63	16	0	47	30	311

Note, the function expects the path './nmist_data' in the same folder where the function file is located.


Task 6: Function classify_digit using HU moments
Function signature:
result = classify_digit_hu(digit)

Input params: The function expects a binarized image(digit).
Description: The function computes the 7 HU moments for first 5000 nmist_digits (binarized threshold >0) and stores it in a local file 'hu_moments.txt',
so it does not process every time the function gets called.
Then, the digit image is binarized with a threshold greater than 0 and calculates the digit moments specified earlier.

The function checks each of the 5000 images moments against the digit image moment using the Euclidian distance, determines the smaller
distance and its corresponding label.

Output: classified label.

Test Results:

Tested with mnist_digits(5000:10000), and obtained an accuracy percentage of 37.3%. Below is the confusion matrix.

238	0	39	64	25	68	6	2	48	13
0	533	3	2	0	4	1	6	6	6
29	1	101	82	65	61	54	56	24	51
37	2	81	126	32	94	22	16	63	26
27	0	60	32	95	26	67	60	54	63
60	8	63	87	23	92	19	34	52	25
7	2	58	25	68	26	126	45	39	94
5	5	46	10	61	35	41	245	11	47
42	0	48	68	39	35	24	15	172	48
10	2	49	27	59	19	95	46	37	135

Note, the function expects the path './nmist_data' in the same folder where the function file is located.

