/** Upgrades the database for a SobekCM system to Version 4.10.1 from Verrsion 4.10.0 **/

-- Add or move TEI viewer up
if ( not exists ( select 1 from SobekCM_Item_Viewer_Types where ViewType='TEI' ))
begin
	insert into SobekCM_Item_Viewer_Types ( ViewType, [Order], DefaultView, MenuOrder )
	values ( 'TEI', 1, 'false', 125 );
end
else
begin
	update SobekCM_Item_Viewer_Types set [Order]=1 where ViewType='TEI';
end;
GO

 -- Add a setting flag to show the result count in text, if not there
 if ( not exists ( select 1 from SobekCM_Settings where Setting_Key = 'Include Result Count In Text' ))
begin
	insert into SobekCM_Settings ( Setting_Key, Setting_Value, TabPage, Heading, Hidden, Reserved, Help, Options, Dimensions )
	values ( 'Include Result Count In Text','true','General Settings','Search Settings','0',0,'When this is set to TRUE, the result count will be displayed in the search explanation text ( i.e., Your search for ... resulted in 2 results ).  Setting this to FALSE will not show the final portion in that text.','true|false','');
end;
GO

-- Add a setting for the Ace editor theme
if ( not exists ( select 1 from SobekCM_Settings where Setting_Key = 'Ace Editor Theme' ))
begin
	insert into SobekCM_Settings ( Setting_Key, Setting_Value, TabPage, Heading, Hidden, Reserved, Help, Options, Dimensions ) 
	values ( 'Ace Editor Theme','chrome','General Settings','UI Settings','0',0,'Set the theme for the Ace editor, used for CSS and Javascript editing, as well as TEI editing, if that plug-in is enabled.','{ACE_THEMES}','');
end;
GO


-- INCREASE THE SORT TITLE COLUMN LENGTH
-- There may be a dependency on the sort title (default value)?
DECLARE @var0 nvarchar(128);

SELECT @var0 = name
FROM sys.default_constraints
WHERE parent_object_id = object_id(N'dbo.SobekCM_Item_Group')
AND col_name(parent_object_id, parent_column_id) = 'SortTitle';

IF ( @var0 IS NOT NULL )
begin
    EXECUTE('ALTER TABLE [dbo].[SobekCM_Item_Group] DROP CONSTRAINT [' + @var0 + ']');
end;
GO

alter table SobekCM_Item_Group alter column SortTitle nvarchar(1000) not null;
GO

ALTER TABLE [dbo].[SobekCM_Item_Group] ADD  DEFAULT ('') FOR [SortTitle];
GO

-- Move where the Document Solr Index URL setting displays
update SobekCM_Settings set Heading='Server Settings' where Setting_Key='Document Solr Index URL';
GO


IF object_id('mySobek_Get_All_User_Settings_Like') IS NULL EXEC ('create procedure dbo.mySobek_Get_All_User_Settings_Like as select 1;');
GO


-- Procedure gets settings across all the users that are like the key start
--
-- Since this uses like, you can pass in a string like 'TEI.%' and that will return
-- all the values that have a setting key that STARTS with 'TEI.'
--
-- If @value is NULL, then all settings that match are returned.  If a value is
-- provided for @value, then only the settings that match the key search and 
-- have the same value in the database as @value are returned.  This is particularly
-- useful for boolean settings, where you only want to the see the settings set to 'true'
ALTER PROCEDURE mySobek_Get_All_User_Settings_Like
	@keyStart nvarchar(255),
	@value nvarchar(max)
AS
begin

	-- User can request settings that are only one value (useful for boolean settings really)
	if ( @value is null )
	begin
	
		-- Just return all that are like the setting key
		select U.UserName, U.UserID, coalesce(U.FirstName,'') as FirstName, coalesce(U.LastName,'') as LastName, S.Setting_Key, S.Setting_Value
		from mySobek_User U, mySobek_User_Settings S
		where ( U.UserID = S.UserID )
		  and ( Setting_Key like @keyStart )
		  and ( U.isActive = 'true' );

	end
	else
	begin
		
		-- Return information on settings like the setting key and set to @value then
		select U.UserName, U.UserID, coalesce(U.FirstName,'') as FirstName, coalesce(U.LastName,'') as LastName, S.Setting_Key, S.Setting_Value
		from mySobek_User U, mySobek_User_Settings S
		where ( U.UserID = S.UserID )
		  and ( Setting_Key like @keyStart )
		  and ( U.isActive = 'true' )
		  and ( Setting_Value = @value );
	end;

end;
GO

GRANT EXECUTE ON mySobek_Get_All_User_Settings_Like to sobek_user;
GO

ALTER PROCEDURE [dbo].[mySobek_Get_User_By_UserID]
	@userid int
AS
BEGIN

	-- No need to perform any locks here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- Get the basic user information
	select UserID, ShibbID=coalesce(ShibbID,''), UserName=coalesce(UserName,''), EmailAddress=coalesce(EmailAddress,''), 
	  FirstName=coalesce(FirstName,''), LastName=coalesce(LastName,''), Note_Length, 
	  Can_Make_Folders_Public, isTemporary_Password, sendEmailOnSubmission, Can_Submit_Items, 
	  NickName=coalesce(NickName,''), Organization=coalesce(Organization, ''), College=coalesce(College,''),
	  Department=coalesce(Department,''), Unit=coalesce(Unit,''), Rights=coalesce(Default_Rights,''), Language=coalesce(UI_Language, ''), 
	  Internal_User, OrganizationCode, EditTemplate, EditTemplateMarc, IsSystemAdmin, IsPortalAdmin, Include_Tracking_Standard_Forms,
	  Descriptions=( select COUNT(*) from mySobek_User_Description_Tags T where T.UserID=U.UserID),
	  Receive_Stats_Emails, Has_Item_Stats, Can_Delete_All_Items, ScanningTechnician, ProcessingTechnician, InternalNotes=coalesce(InternalNotes,''),
	  IsHostAdmin
	from mySobek_User U
	where ( UserID = @userid ) and ( isActive = 'true' );

	-- Get the templates
	select T.TemplateCode, T.TemplateName, GroupDefined='false', DefaultTemplate
	from mySobek_Template T, mySobek_User_Template_Link L
	where ( L.UserID = @userid ) and ( L.TemplateID = T.TemplateID )
	union
	select T.TemplateCode, T.TemplateName, GroupDefined='true', 'false'
	from mySobek_Template T, mySobek_User_Group_Template_Link TL, mySobek_User_Group_Link GL
	where ( GL.UserID = @userid ) and ( GL.UserGroupID = TL.UserGroupID ) and ( TL.TemplateID = T.TemplateID )
	order by DefaultTemplate DESC, TemplateCode ASC;
	
	-- Get the default metadata
	select P.MetadataCode, P.MetadataName, GroupDefined='false', CurrentlySelected
	from mySobek_DefaultMetadata P, mySobek_User_DefaultMetadata_Link L
	where ( L.UserID = @userid ) and ( L.DefaultMetadataID = P.DefaultMetadataID )
	union
	select P.MetadataCode, P.MetadataName, GroupDefined='true', 'false'
	from mySobek_DefaultMetadata P, mySobek_User_Group_DefaultMetadata_Link PL, mySobek_User_Group_Link GL
	where ( GL.UserID = @userid ) and ( GL.UserGroupID = PL.UserGroupID ) and ( PL.DefaultMetadataID = P.DefaultMetadataID )
	order by CurrentlySelected DESC, MetadataCode ASC;

	-- Get the bib id's of items submitted
	select distinct( G.BibID )
	from mySobek_User_Folder F, mySobek_User_Item B, SobekCM_Item I, SobekCM_Item_Group G
	where ( F.UserID = @userid ) and ( B.UserFolderID = F.UserFolderID ) and ( F.FolderName = 'Submitted Items' ) and ( B.ItemID = I.ItemID ) and ( I.GroupID = G.GroupID );

	-- Get the regular expression for editable items
	select R.EditableRegex, GroupDefined='false', CanEditMetadata, CanEditBehaviors, CanPerformQc, CanUploadFiles, CanChangeVisibility, CanDelete
	from mySobek_Editable_Regex R, mySobek_User_Editable_Link L
	where ( L.UserID = @userid ) and ( L.EditableID = R.EditableID )
	union
	select R.EditableRegex, GroupDefined='true', CanEditMetadata, CanEditBehaviors, CanPerformQc, CanUploadFiles, CanChangeVisibility, CanDelete
	from mySobek_Editable_Regex R, mySobek_User_Group_Editable_Link L, mySobek_User_Group_Link GL
	where ( GL.UserID = @userid ) and ( GL.UserGroupID = L.UserGroupID ) and ( L.EditableID = R.EditableID );

	-- Get the list of aggregations associated with this user
	select A.Code, A.[Name], L.CanSelect, L.CanEditItems, L.IsAdmin AS IsAggregationAdmin, L.OnHomePage, L.IsCurator AS IsCollectionManager, GroupDefined='false', CanEditMetadata, CanEditBehaviors, CanPerformQc, CanUploadFiles, CanChangeVisibility, CanDelete
	from SobekCM_Item_Aggregation A, mySobek_User_Edit_Aggregation L
	where  ( L.AggregationID = A.AggregationID ) and ( L.UserID = @userid )
	union
	select A.Code, A.[Name], L.CanSelect, L.CanEditItems, L.IsAdmin AS IsAggregationAdmin, OnHomePage = 'false', L.IsCurator AS IsCollectionManager, GroupDefined='true', CanEditMetadata, CanEditBehaviors, CanPerformQc, CanUploadFiles, CanChangeVisibility, CanDelete
	from SobekCM_Item_Aggregation A, mySobek_User_Group_Edit_Aggregation L, mySobek_User_Group_Link GL
	where  ( L.AggregationID = A.AggregationID ) and ( GL.UserID = @userid ) and ( GL.UserGroupID = L.UserGroupID );

	-- Return the names of all the folders
	select F.FolderName, F.UserFolderID, ParentFolderID=isnull(F.ParentFolderID,-1), isPublic
	from mySobek_User_Folder F
	where ( F.UserID=@userid );

	-- Get the list of all items associated with a user folder (other than submitted items)
	select G.BibID, I.VID
	from mySobek_User_Folder F, mySobek_User_Item B, SobekCM_Item I, SobekCM_Item_Group G
	where ( F.UserID = @userid ) and ( B.UserFolderID = F.UserFolderID ) and ( F.FolderName != 'Submitted Items' ) and ( B.ItemID = I.ItemID ) and ( I.GroupID = G.GroupID );
	
	-- Get the list of all user groups associated with this user
	select G.GroupName, Can_Submit_Items, Internal_User, IsSystemAdmin, IsPortalAdmin, Include_Tracking_Standard_Forms 
	from mySobek_User_Group G, mySobek_User_Group_Link L
	where ( G.UserGroupID = L.UserGroupID )
	  and ( L.UserID = @userid );
	  
	-- Get the user settings
	select * from mySobek_User_Settings where UserID=@userid order by Setting_Key;
	  
	-- Update the user table to include this as the last activity
	update mySobek_User
	set LastActivity = getdate()
	where UserID=@userid;
END;
GO

IF object_id('SobekCM_Set_Item_Setting_Value') IS NULL EXEC ('create procedure dbo.SobekCM_Set_Item_Setting_Value as select 1;');
GO

-- Sets a single item setting value, by key.  Adds a new one if this
-- is a new setting key, otherwise updates the existing value.
ALTER PROCEDURE [dbo].[SobekCM_Set_Item_Setting_Value]
	@ItemID int,
	@Setting_Key varchar(255),
	@Setting_Value varchar(max)
AS
BEGIN

	-- Does this setting exist?
	if ( ( select COUNT(*) from SobekCM_Item_Settings where Setting_Key=@Setting_Key and ItemID=@ItemID ) > 0 )
	begin
		-- Just update existing then
		update SobekCM_Item_Settings set Setting_Value=@Setting_Value where Setting_Key = @Setting_Key and ItemID=@ItemID;
	end
	else
	begin
		-- insert a new settting key/value pair
		insert into SobekCM_Item_Settings( ItemID, Setting_Key, Setting_Value )
		values ( @ItemID, @Setting_Key, @Setting_Value );
	end;	
END;
GO

GRANT EXECUTE ON [dbo].[SobekCM_Set_Item_Setting_Value] to sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_Set_Item_Setting_Value] to sobek_builder;
GO


-- Saves all the main data about an item in UFDC (but not behaviors)
-- Written by Mark Sullivan ( September 2005, Edited Decemver 2010 )
ALTER PROCEDURE [dbo].[SobekCM_Save_Item]
	@GroupID int,
	@VID varchar(5),
	@PageCount int,
	@FileCount int,
	@Title nvarchar(500),
	@SortTitle nvarchar(500), --NEW
	@AccessMethod int,
	@Link varchar(500),
	@CreateDate datetime,
	@PubDate nvarchar(100),
	@SortDate bigint,
	@HoldingCode varchar(20),
	@SourceCode varchar(20),
	@Author nvarchar(1000),
	@Spatial_KML varchar(4000),
	@Spatial_KML_Distance float,
	@DiskSize_KB bigint,
	@Spatial_Display nvarchar(1000), 
	@Institution_Display nvarchar(1000), 
	@Edition_Display nvarchar(1000),
	@Material_Display nvarchar(1000),
	@Measurement_Display nvarchar(1000), 
	@StylePeriod_Display nvarchar(1000), 
	@Technique_Display nvarchar(1000), 
	@Subjects_Display nvarchar(1000), 
	@Donor nvarchar(250),
	@Publisher nvarchar(1000),
	@ItemID int output,
	@Existing bit output,
	@New_VID varchar(5) output
AS
begin transaction

	-- Set the return VID value first
	set @New_VID = @VID;

	-- If this already exists (BibID, VID) then just update
	if ( (	 select count(*) from SobekCM_Item I where ( I.VID = @VID ) and ( I.GroupID = @GroupID ) )  > 0 )
	begin
		-- Save the item id
		select @ItemID = I.ItemID
		from SobekCM_Item I
		where  ( I.VID = @VID ) and ( I.GroupID = @GroupID );

		--Update the main item
		update SobekCM_Item
		set [PageCount] = @PageCount, 
			Deleted = 0, Title=@Title, SortTitle=@SortTitle, AccessMethod=@AccessMethod, Link=@Link,
			PubDate=@PubDate, SortDate=@SortDate, FileCount=@FileCount, Author=@Author, 
			Spatial_KML=@Spatial_KML, Spatial_KML_Distance=@Spatial_KML_Distance,  
			Donor=@Donor, Publisher=@Publisher, 
			GroupID = GroupID, LastSaved=GETDATE(), Spatial_Display=@Spatial_Display, Institution_Display=@Institution_Display, 
			Edition_Display=@Edition_Display, Material_Display=@Material_Display, Measurement_Display=@Measurement_Display, 
			StylePeriod_Display=@StylePeriod_Display, Technique_Display=@Technique_Display, Subjects_Display=@Subjects_Display 
		where ( ItemID = @ItemID );

		-- Set the existing flag to true (1)
		set @Existing = 1;
	end
	else
	begin
	
		-- Verify the VID is a complete bibid, otherwise find the next one
		if ( LEN(@VID) < 5 )
		begin
			declare @next_vid_number int;

			-- Find the next vid number
			select @next_vid_number = isnull(CAST(MAX(VID) as int) + 1,-1)
			from SobekCM_Item
			where GroupID = @GroupID;
			
			-- If no matches to this BibID, just start at 00001
			if ( @next_vid_number < 0 )
			begin
				select @New_VID = '00001';
			end
			else
			begin
				select @New_VID = RIGHT('0000' + (CAST( @next_vid_number as varchar(5))), 5);	
			end;	
		end;
		
		-- Add the values to the main SobekCM_Item table first
		insert into SobekCM_Item ( VID, [PageCount], FileCount, Deleted, Title, SortTitle, AccessMethod, Link, CreateDate, PubDate, SortDate, Author, Spatial_KML, Spatial_KML_Distance, GroupID, LastSaved, Donor, Publisher, Spatial_Display, Institution_Display, Edition_Display, Material_Display, Measurement_Display, StylePeriod_Display, Technique_Display, Subjects_Display )
		values (  @New_VID, @PageCount, @FileCount, 0, @Title, @SortTitle, @AccessMethod, @Link, @CreateDate, @PubDate, @SortDate, @Author, @Spatial_KML, @Spatial_KML_Distance, @GroupID, GETDATE(), @Donor, @Publisher, @Spatial_Display, @Institution_Display, @Edition_Display, @Material_Display, @Measurement_Display, @StylePeriod_Display, @Technique_Display, @Subjects_Display  );

		-- Get the item id identifier for this row
		set @ItemID = @@identity;

		-- Set existing flag to false
		set @Existing = 0;
		
		-- Copy over all the default viewer information
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label, Exclude )
		select @itemid, ItemViewTypeID, '', '', 'false' 
		from SobekCM_Item_Viewer_Types
		where ( DefaultView = 'true' );
	end;

	-- Check for Holding Institution Code
	declare @AggregationID int;
	if ( len ( isnull ( @HoldingCode, '' ) ) > 0 )
	begin
		-- Does this institution already exist?
		if (( select count(*) from SobekCM_Item_Aggregation where Code = @HoldingCode ) = 0 )
		begin
			-- Add new institution
			insert into SobekCM_Item_Aggregation ( Code, [Name], ShortName, Description, ThematicHeadingID, [Type], isActive, Hidden, DisplayOptions, Map_Search, Map_Display, OAI_Flag, ContactEmail, HasNewItems )
			values ( @HoldingCode, 'Added automatically', 'Added automatically', 'Added automatically', -1, 'Institution', 'false', 'true', '', 0, 0, 'false', '', 'false' );
		end;
		
		-- Add the link to this holding code ( and any legitimate parent aggregations )
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @HoldingCode;		
	end;

	-- Check for Source Institution Code
	if ( len ( isnull ( @SourceCode, '' ) ) > 0 )
	begin
		-- Does this institution already exist?
		if (( select count(*) from SobekCM_Item_Aggregation where Code = @SourceCode ) = 0 )
		begin
			-- Add new institution
			insert into SobekCM_Item_Aggregation ( Code, [Name], ShortName, Description, ThematicHeadingID, [Type], isActive, Hidden, DisplayOptions, Map_Search, Map_Display, OAI_Flag, ContactEmail, HasNewItems )
			values ( @SourceCode, 'Added automatically', 'Added automatically', 'Added automatically', -1, 'Institution', 'false', 'true', '', 0, 0, 'false', '', 'false' );
		end;

		-- Add the link to this holding code ( and any legitimate parent aggregations )
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @SourceCode;	
	end;
	
	-- If a size was included, set that value
	if ( @DiskSize_KB > 0 )
	begin
		update SobekCM_Item set DiskSize_KB = @DiskSize_KB where ItemID=@ItemID;
	end;

	-- Finally set the volume count for this group correctly
	declare @itemcount int;
	set @itemcount = ( select count(*) from SobekCM_Item I where ( I.GroupID = @GroupID ) and ( I.Deleted = 'false' ));

	-- Update the item group count
	update SobekCM_Item_Group
	set ItemCount = @itemcount
	where GroupID = @GroupID;

	-- If this was an update, and this group had only this one VID, look at changing the
	-- group title to match the item title
	if (( @Existing = 1 ) and ( @itemcount = 1 ))
	begin
		-- Only make this update if this is not a SERIAL or NEWSPAPER
		if ( exists ( select 1 from SobekCM_Item_Group where GroupID=@GroupID and [Type] != 'Serial' and [Type] != 'Newspaper' ))
		begin
			update SobekCM_Item_Group 
			set GroupTitle = @Title, SortTitle = @SortTitle
			where GroupID=@GroupID;
		end;
	end;

commit transaction;
GO



-- Saves the behavior information about an item in this library
-- Written by Mark Sullivan 
ALTER PROCEDURE [dbo].[SobekCM_Save_Item_Behaviors]
	@ItemID int,
	@TextSearchable bit,
	@MainThumbnail varchar(100),
	@MainJPEG varchar(100),
	@IP_Restriction_Mask smallint,
	@CheckoutRequired bit,
	@Dark_Flag bit,
	@Born_Digital bit,
	@Disposition_Advice int,
	@Disposition_Advice_Notes varchar(150),
	@Material_Received_Date datetime,
	@Material_Recd_Date_Estimated bit,
	@Tracking_Box varchar(25),
	@AggregationCode1 varchar(20),
	@AggregationCode2 varchar(20),
	@AggregationCode3 varchar(20),
	@AggregationCode4 varchar(20),
	@AggregationCode5 varchar(20),
	@AggregationCode6 varchar(20),
	@AggregationCode7 varchar(20),
	@AggregationCode8 varchar(20),
	@HoldingCode varchar(20),
	@SourceCode varchar(20),
	@Icon1_Name varchar(50),
	@Icon2_Name varchar(50),
	@Icon3_Name varchar(50),
	@Icon4_Name varchar(50),
	@Icon5_Name varchar(50),
	@Left_To_Right bit,
	@CitationSet varchar(50)
AS
begin transaction

	--Update the main item
	update SobekCM_Item
	set TextSearchable = @TextSearchable, Deleted = 0, MainThumbnail=@MainThumbnail,
		MainJPEG=@MainJPEG, CheckoutRequired=@CheckoutRequired, IP_Restriction_Mask=@IP_Restriction_Mask,
		Dark=@Dark_Flag, Born_Digital=@Born_Digital, Disposition_Advice=@Disposition_Advice,
		Material_Received_Date=@Material_Received_Date, Material_Recd_Date_Estimated=@Material_Recd_Date_Estimated,
		Tracking_Box=@Tracking_Box, Disposition_Advice_Notes = @Disposition_Advice_Notes, Left_To_Right=@Left_To_Right,
		CitationSet=@CitationSet
	where ( ItemID = @ItemID )

	-- Clear the links to all existing icons
	delete from SobekCM_Item_Icons where ItemID=@ItemID
	
	-- Add the first icon to this object  (this requires the icons have been pre-established )
	declare @IconID int
	if ( len( isnull( @Icon1_Name, '' )) > 0 ) 
	begin
		-- Get the Icon ID for this icon
		select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon1_Name

		-- Tie this item to this icon
		if ( ISNULL(@IconID,-1) > 0 )
		begin
			insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
			values ( @ItemID, @IconID, 1 )
		end
	end

	-- Add the second icon to this object  (this requires the icons have been pre-established )
	if ( len( isnull( @Icon2_Name, '' )) > 0 ) 
	begin
		-- Get the Icon ID for this icon
		select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon2_Name

		-- Tie this item to this icon
		if (( ISNULL(@IconID,-1) > 0 )  and ( not exists ( select 1 from SobekCM_Item_Icons where ItemID=@ItemID and IconID=@IconID )))
		begin
			insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
			values ( @ItemID, @IconID, 2 )
		end
	end

	-- Add the third icon to this object  (this requires the icons have been pre-established )
	if ( len( isnull( @Icon3_Name, '' )) > 0 ) 
	begin
		-- Get the Icon ID for this icon
		select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon3_Name

		-- Tie this item to this icon
		if (( ISNULL(@IconID,-1) > 0 ) and ( not exists ( select 1 from SobekCM_Item_Icons where ItemID=@ItemID and IconID=@IconID )))
		begin
			insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
			values ( @ItemID, @IconID, 3 )
		end
	end

	-- Add the fourth icon to this object  (this requires the icons have been pre-established )
	if ( len( isnull( @Icon4_Name, '' )) > 0 ) 
	begin
		-- Get the Icon ID for this icon
		select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon4_Name
		
		-- Tie this item to this icon
		if (( ISNULL(@IconID,-1) > 0 ) and ( not exists ( select 1 from SobekCM_Item_Icons where ItemID=@ItemID and IconID=@IconID )))
		begin
			insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
			values ( @ItemID, @IconID, 4 )
		end
	end

	-- Add the fifth icon to this object  (this requires the icons have been pre-established )
	if ( len( isnull( @Icon5_Name, '' )) > 0 ) 
	begin
		-- Get the Icon ID for this icon
		select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon5_Name

		-- Tie this item to this icon
		if (( ISNULL(@IconID,-1) > 0 ) and ( not exists ( select 1 from SobekCM_Item_Icons where ItemID=@ItemID and IconID=@IconID )))
		begin
			insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
			values ( @ItemID, @IconID, 5 )
		end
	end

	-- Clear all links to aggregations
	delete from SobekCM_Item_Aggregation_Item_Link where ItemID = @ItemID

	-- Add all of the aggregations
	exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode1
	exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode2
	exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode3
	exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode4
	exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode5
	exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode6
	exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode7
	exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode8
	
	-- Create one string of all the aggregation codes
	declare @aggregationCodes varchar(100)
	set @aggregationCodes = rtrim(isnull(@AggregationCode1,'') + ' ' + isnull(@AggregationCode2,'') + ' ' + isnull(@AggregationCode3,'') + ' ' + isnull(@AggregationCode4,'') + ' ' + isnull(@AggregationCode5,'') + ' ' + isnull(@AggregationCode6,'') + ' ' + isnull(@AggregationCode7,'') + ' ' + isnull(@AggregationCode8,''))
	
	-- Update matching items to have the aggregation codes value
	update SobekCM_Item set AggregationCodes = @aggregationCodes where ItemID=@ItemID

	-- Check for Holding Institution Code
	declare @AggregationID int
	if ( len ( isnull ( @HoldingCode, '' ) ) > 0 )
	begin
		-- Does this institution already exist?
		if (( select count(*) from SobekCM_Item_Aggregation where Code = @HoldingCode ) = 0 )
		begin
			-- Add new institution
			insert into SobekCM_Item_Aggregation ( Code, [Name], ShortName, Description, ThematicHeadingID, [Type], isActive, Hidden, DisplayOptions, Map_Search, Map_Display, OAI_Flag, ContactEmail, HasNewItems )
			values ( @HoldingCode, 'Added automatically', 'Added automatically', 'Added automatically', -1, 'Institution', 'false', 'true', '', 0, 0, 'false', '', 'false' )
		end
		
		-- Add the link to this holding code ( and any legitimate parent aggregations )
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @HoldingCode		
	end

	-- Check for Source Institution Code
	if ( len ( isnull ( @SourceCode, '' ) ) > 0 )
	begin
		-- Does this institution already exist?
		if (( select count(*) from SobekCM_Item_Aggregation where Code = @SourceCode ) = 0 )
		begin
			-- Add new institution
			insert into SobekCM_Item_Aggregation ( Code, [Name], ShortName, Description, ThematicHeadingID, [Type], isActive, Hidden, DisplayOptions, Map_Search, Map_Display, OAI_Flag, ContactEmail, HasNewItems )
			values ( @SourceCode, 'Added automatically', 'Added automatically', 'Added automatically', -1, 'Institution', 'false', 'true', '', 0, 0, 'false', '', 'false' )
		end

		-- Add the link to this holding code ( and any legitimate parent aggregations )
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @SourceCode	
	end	
	
commit transaction;
GO


-- Log an email which was sent through a different method.  This does not
-- cause a database mail to be sent, just logs an email which was sent
ALTER PROCEDURE [dbo].[SobekCM_Log_Email] 
	@sender varchar(250),
	@recipients_list varchar(500),
	@subject_line varchar(240),
	@email_body nvarchar(max),
	@html_format bit,
	@contact_us bit,
	@replytoemailid int
AS
begin

	-- Log this email
	insert into SobekCM_Email_Log( Sender, Receipt_List, Subject_Line, Email_Body, Sent_Date, HTML_Format, Contact_Us, ReplyToEmailID )
	values ( @sender, @recipients_list, @subject_line + '( log only )', @email_body, GETDATE(), @html_format, @contact_us, @replytoemailid );
	
end;
GO


-- Sends an email via database mail and additionally logs that the email was sent
ALTER PROCEDURE [dbo].[SobekCM_Send_Email] 
	@recipients_list varchar(250),
	@subject_line varchar(500),
	@email_body nvarchar(max),
	@from_address nvarchar(250),
	@reply_to nvarchar(250), 
	@html_format bit,
	@contact_us bit,
	@replytoemailid int,
	@userid int
AS
begin transaction

	if (( @userid < 0 ) or (( select count(*) from SobekCM_Email_Log where UserID = @userid and Sent_Date > DateAdd( DAY, -1, GETDATE())) < 20 ))
	begin

		-- Look for an exact match for the recipients_list.  One recipient list should AT MOST get 250 emails over a 24 hours period
		if ( ( select count(*) from SobekCM_Email_Log where Receipt_List=@recipients_list and Sent_Date > DateAdd( DAY, -1, GETDATE())) > 250 )
		begin
			-- Just add this to the email log, but indicate not sent
			insert into SobekCM_Email_Log( Sender, Receipt_List, Subject_Line, Email_Body, Sent_Date, HTML_Format, Contact_Us, ReplyToEmailId, UserID )
			values ( 'sobekcm noreply profile', @recipients_list, @subject_line + '(not delivered)', 'Too many emails to this recipient list in last 24 hours.  Governer kicked in and this email was not sent.   ' + @email_body, GETDATE(), @html_format, @contact_us, @replytoemailid, @userid );

		end
		else
		begin

			-- Log this email
			insert into SobekCM_Email_Log( Sender, Receipt_List, Subject_Line, Email_Body, Sent_Date, HTML_Format, Contact_Us, ReplyToEmailId, UserID )
			values ( 'sobekcm noreply profile', @recipients_list, @subject_line, @email_body, GETDATE(), @html_format, @contact_us, @replytoemailid, @userid );
		
			-- Send the email
			if ( @html_format = 'true' )
			begin
				if ( len(coalesce(@from_address,'')) > 0 )
				begin
					if ( len(coalesce(@reply_to,'')) > 0 )
					begin
						EXEC msdb.dbo.sp_send_dbmail
							@profile_name= 'sobekcm noreply profile',
							@recipients = @recipients_list,
							@body = @email_body,
							@subject = @subject_line,
							@body_format = 'html',
							@from_address = @from_address,
							@reply_to = @reply_to;
					end
					else
					begin
						EXEC msdb.dbo.sp_send_dbmail
							@profile_name= 'sobekcm noreply profile',
							@recipients = @recipients_list,
							@body = @email_body,
							@subject = @subject_line,
							@body_format = 'html',
							@from_address = @from_address;
					end;
				end
				else
				begin
					if ( len(coalesce(@reply_to,'')) > 0 )
					begin
						EXEC msdb.dbo.sp_send_dbmail
							@profile_name= 'sobekcm noreply profile',
							@recipients = @recipients_list,
							@body = @email_body,
							@subject = @subject_line,
							@body_format = 'html',
							@reply_to = @reply_to;
					end
					else
					begin
						EXEC msdb.dbo.sp_send_dbmail
							@profile_name= 'sobekcm noreply profile',
							@recipients = @recipients_list,
							@body = @email_body,
							@subject = @subject_line,
							@body_format = 'html';
					end;
				end;
			end
			else
			begin
				if ( len(coalesce(@from_address,'')) > 0 )
				begin
					if ( len(coalesce(@reply_to,'')) > 0 )
					begin
						EXEC msdb.dbo.sp_send_dbmail
							@profile_name= 'sobekcm noreply profile',
							@recipients = @recipients_list,
							@body = @email_body,
							@subject = @subject_line,
							@from_address = @from_address,
							@reply_to = @reply_to;
					end
					else
					begin
						EXEC msdb.dbo.sp_send_dbmail
							@profile_name= 'sobekcm noreply profile',
							@recipients = @recipients_list,
							@body = @email_body,
							@subject = @subject_line,
							@from_address = @from_address;
					end;
				end
				else
				begin
					if ( len(coalesce(@reply_to,'')) > 0 )
					begin
						EXEC msdb.dbo.sp_send_dbmail
							@profile_name= 'sobekcm noreply profile',
							@recipients = @recipients_list,
							@body = @email_body,
							@subject = @subject_line,
							@reply_to = @reply_to;
					end
					else
					begin
						EXEC msdb.dbo.sp_send_dbmail
							@profile_name= 'sobekcm noreply profile',
							@recipients = @recipients_list,
							@body = @email_body,
							@subject = @subject_line;
					end;
				end;
			end;
		end;
	end;
	
commit transaction;
GO


ALTER PROCEDURE [dbo].[SobekCM_Metadata_Basic_Search_Paged2] 
	@searchcondition nvarchar(4000),
	@include_private bit,
	@aggregationcode varchar(20),
	@daterange_start bigint,
	@daterange_end bigint,
	@pagesize int, 
	@pagenumber int,
	@sort int,
	@minpagelookahead int,
	@maxpagelookahead int,
	@lookahead_factor float,
	@include_facets bit,
	@facettype1 smallint,
	@facettype2 smallint,
	@facettype3 smallint,
	@facettype4 smallint,
	@facettype5 smallint,
	@facettype6 smallint,
	@facettype7 smallint,
	@facettype8 smallint,
	@total_items int output,
	@total_titles int output,
	@all_collections_items int output,
	@all_collections_titles int output												
AS
BEGIN
	-- No need to perform any locks here, especially given the possible
	-- length of this search
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;

	-- Create the temporary tables first
	-- Create the temporary table to hold all the item id's
	create table #TEMP_ITEMS ( ItemID int primary key, fk_TitleID int, Hit_Count int, SortDate bigint );

	-- Determine the start and end rows
	declare @rowstart int; 
	declare @rowend int; 
	set @rowstart = (@pagesize * ( @pagenumber - 1 )) + 1;
	set @rowend = @rowstart + ( @pagesize * @minpagelookahead ) - 1; 

	-- Set value for filtering privates
	declare @lower_mask int;
	set @lower_mask = 0;
	if ( @include_private = 'true' )
	begin
		set @lower_mask = -256;
	end;
		
	-- Determine the aggregationid
	declare @aggregationid int;
	set @aggregationid = coalesce( (select AggregationID from SobekCM_Item_Aggregation where Code=@aggregationcode), -1 );
	
	-- Get the sql which will be used to return the aggregation-specific display values for all the items in this page of results
	declare @item_display_sql nvarchar(max);
	if ( @aggregationid < 0 )
	begin
		select @item_display_sql=coalesce(Browse_Results_Display_SQL, 'select S.ItemID, S.Publication_Date, S.Creator, S.[Publisher.Display], S.Format, S.Edition, S.Material, S.Measurements, S.Style_Period, S.Technique, S.[Subjects.Display], S.Source_Institution, S.Donor from SobekCM_Metadata_Basic_Search_Table S, @itemtable T where S.ItemID = T.ItemID order by T.RowNumber;')
		from SobekCM_Item_Aggregation
		where Code='all';
	end
	else
	begin
		select @item_display_sql=coalesce(Browse_Results_Display_SQL, 'select S.ItemID, S.Publication_Date, S.Creator, S.[Publisher.Display], S.Format, S.Edition, S.Material, S.Measurements, S.Style_Period, S.Technique, S.[Subjects.Display], S.Source_Institution, S.Donor from SobekCM_Metadata_Basic_Search_Table S, @itemtable T where S.ItemID = T.ItemID order by T.RowNumber;')
		from SobekCM_Item_Aggregation
		where AggregationID=@aggregationid;
	end;
	
	-- Perform the actual metadata search differently, depending on whether an aggregation was 
	-- included to limit this search
	if (( @daterange_end < 0 ) and ( @daterange_start < 0 ))
	begin
		if ( @aggregationid > 0 )
		begin		  
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, Hit_Count, SortDate )
			select CL.ItemID, I.GroupID, KEY_TBL.RANK, SortDate
			from SobekCM_Item AS I inner join
				 SobekCM_Item_Aggregation_Item_Link AS CL ON CL.ItemID = I.ItemID inner join
				 CONTAINSTABLE(SobekCM_Metadata_Basic_Search_Table, FullCitation, @SearchCondition ) AS KEY_TBL on KEY_TBL.[KEY] = I.ItemID
			where ( I.Deleted = 'false' )
			  and ( CL.AggregationID = @aggregationid )
			  and ( I.IP_Restriction_Mask >= @lower_mask )
			  and ( I.Dark = 'false' );
		end
		else
		begin	
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, Hit_Count, SortDate )
			select I.ItemID, I.GroupID, KEY_TBL.RANK, SortDate
			from SobekCM_Item AS I inner join
				 CONTAINSTABLE(SobekCM_Metadata_Basic_Search_Table, FullCitation, @SearchCondition ) AS KEY_TBL on KEY_TBL.[KEY] = I.ItemID
			where ( I.Deleted = 'false' )
			  and ( I.IP_Restriction_Mask >= @lower_mask ) 
			  and ( I.IncludeInAll = 'true' )
			  and ( I.Dark = 'false' );
		end;
	end
	else
	begin
		if ( @aggregationid > 0 )
		begin		  
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, Hit_Count, SortDate )
			select CL.ItemID, I.GroupID, KEY_TBL.RANK, SortDate
			from SobekCM_Item AS I inner join
				 SobekCM_Item_Aggregation_Item_Link AS CL ON CL.ItemID = I.ItemID inner join
				 CONTAINSTABLE(SobekCM_Metadata_Basic_Search_Table, FullCitation, @SearchCondition ) AS KEY_TBL on KEY_TBL.[KEY] = I.ItemID
			where ( I.Deleted = 'false' )
			  and ( CL.AggregationID = @aggregationid )
			  and ( I.IP_Restriction_Mask >= @lower_mask )
			  and ( I.Dark = 'false' )
			  and ( I.SortDate >= @daterange_start )
			  and ( I.SortDate <= @daterange_end );
		end
		else
		begin	
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, Hit_Count, SortDate )
			select I.ItemID, I.GroupID, KEY_TBL.RANK, SortDate
			from SobekCM_Item AS I inner join
				 CONTAINSTABLE(SobekCM_Metadata_Basic_Search_Table, FullCitation, @SearchCondition ) AS KEY_TBL on KEY_TBL.[KEY] = I.ItemID
			where ( I.Deleted = 'false' )
			  and ( I.IP_Restriction_Mask >= @lower_mask ) 
			  and ( I.IncludeInAll = 'true' )
			  and ( I.Dark = 'false' )			  
			  and ( I.SortDate >= @daterange_start )
			  and ( I.SortDate <= @daterange_end );
		end;	
	end;
	
	-- If there were no results at all, check the count in the entire library
	if ( ( select COUNT(*) from #TEMP_ITEMS ) = 0 )
	begin
		-- Set the items and titles correctly
		set @total_items = 0;
		set @total_titles = 0;
		
		-- If there was an aggregation id, just return the counts for the whole library
		if ( @aggregationid > 0 )	
		begin
			-- Get all items in the entire library then
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, Hit_Count, SortDate )
			select I.ItemID, I.GroupID, KEY_TBL.RANK, SortDate
			from SobekCM_Item AS I inner join
				CONTAINSTABLE(SobekCM_Metadata_Basic_Search_Table, FullCitation, @SearchCondition ) AS KEY_TBL on KEY_TBL.[KEY] = I.ItemID
			where ( I.Deleted = 'false' )
			  and ( I.IP_Restriction_Mask >= @lower_mask ) 
			  and ( I.IncludeInAll = 'true' )
			  and ( I.Dark = 'false' );
			  
			-- Return these counts
			select @all_collections_items=COUNT(*), @all_collections_titles=COUNT(distinct fk_TitleID)
			from #TEMP_ITEMS;		
		end;
	end
	else
	begin	
		-- Create the temporary item table variable for paging purposes
		declare @TEMP_PAGED_ITEMS TempPagedItemsTableType;
			
		-- There are essentially two major paths of execution, depending on whether this should
		-- be grouped as items within the page requested titles ( sorting by title or the basic
		-- sorting by rank, which ranks this way ) or whether each item should be
		-- returned by itself, such as sorting by individual publication dates, etc..	
		if ( @sort < 10 )
		begin	
			-- create the temporary title table definition
			declare @TEMP_TITLES table ( TitleID int, BibID varchar(10), RowNumber int);		
			
			-- Get the total counts
			select @total_items=COUNT(*), @total_titles=COUNT(distinct fk_TitleID)
			from #TEMP_ITEMS;
			
			-- Now, calculate the actual ending row, based on the ration, page information,
			-- and the lookahead factor
			if (( @total_items > 0 ) and ( @total_titles > 0 ))
			begin	
				-- Compute equation to determine possible page value ( max - log(factor, (items/title)/2))
				declare @computed_value int;
				select @computed_value = (@maxpagelookahead - CEILING( LOG10( ((cast(@total_items as float)) / (cast(@total_titles as float)))/@lookahead_factor)));
				
				-- Compute the minimum value.  This cannot be less than @minpagelookahead.
				declare @floored_value int;
				select @floored_value = 0.5 * ((@computed_value + @minpagelookahead) + ABS(@computed_value - @minpagelookahead));
				
				-- Compute the maximum value.  This cannot be more than @maxpagelookahead.
				declare @actual_pages int;
				select @actual_pages = 0.5 * ((@floored_value + @maxpagelookahead) - ABS(@floored_value - @maxpagelookahead)); 

				-- Set the final row again then
				set @rowend = @rowstart + ( @pagesize * @actual_pages ) - 1; 
			end;
					  
			-- Create saved select across titles for row numbers
			with TITLES_SELECT AS
				(	select GroupID, G.BibID, 
						ROW_NUMBER() OVER (order by case when @sort=0 THEN (SUM(Hit_COunt)/COUNT(*)) end DESC,
													case when @sort=1 THEN G.SortTitle end ASC,												
													case when @sort=2 THEN BibID end ASC,
													case when @sort=3 THEN BibID end DESC) as RowNumber
					from #TEMP_ITEMS I, SobekCM_Item_Group G
					where I.fk_TitleID = G.GroupID
					group by G.GroupID, G.BibID, G.SortTitle )

			-- Insert the correct rows into the temp title table	
			insert into @TEMP_TITLES ( TitleID, BibID, RowNumber )
			select GroupID, BibID, RowNumber
			from TITLES_SELECT
			where RowNumber >= @rowstart
			  and RowNumber <= @rowend;
			
			-- Return the title information for this page
			select RowNumber as TitleID, T.BibID, G.GroupTitle, G.ALEPH_Number as OPAC_Number, G.OCLC_Number, coalesce(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], coalesce(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, coalesce(G.Primary_Identifier, '') as Primary_Identifier
			from @TEMP_TITLES T, SobekCM_Item_Group G
			where ( T.TitleID = G.GroupID )
			order by RowNumber ASC;
			
			-- Get the item id's for the items related to these titles
			insert into @TEMP_PAGED_ITEMS
			select ItemID, RowNumber
			from @TEMP_TITLES T, SobekCM_Item I
			where ( T.TitleID = I.GroupID )
			  and ( I.Deleted = 'false' )
			  and ( I.IP_Restriction_Mask >= @lower_mask )
			  and ( I.Dark = 'false' );
			
			-- Return the basic system required item information for this page of results
			select T.RowNumber as fk_TitleID, I.ItemID, VID, Title, IP_Restriction_Mask, coalesce(I.MainThumbnail,'') as MainThumbnail, coalesce(I.Level1_Index, -1) as Level1_Index, coalesce(I.Level1_Text,'') as Level1_Text, coalesce(I.Level2_Index, -1) as Level2_Index, coalesce(I.Level2_Text,'') as Level2_Text, coalesce(I.Level3_Index,-1) as Level3_Index, coalesce(I.Level3_Text,'') as Level3_Text, isnull(I.PubDate,'') as PubDate, I.[PageCount], coalesce(I.Link,'') as Link, coalesce( Spatial_KML, '') as Spatial_KML, coalesce(COinS_OpenURL, '') as COinS_OpenURL		
			from SobekCM_Item I, @TEMP_PAGED_ITEMS T
			where ( T.ItemID = I.ItemID )
			order by T.RowNumber, Level1_Index, Level2_Index, Level3_Index;			
								
			-- Return the aggregation-specific display values for all the items in this page of results
			execute sp_Executesql @item_display_sql, N' @itemtable TempPagedItemsTableType READONLY', @TEMP_PAGED_ITEMS; 		
		end
		else
		begin
		
			-- Since these sorts make each item paired with a single title row,
			-- number of items and titles are equal
			select @total_items=COUNT(*), @total_titles=COUNT(*)
			from #TEMP_ITEMS;
			
			-- In addition, always return the max lookahead pages
			set @rowend = @rowstart + ( @pagesize * @maxpagelookahead ) - 1; 

			-- Create saved select across items for row numbers
			with ITEMS_SELECT AS
			 (	select I.ItemID, 
					ROW_NUMBER() OVER (order by case when @sort=10 THEN coalesce(SortDate,9223372036854775807)  end ASC,
												case when @sort=11 THEN coalesce(SortDate,-1) end DESC) as RowNumber
					from #TEMP_ITEMS I
					group by I.ItemID, SortDate )
						  
			-- Insert the correct rows into the temp item table	
			insert into @TEMP_PAGED_ITEMS ( ItemID, RowNumber )
			select ItemID, RowNumber
			from ITEMS_SELECT
			where RowNumber >= @rowstart
			  and RowNumber <= @rowend;
			  
			-- Return the title information for this page
			select RowNumber as TitleID, G.BibID, G.GroupTitle, G.ALEPH_Number as OPAC_Number, G.OCLC_Number, coalesce(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], coalesce(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, coalesce(G.Primary_Identifier, '') as Primary_Identifier
			from @TEMP_PAGED_ITEMS T, SobekCM_Item I, SobekCM_Item_Group G
			where ( T.ItemID = I.ItemID )
			  and ( I.GroupID = G.GroupID )
			order by RowNumber ASC;
			
			-- Return the basic system required item information for this page of results
			select T.RowNumber as fk_TitleID, I.ItemID, VID, Title, IP_Restriction_Mask, coalesce(I.MainThumbnail,'') as MainThumbnail, coalesce(I.Level1_Index, -1) as Level1_Index, coalesce(I.Level1_Text,'') as Level1_Text, coalesce(I.Level2_Index, -1) as Level2_Index, coalesce(I.Level2_Text,'') as Level2_Text, coalesce(I.Level3_Index,-1) as Level3_Index, coalesce(I.Level3_Text,'') as Level3_Text, isnull(I.PubDate,'') as PubDate, I.[PageCount], coalesce(I.Link,'') as Link, coalesce( Spatial_KML, '') as Spatial_KML, coalesce(COinS_OpenURL, '') as COinS_OpenURL		
			from SobekCM_Item I, @TEMP_PAGED_ITEMS T
			where ( T.ItemID = I.ItemID )
			order by T.RowNumber, Level1_Index, Level2_Index, Level3_Index;			
			
			-- Return the aggregation-specific display values for all the items in this page of results
			execute sp_Executesql @item_display_sql, N' @itemtable TempPagedItemsTableType READONLY', @TEMP_PAGED_ITEMS; 
		end

		-- Return the facets if asked for
		if ( @include_facets = 'true' )
		begin	
			-- Build the aggregation list
			if ( LEN( isnull( @aggregationcode, '')) = 0 )
			begin
				select A.Code, A.ShortName, Metadata_Count=Count(*)
				from SobekCM_Item_Aggregation A, SobekCM_Item_Aggregation_Item_Link L, SobekCM_Item I, #TEMP_ITEMS T
				where ( T.ItemID = I.ItemID )
				  and ( I.ItemID = L.ItemID )
				  and ( L.AggregationID = A.AggregationID )
				  and ( A.Hidden = 'false' )
				  and ( A.isActive = 'true' )
				  and ( A.Include_In_Collection_Facet = 'true' )
				group by A.Code, A.ShortName
				order by Metadata_Count DESC, ShortName ASC;
			end;
			
			-- Return the FIRST facet
			if ( @facettype1 > 0 )
			begin
				-- Return the first 100 values
				select MetadataValue, Metadata_Count
				from (	select top(100) U.MetadataID, Metadata_Count = COUNT(*)
						from #TEMP_ITEMS I, Metadata_Item_Link_Indexed_View U with (NOEXPAND)
						where ( U.ItemID = I.ItemID )
						  and ( U.MetadataTypeID = @facettype1 )
						group by U.MetadataID
						order by Metadata_Count DESC ) F, SobekCM_Metadata_Unique_Search_Table M
				where M.MetadataID = F.MetadataID
				order by Metadata_Count DESC, MetadataValue ASC;
			end;
			
			-- Return the SECOND facet
			if ( @facettype2 > 0 )
			begin
				-- Return the first 100 values
				select MetadataValue, Metadata_Count
				from (	select top(100) U.MetadataID, Metadata_Count = COUNT(*)
						from #TEMP_ITEMS I, Metadata_Item_Link_Indexed_View U with (NOEXPAND)
						where ( U.ItemID = I.ItemID )
						  and ( U.MetadataTypeID = @facettype2 )
						group by U.MetadataID
						order by Metadata_Count DESC ) F, SobekCM_Metadata_Unique_Search_Table M
				where M.MetadataID = F.MetadataID
				order by Metadata_Count DESC, MetadataValue ASC;
			end;
			
			-- Return the THIRD facet
			if ( @facettype3 > 0 )
			begin
				-- Return the first 100 values
				select MetadataValue, Metadata_Count
				from (	select top(100) U.MetadataID, Metadata_Count = COUNT(*)
						from #TEMP_ITEMS I, Metadata_Item_Link_Indexed_View U with (NOEXPAND)
						where ( U.ItemID = I.ItemID )
						  and ( U.MetadataTypeID = @facettype3 )
						group by U.MetadataID
						order by Metadata_Count DESC ) F, SobekCM_Metadata_Unique_Search_Table M
				where M.MetadataID = F.MetadataID
				order by Metadata_Count DESC, MetadataValue ASC;
			end;
			
			-- Return the FOURTH facet
			if ( @facettype4 > 0 )
			begin
				-- Return the first 100 values
				select MetadataValue, Metadata_Count
				from (	select top(100) U.MetadataID, Metadata_Count = COUNT(*)
						from #TEMP_ITEMS I, Metadata_Item_Link_Indexed_View U with (NOEXPAND)
						where ( U.ItemID = I.ItemID )
						  and ( U.MetadataTypeID = @facettype4 )
						group by U.MetadataID
						order by Metadata_Count DESC ) F, SobekCM_Metadata_Unique_Search_Table M
				where M.MetadataID = F.MetadataID
				order by Metadata_Count DESC, MetadataValue ASC;
			end;
			
			-- Return the FIFTH facet
			if ( @facettype5 > 0 )
			begin
				-- Return the first 100 values
				select MetadataValue, Metadata_Count
				from (	select top(100) U.MetadataID, Metadata_Count = COUNT(*)
						from #TEMP_ITEMS I, Metadata_Item_Link_Indexed_View U with (NOEXPAND)
						where ( U.ItemID = I.ItemID )
						  and ( U.MetadataTypeID = @facettype5 )
						group by U.MetadataID
						order by Metadata_Count DESC ) F, SobekCM_Metadata_Unique_Search_Table M
				where M.MetadataID = F.MetadataID
				order by Metadata_Count DESC, MetadataValue ASC;
			end;
			
			-- Return the SIXTH facet
			if ( @facettype6 > 0 )
			begin
				-- Return the first 100 values
				select MetadataValue, Metadata_Count
				from (	select top(100) U.MetadataID, Metadata_Count = COUNT(*)
						from #TEMP_ITEMS I, Metadata_Item_Link_Indexed_View U with (NOEXPAND)
						where ( U.ItemID = I.ItemID )
						  and ( U.MetadataTypeID = @facettype6 )
						group by U.MetadataID
						order by Metadata_Count DESC ) F, SobekCM_Metadata_Unique_Search_Table M
				where M.MetadataID = F.MetadataID
				order by Metadata_Count DESC, MetadataValue ASC;
			end;
			
			-- Return the SEVENTH facet
			if ( @facettype7 > 0 )
			begin
				-- Return the first 100 values
				select MetadataValue, Metadata_Count
				from (	select top(100) U.MetadataID, Metadata_Count = COUNT(*)
						from #TEMP_ITEMS I, Metadata_Item_Link_Indexed_View U with (NOEXPAND)
						where ( U.ItemID = I.ItemID )
						  and ( U.MetadataTypeID = @facettype7 )
						group by U.MetadataID
						order by Metadata_Count DESC ) F, SobekCM_Metadata_Unique_Search_Table M
				where M.MetadataID = F.MetadataID
				order by Metadata_Count DESC, MetadataValue ASC;
			end;
			
			-- Return the EIGHTH facet
			if ( @facettype8 > 0 )
			begin
				-- Return the first 100 values
				select MetadataValue, Metadata_Count
				from (	select top(100) U.MetadataID, Metadata_Count = COUNT(*)
						from #TEMP_ITEMS I, Metadata_Item_Link_Indexed_View U with (NOEXPAND)
						where ( U.ItemID = I.ItemID )
						  and ( U.MetadataTypeID = @facettype8 )
						group by U.MetadataID
						order by Metadata_Count DESC ) F, SobekCM_Metadata_Unique_Search_Table M
				where M.MetadataID = F.MetadataID
				order by Metadata_Count DESC, MetadataValue ASC;
			end;
		end; -- End overall FACET block
	end; -- End else statement entered if there are any results to return
	
	-- Drop the temporary table
	drop table #TEMP_ITEMS;
	
	SET NOCOUNT OFF;
END;
GO


-- Update the version number
if (( select count(*) from SobekCM_Database_Version ) = 0 )
begin
	insert into SobekCM_Database_Version ( Major_Version, Minor_Version, Release_Phase )
	values ( 4, 10, '1' );
end
else
begin
	update SobekCM_Database_Version
	set Major_Version=4, Minor_Version=10, Release_Phase='1';
end;
GO
