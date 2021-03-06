﻿using System;
using System.Collections.Generic;
using System.Threading;
using SobekCM.Resource_Object;
using SobekCM.Resource_Object.Solr;
using SolrNet;

namespace SobekCM.Engine_Library.Solr.v5
{
    /// <summary> New controller class is used for indexing documents within a SobekCM library or single item aggregation within a SobekCM library </summary>
    public class v5_Solr_Controller : iSolr_Controller
    {
        /// <summary> Indexes a single digital resource within a SobekCM library </summary>
        /// <param name="SolrDocumentUrl"> URL for the solr/lucene core used for searching for a single document within the library </param>
        /// <param name="SolrPageUrl"> URL for the solr/lucene core used for searching within a single document for matching pages </param>
        /// <param name="Resource"> Digital resource to index</param>
        /// <param name="Include_Text"> Flag indicates whether to look for and include full text </param>
        public void Update_Index(string SolrDocumentUrl, string SolrPageUrl, SobekCM_Item Resource, bool Include_Text)
        {
            // Get rid of trailling '/' in solr document url
            SolrDocumentUrl = SolrDocumentUrl.Trim();
            if ((!String.IsNullOrEmpty(SolrDocumentUrl)) && (SolrDocumentUrl[SolrDocumentUrl.Length - 1] == '/'))
                SolrDocumentUrl = SolrDocumentUrl.Substring(0, SolrDocumentUrl.Length - 1);

            // Get rid of trailling '/' in solr page url
            SolrPageUrl = SolrPageUrl.Trim();
            if ((!String.IsNullOrEmpty(SolrPageUrl)) && (SolrPageUrl[SolrPageUrl.Length - 1] == '/'))
                SolrPageUrl = SolrPageUrl.Substring(0, SolrPageUrl.Length - 1);


            // Create the solr workers
            var solrDocumentWorker = Solr_Operations_Cache<v5_SolrDocument>.GetSolrOperations(SolrDocumentUrl);
            var solrPageWorker = Solr_Operations_Cache<Legacy_SolrPage>.GetSolrOperations(SolrPageUrl);

            // Get the list of all items in this collection
            List<v5_SolrDocument> index_files = new List<v5_SolrDocument>();
            List<Legacy_SolrPage> index_pages = new List<Legacy_SolrPage>();

            // Add this document to the list of documents to index
            v5_SolrDocument_Builder builder = new v5_SolrDocument_Builder();
            v5_SolrDocument solrDocument = builder.Build_Solr_Document(Resource, Resource.Source_Directory);
            index_files.Add(solrDocument);

            bool document_success = false;
            int document_attempts = 0;
            while (!document_success)
            {
                try
                {
                    solrDocumentWorker.AddRange(index_files);
                    document_success = true;
                }
                catch (Exception ee)
                {
                    if (document_attempts > 5)
                    {
                        throw;
                    }
                    document_attempts++;
                    Console.WriteLine(@"ERROR {0}", document_attempts);
                    Thread.Sleep(document_attempts * 1000);
                }
            }

            // Add each page to be indexed
            foreach (v5_SolrDocument document in index_files)
            {
                index_pages.AddRange(document.Solr_Pages);
            }


            bool page_success = false;
            int page_attempts = 0;
            while (!page_success)
            {
                try
                {
                    solrPageWorker.Add(index_pages);
                    page_success = true;
                }
                catch (Exception ee)
                {
                    if (page_attempts > 5)
                    {
                        throw;
                    }
                    page_attempts++;
                    Thread.Sleep(page_attempts * 1000);
                }
            }

            // Comit the changes to the solr/lucene index
            try
            {
                solrDocumentWorker.Commit();
            }
            catch (Exception ee)
            {
                Thread.Sleep(10 * 60 * 1000);
            }

            try
            {
                solrPageWorker.Commit();
            }
            catch (Exception ee)
            {
                Thread.Sleep(10 * 60 * 1000);
            }
        }

        /// <summary> Deletes an existing resource from both solr/lucene core indexes </summary>
        /// <param name="SolrDocumentUrl"> URL for the solr/lucene core used for searching for a single document within the library </param>
        /// <param name="SolrPageUrl"> URL for the solr/lucene core used for searching within a single document for matching pages </param>
        /// <param name="BibID"> Bibliographic identifier for the item to remove from the solr/lucene indexes </param>
        /// <param name="VID"> Volume identifier for the item to remove from the solr/lucene indexes </param>
        /// <returns> TRUE if successful, otherwise FALSE </returns>
        public bool Delete_Resource_From_Index(string SolrDocumentUrl, string SolrPageUrl, string BibID, string VID)
        {
            try
            {

                // Get rid of trailling '/' in solr document url
                SolrDocumentUrl = SolrDocumentUrl.Trim();
                if ((!String.IsNullOrEmpty(SolrDocumentUrl)) && (SolrDocumentUrl[SolrDocumentUrl.Length - 1] == '/'))
                    SolrDocumentUrl = SolrDocumentUrl.Substring(0, SolrDocumentUrl.Length - 1);

                // Get rid of trailling '/' in solr page url
                SolrPageUrl = SolrPageUrl.Trim();
                if ((!String.IsNullOrEmpty(SolrPageUrl)) && (SolrPageUrl[SolrPageUrl.Length - 1] == '/'))
                    SolrPageUrl = SolrPageUrl.Substring(0, SolrPageUrl.Length - 1);

                // Create the solr workers
                var solrDocumentWorker = Solr_Operations_Cache<v5_SolrDocument>.GetSolrOperations(SolrDocumentUrl);
                var solrPageWorker = Solr_Operations_Cache<Legacy_SolrPage>.GetSolrOperations(SolrPageUrl);

                // For the object, we can use the unique identifier
                solrDocumentWorker.Delete(BibID + ":" + VID);

                // For the pages, we need to search by id
                solrPageWorker.Delete(new SolrQuery("did:\"" + BibID + ":" + VID + "\""));

                // Comit the changes to the solr/lucene index
                try
                {
                    solrDocumentWorker.Commit();
                }
                catch
                {
                    Thread.Sleep(10 * 60 * 1000);
                }

                try
                {
                    solrPageWorker.Commit();
                }
                catch
                {
                    Thread.Sleep(10 * 60 * 1000);
                }

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }



        /// <summary> Optimize the solr/lucene core used for searching for a single document </summary>
        /// <param name="SolrDocumentUrl"> URL for the solr/lucene core used for searching for a single document within the library </param>
        public void Optimize_Document_Index(string SolrDocumentUrl)
        {
            // Get rid of trailling '/' in solr document url
            SolrDocumentUrl = SolrDocumentUrl.Trim();
            if ((!String.IsNullOrEmpty(SolrDocumentUrl)) && (SolrDocumentUrl[SolrDocumentUrl.Length - 1] == '/'))
                SolrDocumentUrl = SolrDocumentUrl.Substring(0, SolrDocumentUrl.Length - 1);

            // Create the solr worker
            var solrDocumentWorker = Solr_Operations_Cache<v5_SolrDocument>.GetSolrOperations(SolrDocumentUrl);

            try
            {
                solrDocumentWorker.Optimize();
            }
            catch (Exception)
            {
                // Do not do anything here.  It may throw an exception when it runs very longs
            }
        }

        /// <summary> Optimize the solr/lucene core used for searching within a single document </summary>
        /// <param name="SolrPageUrl"> URL for the solr/lucene core used for searching within a single document for matching pages </param>
        public void Optimize_Page_Index(string SolrPageUrl)
        {
            // Get rid of trailling '/' in solr page url
            SolrPageUrl = SolrPageUrl.Trim();
            if ((!String.IsNullOrEmpty(SolrPageUrl)) && (SolrPageUrl[SolrPageUrl.Length - 1] == '/'))
                SolrPageUrl = SolrPageUrl.Substring(0, SolrPageUrl.Length - 1);

            // Create the solr worker
            var solrPageWorker = Solr_Operations_Cache<Legacy_SolrPage>.GetSolrOperations(SolrPageUrl);

            try
            {
                solrPageWorker.Optimize();
            }
            catch (Exception)
            {
                // Do not do anything here.  It may throw an exception when it runs very longs
            }
        }
    }
}
