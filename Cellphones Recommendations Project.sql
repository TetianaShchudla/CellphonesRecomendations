-- Let`s look at a list of 10 most pricey cellphones

SELECT TOP 10
	cd.brand, cd.model, cd.[internal memory], cd.price
FROM PhonesRecommendations..CellphonesData AS cd
ORDER BY cd.price DESC

-- What cellphone models include more than 128GB of the internal memory as well as their price are below $500?

SELECT cd.model, cd.[internal memory], cd.price
FROM PhonesRecommendations..CellphonesData AS cd
WHERE cd.[internal memory] >= 128 AND cd.price <= 500
ORDER BY cd.price 

-- What 5 most recent released models and their price includes the battery size from 4500 to 5000 (including)?

SELECT TOP 5
	cd.model, cd.[battery size], cd.[release date]
FROM PhonesRecommendations..CellphonesData AS cd
WHERE cd.[battery size] BETWEEN 4500 AND 5000 
ORDER BY cd.[release date]

-- Joining 2 tables for receiving the answer to the question: what cellphone models are the highest rated (above 6.5 point) with the Android operating system?

SELECT cd.model, AVG(cr.rating) AS 'average rating'
FROM PhonesRecommendations..CellphonesData AS cd
JOIN PhonesRecommendations..CellphonesRatings AS cr
ON cd.cellphone_id =cr.cellphone_id
WHERE cd.[operating system] LIKE 'Android'
GROUP BY cd.model, cd.[operating system]
HAVING AVG(cr.rating) >= 6.5
ORDER BY AVG(cr.rating) DESC

-- What average ratings are for Google and Sony brands of cellphones?

SELECT cd.brand, AVG(cr.rating) AS 'average rating'
FROM PhonesRecommendations..CellphonesData AS cd
JOIN PhonesRecommendations..CellphonesRatings AS cr
ON cd.cellphone_id =cr.cellphone_id
WHERE cd.brand LIKE 'Google' OR cd.brand LIKE 'Sony'
GROUP BY cd.brand

-- Creating a new column which summarise the industry of users

ALTER TABLE CellphonesUsers
ADD Industry nvarchar(255);

UPDATE CellphonesUsers
SET Industry = 
    CASE
		WHEN occupation IN ('IT', 'it', 'Information Technology', 'software developer', 'Computer technician', 'Technical Engineer', 'WEB DESIGN', 'team worker in it', 'ICT Officer', 'QA Software Manager', 'information', 'System Administrator', 'Data analyst') THEN 'Information Technology'
		WHEN occupation IN ('Accountant', 'FINANCE', 'accountant', 'banking', 'Security', 'Finance') THEN 'Finance'
		WHEN occupation IN ('SALES MANAGER', 'Purchase Manager', 'Sales', 'business', 'Executive Manager', 'retail', 'Warehousing', 'Ops Manager') THEN 'Sales'
		WHEN occupation IN ('Administrative officer', 'Administration', 'Administrator') THEN 'Administration'
		WHEN occupation IN ('Education', 'EDUCATION', 'teacher') THEN 'Education'
		WHEN occupation IN ('Transportation', 'president transportation company') THEN 'Transportation'
		WHEN occupation IN ('HEALTHCARE','HEALTHARE', 'Healthcare', 'nurse') THEN 'Healthcare'
		ELSE 'Other'
	END 

-- Let`s look if our new column was created 

SELECT *
FROM PhonesRecommendations..CellphonesUsers

-- Choosing the unique values of a 'gender' column and identifying the issue (except 'male' and 'female' options, there is '-Select Gender-' one which should be removed further from our dataset) 

SELECT DISTINCT cu.gender
FROM PhonesRecommendations..CellphonesUsers as cu

-- Let`s join all tables into one filtering only the appropriate selection from the 'gender' column - the result is 960 clean rows

SELECT cd.brand, cd.model, cd.[operating system], cd.[internal memory], cd.[screen size], cd.[selfie camera], cd.weight, cd.performance, cd.price, cd.[release date], cr.rating, cu.gender, cu.age, cu.occupation
FROM PhonesRecommendations..CellphonesData AS cd
JOIN PhonesRecommendations..CellphonesRatings AS cr
ON cd.cellphone_id =cr.cellphone_id
JOIN PhonesRecommendations..CellphonesUsers AS cu
ON cr.user_id = cu.user_id
WHERE cu.gender IN ('Male', 'Female')

-- What is the number of female users of the Apple brand?

SELECT cd.brand, COUNT(cu.gender) AS 'Apple female users'
FROM PhonesRecommendations..CellphonesData AS cd
JOIN PhonesRecommendations..CellphonesRatings AS cr
ON cd.cellphone_id =cr.cellphone_id
JOIN PhonesRecommendations..CellphonesUsers AS cu
ON cr.user_id = cu.user_id
WHERE cu.gender LIKE 'Female' AND 
	  cd.brand LIKE 'Apple'
GROUP BY cd.brand

-- What 3 models of Cellphones are the most popular between users at the age of 25-40 who work in IT?

SELECT TOP 3
	cd.model
FROM PhonesRecommendations..CellphonesData AS cd
JOIN PhonesRecommendations..CellphonesRatings AS cr
ON cd.cellphone_id =cr.cellphone_id
JOIN PhonesRecommendations..CellphonesUsers AS cu
ON cr.user_id = cu.user_id
WHERE cu.Industry LIKE 'Information Technology' AND
	  cu.age BETWEEN 25 AND 40
GROUP BY cd.model
ORDER BY COUNT(cd.model) DESC

-- What ratings are for 2 least popular brands according to the recommendation of the males who work in Finance?

SELECT TOP 2
	cd.brand, AVG(cr.rating) AS 'average rating'
FROM PhonesRecommendations..CellphonesData AS cd
JOIN PhonesRecommendations..CellphonesRatings AS cr
ON cd.cellphone_id =cr.cellphone_id
JOIN PhonesRecommendations..CellphonesUsers AS cu
ON cr.user_id = cu.user_id
WHERE cu.Industry LIKE 'Finance' AND
	  cu.gender LIKE 'Male'
GROUP BY cd.brand
ORDER BY COUNT(cd.model), AVG(cr.rating)

-- What price of the most expensive Cellphone between the users working in Sales? 

SELECT TOP 1
       cd.brand, cd.model, AVG(cd.price) AS price
FROM PhonesRecommendations..CellphonesData AS cd
JOIN PhonesRecommendations..CellphonesRatings AS cr
ON cd.cellphone_id =cr.cellphone_id
JOIN PhonesRecommendations..CellphonesUsers AS cu
ON cr.user_id = cu.user_id
WHERE cu.Industry LIKE 'Sales' 
GROUP BY cd.brand, cd.model
ORDER BY AVG(cd.price) DESC
