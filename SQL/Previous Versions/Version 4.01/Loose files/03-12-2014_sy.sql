IF NOT EXISTS
(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SobekCM_QC_Errors]') AND type in (N'U'))
BEGIN
CREATE TABLE SobekCM_QC_Errors
	(
	ErrorID bigint NOT NULL IDENTITY (1, 1),
	ItemID int NOT NULL,
	FileName nvarchar(MAX) NOT NULL,
	ErrorCode nchar(10) NOT NULL,
	isVolumeError bit NULL,
	Description nvarchar(MAX) NULL
	)  ON [PRIMARY]
	 TEXTIMAGE_ON [PRIMARY]
END
GO
ALTER TABLE SobekCM_QC_Errors ADD CONSTRAINT
	PK_Table_1 PRIMARY KEY CLUSTERED 
	(
	ErrorID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

ALTER TABLE [dbo].[SobekCM_QC_Errors]
  ADD CONSTRAINT ItemID_FK FOREIGN KEY (ItemID) references SobekCM_Item(ItemID)

GO




-- Ensure the stored procedure exists
IF object_id('SobekCM_QC_Save_Error') IS NULL EXEC ('create procedure dbo.SobekCM_QC_Save_Error as select 1;');
GO


ALTER PROCEDURE SobekCM_QC_Save_Error 
	-- Add the parameters for the stored procedure here
	@itemID int,
	@filename nvarchar(MAX),
	@errorCode nchar(10),
	@isVolumeError bit,
	@description nvarchar(MAX),
	@errorID int out
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

if not exists(select * from SobekCM_QC_Errors where ItemID=@itemID and [FileName]=@filename)
Begin
    -- Insert statements for procedure here
	INSERT INTO SobekCM_QC_Errors(ItemID, [FileName],ErrorCode,isVolumeError,[Description])
    VALUES(@itemID,@filename,@errorCode, @isVolumeError, @description);
 End
 else
 Begin
	 Update SobekCM_QC_Errors set ErrorCode=@errorCode, isVolumeError=@isVolumeError,[Description]=@description
	 where ItemID=@itemID AND [FileName]=@filename;
 
 End
  set @errorID=@@IDENTITY;   	
END
GO


--Stored Procedure to get all the associated QC page errors by ItemID
-- Ensure the stored procedure exists
IF object_id('SobekCM_QC_Get_Errors') IS NULL EXEC ('create procedure dbo.SobekCM_QC_Get_Errors as select 1;');
GO


ALTER PROCEDURE SobekCM_QC_Get_Errors
	-- Add the parameters for the stored procedure here
	@itemID int

	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT * FROM SobekCM_QC_Errors WHERE ItemID=@itemID; 
     	
END
GO


--Stored Procedure to delete a QC error for a single page for an item
-- Ensure the stored procedure exists
IF object_id('SobekCM_QC_Delete_Error') IS NULL EXEC ('create procedure dbo.SobekCM_QC_Delete_Error as select 1;');
GO


ALTER PROCEDURE SobekCM_QC_Delete_Error
	-- Add the parameters for the stored procedure here
	@itemID int,
	@filename nvarchar(MAX)

	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
DELETE FROM SobekCM_QC_Errors WHERE ItemID=@itemID AND [FileName]=@filename;
     	
END
GO



/****** Object:  StoredProcedure [dbo].[SobekCM_QC_Save_Error]    Script Date: 05/06/2014 17:19:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SobekCM_QC_Save_Error] 
	-- Add the parameters for the stored procedure here
	@itemID int,
	@filename nvarchar(MAX),
	@errorCode nchar(10),
	@isVolumeError bit,
	@description nvarchar(MAX),
	@errorID int out
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Insert this error into the SobekCM_QC_Errors Table
if not exists(select * from SobekCM_QC_Errors where ItemID=@itemID and [FileName]=@filename)
Begin
    -- Insert statements for procedure here
	INSERT INTO SobekCM_QC_Errors(ItemID, [FileName],ErrorCode,isVolumeError,[Description])
    VALUES(@itemID,@filename,@errorCode, @isVolumeError, @description);
 End
 else
 Begin
	 Update SobekCM_QC_Errors set ErrorCode=@errorCode, isVolumeError=@isVolumeError,[Description]=@description
	 where ItemID=@itemID AND [FileName]=@filename;
 
 End
  set @errorID=@@IDENTITY;   
  
  --Also add this error into the the errors History	table
  if not exists(select * from SobekCM_QC_Errors_History where ItemID=@itemID and ErrorCode=@errorCode)
    BEGIN
        INSERT INTO SobekCM_QC_Errors_History(ItemID,ErrorCode,isVolumeError,[Count])
        VALUES(@itemID,@errorCode,@isVolumeError,1);
    END
    else
    Begin
      Declare @errorCount int
      select @errorCount = [Count] from SobekCM_QC_Errors_History
      where ItemID=@itemID and ErrorCode=@errorCode;
      
      update SobekCM_QC_Errors_History set [Count]=(@errorCount+1)
      where ItemID=@itemID and ErrorCode=@errorCode; 
    End
END




GRANT EXECUTE ON [dbo].[SobekCM_QC_Delete_Error] to sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_QC_Get_Errors] to sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_QC_Save_Error] to sobek_user;