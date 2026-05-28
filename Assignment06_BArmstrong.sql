--*************************************************************************--
-- Title: Assignment06
-- Author: 
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,           ,Created File
-- 2026-05-23, BArmstrong, Completed file
--**************************************************************************--

Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_BArmstrong')
	 Begin 
	  Alter Database [Assignment06DB_BArmstrong] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_BArmstrong;
	 End
	Create Database Assignment06DB_BArmstrong;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_BArmstrong;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View vCategories 
With SchemaBinding
AS  
	Select CategoryID, CategoryName
	From dbo.Categories;
go

Create View vEmployees 
With SchemaBinding
AS  
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From dbo.Employees;
go

Create View vInventories 
With SchemaBinding
AS  
	Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
	From dbo.Inventories;
go

Create View vProducts
With SchemaBinding
AS  
	Select ProductID, ProductName, CategoryID, UnitPrice
	From dbo.Products;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select on dbo.Categories to Public;
Grant Select On vCategories to Public;
go

Deny Select On Products to Public;
Grant Select On vProducts to Public;
go

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;
go

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;
go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

GO

Create View vProductsByCategories
With SchemaBinding
AS
	(Select top(1000000000) CategoryName, ProductName, UnitPrice
	From dbo.vCategories as c Inner Join dbo.vProducts as p
	On c.CategoryID = p.CategoryID
	Order By CategoryName, ProductName)
;
GO


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View vInventoriesByProductsByDates
with SCHEMABINDING
AS
	(select top(100000000) ProductName, InventoryDate, Count
	from dbo.vProducts as p inner join dbo.vInventories as i
	  on p.productID = i.ProductID
	Order by ProductName, InventoryDate, [Count]);
GO


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create VIEW vInventoriesByEmployeesByDates
With SCHEMABINDING
AS
	(Select top(10000000) InventoryDate, max(EmployeeFirstName + ' ' + EmployeeLastName) as [Employee Name]
	From dbo.vInventories as i Inner Join dbo.vEmployees as e
	On i.EmployeeID = e.EmployeeID
	Group By InventoryDate
	Order By InventoryDate);
GO

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

create VIEW vInventoriesByProductsByCategories
with SCHEMABINDING
AS
	(Select top(10000000) CategoryName, ProductName, InventoryDate, [Count]
	From dbo.vCategories as c inner join dbo.vProducts as p
	On c.CategoryID = p.CategoryID
	Inner Join dbo.vInventories as i
	On p.ProductID = i.ProductID
	Order By CategoryName, ProductName, InventoryDate, Count);
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vInventoriesByProductsByEmployees
with SCHEMABINDING
AS
	(Select top(10000000) CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName as [Employee Name]
	From dbo.vCategories as c inner join dbo.vProducts as p
	On c.CategoryID = p.CategoryID
	Inner Join dbo.vInventories as i
	On p.ProductID = i.ProductID
	Inner Join dbo.vEmployees as e
	On i.EmployeeID = e.EmployeeID
	Order By InventoryDate, CategoryName, ProductName, [Employee Name]);
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vInventoriesForChaiAndChangByEmployees
with Schemabinding 
AS
	(Select top(10000000) CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName as [Employee Name]
	From dbo.vCategories as c inner join dbo.vProducts as p
	On c.CategoryID = p.CategoryID
	Inner Join dbo.vInventories as i
	On p.ProductID = i.ProductID
	Inner Join dbo.vEmployees as e
	On i.EmployeeID = e.EmployeeID
	Where ProductName IN ('Chai', 'Chang')
	Order By InventoryDate, CategoryName, ProductName, [Employee Name]);
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View vEmployeesByManager
with SCHEMABINDING
AS
	(Select top (100000000)
 		[Employee] = (Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName),
		[Manager] = (Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName)
	From dbo.vEmployees as Emp Inner Join dbo.vEmployees as Mgr
	On 	Emp.ManagerID = Mgr.EmployeeID 
	Order By 1); 
Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

Create View vInventoriesByProductsByCategoriesByEmployees
with SCHEMABINDING
AS
	(Select top(10000000) 
		c.CategoryID, c.CategoryName,
		p. ProductID, p.ProductName, p.UnitPrice,
		i.InventoryID, i.InventoryDate, i.Count, 
		e.EmployeeID, [Employee] = (e.EmployeeFirstName + ' ' + e.EmployeeLastName),
		[Manager] = (m.EmployeeFirstName + ' ' + m.EmployeeLastName)
	From dbo.vCategories as c inner join dbo.vProducts as p
	On c.CategoryID = p.CategoryID
	Inner Join dbo.vInventories as i
	On p.ProductID = i.ProductID
	Inner Join dbo.vEmployees as e
	On i.EmployeeID = e.EmployeeID
	Inner Join dbo.vEmployees as m 
	On 	e.ManagerID = m.EmployeeID 
	Order By CategoryName, ProductName, InventoryID);
GO


/***************************************************************************************/

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/
