import numpy as np
import cv2

#Function to retrieve brightness of coins
def av_pix(img,circles,size):
    #iterate through circles to create squares with brightness values in coins
    av_value = []
    for coords in circles[0,:]:
        col = np.mean(img[coords[1]-size:coords[1]+size,coords[0]-size:coords[0]+size])
        #print(img[coords[1]-size:coords[1]+size,coords[0]-size:coords[0]+size])
        av_value.append(col)
    return av_value

#Function for radii of circles
def find_radius(circles):
    #Iterate through circles to create list of radii
    radius = []
    for coords in circles[0,:]:
        radius.append(coords[2])
    return radius

#Import image of coins, grayscale
img = cv2.imread("C:\\Users\\Tyler Simpson\\Downloads\\capstone_coins.png", cv2.IMREAD_GRAYSCALE)
#Import image of coins, color
original_image = cv2.imread("C:\\Users\\Tyler Simpson\\Downloads\\capstone_coins.png", 1)
#Add blur to help avoiding detection of unwanted circles
img = cv2.GaussianBlur(img, (5,5), 0)

#Hough circle transformation
circles = cv2.HoughCircles(img,cv2.HOUGH_GRADIENT,0.9,120,param1=50,param2=27,minRadius=60,maxRadius=120)
print(circles)

#Draw circles over image
circles = np.uint16(np.around(circles))
count=1
for i in circles[0,:]:
    #Draw outer circles
    cv2.circle(original_image,(i[0],i[1]),i[2],(0,255,0),2)
    #Draw center of circles
    cv2.circle(original_image,(i[0],i[1]),2,(0,0,255),3)
    #cv2.putText(original_image, str(count),(i[0],i[1]), cv2.FONT_HERSHEY_SIMPLEX, 2, (0,0,0), 2)
    count += 1

#call brightness function
bright_values = av_pix(img,circles,20)
print(bright_values)

#call radii function
radii = find_radius(circles)
print(radii)

#Threshold brightness and radii to classify coins
values=[]
for a,b in zip(bright_values,radii):
    #appending to value of coin (p)
    if a > 150 and b > 110:
        values.append(10)
    elif a > 150 and b <= 110:
        values.append(5)
    elif a < 150 and b > 110:
        values.append(2)
    elif a < 150 and b < 110:
        values.append(1)
print(values)

count_2 = 0
for i in circles[0,:]:
    #set text of values of coins
    cv2.putText(original_image, str(values[count_2]) + "p",(i[0],i[1]), cv2.FONT_HERSHEY_SIMPLEX, 2, (0,0,0), 2)
    count_2 += 1
    #estimate the total value of coins in image
cv2.putText(original_image, "TOTAL VALUE: " + str(sum(values)) + "p", (200,100), cv2.FONT_HERSHEY_SIMPLEX, 1.3, 255)

#call coin image
cv2.imshow("Coins", original_image)
cv2.waitKey(0)
cv2.destroyAllWindows()
