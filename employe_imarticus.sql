USE emp_details;

--  CHECK CURRENT TABLE STRUCTURE

DESCRIBE Employees;
DESCRIBE Departments;




-- 1. ADD SALARY TO EMPLOYEES


ALTER TABLE Employees
ADD COLUMN salary INT;


-- 2. ADD SALARY VALUES TO EXISTING EMPLOYEES

UPDATE Employees
SET salary = CASE id
    WHEN 1 THEN 70000
    WHEN 2 THEN 75000
    WHEN 3 THEN 80000
    WHEN 4 THEN 72000
    WHEN 5 THEN 60000
    WHEN 6 THEN 78000
    WHEN 7 THEN 73000
    WHEN 8 THEN 82000
    WHEN 9 THEN 71000
    WHEN 10 THEN 55000
    WHEN 11 THEN 58000
    WHEN 12 THEN 61000
    WHEN 13 THEN 76000
    WHEN 14 THEN 54000
END
WHERE id BETWEEN 1 AND 14;


-- 3. CHECK DEPARTMENT LOCATIONS

SELECT location
FROM Departments;

-- 4. EMPLOYEE + DEPARTMENT + PROJECT

SELECT 
    e.first_name,
    d.D_name,
    p.P_name
FROM Employees e
INNER JOIN Departments d
    ON e.department_id = d.id
INNER JOIN Timesheets t
    ON e.id = t.employee_id
INNER JOIN Projects p
    ON t.project_id = p.id;



-- 5. EMPLOYEE + PROJECT


SELECT 
    e.first_name,
    p.P_name
FROM Employees e
INNER JOIN Timesheets t
    ON e.id = t.employee_id
INNER JOIN Projects p
    ON t.project_id = p.id;


-- 6. TOTAL HOURS BY EMPLOYEE AND PROJECT

SELECT 
    e.first_name,
    p.P_name,
    SUM(t.hours) AS total_hours
FROM Employees e
INNER JOIN Timesheets t
    ON e.id = t.employee_id
INNER JOIN Projects p
    ON t.project_id = p.id
GROUP BY e.id, e.first_name, p.id, p.P_name;

-- 7. EMPLOYEES WITH NO TIMESHEET

SELECT 
    e.first_name
FROM Employees e
LEFT JOIN Timesheets t
    ON e.id = t.employee_id
WHERE t.employee_id IS NULL;


-- 8. PROJECT WITH HIGHEST TOTAL HOURS

SELECT 
    p.P_name,
    SUM(t.hours) AS total_hours
FROM Projects p
INNER JOIN Timesheets t
    ON p.id = t.project_id
GROUP BY p.id, p.P_name
ORDER BY total_hours DESC
LIMIT 1;

-- 9. CREATE EMPLOYEE-DEPARTMENT-SALARY VIEW

DROP VIEW IF EXISTS Employee_Department_Salary;

CREATE VIEW Employee_Department_Salary AS
SELECT 
    e.first_name,
    d.D_name,
    e.salary
FROM Employees e
INNER JOIN Departments d
    ON e.department_id = d.id;


-- 10. CREATE EMPLOYEE-PROJECT VIEW

DROP VIEW IF EXISTS Employee_Project_View;

CREATE VIEW Employee_Project_View AS
SELECT 
    e.first_name,
    p.P_name
FROM Employees e
INNER JOIN Timesheets t
    ON e.id = t.employee_id
INNER JOIN Projects p
    ON t.project_id = p.id;



-- 11. EMPLOYEES WITH MORE THAN 20 HOURS

SELECT 
    e.first_name,
    SUM(t.hours) AS total_hours
FROM Employees e
INNER JOIN Timesheets t
    ON e.id = t.employee_id
GROUP BY e.id, e.first_name
HAVING SUM(t.hours) > 20;

-- 12. EMPLOYEE CATEGORY

SELECT 
    first_name,
    job_title,
    CASE
        WHEN job_title LIKE '%Manager%' THEN 'Manager'
        WHEN job_title LIKE '%Developer%' THEN 'Developer'
        ELSE 'Other'
    END AS employee_category
FROM Employees;

-- 13. EMPLOYEES WORKING ON MORE THAN 1 PROJECT

SELECT 
    e.first_name,
    COUNT(DISTINCT t.project_id) AS total_projects
FROM Employees e
INNER JOIN Timesheets t
    ON e.id = t.employee_id
GROUP BY e.id, e.first_name
HAVING COUNT(DISTINCT t.project_id) > 1;

-- 14. RANK EMPLOYEES BY TOTAL HOURS


SELECT 
    e.first_name,
    SUM(t.hours) AS total_hours,
    RANK() OVER (
        ORDER BY SUM(t.hours) DESC
    ) AS employee_rank
FROM Employees e
INNER JOIN Timesheets t
    ON e.id = t.employee_id
GROUP BY e.id, e.first_name;


-- 15. EMPLOYEES ABOVE AVERAGE HOURS


SELECT 
    e.first_name,
    SUM(t.hours) AS total_hours
FROM Employees e
INNER JOIN Timesheets t
    ON e.id = t.employee_id
GROUP BY e.id, e.first_name
HAVING SUM(t.hours) >
(
    SELECT AVG(total_emp_hours)
    FROM
    (
        SELECT 
            employee_id,
            SUM(hours) AS total_emp_hours
        FROM Timesheets
        GROUP BY employee_id
    ) AS avg_table
);


-- 16. UPDATE ENGINEERING DEVELOPERS

UPDATE Employees
SET job_title = 'Senior Developer'
WHERE department_id = (
    SELECT id
    FROM Departments
    WHERE D_name = 'Engineering'
)
AND job_title = 'Developer';


-- 17. CHECK LOCATIONS AGAIN

SELECT location
FROM Departments;


-- 18. DEPARTMENT WITH HIGHEST AVERAGE SALARY

SELECT 
    d.D_name,
    AVG(e.salary) AS avg_salary
FROM Employees e
INNER JOIN Departments d
    ON e.department_id = d.id
GROUP BY d.id, d.D_name
ORDER BY avg_salary DESC
LIMIT 1;