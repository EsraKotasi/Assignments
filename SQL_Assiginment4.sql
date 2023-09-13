
----
----Create a scalar-valued function that returns the factorial of a number you gave it.


CREATE FUNCTION factorial(@number Int)
RETURNS INT
AS
BEGIN
	DECLARE @product INT = 1
	DECLARE @i INT = 1

	WHILE @number >=@i
	BEGIN
		SET @product = @product*@i
		SET @i = @i+1
	END

	RETURN @product
END;

SELECT dbo.factorial(6)


