﻿#region Using directives

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Text;
using SobekCM.Resource_Object.MARC;

#endregion

namespace SobekCM.Resource_Object.Bib_Info
{
    /// <summary> Standard subject keywords for this item </summary>
    [Serializable]
    public class Subject_Info_Standard : Subject_Standard_Base
    {
        private List<string> occupations;

        /// <summary> Constructor for a new instance of the standard subject class </summary>
        public Subject_Info_Standard()
        {
            // Do nothing
        }

        /// <summary> Constructor for a new instance of the standard subject class </summary>
        /// <param name="Topic">Topical subject</param>
        /// <param name="Authority">Authority for this topic subject keyword</param>
        public Subject_Info_Standard(string Topic, string Authority)
        {
            topics = new List<string> { Topic };
            authority = Authority;
        }

        /// <summary> Gets flag indicating if there is any data in this subject object </summary>
        public new bool hasData
        {
            get
            {
                return (base.hasData) || ((occupations != null) && (occupations.Count > 0));
            }
        }

        /// <summary> Gets the number of topical subjects </summary>
        /// <remarks>This should be used rather than the Count property of the <see cref="Occupations"/> property.  Even if 
        /// there are no occupational subjects, the Occupations property creates a readonly collection to pass back out.</remarks>
        public int Occupations_Count
        {
            get {
                return occupations == null ? 0 : occupations.Count;
            }
        }

        /// <summary> Gets the list of occupational subjects </summary>
        /// <remarks> You should check the count of topical subjects first using the <see cref="Occupations_Count"/> before using this property.
        /// Even if there are no occupational subjects, this property creates a readonly collection to pass back out.</remarks>
        public ReadOnlyCollection<string> Occupations
        {
            get {
                return occupations == null ? new ReadOnlyCollection<string>(new List<string>()) : new ReadOnlyCollection<string>(occupations);
            }
        }

        /// <summary> Indicates this is the standard subclass of Subject_Info </summary>
        public override Subject_Info_Type Class_Type
        {
            get { return Subject_Info_Type.Standard; }
        }

        /// <summary> Add a new occupational subject keyword to this subject </summary>
        /// <param name="NewTerm">New subject term to add</param>
        public void Add_Occupation(string NewTerm)
        {
            if (occupations == null)
                occupations = new List<string>();

            if (!occupations.Contains(NewTerm))
                occupations.Add(NewTerm);
        }

        /// <summary> Clear all the occupational subject keywords from this subject </summary>
        public void Clear_Occupations()
        {
            if (occupations != null)
                occupations.Clear();
        }

        /// <summary> Write the subject information out to string format</summary>
        /// <returns> This subject expressed as a string</returns>
        /// <remarks> The scheme is included in this string</remarks>
        public override string ToString()
        {
            return ToString(true);
        }

        /// <summary> Write the subject information out to string format</summary>
        /// <param name="Include_Scheme"> Flag indicates whether the scheme should be included</param>
        /// <returns> This subject expressed as a string</returns>
        public override string ToString(bool Include_Scheme)
        {
            StringBuilder builder = new StringBuilder();

            if (occupations != null)
            {
                foreach (string thisOccupation in occupations)
                {
                    if (builder.Length > 0)
                    {
                        builder.Append(" -- " + thisOccupation);
                    }
                    else
                    {
                        builder.Append(thisOccupation);
                    }
                }
            }

            builder.Append(To_Base_String());

            if (Include_Scheme)
            {
                if (!String.IsNullOrEmpty(authority))
                    builder.Append(" ( " + authority + " )");
            }

            return Convert_String_To_XML_Safe(builder.ToString());
        }

        internal override void Add_MODS(TextWriter Results)
        {
            if (((occupations == null) || (occupations.Count == 0)) &&
                ((genres == null) || (genres.Count == 0)) &&
                ((temporals == null) || (temporals.Count == 0)) &&
                ((topics == null) || (topics.Count == 0)) &&
                ((geographics == null) || (geographics.Count == 0)))
                return;

            Results.Write("<mods:subject");
            Add_ID(Results);
            if (!String.IsNullOrEmpty(language))
                Results.Write(" lang=\"" + language + "\"");
            if (!String.IsNullOrEmpty(authority))
                Results.Write(" authority=\"" + authority + "\"");
            Results.Write(">\r\n");

            Add_Base_MODS(Results);

            if (occupations != null)
            {
                foreach (string thisElement in occupations)
                {
                    Results.Write("<mods:occupation>" + Convert_String_To_XML_Safe(thisElement) + "</mods:occupation>\r\n");
                }
            }

            Results.Write("</mods:subject>\r\n");
        }


        internal override MARC_Field to_MARC_HTML()
        {
            MARC_Field returnValue = new MARC_Field();

            // Set the tag            
            if ((id.IndexOf("SUBJ") == 0) && (id.Length >= 7))
            {
                string possible_tag = id.Substring(4, 3);
                try
                {
                    int possible_tag_number = Convert.ToInt16(possible_tag);
                    returnValue.Tag = possible_tag_number;
                }
                catch
                {
                }
            }

            // Try to guess the tag, if there was no tag
            if ((returnValue.Tag <= 0) && (Topics_Count == 0))
            {
                if ((Temporals_Count > 0) && (Genres_Count == 0) && (Geographics_Count == 0))
                    returnValue.Tag = 648;

                if ((Temporals_Count == 0) && (Genres_Count > 0) && (Geographics_Count == 0))
                    returnValue.Tag = 655;

                if ((Temporals_Count == 0) && (Genres_Count == 0) && (Geographics_Count > 0))
                    returnValue.Tag = 651;
            }

            // 650 is the default
            if (returnValue.Tag <= 0)
            {
                returnValue.Tag = 650;
            }

            // No indicators 
            returnValue.Indicators = "  ";
            bool first_field_assigned = false;
            string scale = String.Empty;
            StringBuilder fieldBuilder = new StringBuilder();
            StringBuilder fieldBuilder2 = new StringBuilder();

            // Whenever there is an occupation, it must map into the 656
            if ((occupations != null) && (occupations.Count > 0))
            {
                returnValue.Tag = 656;
                fieldBuilder.Append("|a ");
                foreach (string occupation in occupations)
                {
                    if (!first_field_assigned)
                    {
                        fieldBuilder.Append(occupation);
                        first_field_assigned = true;
                    }
                    else
                    {
                        fieldBuilder.Append(" -- " + occupation);
                    }
                }
                fieldBuilder.Append(" ");
            }

            switch (returnValue.Tag)
            {
                case 690:
                    first_field_assigned = assign_genres(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    first_field_assigned = assign_topics(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2, ref scale);
                    first_field_assigned = assign_geographics(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    assign_temporals(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    break;

                case 691:
                    first_field_assigned = assign_genres(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    first_field_assigned = assign_geographics(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    first_field_assigned = assign_topics(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2, ref scale);
                    assign_temporals(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    break;

                default:
                    first_field_assigned = assign_geographics(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    first_field_assigned = assign_temporals(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    first_field_assigned = assign_topics(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2, ref scale);
                   assign_genres(first_field_assigned, returnValue.Tag, fieldBuilder, fieldBuilder2);
                    break;
            }

            if (!String.IsNullOrEmpty(scale))
            {
                fieldBuilder2.Append("|x " + scale + " ");
            }

            fieldBuilder.Append(fieldBuilder2);
            if (fieldBuilder.Length > 2)
            {
                fieldBuilder.Remove(fieldBuilder.Length - 1, 1);
                if ((returnValue.Tag != 653) && (fieldBuilder[fieldBuilder.Length - 1] != '.'))
                    fieldBuilder.Append(". ");
            }

            Add_Source_Indicator(returnValue, fieldBuilder);

            returnValue.Control_Field_Value = returnValue.Tag == 653 ? fieldBuilder.ToString().Trim().Replace("|x ", "|a ") : fieldBuilder.ToString().Trim();

            return returnValue;
        }

        private bool assign_geographics(bool FirstFieldAssigned, int Tag, StringBuilder FieldBuilder, StringBuilder FieldBuilder2)
        {
            if (geographics == null) return FirstFieldAssigned;

            foreach (string geo in geographics)
            {
                if ((!FirstFieldAssigned) && ((Tag == 651) || (Tag == 691)))
                {
                    FieldBuilder.Append("|a " + geo + " ");
                    FirstFieldAssigned = true;
                }
                else
                {
                    FieldBuilder2.Append("|z " + geo + " ");
                }
            }
            return FirstFieldAssigned;
        }

        private bool assign_temporals(bool FirstFieldAssigned, int Tag, StringBuilder FieldBuilder, StringBuilder FieldBuilder2)
        {
            if (temporals != null)
            {
                foreach (string temporal in temporals)
                {
                    if ((!FirstFieldAssigned) && (Tag == 648))
                    {
                        FieldBuilder.Append("|a " + temporal + " ");
                        FirstFieldAssigned = true;
                    }
                    else
                    {
                        FieldBuilder2.Append("|y " + temporal + " ");
                    }
                }
            }
            return FirstFieldAssigned;
        }

        private bool assign_topics(bool FirstFieldAssigned, int Tag, StringBuilder FieldBuilder, StringBuilder FieldBuilder2, ref string Scale)
        {
            if (topics != null)
            {
                foreach (string topic in topics)
                {
                    if ((topic.IndexOf("1:") == 0) || topic.IndexOf(" scale") >= 0)
                        Scale = topic;
                    else
                    {
                        if ((!FirstFieldAssigned) && ((Tag == 690) || (Tag == 650) || (Tag == 654) || (Tag == 657)))
                        {
                            FieldBuilder.Append("|a " + topic + " ");
                            FirstFieldAssigned = true;
                        }
                        else
                        {
                            FieldBuilder2.Append("|x " + topic + " ");
                        }
                    }
                }
            }
            return FirstFieldAssigned;
        }

        private bool assign_genres(bool FirstFieldAssigned, int Tag, StringBuilder FieldBuilder, StringBuilder FieldBuilder2)
        {
            if (genres != null)
            {
                foreach (string form in genres)
                {
                    if ((!FirstFieldAssigned) && ((Tag == 655) || (Tag == 690)))
                    {
                        FieldBuilder.Append("|a " + form + " ");
                        FirstFieldAssigned = true;
                    }
                    else
                    {
                        FieldBuilder2.Append("|v " + form + " ");
                    }
                }
            }
            return FirstFieldAssigned;
        }
    }
}