#region Using directives

using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI.WebControls;
using SobekCM.Library.Application_State;
using SobekCM.Library.Configuration;
using SobekCM.Library.Navigation;
using SobekCM.Library.Results;
using SobekCM.Library.Settings;
using SobekCM.Library.Users;

#endregion

namespace SobekCM.Library.HTML
{
    /// <summary> Search results html subwriter renders a browse of search results  </summary>
    /// <remarks> This class extends the <see cref="abstractHtmlSubwriter"/> abstract class. </remarks>
    public class Search_Results_HtmlSubwriter : abstractHtmlSubwriter
    {
        private readonly Item_Lookup_Object allItemsTable;
        private readonly Aggregation_Code_Manager codeManager;
        private readonly User_Object currentUser;
        private readonly List<iSearch_Title_Result> pagedResults;
        private readonly Search_Results_Statistics resultsStatistics;
        private readonly Language_Support_Info translations;
        private PagedResults_HtmlSubwriter writeResult;

        /// <summary> Constructor for a new instance of the Search_Results_HtmlSubwriter class </summary>
        /// <param name="Results_Statistics"> Information about the entire set of results for a search or browse </param>
        /// <param name="Paged_Results"> Single page of results for a search or browse, within the entire set </param>
        /// <param name="Code_Manager"> List of valid collection codes, including mapping from the Sobek collections to Greenstone collections</param>
        /// <param name="Translator"> Language support object which handles simple translational duties </param>
        /// <param name="All_Items_Lookup"> Lookup object used to pull basic information about any item loaded into this library </param>
        /// <param name="Current_User"> Currently logged on user </param>
        public Search_Results_HtmlSubwriter(Search_Results_Statistics Results_Statistics,
            List<iSearch_Title_Result> Paged_Results,
            Aggregation_Code_Manager Code_Manager, Language_Support_Info Translator,
            Item_Lookup_Object All_Items_Lookup, 
            User_Object Current_User)
        {
            currentUser = Current_User;
            pagedResults = Paged_Results;
            resultsStatistics = Results_Statistics;
            translations = Translator;
            codeManager = Code_Manager;
            allItemsTable = All_Items_Lookup;
         }

        /// <summary> Adds controls to the main navigational page </summary>
        /// <param name="placeHolder"> Main place holder ( &quot;mainPlaceHolder&quot; ) in the itemNavForm form, widely used throughout the application</param>
        /// <param name="Tracer"> Trace object keeps a list of each method executed and important milestones in rendering </param>
        /// <param name="populate_node_event"> Event is used to populate the a tree node without doing a full refresh of the page </param>
        /// <returns> Sorted tree with the results in hierarchical structure with volumes and issues under the titles </returns>
        /// <remarks> This uses a <see cref="PagedResults_HtmlSubwriter"/> instance to render the items  </remarks>
        public void Add_Controls(PlaceHolder placeHolder, Custom_Tracer Tracer, TreeNodeEventHandler populate_node_event )
        {
            if (resultsStatistics == null) return;

            if (writeResult == null)
            {
                Tracer.Add_Trace("Search_Results_HtmlSubwriter.Add_Controls", "Building Result DataSet Writer");

                writeResult = new PagedResults_HtmlSubwriter(resultsStatistics, pagedResults, codeManager, translations, allItemsTable, currentUser, currentMode, Tracer)
                                  {Current_Aggregation = Current_Aggregation, Skin = htmlSkin, Mode = currentMode};
            }

            Tracer.Add_Trace("Search_Results_HtmlSubwriter.Add_Controls", "Add controls");
            writeResult.Add_Controls(placeHolder, Tracer);
        }

        /// <summary> Writes the final output to close this search page results, including the results page navigation buttons </summary>
        /// <param name="Output"> Stream to which to write the HTML for this subwriter </param>
        /// <param name="Tracer"> Trace object keeps a list of each method executed and important milestones in rendering </param>
        /// <returns> TRUE is always returned </returns>
        /// <remarks> This calls the <see cref="PagedResults_HtmlSubwriter.Write_Final_HTML"/> method in the <see cref="PagedResults_HtmlSubwriter"/> object. </remarks>
		public override void Write_Final_HTML(TextWriter Output, Custom_Tracer Tracer)
        {
            Tracer.Add_Trace("browse_info_html_subwriter.Write_Final_Html", "Rendering HTML ( finish the main viewer section )");

            if (writeResult != null)
            {
                writeResult.Write_Final_HTML(Output, Tracer);
            }
        }

        /// <summary> Writes the HTML generated to browse the results of a search directly to the response stream </summary>
        /// <param name="Output"> Stream to which to write the HTML for this subwriter </param>
        /// <param name="Tracer"> Trace object keeps a list of each method executed and important milestones in rendering </param>
        /// <returns> TRUE -- Value indicating if html writer should finish the page immediately after this, or if there are other controls or routines which need to be called first </returns>
        public override bool Write_HTML(TextWriter Output, Custom_Tracer Tracer)
        {
            Tracer.Add_Trace("Search_Results_HtmlSubwriter.Write_HTML", "Rendering HTML");

            // If this skin has top-level navigation suppressed, skip the top tabs
            if (htmlSkin.Suppress_Top_Navigation)
            {
                Output.WriteLine("<br />");
            }
            else
            {
				// Add the main aggrgeation menu here
				MainMenus_Helper_HtmlSubWriter.Add_Aggregation_Search_Results_Menu(Output, currentMode, currentUser, Current_Aggregation, translations, codeManager, false);

            }
           
            if ( resultsStatistics != null )
            {
                if (writeResult == null)
                {
                    Tracer.Add_Trace("Search_Results_HtmlSubwriter.Write_HTML", "Building Result DataSet Writer");
                    writeResult = new PagedResults_HtmlSubwriter(resultsStatistics, pagedResults, codeManager, translations, allItemsTable, currentUser, currentMode, Tracer)
                                      {Current_Aggregation = Current_Aggregation, Skin = htmlSkin, Mode = currentMode};
                }
                writeResult.Write_HTML(Output, Tracer);
            }

            return true;
        }

        /// <summary> Gets the collection of body attributes to be included 
        /// within the HTML body tag (usually to add events to the body) </summary>
        public override List<Tuple<string, string>> Body_Attributes
        {
            get
            {
                if (currentMode.Result_Display_Type == Result_Display_Type_Enum.Map)
                {
                    List<Tuple<string, string>> returnValue = new List<Tuple<string, string>>();

                    returnValue.Add(new Tuple<string, string>("onload", "load();"));

                    return returnValue;
                }
                if (currentMode.Result_Display_Type == Result_Display_Type_Enum.Map_Beta)
                {
                    List<Tuple<string, string>> returnValue = new List<Tuple<string, string>>();

                    returnValue.Add(new Tuple<string, string>("onload", "load();"));

                    return returnValue;
                }
                return null;
            }
        }

        /// <summary> Title for this web page </summary>
        public override string WebPage_Title
        {
            get
            {
                if (Current_Aggregation != null)
                {
                    return "{0} Search Results - " + Current_Aggregation.Name;
                }
                else
                {
                    return "{0} Search Results";
                }
            }
        }

        /// <summary> Write any additional values within the HTML Head of the
        /// final served page </summary>
        /// <param name="Output"> Output stream currently within the HTML head tags </param>
        /// <param name="Tracer"> Trace object keeps a list of each method executed and important milestones in rendering </param>
        public override void Write_Within_HTML_Head(TextWriter Output, Custom_Tracer Tracer)
        {
            Output.WriteLine("  <meta name=\"robots\" content=\"index, nofollow\" />");
        }

		/// <summary> Gets the CSS class of the container that the page is wrapped within </summary>
		public override string Container_CssClass
		{
			get
			{
				return pagedResults != null ? "container-facets" : base.Container_CssClass;
			}
		}
    }
}
