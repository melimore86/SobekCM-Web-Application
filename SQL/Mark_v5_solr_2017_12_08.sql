--/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP 1000 [MetadataTypeID]
--      ,[MetadataName]
--      ,[SobekCode]
--      ,[SolrCode]
--      ,[DisplayTerm]
--      ,[FacetTerm]
--      ,[CustomField]
--      ,[canFacetBrowse]
--      ,[DefaultAdvancedSearch]
--  FROM [test].[dbo].[SobekCM_Metadata_Types]

--  select * from SobekCM_Metadata_Types where SolrCode='all'

  -- Add a setting to choose which search system to use
  if ( not exists ( select 1 from SobekCM_Settings where Setting_Key='Search System' ))
  begin
	insert into SobekCM_Settings ( Setting_Key, Setting_Value, TabPage, Heading, Hidden, Reserved, Help, Options )
	values ( 'Search System', 'Legacy', 'System / Server Settings', 'System Settings', 0, 0, 'Which search system to use, the legacy which uses database searching, or the new completely solr based searching for version 5 (currenty in beta testing). \n\nIMPORTANT!! Using the beta search system requires at least version 7.1.0 of solr, using the new schemas, and re-indexing all your resources.', 'Legacy|Beta');
  end;
  GO

  -- Add a (fairly temporary) setting for the legacy solr documents index
  if ( not exists ( select 1 from SobekCM_Settings where Setting_Key='Document Solr Legacy Index' ))
  begin
	insert into SobekCM_Settings ( Setting_Key, Setting_Value, TabPage, Heading, Hidden, Reserved, Help, Options )
	select 'Document Solr Legacy Index', Setting_Value, TabPage, Heading, Hidden, Reserved, 'Legacy solr/lucene index URL\n\n' + Help, Options 
	from SobekCM_Settings 
	where Setting_Key = 'Document Solr Index URL';
  end;
  GO

    -- Add a (fairly temporary) setting for the legacy solr page index
  if ( not exists ( select 1 from SobekCM_Settings where Setting_Key='Page Solr Legacy Index' ))
  begin
	insert into SobekCM_Settings ( Setting_Key, Setting_Value, TabPage, Heading, Hidden, Reserved, Help, Options )
	select 'Page Solr Legacy Index', Setting_Value, TabPage, Heading, Hidden, Reserved, 'Legacy solr/lucene index URL\n\n' + Help, Options 
	from SobekCM_Settings 
	where Setting_Key = 'Page Solr Index URL';
  end;
  GO

  -- Change the help text for the solr indexes ( the new ones ) so the example is http://localhost:8983/solr/documents, for example
  update SobekCM_Settings 
  set Help = 'URL for the resource-level solr index used when searching for matching pages within a single document.\n\nExample: ''http://localhost:8983/solr/pages'''
  where Setting_Key = 'Page Solr Index URL'; 

  update SobekCM_Settings 
  set Help = 'URL for the document-level solr index.\n\nExample: ''http://localhost:8983/solr/documents'''
  where Setting_Key = 'Document Solr Index URL'; 


  select Help from SobekCM_Settings where Setting_Key='Document Solr Index URL'


  -- Add legacy solr column, if it doesn't exist
  if ( COL_LENGTH('dbo.SobekCM_Metadata_Types', 'LegacySolrCode') is null )
  begin
	-- Add column
	alter table dbo.SobekCM_Metadata_Types 
	add LegacySolrCode varchar(100) null;
  end;
  GO

  -- Add the new solr facets column, if it doesn't exist
  if ( COL_LENGTH('dbo.SobekCM_Metadata_Types', 'SolrCode_Facets') is null )
  begin
	-- Add column
	alter table dbo.SobekCM_Metadata_Types 
	add SolrCode_Facets varchar(100) null;
  end;
  GO

  -- Add the new display column, if it doesn't exist
  if ( COL_LENGTH('dbo.SobekCM_Metadata_Types', 'SolrCode_Display') is null )
  begin
	-- Add column
	alter table dbo.SobekCM_Metadata_Types 
	add SolrCode_Display varchar(100) null;
  end;
  GO

  -- Copy the data over to the legacy solr code, if not there
  if ( not exists ( select 1 from SobekCM_Metadata_Types where LegacySolrCode is not null ))
  begin
  	-- Copy over all the current data
	update SobekCM_Metadata_Types
	set LegacySolrCode = SolrCode;
  end;
  GO


  -- DO these first
  update SobekCM_Metadata_Types set MetadataName=replace(MetadataName, '_', ' ') where MetadataName like 'LOM_%';
  update SobekCM_Metadata_Types set MetadataName='LOM Age Range' where MetadataName='LOM AgeRange';
  GO

  insert into SobekCM_Metadata_Types ( MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, DefaultAdvancedSearch, SolrCode_Facets, SolrCode_Display )
  values ( 'Performance', 'PE', 'performance', 'Performance', 'Peformance', 'false', 'false', 'false', 'peformance_facets', null );
  GO

  insert into SobekCM_Metadata_Types ( MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, DefaultAdvancedSearch, SolrCode_Facets, SolrCode_Display )
  values ( 'Performance Date', 'PD', 'performance_date', 'Performance Date', 'Peformance Date', 'false', 'false', 'false', 'peformance_date_facets', null );
  GO

  insert into SobekCM_Metadata_Types ( MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, DefaultAdvancedSearch, SolrCode_Facets, SolrCode_Display )
  values ( 'Performer', 'PR', 'performer', 'Performer', 'Peformer', 'false', 'false', 'false', 'peformer_facets', null );
  GO


  -- Also, add:
  --   lom learning time 
  --   lom resource type
  --   zt hierarchical
  --   translated title
  --   
  -- check all display fields and suppress?

  -- Don't forget to finish and export SobekCM_Metadata_Save_Single






  -- Create the update SQL
  select 'update SobekCM_Metadata_Types set SolrCode=''' + SolrCode + ''', SolrCode_Facets=''' + SolrCode_Facets + ''',SolrCode_Display=''' + SolrCode_Display + ''' where MetadataName=''' + MetadataName + ''''
  from SobekCM_Metadata_Types
  where SolrCode_Facets is not null and SolrCode_Display is not null
  union
  select 'update SobekCM_Metadata_Types set SolrCode=''' + SolrCode + ''', SolrCode_Facets=NULL,SolrCode_Display=''' + SolrCode_Display + ''' where MetadataName=''' + MetadataName + ''''
  from SobekCM_Metadata_Types
  where SolrCode_Facets is null and SolrCode_Display is not null
  union
  select 'update SobekCM_Metadata_Types set SolrCode=''' + SolrCode + ''', SolrCode_Facets=''' + SolrCode_Facets + ''',SolrCode_Display=NULL where MetadataName=''' + MetadataName + ''''
  from SobekCM_Metadata_Types
  where SolrCode_Facets is not null and SolrCode_Display is null
  union
  select 'update SobekCM_Metadata_Types set SolrCode=''' + SolrCode + ''', SolrCode_Facets=NULL,SolrCode_Display=NULL where MetadataName=''' + MetadataName + ''''
  from SobekCM_Metadata_Types
  where SolrCode_Facets is null and SolrCode_Display is null;

  GO
  

-- Gets the list of all system-wide settings from the database, including the full list of all
-- metadata search fields, possible workflows, and all disposition data
ALTER PROCEDURE [dbo].[SobekCM_Get_Settings]
	@IncludeAdminViewInfo bit
AS
begin

	-- No need to perform any locks here.  A slightly dirty read won't hurt much
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	-- Get all the standard SobekCM settings
	if ( @IncludeAdminViewInfo = 'true' )
	begin
		select Setting_Key, Setting_Value, TabPage, Heading, Hidden, Reserved, Help, Options, SettingID, Dimensions
		from SobekCM_Settings
		where Hidden = 'false'
		order by TabPage, Heading, Setting_Key;
	end 
	else
	begin
		select Setting_Key, Setting_Value
		from SobekCM_Settings;
	end;

	-- Return all the metadata search fields
	select MetadataTypeID, MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, 
	       coalesce(SolrCode_Facets,'') as SolrCode_Facets, 
		   coalesce(SolrCode_Display,'') as SolrCode_Display,
		   coalesce(LegacySolrCode,'') as LegacySolrCode
	from SobekCM_Metadata_Types
	order by DisplayTerm;

	-- Return all the possible workflow types
	select WorkFlowID, WorkFlowName, WorkFlowNotes, Start_Event_Number, End_Event_Number, Start_And_End_Event_Number, Start_Event_Desc, End_Event_Desc
	from Tracking_WorkFlow;

	-- Return all the possible disposition options
	select DispositionID, DispositionFuture, DispositionPast, DispositionNotes
	from Tracking_Disposition_Type;

	-- Always return all the incoming folders
	select IncomingFolderId, NetworkFolder, ErrorFolder, ProcessingFolder, Perform_Checksum_Validation, Archive_TIFF, Archive_All_Files,
		   Allow_Deletes, Allow_Folders_No_Metadata, Allow_Metadata_Updates, FolderName, Can_Move_To_Content_Folder, BibID_Roots_Restrictions,
		   F.ModuleSetID, S.SetName
	from SobekCM_Builder_Incoming_Folders F left outer join 
	     SobekCM_Builder_Module_Set S on F.ModuleSetID=S.ModuleSetID;

	-- Return all the non-scheduled type modules
	select M.ModuleID, M.[Assembly], M.Class, M.ModuleDesc, M.Argument1, M.Argument2, M.Argument3, M.[Enabled], S.ModuleSetID, S.SetName, S.[Enabled] as SetEnabled, T.TypeAbbrev, T.TypeDescription
	from SobekCM_Builder_Module M, SobekCM_Builder_Module_Set S, SobekCM_Builder_Module_Type T
	where M.ModuleSetID = S.ModuleSetID
	  and S.ModuleTypeID = T.ModuleTypeID
	  and T.TypeAbbrev <> 'SCHD'
	order by TypeAbbrev, S.SetOrder, M.[Order];


	-- Return all the scheduled type modules, with the schedule and the last run info
	with last_run_cte ( ModuleScheduleID, LastRun) as 
	(
		select ModuleScheduleID, MAX([Timestamp])
		from SobekCM_Builder_Module_Scheduled_Run
		group by ModuleScheduleID
	)
	-- Return all the scheduled type modules, along with information on when it was last run
	select M.ModuleID, M.[Assembly], M.Class, M.ModuleDesc, M.Argument1, M.Argument2, M.Argument3, M.[Enabled], S.ModuleSetID, S.SetName, S.[Enabled] as SetEnabled, T.TypeAbbrev, T.TypeDescription, C.ModuleScheduleID, C.[Enabled] as ScheduleEnabled, C.DaysOfWeek, C.TimesOfDay, L.LastRun
	from SobekCM_Builder_Module M inner join
		 SobekCM_Builder_Module_Set S on M.ModuleSetID = S.ModuleSetID inner join
		 SobekCM_Builder_Module_Type T on S.ModuleTypeID = T.ModuleTypeID inner join
		 SobekCM_Builder_Module_Schedule C on C.ModuleSetID = S.ModuleSetID left outer join
		 last_run_cte L on L.ModuleScheduleID = C.ModuleScheduleID
	where T.TypeAbbrev = 'SCHD'
	order by TypeAbbrev, S.SetOrder, M.[Order];

	-- Return all the item viewer config information
	select ItemViewTypeID, ViewType, [Order], DefaultView, MenuOrder
	from SobekCM_item_Viewer_Types
	order by ViewType;
	
	-- Return all the information about the extensions from the database
	select ExtensionID, Code, Name, CurrentVersion, IsEnabled, EnabledDate, LicenseKey, UpgradeUrl, LatestVersion 
	from SobekCM_Extension
	order by Code;

end;
GO

