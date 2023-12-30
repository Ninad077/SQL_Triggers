-- Trigger
-- Trigger acts like a stored procedure but it is called automatically before/after we update/insert/delete a table

-- Creating a Trigger
create table log(
SR_no int primary key auto_increment,
Entry_For varchar(40),
event_time timestamp);
Delimiter //
Create Trigger log_entry after insert on Emp_EH for each row
Begin
	insert into log_entry(Entry_For,event_time) values ("data inserted",current_timestamp);
End //
Delimiter ;

call Emp_procedure("Sanjay");



# After Delete Trigger. 

CREATE TABLE Salaries(
    employeeNumber INT PRIMARY KEY,
    salary DECIMAL(10,2) NOT NULL DEFAULT 0
);

INSERT INTO Salaries(employeeNumber,salary)
VALUES (1002,5000), (1056,7000), (1076,8000);

CREATE TABLE SalaryBudgets(
    total DECIMAL(15,2) NOT NULL
);

INSERT INTO SalaryBudgets(total)
	SELECT SUM(salary)  FROM Salaries;

-- INSERT INTO SalaryBudgets values(15000);

DELIMITER //
CREATE TRIGGER after_salaries_delete
AFTER DELETE
ON Salaries 
FOR EACH ROW
BEGIN
	UPDATE SalaryBudgets 
	SET total = total - old.salary;
END //
DELIMITER ;

select * from salaries;
select * from SalaryBudgets;

set sql_safe_updates=0;
DELETE FROM Salaries WHERE employeeNumber = 1002;



-- After Update Trigger
CREATE TABLE Sales (
    id INT AUTO_INCREMENT,
    product VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    fiscalYear SMALLINT NOT NULL,
    fiscalMonth TINYINT NOT NULL,
    CHECK(fiscalMonth >= 1 AND fiscalMonth <= 12),
    CHECK(fiscalYear BETWEEN 2000 and 2050),
    CHECK (quantity >=0),
    UNIQUE(product, fiscalYear, fiscalMonth),
    PRIMARY KEY(id)
);

INSERT INTO Sales(product, quantity, fiscalYear, fiscalMonth)
VALUES
    ('2001 Ferrari Enzo',140, 2021,1),
    ('1998 Chrysler Plymouth Prowler', 110,2021,1),
    ('1913 Ford Model T Speedster', 120,2021,1);

SELECT * FROM Sales;

CREATE TABLE SalesChanges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    salesId INT,
    beforeQuantity INT,
    afterQuantity INT,
    changedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

SELECT * FROM SalesChanges;

DELIMITER $$
CREATE TRIGGER after_sales_update
AFTER UPDATE
ON sales FOR EACH ROW
BEGIN
    IF OLD.quantity <> new.quantity THEN
        INSERT INTO SalesChanges(salesId,beforeQuantity, afterQuantity)
        VALUES(old.id, old.quantity, new.quantity);
    END IF;
END$$
DELIMITER ;

SET SQL_SAFE_UPDATES=0;

UPDATE Sales 
SET quantity = 350
WHERE id = 1;


UPDATE Sales 
SET quantity = 150
WHERE id = 2;

SELECT * FROM SalesChanges;

describe sales;



-- Before Delete Trigger
CREATE TABLE Salary (
    employeeNumber INT PRIMARY KEY,
    validFrom DATE NOT NULL,
    amount DEC(12 , 2 ) NOT NULL DEFAULT 0
);


INSERT INTO salary(employeeNumber,validFrom,amount)
VALUES
    (1002,'2000-01-01',50000),
    (1056,'2000-01-01',60000),
    (1076,'2000-01-01',70000);


CREATE TABLE SalaryArchives (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employeeNumber INT,
    validFrom DATE NOT NULL,
    amount DEC(12 , 2 ) NOT NULL DEFAULT 0,
    deletedAt TIMESTAMP DEFAULT NOW()
);

DELIMITER //
CREATE TRIGGER before_salaries_delete
BEFORE DELETE
ON salary FOR EACH ROW
BEGIN
    INSERT INTO SalaryArchives(employeeNumber,validFrom,amount)
    VALUES(OLD.employeeNumber,OLD.validFrom,OLD.amount);
END //
DELIMITER ;


select * from salary;
select * from salaryarchives;

DELETE FROM salary WHERE employeeNumber = 1002;


-- Before Update Trigger
CREATE TABLE sales (
    id INT AUTO_INCREMENT,
    product VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    fiscalYear SMALLINT NOT NULL,
    fiscalMonth TINYINT NOT NULL,
    CHECK(fiscalMonth >= 1 AND fiscalMonth <= 12),
    CHECK(fiscalYear BETWEEN 2000 and 2050),
    CHECK (quantity >=0),
    UNIQUE(product, fiscalYear, fiscalMonth),
    PRIMARY KEY(id)
);

INSERT INTO sales(product, quantity, fiscalYear, fiscalMonth)
VALUES
    ('2003 Harley-Davidson Eagle Drag Bike',120, 2020,1),
    ('1969 Corvair Monza', 150,2020,1),
    ('1970 Plymouth Hemi Cuda', 200,2020,1);

DELIMITER $$
CREATE TRIGGER before_sales_update
BEFORE UPDATE
ON sales FOR EACH ROW
BEGIN
    DECLARE errorMessage VARCHAR(255);
    SET errorMessage = CONCAT('The new quantity ',
                        NEW.quantity,
                        ' cannot be 3 times greater than the current quantity ',
                        OLD.quantity);
                        
    IF new.quantity > old.quantity * 3 THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = errorMessage;
    END IF;
END $$

DELIMITER ;

show triggers;
select * from sales;

UPDATE sales 
SET quantity = 150
WHERE id = 1;

UPDATE sales 
SET quantity = 500
WHERE id = 1;


-- Before Insert Trigger
CREATE TABLE employee_trigger(  
    name VARCHAR(45) NOT NULL,    
    occupation VARCHAR(35) NOT NULL,    
    working_date DATE,  
    working_hours INT
);  

INSERT INTO employee_trigger VALUES    
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);  

SELECT * FROM employee_trigger;

DELIMITER &&
CREATE TRIGGER before_insert_empworkinghours   
BEFORE INSERT ON employee_trigger
FOR EACH ROW  
BEGIN  
IF NEW.working_hours < 0 THEN SET NEW.working_hours = 0;  
END IF;  
END &&
Delimiter ; 

INSERT INTO employee_trigger VALUES    
('Markus', 'Farmer', '2020-10-08', 14);  

INSERT INTO employee_trigger VALUES    
('Alexander', 'Actor', '2020-10-12', -13);  

INSERT INTO employee_trigger VALUES    
('Alex', 'Farmer', '2020-10-12', -10);  

INSERT INTO employee_trigger VALUES    
('Pandora', 'Actor', '2020-10-12', -80);  

SELECT * FROM employee_trigger;

SHOW TRIGGERS;

DROP TRIGGER before_insert_empworkinghours;