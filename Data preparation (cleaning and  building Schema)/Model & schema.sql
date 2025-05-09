---Normalization
--Create Tables on sqlserver

--Employees	Table  

select H.Emp_ID,H.Name_Prefix,H.First_Name,H.Middle_Initial,H.Last_Name,
H.Gender,H.Date_of_Birth,H.Time_of_Birth,H.Age_in_Yrs,H.Weight_in_Kgs,H.SSN,H.UserName,
H.Password INTO Employees
from [Human Resources] H

select * from Employees
order by  Emp_ID

----------------------------------------------
--Contacts Table

select H.Emp_ID,H.E_Mail,H.Phone_No INTO Contacts
from [Human Resources] H

select * from Contacts
order by Contact_ID

-------------------------------------------------
--Family Table

select H.Emp_ID,H.Father_s_Name,H.Mother_s_Name,H.Mother_s_Maiden_Name INTO Family
from [Human Resources] as H

SELECT *
FROM Family
ORDER BY Family_ID

---------------------------------------------------
--Addresses Table 

select H.Emp_ID,H.Place_Name,H.County,H.City,H.State,H.Zip,H.Region INTO Addresses
from [Human Resources] as H

 SELECT *
 FROM Addresses
 ORDER BY Address_ID

----------------------------------------------------
---Employment Details Table 

select H.Emp_ID,H.Date_of_Joining,H.Quarter_of_Joining,H.Half_of_Joining,H.Year_of_Joining,
H.Month_of_Joining,H.Month_Name_of_Joining,H.Short_Month,H.Day_of_Joining,H.DOW_of_Joining,
H.Short_DOW,H.Age_in_Company_Years INTO [Employment Details]
from [Human Resources] as H

SELECT *
FROM [Employment Details]
ORDER BY Employment_ID

--------------------------------------------------------
--Salaries Table

SELECT H.Emp_ID,H.Salary,H.Last_Hike INTO Salaries
FROM [Human Resources] AS H

SELECT *
FROM Salaries
ORDER BY Salary_ID