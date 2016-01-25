﻿#region Using directives

using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Windows.Forms.VisualStyles;
using SobekCM.Core.Client;
using SobekCM.Core.Configuration.Extensions;
using SobekCM.Core.Navigation;
using SobekCM.Core.Settings;
using SobekCM.Core.UI_Configuration;
using SobekCM.Library.Database;
using SobekCM.Library.HTML;
using SobekCM.Library.MainWriters;
using SobekCM.Library.UI;
using SobekCM.Tools;

#endregion

namespace SobekCM.Library.AdminViewer
{
	/// <summary> Class allows an authenticated system admin to view and edit the library-wide system settings in this library </summary>
	/// <remarks> This class extends the <see cref="abstract_AdminViewer"/> class.<br /><br />
	/// MySobek Viewers are used for registration and authentication with mySobek, as well as performing any task which requires
	/// authentication, such as online submittal, metadata editing, and system administrative tasks.<br /><br />
	/// During a valid html request, the following steps occur:
	/// <ul>
	/// <li>Application state is built/verified by the Application_State_Builder </li>
	/// <li>Request is analyzed by the QueryString_Analyzer and output as a <see cref="Navigation_Object"/>  </li>
	/// <li>Main writer is created for rendering the output, in his case the <see cref="Html_MainWriter"/> </li>
	/// <li>The HTML writer will create the necessary subwriter.  Since this action requires authentication, an instance of the  <see cref="MySobek_HtmlSubwriter"/> class is created. </li>
	/// <li>The mySobek subwriter creates an instance of this viewer to show the library-wide system settings in this digital library</li>
	/// </ul></remarks>
	public class Settings_AdminViewer : abstract_AdminViewer
	{
		private readonly string actionMessage;
		private readonly StringBuilder errorBuilder;

		private bool isValid;
	  
		private readonly bool category_view;
		private readonly bool limitedRightsMode;
		private readonly bool readonlyMode;
		private readonly Admin_Setting_Collection currSettings;
		private SortedList<string, string> tabPageNames;
		private Dictionary<string, List<Admin_Setting_Value>> settingsByPage;
	    private List<Admin_Setting_Value> builderSettings; 

		#region Enumeration of the main modes of the settings, as well as submodes

		private enum Settings_Mode_Enum : byte
		{
			NONE,
	
			Settings,

			Builder,

			Engine,

			UI,

			HTML,

			Extensions
		}

	    private enum Settings_Builder_SubMode_Enum : byte
	    {
	        NONE,

            Builder_Settings,

            Builder_Folders,

            Builder_Modules
	    }

		#endregion


		/// <summary> Constructor for a new instance of the Thematic_Headings_AdminViewer class </summary>
		/// <param name="RequestSpecificValues"> All the necessary, non-global data specific to the current request </param>
		/// <remarks> Postback from handling saving the new settings is handled here in the constructor </remarks>
		public Settings_AdminViewer(RequestCache RequestSpecificValues) : base(RequestSpecificValues)
		{
			// If the RequestSpecificValues.Current_User cannot edit this, go back
			if (( RequestSpecificValues.Current_User == null ) || ((!RequestSpecificValues.Current_User.Is_System_Admin) && (!RequestSpecificValues.Current_User.Is_Portal_Admin)))
			{
				RequestSpecificValues.Current_Mode.Mode = Display_Mode_Enum.My_Sobek;
				RequestSpecificValues.Current_Mode.My_Sobek_Type = My_Sobek_Type_Enum.Home;
				UrlWriterHelper.Redirect(RequestSpecificValues.Current_Mode);
				return;
			}

			// Determine if this user has limited rights
			if ((!RequestSpecificValues.Current_User.Is_System_Admin) && (!RequestSpecificValues.Current_User.Is_Host_Admin))
			{
				limitedRightsMode = true;
				readonlyMode = true;
			}
			else
			{
				limitedRightsMode = ((!RequestSpecificValues.Current_User.Is_Host_Admin) && (UI_ApplicationCache_Gateway.Settings.Servers.isHosted)); 
				readonlyMode = false;
			}

			// Load the settings either from the local session, or from the engine
			currSettings = HttpContext.Current.Session["Admin_Settings"] as Admin_Setting_Collection;
			if (currSettings == null)
			{
				currSettings = SobekEngineClient.Admin.Get_Admin_Settings(RequestSpecificValues.Tracer);
				if (currSettings != null)
				{
					HttpContext.Current.Session["Admin_Settigs"] = currSettings;

					// Build the setting values
					build_setting_objects_for_display();
				}
				else
				{
					actionMessage = "Error pulling the settings from the engine";
				}
			}

			// Establish some default, starting values
			actionMessage = String.Empty;
			category_view = Convert.ToBoolean(RequestSpecificValues.Current_User.Get_Setting("Settings_AdminViewer:Category_View", "false"));

			// Is this a post-back requesting to save all this data?
			if (RequestSpecificValues.Current_Mode.isPostBack)
			{
				NameValueCollection form = HttpContext.Current.Request.Form;

				if (form["admin_settings_order"] == "category")
				{
					RequestSpecificValues.Current_User.Add_Setting("Settings_AdminViewer:Category_View", "true");
					SobekCM_Database.Set_User_Setting(RequestSpecificValues.Current_User.UserID, "Settings_AdminViewer:Category_View", "true");
					category_view = true;
				}

				if (form["admin_settings_order"] == "alphabetical")
				{
					RequestSpecificValues.Current_User.Add_Setting("Settings_AdminViewer:Category_View", "false");
					SobekCM_Database.Set_User_Setting(RequestSpecificValues.Current_User.UserID, "Settings_AdminViewer:Category_View", "false");
					category_view = false;
				}

				string action_value = form["admin_settings_action"];
				if ((action_value == "save") && (RequestSpecificValues.Current_User.Is_System_Admin))
				{
					// If this was read-only, really shouldn't do anything here
					if (readonlyMode)
						return;

					// First, create the setting lookup by ID, and the list of IDs to look for
					List<short> settingIds = new List<short>();
					Dictionary<short, Admin_Setting_Value> settingsObjsById = new Dictionary<short, Admin_Setting_Value>();
					foreach (Admin_Setting_Value Value in currSettings.Settings)
					{
						// If this is readonly, will not prepare to update
						if ((!Is_Value_ReadOnly(Value, readonlyMode, limitedRightsMode )) && ( !Value.Hidden ))
						{
							settingIds.Add(Value.SettingID);
							settingsObjsById[Value.SettingID] = Value;
						}
					}

					// Now, step through and get the values for each of these
					List<Simple_Setting> newValues = new List<Simple_Setting>();
					foreach (short id in settingIds)
					{
						// Get the setting information
						Admin_Setting_Value thisValue = settingsObjsById[id];

						if (form["setting" + id] != null)
						{
							newValues.Add(new Simple_Setting(thisValue.Key, form["setting" + id], thisValue.SettingID));
						}
						else
						{
							newValues.Add(new Simple_Setting(thisValue.Key, String.Empty, thisValue.SettingID));
						}
					}

					// Now, validate all this
					errorBuilder = new StringBuilder();
					isValid = true;
					validate_update_entered_data(newValues);

					// Now, assign the values from the simple settings back to the main settings
					// object.  This is to allow for the validation process to make small changes
					// to the values the user entered, like different starts or endings
					foreach (Simple_Setting thisSetting in newValues)
					{
						settingsObjsById[thisSetting.SettingID].Value = thisSetting.Value;
					}

					if ( isValid )
					{
						// Try to save each setting
						//errors += newSettings.Keys.Count(ThisKey => !SobekCM_Database.Set_Setting(ThisKey, newSettings[ThisKey]));

						// Prepare the action message
					   // if (errors > 0)
					   //     actionMessage = "Save completed, but with " + errors + " errors.";
					   // else
							actionMessage = "Settings saved";

						// Assign this to be used by the system
						UI_ApplicationCache_Gateway.ResetSettings();

						// Also, reset the source for static files, as thatmay have changed
						Static_Resources.Config_Read_Attempted = false;

						// Get all the settings again 
						build_setting_objects_for_display();
					}
					else
					{
						actionMessage = errorBuilder.ToString().Replace("\n", "<br />");
					}
				}
			}
		}

		private static bool Is_Value_ReadOnly(Admin_Setting_Value Value, bool ReadOnlyMode, bool LimitedRightsMode )
		{
		   return ((ReadOnlyMode) || (Value.Reserved > 2) || ((LimitedRightsMode) && (Value.Reserved != 0)));
		}



		/// <summary> Title for the page that displays this viewer, this is shown in the search box at the top of the page, just below the banner </summary>
		/// <value> This always returns the value 'System-Wide Settings' </value>
		public override string Web_Title
		{
			get { return "System-Wide Settings"; }
		}
		
		/// <summary> Gets the URL for the icon related to this administrative task </summary>
		public override string Viewer_Icon
		{
			get { return Static_Resources.Settings_Img; }
		}

  
		
		/// <summary> Add the HTML to be displayed in the main SobekCM viewer area </summary>
		/// <param name="Output"> Textwriter to write the HTML for this viewer</param>
		/// <param name="Tracer">Trace object keeps a list of each method executed and important milestones in rendering</param>
		/// <remarks> This class does nothing, since the themes list is added as controls, not HTML </remarks>
		public override void Write_HTML(TextWriter Output, Custom_Tracer Tracer)
		{
			Tracer.Add_Trace("Settings_AdminViewer.Write_HTML", "Do nothing");
		}

		/// <summary> This is an opportunity to write HTML directly into the main form, without
		/// using the pop-up html form architecture </summary>
		/// <param name="Output"> Textwriter to write the pop-up form HTML for this viewer </param>
		/// <param name="Tracer"> Trace object keeps a list of each method executed and important milestones in rendering</param>
		/// <remarks> This text will appear within the ItemNavForm form tags </remarks>
		public override void Write_ItemNavForm_Closing(TextWriter Output, Custom_Tracer Tracer)
		{
			Tracer.Add_Trace("Settings_AdminViewer.Write_ItemNavForm_Closing", "Write the rest of the form ");


			// Add the hidden field
			Output.WriteLine("<!-- Hidden field is used for postbacks to indicate what to save and reset -->");
			Output.WriteLine("<input type=\"hidden\" id=\"admin_settings_action\" name=\"admin_settings_action\" value=\"\" />");
			if ( category_view )	
				Output.WriteLine("<input type=\"hidden\" id=\"admin_settings_order\" name=\"admin_settings_order\" value=\"category\" />");
			else
				Output.WriteLine("<input type=\"hidden\" id=\"admin_settings_order\" name=\"admin_settings_order\" value=\"alphabetical\" />");

			Output.WriteLine();

			Output.WriteLine("<!-- Settings_AdminViewer.Write_ItemNavForm_Closing -->");
			Output.WriteLine("<script src=\"" + Static_Resources.Sobekcm_Admin_Js + "\" type=\"text/javascript\"></script>");
			Output.WriteLine();

			Output.WriteLine("<div class=\"sbkAdm_HomeText\">");
			Output.WriteLine("  <div id=\"sbkSeav_Explanation\">");
			Output.WriteLine("    <p>This form allows a user to view and edit all the main system-wide settings which allow the SobekCM web application and assorted related applications to function correctly within each custom architecture and each institution.</p>");
			Output.WriteLine("    <p>For more information about these settings, <a href=\"" + UI_ApplicationCache_Gateway.Settings.System.Help_URL(RequestSpecificValues.Current_Mode.Base_URL) + "adminhelp/settings\" target=\"ADMIN_USER_HELP\" >click here to view the help page</a>.</p>");

			// Add portal admin message
			if (!RequestSpecificValues.Current_User.Is_System_Admin)
			{
				Output.WriteLine("    <p>Portal Admins have rights to see these settings. System Admins can change these settings.</p>");
			}

			Output.WriteLine("  </div>");
			Output.WriteLine("</div>");
			Output.WriteLine();

			Output.WriteLine("<table id=\"sbkSeav_MainTable\">");
			Output.WriteLine("  <tr>");
			Output.WriteLine("    <td id=\"sbkSeav_TocArea\">");


			// Determine the redirect URL now
			string[] origUrlSegments = RequestSpecificValues.Current_Mode.Remaining_Url_Segments;
			RequestSpecificValues.Current_Mode.Remaining_Url_Segments = new string[] { "%SETTINGSCODE%" };
			string redirectUrl = UrlWriterHelper.Redirect_URL(RequestSpecificValues.Current_Mode);
			RequestSpecificValues.Current_Mode.Remaining_Url_Segments = origUrlSegments;

			// Determine the current viewer code
			string currentViewerCode = String.Empty;
			if ((RequestSpecificValues.Current_Mode.Remaining_Url_Segments != null) && (RequestSpecificValues.Current_Mode.Remaining_Url_Segments.Length > 0))
			{
				if (RequestSpecificValues.Current_Mode.Remaining_Url_Segments.Length == 1)
					currentViewerCode = RequestSpecificValues.Current_Mode.Remaining_Url_Segments[0];
				else if (RequestSpecificValues.Current_Mode.Remaining_Url_Segments.Length == 2)
					currentViewerCode = RequestSpecificValues.Current_Mode.Remaining_Url_Segments[0] + "/" + RequestSpecificValues.Current_Mode.Remaining_Url_Segments[1];
				else
					currentViewerCode = RequestSpecificValues.Current_Mode.Remaining_Url_Segments[0] + "/" + RequestSpecificValues.Current_Mode.Remaining_Url_Segments[1] + "/" + RequestSpecificValues.Current_Mode.Remaining_Url_Segments[2];
			}

			// Write all the values in the left nav bar
			Output.WriteLine(add_leftnav_h2_link("Settings", "settings", redirectUrl, currentViewerCode));
			Output.WriteLine("        <ul>");

			// Add all the different setting options (tabpages) in the left nav bar
			int tab_count = 1;
			foreach (string tabPageName in tabPageNames.Values)
			{
				Output.WriteLine(add_leftnav_li_link(tabPageName.Trim(), "settings/" + tab_count, redirectUrl, currentViewerCode));
				//add_tab_page_info(Output, tabPageName, settingsByPage[tabPageName]);
				tab_count++;
			}
			Output.WriteLine("        </ul>");

			Output.WriteLine(add_leftnav_h2_link("Builder", "builder", redirectUrl, currentViewerCode));
			Output.WriteLine("        <ul>");
			Output.WriteLine(add_leftnav_li_link("Builder Settings", "builder/settings", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Incoming Folders", "builder/folders", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Builder Modules", "builder/modules", redirectUrl, currentViewerCode));
			Output.WriteLine("        </ul>");

			Output.WriteLine(add_leftnav_h2_link("Engine Configuration", "engine", redirectUrl, currentViewerCode));
			Output.WriteLine("        <ul>");
			Output.WriteLine(add_leftnav_li_link("Authentication", "engine/authentication", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Brief Item Mapping", "engine/briefitem", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Contact Form", "engine/contact", redirectUrl, currentViewerCode));  /** UI? **/
			Output.WriteLine(add_leftnav_li_link("Engine Server Endpoints", "engine/endpoints", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Metadata Readers/Writers", "engine/metadata", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("OAI-PMH Protocol", "engine/oaipmh", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Quality Control Tool", "engine/qctool", redirectUrl, currentViewerCode));    /** UI? **/
			Output.WriteLine("        </ul>");

			Output.WriteLine(add_leftnav_h2_link("UI Configuration", "ui", redirectUrl, currentViewerCode));
			Output.WriteLine("        <ul>");
			Output.WriteLine(add_leftnav_li_link("Citation Viewer", "ui/citation", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Map Editor", "ui/mapeditor", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Microservice Client Endpoints", "ui/microservices", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("Template Elements", "ui/template", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("HTML Viewers/Subviewers", "ui/viewers", redirectUrl, currentViewerCode));
			Output.WriteLine("        </ul>");

			Output.WriteLine(add_leftnav_h2_link("HTML Snippets", "html", redirectUrl, currentViewerCode));
			Output.WriteLine("        <ul>");
			Output.WriteLine(add_leftnav_li_link("Missing page", "html/missing", redirectUrl, currentViewerCode));
			Output.WriteLine(add_leftnav_li_link("No results", "html/noresults", redirectUrl, currentViewerCode));
			Output.WriteLine("        </ul>");

			Output.WriteLine(add_leftnav_h2_link("Extensions", "extensions", redirectUrl, currentViewerCode));
			if ((UI_ApplicationCache_Gateway.Configuration.Extensions != null) && (UI_ApplicationCache_Gateway.Configuration.Extensions.Extensions != null) && (UI_ApplicationCache_Gateway.Configuration.Extensions.Extensions.Count > 0))
			{
				Output.WriteLine("        <ul>");
				int extensionNumber = 1;
				foreach (ExtensionInfo thisExtension in UI_ApplicationCache_Gateway.Configuration.Extensions.Extensions)
				{
					Output.WriteLine(add_leftnav_li_link(thisExtension.Name, "extensions/" + extensionNumber, redirectUrl, currentViewerCode));
					extensionNumber++;
				}
				Output.WriteLine("        </ul>");
			}
			Output.WriteLine("    </td>");

			// Determine the main mode for this
			Settings_Mode_Enum mainMode = Settings_Mode_Enum.NONE;
			if ((RequestSpecificValues.Current_Mode.Remaining_Url_Segments != null) && (RequestSpecificValues.Current_Mode.Remaining_Url_Segments.Length > 0))
			{
				switch (RequestSpecificValues.Current_Mode.Remaining_Url_Segments[0].ToLower())
				{
					case "settings":
						mainMode = Settings_Mode_Enum.Settings;
						break;

					case "builder":
						mainMode = Settings_Mode_Enum.Builder;
						break;

					case "engine":
						mainMode = Settings_Mode_Enum.Engine;
						break;

					case "ui":
						mainMode = Settings_Mode_Enum.UI;
						break;

					case "html":
						mainMode = Settings_Mode_Enum.HTML;
						break;

					case "extensions":
						mainMode = Settings_Mode_Enum.Extensions;
						break;
				}
			}

			// Start the main area
			Output.WriteLine("    <td id=\"sbkSeav_MainArea\">");

			Output.WriteLine("<div class=\"sbkAdm_HomeText\">");

			if (actionMessage.Length > 0)
			{
				Output.WriteLine("  <br />");
				Output.WriteLine("  <div id=\"sbkAdm_ActionMessage\">" + actionMessage + "</div>");
			}

			// Add the content, based on the main mode
			switch (mainMode)
			{
				case Settings_Mode_Enum.NONE:
					add_top_level_info(Output);
					break;

				case Settings_Mode_Enum.Settings:
					add_settings_info(Output);
					break;

				case Settings_Mode_Enum.Builder:
					add_builder_info(Output);
					break;

				case Settings_Mode_Enum.Engine:
					add_engine_info(Output);
					break;

				case Settings_Mode_Enum.UI:
					add_ui_info(Output);
					break;

				case Settings_Mode_Enum.HTML:
					add_html_info(Output);
					break;

				case Settings_Mode_Enum.Extensions:
					add_extensions_info(Output);
					break;
			}


			Output.WriteLine("<br />");
			Output.WriteLine("<br />");


			Output.WriteLine("  <br />");
			Output.WriteLine("</div>");


			Output.WriteLine("    </td>");
			Output.WriteLine("  </tr>");
			Output.WriteLine("</table>");

			Output.WriteLine();
		}

		#region HTML helper methods for the left TOC portion 

		private static string add_leftnav_h2_link(string Text, string LinkCode, string RedirectUrl, string CurrentLinkCode )
		{
			if ( String.Compare(LinkCode, CurrentLinkCode, StringComparison.OrdinalIgnoreCase) == 0 )
				return "      <h2 id=\"sbkSeav_TocArea_SelectedH2\">" + Text + "</h2>";
			return "      <h2><a href=\"" + RedirectUrl.Replace("%SETTINGSCODE%", LinkCode) + "\">" + Text + " </a></h2>";
		}

		private static string add_leftnav_li_link(string Text, string LinkCode, string RedirectUrl, string CurrentLinkCode)
		{
			if (String.Compare(LinkCode, CurrentLinkCode, StringComparison.OrdinalIgnoreCase) == 0)
				return "      <li id=\"sbkSeav_TocArea_SelectedLI\">" + Text + "</li>";
			return "          <li><a href=\"" + RedirectUrl.Replace("%SETTINGSCODE%", LinkCode) + "\">" + Text + " </a></li>";
		}

		#endregion

		#region HTML helper methods for snippets used in multiple spots, like buttons

		private void add_buttons(TextWriter Output)
		{
			Output.WriteLine("  <div class=\"sbkSeav_ButtonsDiv\">");
			if (RequestSpecificValues.Current_User.Is_System_Admin)
			{

				Output.WriteLine("    <button title=\"Do not apply changes\" class=\"sbkAdm_RoundButton\" onclick=\"window.location.href='" + RequestSpecificValues.Current_Mode.Base_URL + "my/admin'; return false;\"><img src=\"" + Static_Resources.Button_Previous_Arrow_Png + "\" class=\"sbkAdm_RoundButton_LeftImg\" alt=\"\" /> CANCEL</button> &nbsp; &nbsp; ");
				Output.WriteLine("    <button title=\"Save changes\" class=\"sbkAdm_RoundButton\" onclick=\"admin_settings_save(); return false;\">SAVE <img src=\"" + Static_Resources.Button_Next_Arrow_Png + "\" class=\"sbkAdm_RoundButton_RightImg\" alt=\"\" /></button>");
			}
			else
			{
				Output.WriteLine("    <button class=\"sbkAdm_RoundButton\" onclick=\"window.location.href='" + RequestSpecificValues.Current_Mode.Base_URL + "my/admin'; return false;\"><img src=\"" + Static_Resources.Button_Previous_Arrow_Png + "\" class=\"sbkAdm_RoundButton_LeftImg\" alt=\"\" /> BACK</button> &nbsp; &nbsp; ");
			}
			Output.WriteLine("  </div>");
			Output.WriteLine();
		}

		#endregion

		#region HTML helper method for the top-level information page

		private void add_top_level_info(TextWriter Output)
		{
			Output.WriteLine("TOP LEVEL INFO HERE");
		}

		#endregion

		#region HTML helper methods for the settings main page and subpages

		private void add_settings_info(TextWriter Output)
		{
			int tabPage = -1;
			if ((RequestSpecificValues.Current_Mode.Remaining_Url_Segments != null) && (RequestSpecificValues.Current_Mode.Remaining_Url_Segments.Length > 1))
			{
				if (!Int32.TryParse(RequestSpecificValues.Current_Mode.Remaining_Url_Segments[1], out tabPage))
					tabPage = -1;
			}

			if ((tabPage < 1) || ( tabPage > tabPageNames.Count ))
			{
				Output.WriteLine("SETTINGS TOP LEVEL PAGE");
			}
			else
			{
				string tabPageNameKey = tabPageNames.Keys[tabPage - 1];
				string tabPageName = tabPageNames[tabPageNameKey];
				Output.WriteLine("  <h2>" + tabPageName.Trim() + "</h2>");

				// Add the buttons
				add_buttons(Output);

				Output.WriteLine();
				add_tab_page_info(Output, tabPageName, settingsByPage[tabPageName]);

				Output.WriteLine("<br />");
				Output.WriteLine();

				// Add final buttons
				add_buttons(Output);
			}
		}

		private void build_setting_objects_for_display()
		{
			// First step, get all the tab headings (excluding Deprecated and Builder)
			// and also categorize the values by tab page to start with
			tabPageNames = new SortedList<string, string>();
			settingsByPage = new Dictionary<string, List<Admin_Setting_Value>>();
            builderSettings = new List<Admin_Setting_Value>();
			foreach (Admin_Setting_Value thisValue in currSettings.Settings)
			{
				// If this is hidden, just do nothing
				if (thisValue.Hidden) continue;

				// If deprecated skip here
                if (String.Compare(thisValue.TabPage, "Deprecated", StringComparison.OrdinalIgnoreCase) == 0) continue;

                // Handle builder settings separately
			    if (String.Compare(thisValue.TabPage, "Builder", StringComparison.OrdinalIgnoreCase) == 0)
			    {
			        builderSettings.Add(thisValue);
			        continue;
			    }

				// Was this tab page already added?
				if (!settingsByPage.ContainsKey(thisValue.TabPage))
				{
					// We are going to move 'General.." up to the front, others are in alphabetical order
					if (thisValue.TabPage.IndexOf("General", StringComparison.OrdinalIgnoreCase) == 0)
						tabPageNames.Add("00", thisValue.TabPage);
					else
						tabPageNames.Add(thisValue.TabPage, thisValue.TabPage);
					settingsByPage[thisValue.TabPage] = new List<Admin_Setting_Value> { thisValue };
				}
				else
				{
					settingsByPage[thisValue.TabPage].Add(thisValue);
				}
			}

			// Add some readonly configuration information from the config file
			// First, look for a server tab name
			string tabNameForConfig = null;
			foreach (string thisTabName in tabPageNames.Values)
			{
				if (thisTabName.IndexOf("Server", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					tabNameForConfig = thisTabName;
					break;
				}
			}
			if (String.IsNullOrEmpty(tabNameForConfig))
			{
				foreach (string thisTabName in tabPageNames.Values)
				{
					if (thisTabName.IndexOf("System", StringComparison.OrdinalIgnoreCase) >= 0)
					{
						tabNameForConfig = thisTabName;
						break;
					}
				}
			}
			if (String.IsNullOrEmpty(tabNameForConfig))
			{
				tabNameForConfig = tabPageNames.Values[0];
			}

			// Build the values to add
			Admin_Setting_Value dbString = new Admin_Setting_Value
			{
				Heading = "Configuration Settings",
				Help = "Connection string used to connect to the SobekCM database\n\nThis value resides in the configuration file on the web server.  See your database and web server administrator to change this value.",
				Hidden = false,
				Key = "Database Connection String",
				Reserved = 3,
				SettingID = 9990,
				Value = UI_ApplicationCache_Gateway.Settings.Database_Connections[0].Connection_String
			};

			Admin_Setting_Value dbType = new Admin_Setting_Value
			{
				Heading = "Configuration Settings",
				Help = "Type of database used to drive the SobekCM system.\n\nCurrently, only Microsoft SQL Server is allowed with plans to add PostgreSQL and MySQL to the supported database system.\n\nThis value resides in the configuration on the web server.  See your database and web server administrator to change this value.",
				Hidden = false,
				Key = "Database Type",
				Reserved = 3,
				SettingID = 9991,
				Value = UI_ApplicationCache_Gateway.Settings.Database_Connections[0].Database_Type_String
			};

			Admin_Setting_Value isHosted = new Admin_Setting_Value
			{
				Heading = "Configuration Settings",
				Help = "Flag indicates if this instance is set as 'hosted', in which case a new Host Administrator role is added and some rights are reserved to that role which are normally assigned to system administrators.\n\nThis value resides in the configuration on the web server.  See your database and web server administrator to change this value.",
				Hidden = false,
				Key = "Hosted Intance",
				Reserved = 3,
				SettingID = 9994,
				Value = UI_ApplicationCache_Gateway.Settings.Servers.isHosted.ToString().ToLower()
			};

			Admin_Setting_Value errorEmails = new Admin_Setting_Value
			{
				Heading = "Configuration Settings",
				Help = "Email address for the web application to mail for any errors encountered while executing requests.\n\nThis account will be notified of inabilities to connect to servers, potential attacks, missing files, etc..\n\nIf the system is able to connect to the database, the 'System Error Email' address listed there, if there is one, will be used instead.\n\nUse a semi-colon betwen email addresses if multiple addresses are included.\n\nExample: 'person1@corp.edu;person2@corp2.edu'.\n\nThis value resides in the web.config file on the web server.  See your web server administrator to change this value.",
				Hidden = false,
				Key = "Error Emails",
				Reserved = 3,
				SettingID = 9992,
				Value = UI_ApplicationCache_Gateway.Settings.Email.System_Error_Email
			};

			Admin_Setting_Value errorWebPage = new Admin_Setting_Value
			{
				Heading = "Configuration Settings",
				Help = "Static page the user should be redirected towards if an unexpected exception occurs which cannot be handled by the web application.\n\nExample: 'http://ufdc.ufl.edu/error.html'.\n\nThis value resides in the web.config file on the web server.  See your web server administrator to change this value.",
				Hidden = false,
				Key = "Error Web Page",
				Reserved = 3,
				SettingID = 9993,
				Value = UI_ApplicationCache_Gateway.Settings.Servers.System_Error_URL
			};

			// Add them all to the tab page
			List<Admin_Setting_Value> settings = settingsByPage[tabNameForConfig];
			settings.Add(dbType);
			settings.Add(dbString);
			settings.Add(isHosted);
			settings.Add(errorEmails);
			settings.Add(errorWebPage);


		}

	    private void add_tab_page_info(TextWriter Output, string TabPageName, List<Admin_Setting_Value> AdminSettingValues, string OmitHeading = null)
		{
			// Start this table
			Output.WriteLine("        <table class=\"sbkSeav_SettingsTable\">");

			// Is this set for categorized via subheadings?
			if (category_view)
			{
				// Sort these admin settings within the headings
				SortedList<string, string> headingSorted = new SortedList<string, string>();
				Dictionary<string, SortedList<string, Admin_Setting_Value>> headingValuesSorted = new Dictionary<string, SortedList<string, Admin_Setting_Value>>();

				foreach (Admin_Setting_Value thisValue in AdminSettingValues)
				{
					if (!headingSorted.ContainsKey(thisValue.Heading))
					{
						headingSorted.Add(thisValue.Heading, thisValue.Heading);
						SortedList<string, Admin_Setting_Value> sortedList = new SortedList<string, Admin_Setting_Value> { { thisValue.Key, thisValue } };
						headingValuesSorted[thisValue.Heading] = sortedList;
					}
					else
					{
						headingValuesSorted[thisValue.Heading].Add(thisValue.Key, thisValue);
					}
				}

				// For now, just draw these
				bool firstHeading = true;
				bool oddRow = true;
				foreach (string thisHeading in headingSorted.Values)
				{
                    // If there was a heading value to omit, skip it here
				    if ((!String.IsNullOrEmpty(OmitHeading)) && (String.Compare(OmitHeading, thisHeading, StringComparison.OrdinalIgnoreCase) == 0))
				        continue;

					// Add a general heading
					Add_Setting_Table_Heading(Output, thisHeading, firstHeading);
					foreach (Admin_Setting_Value thisValueD in headingValuesSorted[thisHeading].Values)
					{
						// If this should be hidden, hide it
						if ((limitedRightsMode) && (thisValueD.Reserved >= 2)) continue;

						// Add this settings
						Add_Setting_Table_Setting(Output, thisValueD, oddRow);
						oddRow = !oddRow;
					}

					firstHeading = false;
				}
			}
			else  // Just add all the values alphabetically witout headers
			{
				// Sort these admin settings
				SortedList<string, Admin_Setting_Value> valuesSorted = new SortedList<string, Admin_Setting_Value>();

                // Add each value alphabetically
                // If there was a heading value to omit, skip it here
			    if (!String.IsNullOrEmpty(OmitHeading))
			    {
			        foreach (Admin_Setting_Value thisValue in AdminSettingValues)
			        {
			            if (String.Compare(OmitHeading, thisValue.Heading, StringComparison.OrdinalIgnoreCase) == 0)
			                continue;
			            valuesSorted[thisValue.Key] = thisValue;
			        }
			    }
			    else
			    {
			        foreach (Admin_Setting_Value thisValue in AdminSettingValues)
			        {
			            valuesSorted[thisValue.Key] = thisValue;
			        }
			    }

			    // Add a general heading
				Add_Setting_Table_Heading(Output, TabPageName, true);

				bool oddRow = true;
				foreach (Admin_Setting_Value thisValueD in valuesSorted.Values)
				{
					// If this should be hidden, hide it
					if ((limitedRightsMode) && (thisValueD.Reserved >= 2)) continue;

					// Add this settings
					Add_Setting_Table_Setting(Output, thisValueD, oddRow);
					oddRow = !oddRow;
				}
			}

			// Close this tab
			Output.WriteLine("        </table>");
		}

		private void Add_Setting_Table_Heading(TextWriter Output, string Heading, bool IsFirst)
		{
			Output.WriteLine("          <tr>");

			if (IsFirst)
			{
				Output.WriteLine("            <th colspan=\"2\">");
				Output.WriteLine("              " + Heading.ToUpper());
				Output.WriteLine("              <div style=\"float: right; text-align:right; padding-right: 40px;text-transform:none\">Order: <select id=\"reorder_select\" name=\"reorder_select\" onchange=\"settings_reorder(this);\"><option value=\"alphabetical\" selected=\"selected\">Alphabetical</option><option value=\"category\">Categories</option></select></div>");
				Output.WriteLine("            </th>");
			}
			else
			{
				Output.WriteLine("            <th colspan=\"2\">" + Heading.ToUpper() + "</th>");
			}

			Output.WriteLine("          </tr>");
		}

		private void Add_Setting_Table_Setting(TextWriter Output, Admin_Setting_Value Value, bool OddRow)
		{
			// Determine how to show this
			bool constant = Is_Value_ReadOnly(Value, readonlyMode, limitedRightsMode);

			Output.WriteLine(OddRow
					 ? "          <tr class=\"sbkSeav_TableEvenRow\">"
					 : "          <tr class=\"sbkSeav_TableOddRow\">");

			if (constant)
				Output.WriteLine("            <td class=\"sbkSeav_TableKeyCell\">" + Value.Key + ":</td>");
			else
				Output.WriteLine("            <td class=\"sbkSeav_TableKeyCell\"><label for=\"setting" + Value.SettingID + "\">" + Value.Key + "</label>:</td>");

			Output.WriteLine("            <td>");


			if (constant)
				Output.WriteLine("              <table class=\"sbkSeav_InnerTableConstant\">");
			else
				Output.WriteLine("              <table class=\"sbkSeav_InnerTable\">");
			Output.WriteLine("                <tr style=\"vertical-align:middle;border:0;\">");
			Output.WriteLine("                  <td style=\"max-width: 650px;\">");

			// Determine how to show this
			if (constant)
			{
				// Readonly for this value
				if (String.IsNullOrWhiteSpace(Value.Value))
				{
					Output.WriteLine("                    <em>( no value )</em>");
				}
				else
				{
					Output.WriteLine("                    " + HttpUtility.HtmlEncode(Value.Value).Replace(",", ", "));
				}
			}
			else
			{
				// Get the value, for easy of additional checks
				string setting_value = String.IsNullOrEmpty(Value.Value) ? String.Empty : Value.Value;


				if ((Value.Options != null) && (Value.Options.Count > 0))
				{

					Output.WriteLine("                    <select id=\"setting" + Value.SettingID + "\" name=\"setting" + Value.SettingID + "\" class=\"sbkSeav_select\" >");

					bool option_found = false;
					foreach (string thisValue in Value.Options)
					{
						if (String.Compare(thisValue, setting_value, StringComparison.OrdinalIgnoreCase) == 0)
						{
							option_found = true;
							Output.WriteLine("                      <option selected=\"selected\">" + setting_value + "</option>");
						}
						else
						{
							Output.WriteLine("                      <option>" + thisValue + "</option>");
						}
					}

					if (!option_found)
					{
						Output.WriteLine("                      <option selected=\"selected\">" + setting_value + "</option>");
					}
					Output.WriteLine("                    </select>");
				}
				else
				{
					if ((Value.Width.HasValue) && (Value.Width.Value > 0))
						Output.WriteLine("                    <input id=\"setting" + Value.SettingID + "\" name=\"setting" + Value.SettingID + "\" class=\"sbkSeav_input sbkAdmin_Focusable\" type=\"text\"  style=\"width: " + Value.Width + "px;\" value=\"" + HttpUtility.HtmlEncode(setting_value) + "\" />");
					else
						Output.WriteLine("                    <input id=\"setting" + Value.SettingID + "\" name=\"setting" + Value.SettingID + "\" class=\"sbkSeav_input sbkAdmin_Focusable\" type=\"text\" value=\"" + HttpUtility.HtmlEncode(setting_value) + "\" />");
				}
			}

			Output.WriteLine("                  </td>");
			Output.WriteLine("                  <td>");
			if (!String.IsNullOrEmpty(Value.Help))
				Output.WriteLine("                    <img  class=\"sbkSeav_HelpButton\" src=\"" + Static_Resources.Help_Button_Jpg + "\" onclick=\"alert('" + Value.Help.Replace("'", "").Replace("\"", "").Replace("\n", "\\n") + "');\"  title=\"" + Value.Help.Replace("'", "").Replace("\"", "").Replace("\n", "\\n") + "\" />");
			Output.WriteLine("                  </td>");
			Output.WriteLine("                </tr>");
			Output.WriteLine("              </table>");
			Output.WriteLine("            </td>");
			Output.WriteLine("          </tr>");
		}

		#region Methods related to special validations

		private bool validate_update_entered_data(List<Simple_Setting> newValues)
		{
			isValid = true;
			foreach (Simple_Setting thisSetting in newValues)
			{
				string value = thisSetting.Value;
				string key = thisSetting.Key;

				switch (key)
				{
					case "Application Server Network":
						must_end_with(thisSetting, "\\");
						break;

					case "Application Server URL":
						must_start_end_with(thisSetting, new string[] { "http://", "https://" }, "/");
						break;

					case "Document Solr Index URL":
						must_start_end_with(thisSetting, new string[] { "http://", "https://" }, "/");
						break;

					case "Files To Exclude From Downloads":
						must_be_valid_regular_expression(thisSetting);
						break;

					case "Image Server Network":
						must_end_with(thisSetting, "\\");
						break;

					case "Image Server URL":
						must_start_end_with(thisSetting, new string[] { "http://", "https://" }, "/");
						break;

					case "JPEG Height":
						must_be_positive_number(thisSetting);
						break;

					case "JPEG Width":
						must_be_positive_number(thisSetting);
						break;

					case "Log Files Directory":
						must_end_with(thisSetting, "\\");
						break;

					case "Log Files URL":
						must_start_end_with(thisSetting, new string[] { "http://", "https://" }, "/");
						break;

					case "Mango Union Search Base URL":
						must_start_with(thisSetting, new string[] { "http://", "https://" });
						break;

					case "Mango Union Search Text":
						if (value.Trim().Length > 0)
						{
							if (value.IndexOf("%1") < 0)
							{
								isValid = false;
								errorBuilder.AppendLine(key + ": Value must contain the '%1' string.  See help for more information.");
							}
						}
						break;

					case "MarcXML Feed Location":
						must_end_with(thisSetting, "\\");
						break;

					case "OAI Resource Identifier Base":
						must_end_with(thisSetting, ":");
						break;

					case "Page Solr Index URL":
						must_start_end_with(thisSetting, new string[] { "http://", "https://" }, "/");
						break;

					case "PostArchive Files To Delete":
						must_be_valid_regular_expression(thisSetting);
						break;

					case "PreArchive Files To Delete":
						must_be_valid_regular_expression(thisSetting);
						break;

					case "Static Pages Location":
						must_end_with(thisSetting, "\\");
						break;

					case "System Base Abbreviation":
						if (value.Trim().Length == 0)
						{
							isValid = false;
							errorBuilder.AppendLine(key + ": Field is required.");
						}
						break;

					case "System Base URL":
						if (value.Trim().Length == 0)
						{
							isValid = false;
							errorBuilder.AppendLine(key + ": Field is required.");
						}
						else
						{
							must_start_end_with(thisSetting, new string[] { "http://", "https://" }, "/");
						}
						break;

					case "Thumbnail Height":
						must_be_positive_number(thisSetting);
						break;

					case "Thumbnail Width":
						must_be_positive_number(thisSetting);
						break;

					case "Web In Process Submission Location":
						must_end_with(thisSetting, "\\");
						break;
				}
			}

			return isValid;
		}

		private void must_be_positive_number(Simple_Setting NewSetting)
		{
			bool appears_valid = false;
			int number;
			if ((Int32.TryParse(NewSetting.Value, out number)) && (number >= 0))
			{
				appears_valid = true;
			}

			if (!appears_valid)
			{
				isValid = false;
				errorBuilder.AppendLine(NewSetting.Key + ": Value must be a positive integer or zero.");
			}
		}

		private void must_be_valid_regular_expression(Simple_Setting NewSetting)
		{
			if (NewSetting.Value.Length == 0)
				return;

			// This is really just a check that it is a valid regular expression by 
			// attempting to perform a regular expression match.  The match itself 
			// ( and the resulting value ) is not important.
			try
			{
				Regex.Match("any_old_file.tif", NewSetting.Value);
			}
			catch (ArgumentException)
			{
				isValid = false;
				errorBuilder.AppendLine(NewSetting.Key + ": Value must be empty or a valid regular expression.");
			}
		}

		private static void must_start_with(Simple_Setting NewSetting, string StartsWith)
		{
			if (NewSetting.Value.Length == 0)
				return;

			if (!NewSetting.Value.StartsWith(StartsWith, StringComparison.OrdinalIgnoreCase))
			{
				NewSetting.Value = StartsWith + NewSetting.Value;
			}
		}

		private static void must_start_with(Simple_Setting NewSetting, string[] StartsWith)
		{
			if (NewSetting.Value.Length == 0)
				return;

			// Check for the start against all possible combinations
			bool missing_start = true;
			foreach (string possibleStart in StartsWith)
			{
				if (NewSetting.Value.StartsWith(possibleStart, StringComparison.OrdinalIgnoreCase))
				{
					missing_start = false;
					break;
				}
			}

			if (missing_start)
			{
				NewSetting.Value = StartsWith[0] + NewSetting.Value;
			}
		}

		private static void must_end_with(Simple_Setting NewSetting, string EndsWith)
		{
			if (NewSetting.Value.Length == 0)
				return;

			if (!NewSetting.Value.EndsWith(EndsWith, StringComparison.OrdinalIgnoreCase))
			{
				NewSetting.Value = NewSetting.Value + EndsWith;
			}
		}

		private static void must_start_end_with(Simple_Setting NewSetting, string StartsWith, string EndsWith)
		{
			if (NewSetting.Value.Length == 0)
				return;

			if ((!NewSetting.Value.StartsWith(StartsWith, StringComparison.OrdinalIgnoreCase)) || (!NewSetting.Value.EndsWith(EndsWith, StringComparison.InvariantCultureIgnoreCase)))
			{
				if (!NewSetting.Value.StartsWith(StartsWith, StringComparison.OrdinalIgnoreCase))
					NewSetting.Value = StartsWith + NewSetting.Value;
				if (!NewSetting.Value.EndsWith(EndsWith, StringComparison.OrdinalIgnoreCase))
					NewSetting.Value = NewSetting.Value + EndsWith;
			}
		}

		private static void must_start_end_with(Simple_Setting NewSetting, string[] StartsWith, string EndsWith)
		{
			if (NewSetting.Value.Length == 0)
				return;

			// Check for the start against all possible combinations
			bool missing_start = true;
			foreach (string possibleStart in StartsWith)
			{
				if (NewSetting.Value.StartsWith(possibleStart, StringComparison.OrdinalIgnoreCase))
				{
					missing_start = false;
					break;
				}
			}

			if ((missing_start) || (!NewSetting.Value.EndsWith(EndsWith, StringComparison.OrdinalIgnoreCase)))
			{
				if (missing_start)
					NewSetting.Value = StartsWith[0] + NewSetting.Value;
				if (!NewSetting.Value.EndsWith(EndsWith, StringComparison.OrdinalIgnoreCase))
					NewSetting.Value = NewSetting.Value + EndsWith;
			}
		}

		#endregion

		#endregion

		#region HTML helper methods for the builder main page and subpages

		private void add_builder_info(TextWriter Output)
		{
            // Determine the submode
		    Settings_Builder_SubMode_Enum builderSubEnum = Settings_Builder_SubMode_Enum.NONE;
		    if (RequestSpecificValues.Current_Mode.Remaining_Url_Segments.Length > 1)
		    {
		        switch (RequestSpecificValues.Current_Mode.Remaining_Url_Segments[1].ToLower())
		        {
		            case "settings":
                        builderSubEnum = Settings_Builder_SubMode_Enum.Builder_Settings;
		                break;

                    case "folders":
                        builderSubEnum = Settings_Builder_SubMode_Enum.Builder_Folders;
		                break;

                    case "modules":
                        builderSubEnum = Settings_Builder_SubMode_Enum.Builder_Modules;
		                break;
		        }
		    }

            // If a submode existed, call that method
		    switch (builderSubEnum)
		    {
		        case Settings_Builder_SubMode_Enum.Builder_Settings:
		            add_builder_settings_info(Output);
		            break;

		        case Settings_Builder_SubMode_Enum.Builder_Folders:
		            add_builder_folders_info(Output);
		            break;

		        case Settings_Builder_SubMode_Enum.Builder_Modules:
		            add_builder_modules_info(Output);
		            break;

                default:
		            add_builder_toplevel_info(Output);
		            break;
		    }
		}

	    private void add_builder_toplevel_info(TextWriter Output)
	    {
            // Look for some values
	        string lastRun = String.Empty;
	        string builderVersion = String.Empty;
	        string lastResult = String.Empty;
	        string currentBuilderMode = String.Empty;
	        foreach (Admin_Setting_Value thisValue in builderSettings)
	        {
	            switch (thisValue.Key.ToLower())
	            {
                    case "builder last run finished":
	                    lastRun = thisValue.Value;
	                    break;

                    case "builder version":
	                    builderVersion = thisValue.Value;
	                    break;

                    case "builder last message":
	                    lastResult = thisValue.Value;
	                    break;

                    case "builder operation flag":
	                    currentBuilderMode = thisValue.Value;
	                    break;
	            }
	        }
            
            Output.WriteLine("  <h2>Builder Information</h2>");

            Output.WriteLine("  <table style=\"padding-left:50px\">");
            Output.WriteLine("    <tr><td>Last Run:</td><td>" + lastRun + "</td></tr>");
            Output.WriteLine("    <tr><td>Last Result:</td><td>" + lastResult + "</td></tr>");
            Output.WriteLine("    <tr><td>Builder Version:</td><td>" + builderVersion + "</td></tr>");
            Output.WriteLine("    <tr><td>Builder Operation:</td><td>" + currentBuilderMode + "</td></tr>");
            Output.WriteLine("  </table>");

            // Look to see if any builder folders exist
	        if ((UI_ApplicationCache_Gateway.Settings.Builder.IncomingFolders == null) || (UI_ApplicationCache_Gateway.Settings.Builder.IncomingFolders.Count == 0))
	        {
	            Output.WriteLine("  <br /><br />");
                Output.WriteLine("  <strong>YOU HAVE NO BUILDER FOLDERS DEFINED!!</strong>");
	        }


	    }

        private void add_builder_settings_info(TextWriter Output)
        {
            Output.WriteLine("  <h2>Builder Settings</h2>");

            // Add the buttons
            add_buttons(Output);

            Output.WriteLine();
            add_tab_page_info(Output, "Builder Settings", builderSettings, "Status");

            Output.WriteLine("<br />");
            Output.WriteLine();

            // Add final buttons
            add_buttons(Output);
        }

        private void add_builder_folders_info(TextWriter Output)
        {
            Output.WriteLine("  <h2>Builder Folders</h2>");

            // Look to see if any builder folders exist
            if ((UI_ApplicationCache_Gateway.Settings.Builder.IncomingFolders == null) || (UI_ApplicationCache_Gateway.Settings.Builder.IncomingFolders.Count == 0))
            {
                Output.WriteLine("  <br /><br />");
                Output.WriteLine("  <strong>YOU HAVE NO BUILDER FOLDERS DEFINED!!</strong>");
                return;
            }

            // Show the information for each builder folder
            foreach (Builder_Source_Folder incomingFolder in UI_ApplicationCache_Gateway.Settings.Builder.IncomingFolders)
            {
                // Add the basic folder information
                Output.WriteLine("  <span class=\"sbkSeav_BuilderFolderName\">" + incomingFolder.Folder_Name + "</span>");
                Output.WriteLine("  <table class=\"sbkSeav_BuilderFolderTable\">");
                Output.WriteLine("    <tr><td>Network Folder:</td><td>" +  incomingFolder.Inbound_Folder + "</td></tr>");
                Output.WriteLine("    <tr><td>Processing Folder:</td><td>" + incomingFolder.Processing_Folder + "</td></tr>");
                Output.WriteLine("    <tr><td>Error Folder:</td><td>" + incomingFolder.Failures_Folder + "</td></tr>");

                // If there are BibID restrictions, add them
                if ( !String.IsNullOrEmpty(incomingFolder.BibID_Roots_Restrictions))
                    Output.WriteLine("    <tr><td>BibID Restrictions:</td><td>" + incomingFolder.BibID_Roots_Restrictions + "</td></tr>");

                // Collect all the options and display them
                StringBuilder builder = new StringBuilder();
                if (incomingFolder.Allow_Deletes) builder.Append("Allow deletes ; ");
                if (incomingFolder.Allow_Folders_No_Metadata) builder.Append("Allow folder with no metadata ; ");
                if (incomingFolder.Allow_Metadata_Updates) builder.Append("Allow metadata updates ; ");
                if (incomingFolder.Archive_All_Files) builder.Append("Archive all files ; ");
                else if (incomingFolder.Archive_TIFFs) builder.Append("Archive TIFFs ; ");
                if (incomingFolder.Perform_Checksum) builder.Append("Perform checksum ; ");
                Output.WriteLine("    <tr><td>Options</td><td>" + builder.ToString() + "</td></tr>");
            
                // Add the possible actions here
                Output.WriteLine("    <tr><td>Actions:</td><td><a href=\"" + RequestSpecificValues.Current_Mode.Base_URL + "admin/builderfolders/" + incomingFolder.IncomingFolderID + "\">edit</a></td></tr>");
                Output.WriteLine("  </table>");
            }
        }

        private void add_builder_modules_info(TextWriter Output)
        {
            Output.WriteLine("  <h2>Builder Modules</h2>");

            // Add all the PRE PROCESS MODULE settings
            Output.WriteLine("  <h3>Pre-Process Modules</h3>");
            if ((UI_ApplicationCache_Gateway.Settings.Builder.PreProcessModulesSettings != null) && (UI_ApplicationCache_Gateway.Settings.Builder.PreProcessModulesSettings.Count > 0))
            {
                foreach (Builder_Module_Setting thisModule in UI_ApplicationCache_Gateway.Settings.Builder.PreProcessModulesSettings)
                {
                    thisModule.ToString()

                    // Order
                    // Class (enabled/disabled)
                    // Assembly 
                    // Description
                    // Arguments (1-3)


                   
                }

            }
            else
            {
                Output.WriteLine("  <strong>NO PRE-PROCESS MODULES SET!<strong>");
                Output.WriteLine("  <br /><br />");                
            }


            UI_ApplicationCache_Gateway.Settings.Builder.ItemDeleteModulesSettings;

            UI_ApplicationCache_Gateway.Settings.Builder.ItemProcessModulesSettings;


            UI_ApplicationCache_Gateway.Settings.Builder.PostProcessModulesSettings;



            // if ( UI_ApplicationCache_Gateway.Settings.Builder.)
        }

	    #endregion


		#region HTML helper methods for the engine main page and subpages

		private void add_engine_info(TextWriter Output)
		{
			Output.WriteLine("ENGINE INFO HERE");
		}

		#endregion


		#region HTML helper methods for the UI main page and subpages

		private void add_ui_info(TextWriter Output)
		{
			Output.WriteLine("UI INFO HERE");
		}

		#endregion


		#region HTML helper methods for the HTML snippets main page and subpages

		private void add_html_info(TextWriter Output)
		{
			Output.WriteLine("HTML INFO HERE");
		}

		#endregion


		#region HTML helper methods for the extensions main page and subpages

		private void add_extensions_info(TextWriter Output)
		{
			Output.WriteLine("EXTENSIONS INFO HERE");
		}

		#endregion


		/// <summary> Gets the CSS class of the container that the page is wrapped within </summary>
		/// <value> Returns 'sbkAsav_ContainerInner' </value>
		public override string Container_CssClass { get { return "sbkSeav_ContainerInner"; } }

	}
}