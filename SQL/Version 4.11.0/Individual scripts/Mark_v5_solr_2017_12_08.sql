

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
  GO

  update SobekCM_Settings 
  set Help = 'URL for the document-level solr index.\n\nExample: ''http://localhost:8983/solr/documents'''
  where Setting_Key = 'Document Solr Index URL'; 
  GO

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

  -- Add a public date to the Item table - this records the first time an item was made public
  if ( COL_LENGTH('dbo.SobekCM_Item', 'MadePublicDate') is null )
  begin
	-- Add column
	alter table dbo.SobekCM_Item 
	add MadePublicDate datetime null;
  end;
  GO

  -- Also, set the made public dates
  update SobekCM_Item 
  set MadePublicDate=CreateDate
  where ( Dark = 'false' ) and ( IP_Restriction_Mask >= 0 );
  GO

if ( not exists ( select 1 from sys.indexes where name='IX_SobekCM_Item_MadePublicDate' AND object_id = OBJECT_ID('dbo.SobekCM_Item')))
begin
	  CREATE NONCLUSTERED INDEX [IX_SobekCM_Item_MadePublicDate] ON [dbo].[SobekCM_Item]
	  (
			[MadePublicDate] ASC
	  )
	  INCLUDE ( 	[ItemID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
end;
GO

  -- Set the flag for results grouping
  if ( COL_LENGTH('dbo.SobekCM_Item_Aggregation', 'GroupResults') is null )
  begin
	-- Add column
	alter table dbo.SobekCM_Item_Aggregation
	add GroupResults bit not null default('false');
  end;
  GO

  -- Just a double check
  if ( COL_LENGTH('dbo.SobekCM_Extension', 'Name') is null )
  begin
	-- Add column
	alter table dbo.SobekCM_Extension 
	add Name varchar(100) null;
  end;
  GO 


  -- DO these first
  update SobekCM_Metadata_Types set MetadataName=replace(MetadataName, '_', ' ') where MetadataName like 'LOM_%';
  update SobekCM_Metadata_Types set MetadataName='LOM Age Range' where MetadataName='LOM AgeRange';
  GO

  insert into SobekCM_Metadata_Types ( MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, DefaultAdvancedSearch, SolrCode_Facets, SolrCode_Display )
  values ( 'Performance', 'PE', 'performance', 'Performance', 'Peformance', 'false', 'true', 'false', 'peformance_facets', 'performance.display' );
  GO

  insert into SobekCM_Metadata_Types ( MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, DefaultAdvancedSearch, SolrCode_Facets, SolrCode_Display )
  values ( 'Performance Date', 'PD', 'performance_date', 'Performance Date', 'Peformance Date', 'false', 'true', 'false', 'peformance_date_facets', null );
  GO

  insert into SobekCM_Metadata_Types ( MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, DefaultAdvancedSearch, SolrCode_Facets, SolrCode_Display )
  values ( 'Performer', 'PR', 'performer', 'Performer', 'Peformer', 'false', 'true', 'false', 'peformer_facets', 'performer.display' );
  GO

  insert into SobekCM_Metadata_Types ( MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, DefaultAdvancedSearch, SolrCode_Facets, SolrCode_Display )
  values ( 'LOM Resource Type', 'LE', 'lom_resource_type', 'Learning Object Type', 'Learning Object Type', 'false', 'true', 'false', 'lom_resource_type_facets', 'lom_resource_type.display' );
  GO

  insert into SobekCM_Metadata_Types ( MetadataName, SobekCode, SolrCode, DisplayTerm, FacetTerm, CustomField, canFacetBrowse, DefaultAdvancedSearch, SolrCode_Facets, SolrCode_Display )
  values ( 'LOM Learning Time', 'LT', 'lom_learning_time', 'Learning Time', 'Learning Time', 'false', 'true', 'false', 'lom_learning_time_facets', 'lom_learning_time' );
  GO


  -- Also, add:
  --   zt hierarchical
  --   translated title
  --   
  -- check all display fields and suppress?

  -- Don't forget to finish and export SobekCM_Metadata_Save_Single





  -- Create the update SQL
  --select 'update SobekCM_Metadata_Types set SolrCode=''' + SolrCode + ''', SolrCode_Facets=''' + SolrCode_Facets + ''',SolrCode_Display=''' + SolrCode_Display + ''' where MetadataName=''' + MetadataName + ''''
  --from SobekCM_Metadata_Types
  --where SolrCode_Facets is not null and SolrCode_Display is not null
  --union
  --select 'update SobekCM_Metadata_Types set SolrCode=''' + SolrCode + ''', SolrCode_Facets=NULL,SolrCode_Display=''' + SolrCode_Display + ''' where MetadataName=''' + MetadataName + ''''
  --from SobekCM_Metadata_Types
  --where SolrCode_Facets is null and SolrCode_Display is not null
  --union
  --select 'update SobekCM_Metadata_Types set SolrCode=''' + SolrCode + ''', SolrCode_Facets=''' + SolrCode_Facets + ''',SolrCode_Display=NULL where MetadataName=''' + MetadataName + ''''
  --from SobekCM_Metadata_Types
  --where SolrCode_Facets is not null and SolrCode_Display is null
  --union
  --select 'update SobekCM_Metadata_Types set SolrCode=''' + SolrCode + ''', SolrCode_Facets=NULL,SolrCode_Display=NULL where MetadataName=''' + MetadataName + ''''
  --from SobekCM_Metadata_Types
  --where SolrCode_Facets is null and SolrCode_Display is null;
  --GO

  update SobekCM_Metadata_Types set SolrCode='', SolrCode_Facets=NULL,SolrCode_Display='' where MetadataName='Publisher.Display'
update SobekCM_Metadata_Types set SolrCode='', SolrCode_Facets=NULL,SolrCode_Display='' where MetadataName='Spatial Coverage.Display'
update SobekCM_Metadata_Types set SolrCode='', SolrCode_Facets=NULL,SolrCode_Display='' where MetadataName='Subjects.Display'
update SobekCM_Metadata_Types set SolrCode='abstract', SolrCode_Facets=NULL,SolrCode_Display='abstract' where MetadataName='Abstract'
update SobekCM_Metadata_Types set SolrCode='accession_number', SolrCode_Facets='accession_number_facets',SolrCode_Display='accession_number.display' where MetadataName='Accession Number'
update SobekCM_Metadata_Types set SolrCode='affiliation', SolrCode_Facets='affiliation_facets',SolrCode_Display='affiliation.display' where MetadataName='Affiliation'
update SobekCM_Metadata_Types set SolrCode='aggregations', SolrCode_Facets=NULL,SolrCode_Display='aggregations' where MetadataName='Aggregations'
update SobekCM_Metadata_Types set SolrCode='all subjects', SolrCode_Facets=NULL,SolrCode_Display='all subjects' where MetadataName='All Subjects'
update SobekCM_Metadata_Types set SolrCode='attribution', SolrCode_Facets=NULL,SolrCode_Display='attribution' where MetadataName='Attribution'
update SobekCM_Metadata_Types set SolrCode='audience', SolrCode_Facets='audience_facets',SolrCode_Display='audience' where MetadataName='Target Audience'
update SobekCM_Metadata_Types set SolrCode='bibid', SolrCode_Facets=NULL,SolrCode_Display='bibid' where MetadataName='BibID'
update SobekCM_Metadata_Types set SolrCode='city', SolrCode_Facets='city_facets',SolrCode_Display='city' where MetadataName='City'
update SobekCM_Metadata_Types set SolrCode='country', SolrCode_Facets='country_facets',SolrCode_Display='country' where MetadataName='Country'
update SobekCM_Metadata_Types set SolrCode='county', SolrCode_Facets='county_facets',SolrCode_Display='county' where MetadataName='County'
update SobekCM_Metadata_Types set SolrCode='creator', SolrCode_Facets='creator_facets',SolrCode_Display='creator.display' where MetadataName='Creator'
update SobekCM_Metadata_Types set SolrCode='cultural_context', SolrCode_Facets='cultural_context_facets',SolrCode_Display='cultural_context' where MetadataName='Cultural Context'
update SobekCM_Metadata_Types set SolrCode='donor', SolrCode_Facets='donor_facets',SolrCode_Display='donor' where MetadataName='Donor'
update SobekCM_Metadata_Types set SolrCode='edition', SolrCode_Facets='edition_facets',SolrCode_Display='edition' where MetadataName='Edition'
update SobekCM_Metadata_Types set SolrCode='etd_committee', SolrCode_Facets='etd_committee_facets',SolrCode_Display='etd_committee' where MetadataName='ETD Committee'
update SobekCM_Metadata_Types set SolrCode='etd_degree', SolrCode_Facets='etd_degree_facets',SolrCode_Display='etd_degree' where MetadataName='ETD Degree'
update SobekCM_Metadata_Types set SolrCode='etd_degree_discipline', SolrCode_Facets='etd_degree_discipline_facets',SolrCode_Display='etd_degree_discipline' where MetadataName='ETD Degree Discipline'
update SobekCM_Metadata_Types set SolrCode='etd_degree_division', SolrCode_Facets='etd_degree_division_facets',SolrCode_Display='etd_degree_division' where MetadataName='ETD Degree Division'
update SobekCM_Metadata_Types set SolrCode='etd_degree_grantor', SolrCode_Facets='etd_degree_grantor_facets',SolrCode_Display='etd_degree_grantor' where MetadataName='ETD Degree Grantor'
update SobekCM_Metadata_Types set SolrCode='etd_degree_level', SolrCode_Facets='etd_degree_level_facets',SolrCode_Display='etd_degree_level' where MetadataName='ETD Degree Level'
update SobekCM_Metadata_Types set SolrCode='format', SolrCode_Facets='format_facets',SolrCode_Display='format' where MetadataName='Format'
update SobekCM_Metadata_Types set SolrCode='frequency', SolrCode_Facets='frequency_facets',SolrCode_Display='frequency' where MetadataName='Frequency'
update SobekCM_Metadata_Types set SolrCode='fullcitation', SolrCode_Facets=NULL,SolrCode_Display=NULL where MetadataName='Full Citation'
update SobekCM_Metadata_Types set SolrCode='genre', SolrCode_Facets='genre_facets',SolrCode_Display='genre.display' where MetadataName='Genre'
update SobekCM_Metadata_Types set SolrCode='holding', SolrCode_Facets='holding_facets',SolrCode_Display='holding' where MetadataName='Holding Location'
update SobekCM_Metadata_Types set SolrCode='identifier', SolrCode_Facets='identifier_facets',SolrCode_Display='identifier.display' where MetadataName='Identifier'
update SobekCM_Metadata_Types set SolrCode='inscription', SolrCode_Facets=NULL,SolrCode_Display='inscription' where MetadataName='Inscription'
update SobekCM_Metadata_Types set SolrCode='interviewee', SolrCode_Facets='interviewee_facets',SolrCode_Display='interviewee' where MetadataName='Interviewee'
update SobekCM_Metadata_Types set SolrCode='interviewer', SolrCode_Facets='interviewer_facets',SolrCode_Display='interviewer' where MetadataName='Interviewer'
update SobekCM_Metadata_Types set SolrCode='language', SolrCode_Facets='language_facets',SolrCode_Display='language' where MetadataName='Language'
update SobekCM_Metadata_Types set SolrCode='lom_age_range', SolrCode_Facets='lom_age_range_facets',SolrCode_Display='lom_age_range' where MetadataName='LOM Age Range'
update SobekCM_Metadata_Types set SolrCode='lom_aggregation', SolrCode_Facets='lom_aggregation_facets',SolrCode_Display='lom_aggregation' where MetadataName='LOM Aggregation'
update SobekCM_Metadata_Types set SolrCode='lom_classification', SolrCode_Facets='lom_classification_facets',SolrCode_Display='lom_classification.display' where MetadataName='LOM Classification'
update SobekCM_Metadata_Types set SolrCode='lom_context', SolrCode_Facets='lom_context_facets',SolrCode_Display='lom_context.display' where MetadataName='LOM Context'
update SobekCM_Metadata_Types set SolrCode='lom_difficulty', SolrCode_Facets='lom_difficulty_facets',SolrCode_Display='lom_difficulty' where MetadataName='LOM Difficulty'
update SobekCM_Metadata_Types set SolrCode='lom_intended_end_user', SolrCode_Facets='lom_intended_end_user_facets',SolrCode_Display='lom_intended_end_user.display' where MetadataName='LOM Intended End User'
update SobekCM_Metadata_Types set SolrCode='lom_interactivity_level', SolrCode_Facets='lom_interactivity_level_facets',SolrCode_Display='lom_interactivity_level.display' where MetadataName='LOM Interactivity Level'
update SobekCM_Metadata_Types set SolrCode='lom_interactivity_type', SolrCode_Facets='lom_interactivity_type_facets',SolrCode_Display='lom_interactivity_type.display' where MetadataName='LOM Interactivity Type'
update SobekCM_Metadata_Types set SolrCode='lom_learning_time', SolrCode_Facets='lom_learning_time_facets',SolrCode_Display='lom_learning_time' where MetadataName='LOM Learning Time'
update SobekCM_Metadata_Types set SolrCode='lom_requirement', SolrCode_Facets='lom_requirement_facets',SolrCode_Display='lom_requirement.display' where MetadataName='LOM Requirement'
update SobekCM_Metadata_Types set SolrCode='lom_resource_type', SolrCode_Facets='lom_resource_type_facets',SolrCode_Display='lom_resource_type.display' where MetadataName='LOM Resource Type'
update SobekCM_Metadata_Types set SolrCode='lom_status', SolrCode_Facets='lom_status_facets',SolrCode_Display='lom_status' where MetadataName='LOM Status'
update SobekCM_Metadata_Types set SolrCode='material', SolrCode_Facets='material_facets',SolrCode_Display='material.display' where MetadataName='Material'
update SobekCM_Metadata_Types set SolrCode='measurements', SolrCode_Facets='measurements_facets',SolrCode_Display='measurements.display' where MetadataName='Measurements'
update SobekCM_Metadata_Types set SolrCode='mime_type', SolrCode_Facets='mime_type_facets',SolrCode_Display='mime_type' where MetadataName='MIME Type'
update SobekCM_Metadata_Types set SolrCode='name_as_subject', SolrCode_Facets='name_as_subject_facets',SolrCode_Display='name_as_subject.display' where MetadataName='Name as Subject'
update SobekCM_Metadata_Types set SolrCode='notes', SolrCode_Facets=NULL,SolrCode_Display='notes' where MetadataName='Notes'
update SobekCM_Metadata_Types set SolrCode='other', SolrCode_Facets=NULL,SolrCode_Display='other' where MetadataName='Other_Citation'
update SobekCM_Metadata_Types set SolrCode='performance', SolrCode_Facets='peformance_facets',SolrCode_Display='performance.display' where MetadataName='Performance'
update SobekCM_Metadata_Types set SolrCode='performance_date', SolrCode_Facets='peformance_date_facets',SolrCode_Display='performance_date' where MetadataName='Performance Date'
update SobekCM_Metadata_Types set SolrCode='performer', SolrCode_Facets='peformer_facets',SolrCode_Display='performer.display' where MetadataName='Performer'
update SobekCM_Metadata_Types set SolrCode='publication date', SolrCode_Facets=NULL,SolrCode_Display='publication date' where MetadataName='Publication Date'
update SobekCM_Metadata_Types set SolrCode='publication_place', SolrCode_Facets='publication_place_facets',SolrCode_Display='publication_place' where MetadataName='Publication Place'
update SobekCM_Metadata_Types set SolrCode='publisher', SolrCode_Facets='publisher_facets',SolrCode_Display='publisher.display' where MetadataName='Publisher'
update SobekCM_Metadata_Types set SolrCode='source', SolrCode_Facets='source_facets',SolrCode_Display='source' where MetadataName='Source Institution'
update SobekCM_Metadata_Types set SolrCode='spatial_standard', SolrCode_Facets='spatial_standard_facets',SolrCode_Display='spatial_standard.display' where MetadataName='Spatial Coverage'
update SobekCM_Metadata_Types set SolrCode='state', SolrCode_Facets='state_facets',SolrCode_Display='state' where MetadataName='State'
update SobekCM_Metadata_Types set SolrCode='style_period', SolrCode_Facets='style_period_facets',SolrCode_Display='style_period' where MetadataName='Style Period'
update SobekCM_Metadata_Types set SolrCode='subject', SolrCode_Facets='subject_facets',SolrCode_Display='subject.display' where MetadataName='Subject Keyword'
update SobekCM_Metadata_Types set SolrCode='technique', SolrCode_Facets='technique_facets',SolrCode_Display='technique' where MetadataName='Technique'
update SobekCM_Metadata_Types set SolrCode='temporal decade', SolrCode_Facets=NULL,SolrCode_Display='temporal decade' where MetadataName='Temporal Decade'
update SobekCM_Metadata_Types set SolrCode='temporal subject', SolrCode_Facets=NULL,SolrCode_Display='temporal subject' where MetadataName='Temporal Subject'
update SobekCM_Metadata_Types set SolrCode='temporal year', SolrCode_Facets=NULL,SolrCode_Display='temporal year' where MetadataName='Temporal Year'
update SobekCM_Metadata_Types set SolrCode='tickler', SolrCode_Facets='tickler_facets',SolrCode_Display='tickler' where MetadataName='Tickler'
update SobekCM_Metadata_Types set SolrCode='title', SolrCode_Facets=NULL,SolrCode_Display='title' where MetadataName='Title'
update SobekCM_Metadata_Types set SolrCode='title_as_subject', SolrCode_Facets='title_as_subject_facets',SolrCode_Display='title_as_subject.display' where MetadataName='Title as Subject'
update SobekCM_Metadata_Types set SolrCode='toc', SolrCode_Facets=NULL,SolrCode_Display=NULL where MetadataName='TOC'
update SobekCM_Metadata_Types set SolrCode='tracking_box', SolrCode_Facets='tracking_box_facets',SolrCode_Display='tracking_box' where MetadataName='Tracking Box'
update SobekCM_Metadata_Types set SolrCode='type', SolrCode_Facets='type_facets',SolrCode_Display='type' where MetadataName='Type'
update SobekCM_Metadata_Types set SolrCode='user description', SolrCode_Facets=NULL,SolrCode_Display='user description' where MetadataName='User Description'
update SobekCM_Metadata_Types set SolrCode='user_defined_01', SolrCode_Facets='user_defined_01_facets',SolrCode_Display='user_defined_01.display' where MetadataName='UserDefined01'
update SobekCM_Metadata_Types set SolrCode='user_defined_02', SolrCode_Facets='user_defined_02_facets',SolrCode_Display='user_defined_02.display' where MetadataName='UserDefined02'
update SobekCM_Metadata_Types set SolrCode='user_defined_03', SolrCode_Facets='user_defined_03_facets',SolrCode_Display='user_defined_03.display' where MetadataName='UserDefined03'
update SobekCM_Metadata_Types set SolrCode='user_defined_04', SolrCode_Facets='user_defined_04_facets',SolrCode_Display='user_defined_04.display' where MetadataName='UserDefined04'
update SobekCM_Metadata_Types set SolrCode='user_defined_05', SolrCode_Facets='user_defined_05_facets',SolrCode_Display='user_defined_05.display' where MetadataName='UserDefined05'
update SobekCM_Metadata_Types set SolrCode='user_defined_06', SolrCode_Facets='user_defined_06_facets',SolrCode_Display='user_defined_06.display' where MetadataName='UserDefined06'
update SobekCM_Metadata_Types set SolrCode='user_defined_07', SolrCode_Facets='user_defined_07_facets',SolrCode_Display='user_defined_07.display' where MetadataName='UserDefined07'
update SobekCM_Metadata_Types set SolrCode='user_defined_08', SolrCode_Facets='user_defined_08_facets',SolrCode_Display='user_defined_08.display' where MetadataName='UserDefined08'
update SobekCM_Metadata_Types set SolrCode='user_defined_09', SolrCode_Facets='user_defined_09_facets',SolrCode_Display='user_defined_09.display' where MetadataName='UserDefined09'
update SobekCM_Metadata_Types set SolrCode='user_defined_10', SolrCode_Facets='user_defined_10_facets',SolrCode_Display='user_defined_10.display' where MetadataName='UserDefined10'
update SobekCM_Metadata_Types set SolrCode='user_defined_11', SolrCode_Facets='user_defined_11_facets',SolrCode_Display='user_defined_11.display' where MetadataName='UserDefined11'
update SobekCM_Metadata_Types set SolrCode='user_defined_12', SolrCode_Facets='user_defined_12_facets',SolrCode_Display='user_defined_12.display' where MetadataName='UserDefined12'
update SobekCM_Metadata_Types set SolrCode='user_defined_13', SolrCode_Facets='user_defined_13_facets',SolrCode_Display='user_defined_13.display' where MetadataName='UserDefined13'
update SobekCM_Metadata_Types set SolrCode='user_defined_14', SolrCode_Facets='user_defined_14_facets',SolrCode_Display='user_defined_14.display' where MetadataName='UserDefined14'
update SobekCM_Metadata_Types set SolrCode='user_defined_15', SolrCode_Facets='user_defined_15_facets',SolrCode_Display='user_defined_15.display' where MetadataName='UserDefined15'
update SobekCM_Metadata_Types set SolrCode='user_defined_16', SolrCode_Facets='user_defined_16_facets',SolrCode_Display='user_defined_16.display' where MetadataName='UserDefined16'
update SobekCM_Metadata_Types set SolrCode='user_defined_17', SolrCode_Facets='user_defined_17_facets',SolrCode_Display='user_defined_17.display' where MetadataName='UserDefined17'
update SobekCM_Metadata_Types set SolrCode='user_defined_18', SolrCode_Facets='user_defined_18_facets',SolrCode_Display='user_defined_18.display' where MetadataName='UserDefined18'
update SobekCM_Metadata_Types set SolrCode='user_defined_19', SolrCode_Facets='user_defined_19_facets',SolrCode_Display='user_defined_19.display' where MetadataName='UserDefined19'
update SobekCM_Metadata_Types set SolrCode='user_defined_20', SolrCode_Facets='user_defined_20_facets',SolrCode_Display='user_defined_20.display' where MetadataName='UserDefined20'
update SobekCM_Metadata_Types set SolrCode='user_defined_21', SolrCode_Facets='user_defined_21_facets',SolrCode_Display='user_defined_21.display' where MetadataName='UserDefined21'
update SobekCM_Metadata_Types set SolrCode='user_defined_22', SolrCode_Facets='user_defined_22_facets',SolrCode_Display='user_defined_22.display' where MetadataName='UserDefined22'
update SobekCM_Metadata_Types set SolrCode='user_defined_23', SolrCode_Facets='user_defined_23_facets',SolrCode_Display='user_defined_23.display' where MetadataName='UserDefined23'
update SobekCM_Metadata_Types set SolrCode='user_defined_24', SolrCode_Facets='user_defined_24_facets',SolrCode_Display='user_defined_24.display' where MetadataName='UserDefined24'
update SobekCM_Metadata_Types set SolrCode='user_defined_25', SolrCode_Facets='user_defined_25_facets',SolrCode_Display='user_defined_25.display' where MetadataName='UserDefined25'
update SobekCM_Metadata_Types set SolrCode='user_defined_26', SolrCode_Facets='user_defined_26_facets',SolrCode_Display='user_defined_26.display' where MetadataName='UserDefined26'
update SobekCM_Metadata_Types set SolrCode='user_defined_27', SolrCode_Facets='user_defined_27_facets',SolrCode_Display='user_defined_27.display' where MetadataName='UserDefined27'
update SobekCM_Metadata_Types set SolrCode='user_defined_28', SolrCode_Facets='user_defined_28_facets',SolrCode_Display='user_defined_28.display' where MetadataName='UserDefined28'
update SobekCM_Metadata_Types set SolrCode='user_defined_29', SolrCode_Facets='user_defined_29_facets',SolrCode_Display='user_defined_29.display' where MetadataName='UserDefined29'
update SobekCM_Metadata_Types set SolrCode='user_defined_30', SolrCode_Facets='user_defined_30_facets',SolrCode_Display='user_defined_30.display' where MetadataName='UserDefined30'
update SobekCM_Metadata_Types set SolrCode='user_defined_31', SolrCode_Facets='user_defined_31_facets',SolrCode_Display='user_defined_31.display' where MetadataName='UserDefined31'
update SobekCM_Metadata_Types set SolrCode='user_defined_32', SolrCode_Facets='user_defined_32_facets',SolrCode_Display='user_defined_32.display' where MetadataName='UserDefined32'
update SobekCM_Metadata_Types set SolrCode='user_defined_33', SolrCode_Facets='user_defined_33_facets',SolrCode_Display='user_defined_33.display' where MetadataName='UserDefined33'
update SobekCM_Metadata_Types set SolrCode='user_defined_34', SolrCode_Facets='user_defined_34_facets',SolrCode_Display='user_defined_34.display' where MetadataName='UserDefined34'
update SobekCM_Metadata_Types set SolrCode='user_defined_35', SolrCode_Facets='user_defined_35_facets',SolrCode_Display='user_defined_35.display' where MetadataName='UserDefined35'
update SobekCM_Metadata_Types set SolrCode='user_defined_36', SolrCode_Facets='user_defined_36_facets',SolrCode_Display='user_defined_36.display' where MetadataName='UserDefined36'
update SobekCM_Metadata_Types set SolrCode='user_defined_37', SolrCode_Facets='user_defined_37_facets',SolrCode_Display='user_defined_37.display' where MetadataName='UserDefined37'
update SobekCM_Metadata_Types set SolrCode='user_defined_38', SolrCode_Facets='user_defined_38_facets',SolrCode_Display='user_defined_38.display' where MetadataName='UserDefined38'
update SobekCM_Metadata_Types set SolrCode='user_defined_39', SolrCode_Facets='user_defined_39_facets',SolrCode_Display='user_defined_39.display' where MetadataName='UserDefined39'
update SobekCM_Metadata_Types set SolrCode='user_defined_40', SolrCode_Facets='user_defined_40_facets',SolrCode_Display='user_defined_40.display' where MetadataName='UserDefined40'
update SobekCM_Metadata_Types set SolrCode='user_defined_41', SolrCode_Facets='user_defined_41_facets',SolrCode_Display='user_defined_41.display' where MetadataName='UserDefined41'
update SobekCM_Metadata_Types set SolrCode='user_defined_42', SolrCode_Facets='user_defined_42_facets',SolrCode_Display='user_defined_42.display' where MetadataName='UserDefined42'
update SobekCM_Metadata_Types set SolrCode='user_defined_43', SolrCode_Facets='user_defined_43_facets',SolrCode_Display='user_defined_43.display' where MetadataName='UserDefined43'
update SobekCM_Metadata_Types set SolrCode='user_defined_44', SolrCode_Facets='user_defined_44_facets',SolrCode_Display='user_defined_44.display' where MetadataName='UserDefined44'
update SobekCM_Metadata_Types set SolrCode='user_defined_45', SolrCode_Facets='user_defined_45_facets',SolrCode_Display='user_defined_45.display' where MetadataName='UserDefined45'
update SobekCM_Metadata_Types set SolrCode='user_defined_46', SolrCode_Facets='user_defined_46_facets',SolrCode_Display='user_defined_46.display' where MetadataName='UserDefined46'
update SobekCM_Metadata_Types set SolrCode='user_defined_47', SolrCode_Facets='user_defined_47_facets',SolrCode_Display='user_defined_47.display' where MetadataName='UserDefined47'
update SobekCM_Metadata_Types set SolrCode='user_defined_48', SolrCode_Facets='user_defined_48_facets',SolrCode_Display='user_defined_48.display' where MetadataName='UserDefined48'
update SobekCM_Metadata_Types set SolrCode='user_defined_49', SolrCode_Facets='user_defined_49_facets',SolrCode_Display='user_defined_49.display' where MetadataName='UserDefined49'
update SobekCM_Metadata_Types set SolrCode='user_defined_50', SolrCode_Facets='user_defined_50_facets',SolrCode_Display='user_defined_50.display' where MetadataName='UserDefined50'
update SobekCM_Metadata_Types set SolrCode='user_defined_51', SolrCode_Facets='user_defined_51_facets',SolrCode_Display='user_defined_51.display' where MetadataName='UserDefined51'
update SobekCM_Metadata_Types set SolrCode='user_defined_52', SolrCode_Facets='user_defined_52_facets',SolrCode_Display='user_defined_52.display' where MetadataName='UserDefined52'
update SobekCM_Metadata_Types set SolrCode='zt all taxonomy', SolrCode_Facets=NULL,SolrCode_Display='zt all taxonomy' where MetadataName='ZT All Taxonomy'
update SobekCM_Metadata_Types set SolrCode='zt_class', SolrCode_Facets='zt_class_facets',SolrCode_Display='zt_class' where MetadataName='ZT Class'
update SobekCM_Metadata_Types set SolrCode='zt_common_name', SolrCode_Facets='zt_common_name_facets',SolrCode_Display='zt_common_name' where MetadataName='ZT Common Name'
update SobekCM_Metadata_Types set SolrCode='zt_family', SolrCode_Facets='zt_family_facets',SolrCode_Display='zt_family' where MetadataName='ZT Family'
update SobekCM_Metadata_Types set SolrCode='zt_genus', SolrCode_Facets='zt_genus_facets',SolrCode_Display='zt_genus' where MetadataName='ZT Genus'
update SobekCM_Metadata_Types set SolrCode='zt_kingdom', SolrCode_Facets='zt_kingdom_facets',SolrCode_Display='zt_kingdom' where MetadataName='ZT Kingdom'
update SobekCM_Metadata_Types set SolrCode='zt_order', SolrCode_Facets='zt_order_facets',SolrCode_Display='zt_order' where MetadataName='ZT Order'
update SobekCM_Metadata_Types set SolrCode='zt_phylum', SolrCode_Facets='zt_phylum_facets',SolrCode_Display='zt_phylum' where MetadataName='ZT Phylum'
update SobekCM_Metadata_Types set SolrCode='zt_scientific_name', SolrCode_Facets='zt_scientific_name_facets',SolrCode_Display='zt_scientific_name' where MetadataName='ZT Scientific Name'
update SobekCM_Metadata_Types set SolrCode='zt_species', SolrCode_Facets='zt_species_facets',SolrCode_Display='zt_species' where MetadataName='ZT Species'


-- NEW TABLES since result fields and facet fields are now in the database 


-- Table links result fields to the results views
IF ( NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'SobekCM_Item_Aggregation_Result_Fields'))
begin
	CREATE TABLE [dbo].[SobekCM_Item_Aggregation_Result_Fields](
		[ItemAggregationResultID] [int] NOT NULL,
		[MetadataTypeID] [smallint] NOT NULL,
		[OverrideDisplayTerm] [nvarchar](255) NULL,
		[DisplayOrder] [int] NOT NULL,
		[DisplayOptions] [nvarchar](255) NULL,
	 CONSTRAINT [PK_SobekCM_Item_Aggregation_Result_Fields] PRIMARY KEY CLUSTERED 
	(
		[ItemAggregationResultID] ASC,
		[MetadataTypeID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
end;
GO




-- Table links facets to the aggregation ( all results viewers have access to the same facets )
IF ( NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'SobekCM_Item_Aggregation_Facets'))
begin
	CREATE TABLE [dbo].[SobekCM_Item_Aggregation_Facets](
		[AggregationID] [int] NOT NULL,
		[MetadataTypeID] [smallint] NOT NULL,
		[OverrideFacetTerm] [nvarchar](100) NULL,
		[FacetOrder] [int] NOT NULL,
		[FacetOptions] [nvarchar](255) NULL,
	 CONSTRAINT [PK_SobekCM_Item_Aggregation_Facets] PRIMARY KEY CLUSTERED 
	(
		[AggregationID] ASC,
		[MetadataTypeID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
end;
GO

-- Add foreign keys
IF ( NOT EXISTS ( SELECT *  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS  WHERE CONSTRAINT_NAME ='FK_SobekCM_Item_Aggregation_Facets_SobekCM_Metadata_Types' ))
begin
	ALTER TABLE [dbo].[SobekCM_Item_Aggregation_Facets]  WITH CHECK ADD  CONSTRAINT [FK_SobekCM_Item_Aggregation_Facets_SobekCM_Metadata_Types] FOREIGN KEY([MetadataTypeID])
	REFERENCES [dbo].[SobekCM_Metadata_Types] ([MetadataTypeID])
end;
GO

IF ( NOT EXISTS ( SELECT *  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS  WHERE CONSTRAINT_NAME ='FK_SobekCM_Item_Aggregation_Facets_SobekCM_Item_Aggregation' ))
begin
	ALTER TABLE [dbo].[SobekCM_Item_Aggregation_Facets]  WITH CHECK ADD  CONSTRAINT [FK_SobekCM_Item_Aggregation_Facets_SobekCM_Item_Aggregation] FOREIGN KEY([AggregationID])
	REFERENCES [dbo].[SobekCM_Item_Aggregation] ([AggregationID])
end;
GO

IF ( NOT EXISTS ( SELECT *  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS  WHERE CONSTRAINT_NAME ='FK_SobekCM_Item_Aggregation_Result_Fields_SobekCM_Item_Aggregation_Result_Views' ))
begin
	ALTER TABLE [dbo].[SobekCM_Item_Aggregation_Result_Fields]  WITH CHECK ADD  CONSTRAINT [FK_SobekCM_Item_Aggregation_Result_Fields_SobekCM_Item_Aggregation_Result_Views] FOREIGN KEY([ItemAggregationResultID])
	REFERENCES [dbo].[SobekCM_Item_Aggregation_Result_Views] ([ItemAggregationResultID]);
end;
GO

IF ( NOT EXISTS ( SELECT *  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS  WHERE CONSTRAINT_NAME ='FK_SobekCM_Item_Aggregation_Result_Views_SobekCM_Item_Aggregation_Result_Types' ))
begin
	ALTER TABLE [dbo].[SobekCM_Item_Aggregation_Result_Views]  WITH CHECK ADD  CONSTRAINT [FK_SobekCM_Item_Aggregation_Result_Views_SobekCM_Item_Aggregation_Result_Types] FOREIGN KEY([ItemAggregationResultTypeID])
	REFERENCES [dbo].[SobekCM_Item_Aggregation_Result_Types] ([ItemAggregationResultTypeID]);
end;
GO

-- Fill the new tables, with the default facets first
if (( select count(*) from SobekCM_Item_Aggregation_Facets ) = 0 )
begin
	insert into SobekCM_Item_Aggregation_Facets ( AggregationID, MetadataTypeID, FacetOrder ) select AggregationID, 3, 1 from SobekCM_Item_Aggregation;
	insert into SobekCM_Item_Aggregation_Facets ( AggregationID, MetadataTypeID, FacetOrder ) select AggregationID, 4, 2 from SobekCM_Item_Aggregation;
	insert into SobekCM_Item_Aggregation_Facets ( AggregationID, MetadataTypeID, FacetOrder ) select AggregationID, 5, 3 from SobekCM_Item_Aggregation;
	insert into SobekCM_Item_Aggregation_Facets ( AggregationID, MetadataTypeID, FacetOrder ) select AggregationID, 7, 4 from SobekCM_Item_Aggregation;
	insert into SobekCM_Item_Aggregation_Facets ( AggregationID, MetadataTypeID, FacetOrder ) select AggregationID, 10, 5 from SobekCM_Item_Aggregation;
	insert into SobekCM_Item_Aggregation_Facets ( AggregationID, MetadataTypeID, FacetOrder ) select AggregationID, 8, 6 from SobekCM_Item_Aggregation;
end;
GO

-- Add the default result fields
if (( select count(*) from SobekCM_Item_Aggregation_Result_Fields ) = 0 )
begin
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 4, 1 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 5, 2 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 2, 4 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 22, 5 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 38, 6 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 15, 7 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 16, 8 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 21, 9 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 7, 10 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 10, 11 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 8, 12 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
	insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, DisplayOrder ) select ItemAggregationResultID, 3, 13 from SobekCM_Item_Aggregation_Result_Views where ItemAggregationResultTypeID in ( 1, 3, 4);
end;
GO



-- Update the old solr indexer for the new name
update SobekCM_Builder_Module 
set Class='SobekCM.Builder_Library.Modules.Items.SaveToSolrLuceneModule_Legacy',
    ModuleDesc = 'Save to the old solr/lucene legacy indexes'
where Class='SobekCM.Builder_Library.Modules.Items.SaveToSolrLuceneModule';
GO

-- Get the old solr module order number
declare @old_solr_order int;
set @old_solr_order = ( select [Order] from SobekCM_Builder_Module where Class='SobekCM.Builder_Library.Modules.Items.SaveToSolrLuceneModule_Legacy' );

-- Make room for this new solr indexer
update SobekCM_Builder_Module 
set [Order] = [Order] + 1
where [Order] > @old_solr_order;

-- Add the new builder module to index the new beta / version 5 modules
insert into SobekCM_Builder_Module ( ModuleSetID, ModuleDesc, Class, [Enabled], [Order] )
values ( 3, 'Save to the new version 5 beta solr/lucene indexes.', 'SobekCM.Builder_Library.Modules.Items.SaveToSolrLuceneModule_v5', 'true', @old_solr_order+1 );
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


-- Saves all the main data for a new item in a SobekCM library, 
-- including the serial hierarchy, behaviors, tracking, and basic item information
-- Written by Mark Sullivan ( January 2011 )
ALTER PROCEDURE [dbo].[SobekCM_Save_New_Item]
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
	@TextSearchable bit,
	@MainThumbnail varchar(100),
	@MainJPEG varchar(100),
	@IP_Restriction_Mask smallint,
	@CheckoutRequired bit,
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
	@Viewer1_TypeID int,
	@Viewer1_Label nvarchar(50),
	@Viewer1_Attribute nvarchar(250),
	@Viewer2_TypeID int,
	@Viewer2_Label nvarchar(50),
	@Viewer2_Attribute nvarchar(250),
	@Viewer3_TypeID int,
	@Viewer3_Label nvarchar(50),
	@Viewer3_Attribute nvarchar(250),
	@Viewer4_TypeID int,
	@Viewer4_Label nvarchar(50),
	@Viewer4_Attribute nvarchar(250),
	@Viewer5_TypeID int,
	@Viewer5_Label nvarchar(50),
	@Viewer5_Attribute nvarchar(250),
	@Viewer6_TypeID int,
	@Viewer6_Label nvarchar(50),
	@Viewer6_Attribute nvarchar(250),
	@Level1_Text varchar(255),
	@Level1_Index int,
	@Level2_Text varchar(255),
	@Level2_Index int,
	@Level3_Text varchar(255),
	@Level3_Index int,
	@Level4_Text varchar(255),
	@Level4_Index int,
	@Level5_Text varchar(255),
	@Level5_Index int,
	@VIDSource varchar(150),
	@CopyrightIndicator smallint, 
	@Born_Digital bit,
	@Dark bit,
	@Material_Received_Date datetime,
	@Material_Recd_Date_Estimated bit,
	@Disposition_Advice int,
	@Disposition_Advice_Notes varchar(150),
	@Internal_Comments nvarchar(1000),
	@Tracking_Box varchar(25),
	@Online_Submit bit,
	@User varchar(50),
	@UserNotes varchar(1000),
	@UserID_To_Link int,
	@ItemID int output,
	@New_VID varchar(5) output
AS
begin transaction

	-- Set the return VID value and itemid first
	set @New_VID = @VID;
	set @ItemID = -1;

	-- Verify this is a new item before doing anything
	if ( (	 select count(*) from SobekCM_Item I where ( I.VID = @VID ) and ( I.GroupID = @GroupID ))  =  0 )
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
				select @New_VID = '00001'
			end
			else
			begin
				select @New_VID = RIGHT('0000' + (CAST( @next_vid_number as varchar(5))), 5);	
			end;	
		end;

		-- Add the values to the main SobekCM_Item table first
		insert into SobekCM_Item ( VID, [PageCount], FileCount, Deleted, Title, SortTitle, AccessMethod, Link, CreateDate, PubDate, SortDate, Author, Spatial_KML, Spatial_KML_Distance, GroupID, LastSaved, Donor, Publisher, TextSearchable, MainThumbnail, MainJPEG, CheckoutRequired, IP_Restriction_Mask, Level1_Text, Level1_Index, Level2_Text, Level2_Index, Level3_Text, Level3_Index, Level4_Text, Level4_Index, Level5_Text, Level5_Index, Last_MileStone, VIDSource, Born_Digital, Dark, Material_Received_Date, Material_Recd_Date_Estimated, Disposition_Advice, Internal_Comments, Tracking_Box, Disposition_Advice_Notes, Spatial_Display, Institution_Display, Edition_Display, Material_Display, Measurement_Display, StylePeriod_Display, Technique_Display, Subjects_Display )
		values (  @New_VID, @PageCount, @FileCount, 0, @Title, @SortTitle, @AccessMethod, @Link, @CreateDate, @PubDate, @SortDate, @Author, @Spatial_KML, @Spatial_KML_Distance, @GroupID, GETDATE(), @Donor, @Publisher, @TextSearchable, @MainThumbnail, @MainJPEG, @CheckoutRequired, @IP_Restriction_Mask, @Level1_Text, @Level1_Index, @Level2_Text, @Level2_Index, @Level3_Text, @Level3_Index, @Level4_Text, @Level4_Index, @Level5_Text, @Level5_Index, 0, @VIDSource, @Born_Digital, @Dark, @Material_Received_Date, @Material_Recd_Date_Estimated, @Disposition_Advice, @Internal_Comments, @Tracking_Box, @Disposition_Advice_Notes, @Spatial_Display, @Institution_Display, @Edition_Display, @Material_Display, @Measurement_Display, @StylePeriod_Display, @Technique_Display, @Subjects_Display  );
		
		-- Get the item id identifier for this row
		set @ItemID = @@identity;	
		
		-- Set the milestones to complete if this is NON-PRIVATE, NON-DARK, and BORN DIGITAL
		if (( @IP_Restriction_Mask >= 0 ) and ( @Dark = 'false' ) and ( @Born_Digital = 'true' ))
		begin
			update SobekCM_Item
			set Last_MileStone = 4, Milestone_DigitalAcquisition = CreateDate, Milestone_ImageProcessing=CreateDate, Milestone_QualityControl=CreateDate, Milestone_OnlineComplete=CreateDate 
			where ItemID=@ItemID;		
		end;
				
		-- If a size was included, set that value
		if ( @DiskSize_KB > 0 )
		begin
			update SobekCM_Item set DiskSize_KB = @DiskSize_KB where ItemID=@ItemID;
		end;

		-- Finally set the volume count for this group correctly
		update SobekCM_Item_Group
		set ItemCount = ( select count(*) from SobekCM_Item I where ( I.GroupID = @GroupID ) and ( I.Deleted = 'false' ))
		where GroupID = @GroupID;
		
		-- Add the first icon to this object  (this requires the icons have been pre-established )
		declare @IconID int;
		if ( len( isnull( @Icon1_Name, '' )) > 0 ) 
		begin
			-- Get the Icon ID for this icon
			select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon1_Name;

			-- Tie this item to this icon
			if ( ISNULL(@IconID,-1) > 0 )
			begin
				insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
				values ( @ItemID, @IconID, 1 );
			end;
		end;

		-- Add the second icon to this object  (this requires the icons have been pre-established )
		if ( len( isnull( @Icon2_Name, '' )) > 0 ) 
		begin
			-- Get the Icon ID for this icon
			select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon2_Name;

			-- Tie this item to this icon
			if ( ISNULL(@IconID,-1) > 0 )
			begin
				insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
				values ( @ItemID, @IconID, 2 );
			end;
		end;

		-- Add the third icon to this object  (this requires the icons have been pre-established )
		if ( len( isnull( @Icon3_Name, '' )) > 0 ) 
		begin
			-- Get the Icon ID for this icon
			select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon3_Name;

			-- Tie this item to this icon
			if ( ISNULL(@IconID,-1) > 0 )
			begin
				insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
				values ( @ItemID, @IconID, 3 );
			end;
		end;

		-- Add the fourth icon to this object  (this requires the icons have been pre-established )
		if ( len( isnull( @Icon4_Name, '' )) > 0 ) 
		begin
			-- Get the Icon ID for this icon
			select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon4_Name;
			
			-- Tie this item to this icon
			if ( ISNULL(@IconID,-1) > 0 )
			begin
				insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
				values ( @ItemID, @IconID, 4 );
			end;
		end;

		-- Add the fifth icon to this object  (this requires the icons have been pre-established )
		if ( len( isnull( @Icon5_Name, '' )) > 0 ) 
		begin
			-- Get the Icon ID for this icon
			select @IconID = IconID from SobekCM_Icon where Icon_Name = @Icon5_Name;

			-- Tie this item to this icon
			if ( ISNULL(@IconID,-1) > 0 )
			begin
				insert into SobekCM_Item_Icons ( ItemID, IconID, [Sequence] )
				values ( @ItemID, @IconID, 5 );
			end;
		end;

		-- Clear all links to aggregations
		delete from SobekCM_Item_Aggregation_Item_Link where ItemID = @ItemID;

		-- Add all of the aggregations
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode1;
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode2;
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode3;
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode4;
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode5;
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode6;
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode7;
		exec SobekCM_Save_Item_Item_Aggregation_Link @ItemID, @AggregationCode8;
		
		-- Create one string of all the aggregation codes
		declare @aggregationCodes varchar(100);
		set @aggregationCodes = rtrim(isnull(@AggregationCode1,'') + ' ' + isnull(@AggregationCode2,'') + ' ' + isnull(@AggregationCode3,'') + ' ' + isnull(@AggregationCode4,'') + ' ' + isnull(@AggregationCode5,'') + ' ' + isnull(@AggregationCode6,'') + ' ' + isnull(@AggregationCode7,'') + ' ' + isnull(@AggregationCode8,''));
	
		-- Update matching items to have the aggregation codes value
		update SobekCM_Item set AggregationCodes = @aggregationCodes where ItemID=@ItemID;

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
		
		-- Clear the links to all existing viewers
		delete from SobekCM_Item_Viewers where ItemID=@ItemID;
		
		-- Add the first viewer information
		if ( @Viewer1_TypeID > 0 )
		begin
			-- Insert this viewer information
			insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
			values ( @ItemID, @Viewer1_TypeID, @Viewer1_Attribute, @Viewer1_Label );
		end;
		
		-- Add the second viewer information
		if ( @Viewer2_TypeID > 0 )
		begin
			-- Insert this viewer information
			insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
			values ( @ItemID, @Viewer2_TypeID, @Viewer2_Attribute, @Viewer2_Label );
		end;
		
		-- Add the third viewer information
		if ( @Viewer3_TypeID > 0 )
		begin
			-- Insert this viewer information
			insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
			values ( @ItemID, @Viewer3_TypeID, @Viewer3_Attribute, @Viewer3_Label );
		end;
		
		-- Add the fourth viewer information
		if ( @Viewer4_TypeID > 0 )
		begin
			-- Insert this viewer information
			insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
			values ( @ItemID, @Viewer4_TypeID, @Viewer4_Attribute, @Viewer4_Label );
		end;
		
		-- Add the fifth viewer information
		if ( @Viewer5_TypeID > 0 )
		begin
			-- Insert this viewer information
			insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
			values ( @ItemID, @Viewer5_TypeID, @Viewer5_Attribute, @Viewer5_Label );
		end;
		
		-- Add the first viewer information
		if ( @Viewer6_TypeID > 0 )
		begin
			-- Insert this viewer information
			insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
			values ( @ItemID, @Viewer6_TypeID, @Viewer6_Attribute, @Viewer6_Label );
		end;

		-- Add the workhistory for this item being loaded
		if ( @Online_Submit = 'true' )
		begin
			-- Add progress for online submission completed
			insert into Tracking_Progress ( ItemID, WorkFlowID, DateCompleted, WorkPerformedBy, ProgressNote, WorkingFilePath )
			values ( @itemid, 29, getdate(), @user, @usernotes, '' );
		end
		else
		begin  
			-- Add progress for bulk loaded into the system through the Builder
			insert into Tracking_Progress ( ItemID, WorkFlowID, DateCompleted, WorkPerformedBy, ProgressNote, WorkingFilePath )
			values ( @itemid, 40, getdate(), @user, @usernotes, '' );	
		end;		

		-- Is this non-dark and pulic?
		if (( @Dark = 'false' ) and ( @IP_Restriction_Mask >= 0 ))
		begin
			update SobekCM_Item 
			set MadePublicDate = getdate()
			where ItemID=@ItemID;
		end;
		
		-- Link this to the user?
		if ( @UserID_To_Link >= 1 )
		begin
			-- Link this user to the bibid, if not already linked
			if (( select COUNT(*) from mySobek_User_Bib_Link where UserID=@UserID_To_Link and GroupID = @groupid ) = 0 )
			begin
				insert into mySobek_User_Bib_Link ( UserID, GroupID )
				values ( @UserID_To_Link, @groupid );
			end;
			
			-- First, see if this user already has a folder named 'Submitted Items'
			declare @userfolderid int
			if (( select count(*) from mySobek_User_Folder where UserID=@UserID_To_Link and FolderName='Submitted Items') > 0 )
			begin
				-- Get the existing folder id
				select @userfolderid = UserFolderID from mySobek_User_Folder where UserID=@UserID_To_Link and FolderName='Submitted Items';
			end
			else
			begin
				-- Add this folder
				insert into mySobek_User_Folder ( UserID, FolderName, isPublic )
				values ( @UserID_To_Link, 'Submitted Items', 'false' );

				-- Get the new id
				select @userfolderid = @@identity;
			end;
			
			-- Add a new link then
			insert into mySobek_User_Item( UserFolderID, ItemID, ItemOrder, UserNotes, DateAdded )
			values ( @userfolderid, @itemid, 1, '', getdate() );
			
			-- Also link using the newer system, which links for statistical reporting, etc..
			-- This will likely replace the 'submitted items' folder technique from above
			insert into mySobek_User_Item_Link( UserID, ItemID, RelationshipID )
			values ( @UserID_To_Link, @ItemID, 1 );
		
		end;
	end;

commit transaction;
GO

ALTER PROCEDURE [dbo].[SobekCM_Set_Item_Visibility] 
	@ItemID int,
	@IpRestrictionMask smallint,
	@DarkFlag bit,
	@EmbargoDate datetime,
	@User varchar(255)
AS 
BEGIN

	-- Build the note text and value
	declare @noteText varchar(200);
	set @noteText = '';

	-- Set the embargo date
	if ( @EmbargoDate is null )
	begin
		if ( exists ( select 1 from Tracking_Item where ItemID=@ItemID and EmbargoEnd is not null ))
		begin
			update Tracking_Item set EmbargoEnd=null where ItemID=@ItemID;

			set @noteText = 'Embargo date removed.  ';
		end;
	end
	else
	begin
		if ( exists ( select 1 from Tracking_Item where ItemID=@ItemID ))
		begin
			update Tracking_Item set EmbargoEnd=@EmbargoDate where ItemID=@ItemID;
		end
		else
		begin
			insert into Tracking_Item ( ItemID, Original_EmbargoEnd, EmbargoEnd )
			values ( @ItemID, @EmbargoDate, @EmbargoDate );
		end;

		set @noteText = 'Embargo date of ' + convert(varchar(20), @EmbargoDate, 102) + '.  ';
	end;

	-- Set the workflow id
	declare @workflowId int;
	set @workflowId = 34;
	if ( @IpRestrictionMask < 0 )
		set @workflowId = 35;
	if ( @IpRestrictionMask < 0 )
		set @workflowId = 36;
	if ( @DarkFlag = 'true' )
	begin
		set @workflowId = 35;
		set @noteText = @noteText + 'Item made dark.';
	end;

	-- Update the main item table ( and set for the builder to review this)
	update SobekCM_Item 
	set IP_Restriction_Mask = @IpRestrictionMask, Dark = @DarkFlag, AdditionalWorkNeeded = 'true' 
	where ItemID=@ItemID;

	insert into Tracking_Progress ( ItemID, WorkFlowID, DateCompleted, WorkPerformedBy, ProgressNote, DateStarted )
	values ( @ItemID, @workflowId, getdate(), @User, @noteText, getdate() );

	-- If this is being made public, set the public data
	if (( @DarkFlag = 'false' ) and ( @IpRestrictionMask >= 0 ))
	begin
		update SobekCM_Item 
		set MadePublicDate = coalesce(MadePublicDate, getdate())
		where ItemID=@ItemID;
	end;
END;
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
	@Viewer1_TypeID int,
	@Viewer1_Label nvarchar(50),
	@Viewer1_Attribute nvarchar(250),
	@Viewer2_TypeID int,
	@Viewer2_Label nvarchar(50),
	@Viewer2_Attribute nvarchar(250),
	@Viewer3_TypeID int,
	@Viewer3_Label nvarchar(50),
	@Viewer3_Attribute nvarchar(250),
	@Viewer4_TypeID int,
	@Viewer4_Label nvarchar(50),
	@Viewer4_Attribute nvarchar(250),
	@Viewer5_TypeID int,
	@Viewer5_Label nvarchar(50),
	@Viewer5_Attribute nvarchar(250),
	@Viewer6_TypeID int,
	@Viewer6_Label nvarchar(50),
	@Viewer6_Attribute nvarchar(250),
	@Left_To_Right bit
AS
begin transaction

	--Update the main item
	update SobekCM_Item
	set TextSearchable = @TextSearchable, Deleted = 0, MainThumbnail=@MainThumbnail,
		MainJPEG=@MainJPEG, CheckoutRequired=@CheckoutRequired, IP_Restriction_Mask=@IP_Restriction_Mask,
		Dark=@Dark_Flag, Born_Digital=@Born_Digital, Disposition_Advice=@Disposition_Advice,
		Material_Received_Date=@Material_Received_Date, Material_Recd_Date_Estimated=@Material_Recd_Date_Estimated,
		Tracking_Box=@Tracking_Box, Disposition_Advice_Notes = @Disposition_Advice_Notes, Left_To_Right=@Left_To_Right
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
		if ( ISNULL(@IconID,-1) > 0 )
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
		if ( ISNULL(@IconID,-1) > 0 )
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
		if ( ISNULL(@IconID,-1) > 0 )
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
		if ( ISNULL(@IconID,-1) > 0 )
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
	
	-- Clear the links to all existing viewers
	delete from SobekCM_Item_Viewers where ItemID=@ItemID
	
	-- Add the first viewer information
	if ( @Viewer1_TypeID > 0 )
	begin
		-- Insert this viewer information
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
		values ( @ItemID, @Viewer1_TypeID, @Viewer1_Attribute, @Viewer1_Label )
	end
	
	-- Add the second viewer information
	if ( @Viewer2_TypeID > 0 )
	begin
		-- Insert this viewer information
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
		values ( @ItemID, @Viewer2_TypeID, @Viewer2_Attribute, @Viewer2_Label )
	end
	
	-- Add the third viewer information
	if ( @Viewer3_TypeID > 0 )
	begin
		-- Insert this viewer information
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
		values ( @ItemID, @Viewer3_TypeID, @Viewer3_Attribute, @Viewer3_Label )
	end
	
	-- Add the fourth viewer information
	if ( @Viewer4_TypeID > 0 )
	begin
		-- Insert this viewer information
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
		values ( @ItemID, @Viewer4_TypeID, @Viewer4_Attribute, @Viewer4_Label )
	end
	
	-- Add the fifth viewer information
	if ( @Viewer5_TypeID > 0 )
	begin
		-- Insert this viewer information
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
		values ( @ItemID, @Viewer5_TypeID, @Viewer5_Attribute, @Viewer5_Label )
	end
	
	-- Add the first viewer information
	if ( @Viewer6_TypeID > 0 )
	begin
		-- Insert this viewer information
		insert into SobekCM_Item_Viewers ( ItemID, ItemViewTypeID, Attribute, Label )
		values ( @ItemID, @Viewer6_TypeID, @Viewer6_Attribute, @Viewer6_Label )
	end

	-- If this is being made public, set the public data
	if (( @Dark_Flag = 'false' ) and ( @IP_Restriction_Mask >= 0 ))
	begin
		update SobekCM_Item 
		set MadePublicDate = coalesce(MadePublicDate, getdate())
		where ItemID=@ItemID;
	end;

commit transaction
GO


/****** Object:  StoredProcedure [dbo].[SobekCM_Builder_Get_Minimum_Item_Information]    Script Date: 12/20/2013 05:43:36 ******/
ALTER PROCEDURE [dbo].[SobekCM_Builder_Get_Minimum_Item_Information]
	@bibid varchar(10),
	@vid varchar(5)
AS
begin

	-- No need to perform any locks here.  A slightly dirty read won't hurt much
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	-- Only continue if there is ONE match
	if (( select COUNT(*) from SobekCM_Item I, SobekCM_Item_Group G where I.GroupID = G.GroupID and G.BibID = @BibID and I.VID = @VID ) = 1 )
	begin
		-- Get the itemid
		declare @ItemID int;
		select @ItemID = ItemID from SobekCM_Item I, SobekCM_Item_Group G where I.GroupID = G.GroupID and G.BibID = @BibID and I.VID = @VID;

		-- Get the item id and mainthumbnail
		select I.ItemID, I.MainThumbnail, I.IP_Restriction_Mask, I.Born_Digital, G.ItemCount, I.Dark, I.MadePublicDate
		from SobekCM_Item I, SobekCM_Item_Group G
		where ( I.VID = @vid )
		  and ( G.BibID = @bibid )
		  and ( I.GroupID = G.GroupID );

		-- Get the links to the aggregations
		select A.Code, A.Name, A.[Type]
		from SobekCM_Item_Aggregation_Item_Link L, SobekCM_Item_Aggregation A
		where ( L.ItemID = @itemid )
		  and ( L.AggregationID = A.AggregationID );
	 
		-- Return the icons for this item
		select Icon_URL, Link, Icon_Name, I.Title
		from SobekCM_Icon I, SobekCM_Item_Icons L
		where ( L.IconID = I.IconID ) 
		  and ( L.ItemID = @ItemID )
		order by Sequence;
			  
		-- Return any web skin restrictions
		select S.WebSkinCode
		from SobekCM_Item_Group_Web_Skin_Link L, SobekCM_Item I, SobekCM_Web_Skin S
		where ( L.GroupID = I.GroupID )
		  and ( L.WebSkinID = S.WebSkinID )
		  and ( I.ItemID = @ItemID )
		order by L.Sequence;
		
	end;

end;
GO


-- Pull any additional item details before showing this item
ALTER PROCEDURE [dbo].[SobekCM_Get_Item_Details2]
	@BibID varchar(10),
	@VID varchar(5)
AS
BEGIN

	-- No need to perform any locks here
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- Does this BIbID exist?
	if (not exists ( select 1 from SobekCM_Item_Group where BibID = @BibID ))
	begin
		select 'INVALID BIBID' as ErrorMsg, '' as BibID, '' as VID;
		return;
	end;

	-- Was this for one item within a group?
	if ( LEN( ISNULL(@VID,'')) > 0 )
	begin	

		-- Does this VID exist in that stored procedure?
		if ( not exists ( select 1 from SobekCM_Item I, SobekCM_Item_Group G where I.GroupID = G.GroupID and G.BibID=@BibID and I.VID = @VID ))
		begin

			select top 1 'INVALID VID' as ErrorMsg, @BibID as BibID, VID
			from SobekCM_Item I, SobekCM_Item_Group G
			where I.GroupID = G.GroupID 
			  and G.BibID = @BibID
			order by VID;

			return;
		end;
	
		-- Only continue if there is ONE match
		if (( select COUNT(*) from SobekCM_Item I, SobekCM_Item_Group G where I.GroupID = G.GroupID and G.BibID = @BibID and I.VID = @VID ) = 1 )
		begin
			-- Get the itemid
			declare @ItemID int;
			select @ItemID = ItemID from SobekCM_Item I, SobekCM_Item_Group G where I.GroupID = G.GroupID and G.BibID = @BibID and I.VID = @VID;

			-- Return any descriptive tags
			select U.FirstName, U.NickName, U.LastName, G.BibID, I.VID, T.Description_Tag, T.TagID, T.Date_Modified, U.UserID, isnull([PageCount], 0) as Pages, ExposeFullTextForHarvesting
			from mySobek_User U, mySobek_User_Description_Tags T, SobekCM_Item I, SobekCM_Item_Group G
			where ( T.ItemID = @ItemID )
			  and ( I.ItemID = T.ItemID )
			  and ( I.GroupID = G.GroupID )
			  and ( T.UserID = U.UserID );
			
			-- Return the aggregation information linked to this item
			select A.Code, A.Name, A.ShortName, A.[Type], A.Map_Search, A.DisplayOptions, A.Items_Can_Be_Described, L.impliedLink, A.Hidden, A.isActive, ISNULL(A.External_Link,'') as External_Link
			from SobekCM_Item_Aggregation_Item_Link L, SobekCM_Item_Aggregation A
			where ( L.ItemID = @ItemID )
			  and ( A.AggregationID = L.AggregationID );
		  
			-- Return information about the actual item/group
			select G.BibID, I.VID, G.File_Location, G.SuppressEndeca, 'true' as [Public], I.IP_Restriction_Mask, G.GroupID, I.ItemID, I.CheckoutRequired, Total_Volumes=(select COUNT(*) from SobekCM_Item J where G.GroupID = J.GroupID ),
				isnull(I.Level1_Text, '') as Level1_Text, isnull( I.Level1_Index, 0 ) as Level1_Index, 
				isnull(I.Level2_Text, '') as Level2_Text, isnull( I.Level2_Index, 0 ) as Level2_Index, 
				isnull(I.Level3_Text, '') as Level3_Text, isnull( I.Level3_Index, 0 ) as Level3_Index,
				G.GroupTitle, I.TextSearchable, Comments=isnull(I.Internal_Comments,''), Dark, G.[Type],
				I.Title, I.Publisher, I.Author, I.Donor, I.PubDate, G.ALEPH_Number, G.OCLC_Number, I.Born_Digital, 
				I.Disposition_Advice, I.Material_Received_Date, I.Material_Recd_Date_Estimated, I.Tracking_Box, I.Disposition_Advice_Notes, 
				I.Left_To_Right, I.Disposition_Notes, G.Track_By_Month, G.Large_Format, G.Never_Overlay_Record, I.CreateDate, I.SortDate, 
				G.Primary_Identifier_Type, G.Primary_Identifier, G.[Type] as GroupType, coalesce(I.MainThumbnail,'') as MainThumbnail,
				T.EmbargoEnd, coalesce(T.UMI,'') as UMI, T.Original_EmbargoEnd, coalesce(T.Original_AccessCode,'') as Original_AccessCode,
				I.CitationSet, I.MadePublicDate
			from SobekCM_Item as I inner join
				 SobekCM_Item_Group as G on G.GroupID=I.GroupID left outer join
				 Tracking_Item as T on T.ItemID=I.ItemID
			where ( I.ItemID = @ItemID );
		  
			-- Return any ticklers associated with this item
			select MetadataValue
			from SobekCM_Metadata_Unique_Search_Table M, SobekCM_Metadata_Unique_Link L
			where ( L.ItemID = @ItemID ) 
			  and ( L.MetadataID = M.MetadataID )
			  and ( M.MetadataTypeID = 20 );
			
			-- Return the viewers for this item
			select T.ViewType, V.Attribute, V.Label, coalesce(V.MenuOrder, T.MenuOrder) as MenuOrder, V.Exclude, coalesce(V.OrderOverride, T.[Order])
			from SobekCM_Item_Viewers V, SobekCM_Item_Viewer_Types T
			where ( V.ItemID = @ItemID )
			  and ( V.ItemViewTypeID = T.ItemViewTypeID )
			group by T.ViewType, V.Attribute, V.Label, coalesce(V.MenuOrder, T.MenuOrder), V.Exclude, coalesce(V.OrderOverride, T.[Order])
			order by coalesce(V.OrderOverride, T.[Order]) ASC;
				
			-- Return the icons for this item
			select Icon_URL, Link, Icon_Name, I.Title
			from SobekCM_Icon I, SobekCM_Item_Icons L
			where ( L.IconID = I.IconID ) 
			  and ( L.ItemID = @ItemID )
			order by Sequence;
			  
			-- Return any web skin restrictions
			select S.WebSkinCode
			from SobekCM_Item_Group_Web_Skin_Link L, SobekCM_Item I, SobekCM_Web_Skin S
			where ( L.GroupID = I.GroupID )
			  and ( L.WebSkinID = S.WebSkinID )
			  and ( I.ItemID = @ItemID )
			order by L.Sequence;

			-- Return all of the key/value pairs of settings
			select Setting_Key, Setting_Value
			from SobekCM_Item_Settings 
			where ItemID=@ItemID;
		end;		
	end
	else
	begin
		-- Return the aggregation information linked to this item
		select GroupTitle, BibID, G.[Type], G.File_Location, isnull(AGGS.Code,'') AS Code, G.GroupID, isnull(GroupThumbnail,'') as Thumbnail, G.Track_By_Month, G.Large_Format, G.Never_Overlay_Record, G.Primary_Identifier_Type, G.Primary_Identifier
		from SobekCM_Item_Group AS G LEFT JOIN
			 ( select distinct(A.Code),  G2.GroupID
			   from SobekCM_Item_Group G2, SobekCM_Item IL, SobekCM_Item_Aggregation_Item_Link L, SobekCM_Item_Aggregation A
		       where IL.ItemID=L.ItemID 
		         and A.AggregationID=L.AggregationID
		         and G2.GroupID=IL.GroupID
		         and G2.BibID=@BibID
		         and G2.Deleted='false'
		       group by A.Code, G2.GroupID ) AS AGGS ON G.GroupID=AGGS.GroupID
		where ( G.BibID = @BibID )
		  and ( G.Deleted = 'false' );

		-- Get list of icon ids
		select distinct(IconID)
		into #TEMP_ICON
		from SobekCM_Item_Icons II, SobekCM_Item It, SobekCM_Item_Group G
		where ( It.GroupID = G.GroupID )
			and ( G.BibID = @bibid )
			and ( It.Deleted = 0 )
			and ( II.ItemID = It.ItemID )
		group by IconID;

		-- Return icons
		select Icon_URL, Link, Icon_Name, Title
		from SobekCM_Icon I, (	select distinct(IconID)
								from SobekCM_Item_Icons II, SobekCM_Item It, SobekCM_Item_Group G
								where ( It.GroupID = G.GroupID )
							 	  and ( G.BibID = @bibid )
								  and ( It.Deleted = 0 )
								  and ( II.ItemID = It.ItemID )
								group by IconID) AS T
		where ( T.IconID = I.IconID );
		
		-- Return any web skin restrictions
		select S.WebSkinCode
		from SobekCM_Item_Group_Web_Skin_Link L, SobekCM_Item_Group G, SobekCM_Web_Skin S
		where ( L.GroupID = G.GroupID )
		  and ( L.WebSkinID = S.WebSkinID )
		  and ( G.BibID = @BibID )
		order by L.Sequence;
		
		-- Get the distinct list of all aggregations linked to this item
		select distinct( Code )
		from SobekCM_Item_Aggregation A, SobekCM_Item_Aggregation_Item_Link L, SobekCM_Item_Group G, SobekCM_Item I
		where ( I.ItemID = L.ItemID )
		  and ( I.GroupID = G.GroupID )
		  and ( G.BibID = @BibID )
		  and ( L.AggregationID = A.AggregationID );		
	end;
		
	-- Get the list of related item groups
	select B.BibID, B.GroupTitle, R.Relationship_A_to_B AS Relationship
	from SobekCM_Item_Group A, SobekCM_Item_Group_Relationship R, SobekCM_Item_Group B
	where ( A.BibID = @bibid ) 
	  and ( R.GroupA = A.GroupID )
	  and ( R.GroupB = B.GroupID )
	union
	select A.BibID, A.GroupTitle, R.Relationship_B_to_A AS Relationship
	from SobekCM_Item_Group A, SobekCM_Item_Group_Relationship R, SobekCM_Item_Group B
	where ( B.BibID = @bibid ) 
	  and ( R.GroupB = B.GroupID )
	  and ( R.GroupA = A.GroupID );
		  
END;
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

	-- Determine when the last item was made available and if the new browse should display
	declare @last_added_date datetime;
	set @last_added_date = ( select MAX(MadePublicDate) from SobekCM_Item I, SobekCM_Item_Aggregation_Item_Link L where I.ItemID=L.ItemID and I.Dark='false' and I.IP_Restriction_Mask >= 0 and L.AggregationID=@aggregationid);

	declare @has_new_items bit;
	set @has_new_items = 'false';
	if ( coalesce(@last_added_date, '1/1/1900' ) > DATEADD(day, -14, getdate()))
	begin
		set @has_new_items='true';
	end;
	
	-- Return information about this aggregation
	select AggregationID, Code, [Name], coalesce(ShortName,[Name]) AS ShortName, [Type], isActive, Hidden, @has_new_items as HasNewItems,
	   ContactEmail, DefaultInterface, [Description], Map_Display, Map_Search, OAI_Flag, OAI_Metadata, DisplayOptions, coalesce(@last_added_date, '1/1/1900' ) as LastItemAdded, 
	   Can_Browse_Items, Items_Can_Be_Described, External_Link, T.ThematicHeadingID, LanguageVariants, ThemeName, GroupResults
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

	-- Return all of the key/value pairs of settings
	select Setting_Key, Setting_Value
	from SobekCM_Item_Aggregation_Settings 
	where AggregationID=@aggregationid;

	-- Get the list of result views for this aggregation
	select T.ResultType, A.DefaultView
	from SobekCM_Item_Aggregation_Result_Views A, SobekCM_Item_Aggregation_Result_Types T
	where A.AggregationID=@aggregationid
	  and A.ItemAggregationResultTypeID=T.ItemAggregationResultTypeID
	order by T.DefaultOrder ASC;
	
	-- Get the fields for the facets
	select F.MetadataTypeID, coalesce(F.OverrideFacetTerm, T.FacetTerm) as FacetTerm, T.SobekCode, T.SolrCode_Facets
	from SobekCM_Item_Aggregation_Facets F, SobekCM_Metadata_Types T
	where ( F.AggregationID = @aggregationid ) 
	  and ( F.MetadataTypeID = T.MetadataTypeID )
	order by FacetOrder;

	-- Get the fields for the result fields
	select R.ResultType, F.MetadataTypeID, coalesce(F.OverrideDisplayTerm, T.DisplayTerm) as DisplayTerm, T.SobekCode, T.SolrCode_Display, F.DisplayOrder
	from SobekCM_Item_Aggregation_Result_Fields F, SobekCM_Metadata_Types T, SobekCM_Item_Aggregation_Result_Views A, SobekCM_Item_Aggregation_Result_Types R
	where ( A.AggregationID = @aggregationid ) 
      and ( A.ItemAggregationResultTypeID=R.ItemAggregationResultTypeID )
	  and ( A.ItemAggregationResultID = F.ItemAggregationResultID )
	  and ( F.MetadataTypeID = T.MetadataTypeID )
	order by R.ResultType, DisplayOrder;
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

	-- Determine when the last item was made available and if the new browse should display
	declare @last_added_date datetime;
	set @last_added_date = ( select MAX(MadePublicDate) from SobekCM_Item I where I.Dark='false' and I.IP_Restriction_Mask >= 0 and I.IncludeInAll='true');

	declare @has_new_items bit;
	set @has_new_items = 'false';
	if ( coalesce(@last_added_date, '1/1/1900' ) > DATEADD(day, -14, getdate()))
	begin
		set @has_new_items='true';
	end;
	
	-- Return information about this aggregation
	select AggregationID, Code, [Name], isnull(ShortName,[Name]) AS ShortName, [Type], isActive, Hidden, @has_new_items as HasNewItems,
	   ContactEmail, DefaultInterface, [Description], Map_Display, Map_Search, OAI_Flag, OAI_Metadata, DisplayOptions, 
	  coalesce(@last_added_date, '1/1/1900' ) as LastItemAdded, Can_Browse_Items, Items_Can_Be_Described, External_Link, GroupResults
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

	-- Return all of the key/value pairs of settings
	select Setting_Key, Setting_Value
	from SobekCM_Item_Aggregation_Settings 
	where AggregationID=@aggregationid;

	-- Get the list of result views for this aggregation
	select T.ResultType, A.DefaultView
	from SobekCM_Item_Aggregation_Result_Views A, SobekCM_Item_Aggregation_Result_Types T
	where A.AggregationID=@aggregationid
	  and A.ItemAggregationResultTypeID=T.ItemAggregationResultTypeID
	order by T.DefaultOrder ASC;

	-- Get the fields for the facets
	select F.MetadataTypeID, coalesce(F.OverrideFacetTerm, T.FacetTerm) as FacetTerm, T.SobekCode, T.SolrCode_Facets
	from SobekCM_Item_Aggregation_Facets F, SobekCM_Metadata_Types T
	where ( F.AggregationID = @aggregationid ) 
	  and ( F.MetadataTypeID = T.MetadataTypeID )
	order by FacetOrder;

	-- Get the fields for the result fields
	select R.ResultType, F.MetadataTypeID, coalesce(F.OverrideDisplayTerm, T.DisplayTerm) as DisplayTerm, T.SobekCode, T.SolrCode_Display, F.DisplayOrder
	from SobekCM_Item_Aggregation_Result_Fields F, SobekCM_Metadata_Types T, SobekCM_Item_Aggregation_Result_Views A, SobekCM_Item_Aggregation_Result_Types R
	where ( A.AggregationID = @aggregationid ) 
      and ( A.ItemAggregationResultTypeID=R.ItemAggregationResultTypeID )
	  and ( A.ItemAggregationResultID = F.ItemAggregationResultID )
	  and ( F.MetadataTypeID = T.MetadataTypeID )
	order by R.ResultType, DisplayOrder;

end;
GO



-- Stored procedure to save the basic item aggregation information
ALTER PROCEDURE [dbo].[SobekCM_Save_Item_Aggregation]
	@aggregationid int,
	@code varchar(20),
	@name nvarchar(255),
	@shortname nvarchar(100),
	@description nvarchar(1000),
	@thematicHeadingId int,
	@type varchar(50),
	@isactive bit,
	@hidden bit,
	@display_options varchar(10),
	@map_search tinyint,
	@map_display tinyint,
	@oai_flag bit,
	@oai_metadata nvarchar(2000),
	@contactemail varchar(255),
	@defaultinterface varchar(10),
	@externallink nvarchar(255),
	@parentid int,
	@username varchar(100),
	@languageVariants varchar(500),
	@groupResults bit,
	@newaggregationid int output
AS
begin transaction

	-- Set flag to see if this was basically just created (either new or undeleted)
	declare @newly_added bit;
	set @newly_added = 'false';

   -- If the aggregation id is less than 1 then this is for a new aggregation
   if ((@aggregationid  < 1 ) and (( select COUNT(*) from SobekCM_Item_Aggregation where Code=@code ) = 0 ))
   begin

		-- Insert a new row
		insert into SobekCM_Item_Aggregation(Code, [Name], Shortname, Description, ThematicHeadingID, [Type], isActive, Hidden, DisplayOptions, Map_Search, Map_Display, OAI_Flag, OAI_Metadata, ContactEmail, HasNewItems, DefaultInterface, External_Link, DateAdded, LanguageVariants, GroupResults )
		values(@code, @name, @shortname, @description, @thematicHeadingId, @type, @isActive, @hidden, @display_options, @map_search, @map_display, @oai_flag, @oai_metadata, @contactemail, 'false', @defaultinterface, @externallink, GETDATE(), @languageVariants, @groupResults );

		-- Get the primary key
		set @newaggregationid = @@identity;
       
		-- insert the CREATED milestone
		insert into [SobekCM_Item_Aggregation_Milestones] ( AggregationID, Milestone, MilestoneDate, MilestoneUser )
		values ( @newaggregationid, 'Created', getdate(), @username );

		-- Since this was a brand new, set flag
		set @newly_added='true';
   end
   else
   begin

	  -- Add special code to indicate if this aggregation was undeleted
	  if ( exists ( select 1 from SobekCM_Item_Aggregation where Code=@Code and Deleted='true'))
	  begin
		declare @deletedid int;
		set @deletedid = ( select aggregationid from SobekCM_Item_Aggregation where Code=@Code );

		-- insert the UNDELETED milestone
		insert into [SobekCM_Item_Aggregation_Milestones] ( AggregationID, Milestone, MilestoneDate, MilestoneUser )
		values ( @deletedid, 'Created (undeleted as previously existed)', getdate(), @username );

		-- Since this was undeleted, let's make sure this collection isn't linked 
		-- to any parent collections
		delete from SobekCM_Item_Aggregation_Hierarchy
		where ChildID=@deletedid;

		-- Since this was UNDELETED, set flag
		set @newly_added='true';
	  end;

      -- Update the existing row
      update SobekCM_Item_Aggregation
      set  
		Code = @code,
		[Name] = @name,
		ShortName = @shortname,
		[Description] = @description,
		ThematicHeadingID = @thematicHeadingID,
		[Type] = @type,
		isActive = @isactive,
		Hidden = @hidden,
		DisplayOptions = @display_options,
		Map_Search = @map_search,
		Map_Display = @map_display,
		OAI_Flag = @oai_flag,
		OAI_Metadata = @oai_metadata,
		ContactEmail = @contactemail,
		DefaultInterface = @defaultinterface,
		External_Link = @externallink,
		Deleted = 'false',
		DeleteDate = null,
		LanguageVariants = @languageVariants,
		GroupResults = @groupResults
      where AggregationID = @aggregationid or Code = @code;

      -- Set the return value to the existing id
      set @newaggregationid = ( select aggregationid from SobekCM_Item_Aggregation where Code=@Code );

   end;



	-- Was a parent id provided
	if ( isnull(@parentid, -1 ) > 0 )
	begin
		-- Now, see if the link to the parent exists
		if (( select count(*) from SobekCM_Item_Aggregation_Hierarchy H where H.ParentID = @parentid and H.ChildID = @newaggregationid ) < 1 )
		begin			
			insert into SobekCM_Item_Aggregation_Hierarchy ( ParentID, ChildID )
			values ( @parentid, @newaggregationid );
		end;
	end;

	-- If this was newly added (new or undeleted), ensure permissions and other things copied over from parent
	if ( @newly_added = 'true' )
	begin
		-- There should ALWAYS be a parent for new collections, even if it is the ALL collection
		if ( isnull(@parentid, -1 ) < 0 )
		begin
			set @parentid = ( select AggregationID from SobekCM_Item_Aggregation where Code='ALL' );
		end;

		-- Since this is NEW, set the group results based on the parent
		update SobekCM_Item_Aggregation
		set GroupResults = ( select GroupResults from SobekCM_Item_Aggregation where AggregationID=@parentid )
		where AggregationID=@newaggregationid;

			-- Add individual user permissions first
			insert into mySobek_User_Edit_Aggregation ( UserID, AggregationID, CanSelect, CanEditItems, 
				IsCurator, IsAdmin, CanEditMetadata, CanEditBehaviors, CanPerformQc, 
				CanUploadFiles, CanChangeVisibility, CanDelete )
			select UserID, @newaggregationid, CanSelect, CanEditItems, 
				IsCurator, IsAdmin, CanEditMetadata, CanEditBehaviors, CanPerformQc, 
				CanUploadFiles, CanChangeVisibility, CanDelete
			from mySobek_User_Edit_Aggregation A
			where ( AggregationID = @parentid )
			  and ( not exists ( select * from mySobek_User_Edit_Aggregation L where L.UserID=A.UserID and L.AggregationID=@newaggregationid ))
			  and (    ( CanEditMetadata='true' ) 
	                or ( CanEditBehaviors='true' )
	                or ( CanPerformQc='true' )
	                or ( CanUploadFiles='true' )
	                or ( CanChangeVisibility='true' )
	                or ( IsCurator='true' )
	                or ( IsAdmin='true' ));

			-- Add user group permissions next 
			insert into mySobek_User_Group_Edit_Aggregation ( UserGroupID, AggregationID, CanSelect, CanEditItems, 
				IsCurator, IsAdmin, CanEditMetadata, CanEditBehaviors, CanPerformQc, 
				CanUploadFiles, CanChangeVisibility, CanDelete )
			select UserGroupID, @newaggregationid, CanSelect, CanEditItems, 
				IsCurator, IsAdmin, CanEditMetadata, CanEditBehaviors, CanPerformQc, 
				CanUploadFiles, CanChangeVisibility, CanDelete
			from mySobek_User_Group_Edit_Aggregation A
			where ( AggregationID = @parentid )
			  and ( not exists ( select * from mySobek_User_Group_Edit_Aggregation L where L.UserGroupID=A.UserGroupID and L.AggregationID=@newaggregationid ))
			  and (    ( CanEditMetadata='true' ) 
	                or ( CanEditBehaviors='true' )
	                or ( CanPerformQc='true' )
	                or ( CanUploadFiles='true' )
	                or ( CanChangeVisibility='true' )
	                or ( IsCurator='true' )
	                or ( IsAdmin='true' ));

			-- Copy over the facet fields
			insert into SobekCM_Item_Aggregation_Facets ( AggregationID, MetadataTypeID, OverrideFacetTerm, FacetOrder, FacetOptions )
			select @newaggregationid, MetadataTypeID, OverrideFacetTerm, FacetOrder, FacetOptions
			from SobekCM_Item_Aggregation_Facets
			where AggregationID=@parentid;

			-- Copy over the results views from the parent
			insert into SobekCM_Item_Aggregation_Result_Views ( AggregationID, ItemAggregationResultTypeID, DefaultView )
			select @newaggregationid, ItemAggregationResultTypeID, DefaultView
			from SobekCM_Item_Aggregation_Result_Views
			where AggregationID=@parentid;

			-- Now, add the result view fields from the parent
			insert into SobekCM_Item_Aggregation_Result_Fields ( ItemAggregationResultID, MetadataTypeID, OverrideDisplayTerm, DisplayOrder, DisplayOptions )
			select V2.ItemAggregationResultID, F1.MetadataTypeID, F1.OverrideDisplayTerm, F1.DisplayOrder, F1.DisplayOptions
			from SobekCM_Item_Aggregation_Result_Views V1, SobekCM_Item_Aggregation_Result_Fields F1, SobekCM_Item_Aggregation_Result_Views V2
			where V1.ItemAggregationResultID=F1.ItemAggregationResultID
			  and V1.AggregationID=@parentid
			  and V2.ItemAggregationResultTypeID=V1.ItemAggregationResultTypeID
			  and V2.AggregationID=@newaggregationid;
		end;

commit transaction;
GO
