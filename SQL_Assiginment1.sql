






CREATE DATABASE Manufacturer_;
GO;

USE Manufacturer_;
GO;

CREATE TABLE Product (
				product_ID int PRIMARY KEY NOT NULL,
				product_name nvarchar(50) NOT NULL, 
				product_quantity int
				);


CREATE TABLE Component (
						component_ID int PRIMARY KEY NOT NULL, 
						component_name nvarchar(50) NOT NULL, 
						component_desc nvarchar(250) NOT NULL,
						component_quantity int
						);
						

CREATE TABLE Supplier (
				supplier_ID int PRIMARY KEY NOT NULL,
				supplier_name nvarchar(50) NOT NULL, 
				activation_status bit
				);


CREATE TABLE Supplier_Component (
						supplier_ID int,
						component_ID int,
						supplied_date date, 
						supplied_quantity int,
						PRIMARY KEY (supplier_ID, component_ID)
						);

CREATE TABLE Product_Component (
						product_ID int NOT NULL,
						component_ID int NOT NULL,
						PRIMARY KEY (product_ID, component_ID)
						);


ALTER TABLE Supplier_Component ADD CONSTRAINT supplier_fk FOREIGN KEY (supplier_ID) REFERENCES Supplier (supplier_ID);

ALTER TABLE Supplier_Component ADD CONSTRAINT component_fk1 FOREIGN KEY (component_ID) REFERENCES Component (component_ID);

ALTER TABLE Product_Component ADD CONSTRAINT product_fk FOREIGN KEY (product_ID) REFERENCES Product (product_ID);

ALTER TABLE Product_Component ADD CONSTRAINT component_fk2 FOREIGN KEY (component_ID) REFERENCES Component (component_ID);