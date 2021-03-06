alter table SobekCM_Item_Group add HasGroupMetadata bit default('false') not null;
GO

alter table SobekCM_Item_Group add CustomThumbnail nvarchar(255) null;
GO

alter table SobekCM_Item_Group add ThumbnailType tinyint default(0) not null;
GO

alter table SobekCM_Item_Group add FlagByte tinyint default(0) not null;
GO

alter table SobekCM_Item_Group add LastFourInt smallint null;
GO
 
update SobekCM_Item_Group 
set LastFourInt = cast(substring(BibID, 7, 4) as smallint );
GO


-- Saves all the main data about a group of items in UFDC
-- Written by Mark Sullivan (September 2006, Modified October 2011 )
ALTER PROCEDURE [dbo].[SobekCM_Save_Item_Group]
	@BibID varchar(10),
	@GroupTitle nvarchar(500),
	@SortTitle varchar(255),
	@Type varchar(50),
	@File_Location varchar(100),
	@OCLC_Number bigint,
	@ALEPH_Number int,
	@Group_Thumbnail varchar(500),
	@Large_Format bit,
	@Track_By_Month bit,
	@Never_Overlay_Record bit,
	@Update_Existing bit,
	@PrimaryIdentifierType nvarchar(50),
	@PrimaryIdentifier nvarchar(100),
	@GroupID int output,
	@New_BibID varchar(10) output,
	@New_Group bit output
AS
begin transaction

	-- Set the return BibID value first
	set @New_BibID = @BibID;
	set @New_Group = 'false';

	-- If this group does not exists (BibID) insert, else update
	if (( select count(*) from SobekCM_Item_Group  where ( BibID = @BibID ))  < 1 )
	begin	
		-- Verify the BibID is a complete bibid, otherwise find the next one
		if ( LEN(@bibid) < 10 )
		begin
			declare @next_bibid_number int;

			-- Find the next bibid number
			select @next_bibid_number = isnull(CAST(REPLACE(MAX(BibID), @bibid, '') as int) + 1,-1)
			from SobekCM_Item_Group
			where BibID like @bibid + '%';
			
			-- If no matches to this BibID, just start at 0000001
			if ( @next_bibid_number < 0 )
			begin
				select @New_BibID = @bibid + RIGHT('00000001', 10-LEN(@bibid));
			end
			else
			begin
				select @New_BibID = @bibid + RIGHT('00000000' + (CAST( @next_bibid_number as varchar(10))), 10-LEN(@bibid));
			end;
		end;
		
		-- Compute the file location if needed
		if ( LEN(@File_Location) = 0 )
		begin
			set @File_Location = SUBSTRING(@New_BibID,1 ,2 ) + '\' + SUBSTRING(@New_BibID,3,2) + '\' + SUBSTRING(@New_BibID,5,2) + '\' + SUBSTRING(@New_BibID,7,2) + '\' + SUBSTRING(@New_BibID,9,2);
		end;
		
		-- Add the values to the main SobekCM_Item table first
		insert into SobekCM_Item_Group ( BibID, GroupTitle, Deleted, [Type], SortTitle, ItemCount, File_Location, GroupCreateDate, OCLC_Number, ALEPH_Number, GroupThumbnail, Track_By_Month, Large_Format, Never_Overlay_Record, Primary_Identifier_Type, Primary_Identifier, LastFourInt )
		values ( @New_BibID, @GroupTitle, 0, @Type, @SortTitle, 0, @File_Location, getdate(), @OCLC_Number, @ALEPH_Number, @Group_Thumbnail, @Track_By_Month, @Large_Format, @Never_Overlay_Record, @PrimaryIdentifierType, @PrimaryIdentifier, cast(substring(@BibID, 7, 4) as smallint ) );

		-- Get the item id identifier for this row
		set @GroupID = @@identity;
		set @New_Group = 'true';
	end
	else
	begin

		-- This already existed, so just return the existing group id
		select @GroupID = GroupID
		from SobekCM_Item_Group
		where BibID = @BibID;

		-- If we are supposed to update it, do this
		if ( @Update_Existing = 'true' )
		begin

			update SobekCM_Item_Group
			set GroupTitle=@GroupTitle, [Type]=@Type, SortTitle=@SortTitle, OCLC_Number=@OCLC_Number, ALEPH_Number=@ALEPH_Number, GroupThumbnail=@Group_Thumbnail, Track_By_Month = @Track_By_Month, Large_Format=@Large_Format, Never_Overlay_Record = @Never_Overlay_Record, Primary_Identifier_Type=@PrimaryIdentifierType, Primary_Identifier=@PrimaryIdentifier
			where BibID = @BibID;

		end;
		
		set @New_Group = 'false';
	end;

commit transaction;
GO



-- Gets the information about all the multi-volume titles
CREATE PROCEDURE [dbo].[SobekCM_Get_MultiVolume_Title_Info] 
AS
begin

	-- No need to perform any locks here.  A slightly dirty read won't hurt much
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- Return the multiple volumes
	with volume_count as 
	(
		select BibID, count(*) as ItemCount
		from SobekCM_Item_Group G, SobekCM_Item I
		where G.GroupID = I.GroupID 
		  and G.Deleted='false'
		  and I.Deleted='false'
		group by BibID
	)
	select G.BibID, CustomThumbnail, FlagByte, LastFourInt, coalesce(GroupTitle,'') as GroupTitle
	from SobekCM_Item_Group G, volume_count C
	where ( C.BibID=G.BibID )
	  and (( C.ItemCount > 1 ) or ( G.HasGroupMetadata = 'true' ));

end;
GO

GRANT EXECUTE ON SobekCM_Get_MultiVolume_Title_Info TO sobek_user;
GRANT EXECUTE ON SobekCM_Get_MultiVolume_Title_Info TO sobek_builder;
GO