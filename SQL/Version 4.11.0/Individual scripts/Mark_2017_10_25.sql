

  update SobekCM_Settings
  set Heading='Search System Settings'
  where Setting_Key in ( 'Document Solr Index URL', 'Page Solr Index URL' );
  GO

  if ( not exists ( select 1 from SobekCM_Settings where Setting_Key = 'Solr Schema' ))
  begin
	insert into SobekCM_Settings ( Setting_Key, Setting_Value, TabPage, Heading, Hidden, Reserved, Help, Options, Dimensions )
	values ( 'Solr Schema', 'Legacy', 'System / Server Settings', 'Search System Settings', 0, 2, 'Tells which SobekCM Solr schema is in use in this system.',  'Legacy|V5', null );
  end;
  GO

    if ( not exists ( select 1 from SobekCM_Settings where Setting_Key = 'Metadata Search System' ))
  begin
	insert into SobekCM_Settings ( Setting_Key, Setting_Value, TabPage, Heading, Hidden, Reserved, Help, Options, Dimensions )
	values ( 'Metadata Search System', 'Database', 'System / Server Settings', 'Search System Settings', 0, 2, 'Indicates whether to use the database for metadata searching, or the solr indexes.',  'Database|Solr', null );
  end;
  GO

  update SobekCM_Settings
  set Heading='Search Preferences'
  where TabPage='General Settings' and Heading='Search Settings';
  GO
