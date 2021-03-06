<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Solr Search Log --->
<!--- @@author: Sean Coyne (www.n42designs.com), Jeff Coughlin (www.jeffcoughlin.com) --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<skin:loadJs id="jquery" />
<skin:loadJs id="jquery-ui" />
<skin:loadCss id="jquery-ui" />

<skin:onReady>
<cfoutput>
$j('input.datefield').datepicker();
</cfoutput>
</skin:onReady>

<admin:header title="Searches Without Results" />

<cfparam name="form.queryString" default="" />
<cfparam name="form.startDate" default="#dateAdd('m',-1,now())#" />
<cfparam name="form.endDate" default="#now()#" />

<cfset dateMask = "yyyy-mm-dd" />
<cfset timeMask = "short" />

<!--- this is here so the pagination will work --->
<cfset form.farcryFormSubmitButtonClickedSearchLog = "Submit" />

<ft:processForm action="Submit">
	
	<cfset oLog = application.fapi.getContentType("solrProSearchLog") />
	<cfset qResults = oLog.getSearchesWithoutResults(startDate = form.startDate, endDate = form.endDate, queryString = form.queryString) />
	
</ft:processForm>

<cfif application.fapi.getConfig(key = 'solrserver', name = 'bLogSearches', default = true) eq false>
	<cfoutput><p class="error">NOTE: Search logging is currently turned OFF.</p></cfoutput>
</cfif>

<cfif application.fapi.getConfig(key = 'solrserver', name = 'bConfigured', default = false) eq true>

<cfoutput><h1>Searches Without Results</h1></cfoutput>

<ft:form name="SearchLog">
	
	<ft:fieldset legend="Filter">
		
		<ft:field for="startDate" label="Start Date" hint="mm/dd/yyyy">
			<cfoutput>
			<input type="text" class="textInput datefield" name="startDate" id="endDate" value="#dateFormat(form.startDate,'mm/dd/yyyy')#" />
			</cfoutput>
		</ft:field>
		
		<ft:field for="endDate" label="End Date" hint="mm/dd/yyyy">
			<cfoutput>
			<input type="text" class="textInput datefield" name="endDate" id="endDate" value="#dateFormat(form.endDate,'mm/dd/yyyy')#" />
			</cfoutput>
		</ft:field>
		
		<ft:field for="queryString" label="Query String">
			<cfoutput>
			<input type="text" class="textInput" name="queryString" id="queryString" value="#form.queryString#" />
			</cfoutput>
		</ft:field>
		
		<ft:buttonPanel>
			<ft:button value="Submit" />
		</ft:buttonPanel>
		
	</ft:fieldset>

<cfif structKeyExists(variables,"qResults")>
	
	<skin:pagination submissionType="form" bDisplayTotalRecords="true" paginationId="" query="qResults" pageLinks="5">
	
	<cfif stObject.bFirst>
	<cfoutput>
	<table class="ui-widget ui-widget-content solrprotable">
		<thead>
			<tr class="ui-widget-header">
				<th>Query String</th>
				<th>Content Types</th>
				<th>Times Searched</th>
			</tr>
		</thead>
		<tbody>
	</cfoutput>
	</cfif>
			
			<cfoutput>
			<tr>
				<td>#qResults.q[stObject.recordsetRow]#</td>
				<td>#qResults.lContentTypes[stObject.recordsetRow]#</td>
				<td>#qResults.timesSearched[stObject.recordsetRow]#</td>
			</tr>
			</cfoutput>
			
	<cfif stObject.bLast>
	<cfoutput>		
		</tbody>
	</table>
	</cfoutput>
	</cfif>
	
	</skin:pagination>
	
</cfif>

</ft:form>

<cfelse>
	<cfset linkConfig = application.url.webtop & "/admin/customadmin.cfm?module=customlists/farConfig.cfm" />
	<cfoutput><p>You must <a href="#linkConfig#">configure the Solr settings</a> before you can run this report.</p></cfoutput>
</cfif>

<admin:footer />

<!--- Load Custom Webtop Styling (load after admin:header) --->
<skin:loadCss id="solrPro-customWebtopStyles" />

<cfsetting enablecfoutputonly="false" />