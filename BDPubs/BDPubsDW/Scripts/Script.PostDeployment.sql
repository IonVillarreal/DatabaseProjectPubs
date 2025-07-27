/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

PRINT 'Ejecutando scripts post-deployment...';

-- Ejecutar scripts de datos
:r .\PackageConfig.data.sql	
:r .\DimDate.data.sql	

PRINT 'Scripts post-deployment completados exitosamente';
GO