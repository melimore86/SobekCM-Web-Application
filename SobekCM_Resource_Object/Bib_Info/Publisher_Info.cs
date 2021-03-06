﻿#region Using directives

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Text;

#endregion

namespace SobekCM.Resource_Object.Bib_Info
{
    /// <summary> Class contains the information about the publisher of a resource </summary>
    [Serializable]
    public class Publisher_Info : XML_Node_Base_Type, IEquatable<Publisher_Info>
    {
        private string name;
        private List<Origin_Info_Place> places;

        /// <summary> Constructor create a new instance of the Publisher_Info class </summary>
        public Publisher_Info()
        {
            // Do nothing
        }

        /// <summary> Constructor create a new instance of the Publisher_Info class </summary>
        /// <param name="Name">Name of the publisher </param>
        public Publisher_Info(string Name)
        {
            name = Name;
        }

        /// <summary> Gets and sets the name of this publisher  </summary>
        public string Name
        {
            get { return name ?? String.Empty; }
            set { name = value; }
        }

        /// <summary> Gets the number of places associated with this publisher </summary>
        /// <remarks>This should be used rather than the Count property of the <see cref="Places"/> property.  Even if 
        /// there are no places, the SubCollections property creates a readonly collection to pass back out.</remarks>
        public int Places_Count
        {
            get {
                return places == null ? 0 : places.Count;
            }
        }

        /// <summary>Gets the list of places associated with this publisher </summary>
        /// <remarks> You should check the count of places first using the <see cref="Places_Count"/> property before using this property.
        /// Even if there are no places, this property creates a readonly collection to pass back out.</remarks>
        public ReadOnlyCollection<Origin_Info_Place> Places
        {
            get {
                return places == null ? new ReadOnlyCollection<Origin_Info_Place>(new List<Origin_Info_Place>()) : new ReadOnlyCollection<Origin_Info_Place>(places);
            }
        }

        #region IEquatable<Publisher_Info> Members

        /// <summary> Compares this object with another similarly typed object </summary>
        /// <param name="Other">Similarly types object </param>
        /// <returns>TRUE if the two objects are sufficiently similar</returns>
        public bool Equals(Publisher_Info Other)
        {
            return String.Compare(Other.Name, Name, StringComparison.Ordinal) == 0;
        }

        #endregion

        /// <summary> Clears all places associated with this publisher </summary>
        public void Clear_Places()
        {
            if (places != null)
                places.Clear();
        }

        /// <summary> Add a new publication place </summary>
        /// <param name="Place_Text">Text of the publication place</param>
        public void Add_Place(string Place_Text)
        {
            if (places == null)
                places = new List<Origin_Info_Place>();

            places.Add(new Origin_Info_Place(Place_Text, String.Empty, String.Empty));
        }

        /// <summary> Add a new publication place </summary>
        /// <param name="Place_Text">Text of the publication place</param>
        /// <param name="Place_MarcCountry">Marc country code for the publication place</param>
        /// <param name="Place_ISO3166">ISO-3166 code for the publication place</param>
        public void Add_Place(string Place_Text, string Place_MarcCountry, string Place_ISO3166)
        {
            if (places == null)
                places = new List<Origin_Info_Place>();

            places.Add(new Origin_Info_Place(Place_Text, Place_MarcCountry, Place_ISO3166));
        }

        /// <summary> Write the publisher information out to string format</summary>
        /// <returns> This publisher expressed as a string</returns>
        public override string ToString()
        {
            StringBuilder builder = new StringBuilder();
            if (!String.IsNullOrEmpty(name))
            {
                builder.Append(Convert_String_To_XML_Safe(name));
            }
            if ((places != null) && (places.Count > 0))
            {
                builder.Append(" ( ");
                foreach (Origin_Info_Place thisPlace in places)
                {
                    if (thisPlace.Place_Text.Length > 0)
                    {
                        builder.Append(Convert_String_To_XML_Safe(thisPlace.Place_Text) + ", ");
                    }
                }
                builder.Append(")");
            }
            return builder.ToString().Replace(", )", " )");
        }

        /// <summary> Writes this publisher as SobekCM-formatted XML </summary>
        /// <param name="SobekcmNamespace"> Namespace to use for the SobekCM custom schema ( usually 'sobekcm' )</param>
        /// <param name="Results"> Stream to write this publisher as SobekCM-formatted XML</param>
        /// <param name="Type"> Type indicates if this is a publisher or a manufacturer of the digital resource </param>
        internal void Add_SobekCM_Metadata(string SobekcmNamespace, string Type, TextWriter Results)
        {
            if (String.IsNullOrEmpty(name)) return;

            Results.Write("<" + SobekcmNamespace + ":" + Type);
            Add_ID(Results);
            Results.WriteLine(">");

            Results.WriteLine("<" + SobekcmNamespace + ":Name>" + Convert_String_To_XML_Safe(name) + "</" + SobekcmNamespace + ":Name>");

            // Step through all the publication places
            if (places != null)
            {
                foreach (Origin_Info_Place place in places)
                {
                    if ((place.Place_ISO3166.Length > 0) || (place.Place_MarcCountry.Length > 0) || (place.Place_Text.Length > 0))
                    {
                        if (place.Place_Text.Length > 0)
                            Results.WriteLine("<" + SobekcmNamespace + ":PlaceTerm type=\"text\">" + Convert_String_To_XML_Safe(place.Place_Text) + "</" + SobekcmNamespace + ":PlaceTerm>");
                        if (place.Place_MarcCountry.Length > 0)
                            Results.WriteLine("<" + SobekcmNamespace + ":PlaceTerm type=\"code\" authority=\"marccountry\">" + place.Place_MarcCountry + "</" + SobekcmNamespace + ":PlaceTerm>");
                        if (place.Place_ISO3166.Length > 0)
                            Results.WriteLine("<" + SobekcmNamespace + ":PlaceTerm type=\"code\" authority=\"iso3166\">" + place.Place_ISO3166 + "</" + SobekcmNamespace + ":PlaceTerm>");
                    }
                }
            }

            Results.WriteLine("</" + SobekcmNamespace + ":" + Type + ">");
        }
    }
}