

  insert into SobekCM_Builder_Incoming_Folders ( NetworkFolder, ErrorFolder, ProcessingFolder, Perform_Checksum_Validation, Archive_TIFF, Archive_All_Files, Allow_Deletes, Allow_Folders_No_Metadata, Allow_Metadata_Updates, FolderName, BibID_Roots_Restrictions, ModuleSetID )
  values ( '\\SOB-FILE01\ftp\ginamark\builder\', '\\SOB-FILE01\ftp\ginamark\failures\', '\\SOB-FILE01\ftp\ginamark\processing\', 'false', 'false', 'false', 'true', 'true', 'True', 'FTP Folder', '', 10 );
