

-- Add views used to allow item count stats to be pulled based on other criteria, rather than just completed


/****** Object:  View [dbo].[Statistics_Item_Aggregation_Link_View2]    Script Date: 12/20/2013 05:43:33 ******/
IF ( EXISTS(select * FROM sys.views where name = 'Statistics_Item_Aggregation_Link_View2'))
	DROP VIEW [dbo].[Statistics_Item_Aggregation_Link_View2];
GO

CREATE VIEW [dbo].[Statistics_Item_Aggregation_Link_View2] WITH SCHEMABINDING
AS
SELECT  AggregationID, I.ItemID, I.FileCount, I.[PageCount], I.GroupID, coalesce(I.CreateDate, I.Milestone_DigitalAcquisition) as CreateDate
FROM  dbo.SobekCM_Item_Aggregation_Item_Link CL, dbo.SobekCM_Item I
WHERE ( CL.ItemID = I.ItemID )
  and ( I.Deleted = 'false' )
  and (( I.FileCount > 0 ) or ( I.[PageCount] > 0 ));
GO

/****** Object:  View [dbo].[Statistics_Item_Aggregation_Link_View2]    Script Date: 12/20/2013 05:43:33 ******/
IF ( EXISTS(select * FROM sys.indexes  where name = 'Statistics_Item_Aggregation_Link_View2_IX' AND object_id = OBJECT_ID('dbo.Statistics_Item_Aggregation_Link_View2')))
	DROP INDEX [Statistics_Item_Aggregation_Link_View2_IX] ON [dbo].[Statistics_Item_Aggregation_Link_View2]
GO

/****** Object:  Index [Statistics_Item_Aggregation_Link_View_IX]    Script Date: 9/28/2015 5:34:13 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Statistics_Item_Aggregation_Link_View2_IX] ON [dbo].[Statistics_Item_Aggregation_Link_View2]
(
	[AggregationID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  View [dbo].[Statistics_Item_Aggregation_Link_View2]    Script Date: 12/20/2013 05:43:33 ******/
IF ( EXISTS(select * FROM sys.indexes  where name = 'Statistics_Item_Aggregation_Link_View2_IX2' AND object_id = OBJECT_ID('dbo.Statistics_Item_Aggregation_Link_View2')))
	DROP INDEX Statistics_Item_Aggregation_Link_View2_IX2 ON [dbo].[Statistics_Item_Aggregation_Link_View2]
GO


/****** Object:  Index [Statistics_Item_Aggregation_Link_View_IX2]    Script Date: 9/28/2015 5:34:30 PM ******/
CREATE NONCLUSTERED INDEX [Statistics_Item_Aggregation_Link_View2_IX2] ON [dbo].[Statistics_Item_Aggregation_Link_View2]
(
	[CreateDate] ASC
)
INCLUDE ( 	[AggregationID],
	[GroupID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF ( EXISTS(select * FROM sys.views where name = 'Statistics_Item_Aggregation_Link_View3'))
	DROP VIEW [dbo].[Statistics_Item_Aggregation_Link_View3];
GO

/****** Object:  View [dbo].[Statistics_Item_Aggregation_Link_View3]    Script Date: 12/20/2013 05:43:33 ******/
CREATE VIEW [dbo].[Statistics_Item_Aggregation_Link_View3] WITH SCHEMABINDING
AS
SELECT  AggregationID, I.ItemID, I.FileCount, I.[PageCount], I.GroupID, coalesce(I.CreateDate, I.Milestone_DigitalAcquisition) as CreateDate
FROM  dbo.SobekCM_Item_Aggregation_Item_Link CL, dbo.SobekCM_Item I
WHERE ( CL.ItemID = I.ItemID )
  and ( I.Deleted = 'false' );
GO

IF ( EXISTS(select * FROM sys.indexes  where name = 'Statistics_Item_Aggregation_Link_View3_IX' AND object_id = OBJECT_ID('dbo.Statistics_Item_Aggregation_Link_View3')))
	DROP INDEX Statistics_Item_Aggregation_Link_View3_IX ON [dbo].[Statistics_Item_Aggregation_Link_View3]
GO

/****** Object:  Index [Statistics_Item_Aggregation_Link_View_IX]    Script Date: 9/28/2015 5:34:13 PM ******/
CREATE UNIQUE CLUSTERED INDEX [Statistics_Item_Aggregation_Link_View3_IX] ON [dbo].[Statistics_Item_Aggregation_Link_View3]
(
	[AggregationID] ASC,
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

IF ( EXISTS(select * FROM sys.indexes  where name = 'Statistics_Item_Aggregation_Link_View3_IX2' AND object_id = OBJECT_ID('dbo.Statistics_Item_Aggregation_Link_View3')))
	DROP INDEX Statistics_Item_Aggregation_Link_View3_IX2 ON [dbo].[Statistics_Item_Aggregation_Link_View3]
GO

/****** Object:  Index [Statistics_Item_Aggregation_Link_View_IX2]    Script Date: 9/28/2015 5:34:30 PM ******/
CREATE NONCLUSTERED INDEX [Statistics_Item_Aggregation_Link_View3_IX2] ON [dbo].[Statistics_Item_Aggregation_Link_View3]
(
	[CreateDate] ASC
)
INCLUDE ( 	[AggregationID],
	[GroupID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-- Add video viewer into the priority list
if ( not exists ( select 1 from SobekCM_Item_Viewer_Priority where ViewType = 'VIDEO' ))
begin
	update SobekCM_Item_Viewer_Priority
	set [Priority] = [Priority] + 1
	where [Priority] > 7;

	insert into SobekCM_Item_Viewer_Priority ( ViewType, [Priority] )
	values ( 'VIDEO', 8 );
end;
GO


-- Just double check these columns were added
if ( NOT EXISTS (select * from sys.columns where Name = N'Redirect' and Object_ID = Object_ID(N'SobekCM_WebContent')))
BEGIN
	ALTER TABLE [dbo].SobekCM_WebContent add Redirect nvarchar(500) null;
END;
GO


IF NOT EXISTS(select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'SobekCM_WebContent' and COLUMN_NAME = 'Locked') 
begin
	ALTER TABLE SobekCM_WebContent ADD Locked bit not null default('false');
end;
GO

if ( NOT EXISTS (select * from sys.columns where Name = N'SpatialFootprint' and Object_ID = Object_ID(N'SobekCM_Item')))
BEGIN
	ALTER TABLE SobekCM_Item
	ADD SpatialFootprint varchar(255) null default('');
END;
GO

if ( NOT EXISTS (select * from sys.columns where Name = N'SpatialFootprintDistance' and Object_ID = Object_ID(N'SobekCM_Item')))
BEGIN
	ALTER TABLE SobekCM_Item
	ADD SpatialFootprintDistance float not null default(999);
END;
GO

update SobekCM_Item 
set SpatialFootprint = Spatial_KML, SpatialFootprintDistance = Spatial_KML_Distance
where len(coalesce(Spatial_KML,'')) > 0;
GO


select F.ItemID
into #ItemsWithFootprints
from SobekCM_Item_Footprint F, SobekCM_Item I
where ( len(coalesce(SpatialFootprint,'')) = 0 )
  and ( F.ItemID = I.ItemID )
group by F.ItemID;

select * from #ItemsWithFootprints;

declare @itemID int;

declare ItemWithFootprintsCursor cursor  for
select ItemID from #ItemsWithFootprints;

open ItemWithFootprintsCursor;

FETCH NEXT FROM ItemWithFootprintsCursor 
INTO @itemID;

WHILE @@FETCH_STATUS = 0
BEGIN

	with ItemPoints as
	(
		select Point_Latitude as Latitude, Point_Longitude as Longitude
		from SobekCM_Item_Footprint
		where ( ItemID=@itemID )
		  and ( Point_Latitude is not null )
		  and ( Point_Longitude is not null )
		union
		select Rect_Latitude_A, Rect_Longitude_A
		from SobekCM_Item_Footprint
		where ( ItemID=@itemID )
		  and ( Rect_Latitude_A is not null )
		  and ( Rect_Longitude_A is not null )
		union
		select Rect_Latitude_B, Rect_Longitude_B
		from SobekCM_Item_Footprint
		where ( ItemID=@itemID )
		  and ( Rect_Latitude_B is not null )
		  and ( Rect_Longitude_B is not null )
	), MinMaxItemPoints as
	(
		select Min(Latitude) as Min_Latitude, 
			   Max(Latitude) as Max_Latitude, 
			   Min(Longitude) as Min_Longitude, 
			   Max(Longitude) as Max_Longitude
		from ItemPoints
	)
	select CASE WHEN Min_Latitude=Max_Latitude and Min_Longitude=Max_Longitude THEN 'P|' + cast(Min_Latitude as varchar(20)) + '|' + cast(Min_Longitude as varchar(20))
				ELSE 'A|' + cast(Min_Latitude as varchar(20)) + '|' + cast(Min_Longitude as varchar(20)) + '|' + cast(Max_Latitude as varchar(20)) + '|' + cast(Max_Longitude as varchar(20))
		   END as SpatialFootprint,
		   Square(Max_Latitude - Min_Latitude ) + Square(Max_Longitude-Min_Longitude) as SpatialFootprintDistance
	into #FinalValues
    from MinMaxItemPoints;

	update SobekCM_Item 
	set SpatialFootprint= ( select SpatialFootprint from #FinalValues ),
	    SpatialFootprintDistance = ( select SpatialFootprintDistance from #FinalValues )
	where ItemID=@ItemID;

	drop table #FinalValues;

	FETCH NEXT FROM ItemWithFootprintsCursor 
	INTO @itemID;
end;


CLOSE ItemWithFootprintsCursor;
DEALLOCATE ItemWithFootprintsCursor;
drop table #ItemsWithFootprints;
GO


-- Ensure the SobekCM_WebContent_Add stored procedure exists
IF object_id('SobekCM_WebContent_Add') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Add as select 1;');
GO

-- Add a new web content page
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Add]
	@Level1 varchar(100),
	@Level2 varchar(100),
	@Level3 varchar(100),
	@Level4 varchar(100),
	@Level5 varchar(100),
	@Level6 varchar(100),
	@Level7 varchar(100),
	@Level8 varchar(100),
	@UserName nvarchar(100),
	@Title nvarchar(255),
	@Summary nvarchar(1000),
	@Redirect nvarchar(500),
	@WebContentID int output
AS
BEGIN	
	-- Is there a match already for this?
	if ( EXISTS ( select 1 from SobekCM_WebContent 
	              where ( Level1=@Level1 )
	                and ((Level2 is null and @Level2 is null ) or ( Level2=@Level2)) 
					and ((Level3 is null and @Level3 is null ) or ( Level3=@Level3))
					and ((Level4 is null and @Level4 is null ) or ( Level4=@Level4))
					and ((Level5 is null and @Level5 is null ) or ( Level5=@Level5))
					and ((Level6 is null and @Level6 is null ) or ( Level6=@Level6))
					and ((Level7 is null and @Level7 is null ) or ( Level7=@Level7))
					and ((Level8 is null and @Level8 is null ) or ( Level8=@Level8))))
	begin
		-- Get the web content id
		set @WebContentID = (   select top 1 WebContentID 
								from SobekCM_WebContent 
								where ( Level1=@Level1 )
								  and ((Level2 is null and @Level2 is null ) or ( Level2=@Level2)) 
								  and ((Level3 is null and @Level3 is null ) or ( Level3=@Level3))
								  and ((Level4 is null and @Level4 is null ) or ( Level4=@Level4))
								  and ((Level5 is null and @Level5 is null ) or ( Level5=@Level5))
								  and ((Level6 is null and @Level6 is null ) or ( Level6=@Level6))
								  and ((Level7 is null and @Level7 is null ) or ( Level7=@Level7))
								  and ((Level8 is null and @Level8 is null ) or ( Level8=@Level8)));

		-- Ensure the title and summary are correct
		update SobekCM_WebContent set Title=@Title, Summary=@Summary, Redirect=@Redirect where WebContentID=@WebContentID;
		
		-- Was this previously deleted?
		if ( EXISTS ( select 1 from SobekCM_WebContent where Deleted='true' and WebContentID=@WebContentID ))
		begin
			-- Undelete this 
			update SobekCM_WebContent
			set Deleted='false'
			where WebContentID = @WebContentID;

			-- Mark this in the milestones then
			insert into SobekCM_WebContent_Milestones ( WebContentID, Milestone, MilestoneDate, MilestoneUser )
			values ( @WebContentID, 'Restored previously deleted page', getdate(), @UserName );
		end;
	end
	else
	begin
		-- Add the new web content then
		insert into SobekCM_WebContent ( Level1, Level2, Level3, Level4, Level5, Level6, Level7, Level8, Title, Summary, Deleted, Redirect )
		values ( @Level1, @Level2, @Level3, @Level4, @Level5, @Level6, @Level7, @Level8, @Title, @Summary, 'false', @Redirect );

		-- Get the new ID for this
		set @WebContentID = SCOPE_IDENTITY();

		-- Now, add this to the milestones table
		insert into SobekCM_WebContent_Milestones ( WebContentID, Milestone, MilestoneDate, MilestoneUser )
		values ( @WebContentID, 'Add new page', getdate(), @UserName );
	end;
END;
GO


-- Ensure the SobekCM_WebContent_Get_Page stored procedure exists
IF object_id('SobekCM_WebContent_Get_Page') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Get_Page as select 1;');
GO

-- Get basic details about an existing web content page
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Get_Page]
	@Level1 varchar(100),
	@Level2 varchar(100),
	@Level3 varchar(100),
	@Level4 varchar(100),
	@Level5 varchar(100),
	@Level6 varchar(100),
	@Level7 varchar(100),
	@Level8 varchar(100)
AS
BEGIN	
	-- Return the couple of requested pieces of information
	select top 1 W.WebContentID, W.Title, W.Summary, W.Deleted, M.MilestoneDate, M.MilestoneUser, W.Redirect, W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8, W.Locked
	from SobekCM_WebContent W left outer join
	     SobekCM_WebContent_Milestones M on W.WebContentID=M.WebContentID
	where ( Level1=@Level1 )
	  and ((Level2 is null and @Level2 is null ) or ( Level2=@Level2)) 
	  and ((Level3 is null and @Level3 is null ) or ( Level3=@Level3))
	  and ((Level4 is null and @Level4 is null ) or ( Level4=@Level4))
	  and ((Level5 is null and @Level5 is null ) or ( Level5=@Level5))
	  and ((Level6 is null and @Level6 is null ) or ( Level6=@Level6))
	  and ((Level7 is null and @Level7 is null ) or ( Level7=@Level7))
	  and ((Level8 is null and @Level8 is null ) or ( Level8=@Level8))
	order by M.MilestoneDate DESC;
END;
GO

-- Ensure the SobekCM_WebContent_Get_Page stored procedure exists
IF object_id('SobekCM_WebContent_Get_Page_ID') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Get_Page_ID as select 1;');
GO

-- Get basic details about an existing web content page
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Get_Page_ID]
	@WebContentID int
AS
BEGIN	
	-- Return the couple of requested pieces of information
	select top 1 W.WebContentID, W.Title, W.Summary, W.Deleted, M.MilestoneDate, M.MilestoneUser, W.Redirect, W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8, W.Locked
	from SobekCM_WebContent W left outer join
	     SobekCM_WebContent_Milestones M on W.WebContentID=M.WebContentID
	where W.WebContentID = @WebContentID
	order by M.MilestoneDate DESC;
END;
GO

-- Ensure the SobekCM_WebContent_All stored procedure exists
IF object_id('SobekCM_WebContent_All') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_All as select 1;');
GO

-- Return all the web content pages, regardless of whether they are redirects or an actual content page
ALTER PROCEDURE [dbo].[SobekCM_WebContent_All]
AS
BEGIN

	-- Get the pages, with the time last updated
	with webcontent_last_update as
	(
		select WebContentID, Max(WebContentMilestoneID) as MaxMilestoneID
		from SobekCM_WebContent_Milestones
		group by WebContentID
	)
	select W.WebContentID, W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8, W.Title, W.Summary, W.Deleted, W.Redirect, M.MilestoneDate, M.MilestoneUser
	from SobekCM_WebContent W left outer join
		 webcontent_last_update L on L.WebContentID=W.WebContentID left outer join
	     SobekCM_WebContent_Milestones M on M.WebContentMilestoneID=L.MaxMilestoneID
	where Deleted='false'
	order by W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8;

	-- Get the distinct top level pages
	select distinct(W.Level1)
	from SobekCM_WebContent W
	where ( Deleted = 'false' )
	order by W.Level1;

	-- Get the distinct top TWO level pages
	select W.Level1, W.Level2
	from SobekCM_WebContent W
	where ( W.Level2 is not null )
	  and ( Deleted = 'false' )
	group by W.Level1, W.Level2
	order by W.Level1, W.Level2;

END;
GO

-- Ensure the SobekCM_WebContent_All_Pages stored procedure exists
IF object_id('SobekCM_WebContent_All_Pages') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_All_Pages as select 1;');
GO

-- Return all the web content pages that are not set as redirects
ALTER PROCEDURE [dbo].[SobekCM_WebContent_All_Pages]
AS
BEGIN

	-- Get the pages, with the time last updated
	with webcontent_last_update as
	(
		select WebContentID, Max(WebContentMilestoneID) as MaxMilestoneID
		from SobekCM_WebContent_Milestones
		group by WebContentID
	)
	select W.WebContentID, W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8, W.Title, W.Summary, W.Deleted, W.Redirect, M.MilestoneDate, M.MilestoneUser
	from SobekCM_WebContent W left outer join
		 webcontent_last_update L on L.WebContentID=W.WebContentID left outer join
	     SobekCM_WebContent_Milestones M on M.WebContentMilestoneID=L.MaxMilestoneID
	where ( len(coalesce(W.Redirect,'')) = 0 ) and ( Deleted = 'false' )
	order by W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8;

	-- Get the distinct top level pages
	select distinct(W.Level1)
	from SobekCM_WebContent W
	where ( len(coalesce(W.Redirect,'')) = 0 ) and ( Deleted = 'false' )
	order by W.Level1;

	-- Get the distinct top TWO level pages
	select W.Level1, W.Level2
	from SobekCM_WebContent W
	where ( len(coalesce(W.Redirect,'')) = 0 )
	  and ( W.Level2 is not null )
	  and ( Deleted = 'false' )
	group by W.Level1, W.Level2
	order by W.Level1, W.Level2;

END;
GO

-- Ensure the SobekCM_WebContent_All_Redirects stored procedure exists
IF object_id('SobekCM_WebContent_All_Redirects') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_All_Redirects as select 1;');
GO

-- Return all the web content pages that are set as redirects
ALTER PROCEDURE [dbo].[SobekCM_WebContent_All_Redirects]
AS
BEGIN

	-- Get the pages, with the time last updated
	with webcontent_last_update as
	(
		select WebContentID, Max(WebContentMilestoneID) as MaxMilestoneID
		from SobekCM_WebContent_Milestones
		group by WebContentID
	)
	select W.WebContentID, W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8, W.Title, W.Summary, W.Deleted, W.Redirect, M.MilestoneDate, M.MilestoneUser
	from SobekCM_WebContent W left outer join
		 webcontent_last_update L on L.WebContentID=W.WebContentID left outer join
	     SobekCM_WebContent_Milestones M on M.WebContentMilestoneID=L.MaxMilestoneID
	where ( len(coalesce(W.Redirect,'')) > 0 ) and ( Deleted = 'false' )
	order by W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8;

	-- Get the distinct top level pages
	select distinct(W.Level1)
	from SobekCM_WebContent W
	where ( len(coalesce(W.Redirect,'')) > 0 ) and ( Deleted = 'false' )
	order by W.Level1;

	-- Get the distinct top TWO level pages
	select W.Level1, W.Level2
	from SobekCM_WebContent W
	where ( len(coalesce(W.Redirect,'')) > 0 )
	  and ( W.Level2 is not null )
	  and ( Deleted = 'false' )
	group by W.Level1, W.Level2
	order by W.Level1, W.Level2;

END;
GO

-- Ensure the SobekCM_WebContent_All_Redirects stored procedure exists
IF object_id('SobekCM_WebContent_Get_Recent_Changes') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Get_Recent_Changes as select 1;');
GO

-- Get the list of recent changes to all web content pages
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Get_Recent_Changes]
AS
BEGIN

	-- Get all milestones
	select W.WebContentID, W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8, MilestoneDate, MilestoneUser, Milestone, W.Title
	from SobekCM_WebContent_Milestones M, SobekCM_WebContent W
	where M.WebContentID=W.WebContentID
	order by MilestoneDate DESC;

	-- Get the distinct list of users that made changes
	select MilestoneUser
	from SobekCM_WebContent_Milestones
	group by MilestoneUser
	order by MilestoneUser;

	-- Return the distinct first level
	select Level1 
	from SobekCM_WebContent_Milestones M, SobekCM_WebContent W
	where M.WebContentID=W.WebContentID
	group by Level1
	order by Level1;
	
	-- Return the distinct first TWO level					
	select Level1, Level2
	from SobekCM_WebContent_Milestones M, SobekCM_WebContent W
	where M.WebContentID=W.WebContentID
	group by Level1, Level2
	order by Level1, Level2;


END;
GO

-- Ensure the SobekCM_WebContent_All_Redirects stored procedure exists
IF object_id('SobekCM_WebContent_Edit') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Edit as select 1;');
GO

-- Edit basic information on an existing web content page
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Edit]
	@WebContentID int,
	@UserName nvarchar(100),
	@Title nvarchar(255),
	@Summary nvarchar(1000),
	@Redirect varchar(500),
	@MilestoneText varchar(max)
AS
BEGIN	
	-- Make the change
	update SobekCM_WebContent
	set Title=@Title, Summary=@Summary, Redirect=@Redirect
	where WebContentID=@WebContentID;

	-- Now, add a milestone
	if ( len(coalesce(@MilestoneText,'')) > 0 )
	begin
		insert into SobekCM_WebContent_Milestones (WebContentID, Milestone, MilestoneDate, MilestoneUser )
		values ( @WebContentID, @MilestoneText, getdate(), @UserName );
	end
	else
	begin
		insert into SobekCM_WebContent_Milestones (WebContentID, Milestone, MilestoneDate, MilestoneUser )
		values ( @WebContentID, 'Edited', getdate(), @UserName );
	end;

END;
GO

-- Ensure the SobekCM_WebContent_All_Redirects stored procedure exists
IF object_id('SobekCM_WebContent_Usage_Report') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Usage_Report as select 1;');
GO

-- Pull the usage for all top-level web content pages between two dates
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Usage_Report]
	@year1 smallint,
	@month1 smallint,
	@year2 smallint,
	@month2 smallint
AS
BEGIN	

	with stats_compiled as
	(	
		select Level1, Level2, Level3, Level4, Level5, Level6, Level7, Level8, sum(Hits) as Hits, sum(Hits_Complete) as HitsHierarchical
		from SobekCM_WebContent_Statistics
		where ((( [Month] >= @month1 ) and ( [Year] = @year1 )) or ([Year] > @year1 ))
		  and ((( [Month] <= @month2 ) and ( [Year] = @year2 )) or ([Year] < @year2 ))
		group by Level1, Level2, Level3, Level4, Level5, Level6, Level7, Level8
	)
	select coalesce(W.Level1, S.Level1) as Level1, coalesce(W.Level2, S.Level2) as Level2, coalesce(W.Level3, S.Level3) as Level3,
	       coalesce(W.Level4, S.Level4) as Level4, coalesce(W.Level5, S.Level5) as Level5, coalesce(W.Level6, S.Level6) as Level6,
		   coalesce(W.Level7, S.Level7) as Level7, coalesce(W.Level8, S.Level8) as Level8, W.Deleted, coalesce(W.Title,'(no title)') as Title, S.Hits, S.HitsHierarchical
	into #TEMP1
	from stats_compiled S left outer join
	     SobekCM_WebContent W on     ( W.Level1=S.Level1 ) 
		                         and ( coalesce(W.Level2,'')=coalesce(S.Level2,''))
								 and ( coalesce(W.Level3,'')=coalesce(S.Level3,''))
								 and ( coalesce(W.Level4,'')=coalesce(S.Level4,''))
								 and ( coalesce(W.Level5,'')=coalesce(S.Level5,''))
								 and ( coalesce(W.Level6,'')=coalesce(S.Level6,''))
								 and ( coalesce(W.Level7,'')=coalesce(S.Level7,''))
								 and ( coalesce(W.Level8,'')=coalesce(S.Level8,''))
	order by Level1, Level2, Level3, Level4, Level5, Level6, Level7, Level8;	
	
	-- Return the full stats
	select * from #TEMP1;
	
	-- Return the distinct first level
	select Level1 
	from #TEMP1
	group by Level1
	order by Level1;
	
	-- Return the distinct first TWO level					
	select Level1, Level2
	from #TEMP1
	group by Level1, Level2
	order by Level1, Level2;

END;
GO


-- Ensure the SobekCM_WebContent_Has_Usage stored procedure exists
IF object_id('SobekCM_WebContent_Has_Usage') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Has_Usage as select 1;');
GO

-- Pull the flag indicating if this instance has any web content usage logged
ALTER PROCEDURE [dbo].SobekCM_WebContent_Has_Usage
	@value bit output
AS
BEGIN	

	if ( exists ( select 1 from SobekCM_WebContent_Statistics ))
		set @value = 'true';
	else
		set @value = 'false';
	
END;
GO

-- Ensure the SobekCM_WebContent_All_Brief stored procedure exists
IF object_id('SobekCM_WebContent_All_Brief') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_All_Brief as select 1;');
GO

-- Return a brief account of all the web content pages, regardless of whether they are redirects or an actual content page
ALTER PROCEDURE [dbo].[SobekCM_WebContent_All_Brief]
AS
BEGIN

	-- Get the complete list of all active web content pages, with segment level names, primary key, and redirect URL
	select W.WebContentID, W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8, W.Redirect
	from SobekCM_WebContent W 
	where Deleted = 'false'
	order by W.Level1, W.Level2, W.Level3, W.Level4, W.Level5, W.Level6, W.Level7, W.Level8;

END;
GO

-- Ensure the SobekCM_WebContent_Add_Milestone stored procedure exists
IF object_id('SobekCM_WebContent_Add_Milestone') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Add_Milestone as select 1;');
GO

-- Add a new milestone to an existing web content page
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Add_Milestone]
	@WebContentID int,
	@Milestone nvarchar(max),
	@MilestoneUser nvarchar(100)
AS
BEGIN

	-- Insert milestone
	insert into SobekCM_WebContent_Milestones ( WebContentID, Milestone, MilestoneUser, MilestoneDate )
	values ( @WebContentID, @Milestone, @MilestoneUser, getdate());

END;
GO

-- Ensure the SobekCM_WebContent_Delete stored procedure exists
IF object_id('SobekCM_WebContent_Delete') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Delete as select 1;');
GO

-- Delete an existing web content page (and mark in the milestones)
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Delete]
	@WebContentID int,
	@Reason nvarchar(max),
	@MilestoneUser nvarchar(100)
AS
BEGIN

	-- Mark web page as deleted
	update SobekCM_WebContent
	set Deleted='true'
	where WebContentID=@WebContentID;

	-- Add a milestone for this
	if (( @Reason is not null ) and ( len(@Reason) > 0 ))
	begin
		insert into SobekCM_WebContent_Milestones ( WebContentID, Milestone, MilestoneUser, MilestoneDate )
		values ( @WebContentID, 'Page Deleted - ' + @Reason, @MilestoneUser, getdate());
	end
	else
	begin
		insert into SobekCM_WebContent_Milestones ( WebContentID, Milestone, MilestoneUser, MilestoneDate )
		values ( @WebContentID, 'Page Deleted', @MilestoneUser, getdate());
	end;

END;
GO

-- Ensure the SobekCM_WebContent_Get_Milestones stored procedure exists
IF object_id('SobekCM_WebContent_Get_Milestones') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Get_Milestones as select 1;');
GO

-- Get the milestones for a webcontent page (by ID)
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Get_Milestones]
	@WebContentID int
AS
BEGIN

	-- Get all milestones
	select Milestone, MilestoneDate, MilestoneUser
	from SobekCM_WebContent_Milestones
	where WebContentID=@WebContentID
	order by MilestoneDate;

END;
GO

-- Ensure the SobekCM_WebContent_Get_Usage stored procedure exists
IF object_id('SobekCM_WebContent_Get_Usage') IS NULL EXEC ('create procedure dbo.SobekCM_WebContent_Get_Usage as select 1;');
GO

-- Get the usage stats for a webcontent page (by ID)
ALTER PROCEDURE [dbo].[SobekCM_WebContent_Get_Usage]
	@WebContentID int
AS
BEGIN

	-- Get all stats
	select [Year], [Month], Hits, Hits_Complete
	from SobekCM_WebContent_Statistics
	where WebContentID=@WebContentID
	order by [Year], [Month];

END;
GO


GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Add] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Add] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Add_Milestone] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Add_Milestone] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_All] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_All] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_All_Brief] to sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_All_Brief] to sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_All_Pages] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_All_Pages] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_All_Redirects] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_All_Redirects] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Delete] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Delete] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Edit] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Edit] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Milestones] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Milestones] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Page] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Page] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Page_ID] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Page_ID] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Recent_Changes] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Recent_Changes] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Usage] TO sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Get_Usage] TO sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Has_Usage] to sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Has_Usage] to sobek_builder;

GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Usage_Report] to sobek_user;
GRANT EXECUTE ON [dbo].[SobekCM_WebContent_Usage_Report] to sobek_builder;
GO



-- Drop index, if it exists 
if ( EXISTS ( select 1 from sys.indexes WHERE name='IX_SobekCM_WebContent_Milestones_Date_ID' AND object_id = OBJECT_ID('SobekCM_WebContent_Milestones')))
	DROP INDEX IX_SobekCM_WebContent_Milestones_Date_ID ON [dbo].SobekCM_WebContent_Milestones
GO

alter table SobekCM_WebContent_Milestones 
alter column MilestoneDate datetime not null;
GO

/****** Object:  Index [IX_SobekCM_WebContent_Milestones_Date_ID]    Script Date: 6/4/2015 6:55:43 AM ******/
CREATE NONCLUSTERED INDEX [IX_SobekCM_WebContent_Milestones_Date_ID] ON [dbo].[SobekCM_WebContent_Milestones]
(
	[WebContentID] ASC,
	[MilestoneDate] ASC
)
INCLUDE ( 	[MilestoneUser]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


ALTER PROCEDURE [dbo].[SobekCM_Item_Count_By_Collection_By_Date_Range]
	@date1 datetime,
	@date2 datetime
AS
BEGIN

	-- No need to perform any locks here, especially given the possible
	-- length of this search
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	SET ARITHABORT ON;

	-- Get the id for the ALL aggregation
	declare @all_id int;
	set @all_id = coalesce(( select AggregationID from SObekCM_Item_Aggregation where Code='all'), -1);
	
	declare @Aggregation_List TABLE
	(
	  AggregationID int,
	  Code varchar(20),
	  ChildCode varchar(20),
	  Child2Code varchar(20),
	  AllCodes varchar(20),
	  Name nvarchar(255),
	  ShortName nvarchar(100),
	  [Type] varchar(50),
	  isActive bit
	);
	
	-- Insert the list of items linked to ALL or linked to NONE (include ALL)
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select AggregationID, Code, '', '', Code, Name, ShortName, [Type], isActive
	from SobekCM_Item_Aggregation A
	where ( [Type] not like 'Institut%' )
	  and ( Deleted='false' )
	  and exists ( select * from SobekCM_Item_Aggregation_Hierarchy where ChildID=A.AggregationID and ParentID=@all_id);
	  
	-- Insert the children under those top-level collections
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select A2.AggregationID, T.Code, A2.Code, '', A2.Code, A2.Name, A2.SHortName, A2.[Type], A2.isActive
	from @Aggregation_List T, SobekCM_Item_Aggregation A2, SobekCM_Item_Aggregation_Hierarchy H
	where ( A2.[Type] not like 'Institut%' )
	  and ( T.AggregationID = H.ParentID )
	  and ( A2.AggregationID = H.ChildID )
	  and ( Deleted='false' );
	  
	-- Insert the grand-children under those child collections
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select A2.AggregationID, T.Code, T.ChildCode, A2.Code, A2.Code, A2.Name, A2.SHortName, A2.[Type], A2.isActive
	from @Aggregation_List T, SobekCM_Item_Aggregation A2, SobekCM_Item_Aggregation_Hierarchy H
	where ( A2.[Type] not like 'Institut%' )
	  and ( T.AggregationID = H.ParentID )
	  and ( A2.AggregationID = H.ChildID )
	  and ( Deleted='false' )
	  and ( ChildCode <> '' );
	  
	-- Get total item count
	declare @total_item_count int;
	select @total_item_count =  ( select count(*) from SobekCM_Item where Deleted = 'false' and Milestone_OnlineComplete is not null );

	-- Get total title count
	declare @total_title_count int;
    select @total_title_count = ( select count(G.GroupID)
                                  from SobekCM_Item_Group G
                                  where exists ( select ItemID
                                                 from SobekCM_Item I
                                                 where ( I.Deleted = 'false' )
                                                   and ( Milestone_OnlineComplete is not null )
                                                   and ( I.GroupID = G.GroupID )));
	-- Get total title count
	declare @total_page_count int;
	select @total_page_count =  coalesce(( select sum( [PageCount] ) from SobekCM_Item where Deleted = 'false'  and ( Milestone_OnlineComplete is not null )), 0 );

	-- Get total item count
	declare @total_item_count_date1 int;
	select @total_item_count_date1 =  ( select count(ItemID) 
										from SobekCM_Item I
										where ( I.Deleted = 'false' )
										  and ( Milestone_OnlineComplete is not null )
										  and ( Milestone_OnlineComplete <= @date1 ));

	-- Get total title count
	declare @total_title_count_date1 int;
	select @total_title_count_date1 =  ( select count(G.GroupID)
										 from SobekCM_Item_Group G
										 where exists ( select *
														from SobekCM_Item I
														where ( I.Deleted = 'false' )
														  and ( Milestone_OnlineComplete is not null )
														  and ( Milestone_OnlineComplete <= @date1 ) 
														  and ( I.GroupID = G.GroupID )));


	-- Get total title count
	declare @total_page_count_date1 int;
	select @total_page_count_date1 =  ( select sum( coalesce([PageCount],0) ) 
										from SobekCM_Item I
										where ( I.Deleted = 'false' )
										  and ( Milestone_OnlineComplete is not null )
										  and ( Milestone_OnlineComplete <= @date1 ));

	-- Return these values if this has just one date
	if ( isnull( @date2, '1/1/2000' ) = '1/1/2000' )
	begin
	
		-- Start to build the return set of values
		select code1 = Code, 
		       code2 = ChildCode,
		       code3 = Child2Code,
		       AllCodes,
		    [Name], 
		    C.isActive AS Active,
			title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ),
			item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 
			page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 0),
			title_count_date1 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1),
			item_count_date1 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1 ), 
			page_count_date1 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1 ), 0)
		from @Aggregation_List C
		union
		select 'ZZZ','','', 'ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count, 
			coalesce(@total_title_count_date1,0), coalesce(@total_item_count_date1,0), coalesce(@total_page_count_date1,0)
		order by code, code2, code3;
		
	end
	else
	begin

		-- Get total item count
		declare @total_item_count_date2 int
		select @total_item_count_date2 =  ( select count(ItemID) 
											from SobekCM_Item I
											where ( I.Deleted = 'false' )
											  and ( Milestone_OnlineComplete is not null )
											  and ( Milestone_OnlineComplete <= @date2 ));

		-- Get total title count
		declare @total_title_count_date2 int
		select @total_title_count_date2 =  ( select count(G.GroupID)
											 from SobekCM_Item_Group G
											 where exists ( select *
															from SobekCM_Item I
															where ( I.Deleted = 'false' )
															  and ( Milestone_OnlineComplete is not null )
															  and ( Milestone_OnlineComplete <= @date2 ) 
															  and ( I.GroupID = G.GroupID )));


		-- Get total title count
		declare @total_page_count_date2 int
		select @total_page_count_date2 =  ( select sum( coalesce([PageCount],0) ) 
											from SobekCM_Item I
											where ( I.Deleted = 'false' )
											  and ( Milestone_OnlineComplete is not null )
											  and ( Milestone_OnlineComplete <= @date2 ));


		-- Start to build the return set of values
		select code1 = Code, 
		       code2 = ChildCode,
		       code3 = Child2Code,
		       AllCodes,
		    [Name], 
		    C.isActive AS Active,
			title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ),
			item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 
			page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 0),
			title_count_date1 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1),
			item_count_date1 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1 ), 
			page_count_date1 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1 ), 0),
			title_count_date2 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date2),
			item_count_date2 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date2 ), 
			page_count_date2 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date2 ), 0)
		from @Aggregation_List C
		union
		select 'ZZZ','','','ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count, 
				coalesce(@total_title_count_date1,0), coalesce(@total_item_count_date1,0), coalesce(@total_page_count_date1,0),
				coalesce(@total_title_count_date2,0), coalesce(@total_item_count_date2,0), coalesce(@total_page_count_date2,0)
		order by code, code2, code3;
	end;
END;
GO

/****** Object:  StoredProcedure [dbo].[SobekCM_Delete_Item]    Script Date: 12/20/2013 05:43:36 ******/
-- Deletes an item, and deletes the group if there are no additional items attached
ALTER PROCEDURE [dbo].[SobekCM_Delete_Item] 
@bibid varchar(10),
@vid varchar(5),
@as_admin bit,
@delete_message varchar(1000)
AS
begin transaction
	-- Perform transactionally in case there is a problem deleting some of the rows
	-- so the entire delete is rolled back

   declare @itemid int;
   set @itemid = 0;

    -- first to get the itemid of the specified bibid and vid
   select @itemid = isnull(I.itemid, 0)
   from SobekCM_Item I, SobekCM_Item_Group G
   where (G.bibid = @bibid) 
       and (I.vid = @vid)
       and ( I.GroupID = G.GroupID );

   -- if there is such an itemid in the UFDC database, then delete this item and its related information
  if ( isnull(@itemid, 0 ) > 0)
  begin

	-- Delete all references to this item 
	delete from SobekCM_Metadata_Unique_Link where ItemID=@itemid;
	delete from SobekCM_Metadata_Basic_Search_Table where ItemID=@itemid;
	delete from SobekCM_Item_Footprint where ItemID=@itemid;
	delete from SobekCM_Item_Icons where ItemID=@itemid;
	delete from SobekCM_Item_Statistics where ItemID=@itemid;
	delete from SobekCM_Item_GeoRegion_Link where ItemID=@itemid;
	delete from SobekCM_Item_Aggregation_Item_Link where ItemID=@itemid;
	delete from mySobek_User_Item where ItemID=@itemid;
	delete from mySobek_User_Item_Link where ItemID=@itemid;
	delete from mySobek_User_Description_Tags where ItemID=@itemid;
	delete from SobekCM_Item_Viewers where ItemID=@itemid;
	delete from Tracking_Item where ItemID=@itemid;
	delete from Tracking_Progress where ItemID=@itemid;
	delete from SobekCM_Item_OAI where ItemID=@itemid;
	
	if ( @as_admin = 'true' )
	begin
		delete from Tracking_Archive_Item_Link where ItemID=@itemid;
		update Tivoli_File_Log set DeleteMsg=@delete_message, ItemID = -1 where ItemID=@itemid;
	end;
	
	-- Finally, delete the item 
	delete from SobekCM_Item where ItemID=@itemid;
	
	-- Delete the item group if it is the last one existing
	if (( select count(I.ItemID) from SobekCM_Item_Group G, SobekCM_Item I where ( G.BibID = @bibid ) and ( G.GroupID = I.GroupID ) and ( I.Deleted = 0 )) < 1 )
	begin
		
		declare @groupid int;
		set @groupid = 0;	
		
		-- first to get the itemid of the specified bibid and vid
		select @groupid = isnull(G.GroupID, 0)
		from SobekCM_Item_Group G
		where (G.bibid = @bibid);
		
		-- Delete if this selected something
		if ( ISNULL(@groupid, 0 ) > 0 )
		begin		
			-- delete from the item group table	and all references
			delete from SobekCM_Item_Group_External_Record where GroupID=@groupid;
			delete from SobekCM_Item_Group_Web_Skin_Link where GroupID=@groupid;
			delete from SobekCM_Item_Group_Statistics where GroupID=@groupid;
			delete from mySobek_User_Bib_Link where GroupID=@groupid;
			delete from SobekCM_Item_Group_OAI where GroupID=@groupid;
			delete from SobekCM_Item_Group where GroupID=@groupid;
		end;
	end
	else
	begin
		-- Finally set the volume count for this group correctly
		update SobekCM_Item_Group
		set ItemCount = ( select count(*) from SobekCM_Item I where ( I.GroupID = SobekCM_Item_Group.GroupID ))	
		where ( SobekCM_Item_Group.BibID = @bibid );
	end;
  end;
   
commit transaction;
GO


/****** Object:  StoredProcedure [dbo].[mySobek_Update_User]    Script Date: 12/20/2013 05:43:36 ******/
-- Procedure allows an admin to edit permissions flags for this user
ALTER PROCEDURE [dbo].[mySobek_Update_User]
      @userid int,
      @can_submit bit,
      @is_internal bit,
      @can_edit_all bit,
      @can_delete_all bit,
      @is_portal_admin bit,
      @is_system_admin bit,
	  @is_host_admin bit,
      @include_tracking_standard_forms bit,
      @edit_template varchar(20),
      @edit_template_marc varchar(20),
      @clear_projects_templates bit,
      @clear_aggregation_links bit,
      @clear_user_groups bit
AS
begin transaction

      -- Update the simple table values
      update mySobek_User
      set Can_Submit_Items=@can_submit, Internal_User=@is_internal, 
            IsPortalAdmin=@is_portal_admin, IsSystemAdmin=@is_system_admin, 
            Include_Tracking_Standard_Forms=@include_tracking_standard_forms, 
            EditTemplate=@edit_template, Can_Delete_All_Items = @can_delete_all,
            EditTemplateMarc=@edit_template_marc, IsHostAdmin=@is_host_admin
      where UserID=@userid;

      -- Check the flag to edit all items
      if ( @can_edit_all = 'true' )
      begin 
            if ( ( select count(*) from mySobek_User_Editable_Link where EditableID=1 and UserID=@userid ) = 0 )
            begin
                  -- Add the link to the ALL EDITABLE
                  insert into mySobek_User_Editable_Link ( UserID, EditableID )
                  values ( @userid, 1 );
            end;
      end
      else
      begin
            -- Delete the link to all
            delete from mySobek_User_Editable_Link where EditableID = 1 and UserID=@userid;
      end;

      -- Clear the projects/templates
      if ( @clear_projects_templates = 'true' )
      begin
            delete from mySobek_User_DefaultMetadata_Link where UserID=@userid;
            delete from mySobek_User_Template_Link where UserID=@userid;
      end;

      -- Clear the projects/templates
      if ( @clear_aggregation_links = 'true' )
      begin
            delete from mySobek_User_Edit_Aggregation where UserID=@userid;
      end;
      
      -- Clear the user groups
      if ( @clear_user_groups = 'true' )
      begin
            delete from mySobek_User_Group_Link where UserID=@userid;
      end;

commit transaction;
GO


-- Gets the list of all point coordinates for a single aggregation
ALTER PROCEDURE [dbo].[SobekCM_Coordinate_Points_By_Aggregation]
	@aggregation_code varchar(20)
AS
begin

	-- No need to perform any locks here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- Return the groups/items/points
	with min_itemid_per_groupid as
	(
		-- Get the mininmum ItemID per group per coordinate point
		select GroupID, F.Point_Latitude, F.Point_Longitude, Min(I.ItemID) as MinItemID
		from SobekCM_Item I, SobekCM_Item_Aggregation_Item_Link L, SobekCM_Item_Aggregation A, SobekCM_Item_Footprint F
		where ( I.ItemID = L.ItemID  )
		  and ( L.AggregationID = A.AggregationID )
		  and ( A.Code = @aggregation_code ) 
		  and ( F.ItemID = I.ItemID )
		  and ( F.Point_Latitude is not null )
		  and ( F.Point_Longitude is not null )
		group by GroupID, F.Point_Latitude, F.Point_Longitude
	), min_item_thumbnail_per_group as
	(
	    -- Get the matching item thumbnail for the item per group per coordiante point
		select G.GroupID, G.Point_Latitude, G.Point_Longitude, I.VID + '/' + I.MainThumbnail as MinThumbnail
		from SobekCM_Item I, min_itemid_per_groupid G
		where G.MinItemID = I.ItemID
	)
	-- Return all matchint group/coordinate point, with the group thumbnail, or item thumbnail from above WITH statements
	select F.Point_Latitude, F.Point_Longitude, G.BibID, G.GroupTitle, coalesce(NULLIF(G.GroupThumbnail,''), T.MinThumbnail) as Thumbnail, G.ItemCount, G.[Type]
	from SobekCM_Item_Group G, SobekCM_Item I, SobekCM_Item_Aggregation_Item_Link L, SobekCM_Item_Footprint F, SobekCM_Item_Aggregation A, min_item_thumbnail_per_group T
	where ( G.GroupID = I.GroupID )
	  and ( I.ItemID = L.ItemID  )
	  and ( L.AggregationID = A.AggregationID )
	  and ( A.Code = @aggregation_code ) 
	  and ( F.ItemID = I.ItemID )
	  and ( F.Point_Latitude is not null )
	  and ( F.Point_Longitude is not null )
	  and ( T.GroupID = G.GroupID )
	  and ( T.Point_Latitude = F.Point_Latitude )
	  and ( T.Point_Longitude = F.Point_Longitude )
	group by I.Spatial_KML, F.Point_Latitude, F.Point_Longitude, G.BibID, G.GroupTitle, coalesce(NULLIF(G.GroupThumbnail,''), T.MinThumbnail), G.ItemCount, G.[Type]
	order by I.Spatial_KML;
end;
GO


-- Gets all of the information about a single item aggregation
ALTER PROCEDURE [dbo].[SobekCM_Get_Item_Aggregation]
	@code varchar(20)
AS
begin

	-- No need to perform any locks here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- Create the temporary table
	create table #TEMP_CHILDREN_BUILDER (AggregationID int, Code varchar(20), ParentCode varchar(20), Name varchar(255), [Type] varchar(50), ShortName varchar(100), isActive bit, Hidden bit, HierarchyLevel int );
	
	-- Get the aggregation id
	declare @aggregationid int
	set @aggregationid = coalesce((select AggregationID from SobekCM_Item_Aggregation AS C where C.Code = @code and Deleted=0), -1 );
	
	-- Return information about this aggregation
	select AggregationID, Code, [Name], coalesce(ShortName,[Name]) AS ShortName, [Type], isActive, Hidden, HasNewItems,
	   ContactEmail, DefaultInterface, [Description], Map_Display, Map_Search, OAI_Flag, OAI_Metadata, DisplayOptions, LastItemAdded, 
	   Can_Browse_Items, Items_Can_Be_Described, External_Link, T.ThematicHeadingID, LanguageVariants, ThemeName
	from SobekCM_Item_Aggregation AS C left outer join
	     SobekCM_Thematic_Heading as T on C.ThematicHeadingID=T.ThematicHeadingID 
	where C.AggregationID = @aggregationid;

	-- Drive down through the children in the item aggregation hierarchy (first level below)
	insert into #TEMP_CHILDREN_BUILDER ( AggregationID, Code, ParentCode, Name, [Type], ShortName, isActive, Hidden, HierarchyLevel )
	select C.AggregationID, C.Code, ParentCode=@code, C.[Name], C.[Type], coalesce(C.ShortName,C.[Name]) AS ShortName, C.isActive, C.Hidden, -1
	from SobekCM_Item_Aggregation AS P INNER JOIN
		 SobekCM_Item_Aggregation_Hierarchy AS H ON H.ParentID = P.AggregationID INNER JOIN
		 SobekCM_Item_Aggregation AS C ON H.ChildID = C.AggregationID 
	where ( P.AggregationID = @aggregationid )
	  and ( C.Deleted = 'false' );
	
	-- Now, try to find any children to this ( second level below )
	insert into #TEMP_CHILDREN_BUILDER ( AggregationID, Code, ParentCode, Name, [Type], ShortName, isActive, Hidden, HierarchyLevel )
	select C.AggregationID, C.Code, P.Code, C.[Name], C.[Type], coalesce(C.ShortName,C.[Name]) AS ShortName, C.isActive, C.Hidden, -2
	from #TEMP_CHILDREN_BUILDER AS P INNER JOIN
			SobekCM_Item_Aggregation_Hierarchy AS H ON H.ParentID = P.AggregationID INNER JOIN
			SobekCM_Item_Aggregation AS C ON H.ChildID = C.AggregationID 
	where ( HierarchyLevel = -1 )
	  and ( C.Deleted = 'false' );

	-- Now, try to find any children to this ( third level below )
	insert into #TEMP_CHILDREN_BUILDER ( AggregationID, Code, ParentCode, Name, [Type], ShortName, isActive, Hidden, HierarchyLevel )
	select C.AggregationID, C.Code, P.Code, C.[Name], C.[Type], coalesce(C.ShortName,C.[Name]) AS ShortName, C.isActive, C.Hidden, -3
	from #TEMP_CHILDREN_BUILDER AS P INNER JOIN
			SobekCM_Item_Aggregation_Hierarchy AS H ON H.ParentID = P.AggregationID INNER JOIN
			SobekCM_Item_Aggregation AS C ON H.ChildID = C.AggregationID 
	where ( HierarchyLevel = -2 )
	  and ( C.Deleted = 'false' );

	-- Now, try to find any children to this ( fourth level below )
	insert into #TEMP_CHILDREN_BUILDER ( AggregationID, Code, ParentCode, Name, [Type], ShortName, isActive, Hidden, HierarchyLevel )
	select C.AggregationID, C.Code, P.Code, C.[Name], C.[Type], coalesce(C.ShortName,C.[Name]) AS ShortName, C.isActive, C.Hidden, -4
	from #TEMP_CHILDREN_BUILDER AS P INNER JOIN
			SobekCM_Item_Aggregation_Hierarchy AS H ON H.ParentID = P.AggregationID INNER JOIN
			SobekCM_Item_Aggregation AS C ON H.ChildID = C.AggregationID 
	where ( HierarchyLevel = -3 )
	  and ( C.Deleted = 'false' );

	-- Return all the children
	select Code, ParentCode, [Name], [ShortName], [Type], HierarchyLevel, isActive, Hidden
	from #TEMP_CHILDREN_BUILDER
	order by HierarchyLevel, Code ASC;
	
	-- drop the temporary tables
	drop table #TEMP_CHILDREN_BUILDER;

	-- Return all the metadata ids for metadata types which have values 
	select T.MetadataTypeID, T.canFacetBrowse, T.DisplayTerm, T.SobekCode, T.SolrCode
	into #TEMP_METADATA
	from SobekCM_Metadata_Types T
	where ( LEN(T.SobekCode) > 0 )
	  and exists ( select * from SobekCM_Item_Aggregation_Metadata_Link L where L.AggregationID=@aggregationid and L.MetadataTypeID=T.MetadataTypeID and L.Metadata_Count > 0 );

	if (( select count(*) from #TEMP_METADATA ) > 0 )
	begin
		select * from #TEMP_METADATA order by DisplayTerm ASC;
	end
	else
	begin
		select MetadataTypeID, canFacetBrowse, DisplayTerm, SobekCode, SolrCode
		from SobekCM_Metadata_Types 
		where DefaultAdvancedSearch = 'true'
		order by DisplayTerm ASC;
	end;
			
	-- Return all the parents 
	select Code, [Name], [ShortName], [Type], isActive
	from SobekCM_Item_Aggregation A, SobekCM_Item_Aggregation_Hierarchy H
	where A.AggregationID = H.ParentID 
	  and H.ChildID = @aggregationid
	  and A.Deleted = 'false';

	-- Return the max/min of latitude and longitude - spatial footprint to cover all items with coordinate info
	select Min(F.Point_Latitude) as Min_Latitude, Max(F.Point_Latitude) as Max_Latitude, Min(F.Point_Longitude) as Min_Longitude, Max(F.Point_Longitude) as Max_Longitude
	from SobekCM_Item I, SobekCM_Item_Aggregation_Item_Link L, SobekCM_Item_Footprint F
	where ( I.ItemID = L.ItemID  )
	  and ( L.AggregationID = @aggregationid )
	  and ( F.ItemID = I.ItemID )
	  and ( F.Point_Latitude is not null )
	  and ( F.Point_Longitude is not null )
	  and ( I.Dark = 'false' );

end;
GO


-- Get the information about the ALL aggregation - standard fron home page collection
-- Written by Mark Sullivan (September 2005), Updated ( January 2010 )
ALTER PROCEDURE [dbo].[SobekCM_Get_All_Groups]
	@metadata_count_to_use_cache int
AS
begin 

	-- No need to perform any locks here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	-- Create the temporary table variable
	declare @TEMP_CHILDREN_BUILDER table ( AggregationID int primary key, Code varchar(20), ParentCode varchar(20), Name nvarchar(255), ShortName nvarchar(100), [Type] nvarchar(50), HierarchyLevel int, isActive bit, Hidden bit );

	-- Get the aggregation id for 'all'
	declare @aggregationid int;
	
	-- Get the aggregation id
	select @aggregationid = AggregationID
	from SobekCM_Item_Aggregation AS C 
	where ( C.Code = 'all' );
	
	-- Return information about this aggregation
	select AggregationID, Code, [Name], isnull(ShortName,[Name]) AS ShortName, [Type], isActive, Hidden, HasNewItems,
	   ContactEmail, DefaultInterface, [Description], Map_Display, Map_Search, OAI_Flag, OAI_Metadata, DisplayOptions, 
	   LastItemAdded=(select MAX(CreateDate) from SobekCM_Item), Can_Browse_Items, Items_Can_Be_Described, External_Link
	from SobekCM_Item_Aggregation AS C 
	where ( C.AggregationID=@aggregationid );
	
	-- Return every metadata term for which any data is present
	if ( ( select COUNT(*) from SobekCM_Item_Aggregation_Metadata_Link where AggregationID=@aggregationid ) > @metadata_count_to_use_cache )
	begin
		-- Just pull the cached links here
		select distinct(S.MetadataTypeID), T.canFacetBrowse, DisplayTerm, T.SobekCode, T.SolrCode
		from SobekCM_Item_Aggregation_Metadata_Link S, 
			SobekCM_Metadata_Types T
		where ( S.MetadataTypeID = T.MetadataTypeID )
		  and ( S.AggregationID = @aggregationid )
		group by S.MetadataTypeID, DisplayTerm, T.canFacetBrowse, T.SobekCode, T.SolrCode
		order by DisplayTerm ASC;		
		
	end
	else
	begin
		-- Just pull this from the actual metadata links then
		select distinct(S.MetadataTypeID), T.canFacetBrowse, DisplayTerm, T.SobekCode, T.SolrCode
		from SobekCM_Metadata_Unique_Search_Table S, 
			SobekCM_Metadata_Types T
		where ( S.MetadataTypeID = T.MetadataTypeID )
		group by S.MetadataTypeID, DisplayTerm, T.canFacetBrowse, T.SobekCode, T.SolrCode
		order by DisplayTerm ASC;		
	end;

	-- Return the max/min of latitude and longitude - spatial footprint to cover all items with coordinate info
	select Min(F.Point_Latitude) as Min_Latitude, Max(F.Point_Latitude) as Max_Latitude, Min(F.Point_Longitude) as Min_Longitude, Max(F.Point_Longitude) as Max_Longitude
	from SobekCM_Item I, SobekCM_Item_Footprint F
	where ( F.ItemID = I.ItemID )
	  and ( F.Point_Latitude is not null )
	  and ( F.Point_Longitude is not null )
	  and ( I.Dark = 'false' );
end;
GO



-- Procedure returns the items by a coordinate search
ALTER PROCEDURE [dbo].[SobekCM_Get_Items_By_Coordinates]
	@lat1 float,
	@long1 float,
	@lat2 float,
	@long2 float,
	@include_private bit,
	@aggregationcode varchar(20),
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
	@total_titles int output
AS
BEGIN

	-- No need to perform any locks here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- Create the temporary tables first
	-- Create the temporary table to hold all the item id's
	create table #TEMPSUBZERO ( ItemID int );
	create table #TEMPZERO ( ItemID int );
	create table #TEMP_ITEMS ( ItemID int, fk_TitleID int, SortDate bigint, SpatialFootprint varchar(255), SpatialFootprintDistance float );

	-- Is this really just a point search?
	if (( isnull(@lat2,1000) = 1000 ) or ( isnull(@long2,1000) = 1000 ) or (( @lat1=@lat2 ) and ( @long1=@long2 )))
	begin

		-- Select all matching item ids
		insert into #TEMPZERO
		select distinct(itemid) 
		from SobekCM_Item_Footprint
		where (( Point_Latitude = @lat1 ) and ( Point_Longitude = @long1 ))
		   or (((( Rect_Latitude_A >= @lat1 ) and ( Rect_Latitude_B <= @lat1 )) or (( Rect_Latitude_A <= @lat1 ) and ( Rect_Latitude_B >= @lat1)))
	        and((( Rect_Longitude_A >= @long1 ) and ( Rect_Longitude_B <= @long1 )) or (( Rect_Longitude_A <= @long1 ) and ( Rect_Longitude_B >= @long1 ))));

	end
	else
	begin

		-- Select all matching item ids by rectangle
		insert into #TEMPSUBZERO
		select distinct(itemid)
		from SobekCM_Item_Footprint
		where ((( Point_Latitude <= @lat1 ) and ( Point_Latitude >= @lat2 )) or (( Point_Latitude >= @lat1 ) and ( Point_Latitude <= @lat2 )))
		  and ((( Point_Longitude <= @long1 ) and ( Point_Longitude >= @long2 )) or (( Point_Longitude >= @long1 ) and ( Point_Longitude <= @long2 )));
		


		-- Select rectangles which OVERLAP with this rectangle
		insert into #TEMPSUBZERO
		select distinct(itemid)
		from SobekCM_Item_Footprint
		where (((( Rect_Latitude_A >= @lat1 ) and ( Rect_Latitude_A <= @lat2 )) or (( Rect_Latitude_A <= @lat1 ) and ( Rect_Latitude_A >= @lat2 )))
			or ((( Rect_Latitude_B >= @lat1 ) and ( Rect_Latitude_B <= @lat2 )) or (( Rect_Latitude_B <= @lat1 ) and ( Rect_Latitude_B >= @lat2 ))))
		  and (((( Rect_Longitude_A >= @long1 ) and ( Rect_Longitude_A <= @long2 )) or (( Rect_Longitude_A <= @long1 ) and ( Rect_Longitude_A >= @long2 )))
			or ((( Rect_Longitude_B >= @long1 ) and ( Rect_Longitude_B <= @long2 )) or (( Rect_Longitude_B <= @long1 ) and ( Rect_Longitude_B >= @long2 ))));
		
		-- Select rectangles that INCLUDE this rectangle by picking overlaps with one point
		insert into #TEMPSUBZERO
		select distinct(itemid)
		from SobekCM_Item_Footprint
		where ((( @lat1 <= Rect_Latitude_A ) and ( @lat1 >= Rect_Latitude_B )) or (( @lat1 >= Rect_Latitude_A ) and ( @lat1 <= Rect_Latitude_B )))
		  and ((( @long1 <= Rect_Longitude_A ) and ( @long1 >= Rect_Longitude_B )) or (( @long1 >= Rect_Longitude_A ) and ( @long1 <= Rect_Longitude_B )));

		-- Make sure uniqueness applies here as well
		insert into #TEMPZERO
		select distinct(itemid)
		from #TEMPSUBZERO;

	end;
	
	-- Determine the start and end rows
	declare @rowstart int;
	declare @rowend int; 
	set @rowstart = (@pagesize * ( @pagenumber - 1 )) + 1;
	set @rowend = @rowstart + @pagesize - 1; 

	-- Set value for filtering privates
	declare @lower_mask int;
	set @lower_mask = 0;
	if ( @include_private = 'true' )
	begin
		set @lower_mask = -256;
	end;

	-- Determine the aggregationid
	declare @aggregationid int;
	set @aggregationid = coalesce(( select AggregationID from SobekCM_Item_Aggregation where Code=@aggregationcode ), -1);

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
			
	-- Was an aggregation included?
	if ( LEN(coalesce( @aggregationcode,'' )) > 0 )
	begin	
		-- Look for matching the provided aggregation
		insert into #TEMP_ITEMS ( ItemID, fk_TitleID, SortDate, SpatialFootprint, SpatialFootprintDistance )
		select I.ItemID, I.GroupID, SortDate=coalesce( I.SortDate,-1), SpatialFootprint=coalesce(SpatialFootprint,''), SpatialFootprintDistance
		from #TEMPZERO T1, SobekCM_Item I, SobekCM_Item_Aggregation_Item_Link CL
		where ( CL.ItemID = I.ItemID )
		  and ( CL.AggregationID = @aggregationid )
		  and ( I.Deleted = 'false' )
		  and ( T1.ItemID = I.ItemID )
		  and ( I.IP_Restriction_Mask >= @lower_mask );
	end
	else
	begin	
		-- Look for matching the provided aggregation
		insert into #TEMP_ITEMS ( ItemID, fk_TitleID, SortDate, SpatialFootprint, SpatialFootprintDistance )
		select I.ItemID, I.GroupID, SortDate=coalesce( I.SortDate,-1), SpatialFootprint=coalesce(SpatialFootprint,''), SpatialFootprintDistance
		from #TEMPZERO T1, SobekCM_Item I
		where ( I.Deleted = 'false' )
		  and ( T1.ItemID = I.ItemID )
		  and ( I.IP_Restriction_Mask >= @lower_mask );
	end;
	

	
	-- Create the temporary item table variable for paging purposes
	declare @TEMP_PAGED_ITEMS TempPagedItemsTableType;
	
	-- There are essentially THREE major paths of execution, depending on whether this should
	-- be grouped as items within the page requested titles ( sorting by title or the basic
	-- sorting by rank, which ranks this way ) or whether each item should be
	-- returned by itself, such as sorting by individual publication dates, etc..
	-- The default sort for this search is by spatial coordiantes, in which case the same 
	-- title should appear multiple times, if the items in the volume have different coordinates
	
	if ( @sort = 0 )
	begin

		-- create the temporary title table definition
		create table #TEMP_TITLES_ITEMS ( TitleID int, BibID varchar(10), RowNumber int, SpatialFootprint varchar(255), SpatialFootprintDistance float );
		
		-- Compute the number of seperate titles/coordinates
		select fk_TitleID, (COUNT(SpatialFootprint)) as assign_value
		into #TEMP1
		from #TEMP_ITEMS I
		group by fk_TitleID, SpatialFootprint;
		
		-- Get the TOTAL count of spatial_kmls
		select @total_titles = isnull(SUM(assign_value), 0) from #TEMP1;
		drop table #TEMP1;
		
		-- Total items is simpler to computer
		select @total_items = COUNT(*) from #TEMP_ITEMS;	
		
		-- For now, always return the max lookahead pages
		set @rowend = @rowstart + ( @pagesize * @maxpagelookahead ) - 1; 
		
		-- Create saved select across titles for row numbers
		with TITLES_SELECT AS
			(	select GroupID, G.BibID, SpatialFootprint, SpatialFootprintDistance,
					ROW_NUMBER() OVER (order by SpatialFootprintDistance ASC, SpatialFootprint ASC) as RowNumber
				from #TEMP_ITEMS I, SobekCM_Item_Group G
				where I.fk_TitleID = G.GroupID
				group by G.GroupID, G.BibID, G.SortTitle, SpatialFootprint, SpatialFootprintDistance )

		-- Insert the correct rows into the temp title table	
		insert into #TEMP_TITLES_ITEMS ( TitleID, BibID, RowNumber, SpatialFootprint, SpatialFootprintDistance )
		select GroupID, BibID, RowNumber, SpatialFootprint, SpatialFootprintDistance
		from TITLES_SELECT
		where RowNumber >= @rowstart
		  and RowNumber <= @rowend;

	  
		-- Return the title information for this page
		select RowNumber as TitleID, T.BibID, G.GroupTitle, G.ALEPH_Number as OPAC_Number, G.OCLC_Number, isnull(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], isnull(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, isnull(G.Primary_Identifier, '') as Primary_Identifier, SpatialFootprint, SpatialFootprintDistance
		from #TEMP_TITLES_ITEMS T, SobekCM_Item_Group G
		where ( T.TitleID = G.GroupID )
		order by RowNumber ASC;
		
		-- Get the item id's for the items related to these titles (using rownumber as the new group id)
		insert into @TEMP_PAGED_ITEMS
		select I.ItemID, RowNumber
		from #TEMP_TITLES_ITEMS T, #TEMP_ITEMS M, SobekCM_Item I
		where ( T.TitleID = M.fk_TitleID )
		  and ( M.ItemID = I.ItemID )
		  and ( M.SpatialFootprint = T.SpatialFootprint )
		  and ( M.SpatialFootprintDistance = T.SpatialFootprintDistance );  
			
		-- Return the basic system required item information for this page of results
		select T.RowNumber as fk_TitleID, I.ItemID, VID, Title, IP_Restriction_Mask, coalesce(I.MainThumbnail,'') as MainThumbnail, coalesce(I.Level1_Index, -1) as Level1_Index, coalesce(I.Level1_Text,'') as Level1_Text, coalesce(I.Level2_Index, -1) as Level2_Index, coalesce(I.Level2_Text,'') as Level2_Text, coalesce(I.Level3_Index,-1) as Level3_Index, coalesce(I.Level3_Text,'') as Level3_Text, isnull(I.PubDate,'') as PubDate, I.[PageCount], coalesce(I.Link,'') as Link, coalesce( SpatialFootprint, '') as SpatialFootprint, coalesce(COinS_OpenURL, '') as COinS_OpenURL		
		from SobekCM_Item I, @TEMP_PAGED_ITEMS T
		where ( T.ItemID = I.ItemID )
		order by T.RowNumber, Level1_Index, Level2_Index, Level3_Index;			
								
		-- Return the aggregation-specific display values for all the items in this page of results
		execute sp_Executesql @item_display_sql, N' @itemtable TempPagedItemsTableType READONLY', @TEMP_PAGED_ITEMS; 
	
		-- drop the temporary table
		drop table #TEMP_TITLES_ITEMS;	
	end;
	
	if (( @sort < 10 ) and ( @sort > 0 ))
	begin	
		-- create the temporary title table definition
		create table #TEMP_TITLES ( TitleID int, BibID varchar(10), RowNumber int );

		-- Get the total counts
		select @total_items=COUNT(*), @total_titles=COUNT(distinct fk_TitleID)
		from #TEMP_ITEMS; 

		-- If there are some titles, continue
		if ( @total_titles > 0 )
		begin
		
			-- Now, calculate the actual ending row, based on the ration, page information,
			-- and the lookahead factor
		
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
		  
			-- Create saved select across titles for row numbers
			with TITLES_SELECT AS
				(	select GroupID, G.BibID, 
						ROW_NUMBER() OVER (order by case when @sort=1 THEN G.SortTitle end ASC,											
													case when @sort=2 THEN BibID end ASC,
													case when @sort=3 THEN BibID end DESC) as RowNumber
					from #TEMP_ITEMS I, SobekCM_Item_Group G
					where I.fk_TitleID = G.GroupID
					group by G.GroupID, G.BibID, G.SortTitle )

			-- Insert the correct rows into the temp title table	
			insert into #TEMP_TITLES ( TitleID, BibID, RowNumber )
			select GroupID, BibID, RowNumber
			from TITLES_SELECT
			where RowNumber >= @rowstart
			  and RowNumber <= @rowend;
	
			-- Return the title information for this page
			select RowNumber as TitleID, T.BibID, G.GroupTitle, G.ALEPH_Number, G.OCLC_Number, isnull(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], isnull(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, isnull(G.Primary_Identifier, '') as Primary_Identifier
			from #TEMP_TITLES T, SobekCM_Item_Group G
			where ( T.TitleID = G.GroupID )
			order by RowNumber ASC;
		
			-- Get the item id's for the items related to these titles
			insert into @TEMP_PAGED_ITEMS
			select ItemID, RowNumber
			from #TEMP_TITLES T, SobekCM_Item I
			where ( T.TitleID = I.GroupID );			  
			
			-- Return the basic system required item information for this page of results
			select T.RowNumber as fk_TitleID, I.ItemID, VID, Title, IP_Restriction_Mask, coalesce(I.MainThumbnail,'') as MainThumbnail, coalesce(I.Level1_Index, -1) as Level1_Index, coalesce(I.Level1_Text,'') as Level1_Text, coalesce(I.Level2_Index, -1) as Level2_Index, coalesce(I.Level2_Text,'') as Level2_Text, coalesce(I.Level3_Index,-1) as Level3_Index, coalesce(I.Level3_Text,'') as Level3_Text, isnull(I.PubDate,'') as PubDate, I.[PageCount], coalesce(I.Link,'') as Link, coalesce( SpatialFootprint, '') as SpatialFootprint, coalesce(COinS_OpenURL, '') as COinS_OpenURL		
			from SobekCM_Item I, @TEMP_PAGED_ITEMS T
			where ( T.ItemID = I.ItemID )
			order by T.RowNumber, Level1_Index, Level2_Index, Level3_Index;			
								
			-- Return the aggregation-specific display values for all the items in this page of results
			execute sp_Executesql @item_display_sql, N' @itemtable TempPagedItemsTableType READONLY', @TEMP_PAGED_ITEMS; 	

			-- drop the temporary table
			drop table #TEMP_TITLES;

		end;
	end;
	
	if ( @sort >= 10 )
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
				ROW_NUMBER() OVER (order by case when @sort=10 THEN SortDate end ASC,
											case when @sort=11 THEN SortDate end DESC) as RowNumber
				from #TEMP_ITEMS I
				group by I.ItemID, SortDate )
					  
		-- Insert the correct rows into the temp item table	
		insert into @TEMP_PAGED_ITEMS ( ItemID, RowNumber )
		select ItemID, RowNumber
		from ITEMS_SELECT
		where RowNumber >= @rowstart
		  and RowNumber <= @rowend;
		  
		-- Return the title information for this page
		select RowNumber as TitleID, G.BibID, G.GroupTitle, G.ALEPH_Number, G.OCLC_Number, isnull(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], isnull(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, isnull(G.Primary_Identifier, '') as Primary_Identifier
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
	end;
	
	-- Return the facets if asked for
	if ( @include_facets = 'true' )
	begin	
		-- Only return the aggregation codes if this was a search across all collections	
		if (( LEN( isnull( @aggregationcode, '')) = 0 ) or ( @aggregationcode='all'))
		begin
			-- Build the aggregation list
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
	end;

	-- drop the temporary tables
	drop table #TEMP_ITEMS;
	drop table #TEMPZERO;
	drop table #TEMPSUBZERO;

END;
go


-- Takes all the individual pieces of metadata linked to an item, and then collapses them 
-- all together into a large single value to be stored for the basic searches which do
-- not indicate anything about which field each search term should appear in.
ALTER PROCEDURE [dbo].[SobekCM_Create_Full_Citation_Value]
	@itemid int
AS
begin

	-- Delete the old tracking box from the metadata unique link, since we wil pull
	-- in the latest value from the item table first
	delete from SobekCM_Metadata_Unique_Link 
	where ItemID=@itemid and exists ( select * from SobekCM_Metadata_Unique_Search_Table T where T.MetadataID = SobekCM_Metadata_Unique_Link.MetadataID and T.MetadataTypeID=36);

	-- Copy the tracking box from the item table
	if ( (select LEN(ISNULL(Tracking_Box,'')) from SobekCM_Item where ItemID=@itemid ) > 0 )
	begin
		-- Get the tracking box from the item table
		declare @tracking_box_add nvarchar(max);
		set @tracking_box_add = ( select Tracking_Box from SobekCM_Item where ItemID=@itemid );
		
		-- Save this in the single metadata portion, in case a search is done by 'tracking box'
		exec [SobekCM_Metadata_Save_Single] @itemid, 'Tracking Box', @tracking_box_add;
	end;
	
	-- Delete the old complete citation
	delete from SobekCM_Metadata_Basic_Search_Table
	where ItemID=@itemid;

	-- Prepare to step through each metadata value and build the full citation and also
	-- each individual search value for the 
	declare @singlevalue nvarchar(max);
	declare @metadatatype int;
	declare @fullcitation nvarchar(max);
	declare @title nvarchar(max);
	declare @type nvarchar(max);
	declare @language nvarchar(max);
	declare @creator nvarchar(max);
	declare @publisher nvarchar(max);
	declare @publication_place nvarchar(max);
	declare @subject_keyword nvarchar(max);
	declare @genre nvarchar(max);
	declare @target_audience nvarchar(max);
	declare @spatial_coverage nvarchar(max);
	declare @country nvarchar(max);
	declare @state nvarchar(max);
	declare @county nvarchar(max);
	declare @city nvarchar(max);
	declare @source_institution nvarchar(max);
	declare @holding_location nvarchar(max);
	declare @identifier nvarchar(max);
	declare @notes nvarchar(max);
	declare @other_citation nvarchar(max);
	declare @tickler nvarchar(max);
	declare @donor nvarchar(max);
	declare @format nvarchar(max);
	declare @bibid nvarchar(max);
	declare @publication_date nvarchar(max);
	declare @affiliation nvarchar(max);
	declare @frequency nvarchar(max);
	declare @name_as_subject nvarchar(max);
	declare @title_as_subject nvarchar(max);
	declare @all_subjects nvarchar(max);
	declare @temporal_subject nvarchar(max);
	declare @attribution nvarchar(max);
	declare @user_description nvarchar(max);
	declare @temporal_decade nvarchar(max);
	declare @mime_type nvarchar(max);
	declare @tracking_box nvarchar(max);
	declare @abstract nvarchar(max);
	declare @edition nvarchar(max);
	declare @toc nvarchar(max);
	declare @zt_kingdom nvarchar(max);
	declare @zt_phylum nvarchar(max);
	declare @zt_class nvarchar(max);
	declare @zt_order nvarchar(max);
	declare @zt_family nvarchar(max);
	declare @zt_genus nvarchar(max);
	declare @zt_species nvarchar(max);
	declare @zt_common_name nvarchar(max);
	declare @zt_scientific_name nvarchar(max);
	declare @zt_all_taxonomy nvarchar(max);
	declare @cultural_context nvarchar(max);
	declare @inscription nvarchar(max);
	declare @material nvarchar(max);
	declare @style_period nvarchar(max);
	declare @technique nvarchar(max);
	declare @accession_number nvarchar(max);
	declare @interviewee nvarchar(max);
	declare @interviewer nvarchar(max);
	declare @temporal_year nvarchar(max);
	declare @etd_committee nvarchar(max);
	declare @etd_degree nvarchar(max);
	declare @etd_degree_discipline nvarchar(max);
	declare @etd_degree_grantor nvarchar(max);
	declare @etd_degree_level nvarchar(max);
	declare @etd_degree_division nvarchar(max);
	declare @userdefined01 nvarchar(max);
	declare @userdefined02 nvarchar(max);
	declare @userdefined03 nvarchar(max);
	declare @userdefined04 nvarchar(max);
	declare @userdefined05 nvarchar(max);
	declare @userdefined06 nvarchar(max);
	declare @userdefined07 nvarchar(max);
	declare @userdefined08 nvarchar(max);
	declare @userdefined09 nvarchar(max);
	declare @userdefined10 nvarchar(max);
	declare @userdefined11 nvarchar(max);
	declare @userdefined12 nvarchar(max);
	declare @userdefined13 nvarchar(max);
	declare @userdefined14 nvarchar(max);
	declare @userdefined15 nvarchar(max);
	declare @userdefined16 nvarchar(max);
	declare @userdefined17 nvarchar(max);
	declare @userdefined18 nvarchar(max);
	declare @userdefined19 nvarchar(max);
	declare @userdefined20 nvarchar(max);
	declare @userdefined21 nvarchar(max);
	declare @userdefined22 nvarchar(max);
	declare @userdefined23 nvarchar(max);
	declare @userdefined24 nvarchar(max);
	declare @userdefined25 nvarchar(max);
	declare @userdefined26 nvarchar(max);
	declare @userdefined27 nvarchar(max);
	declare @userdefined28 nvarchar(max);
	declare @userdefined29 nvarchar(max);
	declare @userdefined30 nvarchar(max);
	declare @userdefined31 nvarchar(max);
	declare @userdefined32 nvarchar(max);
	declare @userdefined33 nvarchar(max);
	declare @userdefined34 nvarchar(max);
	declare @userdefined35 nvarchar(max);
	declare @userdefined36 nvarchar(max);
	declare @userdefined37 nvarchar(max);
	declare @userdefined38 nvarchar(max);
	declare @userdefined39 nvarchar(max);
	declare @userdefined40 nvarchar(max);
	declare @userdefined41 nvarchar(max);
	declare @userdefined42 nvarchar(max);
	declare @userdefined43 nvarchar(max);
	declare @userdefined44 nvarchar(max);
	declare @userdefined45 nvarchar(max);
	declare @userdefined46 nvarchar(max);
	declare @userdefined47 nvarchar(max);
	declare @userdefined48 nvarchar(max);
	declare @userdefined49 nvarchar(max);
	declare @userdefined50 nvarchar(max);
	declare @userdefined51 nvarchar(max);
	declare @userdefined52 nvarchar(max);	
	declare @publisher_display nvarchar(max);
	declare @spatial_display nvarchar(max);
	declare @measurement nvarchar(max);
	declare @subject_display nvarchar(max);
	declare @aggregations nvarchar(max);	
	declare @lom_aggregation nvarchar(max);	
	declare @lom_context nvarchar(max);
	declare @lom_classification nvarchar(max);
	declare @lom_difficulty nvarchar(max);
	declare @lom_user nvarchar(max);
	declare @lom_interactivity_level nvarchar(max);
	declare @lom_interactivity_type nvarchar(max);
	declare @lom_status nvarchar(max);
	declare @lom_requirements nvarchar(max);
	declare @lom_agerange nvarchar(max);

	
	
	set @fullcitation='';
	set @title='';
	set @type='';
	set @language='';
	set @creator='';
	set @publisher='';
	set @publication_place='';
	set @subject_keyword='';
	set @genre='';
	set @target_audience='';
	set @spatial_coverage='';
	set @country='';
	set @state='';
	set @county='';
	set @city='';
	set @source_institution='';
	set @holding_location='';
	set @identifier='';
	set @notes='';
	set @other_citation='';
	set @tickler='';
	set @donor='';
	set @format='';
	set @bibid='';
	set @publication_date='';
	set @affiliation='';
	set @frequency='';
	set @name_as_subject='';
	set @title_as_subject='';
	set @all_subjects='';
	set @temporal_subject='';
	set @attribution='';
	set @user_description='';
	set @temporal_decade='';
	set @mime_type='';
	set @tracking_box='';
	set @abstract='';
	set @edition='';
	set @toc='';
	set @zt_kingdom='';
	set @zt_phylum='';
	set @zt_class='';
	set @zt_order='';
	set @zt_family='';
	set @zt_genus='';
	set @zt_species='';
	set @zt_common_name='';
	set @zt_scientific_name='';
	set @zt_all_taxonomy='';
	set @cultural_context='';
	set @inscription='';
	set @material='';
	set @style_period='';
	set @technique='';
	set @accession_number='';
	set @interviewee ='';
	set @interviewer ='';
	set @temporal_year ='';
	set @etd_committee ='';
	set @etd_degree ='';
	set @etd_degree_discipline ='';
	set @etd_degree_grantor ='';
	set @etd_degree_level ='';
	set @etd_degree_division ='';
	set @userdefined01 ='';
	set @userdefined02 ='';
	set @userdefined03 ='';
	set @userdefined04 ='';
	set @userdefined05 ='';
	set @userdefined06 ='';
	set @userdefined07 ='';
	set @userdefined08 ='';
	set @userdefined09 ='';
	set @userdefined10 ='';
	set @userdefined11 ='';
	set @userdefined12 ='';
	set @userdefined13 ='';
	set @userdefined14 ='';
	set @userdefined15 ='';
	set @userdefined16 ='';
	set @userdefined17 ='';
	set @userdefined18 ='';
	set @userdefined19 ='';
	set @userdefined20 ='';
	set @userdefined21 ='';
	set @userdefined22 ='';
	set @userdefined23 ='';
	set @userdefined24 ='';
	set @userdefined25 ='';
	set @userdefined26 ='';
	set @userdefined27 ='';
	set @userdefined28 ='';
	set @userdefined29 ='';
	set @userdefined30 ='';
	set @userdefined31 ='';
	set @userdefined32 ='';
	set @userdefined33 ='';
	set @userdefined34 ='';
	set @userdefined35 ='';
	set @userdefined36 ='';
	set @userdefined37 ='';
	set @userdefined38 ='';
	set @userdefined39 ='';
	set @userdefined40 ='';
	set @userdefined41 ='';
	set @userdefined42 ='';
	set @userdefined43 ='';
	set @userdefined44 ='';
	set @userdefined45 ='';
	set @userdefined46 ='';
	set @userdefined47 ='';
	set @userdefined48 ='';
	set @userdefined49 ='';
	set @userdefined50 ='';
	set @userdefined51 ='';
	set @userdefined52 ='';
	set @publisher_display ='';
	set @spatial_display ='';
	set @measurement ='';
	set @subject_display ='';
	set @aggregations ='';	
	set @lom_aggregation ='';
	set @lom_context ='';
	set @lom_classification ='';
	set @lom_difficulty ='';
	set @lom_user ='';
	set @lom_interactivity_level ='';
	set @lom_interactivity_type ='';;
	set @lom_status ='';
	set @lom_requirements ='';
	set @lom_agerange ='';
		
	-- Use a cursor to step through all the metadata linked to this item
	declare metadatacursor cursor read_only
	for (select MetadataValue, MetadataTypeID
	    from SobekCM_Metadata_Unique_Search_Table M, SobekCM_Metadata_Unique_Link L
	    where L.ItemID=@itemid 
	      and L.MetadataID = M.MetadataID
	      and M.MetadataTypeID != 35);

	-- Open the cursor to begin stepping through all the unique metadata
	open metadatacursor;

	-- Get the first metadata value
	fetch next from metadatacursor into @singlevalue, @metadatatype;

	while @@fetch_status = 0
	begin
		-- Build the full citation by adding each single value to the full citation
		-- being built
		set @fullcitation = @fullcitation + ' | ' + @singlevalue;
		
		-- Now, build each smaller metadata value
		if ( @metadatatype = 1 ) set @title=@title + ' | ' + @singlevalue;
		if ( @metadatatype = 2 ) set @type=@type + ' | ' + @singlevalue;
		if ( @metadatatype = 3 ) set @language=@language + ' | ' + @singlevalue;
		if ( @metadatatype = 4 ) set @creator=@creator + ' | ' + @singlevalue;
		if ( @metadatatype = 5 ) set @publisher=@publisher + ' | ' + @singlevalue;
		if ( @metadatatype = 6 ) set @publication_place=@publication_place + ' | ' + @singlevalue;
		if ( @metadatatype = 7 ) set @subject_keyword=@subject_keyword + ' | ' + @singlevalue;
		if ( @metadatatype = 8 ) set @genre=@genre + ' | ' + @singlevalue;
		if ( @metadatatype = 9 ) set @target_audience=@target_audience + ' | ' + @singlevalue;
		if ( @metadatatype = 10 ) set @spatial_coverage=@spatial_coverage + ' | ' + @singlevalue;
		if ( @metadatatype = 11 ) set @country=@country + ' | ' + @singlevalue;
		if ( @metadatatype = 12 ) set @state=@state + ' | ' + @singlevalue;
		if ( @metadatatype = 13 ) set @county=@county + ' | ' + @singlevalue;
		if ( @metadatatype = 14 ) set @city=@city + ' | ' + @singlevalue;
		if ( @metadatatype = 15 ) set @source_institution=@source_institution + ' | ' + @singlevalue;
		if ( @metadatatype = 16 ) set @holding_location=@holding_location + ' | ' + @singlevalue;
		if ( @metadatatype = 17 ) set @identifier=@identifier + ' | ' + @singlevalue;
		if ( @metadatatype = 18 ) set @notes=@notes + ' | ' + @singlevalue;
		if ( @metadatatype = 19 ) set @other_citation=@other_citation + ' | ' + @singlevalue;
		if ( @metadatatype = 20 ) set @tickler=@tickler + ' | ' + @singlevalue;
		if ( @metadatatype = 21 ) set @donor=@donor + ' | ' + @singlevalue;
		if ( @metadatatype = 22 ) set @format=@format + ' | ' + @singlevalue;
		if ( @metadatatype = 23 ) set @bibid=@bibid + ' | ' + @singlevalue;
		if ( @metadatatype = 24 ) set @publication_date=@publication_date + ' | ' + @singlevalue;
		if ( @metadatatype = 25 ) set @affiliation=@affiliation + ' | ' + @singlevalue;
		if ( @metadatatype = 26 ) set @frequency=@frequency + ' | ' + @singlevalue;
		if ( @metadatatype = 27 ) set @name_as_subject=@name_as_subject + ' | ' + @singlevalue;
		if ( @metadatatype = 28 ) set @title_as_subject=@title_as_subject + ' | ' + @singlevalue;
		if ( @metadatatype = 29 ) set @all_subjects=@all_subjects + ' | ' + @singlevalue;
		if ( @metadatatype = 30 ) set @temporal_subject=@temporal_subject + ' | ' + @singlevalue;
		if ( @metadatatype = 31 ) set @attribution=@attribution + ' | ' + @singlevalue;
		if ( @metadatatype = 32 ) set @user_description=@user_description + ' | ' + @singlevalue;
		if ( @metadatatype = 33 ) set @temporal_decade=@temporal_decade + ' | ' + @singlevalue;
		if ( @metadatatype = 34 ) set @mime_type=@mime_type + ' | ' + @singlevalue;
		if ( @metadatatype = 36 ) set @tracking_box=@tracking_box + ' | ' + @singlevalue;
		if ( @metadatatype = 37 ) set @abstract=@abstract + ' | ' + @singlevalue;
		if ( @metadatatype = 38 ) set @edition=@edition + ' | ' + @singlevalue;
		if ( @metadatatype = 39 ) set @toc=@toc + ' | ' + @singlevalue;
		if ( @metadatatype = 40 ) set @zt_kingdom=@zt_kingdom + ' | ' + @singlevalue;
		if ( @metadatatype = 41 ) set @zt_phylum=@zt_phylum + ' | ' + @singlevalue;
		if ( @metadatatype = 42 ) set @zt_class=@zt_class + ' | ' + @singlevalue;
		if ( @metadatatype = 43 ) set @zt_order=@zt_order + ' | ' + @singlevalue;
		if ( @metadatatype = 44 ) set @zt_family=@zt_family + ' | ' + @singlevalue;
		if ( @metadatatype = 45 ) set @zt_genus=@zt_genus + ' | ' + @singlevalue;
		if ( @metadatatype = 46 ) set @zt_species=@zt_species + ' | ' + @singlevalue;
		if ( @metadatatype = 47 ) set @zt_common_name=@zt_common_name + ' | ' + @singlevalue;
		if ( @metadatatype = 48 ) set @zt_scientific_name=@zt_scientific_name + ' | ' + @singlevalue;
		if ( @metadatatype = 49 ) set @zt_all_taxonomy=@zt_all_taxonomy + ' | ' + @singlevalue;
		if ( @metadatatype = 50 ) set @cultural_context=@cultural_context + ' | ' + @singlevalue;
		if ( @metadatatype = 51 ) set @inscription=@inscription + ' | ' + @singlevalue;
		if ( @metadatatype = 52 ) set @material=@material + ' | ' + @singlevalue;
		if ( @metadatatype = 53 ) set @style_period=@style_period + ' | ' + @singlevalue;
		if ( @metadatatype = 54 ) set @technique=@technique + ' | ' + @singlevalue;
		if ( @metadatatype = 55 ) set @accession_number=@accession_number + ' | ' + @singlevalue;
		if ( @metadatatype = 62 ) set @interviewee = @interviewee + ' | ' + @singlevalue;
		if ( @metadatatype = 63 ) set @interviewer = @interviewer + ' | ' + @singlevalue;
		if ( @metadatatype = 61 ) set @temporal_year = @temporal_year + ' | ' + @singlevalue;
		if ( @metadatatype = 56 ) set @etd_committee = @etd_committee + ' | ' + @singlevalue;
		if ( @metadatatype = 57 ) set @etd_degree = @etd_degree + ' | ' + @singlevalue;
		if ( @metadatatype = 58 ) set @etd_degree_discipline = @etd_degree_discipline + ' | ' + @singlevalue;
		if ( @metadatatype = 59 ) set @etd_degree_grantor = @etd_degree_grantor + ' | ' + @singlevalue;
		if ( @metadatatype = 60 ) set @etd_degree_level = @etd_degree_level + ' | ' + @singlevalue;
		if ( @metadatatype = 64 ) set @userdefined01 = @userdefined01 + ' | ' + @singlevalue;
		if ( @metadatatype = 65 ) set @userdefined02 = @userdefined02 + ' | ' + @singlevalue;
		if ( @metadatatype = 66 ) set @userdefined03 = @userdefined03 + ' | ' + @singlevalue;
		if ( @metadatatype = 67 ) set @userdefined04 = @userdefined04 + ' | ' + @singlevalue;
		if ( @metadatatype = 68 ) set @userdefined05 = @userdefined05 + ' | ' + @singlevalue;
		if ( @metadatatype = 69 ) set @userdefined06 = @userdefined06 + ' | ' + @singlevalue;
		if ( @metadatatype = 70 ) set @userdefined07 = @userdefined07 + ' | ' + @singlevalue;
		if ( @metadatatype = 71 ) set @userdefined08 = @userdefined08 + ' | ' + @singlevalue;
		if ( @metadatatype = 72 ) set @userdefined09 = @userdefined09 + ' | ' + @singlevalue;
		if ( @metadatatype = 73 ) set @userdefined10 = @userdefined10 + ' | ' + @singlevalue;
		if ( @metadatatype = 74 ) set @userdefined11 = @userdefined11 + ' | ' + @singlevalue;
		if ( @metadatatype = 75 ) set @userdefined12 = @userdefined12 + ' | ' + @singlevalue;
		if ( @metadatatype = 76 ) set @userdefined13 = @userdefined13 + ' | ' + @singlevalue;
		if ( @metadatatype = 77 ) set @userdefined14 = @userdefined14 + ' | ' + @singlevalue;
		if ( @metadatatype = 78 ) set @userdefined15 = @userdefined15 + ' | ' + @singlevalue;
		if ( @metadatatype = 79 ) set @userdefined16 = @userdefined16 + ' | ' + @singlevalue;
		if ( @metadatatype = 80 ) set @userdefined17 = @userdefined17 + ' | ' + @singlevalue;
		if ( @metadatatype = 81 ) set @userdefined18 = @userdefined18 + ' | ' + @singlevalue;
		if ( @metadatatype = 82 ) set @userdefined19 = @userdefined19 + ' | ' + @singlevalue;
		if ( @metadatatype = 83 ) set @userdefined20 = @userdefined20 + ' | ' + @singlevalue;
		if ( @metadatatype = 84 ) set @userdefined21 = @userdefined21 + ' | ' + @singlevalue;
		if ( @metadatatype = 85 ) set @userdefined22 = @userdefined22 + ' | ' + @singlevalue;
		if ( @metadatatype = 86 ) set @userdefined23 = @userdefined23 + ' | ' + @singlevalue;
		if ( @metadatatype = 87 ) set @userdefined24 = @userdefined24 + ' | ' + @singlevalue;
		if ( @metadatatype = 88 ) set @userdefined25 = @userdefined25 + ' | ' + @singlevalue;
		if ( @metadatatype = 89 ) set @userdefined26 = @userdefined26 + ' | ' + @singlevalue;
		if ( @metadatatype = 90 ) set @userdefined27 = @userdefined27 + ' | ' + @singlevalue;
		if ( @metadatatype = 91 ) set @userdefined28 = @userdefined28 + ' | ' + @singlevalue;
		if ( @metadatatype = 92 ) set @userdefined29 = @userdefined29 + ' | ' + @singlevalue;
		if ( @metadatatype = 93 ) set @userdefined30 = @userdefined30 + ' | ' + @singlevalue;
		if ( @metadatatype = 94 ) set @userdefined31 = @userdefined31 + ' | ' + @singlevalue;
		if ( @metadatatype = 95 ) set @userdefined32 = @userdefined32 + ' | ' + @singlevalue;
		if ( @metadatatype = 96 ) set @userdefined33 = @userdefined33 + ' | ' + @singlevalue;
		if ( @metadatatype = 97 ) set @userdefined34 = @userdefined34 + ' | ' + @singlevalue;
		if ( @metadatatype = 98 ) set @userdefined35 = @userdefined35 + ' | ' + @singlevalue;
		if ( @metadatatype = 99 ) set @userdefined36 = @userdefined36 + ' | ' + @singlevalue;
		if ( @metadatatype = 100 ) set @userdefined37 = @userdefined37 + ' | ' + @singlevalue;
		if ( @metadatatype = 101 ) set @userdefined38 = @userdefined38 + ' | ' + @singlevalue;
		if ( @metadatatype = 102 ) set @userdefined39 = @userdefined39 + ' | ' + @singlevalue;
		if ( @metadatatype = 103 ) set @userdefined40 = @userdefined40 + ' | ' + @singlevalue;
		if ( @metadatatype = 104 ) set @userdefined41 = @userdefined41 + ' | ' + @singlevalue;
		if ( @metadatatype = 105 ) set @userdefined42 = @userdefined42 + ' | ' + @singlevalue;
		if ( @metadatatype = 106 ) set @userdefined43 = @userdefined43 + ' | ' + @singlevalue;
		if ( @metadatatype = 107 ) set @userdefined44 = @userdefined44 + ' | ' + @singlevalue;
		if ( @metadatatype = 108 ) set @userdefined45 = @userdefined45 + ' | ' + @singlevalue;
		if ( @metadatatype = 109 ) set @userdefined46 = @userdefined46 + ' | ' + @singlevalue;
		if ( @metadatatype = 110 ) set @userdefined47 = @userdefined47 + ' | ' + @singlevalue;
		if ( @metadatatype = 111 ) set @userdefined48 = @userdefined48 + ' | ' + @singlevalue;
		if ( @metadatatype = 112 ) set @userdefined49 = @userdefined49 + ' | ' + @singlevalue;
		if ( @metadatatype = 113 ) set @userdefined50 = @userdefined50 + ' | ' + @singlevalue;
		if ( @metadatatype = 114 ) set @userdefined51 = @userdefined51 + ' | ' + @singlevalue;
		if ( @metadatatype = 115 ) set @userdefined52 = @userdefined52 + ' | ' + @singlevalue;	
		if ( @metadatatype = 116 ) set @publisher_display = @publisher_display + ' | ' + @singlevalue;
		if ( @metadatatype = 117 ) set @spatial_display = @spatial_display + ' | ' + @singlevalue;
		if ( @metadatatype = 118 ) set @measurement = @measurement + ' | ' + @singlevalue;
		if ( @metadatatype = 119 ) set @subject_display = @subject_display + ' | ' + @singlevalue;
		if ( @metadatatype = 120 ) set @aggregations = @aggregations + ' | ' + @singlevalue;
		if ( @metadatatype = 121 ) set @lom_aggregation = @lom_aggregation + ' | ' + @singlevalue;
		if ( @metadatatype = 122 ) set @lom_context = @lom_context + ' | ' + @singlevalue;
		if ( @metadatatype = 123 ) set @lom_classification = @lom_classification + ' | ' + @singlevalue;
		if ( @metadatatype = 124 ) set @lom_difficulty = @lom_difficulty + ' | ' + @singlevalue;
		if ( @metadatatype = 125 ) set @lom_user = @lom_user + ' | ' + @singlevalue;
		if ( @metadatatype = 126 ) set @lom_interactivity_level = @lom_interactivity_level + ' | ' + @singlevalue;
		if ( @metadatatype = 127 ) set @lom_interactivity_type = @lom_interactivity_type + ' | ' + @singlevalue;
		if ( @metadatatype = 128 ) set @lom_status = @lom_status + ' | ' + @singlevalue;
		if ( @metadatatype = 129 ) set @lom_requirements = @lom_requirements + ' | ' + @singlevalue;
		if ( @metadatatype = 130 ) set @lom_agerange = @lom_agerange + ' | ' + @singlevalue;
		if ( @metadatatype = 131 ) set @etd_degree_division = @etd_degree_division + ' | ' + @singlevalue;
	
		-- Get the next value
		fetch next from metadatacursor into @singlevalue, @metadatatype;

	end;

	-- Close and deallocate the cursor which was used
	close metadatacursor;
	deallocate metadatacursor;
	
	-- Get the sortdate
	declare @sortdate bigint;
	set @sortdate = ( select SortDate from SobekCM_Item where ItemID=@itemid);

	-- Insert the newly created full citation for this item
	insert into SobekCM_Metadata_Basic_Search_Table ( ItemID, FullCitation, Title, [Type], [Language], Creator, Publisher, Publication_Place, Subject_Keyword, Genre, Target_Audience, Spatial_Coverage, Country, [State], County, City, Source_Institution, Holding_Location, Notes, Other_Citation, Tickler, Donor, Format, BibID, Publication_Date, Affiliation, Frequency, Name_as_Subject, Title_as_Subject, All_Subjects, Temporal_Subject, Attribution, User_Description, Temporal_Decade, MIME_Type, Tracking_Box, Abstract, Edition, TOC, ZT_Kingdom, ZT_Phylum, ZT_Class, ZT_Order, ZT_Family, ZT_Genus, ZT_Species, ZT_Common_Name, ZT_Scientific_Name, ZT_All_Taxonomy, Cultural_Context, Inscription, Material, Style_Period, Technique, Accession_Number, Interviewee, Interviewer, Temporal_Year, ETD_Committee, ETD_Degree, ETD_Degree_Discipline, ETD_Degree_Grantor, ETD_Degree_Level, UserDefined01, UserDefined02, UserDefined03, UserDefined04, UserDefined05, UserDefined06, UserDefined07, UserDefined08, UserDefined09, UserDefined10, UserDefined11, UserDefined12, UserDefined13, UserDefined14, UserDefined15, UserDefined16, UserDefined17, UserDefined18, UserDefined19, UserDefined20, UserDefined21, UserDefined22, UserDefined23, UserDefined24, UserDefined25, UserDefined26, UserDefined27, UserDefined28, UserDefined29, UserDefined30, UserDefined31, UserDefined32, UserDefined33, UserDefined34, UserDefined35, UserDefined36, UserDefined37, UserDefined38, UserDefined39, UserDefined40, UserDefined41, UserDefined42, UserDefined43, UserDefined44, UserDefined45, UserDefined46, UserDefined47, UserDefined48, UserDefined49, UserDefined50, UserDefined51, UserDefined52, [Publisher.Display], [Spatial_Coverage.Display], Measurements, [Subjects.Display], Aggregations, LOM_Aggregation, LOM_Context, LOM_Classification, LOM_Difficulty, LOM_Intended_End_User, LOM_Interactivity_Level, LOM_Interactivity_Type, LOM_Status, LOM_Requirement, LOM_AgeRange, ETD_Degree_Division, SortDate )
	values ( @itemid, @fullcitation + ' | ', @title , @type , @language , @creator , @publisher , @publication_place , @subject_keyword , @genre , @target_audience , @spatial_coverage , @country , @state , @county , @city , @source_institution , @holding_location , @notes , @other_citation , @tickler , @donor , @format , @bibid , @publication_date , @affiliation , @frequency , @name_as_subject , @title_as_subject , @all_subjects , @temporal_subject , @attribution , @user_description , @temporal_decade , @mime_type , @tracking_box , @abstract , @edition , @toc , @zt_kingdom , @zt_phylum , @zt_class , @zt_order , @zt_family , @zt_genus , @zt_species , @zt_common_name , @zt_scientific_name , @zt_all_taxonomy , @cultural_context , @inscription , @material , @style_period , @technique , @accession_number, @interviewee, @interviewer, @temporal_year, @etd_committee, @etd_degree, @etd_degree_discipline, @etd_degree_grantor, @etd_degree_level, @userdefined01, @userdefined02, @userdefined03, @userdefined04, @userdefined05, @userdefined06, @userdefined07, @userdefined08, @userdefined09, @userdefined10, @userdefined11, @userdefined12, @userdefined13, @userdefined14, @userdefined15, @userdefined16, @userdefined17, @userdefined18, @userdefined19, @userdefined20, @userdefined21, @userdefined22, @userdefined23, @userdefined24, @userdefined25, @userdefined26, @userdefined27, @userdefined28, @userdefined29, @userdefined30, @userdefined31, @userdefined32, @userdefined33, @userdefined34, @userdefined35, @userdefined36, @userdefined37, @userdefined38, @userdefined39, @userdefined40, @userdefined41, @userdefined42, @userdefined43, @userdefined44, @userdefined45, @userdefined46, @userdefined47, @userdefined48, @userdefined49, @userdefined50, @userdefined51, @userdefined52, @publisher_display, @spatial_display, @measurement, @subject_display, @aggregations, @lom_aggregation, @lom_context, @lom_classification, @lom_difficulty, @lom_user, @lom_interactivity_level, @lom_interactivity_type, @lom_status, @lom_requirements, @lom_agerange, @etd_degree_division, @sortdate );

	-- Compute the overall spatial footprint string and distance
	with ItemPoints as
	(
		select Point_Latitude as Latitude, Point_Longitude as Longitude
		from SobekCM_Item_Footprint
		where ( ItemID=@itemID )
		  and ( Point_Latitude is not null )
		  and ( Point_Longitude is not null )
		union
		select Rect_Latitude_A, Rect_Longitude_A
		from SobekCM_Item_Footprint
		where ( ItemID=@itemID )
		  and ( Rect_Latitude_A is not null )
		  and ( Rect_Longitude_A is not null )
		union
		select Rect_Latitude_B, Rect_Longitude_B
		from SobekCM_Item_Footprint
		where ( ItemID=@itemID )
		  and ( Rect_Latitude_B is not null )
		  and ( Rect_Longitude_B is not null )
	), MinMaxItemPoints as
	(
		select Min(Latitude) as Min_Latitude, 
			   Max(Latitude) as Max_Latitude, 
			   Min(Longitude) as Min_Longitude, 
			   Max(Longitude) as Max_Longitude
		from ItemPoints
	)
	select CASE WHEN Min_Latitude=Max_Latitude and Min_Longitude=Max_Longitude THEN 'P|' + cast(Min_Latitude as varchar(20)) + '|' + cast(Min_Longitude as varchar(20))
				ELSE 'A|' + cast(Min_Latitude as varchar(20)) + '|' + cast(Min_Longitude as varchar(20)) + '|' + cast(Max_Latitude as varchar(20)) + '|' + cast(Max_Longitude as varchar(20))
		   END as SpatialFootprint,
		   Square(Max_Latitude - Min_Latitude ) + Square(Max_Longitude-Min_Longitude) as SpatialFootprintDistance
	into #FinalValues
    from MinMaxItemPoints;

	update SobekCM_Item 
	set SpatialFootprint= coalesce(( select SpatialFootprint from #FinalValues ),''),
	    SpatialFootprintDistance = coalesce(( select SpatialFootprintDistance from #FinalValues ), 999)
	where ItemID=@ItemID;

	drop table #FinalValues;
	
end;
GO



-- Perform metadata search 
ALTER PROCEDURE [dbo].[SobekCM_Metadata_Search_Paged]
	@link1 int,
	@term1 nvarchar(255),
	@field1 int,
	@link2 int,
	@term2 nvarchar(255),
	@field2 int,
	@link3 int,
	@term3 nvarchar(255),
	@field3 int,
	@link4 int,
	@term4 nvarchar(255),
	@field4 int,
	@link5 int,
	@term5 nvarchar(255),
	@field5 int,
	@link6 int,
	@term6 nvarchar(255),
	@field6 int,
	@link7 int,
	@term7 nvarchar(255),
	@field7 int,
	@link8 int,
	@term8 nvarchar(255),
	@field8 int,
	@link9 int,
	@term9 nvarchar(255),
	@field9 int,
	@link10 int,
	@term10 nvarchar(255),
	@field10 int,
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
	
	-- Field#'s indicate which metadata field (if any).  These are numbers from the 
	-- SobekCM_Metadata_Types table.  A field# of -1, means all fields are included.
	
	-- Link#'s indicate if this is an AND-joiner ( intersect ) or an OR-joiner ( union )
	-- 0 = AND, 1 = OR, 2 = AND NOT
	
	-- Examples of using this procedure are:
	-- exec SobekCM_Metadata_Search 'haiti',1,0,'kesse',4,0,'',0
	-- This searches for materials which have haiti in the title AND kesse in the creator
	
	-- exec SobekCM_Metadata_Search 'haiti',1,1,'kesse',-1,0,'',0
	-- This searches for materials which have haiti in the title OR kesse anywhere
	
	-- Create the temporary table variables first
	-- Create the temporary table to hold all the item id's
	create table #TEMPZERO ( ItemID int primary key );
	create table #TEMP_ITEMS ( ItemID int primary key, fk_TitleID int, Hit_Count int, SortDate bigint );
		    
	-- declare both the sql query and the parameter definitions
	declare @SQLQuery AS nvarchar(max);
	declare @rankselection AS nvarchar(1000);
    declare @ParamDefinition AS NVarchar(2000);
		
    -- Determine the aggregationid
	declare @aggregationid int;
	set @aggregationid = coalesce(( select AggregationID from SobekCM_Item_Aggregation where Code=@aggregationcode ), -1);
	
	-- Get the sql which will be used to return the aggregation-specific display values for all the items in this page of results
	declare @item_display_sql nvarchar(max);
	if ( @aggregationid < 0 )
	begin
		select @item_display_sql=coalesce(Browse_Results_Display_SQL, 'select S.ItemID, S.Publication_Date, S.Creator, S.[Publisher.Display], S.Format, S.Edition, S.Material, S.Measurements, S.Style_Period, S.Technique, S.[Subjects.Display], S.Source_Institution, S.Donor from SobekCM_Metadata_Basic_Search_Table S, @itemtable T where S.ItemID = T.ItemID;')
		from SobekCM_Item_Aggregation
		where Code='all';
	end
	else
	begin
		select @item_display_sql=coalesce(Browse_Results_Display_SQL, 'select S.ItemID, S.Publication_Date, S.Creator, S.[Publisher.Display], S.Format, S.Edition, S.Material, S.Measurements, S.Style_Period, S.Technique, S.[Subjects.Display], S.Source_Institution, S.Donor from SobekCM_Metadata_Basic_Search_Table S, @itemtable T where S.ItemID = T.ItemID;')
		from SobekCM_Item_Aggregation
		where AggregationID=@aggregationid;
	end;
	
    -- Set value for filtering privates
	declare @lower_mask int;
	set @lower_mask = 0;
	if ( @include_private = 'true' )
	begin
		set @lower_mask = -256;
	end;
	    
    -- Start to build the main bulk of the query   
	set @SQLQuery = '( I.Dark = ''false'' ) and ( I.Deleted = ''false'' ) and ( I.IP_Restriction_Mask >= ' + cast(@lower_mask as varchar(3)) + ' ) and ';
	
	-- Start with the date range information, if this includes a date range search
	if ( @daterange_end > 0 )
	begin
		set @SQLQuery = @SQLQuery + ' ( L.SortDate > ' + cast(@daterange_start as nvarchar(12)) + ') and ( L.SortDate < ' +  cast(@daterange_end as nvarchar(12)) + ') and ';	
	end;
    
    -- Was a field listed?
    if (( @field1 > 0 ) and ( @field1 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
    begin
		-- Was this an AND, OR, or AND NOT?
		if ( @link1 = 2 ) set @SQLQuery = @SQLQuery + ' not';

		-- Get the name of this column then
		declare @field1_name varchar(100);
		set @field1_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field1 );

		-- Add this search then
		set @SQLQuery = @SQLQuery + ' contains ( L.' + @field1_name + ', @innerterm1 )';
	end
	else
	begin
		-- Search the full citation then
		set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm1 )';	
	end;
            
    -- Start to build the query which will do ranking over the results which match this search
    set @rankselection = @term1;

	-- Add the second term, if there is one
	if (( LEN( ISNULL(@term2,'')) > 0 ) and (( @link2 = 0 ) or ( @link2 = 1 ) or ( @link2 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link2 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link2 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link2 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field2 > 0 ) and ( @field2 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field2_name varchar(100);
			set @field2_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field2 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field2_name + ', @innerterm2 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm2 )';	
		end;			
		
		-- Build the ranking query
		if ( @link2 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term2;	
		end
	end;    
	
	-- Add the third term, if there is one
	if (( LEN( ISNULL(@term3,'')) > 0 ) and (( @link3 = 0 ) or ( @link3 = 1 ) or ( @link3 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link3 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link3 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link3 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field3 > 0 ) and ( @field3 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field3_name varchar(100);
			set @field3_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field3 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field3_name + ', @innerterm3 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm3 )';	
		end;	
		
		-- Build the ranking query
		if ( @link3 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term3;		
		end
	end;   
	
	-- Add the fourth term, if there is one
	if (( LEN( ISNULL(@term4,'')) > 0 ) and (( @link4 = 0 ) or ( @link4 = 1 ) or ( @link4 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link4 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link4 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link4 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field4 > 0 ) and ( @field4 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field4_name varchar(100);
			set @field4_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field4 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field4_name + ', @innerterm4 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm4 )';	
		end;	
			
		-- Build the ranking query
		if ( @link4 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term4;		
		end
	end;
	
	-- Add the fifth term, if there is one
	if (( LEN( ISNULL(@term5,'')) > 0 ) and (( @link5 = 0 ) or ( @link5 = 1 ) or ( @link5 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link5 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link5 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link5 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field5 > 0 ) and ( @field5 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field5_name varchar(100);
			set @field5_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field5 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field5_name + ', @innerterm5 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm5 )';	
		end;
			
		-- Build the ranking query
		if ( @link5 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term5;		
		end
	end;
	
	-- Add the sixth term, if there is one
	if (( LEN( ISNULL(@term6,'')) > 0 ) and (( @link6 = 0 ) or ( @link6 = 1 ) or ( @link6 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link6 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link6 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link6 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field6 > 0 ) and ( @field6 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field6_name varchar(100);
			set @field6_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field6 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field6_name + ', @innerterm6 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm6 )';	
		end;
		
		-- Build the ranking query
		if ( @link6 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term6;		
		end
	end; 
	
	-- Add the seventh term, if there is one
	if (( LEN( ISNULL(@term7,'')) > 0 ) and (( @link7 = 0 ) or ( @link7 = 1 ) or ( @link7 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link7 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link7 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link7 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field7 > 0 ) and ( @field7 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field7_name varchar(100);
			set @field7_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field7 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field7_name + ', @innerterm7 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm7 )';	
		end;
		
		-- Build the ranking query
		if ( @link7 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term7;		
		end
	end;
	
	-- Add the eighth term, if there is one
	if (( LEN( ISNULL(@term8,'')) > 0 ) and (( @link8 = 0 ) or ( @link8 = 1 ) or ( @link8 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link8 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link8 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link8 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field8 > 0 ) and ( @field8 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field8_name varchar(100);
			set @field8_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field8 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field8_name + ', @innerterm8 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm8 )';	
		end;
		
		-- Build the ranking query
		if ( @link8 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term8;		
		end
	end;
	
	-- Add the ninth term, if there is one
	if (( LEN( ISNULL(@term9,'')) > 0 ) and (( @link9 = 0 ) or ( @link9 = 1 ) or ( @link9 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link9 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link9 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link9 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field9 > 0 ) and ( @field9 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field9_name varchar(100);
			set @field9_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field9 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field9_name + ', @innerterm9 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm9 )';	
		end;
		
		-- Build the ranking query
		if ( @link9 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term9;		
		end
	end;
	
	-- Add the tenth term, if there is one
	if (( LEN( ISNULL(@term10,'')) > 0 ) and (( @link10 = 0 ) or ( @link10 = 1 ) or ( @link10 = 2 )))
	begin	
		-- Was this an AND, OR, or AND NOT?
		if ( @link10 = 0 ) set @SQLQuery = @SQLQuery + ' and';
		if ( @link10 = 1 ) set @SQLQuery = @SQLQuery + ' or';
		if ( @link10 = 2 ) set @SQLQuery = @SQLQuery + ' and not';
		
		-- Was a field listed?
		if (( @field10 > 0 ) and ( @field10 in ( select MetadataTypeID from SobekCM_Metadata_Types )))
		begin
			-- Get the name of this column then
			declare @field10_name varchar(100);
			set @field10_name = ( select REPLACE(MetadataName, ' ', '_') from SobekCM_Metadata_Types where MetadataTypeID = @field10 );

			-- Add this search then
			set @SQLQuery = @SQLQuery + ' contains ( L.' + @field10_name + ', @innerterm10 )';
		end
		else
		begin
			-- Search the full citation then
			set @SQLQuery = @SQLQuery + ' contains ( L.FullCitation, @innerterm10 )';	
		end;
		
		-- Build the ranking query
		if ( @link10 != 2 )
		begin
			set @rankselection = @rankselection + ' or ' + @term10;		
		end		
	end;
	
	-- Add the recompile option
	--set @SQLQuery = @SQLQuery + ' option (RECOMPILE)';

    -- Add the first term and start to build the query which will provide the items which match the search
    declare @mainquery nvarchar(max);
    set @mainquery = 'select L.Itemid from SobekCM_Metadata_Basic_Search_Table as L join SobekCM_Item as I on ( I.itemID = L.ItemID ) ';
    
    -- Do we need to limit by aggregation id as well?
    if ( @aggregationid > 0 )
    begin
		set @mainquery = @mainquery + ' join SobekCM_Item_Aggregation_Item_Link AS A ON ( A.ItemID = L.ItemID ) and ( A.AggregationID = ' + CAST( @aggregationid as varchar(5) ) + ')';   
    end    
    
    -- Add the full text search portion here
    set @mainquery = @mainquery + ' where ' + @SQLQuery;
	
	-- Set the parameter definition
	set @ParamDefinition = ' @innerterm1 nvarchar(255), @innerterm2 nvarchar(255), @innerterm3 nvarchar(255), @innerterm4 nvarchar(255), @innerterm5 nvarchar(255), @innerterm6 nvarchar(255), @innerterm7 nvarchar(255), @innerterm8 nvarchar(255), @innerterm9 nvarchar(255), @innerterm10 nvarchar(255)';
		
	-- Execute this stored procedure
	insert #TEMPZERO execute sp_Executesql @mainquery, @ParamDefinition, @term1, @term2, @term3, @term4, @term5, @term6, @term7, @term8, @term9, @term10;

	-- DEBUG
	--declare @tempzero_count int;
	--set @tempzero_count = (select count(*) from #TEMPZERO );
	--print '-- #TEMPZERO count = ' + cast(@tempzero_count as varchar(10));
			
	-- Perform ranking against the items and insert into another temporary table 
	-- with all the possible data elements needed for applying the user's sort
	insert into #TEMP_ITEMS ( ItemID, fk_TitleID, SortDate, Hit_Count )
	select I.ItemID, I.GroupID, SortDate=isnull( I.SortDate,-1), isnull(KEY_TBL.RANK, 0 )
	from #TEMPZERO AS T1 inner join
		 SobekCM_Item as I on T1.ItemID=I.ItemID left outer join
		 CONTAINSTABLE(SobekCM_Metadata_Basic_Search_Table, FullCitation, @rankselection ) AS KEY_TBL on KEY_TBL.[KEY] = T1.ItemID
	where ( I.Deleted = 'false' )
      and ( I.IP_Restriction_Mask >= @lower_mask )	
      and ( I.IncludeInAll = 'true' );

	-- DEBUG
	-- print '-- @rankselection = ' + @rankselection;
	-- select * from #TEMP_ITEMS;
	-- declare @tempitems_count int;
	-- set @tempitems_count = ( select count(*) from #TEMP_ITEMS);
	-- print '-- ##TEMP_ITEMS count = ' + cast(@tempitems_count as varchar(10));

	-- Determine the start and end rows
	declare @rowstart int;
	declare @rowend int;
	set @rowstart = (@pagesize * ( @pagenumber - 1 )) + 1;
	set @rowend = @rowstart + @pagesize - 1; 
	
	-- If there were no results at all, check the count in the entire library
	if ( ( select COUNT(*) from #TEMP_ITEMS ) = 0 )
	begin
		-- Set the items and titles correctly
		set @total_items = 0;
		set @total_titles = 0;
		
		-- If there was an aggregation id, just return the counts for the whole library
		if ( @aggregationid > 0 )	
		begin
		
			-- Truncate the table and repull the data
			truncate table #TEMPZERO;
			
			-- Query against ALL aggregations this time
			declare @allquery nvarchar(max);
			set @allquery = 'select L.Itemid from SobekCM_Metadata_Basic_Search_Table AS L where ' + @SQLQuery;
			
			-- Execute this stored procedure
			insert #TEMPZERO execute sp_Executesql @allquery, @ParamDefinition, @term1, @term2, @term3, @term4, @term5, @term6, @term7, @term8, @term9, @term10;
			
			-- Get all items in the entire library then		  
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID )
			select I.ItemID, I.GroupID
			from #TEMPZERO T1, SobekCM_Item I
			where ( T1.ItemID = I.ItemID )
			  and ( I.Deleted = 'false' )
			  and ( I.IP_Restriction_Mask >= @lower_mask )	
			  and ( I.IncludeInAll = 'true' );  
			  
			-- Return these counts
			select @all_collections_items=COUNT(*), @all_collections_titles=COUNT(distinct fk_TitleID)
			from #TEMP_ITEMS;
		end;
		
		-- Drop the big temporary table
		drop table #TEMPZERO;
	
	end
	else
	begin	
	
		-- Drop the big temporary table
		drop table #TEMPZERO;	
		
		-- Create the temporary item table variable for paging purposes
		declare @TEMP_PAGED_ITEMS TempPagedItemsTableType;
		  
		-- There are essentially two major paths of execution, depending on whether this should
		-- be grouped as items within the page requested titles ( sorting by title or the basic
		-- sorting by rank, which ranks this way ) or whether each item should be
		-- returned by itself, such as sorting by individual publication dates, etc..
		
		if ( @sort < 10 )
		begin	
			-- create the temporary title table definition
			declare @TEMP_TITLES table ( TitleID int, BibID varchar(10), RowNumber int );	
			
			-- Return these counts
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
			select RowNumber as TitleID, T.BibID, G.GroupTitle, G.ALEPH_Number as OPAC_Number, G.OCLC_Number, isnull(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], isnull(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, isnull(G.Primary_Identifier, '') as Primary_Identifier
			from @TEMP_TITLES T, SobekCM_Item_Group G
			where ( T.TitleID = G.GroupID )
			order by RowNumber ASC;
			
			-- Get the item id's for the items related to these titles
			insert into @TEMP_PAGED_ITEMS
			select ItemID, RowNumber
			from @TEMP_TITLES T, SobekCM_Item I
			where ( T.TitleID = I.GroupID );			  
			
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
					ROW_NUMBER() OVER (order by case when @sort=10 THEN isnull(SortDate,9223372036854775807)  end ASC,
												case when @sort=11 THEN isnull(SortDate,-1) end DESC) as RowNumber
					from #TEMP_ITEMS I
					group by I.ItemID, SortDate )
						  
			-- Insert the correct rows into the temp item table	
			insert into @TEMP_PAGED_ITEMS ( ItemID, RowNumber )
			select ItemID, RowNumber
			from ITEMS_SELECT
			where RowNumber >= @rowstart
			  and RowNumber <= @rowend;
			  
			-- Return the title information for this page
			select RowNumber as TitleID, G.BibID, G.GroupTitle, G.ALEPH_Number as OPAC_Number, G.OCLC_Number, isnull(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], isnull(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, isnull(G.Primary_Identifier, '') as Primary_Identifier
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

		end;

		-- Return the facets if asked for
		if ( @include_facets = 'true' )
		begin	
			if (( LEN( isnull( @aggregationcode, '')) = 0 ) or ( @aggregationcode = 'all' ))
			begin
				-- Build the aggregation list
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
	
	-- return the query string as well, for debuggins
	select Query = @mainquery;
	select RankSelection = @rankselection;
	
	-- drop the temporary tables
	drop table #TEMP_ITEMS;
	
	Set NoCount OFF;
			
	If @@ERROR <> 0 GoTo ErrorHandler;
    Return(0);
  
ErrorHandler:
    Return(@@ERROR);
	
END;
GO


-- Perform an EXACT match type of search against one field of metadata
ALTER PROCEDURE [dbo].[SobekCM_Metadata_Exact_Search_Paged2] 
	@term1 nvarchar(512),
	@field1 int,
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

	-- Create the temporary table variable first
	-- Create the temporary table variable to hold all the item id's
	create table #TEMP_ITEMS ( ItemID int primary key, fk_TitleID int, Hit_Count int, SortDate bigint );

	-- Determine the start and end rows
	declare @rowstart int;
	declare @rowend int; 
	set @rowstart = (@pagesize * ( @pagenumber - 1 )) + 1;
	set @rowend = @rowstart + @pagesize - 1; 

	-- Set value for filtering privates
	declare @lower_mask int;
	set @lower_mask = 0;
	if ( @include_private = 'true' )
	begin
		set @lower_mask = -256;
	end;

	-- Determine the aggregationid
	declare @aggregationid int;
	set @aggregationid = coalesce(( select AggregationID from SobekCM_Item_Aggregation where Code=@aggregationcode ), -1);
	
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
	
	-- Determine the first 100 of the search term
	declare @term_start nvarchar(100);
	set @term_start = SUBSTRING(@term1, 1, 100);
	
	-- Perform the actual metadata search differently, depending on whether an aggregation was 
	-- included to limit this search
	if (( @daterange_end < 0 ) and ( @daterange_start < 0 ))
	begin
		if ( @aggregationid > 0 )
		begin 
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, SortDate )
			select I.ItemID, I.GroupID, SortDate=isnull( I.SortDate,-1)
			from SobekCM_Item AS I inner join
				 SobekCM_Item_Aggregation_Item_Link AS CL ON CL.ItemID = I.ItemID inner join
				 SobekCM_Metadata_Unique_Link ML on ML.ItemID = I.ItemID inner join
				 SobekCM_Metadata_Unique_Search_Table M ON M.MetadataID = ML.MetadataID and MetadataTypeID = @field1 and M.MetadataValueStart = @term_start and M.MetadataValue = @term1
			where ( I.Deleted = 'false' )
			  and ( CL.AggregationID = @aggregationid )
			  and ( I.IP_Restriction_Mask >= @lower_mask )
			  and ( I.Dark = 'false' );
		end
		else
		begin	
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, SortDate )
			select I.ItemID, I.GroupID, SortDate=isnull( I.SortDate,-1)
			from SobekCM_Item AS I inner join
				 SobekCM_Metadata_Unique_Link ML on ML.ItemID = I.ItemID inner join
				 SobekCM_Metadata_Unique_Search_Table M ON M.MetadataID = ML.MetadataID and MetadataTypeID = @field1 and M.MetadataValueStart = @term_start and M.MetadataValue = @term1
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
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, SortDate )
			select I.ItemID, I.GroupID, SortDate=isnull( I.SortDate,-1)
			from SobekCM_Item AS I inner join
				 SobekCM_Item_Aggregation_Item_Link AS CL ON CL.ItemID = I.ItemID inner join
				 SobekCM_Metadata_Unique_Link ML on ML.ItemID = I.ItemID inner join
				 SobekCM_Metadata_Unique_Search_Table M ON M.MetadataID = ML.MetadataID and MetadataTypeID = @field1 and M.MetadataValueStart = @term_start and M.MetadataValue = @term1
			where ( I.Deleted = 'false' )
			  and ( CL.AggregationID = @aggregationid )
			  and ( I.IP_Restriction_Mask >= @lower_mask )
			  and ( I.Dark = 'false' )			  
			  and ( I.SortDate >= @daterange_start )
			  and ( I.SortDate <= @daterange_end );
		end
		else
		begin	
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, SortDate )
			select I.ItemID, I.GroupID, SortDate=isnull( I.SortDate,-1)
			from SobekCM_Item AS I inner join
				 SobekCM_Metadata_Unique_Link ML on ML.ItemID = I.ItemID inner join
				 SobekCM_Metadata_Unique_Search_Table M ON M.MetadataID = ML.MetadataID and MetadataTypeID = @field1 and M.MetadataValueStart = @term_start and M.MetadataValue = @term1
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
			insert into #TEMP_ITEMS ( ItemID, fk_TitleID, SortDate )
			select I.ItemID, I.GroupID, SortDate=isnull( I.SortDate,-1)
			from SobekCM_Item AS I inner join
				 SobekCM_Metadata_Unique_Link ML on ML.ItemID = I.ItemID inner join
				 SobekCM_Metadata_Unique_Search_Table M ON M.MetadataID = ML.MetadataID and MetadataTypeID = @field1 and M.MetadataValueStart = @term_start and M.MetadataValue = @term1
			where ( I.Deleted = 'false' )
			  and ( I.IP_Restriction_Mask >= @lower_mask )	
			  and ( I.IncludeInAll = 'true' );	 
			  
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
					  
			-- Create saved select across titles for row numbers for selecting correct page(s) of results
			with TITLES_SELECT AS
				(	select GroupID, G.BibID, 
						ROW_NUMBER() OVER (order by case when @sort=0 THEN G.SortTitle end ASC,	
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
			
			-- Return the title information for this page of results
			select RowNumber as TitleID, T.BibID, G.GroupTitle, G.ALEPH_Number as OPAC_Number, G.OCLC_Number, isnull(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], isnull(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, isnull(G.Primary_Identifier, '') as Primary_Identifier
			from @TEMP_TITLES T, SobekCM_Item_Group G
			where ( T.TitleID = G.GroupID )
			order by RowNumber ASC;
			
			-- Get the item id's for the items related to these titles
			insert into @TEMP_PAGED_ITEMS
			select ItemID, RowNumber
			from @TEMP_TITLES T, SobekCM_Item I
			where ( T.TitleID = I.GroupID );			  
			
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
					ROW_NUMBER() OVER (order by case when @sort=10 THEN isnull(SortDate,9223372036854775807)  end ASC,
												case when @sort=11 THEN isnull(SortDate,-1) end DESC) as RowNumber
					from #TEMP_ITEMS I
					group by I.ItemID, SortDate )
						  
			-- Insert the correct rows into the temp item table	
			insert into @TEMP_PAGED_ITEMS ( ItemID, RowNumber )
			select ItemID, RowNumber
			from ITEMS_SELECT
			where RowNumber >= @rowstart
			  and RowNumber <= @rowend;
			  
			-- Return the title information for this page
			select RowNumber as TitleID, G.BibID, G.GroupTitle, G.ALEPH_Number as OPAC_Number, G.OCLC_Number, isnull(G.GroupThumbnail,'') as GroupThumbnail, G.[Type], isnull(G.Primary_Identifier_Type,'') as Primary_Identifier_Type, isnull(G.Primary_Identifier, '') as Primary_Identifier
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
			end
			
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
			
    Set NoCount OFF;	
END;
GO

ALTER PROCEDURE [dbo].[SobekCM_Item_Count_By_Collection]
	@option int
AS
BEGIN

	-- No need to perform any locks here, especially given the possible
	-- length of this search
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	
	-- Get the id for the ALL aggregation
	declare @all_id int;
	set @all_id = coalesce(( select AggregationID from SObekCM_Item_Aggregation where Code='all'), -1);
	
	declare @Aggregation_List TABLE
	(
	  AggregationID int,
	  Code varchar(20),
	  ChildCode varchar(20),
	  Child2Code varchar(20),
	  AllCodes varchar(20),
	  Name nvarchar(255),
	  ShortName nvarchar(100),
	  [Type] varchar(50),
	  isActive bit
	);

	-- Insert the list of items linked to ALL or linked to NONE (include ALL)
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select AggregationID, Code, '', '', Code, Name, ShortName, [Type], isActive
	from SobekCM_Item_Aggregation A
	where ( [Type] not like 'Institut%' )
	  and ( Deleted='false' )
	  and exists ( select * from SobekCM_Item_Aggregation_Hierarchy where ChildID=A.AggregationID and ParentID=@all_id);
	  
	-- Insert the children under those top-level collections
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select A2.AggregationID, T.Code, A2.Code, '', A2.Code, A2.Name, A2.SHortName, A2.[Type], A2.isActive
	from @Aggregation_List T, SobekCM_Item_Aggregation A2, SobekCM_Item_Aggregation_Hierarchy H
	where ( A2.[Type] not like 'Institut%' )
	  and ( T.AggregationID = H.ParentID )
	  and ( A2.AggregationID = H.ChildID )
	  and ( Deleted='false' );
	  
	-- Insert the grand-children under those child collections
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select A2.AggregationID, T.Code, T.ChildCode, A2.Code, A2.Code, A2.Name, A2.SHortName, A2.[Type], A2.isActive
	from @Aggregation_List T, SobekCM_Item_Aggregation A2, SobekCM_Item_Aggregation_Hierarchy H
	where ( A2.[Type] not like 'Institut%' )
	  and ( T.AggregationID = H.ParentID )
	  and ( A2.AggregationID = H.ChildID )
	  and ( Deleted='false' )
	  and ( ChildCode <> '' );

	-- declare the values
	declare @total_item_count int;
	declare @total_title_count int;
	declare @total_page_count int;

	-- Based on the option, select differently
	if ( @option = 1 )
	begin
		  
		-- COUNT OF ALL ITEMS WITH SOME DIGITAL RESOURCES ATTACHED
		-- Get total counts
		select @total_item_count =  ( select count(*) from SobekCM_Item where Deleted = 'false' and (( FileCount > 0 ) or ( [PageCount] > 0 )));
		select @total_title_count =  ( select count(*) from SobekCM_Item_Group G where G.Deleted = 'false' and exists ( select * from SobekCM_Item I where I.GroupID = G.GroupID and I.Deleted = 'false' and (( FileCount > 0 ) or ( [PageCount] > 0 ))));
		select @total_page_count =  coalesce(( select sum( [PageCount] ) from SobekCM_Item where Deleted = 'false'  and (( FileCount > 0 ) or ( [PageCount] > 0 ))), 0 );

		-- Start to build the return set of values
		select code1 = Code, 
			   code2 = ChildCode,
			   code3 = Child2Code,
			   AllCodes,
			[Name], 
			C.isActive AS Active,
			title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ),
			item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ), 
			page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ), 0)
		from @Aggregation_List C
		where ( C.Code <> 'TESTCOL' ) AND ( C.Code <> 'TESTG' )
		union
		select 'ZZZ','','', 'ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count
		order by code, code2, code3;
	end
	else if ( @option = 2 )
	begin  

		-- COUNT OF ALL ENTERED ITEMS
		-- Get total counts
		select @total_item_count =  ( select count(*) from SobekCM_Item where Deleted = 'false');
		select @total_title_count =  ( select count(*) from SobekCM_Item_Group G where G.Deleted = 'false');
		select @total_page_count =  coalesce(( select sum( [PageCount] ) from SobekCM_Item ), 0 );

		-- Start to build the return set of values
		select code1 = Code, 
			   code2 = ChildCode,
			   code3 = Child2Code,
			   AllCodes,
			[Name], 
			C.isActive AS Active,
			title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ),
			item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ), 
			page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ), 0)
		from @Aggregation_List C
		where ( C.Code <> 'TESTCOL' ) AND ( C.Code <> 'TESTG' )
		union
		select 'ZZZ','','', 'ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count
		order by code, code2, code3;
	end
	else
	begin
			  
		-- THIS IS THE OLDER OPTION, WHERE MILESTONE_COMPLETE MUST HAVE A DATE
		-- Get total counts
		select @total_item_count =  ( select count(*) from SobekCM_Item where Deleted = 'false' and Milestone_OnlineComplete is not null );
		select @total_title_count =  ( select count(*) from SobekCM_Item_Group G where G.Deleted = 'false' and exists ( select * from SobekCM_Item I where I.GroupID = G.GroupID and I.Deleted = 'false' and Milestone_OnlineComplete is not null ));
		select @total_page_count =  coalesce(( select sum( [PageCount] ) from SobekCM_Item where Deleted = 'false'  and ( Milestone_OnlineComplete is not null )), 0 );

		-- Start to build the return set of values
		select code1 = Code, 
			   code2 = ChildCode,
			   code3 = Child2Code,
			   AllCodes,
			[Name], 
			C.isActive AS Active,
			title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ),
			item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 
			page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 0)
		from @Aggregation_List C
		where ( C.Code <> 'TESTCOL' ) AND ( C.Code <> 'TESTG' )
		union
		select 'ZZZ','','', 'ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count
		order by code, code2, code3;
	end;
END;
GO

ALTER PROCEDURE [dbo].[SobekCM_Item_Count_By_Collection_By_Date_Range]
	@date1 datetime,
	@date2 datetime,
	@option int
AS
BEGIN

	-- No need to perform any locks here, especially given the possible
	-- length of this search
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	SET ARITHABORT ON;

	-- Get the id for the ALL aggregation
	declare @all_id int;
	set @all_id = coalesce(( select AggregationID from SObekCM_Item_Aggregation where Code='all'), -1);
	
	declare @Aggregation_List TABLE
	(
	  AggregationID int,
	  Code varchar(20),
	  ChildCode varchar(20),
	  Child2Code varchar(20),
	  AllCodes varchar(20),
	  Name nvarchar(255),
	  ShortName nvarchar(100),
	  [Type] varchar(50),
	  isActive bit
	);
	
	-- Insert the list of items linked to ALL or linked to NONE (include ALL)
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select AggregationID, Code, '', '', Code, Name, ShortName, [Type], isActive
	from SobekCM_Item_Aggregation A
	where ( [Type] not like 'Institut%' )
	  and ( Deleted='false' )
	  and exists ( select * from SobekCM_Item_Aggregation_Hierarchy where ChildID=A.AggregationID and ParentID=@all_id);
	  
	-- Insert the children under those top-level collections
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select A2.AggregationID, T.Code, A2.Code, '', A2.Code, A2.Name, A2.SHortName, A2.[Type], A2.isActive
	from @Aggregation_List T, SobekCM_Item_Aggregation A2, SobekCM_Item_Aggregation_Hierarchy H
	where ( A2.[Type] not like 'Institut%' )
	  and ( T.AggregationID = H.ParentID )
	  and ( A2.AggregationID = H.ChildID )
	  and ( Deleted='false' );
	  
	-- Insert the grand-children under those child collections
	insert into @Aggregation_List ( AggregationID, Code, ChildCode, Child2Code, AllCodes, Name, ShortName, [Type], isActive )
	select A2.AggregationID, T.Code, T.ChildCode, A2.Code, A2.Code, A2.Name, A2.SHortName, A2.[Type], A2.isActive
	from @Aggregation_List T, SobekCM_Item_Aggregation A2, SobekCM_Item_Aggregation_Hierarchy H
	where ( A2.[Type] not like 'Institut%' )
	  and ( T.AggregationID = H.ParentID )
	  and ( A2.AggregationID = H.ChildID )
	  and ( Deleted='false' )
	  and ( ChildCode <> '' );

	-- Prepare to collect the total counts
	declare @total_item_count int;
	declare @total_title_count int;
	declare @total_page_count int;
	declare @total_item_count_date1 int;
	declare @total_title_count_date1 int;
	declare @total_page_count_date1 int;
	declare @total_item_count_date2 int;
	declare @total_title_count_date2 int;
	declare @total_page_count_date2 int;

		-- Based on the option, select differently
	if ( @option = 1 )
	begin
		  
		-- COUNT OF ALL ITEMS WITH SOME DIGITAL RESOURCES ATTACHED
		-- Get total item count	
		select @total_item_count =  ( select count(*) from SobekCM_Item where Deleted = 'false' and (( FileCount > 0 ) or ( [PageCount] > 0 )));

		-- Get total title count	
		select @total_title_count = ( select count(G.GroupID)
										from SobekCM_Item_Group G
										where exists ( select ItemID
														from SobekCM_Item I
														where ( I.Deleted = 'false' )
														and (( FileCount > 0 ) or ( [PageCount] > 0 ))
														and ( I.GroupID = G.GroupID )));
		-- Get total title count	
		select @total_page_count =  coalesce(( select sum( [PageCount] ) from SobekCM_Item where Deleted = 'false'  and (( FileCount > 0 ) or ( [PageCount] > 0 ))), 0 );

		-- Get total item count	
		select @total_item_count_date1 =  ( select count(ItemID) 
											from SobekCM_Item I
											where ( I.Deleted = 'false' )
											  and (( FileCount > 0 ) or ( [PageCount] > 0 ))
											  and ( CreateDate is not null )
											  and ( CreateDate <= @date1 ));

		-- Get total title count	
		select @total_title_count_date1 =  ( select count(G.GroupID)
												from SobekCM_Item_Group G
												where exists ( select *
															from SobekCM_Item I
															where ( I.Deleted = 'false' )
																and (( FileCount > 0 ) or ( [PageCount] > 0 ))
																and ( CreateDate is not null )
																and ( CreateDate <= @date1 )
																and ( I.GroupID = G.GroupID )));


		-- Get total title count	
		select @total_page_count_date1 =  ( select sum( coalesce([PageCount],0) ) 
											from SobekCM_Item I
											where ( I.Deleted = 'false' )
												and (( FileCount > 0 ) or ( [PageCount] > 0 ))
												and ( CreateDate is not null )
												and ( CreateDate <= @date1 ));

		-- Return these values if this has just one date
		if ( isnull( @date2, '1/1/2000' ) = '1/1/2000' )
		begin
	
			-- Start to build the return set of values
			select code1 = Code, 
					code2 = ChildCode,
					code3 = Child2Code,
					AllCodes,
				[Name], 
				C.isActive AS Active,
				title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ),
				item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ), 
				page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ), 0),
				title_count_date1 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )),
				item_count_date1 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )),
				page_count_date1 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )), 0)
			from @Aggregation_List C
			union
			select 'ZZZ','','', 'ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count, 
				coalesce(@total_title_count_date1,0), coalesce(@total_item_count_date1,0), coalesce(@total_page_count_date1,0)
			order by code, code2, code3;
		
		end
		else
		begin

			-- Get total item count		
			select @total_item_count_date2 =  ( select count(ItemID) 
												from SobekCM_Item I
												where ( I.Deleted = 'false' )
													and (( FileCount > 0 ) or ( [PageCount] > 0 ))
													and ( CreateDate <= @date2 ));

			-- Get total title count		
			select @total_title_count_date2 =  ( select count(G.GroupID)
													from SobekCM_Item_Group G
													where exists ( select *
																from SobekCM_Item I
																where ( I.Deleted = 'false' )
																	and (( FileCount > 0 ) or ( [PageCount] > 0 ))
																	and ( CreateDate <= @date2 ) 
																	and ( I.GroupID = G.GroupID )));


			-- Get total title count		
			select @total_page_count_date2 =  ( select sum( coalesce([PageCount],0) ) 
												from SobekCM_Item I
												where ( I.Deleted = 'false' )
													and (( FileCount > 0 ) or ( [PageCount] > 0 ))
													and ( CreateDate <= @date2 ));


			-- Start to build the return set of values
			select code1 = Code, 
					code2 = ChildCode,
					code3 = Child2Code,
					AllCodes,
				[Name], 
				C.isActive AS Active,
				title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ),
				item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ), 
				page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID ), 0),
				title_count_date1 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )),
				item_count_date1 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )), 
				page_count_date1 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )), 0),
				title_count_date2 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date2 )),
				item_count_date2 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date2 )), 
				page_count_date2 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View2 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date2 )), 0)
			from @Aggregation_List C
			union
			select 'ZZZ','','','ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count, 
					coalesce(@total_title_count_date1,0), coalesce(@total_item_count_date1,0), coalesce(@total_page_count_date1,0),
					coalesce(@total_title_count_date2,0), coalesce(@total_item_count_date2,0), coalesce(@total_page_count_date2,0)
			order by code, code2, code3;
		end;

	end
	else if ( @option = 2 )
	begin
		-- COUNT OF ALL ENTERED ITEMS
						-- Get total item count	
		select @total_item_count =  ( select count(*) from SobekCM_Item where Deleted = 'false' and (( FileCount > 0 ) or ( [PageCount] > 0 )));

		-- Get total title count	
		select @total_title_count = ( select count(G.GroupID)
										from SobekCM_Item_Group G
										where exists ( select ItemID
														from SobekCM_Item I
														where ( I.Deleted = 'false' )
														and ( I.GroupID = G.GroupID )));
		-- Get total title count	
		select @total_page_count =  coalesce(( select sum( [PageCount] ) from SobekCM_Item where Deleted = 'false'), 0 );

		-- Get total item count	
		select @total_item_count_date1 =  ( select count(ItemID) 
											from SobekCM_Item I
											where ( I.Deleted = 'false' )
											  and ( CreateDate is not null )
											  and ( CreateDate <= @date1 ));

		-- Get total title count	
		select @total_title_count_date1 =  ( select count(G.GroupID)
												from SobekCM_Item_Group G
												where exists ( select *
															from SobekCM_Item I
															where ( I.Deleted = 'false' )
																and ( CreateDate is not null )
																and ( CreateDate <= @date1 )
																and ( I.GroupID = G.GroupID )));


		-- Get total title count	
		select @total_page_count_date1 =  ( select sum( coalesce([PageCount],0) ) 
											from SobekCM_Item I
											where ( I.Deleted = 'false' )
												and ( CreateDate is not null )
												and ( CreateDate <= @date1 ));

		-- Return these values if this has just one date
		if ( isnull( @date2, '1/1/2000' ) = '1/1/2000' )
		begin
	
			-- Start to build the return set of values
			select code1 = Code, 
					code2 = ChildCode,
					code3 = Child2Code,
					AllCodes,
				[Name], 
				C.isActive AS Active,
				title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ),
				item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ), 
				page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ), 0),
				title_count_date1 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )),
				item_count_date1 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )),
				page_count_date1 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )), 0)
			from @Aggregation_List C
			union
			select 'ZZZ','','', 'ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count, 
				coalesce(@total_title_count_date1,0), coalesce(@total_item_count_date1,0), coalesce(@total_page_count_date1,0)
			order by code, code2, code3;
		
		end
		else
		begin

			-- Get total item count		
			select @total_item_count_date2 =  ( select count(ItemID) 
												from SobekCM_Item I
												where ( I.Deleted = 'false' )
													and ( CreateDate <= @date2 ));

			-- Get total title count		
			select @total_title_count_date2 =  ( select count(G.GroupID)
													from SobekCM_Item_Group G
													where exists ( select *
																from SobekCM_Item I
																where ( I.Deleted = 'false' )
																	and ( CreateDate <= @date2 ) 
																	and ( I.GroupID = G.GroupID )));


			-- Get total title count		
			select @total_page_count_date2 =  ( select sum( coalesce([PageCount],0) ) 
												from SobekCM_Item I
												where ( I.Deleted = 'false' )
													and ( CreateDate <= @date2 ));


			-- Start to build the return set of values
			select code1 = Code, 
					code2 = ChildCode,
					code3 = Child2Code,
					AllCodes,
				[Name], 
				C.isActive AS Active,
				title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ),
				item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ), 
				page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID ), 0),
				title_count_date1 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )),
				item_count_date1 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )), 
				page_count_date1 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date1 )), 0),
				title_count_date2 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date2 )),
				item_count_date2 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date2 )), 
				page_count_date2 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View3 T where T.AggregationID = C.AggregationID and ( CreateDate is not null ) and ( CreateDate <= @date2 )), 0)
			from @Aggregation_List C
			union
			select 'ZZZ','','','ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count, 
					coalesce(@total_title_count_date1,0), coalesce(@total_item_count_date1,0), coalesce(@total_page_count_date1,0),
					coalesce(@total_title_count_date2,0), coalesce(@total_item_count_date2,0), coalesce(@total_page_count_date2,0)
			order by code, code2, code3;
		end;
	end
	else 
	begin

		-- THIS IS THE OLDER OPTION, WHERE MILESTONE_COMPLETE MUST HAVE A DATE

		-- Get total item count	
		select @total_item_count =  ( select count(*) from SobekCM_Item where Deleted = 'false' and Milestone_OnlineComplete is not null );

		-- Get total title count	
		select @total_title_count = ( select count(G.GroupID)
										from SobekCM_Item_Group G
										where exists ( select ItemID
														from SobekCM_Item I
														where ( I.Deleted = 'false' )
														and ( Milestone_OnlineComplete is not null )
														and ( I.GroupID = G.GroupID )));
		-- Get total title count	
		select @total_page_count =  coalesce(( select sum( [PageCount] ) from SobekCM_Item where Deleted = 'false'  and ( Milestone_OnlineComplete is not null )), 0 );

		-- Get total item count	
		select @total_item_count_date1 =  ( select count(ItemID) 
											from SobekCM_Item I
											where ( I.Deleted = 'false' )
												and ( Milestone_OnlineComplete is not null )
												and ( Milestone_OnlineComplete <= @date1 ));

		-- Get total title count	
		select @total_title_count_date1 =  ( select count(G.GroupID)
												from SobekCM_Item_Group G
												where exists ( select *
															from SobekCM_Item I
															where ( I.Deleted = 'false' )
																and ( Milestone_OnlineComplete is not null )
																and ( Milestone_OnlineComplete <= @date1 ) 
																and ( I.GroupID = G.GroupID )));


		-- Get total title count	
		select @total_page_count_date1 =  ( select sum( coalesce([PageCount],0) ) 
											from SobekCM_Item I
											where ( I.Deleted = 'false' )
												and ( Milestone_OnlineComplete is not null )
												and ( Milestone_OnlineComplete <= @date1 ));

		-- Return these values if this has just one date
		if ( isnull( @date2, '1/1/2000' ) = '1/1/2000' )
		begin
	
			-- Start to build the return set of values
			select code1 = Code, 
					code2 = ChildCode,
					code3 = Child2Code,
					AllCodes,
				[Name], 
				C.isActive AS Active,
				title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ),
				item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 
				page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 0),
				title_count_date1 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1),
				item_count_date1 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1 ), 
				page_count_date1 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1 ), 0)
			from @Aggregation_List C
			union
			select 'ZZZ','','', 'ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count, 
				coalesce(@total_title_count_date1,0), coalesce(@total_item_count_date1,0), coalesce(@total_page_count_date1,0)
			order by code, code2, code3;
		
		end
		else
		begin

			-- Get total item count		
			select @total_item_count_date2 =  ( select count(ItemID) 
												from SobekCM_Item I
												where ( I.Deleted = 'false' )
													and ( Milestone_OnlineComplete is not null )
													and ( Milestone_OnlineComplete <= @date2 ));

			-- Get total title count		
			select @total_title_count_date2 =  ( select count(G.GroupID)
													from SobekCM_Item_Group G
													where exists ( select *
																from SobekCM_Item I
																where ( I.Deleted = 'false' )
																	and ( Milestone_OnlineComplete is not null )
																	and ( Milestone_OnlineComplete <= @date2 ) 
																	and ( I.GroupID = G.GroupID )));


			-- Get total title count		
			select @total_page_count_date2 =  ( select sum( coalesce([PageCount],0) ) 
												from SobekCM_Item I
												where ( I.Deleted = 'false' )
													and ( Milestone_OnlineComplete is not null )
													and ( Milestone_OnlineComplete <= @date2 ));


			-- Start to build the return set of values
			select code1 = Code, 
					code2 = ChildCode,
					code3 = Child2Code,
					AllCodes,
				[Name], 
				C.isActive AS Active,
				title_count = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ),
				item_count = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 
				page_count = coalesce(( select sum( PageCount ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID ), 0),
				title_count_date1 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1),
				item_count_date1 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1 ), 
				page_count_date1 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date1 ), 0),
				title_count_date2 = ( select count(distinct(GroupID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date2),
				item_count_date2 = ( select count(distinct(ItemID)) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date2 ), 
				page_count_date2 = coalesce(( select sum( [PageCount] ) from Statistics_Item_Aggregation_Link_View T where T.AggregationID = C.AggregationID and Milestone_OnlineComplete is not null and Milestone_OnlineComplete <= @date2 ), 0)
			from @Aggregation_List C
			union
			select 'ZZZ','','','ZZZ', 'Total Count', 'false', @total_title_count, @total_item_count, @total_page_count, 
					coalesce(@total_title_count_date1,0), coalesce(@total_item_count_date1,0), coalesce(@total_page_count_date1,0),
					coalesce(@total_title_count_date2,0), coalesce(@total_item_count_date2,0), coalesce(@total_page_count_date2,0)
			order by code, code2, code3;
		end;
	end;
END;
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
		
		-- Add the default views
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
		values ( @ItemID, 1, '', '');
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
		values ( @ItemID, 2, '', '');
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

-- Update the version number
if (( select count(*) from SobekCM_Database_Version ) = 0 )
begin
	insert into SobekCM_Database_Version ( Major_Version, Minor_Version, Release_Phase )
	values ( 4, 9, '0' );
end
else
begin
	update SobekCM_Database_Version
	set Major_Version=4, Minor_Version=9, Release_Phase='0';
end;
GO
