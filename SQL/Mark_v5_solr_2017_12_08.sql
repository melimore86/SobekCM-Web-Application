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

  update SobekCM_Metadata_Types set SolrCode='subject' where MetadataTypeID=7;
  update SobekCM_Metadata_Types set SolrCode='audience' where MetadataTypeID=9;
  update SobekCM_Metadata_Types set SolrCode='spatial_standard' where MetadataTypeID=10;
  update SobekCM_Metadata_Types set SolrCode='source' where MetadataTypeID=15;
  update SobekCM_Metadata_Types set SolrCode='holding' where MetadataTypeID=16;
  update SobekCM_Metadata_Types set SolrCode='other' where MetadataTypeID=19;
  update SobekCM_Metadata_Types set SolrCode='name_as_subject' where MetadataTypeID=27;
  update SobekCM_Metadata_Types set SolrCode='title_as_subject' where MetadataTypeID=28;
  update SobekCM_Metadata_Types set SolrCode='mime_type' where MetadataTypeID=34;
  update SobekCM_Metadata_Types set SolrCode='fullcitation' where MetadataTypeID=35;
  update SobekCM_Metadata_Types set SolrCode='tracking_box' where MetadataTypeID=36;


  update SobekCM_Metadata_Types set MetadataName=replace(MetadataName, '_', ' ') where MetadataName like 'LOM_%';
  update SobekCM_Metadata_Types set MetadataName='LOM Age Range' where MetadataName='LOM AgeRange';

  -- Also, add:
  --   lom learning time 
  --   lom resource type
  --   zt hierarchical
  --   translated title
  --   
  -- check all display fields and suppress?
