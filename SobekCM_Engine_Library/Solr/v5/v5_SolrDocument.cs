﻿using System;
using System.Collections.Generic;
using SobekCM.Resource_Object;
using SobekCM.Resource_Object.Bib_Info;
using SobekCM.Resource_Object.Solr;
using SolrNet.Attributes;

namespace SobekCM.Engine_Library.Solr.v5
{
    public class v5_SolrDocument
    {

        #region Constructors for this class 

        /// <summary> Constructor for a new instance of the v5_SolrDocument class </summary>
        public v5_SolrDocument()
        {
            // Empty (required)
        }


        /// <summary> Constructor for a new instance of the v5_SolrDocument class </summary>
        /// <param name="Digital_Object"> Digital object to create an easily indexable view object for </param>
        /// <param name="File_Location"> Location for all of the text files associated with this item </param>
        /// <remarks> Some work is done in the constructor; in particular, work that eliminates the number of times 
        /// iterations must be made through objects which may be indexed in a number of places.  
        /// This includes subject keywords, spatial information, genres, and information from the table of contents </remarks>
        public v5_SolrDocument(SobekCM_Item Digital_Object, string File_Location)
        {
            // Set the unique key
            DID = Digital_Object.BibID + ":" + Digital_Object.VID;

            // Add the administrative fields
            Aggregations = new List<string>();
            Aggregations.AddRange(Digital_Object.Behaviors.Aggregation_Code_List);
            BibID = Digital_Object.BibID;
            VID = Digital_Object.VID;

            // Get the rest of the metadata, from the item
            List<KeyValuePair<string, string>> searchTerms = new List<KeyValuePair<string, string>>();

            foreach (KeyValuePair<string, string> searchTerm in searchTerms)
            {
                switch (searchTerm.Key.ToLower())
                {
                    case "title":
                        Title = searchTerm.Value;
                        break;



                }
            }

            //// Add the main metadata fields
            //Title = Digital_Object.Bib_Info.Main_Title.ToString();
            //SortTitle = Digital_Object.Bib_Info.SortTitle;
            //if ((Digital_Object.Bib_Info.Other_Titles_Count > 0) || ((Digital_Object.Bib_Info.SeriesTitle != null) && ( !String.IsNullOrEmpty(Digital_Object.Bib_Info.SeriesTitle.Title ))))
            //AltTitle = new List<string>();
            //if (Digital_Object.Bib_Info.Other_Titles_Count > 0)
            //{
            //    foreach (Title_Info altTitle in Digital_Object.Bib_Info.Other_Titles)
            //    {
            //        AltTitle.Add(altTitle.ToString());
            //    }
            //}
            //if ((Digital_Object.Bib_Info.SeriesTitle != null) && (!String.IsNullOrEmpty(Digital_Object.Bib_Info.SeriesTitle.Title)))
            //    AltTitle.Add(Digital_Object.Bib_Info.SeriesTitle.ToString());
            //Type = Digital_Object.Bib_Info.SobekCM_Type_String;
            //if (Digital_Object.Bib_Info.Languages_Count > 0)
            //{
            //    Language = new List<string>();
            //    foreach (Language_Info language in Digital_Object.Bib_Info.Languages)
            //    {
            //        if (!String.IsNullOrEmpty(language.Language_Text))
            //            Language.Add(language.Language_Text);
            //        else if (!String.IsNullOrEmpty(language.Language_ISO_Code))
            //        {
            //            string possLanguage = language.Get_Language_By_Code(language.Language_ISO_Code);
            //            if (!String.IsNullOrEmpty(possLanguage))
            //                Language.Add(possLanguage);
            //        }
            //    }
            //}
            //if (Digital_Object.Bib_Info.Names_Count > 0)
            //{
            //    Creator = new List<string>();
            //    foreach (Name_Info thisName in Digital_Object.Bib_Info.Names)
            //    {
            //        Creator.Add(thisName.ToString(true));
            //    }
            //}
            //if (Digital_Object.Bib_Info.Publishers_Count > 0)
            //{
            //    Publisher = new List<string>();
            //    Publisher_Display = new List<string>();
            //    PubPlace = new List<string>();
            //    foreach (Publisher_Info publisher in Digital_Object.Bib_Info.Publishers)
            //    {
            //        Publisher.Add(publisher.Name);
            //        Publisher_Display.Add(publisher.ToString());
            //        if (publisher.Places_Count > 0)
            //        {
            //            foreach (Origin_Info_Place pubPlace in publisher.Places)
            //            {
            //                if ( !String.IsNullOrEmpty(pubPlace.Place_Text))
            //                    PubPlace.Add(pubPlace.Place_Text);
            //            }
            //        }
            //    }
            //}
            //if (Digital_Object.Bib_Info.Target_Audiences_Count > 0)
            //{
            //    Audience = new List<string>();
            //    foreach (TargetAudience_Info audience in Digital_Object.Bib_Info.Target_Audiences)
            //        Audience.Add(audience.Audience);
            //}
            //if (!String.IsNullOrEmpty(Digital_Object.Bib_Info.Source.Statement))
            //    Source = Digital_Object.Bib_Info.Source.Statement;
            //if (!String.IsNullOrEmpty(Digital_Object.Bib_Info.Location.Holding_Name))
            //    Holding = Digital_Object.Bib_Info.Location.Holding_Name;
            //if (Digital_Object.Bib_Info.Identifiers_Count > 0)
            //{
            //    Identifier = new List<string>();
            //    foreach( Identifier_Info identifier in Digital_Object.Bib_Info.Identifiers )
            //        Identifier.Add(identifier.ToString());
            //}
            //if (Digital_Object.Bib_Info.Notes_Count > 0)
            //{
            //    Notes = new List<string>();
            //    foreach (Note_Info thisNote in Digital_Object.Bib_Info.Notes)
            //    {
            //        Notes.Add(thisNote.Note);
            //    }
            //}
            //if (Digital_Object.Behaviors.Ticklers_Count > 0)
            //{
            //    Tickler = new List<string>();
            //    Tickler.AddRange(Digital_Object.Behaviors.Ticklers);
            //}
            //if (Digital_Object.Bib_Info.hasDonor)
            //    Donor = Digital_Object.Bib_Info.Donor.ToString();
            //if (!String.IsNullOrEmpty(Digital_Object.Bib_Info.Original_Description.Extent))
            //    Format = Digital_Object.Bib_Info.Original_Description.Extent;
            //if (Digital_Object.Bib_Info.Origin_Info.Frequencies_Count > 0)
            //{
            //    Frequency = new List<string>();
            //    foreach (Origin_Info_Frequency frequency in Digital_Object.Bib_Info.Origin_Info.Frequencies)
            //    {
            //        Frequency.Add(frequency.Term);
            //    }
            //}
            //if (Digital_Object.Bib_Info.Genres_Count > 0)
            //{
            //    Genre = new List<string>();
            //    foreach (Genre_Info thisGenre in Digital_Object.Bib_Info.Genres)
            //    {
            //        if ( !String.Equals(thisGenre.Authority, "sobekcm", StringComparison.OrdinalIgnoreCase))
            //            Genre.Add(thisGenre.ToString());
            //    }
            //}

            //// Date fields - STILL NEED TO REVIEW THIS!!

            //// Subject metadata fields ( and also same spatial information )
            //List<string> spatials = new List<string>();
            //List<Subject_Info_HierarchicalGeographic> hierarhicals = new List<Subject_Info_HierarchicalGeographic>();
            //if ( Digital_Object.Bib_Info.Subjects_Count > 0 )
            //{
            //    List<string> subjects = new List<string>();
            //    List<string> name_as_subject = new List<string>();
            //    List<string> title_as_subject = new List<string>();

            //    // Collect the types of subjects
            //    foreach (Subject_Info thisSubject in Digital_Object.Bib_Info.Subjects)
            //    {
            //        switch (thisSubject.Class_Type)
            //        {
            //            case Subject_Info_Type.Name:
            //                name_as_subject.Add(thisSubject.ToString());
            //                break;

            //             case Subject_Info_Type.TitleInfo:
            //                title_as_subject.Add(thisSubject.ToString());
            //                break;

            //             case Subject_Info_Type.Standard:
            //                subjects.Add(thisSubject.ToString());
            //                Subject_Info_Standard standardSubj = thisSubject as Subject_Info_Standard;
            //                if (standardSubj.Geographics_Count > 0)
            //                {
            //                    spatials.AddRange(standardSubj.Geographics);
            //                }
            //                break;

            //            case Subject_Info_Type.Hierarchical_Spatial:
            //                hierarhicals.Add( thisSubject as Subject_Info_HierarchicalGeographic);
            //                break;
            //        }
            //    }

            //    // Now add to this document, if present
            //    if (name_as_subject.Count > 0)
            //    {
            //        NameAsSubject = new List<string>();
            //        NameAsSubject.AddRange(name_as_subject);
            //    }
            //    if (title_as_subject.Count > 0)
            //    {
            //        TitleAsSubject = new List<string>();
            //        TitleAsSubject.AddRange(title_as_subject);
            //    }
            //    if (subjects.Count > 0)
            //    {
            //        Subject = new List<string>();
            //        Subject.AddRange(subjects);
            //    }
            //}

            // Spatial metadata fields
            // Copy individual portions of the hierarchical over to the spatials

                // spatial_standard
            // spatial_hierarchical
            // country
            // state 
            // county
            // city


            // Add the empty solr pages for now
            Solr_Pages = new List<Legacy_SolrPage>();

        }

        #endregion


        /// <summary> Gets the collection of page objects for Solr indexing </summary>
        public List<Legacy_SolrPage> Solr_Pages { get; set; }

        /// <summary> Unique key for this document</summary>
        [SolrUniqueKey("did")]
        public string DID { get; set; }

        #region Administrative Fields

        /// <summary> List of aggregations to which this item is linked </summary>
        [SolrField("aggregations")]
        public List<string> Aggregations { get; set; }

        /// <summary> Bibliographic identifier for this title (multiple volumes potentially) </summary>
        [SolrField("bibid")]
        public string BibID { get; set; }

        /// <summary> </summary>
        [SolrField("vid")]
        public string VID { get; set; }

        #endregion

        #region Main metadata fields

        /// <summary> Main title for this document </summary>
        [SolrField("title")]
        public string Title { get; set; }

        /// <summary> Sort title for this document </summary>
        [SolrField("sorttitle")]
        public string SortTitle { get; set; }

        /// <summary> Alternate titles for this document </summary>
        [SolrField("alttitle")]
        public List<string> AltTitle { get; set; }

        /// <summary> Overall resource type for this document </summary>
        [SolrField("type")]
        public string Type { get; set; }

        /// <summary> Languages for this document </summary>
        [SolrField("language")]
        public List<string> Language { get; set; }

        /// <summary> Creators (and contributors) for this document </summary>
        [SolrField("creator")]
        public List<string> Creator { get; set; }

        /// <summary> Affiliations for this document </summary>
        [SolrField("affiliation")]
        public List<string> Affiliation { get; set; }

        /// <summary> Publishers for this document </summary>
        [SolrField("publisher")]
        public List<string> Publisher { get; set; }

        /// <summary> Publisher (display format which includes publication place, etc..) for this document </summary>
        [SolrField("publisher.display")]
        public List<string> Publisher_Display { get; set; }

        /// <summary> Publication places for this document </summary>
        [SolrField("publication_place")]
        public List<string> PubPlace { get; set; }

        /// <summary> Audiences for this document </summary>
        [SolrField("audience")]
        public List<string> Audience { get; set; }

        /// <summary> Source institution (and location) for this document </summary>
        [SolrField("source")]
        public string Source { get; set; }

        /// <summary> Holding location for this document </summary>
        [SolrField("holding")]
        public string Holding { get; set; }

        /// <summary> Identifiers for this document </summary>
        [SolrField("identifier")]
        public List<string> Identifier { get; set; }

        /// <summary> Notes for this document </summary>
        [SolrField("notes")]
        public List<string> Notes { get; set; }

        /// <summary> Ticklers for this document </summary>
        [SolrField("tickler")]
        public List<string> Tickler { get; set; }

        /// <summary> Donor for this document </summary>
        [SolrField("donor")]
        public string Donor { get; set; }

        /// <summary> Format for this document </summary>
        [SolrField("format")]
        public string Format { get; set; }

        /// <summary> Frequencies for this document </summary>
        [SolrField("frequency")]
        public List<string> Frequency { get; set; }

        /// <summary> Genres for this document </summary>
        [SolrField("genre")]
        public List<string> Genre { get; set; }

        #endregion

        #region Date metadata fields - STILL NEED TO REVIEW THIS!!!

        #endregion

        #region Subject metadata fields

        /// <summary> Subjects and subject keywords for this document </summary>
        [SolrField("subject")]
        public List<string> Subject { get; set; }

        /// <summary> Name (corporate or personal) as subject for this document </summary>
        [SolrField("name_as_subject")]
        public List<string> NameAsSubject { get; set; }

        /// <summary> Title of a work as subject for this document </summary>
        [SolrField("title_as_subject")]
        public List<string> TitleAsSubject { get; set; }

        #endregion

        #region Spatial metadata fields

        /// <summary> Standard spatial subjects for this document </summary>
        [SolrField("spatial_standard")]
        public List<string> Spatial { get; set; }

        /// <summary> Hierarchical spatial subjects for this document </summary>
        /// <remarks> Some individual components are also broken out below </remarks>
        [SolrField("spatial_hierarchical")]
        public List<string> HierarchicalSpatial { get; set; }

        /// <summary> Country spatial keywords for this document </summary>
        [SolrField("country")]
        public List<string> Country { get; set; }

        /// <summary> State spatial keywords for this document </summary>
        [SolrField("state")]
        public List<string> State { get; set; }

        /// <summary> County spatial keywords for this document </summary>
        [SolrField("county")]
        public List<string> County { get; set; }

        /// <summary> City spatial keywords for this document </summary>
        [SolrField("city")]
        public List<string> City { get; set; }

        #endregion

        #region Temporal subject fields- STILL NEED TO REVIEW THIS!!!

        // [SolrField("temporal_subject" type = "text_general" indexed = "true" stored = "true"  multiValued = "true" />

        // [SolrField("temporal_decade" type = "text_general" indexed = "true" stored = "true"  multiValued = "true" />

        // [SolrField("temporal_year" type = "text_general" indexed = "true" stored = "true" />

        #endregion

        #region Other standard fields 

        /// <summary> Attribution for this document</summary>
        [SolrField("attribution")]
        public string Attribution { get; set; }

        /// <summary> MIME types associated with this document </summary>
        [SolrField("mime_type")]
        public List<string> MimeType { get; set; }

        /// <summary> Tracking box for this document </summary>
        [SolrField("tracking_box")]
        public List<string> TrackingBox { get; set; }

        /// <summary> Abstract for this document </summary>
        [SolrField("abstract")]
        public List<string> Abstract { get; set; }

        /// <summary> Edition for this document</summary>
        [SolrField("edition")]
        public string Edition { get; set; }

        /// <summary> Table of contents text for this document </summary>
        [SolrField("toc")]
        public List<string> TableOfContents { get; set; }

        /// <summary> Accession Number for this document</summary>
        [SolrField("accession_number")]
        public string AccessionNumber { get; set; }

        #endregion

        #region Oral history metadata fields 

        /// <summary> Interviewee with this oral history interview </summary>
        [SolrField("interviewee")]
        public List<string> Interviewee { get; set; }

        /// <summary> Interviewer with this oral history interview </summary>
        [SolrField("interviewer")]
        public List<string> Interviewer { get; set; }

        #endregion

        #region VRA Core(visual resource) metadata fields 
        
        /// <summary> Measurements VRACore information for this resource </summary>
        [SolrField("measurements")]
        public List<string> Measurements { get; set; }

        /// <summary> Cultural context VRACore information for this resource </summary>
        [SolrField("cultural_context")]
        public List<string> CulturalContext { get; set; }

        /// <summary> Inscription VRACore information for this resource </summary>
        [SolrField("inscription")]
        public List<string> Inscription { get; set; }

        /// <summary> Material VRACore information for this resource </summary>
        [SolrField("material")]
        public List<string> Material { get; set; }

        /// <summary> Style / Period VRACore information for this resource </summary>
        [SolrField("style_period")]
        public List<string> StylePeriod { get; set; }

        /// <summary> Technique VRACore information for this resource </summary>
        [SolrField("technique")]
        public List<string> Technique { get; set; }

        #endregion

        #region Zoological Taxonomy metadata fields 

        /// <summary> Complete hierarchical zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_hierarchical")]
        public List<string> ZoologicalHierarchical { get; set; }

        /// <summary> Kingdom zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_kingdom")]
        public List<string> ZoologicalKingdon { get; set; }

        /// <summary> Phylum zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_phylum")]
        public List<string> ZoologicalPhylum { get; set; }

        /// <summary> Class zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_class")]
        public List<string> ZoologicalClass { get; set; }

        /// <summary> Order zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_order")]
        public List<string> ZoologicalOrder { get; set; }

        /// <summary> Family zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_family")]
        public List<string> ZoologicalFamily { get; set; }

        /// <summary> Genus zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_genus")]
        public List<string> ZoologicalGenus { get; set; }

        /// <summary> Species zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_species")]
        public List<string> ZoologicalSpecies { get; set; }

        /// <summary> Common name zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_common_name")]
        public List<string> ZoologicalCommonName { get; set; }

        /// <summary> zt_scientific_name zoological taxonomic (DarwinCore) data for this resource </summary>
        [SolrField("zt_scientific_name")]
        public List<string> ZoologicalScientificName { get; set; }

        #endregion

        #region (Electronic) Thesis and Dissertation metadata fields 

        /// <summary> Committee members information for this thesis/dissertation resource </summary>
        [SolrField("etd_committee")]
        public List<string> EtdCommittee { get; set; }

        /// <summary> Degree information for this thesis/dissertation resource </summary>
        [SolrField("etd_degree")]
        public string EtdDegree { get; set; }

        /// <summary> Degree discipline information for this thesis/dissertation resource </summary>
        [SolrField("etd_degree_discipline")]
        public string EtdDegreeDiscipline { get; set; }

        /// <summary> Degree grantor information for this thesis/dissertation resource </summary>
        [SolrField("etd_degree_grantor")]
        public string EtdDegreeGrantor { get; set; }

        /// <summary> Degree level ( i.e., masters, doctorate, etc.. ) information for this thesis/dissertation resource </summary>
        [SolrField("etd_degree_level")]
        public string EtdDegreeLevel { get; set; }

        /// <summary> Degree division information for this thesis/dissertation resource </summary>
        [SolrField("etd_degree_division")]
        public string EtdDegreeDivision { get; set; }

        #endregion

        #region Learning Object metadata fields 

        /// <summary> Aggregation information for this learning object resource </summary>
        [SolrField("lom_aggregation")]
        public string LomAggregation { get; set; }

        /// <summary> Context information for this learning object resource </summary>
        [SolrField("lom_context")]
        public List<string> LomContext { get; set; }

        /// <summary> Classification information for this learning object resource </summary>
        [SolrField("lom_classification")]
        public List<string> LomClassification { get; set; }

        /// <summary> Difficulty information for this learning object resource </summary>
        [SolrField("lom_difficulty")]
        public string LomDifficulty { get; set; }

        /// <summary> Intended end user information for this learning object resource </summary>
        [SolrField("lom_intended_end_user")]
        public List<string> LomIntendedEndUser { get; set; }

        /// <summary> Interactivity level information for this learning object resource </summary>
        [SolrField("lom_interactivity_level")]
        public string LomInteractivityLevel { get; set; }

        /// <summary> Interactivity type information for this learning object resource </summary>
        [SolrField("lom_interactivity_type")]
        public string LomInteractivityType { get; set; }

        /// <summary> Status information for this learning object resource </summary>
        [SolrField("lom_status")]
        public string LomStatus { get; set; }

        /// <summary> System requirements information for this learning object resource </summary>
        [SolrField("lom_requirement")]
        public List<string> LomRequirement { get; set; }

        /// <summary> Age range information for this learning object resource </summary>
        [SolrField("lom_age_range")]
        public List<string> LomAgeRange { get; set; }

        /// <summary> Resource type information for this learning object resource </summary>
        [SolrField("lom_resource_type")]
        public List<string> LomResourceType { get; set; }

        /// <summary> Learning time information for this learning object resource </summary>
        [SolrField("lom_learning_time")]
        public string LomLearningTime { get; set; }

        #endregion

        #region User defined metadata fields, used by plug-ins, etc.. 

        /// <summary> User defined metadata field (#1) for this learning object resource </summary>
        [SolrField("user_defined_01")]
        public List<string> UserDefined01 { get; set; }

        /// <summary> User defined metadata field (#2) for this learning object resource </summary>
        [SolrField("user_defined_02")]
        public List<string> UserDefined02 { get; set; }

        /// <summary> User defined metadata field (#3) for this learning object resource </summary>
        [SolrField("user_defined_03")]
        public List<string> UserDefined03 { get; set; }

        /// <summary> User defined metadata field (#4) for this learning object resource </summary>
        [SolrField("user_defined_04")]
        public List<string> UserDefined04 { get; set; }

        /// <summary> User defined metadata field (#5) for this learning object resource </summary>
        [SolrField("user_defined_05")]
        public List<string> UserDefined05 { get; set; }

        /// <summary> User defined metadata field (#6) for this learning object resource </summary>
        [SolrField("user_defined_06")]
        public List<string> UserDefined06 { get; set; }

        /// <summary> User defined metadata field (#7) for this learning object resource </summary>
        [SolrField("user_defined_07")]
        public List<string> UserDefined07 { get; set; }

        /// <summary> User defined metadata field (#8) for this learning object resource </summary>
        [SolrField("user_defined_08")]
        public List<string> UserDefined08 { get; set; }

        /// <summary> User defined metadata field (#9) for this learning object resource </summary>
        [SolrField("user_defined_09")]
        public List<string> UserDefined09 { get; set; }

        /// <summary> User defined metadata field (#10) for this learning object resource </summary>
        [SolrField("user_defined_10")]
        public List<string> UserDefined10 { get; set; }

        /// <summary> User defined metadata field (#11) for this learning object resource </summary>
        [SolrField("user_defined_11")]
        public List<string> UserDefined11 { get; set; }

        /// <summary> User defined metadata field (#12) for this learning object resource </summary>
        [SolrField("user_defined_12")]
        public List<string> UserDefined12 { get; set; }

        /// <summary> User defined metadata field (#13) for this learning object resource </summary>
        [SolrField("user_defined_13")]
        public List<string> UserDefined13 { get; set; }

        /// <summary> User defined metadata field (#14) for this learning object resource </summary>
        [SolrField("user_defined_14")]
        public List<string> UserDefined14 { get; set; }

        /// <summary> User defined metadata field (#15) for this learning object resource </summary>
        [SolrField("user_defined_15")]
        public List<string> UserDefined15 { get; set; }

        /// <summary> User defined metadata field (#16) for this learning object resource </summary>
        [SolrField("user_defined_16")]
        public List<string> UserDefined16 { get; set; }

        /// <summary> User defined metadata field (#17) for this learning object resource </summary>
        [SolrField("user_defined_17")]
        public List<string> UserDefined17 { get; set; }

        /// <summary> User defined metadata field (#18) for this learning object resource </summary>
        [SolrField("user_defined_18")]
        public List<string> UserDefined18 { get; set; }

        /// <summary> User defined metadata field (#19) for this learning object resource </summary>
        [SolrField("user_defined_19")]
        public List<string> UserDefined19 { get; set; }

        /// <summary> User defined metadata field (#20) for this learning object resource </summary>
        [SolrField("user_defined_20")]
        public List<string> UserDefined20 { get; set; }

        /// <summary> User defined metadata field (#21) for this learning object resource </summary>
        [SolrField("user_defined_21")]
        public List<string> UserDefined21 { get; set; }

        /// <summary> User defined metadata field (#22) for this learning object resource </summary>
        [SolrField("user_defined_22")]
        public List<string> UserDefined22 { get; set; }

        /// <summary> User defined metadata field (#23) for this learning object resource </summary>
        [SolrField("user_defined_23")]
        public List<string> UserDefined23 { get; set; }

        /// <summary> User defined metadata field (#24) for this learning object resource </summary>
        [SolrField("user_defined_24")]
        public List<string> UserDefined24 { get; set; }

        /// <summary> User defined metadata field (#25) for this learning object resource </summary>
        [SolrField("user_defined_25")]
        public List<string> UserDefined25 { get; set; }

        /// <summary> User defined metadata field (#26) for this learning object resource </summary>
        [SolrField("user_defined_26")]
        public List<string> UserDefined26 { get; set; }

        /// <summary> User defined metadata field (#27) for this learning object resource </summary>
        [SolrField("user_defined_27")]
        public List<string> UserDefined27 { get; set; }

        /// <summary> User defined metadata field (#28) for this learning object resource </summary>
        [SolrField("user_defined_28")]
        public List<string> UserDefined28 { get; set; }

        /// <summary> User defined metadata field (#29) for this learning object resource </summary>
        [SolrField("user_defined_29")]
        public List<string> UserDefined29 { get; set; }

        /// <summary> User defined metadata field (#30) for this learning object resource </summary>
        [SolrField("user_defined_30")]
        public List<string> UserDefined30 { get; set; }

        /// <summary> User defined metadata field (#31) for this learning object resource </summary>
        [SolrField("user_defined_31")]
        public List<string> UserDefined31 { get; set; }

        /// <summary> User defined metadata field (#32) for this learning object resource </summary>
        [SolrField("user_defined_32")]
        public List<string> UserDefined32 { get; set; }

        /// <summary> User defined metadata field (#33) for this learning object resource </summary>
        [SolrField("user_defined_33")]
        public List<string> UserDefined33 { get; set; }

        /// <summary> User defined metadata field (#34) for this learning object resource </summary>
        [SolrField("user_defined_34")]
        public List<string> UserDefined34 { get; set; }

        /// <summary> User defined metadata field (#35) for this learning object resource </summary>
        [SolrField("user_defined_35")]
        public List<string> UserDefined35 { get; set; }

        /// <summary> User defined metadata field (#36) for this learning object resource </summary>
        [SolrField("user_defined_36")]
        public List<string> UserDefined36 { get; set; }

        /// <summary> User defined metadata field (#37) for this learning object resource </summary>
        [SolrField("user_defined_37")]
        public List<string> UserDefined37 { get; set; }

        /// <summary> User defined metadata field (#38) for this learning object resource </summary>
        [SolrField("user_defined_38")]
        public List<string> UserDefined38 { get; set; }

        /// <summary> User defined metadata field (#39) for this learning object resource </summary>
        [SolrField("user_defined_39")]
        public List<string> UserDefined39 { get; set; }

        /// <summary> User defined metadata field (#40) for this learning object resource </summary>
        [SolrField("user_defined_40")]
        public List<string> UserDefined40 { get; set; }

        /// <summary> User defined metadata field (#41) for this learning object resource </summary>
        [SolrField("user_defined_41")]
        public List<string> UserDefined41 { get; set; }

        /// <summary> User defined metadata field (#42) for this learning object resource </summary>
        [SolrField("user_defined_42")]
        public List<string> UserDefined42 { get; set; }

        /// <summary> User defined metadata field (#43) for this learning object resource </summary>
        [SolrField("user_defined_43")]
        public List<string> UserDefined43 { get; set; }

        /// <summary> User defined metadata field (#44) for this learning object resource </summary>
        [SolrField("user_defined_44")]
        public List<string> UserDefined44 { get; set; }

        /// <summary> User defined metadata field (#45) for this learning object resource </summary>
        [SolrField("user_defined_45")]
        public List<string> UserDefined45 { get; set; }

        /// <summary> User defined metadata field (#46) for this learning object resource </summary>
        [SolrField("user_defined_46")]
        public List<string> UserDefined46 { get; set; }

        /// <summary> User defined metadata field (#47) for this learning object resource </summary>
        [SolrField("user_defined_47")]
        public List<string> UserDefined47 { get; set; }

        /// <summary> User defined metadata field (#48) for this learning object resource </summary>
        [SolrField("user_defined_48")]
        public List<string> UserDefined48 { get; set; }

        /// <summary> User defined metadata field (#49) for this learning object resource </summary>
        [SolrField("user_defined_49")]
        public List<string> UserDefined49 { get; set; }

        /// <summary> User defined metadata field (#50) for this learning object resource </summary>
        [SolrField("user_defined_50")]
        public List<string> UserDefined50 { get; set; }

        /// <summary> User defined metadata field (#51) for this learning object resource </summary>
        [SolrField("user_defined_51")]
        public List<string> UserDefined51 { get; set; }

        /// <summary> User defined metadata field (#52) for this learning object resource </summary>
        [SolrField("user_defined_52")]
        public List<string> UserDefined52 { get; set; }

        #endregion

    }
}