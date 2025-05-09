--Q99 - v_active_employees
Create VIEW v_active_employees AS
SELECT COUNT(*) AS active_employees
FROM Employees
WHERE Attrition IS NULL OR Attrition =  0 ;

--Q99 - vw_recent_hires_last_30_days
ALTER VIEW vw_recent_hires_last_30_days AS
WITH max_hire AS (
    SELECT MAX(Date_of_Joining) AS max_hire_date
    FROM [Employment Details]
)
SELECT 
    COUNT(*) AS recent_hires_last_30_days
FROM 
    [Employment Details]
    CROSS JOIN max_hire
WHERE 
    Date_of_Joining >= DATEADD(DAY, -30, max_hire.max_hire_date);

--•	Q1: Hiring Trend Over Time (Year – Quarter – Month – Weekday)
ALTER VIEW VW_Hiring_Trend_By_Date AS
SELECT 
    Date_of_Joining,
    YEAR(Date_of_Joining) AS Year,
    MONTH(Date_of_Joining) AS Month,
    DATENAME(Quarter, Date_of_Joining) AS Quarter,
    DATENAME(weekday, Date_of_Joining) AS Weekday,
    COUNT(Emp_ID) AS Number_of_Hires
FROM 
    dbo.[Employment Details]
WHERE 
    Date_of_Joining IS NOT NULL
GROUP BY 
    Date_of_Joining;

--•	Q4: Total New Hires (This Year)
ALTER VIEW VW_Total_New_Hires_Latest_Year AS
SELECT 
    Year_of_Joining,
    COUNT(Emp_ID) AS Total_New_Hires
FROM 
    dbo.[Employment Details]
WHERE 
    Year_of_Joining = (SELECT MAX(Year_of_Joining) FROM dbo.[Employment Details])
GROUP BY 
    Year_of_Joining;

--•	Q5: Percentage Increase/Decrease in Hiring (YOY)(Growth Rate)
ALTER VIEW vw_HiringGrowth2017 AS
SELECT 
    CurrentYearHires,
    AvgHires,
    (CurrentYearHires - AvgHires) AS Diff,
    ((CurrentYearHires - AvgHires) / AvgHires) AS GrowthPercentage
FROM (
    SELECT 
        (SELECT COUNT(Emp_ID)
         FROM [Employment Details]
         WHERE YEAR(Date_of_Joining) = 2017) AS CurrentYearHires,

        (SELECT AVG(Hires)
         FROM (
             SELECT COUNT(Emp_ID) AS Hires
             FROM [Employment Details]
             WHERE YEAR(Date_of_Joining) <> 2017
             GROUP BY YEAR(Date_of_Joining)
         ) AS Subquery) AS AvgHires
) AS FinalResult;

--•	Q2: Number of Employees in Each State
ALTER VIEW vw_NumberOfEmployeesPerState AS
SELECT 
    State,
    COUNT(Emp_ID) AS Number_of_Employees
FROM 
    Addresses
GROUP BY 
    State;

--•	Q17: Top & Bottom 5 States by Number of Employees
ALTER VIEW vw_TopBottomStatesByEmployeeCount AS
WITH StateEmployeeCounts_Top AS (
    SELECT 
        State, 
        COUNT(Emp_ID) AS Number_of_Employees,
        RANK() OVER (ORDER BY COUNT(Emp_ID) DESC) AS Rank_Desc
    FROM Addresses
    GROUP BY State
),
StateEmployeeCounts_Bottom AS (
    SELECT 
        State, 
        COUNT(Emp_ID) AS Number_of_Employees,
        RANK() OVER (ORDER BY COUNT(Emp_ID) ASC) AS Rank_ASC
    FROM Addresses
    GROUP BY State
)
SELECT 
    'Top' AS Category, 
    State, 
    Number_of_Employees, 
    Rank_Desc AS Rank
FROM StateEmployeeCounts_Top
WHERE Rank_Desc <= 5

UNION ALL

SELECT 
    'Bottom' AS Category, 
    State, 
    Number_of_Employees, 
    Rank_ASC AS Rank
FROM StateEmployeeCounts_Bottom
WHERE Rank_ASC <= 5;

--•	Q18: Top 5 States by Percentage of Total Employees
ALTER VIEW vw_Top5Combined_vs_Others AS
WITH StateEmployeeCounts AS (
    SELECT 
        State,
        COUNT(Emp_ID) AS Number_of_Employees
    FROM Addresses
    GROUP BY State
),
StateWithRanks AS (
    SELECT 
        State,
        Number_of_Employees,
        RANK() OVER (ORDER BY Number_of_Employees DESC) AS Rank_Desc
    FROM StateEmployeeCounts
)
SELECT 
    'Top 5 States' AS Category,
    SUM(Number_of_Employees) AS Total_Employees
FROM StateWithRanks
WHERE Rank_Desc <= 5

UNION ALL

SELECT 
    'Other States' AS Category,
    SUM(Number_of_Employees) AS Total_Employees
FROM StateWithRanks
WHERE Rank_Desc > 5;

--•	Q21: Number of Employees by Gender in Each Region
ALTER VIEW vw_EmployeesByGenderInRegion AS
SELECT 
    a.Region, 
    e.Gender, 
    COUNT(e.Emp_ID) AS Number_of_Employees
FROM Employees e 
JOIN Addresses a ON e.Emp_ID = a.Emp_ID
GROUP BY a.Region, e.Gender;

--•	Q8: Hiring Trends by Gender Over Time
ALTER VIEW vw_HiringTrendsByGender AS
SELECT 
    ed.Year_of_Joining AS Hire_Year,
    e.Gender,
    COUNT(e.Emp_ID) AS Number_of_Hires
FROM Employees e
JOIN [Employment Details] ed 
    ON e.Emp_ID = ed.Emp_ID
GROUP BY ed.Year_of_Joining, e.Gender;

----------------Category 2 ------------------

--Q99 
ALTER VIEW v_active_employees_by_gender AS
SELECT 
    Gender,
    COUNT(*) AS active_employee_count
FROM Employees
WHERE Attrition IS NULL OR Attrition = 0
GROUP BY Gender;

--Q99 
CREATE OR ALTER VIEW vw_NumberOfStates AS
SELECT COUNT(DISTINCT State) AS NumberOfStates
FROM Addresses;

--Q3: Average Age at Hiring
CREATE OR ALTER VIEW vw_AverageAgeAtHiring AS
SELECT 
    ROUND(AVG(DATEDIFF(YEAR, e.Date_of_Birth, ed.Date_of_Joining)), 0) AS Average_Age_at_Hiring
FROM dbo.Employees e 
JOIN dbo.[Employment Details] ed 
    ON e.Emp_ID = ed.Emp_ID;

--Q6: Gender Ratio
ALTER VIEW vw_GenderRatio AS
SELECT Gender, COUNT(*) AS Employee_Count, ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employees), 2) AS Percentage
FROM Employees
GROUP BY Gender;

--Q9: Average Age by Region
CREATE OR ALTER VIEW vw_AvgAgePerRegion AS
SELECT a.Region, ROUND(AVG(e.Age_in_Yrs), 1) AS Average_Age
FROM Employees e 
JOIN Addresses a ON e.Emp_ID = a.Emp_ID
GROUP BY a.Region;

--Q10: Number of Employees by Age Group
CREATE OR ALTER VIEW vw_NumberofEmployeesbyAgeGroup AS
SELECT 
  Age_Group,
  COUNT(*) AS Employee_Count,
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employees), 2) AS Percentage,
  ROW_NUMBER() OVER (ORDER BY 
    CASE 
      WHEN Age_Group = 'Under 20' THEN 1
      WHEN Age_Group = '20-29' THEN 2
      WHEN Age_Group = '30-39' THEN 3
      WHEN Age_Group = '40-49' THEN 4
      WHEN Age_Group = '50-59' THEN 5
      ELSE 6
    END) AS RowNum
FROM 
  (SELECT 
    CASE 
      WHEN Age_in_Yrs < 20 THEN 'Under 20'
      WHEN Age_in_Yrs BETWEEN 20 AND 29 THEN '20-29'
      WHEN Age_in_Yrs BETWEEN 30 AND 39 THEN '30-39'
      WHEN Age_in_Yrs BETWEEN 40 AND 49 THEN '40-49'
      WHEN Age_in_Yrs BETWEEN 50 AND 59 THEN '50-59'
      ELSE '60+'
    END AS Age_Group
  FROM Employees) AS AgeGroups
GROUP BY Age_Group;

--Q25: Average Age by Gender
CREATE OR ALTER VIEW vw_AverageAgeByGender AS
SELECT 
  e.Gender, 
  ROUND(AVG(e.Age_in_Yrs), 1) AS Average_Age, 
  COUNT(*) AS Employee_Count
FROM Employees e
GROUP BY e.Gender;

--Q26: Top 5 States by Average Age
CREATE OR ALTER VIEW vw_Top5StatesByAverageAge AS
SELECT 
    a.State,
    ROUND(AVG(e.Age_in_Yrs), 1) AS Average_Age,
    COUNT(*) AS Employee_Count
FROM 
    Employees e
JOIN 
    Addresses a ON e.Emp_ID = a.Emp_ID
GROUP BY 
    a.State
ORDER BY 
    Average_Age DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

--Q22: Average Age in Company by Region
CREATE OR ALTER VIEW vw_AverageAgeByRegion AS
SELECT 
    a.Region, 
    ROUND(AVG(e.Age_in_Yrs), 1) AS Average_Age, 
    COUNT(*) AS Employee_Count
FROM 
    Employees e
JOIN 
    Addresses a ON e.Emp_ID = a.Emp_ID
GROUP BY a.Region;

--Q29-1: Count of Employees by Job Title
CREATE OR ALTER VIEW vw_NamePrefix_Count AS
SELECT 
    e.Job_title,
    COUNT(*) AS Employee_Count
FROM 
    Employees e
GROUP BY 
    e.Job_title;

--Q29-2: Average Salary by Job Title
CREATE OR ALTER VIEW vw_NamePrefix_AvgSalary AS
SELECT 
    e.Job_title,
    ROUND(AVG(CAST(s.Salary AS FLOAT)), 2) AS Average_Salary
FROM 
    Employees e
LEFT JOIN 
    Salaries s ON e.Emp_ID = s.Emp_ID
GROUP BY 
    e.Job_title;

--Q29-3: Average Last Hike by Job Title
CREATE OR ALTER VIEW vw_NamePrefix_AvgHike AS
SELECT 
    e.Job_title,
    ROUND(AVG(CAST(REPLACE(s.Last_Hike, '%', '') AS FLOAT)) / 100, 4) AS Average_Hike
FROM 
    Employees e
LEFT JOIN 
    Salaries s ON e.Emp_ID = s.Emp_ID
GROUP BY 
    e.Job_title;

--Q33: Email Classification
CREATE OR ALTER VIEW vw_EmailClassifications AS
SELECT 
    CASE 
        WHEN E_Mail LIKE '%@gmail.com%' THEN 'Individual'
        WHEN E_Mail LIKE '%@yahoo.com%' THEN 'Individual'
        WHEN E_Mail LIKE '%@hotmail.com%' THEN 'Individual'
        WHEN E_Mail LIKE '%@outlook.com%' THEN 'Individual'
        ELSE 'Company'
    END AS Email_Type,
    COUNT(*) AS Employee_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Contacts), 2) AS Percentage
FROM 
    Contacts
GROUP BY 
    CASE 
        WHEN E_Mail LIKE '%@gmail.com%' THEN 'Individual'
        WHEN E_Mail LIKE '%@yahoo.com%' THEN 'Individual'
        WHEN E_Mail LIKE '%@hotmail.com%' THEN 'Individual'
        WHEN E_Mail LIKE '%@outlook.com%' THEN 'Individual'
        ELSE 'Company'
    END;

--Q40: Average Age (Left vs Stayed)
CREATE OR ALTER VIEW vw_EmployeeStatusSummary AS
SELECT 
    CASE 
        WHEN Attrition = 1 THEN 'Left'
        ELSE 'Stayed'
    END AS Employee_Status,
    ROUND(AVG(Age_in_Yrs), 1) AS Average_Age,
    COUNT(*) AS Employee_Count
FROM 
    Employees
GROUP BY 
    CASE 
        WHEN Attrition = 1 THEN 'Left'
        ELSE 'Stayed'
    END;



--------------3. Experience & Compensation-------------
-- Q7: Average Salary by Gender
CREATE OR ALTER VIEW vw_AvgSalaryByGender AS
SELECT 
    e.Gender AS Gender,
    COUNT(DISTINCT e.Emp_ID) AS Employee_Count,
    ROUND(AVG(CAST(s.Salary AS FLOAT)), 0) AS Avg_Salary
FROM 
    Employees e
INNER JOIN 
    Salaries s ON e.Emp_ID = s.Emp_ID
GROUP BY 
    e.Gender;

-- Q11: Correlation Between Salary and Age in Company
CREATE OR ALTER VIEW vw_Correlation_Salary_AgeInCompany AS
SELECT
    (AVG(CAST(s.Salary AS FLOAT) * CAST(ed.Age_in_Company_Years AS FLOAT)) - 
     AVG(CAST(s.Salary AS FLOAT)) * AVG(CAST(ed.Age_in_Company_Years AS FLOAT)))
    /
    (STDEV(CAST(s.Salary AS FLOAT)) * STDEV(CAST(ed.Age_in_Company_Years AS FLOAT))) 
    AS Correlation_Salary_AgeInCompany
FROM 
    Salaries s
INNER JOIN 
    [Employment Details] ed ON s.Emp_ID = ed.Emp_ID
WHERE 
    s.Salary IS NOT NULL 
    AND ed.Age_in_Company_Years IS NOT NULL;

-- Q12: Average Salary by Region
CREATE OR ALTER VIEW vw_AvgSalaryByRegion AS
SELECT 
    a.Region, 
    ROUND(AVG(CAST(s.Salary AS FLOAT)), 0) AS Avg_Salary,
    COUNT(DISTINCT e.Emp_ID) AS Employee_Count
FROM 
    Employees e
INNER JOIN 
    Salaries s ON e.Emp_ID = s.Emp_ID
INNER JOIN 
    Addresses a ON e.Emp_ID = a.Emp_ID
WHERE
    s.Salary IS NOT NULL
    AND a.Region IS NOT NULL
GROUP BY 
    a.Region;

-- Q13: Number of Employees by Last % Hike Category
CREATE OR ALTER VIEW vw_Employee_Hike_Categories AS
SELECT 
    CASE 
        WHEN CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 0 AND 10 THEN 'Low Hike (0%-10%)'
        WHEN CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 11 AND 20 THEN 'Medium Hike (11%-20%)'
        WHEN CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 21 AND 30 THEN 'High Hike (21%-30%)'
        ELSE 'Other'
    END AS Hike_Category,
    COUNT(Emp_ID) AS Number_of_Employees
FROM 
    Salaries
GROUP BY 
    CASE 
        WHEN CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 0 AND 10 THEN 'Low Hike (0%-10%)'
        WHEN CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 11 AND 20 THEN 'Medium Hike (11%-20%)'
        WHEN CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 21 AND 30 THEN 'High Hike (21%-30%)'
        ELSE 'Other'
    END;

-- Q14: Number of Males and Females by Last % Hike Category
CREATE OR ALTER VIEW vw_Employee_Hike_Gender_Categories AS
WITH HikeCategories AS (
    SELECT 
        S.EMP_ID,
        E.GENDER,
        CASE 
            WHEN CAST(REPLACE(S.LAST_HIKE, '%', '') AS INT) BETWEEN 0 AND 10 THEN 'Low Hike (0%-10%)'
            WHEN CAST(REPLACE(S.LAST_HIKE, '%', '') AS INT) BETWEEN 11 AND 20 THEN 'Medium Hike (11%-20%)'
            WHEN CAST(REPLACE(S.LAST_HIKE, '%', '') AS INT) BETWEEN 21 AND 30 THEN 'High Hike (21%-30%)'
            ELSE 'Other'
        END AS Hike_Category
    FROM 
        Salaries S
    INNER JOIN 
        Employees E ON S.EMP_ID = E.EMP_ID
)
SELECT 
    Hike_Category,
    GENDER,
    COUNT(EMP_ID) AS Number_of_Employees
FROM 
    HikeCategories
GROUP BY 
    Hike_Category,
    GENDER;

-- Q15: Distribution by Age in Company (Experience)
CREATE OR ALTER VIEW vw_AgeDistributionInCompany AS
SELECT
    CASE
        WHEN Age_in_Company_Years < 2 THEN 'Less than 2 years'
        WHEN Age_in_Company_Years BETWEEN 2 AND 5 THEN '2-5 years'
        WHEN Age_in_Company_Years BETWEEN 6 AND 10 THEN '6-10 years'
        WHEN Age_in_Company_Years BETWEEN 11 AND 15 THEN '11-15 years'
        ELSE 'More than 15 years'
    END AS Tenure_Group,
    COUNT(*) AS Employee_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dbo.[Employees]), 2) AS Percentage
FROM dbo.[Employment Details]
GROUP BY
    CASE
        WHEN Age_in_Company_Years < 2 THEN 'Less than 2 years'
        WHEN Age_in_Company_Years BETWEEN 2 AND 5 THEN '2-5 years'
        WHEN Age_in_Company_Years BETWEEN 6 AND 10 THEN '6-10 years'
        WHEN Age_in_Company_Years BETWEEN 11 AND 15 THEN '11-15 years'
        ELSE 'More than 15 years'
    END;

-- Q20: Average Salary in Each State
CREATE OR ALTER VIEW dbo.vw_AverageSalaryByState AS
SELECT 
    a.State,
    ROUND(AVG(CAST(s.Salary AS BIGINT)), 0) AS Avg_Salary,
    COUNT_BIG(*) AS Employee_Count,
    ROUND(COUNT_BIG(*) * 100.0 / (SELECT COUNT_BIG(*) FROM dbo.Employees), 2) AS Percentage
FROM dbo.Employees e
JOIN dbo.Salaries s ON e.Emp_ID = s.Emp_ID
JOIN dbo.Addresses a ON e.Emp_ID = a.Emp_ID
GROUP BY a.State;

-- Q23: Average % Hike by Age Group
CREATE OR ALTER VIEW vw_Average_Hike_By_Age_Group AS
SELECT 
    CASE 
        WHEN E.Age_in_Yrs BETWEEN 20 AND 30 THEN '20-30'
        WHEN E.Age_in_Yrs BETWEEN 31 AND 40 THEN '31-40'
        WHEN E.Age_in_Yrs BETWEEN 41 AND 50 THEN '41-50'
        WHEN E.Age_in_Yrs BETWEEN 51 AND 60 THEN '51-60'
        ELSE 'Other'
    END AS Age_Group,
    AVG(CAST(REPLACE(S.LAST_HIKE, '%', '') AS FLOAT)) AS Average_Hike
FROM 
    Employees E
INNER JOIN 
    Salaries S ON E.EMP_ID = S.EMP_ID
GROUP BY 
    CASE 
        WHEN E.Age_in_Yrs BETWEEN 20 AND 30 THEN '20-30'
        WHEN E.Age_in_Yrs BETWEEN 31 AND 40 THEN '31-40'
        WHEN E.Age_in_Yrs BETWEEN 41 AND 50 THEN '41-50'
        WHEN E.Age_in_Yrs BETWEEN 51 AND 60 THEN '51-60'
        ELSE 'Other'
    END;

-- Q24: Average Salary by Age Group
CREATE OR ALTER VIEW vw_Avg_Salary_And_Count_By_Age_Group AS
SELECT
    CASE
        WHEN e.Age_in_Yrs BETWEEN 20 AND 30 THEN '20-30'
        WHEN e.Age_in_Yrs BETWEEN 31 AND 40 THEN '31-40'
        WHEN e.Age_in_Yrs BETWEEN 41 AND 50 THEN '41-50'
        WHEN e.Age_in_Yrs BETWEEN 51 AND 60 THEN '51-60'
        ELSE 'Other'
    END AS Age_Group,
    ROUND(AVG(CAST(s.Salary AS FLOAT)), 0) AS Avg_Salary,
    COUNT(*) AS Employee_Count
FROM 
    Employees e
JOIN 
    Salaries s ON e.Emp_ID = s.Emp_ID
GROUP BY
    CASE
        WHEN e.Age_in_Yrs BETWEEN 20 AND 30 THEN '20-30'
        WHEN e.Age_in_Yrs BETWEEN 31 AND 40 THEN '31-40'
        WHEN e.Age_in_Yrs BETWEEN 41 AND 50 THEN '41-50'
        WHEN e.Age_in_Yrs BETWEEN 51 AND 60 THEN '51-60'
        ELSE 'Other'
    END;

-- Q31: Distribution by Career Stage
CREATE OR ALTER VIEW vw_Career_Stage_Analysis AS
WITH CareerStages AS (
    SELECT 
        e.Emp_ID, 
        e.Age_in_Yrs, 
        ed.Age_in_Company_Years, 
        CAST(s.Salary AS FLOAT) AS Salary,
        CASE
            WHEN ed.Age_in_Company_Years < 2 THEN 'Entry-Level'
            WHEN ed.Age_in_Company_Years BETWEEN 2 AND 5 THEN 'Early-Career'
            WHEN ed.Age_in_Company_Years BETWEEN 6 AND 10 THEN 'Mid-Career'
            WHEN ed.Age_in_Company_Years BETWEEN 11 AND 20 THEN 'Experienced'
            ELSE 'Leadership'
        END AS Career_Stage
    FROM 
        Employees e 
    JOIN 
        Salaries s ON e.Emp_ID = s.Emp_ID
    JOIN 
        [Employment Details] ed ON e.Emp_ID = ed.Emp_ID
    WHERE 
        e.Attrition = 0
)
SELECT
    Career_Stage,
    COUNT(*) AS Employee_Count, 
    ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM CareerStages), 2) AS Percentage, 
    ROUND(AVG(Salary), 0) AS Avg_Salary,
    ROUND(AVG(CAST(Age_in_Yrs AS FLOAT)), 1) AS Avg_Age, 
    ROUND(AVG(CAST(Age_in_Company_Years AS FLOAT)), 1) AS Avg_Tenure
FROM
    CareerStages
GROUP BY 
    Career_Stage;









-------------4. Success Factors of Top 10% High-Earning Employees------------

----Q30.1: What is the average age of the top 10% employees based on salary
ALTER VIEW average_age_of_the_top_10_employees AS
WITH filtering AS (
    SELECT *, NTILE(10) OVER (ORDER BY s.Salary DESC) AS groups
    FROM Salaries s
)
SELECT AVG(E.Age_in_Yrs) AS [average age of the top 10 % employees]
FROM filtering f, Employees E
WHERE f.Emp_ID = E.Emp_ID AND f.groups = 1;


----Q30.2: What is the gender distribution among the top 10 % employees based salary
ALTER VIEW the_Gender_distribution_of_the_top_10_employees AS
WITH filtering AS (
    SELECT *, NTILE(10) OVER (ORDER BY s.Salary DESC) AS groups
    FROM Salaries s
)
SELECT E.Gender, COUNT(E.Gender) AS [Number of Employees]
FROM Employees E, filtering f
WHERE E.Emp_ID = f.Emp_ID AND f.groups = 1
GROUP BY E.Gender;


----Q30.3: What is the regional distribution of the top 10 % employees based salary
ALTER VIEW the_regional_distribution_of_the_top_10_employees AS
WITH filtering AS (
    SELECT *, NTILE(10) OVER (ORDER BY s.Salary DESC) AS groups
    FROM Salaries s
)
SELECT A.Region, COUNT(A.Region) AS [Number of Employees]
FROM Addresses A, filtering f
WHERE A.Emp_ID = f.Emp_ID AND f.groups = 1
GROUP BY A.Region;


----Q30.4: What is the average years of experience for the top 10% employees based salary
ALTER VIEW average_years_of_experience_or_the_top_10_employees AS
WITH filtering AS (
    SELECT *, NTILE(10) OVER (ORDER BY s.Salary DESC) AS groups
    FROM Salaries s
)
SELECT AVG(E.Age_in_Company_Years) AS [average years of experience]
FROM [Employment Details] E, filtering f
WHERE E.Emp_ID = f.Emp_ID AND f.groups = 1;


----Q30.5: How does the joining time (quarter/half/year) relate to the salary growth of the top 10% employees
ALTER VIEW joining_time_top_10_employees AS
WITH filtering AS (
    SELECT *, NTILE(10) OVER (ORDER BY s.Salary DESC) AS groups
    FROM Salaries s
)
SELECT 
    E.Date_of_Joining, 
    E.Year_of_Joining, 
    E.Quarter_of_Joining,  
    E.Half_of_Joining,  
    COUNT(E.Emp_ID) AS Total_Employees
FROM [Employment Details] E
JOIN filtering f ON E.Emp_ID = f.Emp_ID
WHERE f.groups = 1
GROUP BY 
    E.Date_of_Joining, 
    E.Year_of_Joining, 
    E.Quarter_of_Joining,  
    E.Half_of_Joining;


----Q99: Attrition status of top 10% employees
ALTER VIEW top_10_percent_attrition_status AS
WITH top_earners AS (
    SELECT *, NTILE(10) OVER (ORDER BY Salary DESC) AS grp
    FROM Salaries
)
SELECT 
    E.Attrition, 
    COUNT(*) AS count_employees,
    ROUND(COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_top_10
FROM top_earners T
JOIN Employees E ON T.Emp_ID = E.Emp_ID
WHERE T.grp = 1
GROUP BY E.Attrition;


----Q99: Gender distribution of top 10%
ALTER VIEW gender_distribution_top_10_employees AS
WITH top_earners AS (
    SELECT *, NTILE(10) OVER (ORDER BY Salary DESC) AS grp
    FROM Salaries
)
SELECT 
    E.Gender, 
    COUNT(*) AS count_employees,
    ROUND(COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM top_earners T
JOIN Employees E ON T.Emp_ID = E.Emp_ID
WHERE T.grp = 1
GROUP BY E.Gender;


----Q99: States of top 10% earners
ALTER VIEW top_states_top_10_employees AS
WITH top_earners AS (
    SELECT *, NTILE(10) OVER (ORDER BY Salary DESC) AS grp
    FROM Salaries
)
SELECT A.State, COUNT(*) AS count_employees
FROM top_earners T
JOIN Addresses A ON T.Emp_ID = A.Emp_ID
WHERE T.grp = 1
GROUP BY A.State;


---Q99
Create VIEW the_job_titles_of_top_10_percent_salaries AS
WITH filtering AS (
    SELECT s.Emp_ID, e.Job_title, NTILE(10) OVER (ORDER BY s.Salary DESC) AS groups
    FROM Salaries s
    JOIN Employees e ON s.Emp_ID = e.Emp_ID
)
SELECT Job_title, COUNT(*) AS [Number of Employees]
FROM filtering
WHERE groups = 1
GROUP BY Job_title;





--------------------5. Attrition & Exit Analysis-------------------
----Q34: Overall Employee Attrition Rate
ALTER VIEW AttritionPercentage AS
SELECT 
    1.0 * SUM(CASE WHEN E.Attrition = 'True' THEN 1 ELSE 0 END) 
    / 
    COUNT(*) AS [Attrition Rate Percentage]
FROM 
    Employees E;


----Q99: Employees Who Left Number
CREATE OR ALTER VIEW vw_EmployeesWhoLeft AS
SELECT COUNT(*) AS NumberOfEmployeesWhoLeft
FROM Employees
WHERE Attrition = 'True';


----Q35: Region with Highest Attrition
ALTER VIEW Region_with_Highest_Attrition AS
SELECT A.Region, COUNT(E.Attrition) AS [Number of Employees Who Left]
FROM Employees E
JOIN Addresses A ON E.Emp_ID = A.Emp_ID
WHERE E.Attrition = 'True'
GROUP BY A.Region;


----Q36: State with Highest Attrition
ALTER VIEW State_with_Highest_Attrition AS
SELECT A.State, COUNT(E.Attrition) AS [Number of Employees Who Left]
FROM Employees E
JOIN Addresses A ON E.Emp_ID = A.Emp_ID
WHERE E.Attrition = 'True'
GROUP BY A.State;


----Q37: Average Salary Comparison (Left vs Stayed)
ALTER VIEW Average_Salary_Comparison AS
SELECT 
    CASE WHEN E.Attrition = 1 THEN 'True' ELSE 'False' END AS Attrition,
    AVG(CAST(S.Salary AS FLOAT)) AS [Average Salary]
FROM Employees E
JOIN Salaries S ON E.Emp_ID = S.Emp_ID
GROUP BY E.Attrition;


----Q38: Average Tenure Comparison (Left vs Stayed)
ALTER VIEW Average_Tenure_Comparison AS
SELECT 
    CASE WHEN E.Attrition = 1 THEN 'True' ELSE 'False' END AS Attrition,
    AVG(D.Age_in_Company_Years) AS [Average Tenure]
FROM Employees E
JOIN [Employment Details] D ON E.Emp_ID = D.Emp_ID
GROUP BY E.Attrition;


----Q39: Attrition Trend Over Time (Year, Quarter, Month)
ALTER VIEW Attrition_Trend_Over_Time AS
SELECT 
    D.Date_of_Joining, 
    D.Year_of_Joining,
    D.Quarter_of_Joining,
    D.Month_of_Joining,
    COUNT(E.Attrition) AS [Number of Employees Who Left]
FROM Employees E
JOIN [Employment Details] D ON E.Emp_ID = D.Emp_ID
WHERE E.Attrition = 'True'
GROUP BY 
    D.Date_of_Joining, 
    D.Year_of_Joining,
    D.Quarter_of_Joining,
    D.Month_of_Joining;


----Q41: Gender Distribution of Employees Who Left
ALTER VIEW Gender_Distribution_of_Employees_Who_Left AS
SELECT 
    E.Gender,
    COUNT(E.Attrition) AS [Employees Who Left]
FROM Employees E
WHERE E.Attrition = 'True'
GROUP BY E.Gender;


----Q42: Average Last % Hike (Left vs Stayed) 
ALTER VIEW AverageLastHike_Left_vs_Stayed AS 
SELECT 
    CASE WHEN E.Attrition = 1 THEN 'True' ELSE 'False' END AS Attrition,
    AVG(CAST(REPLACE(S.Last_Hike, '%', '') AS FLOAT)) AS [Average Last % Hike]
FROM Employees E
JOIN Salaries S ON E.Emp_ID = S.Emp_ID
GROUP BY E.Attrition;


----Q99: Avg Salary By Age Group and Attrition Status
ALTER VIEW Avg_Salary_By_AgeGroup_Attrition_Status AS
SELECT 
    Age_Group,
    CASE 
        WHEN E.Attrition = 'True' THEN 'Left'
        ELSE 'Stayed'
    END AS Attrition_Status,
    AVG(CAST(S.Salary AS FLOAT)) AS [Average Salary]
FROM Employees E
JOIN Salaries S ON E.Emp_ID = S.Emp_ID
CROSS APPLY (
    SELECT 
        CASE 
            WHEN E.Age_in_Yrs BETWEEN 20 AND 30 THEN '20-30'
            WHEN E.Age_in_Yrs BETWEEN 31 AND 40 THEN '31-40'
            WHEN E.Age_in_Yrs BETWEEN 41 AND 50 THEN '41-50'
            WHEN E.Age_in_Yrs BETWEEN 51 AND 60 THEN '51-60'
            ELSE 'Other'
        END AS Age_Group
) AS Grouping
GROUP BY Age_Group, E.Attrition;
--------------------------------------------- 

ALTER TABLE Salaries
ADD Hike_Category VARCHAR(30);

UPDATE Salaries
SET Hike_Category = 
    CASE 
        WHEN TRY_CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 0 AND 10 THEN 'Low Hike (0%-10%)'
        WHEN TRY_CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 11 AND 20 THEN 'Medium Hike (11%-20%)'
        WHEN TRY_CAST(REPLACE(Last_Hike, '%', '') AS INT) BETWEEN 21 AND 30 THEN 'High Hike (21%-30%)'
        ELSE 'Other'
    END;







-------------------------

CREATE OR ALTER VIEW vw_Employees_With_Top10Flag AS
WITH RankedSalaries AS (
    SELECT 
        EMP_ID,
        Salary,
        PERCENT_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Salaries
)
SELECT 
    EMP_ID,
    Salary,
    CASE 
        WHEN SalaryRank <= 0.10 THEN 'Top 10%'
        ELSE 'Others'
    END AS Top10Flag
FROM RankedSalaries;
