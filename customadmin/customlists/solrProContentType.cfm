<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Pro Content Type Admin --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (jeff@jeffcoughlin.com)--->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<admin:header title="Solr Pro Content Type Admin" />

<ft:processForm action="resetCollection">
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset stContentType = oContentType.getData(form.selectedObjectId) />
	<cfset oContentType.deleteByTypename(typename = stContentType.contentType, bCommit = true) />
	<cfset stContentType.builtToDate = "" />
	<cfset oContentType.setData(stContentType) />
	<skin:bubble title="Reset Collection" message="#stContentType.title# has been reset" />
</ft:processForm>

<ft:processForm action="Optimize All">
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset oContentType.optimize() />
	<skin:bubble title="Optimize" message="The Solr collection has been optimized." />
</ft:processForm>

<ft:processForm action="Reset All">
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset oContentType.resetIndex() />
	<cfset qContentTypes = oContentType.getAllContentTypes() />
	<cfloop query="qContentTypes">
		<cfset stContentType = oContentType.getData(qContentTypes.objectid[qContentTypes.currentRow]) />
		<cfset stContentType.builtToDate = "" />
		<cfset oContentType.setData(stContentType) />
	</cfloop>
	<skin:bubble title="Reset All" message="Solr has been reset." />
</ft:processForm>

<ft:processForm action="indexCollection">
	<cfsetting requesttimeout="9999" />
	<cfset oContentType = application.fapi.getContentType("solrProContentType") />
	<cfset stContentType = oContentType.getData(form.selectedObjectId) />
	<cfset stResult = oContentType.indexRecords(lContentTypeIds = stContentType.objectid) />
	<skin:bubble title="Index Collection" message="#stContentType.title# has been indexed. #stResult.aStats[1].indexRecordCount# items were indexed in #timeFormat(application.stPlugins.farcrysolrpro.oCustomFunctions.millisecondsToDate(stResult.processTime),'HH:mm:ss')#" />
</ft:processForm>

<cfscript>
	aButtons = [
		{ value = "Add", permission = 1, onclick = "" },
		{ value = "Delete", permission = 1, onclick = "", confirmText = "Are you sure you wish to delete these objects?" },
		{ value = "Unlock", permission = 1, onclick = "" },
		{ value = "Optimize All", permission = 1, onclick = "" },
		{ value = "Reset All", permission = 1, onclick = "", confirmText = "This will clear all records from Solr, are you sure you wish to do this?" }
	];
</cfscript>

<cfif application.fapi.getConfig(key = 'solrserver', name = 'bConfigured', default = false) eq true>

<cftry>

	<ft:objectadmin 
		typename="solrProContentType"
		columnList="title,contentType,datetimecreated" 
		sortableColumns="title,contentType,datetimelastUpdated"
		lCustomColumns="Current Index Count:displayCellCurrentIndexCount"
		lFilterFields="title,contentType"
		sqlorderby="title"
		aButtons="#aButtons#"
		lButtons="Add,Delete,Unlock,Optimize All,Reset All"
		plugin="farcrysolrpro"
		lCustomActions="resetCollection:Reset Collection,indexCollection:Index Collection" />
		
	<cfcatch>
		
		<cfoutput><p><br />Error loading object admin, be sure you have deployed all COAPI objects.</p></cfoutput>
		
	</cfcatch>

</cftry>

<cfelse>
	<cfset linkConfig = application.url.webroot & "/webtop/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
	<cfoutput><p>You must <a href="#linkConfig#">configure the Solr settings</a> before you can define any content types.</p></cfoutput>
</cfif>

<admin:footer />

<cfsetting enablecfoutputonly="false" />