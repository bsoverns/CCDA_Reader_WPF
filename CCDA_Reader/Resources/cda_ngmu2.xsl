<?xml version="1.0" encoding="UTF-8"?>
<!--
  Title: CDA XSL StyleSheet
  Original Filename: cda.xsl 
  Version: 3.0
  Specification: ANSI/HL7 CDAR2
  The current version and documentation are available at http://www.lantanagroup.com/resources/tools/. 
  We welcome feedback and contributions to tools@lantanagroup.com
  The stylesheet is the cumulative work of several developers; the most significant prior milestones were the foundation work from HL7 
  Germany and Finland (Tyylitiedosto) and HL7 US (Calvin Beebe), and the presentation approach from Tony Schaller, medshare GmbH provided at IHIC 2009. 
-->
<!-- LICENSE INFORMATION
  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
  You may obtain a copy of the License at  http://www.apache.org/licenses/LICENSE-2.0 
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n1="urn:hl7-org:v3" xmlns:in="urn:lantana-com:inline-variable-data" xmlns:sdtc="urn:hl7-org:sdtc">
	<xsl:output method="html" indent="yes" version="4.01" encoding="ISO-8859-1" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"/>
	<xsl:param name="limit-external-images" select="'yes'"/>
	<!-- A vertical bar separated list of URI prefixes, such as "http://www.example.com|https://www.example.com" -->
	<xsl:param name="external-image-whitelist"/>
	<!-- string processing variables -->
	<xsl:variable name="lc" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<!-- removes the following characters, in addition to line breaks "':;?`{}“”„‚’ -->
	<xsl:variable name="simple-sanitizer-match">
		<xsl:text>&#10;&#13;&#34;&#39;&#58;&#59;&#63;&#96;&#123;&#125;&#8220;&#8221;&#8222;&#8218;&#8217;</xsl:text>
	</xsl:variable>
	<xsl:variable name="simple-sanitizer-replace" select="'***************'"/>
	<xsl:variable name="javascript-injection-warning">WARNING: Javascript injection attempt detected in source CDA document. Terminating</xsl:variable>
	<xsl:variable name="malicious-content-warning">WARNING: Potentially malicious content found in CDA document.</xsl:variable>
	<!-- global variable title -->
	<xsl:variable name="title">
		<xsl:choose>
			<xsl:when test="string-length(/n1:ClinicalDocument/n1:title)  &gt;= 1">
				<xsl:value-of select="/n1:ClinicalDocument/n1:title"/>
			</xsl:when>
			<xsl:when test="/n1:ClinicalDocument/n1:code/@displayName">
				<xsl:value-of select="/n1:ClinicalDocument/n1:code/@displayName"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Clinical Document</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- Main -->
	<xsl:template match="/">
		<xsl:apply-templates select="n1:ClinicalDocument"/>
	</xsl:template>
	<!-- produce browser rendered, human readable clinical document -->
	<xsl:template match="n1:ClinicalDocument">
		<html>
			<head>
				<xsl:comment> Do NOT edit this HTML directly: it was generated via an XSLT transformation from a CDA Release 2 XML document. </xsl:comment>
				<title>
					<xsl:value-of select="$title"/>
				</title>
				<xsl:call-template name="addCSS"/>
			</head>
			<body>
				<h1 class="h1center">
					<xsl:value-of select="$title"/>
				</h1>
				<!-- START display top portion of clinical document -->
				<xsl:call-template name="recordTarget"/>
				<xsl:call-template name="documentGeneral"/>
				<xsl:call-template name="documentationOf"/>
				<xsl:call-template name="author"/>
				<xsl:call-template name="componentOf"/>
				<xsl:call-template name="participant"/>
				<xsl:call-template name="dataEnterer"/>
				<xsl:call-template name="authenticator"/>
				<xsl:call-template name="informant"/>
				<xsl:call-template name="informationRecipient"/>
				<xsl:call-template name="legalAuthenticator"/>
				<xsl:call-template name="custodian"/>
				<!-- END display top portion of clinical document -->
				<!-- produce table of contents -->
				<xsl:if test="not(//n1:nonXMLBody)">
					<xsl:if test="count(/n1:ClinicalDocument/n1:component/n1:structuredBody/n1:component[n1:section]) &gt; 1">
						<xsl:call-template name="make-tableofcontents"/>
					</xsl:if>
				</xsl:if>
				<hr align="left" color="teal" size="2"/>
				<!-- produce human readable document content -->
				<xsl:apply-templates select="n1:component/n1:structuredBody|n1:component/n1:nonXMLBody"/>
				<br/>
				<br/>
			</body>
		</html>
	</xsl:template>
	<!-- generate table of contents -->
	<xsl:template name="make-tableofcontents">
		<h2>
			<a name="toc">Table of Contents</a>
		</h2>
		<ul>
			<xsl:for-each select="n1:component/n1:structuredBody/n1:component/n1:section/n1:title">
				<li>
					<a href="#{generate-id(.)}">
						<xsl:value-of select="."/>
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	<!-- header elements -->
	<xsl:template name="documentGeneral">
		<table class="header_table">
			<tbody>
				<tr>
					<td class="td_header_role_name">
						<span class="td_label">
							<xsl:text>Document Id</xsl:text>
						</span>
					</td>
					<td class="td_header_role_value">
						<xsl:call-template name="show-id">
							<xsl:with-param name="id" select="n1:id"/>
						</xsl:call-template>
					</td>
				</tr>
				<tr>
					<td class="td_header_role_name">
						<span class="td_label">
							<xsl:text>Document Created:</xsl:text>
						</span>
					</td>
					<td class="td_header_role_value">
						<xsl:call-template name="show-time">
							<xsl:with-param name="datetime" select="n1:effectiveTime"/>
						</xsl:call-template>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	<!-- confidentiality -->
	<xsl:template name="confidentiality">
		<table class="header_table">
			<tbody>
				<td class="td_header_role_name">
					<xsl:text>Confidentiality</xsl:text>
				</td>
				<td class="td_header_role_value">
					<xsl:choose>
						<xsl:when test="n1:confidentialityCode/@code  = &apos;N&apos;">
							<xsl:text>Normal</xsl:text>
						</xsl:when>
						<xsl:when test="n1:confidentialityCode/@code  = &apos;R&apos;">
							<xsl:text>Restricted</xsl:text>
						</xsl:when>
						<xsl:when test="n1:confidentialityCode/@code  = &apos;V&apos;">
							<xsl:text>Very restricted</xsl:text>
						</xsl:when>
					</xsl:choose>
					<xsl:if test="n1:confidentialityCode/n1:originalText">
						<xsl:text> </xsl:text>
						<xsl:value-of select="n1:confidentialityCode/n1:originalText"/>
					</xsl:if>
				</td>
			</tbody>
		</table>
	</xsl:template>
	<!-- author -->
	<xsl:template name="author">
		<xsl:if test="n1:author">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:author/n1:assignedAuthor">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Author</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<xsl:choose>
									<xsl:when test="n1:assignedPerson/n1:name">
										<xsl:call-template name="show-name">
											<xsl:with-param name="name" select="n1:assignedPerson/n1:name"/>
										</xsl:call-template>
										<xsl:if test="n1:representedOrganization">
											<xsl:text>, </xsl:text>
											<xsl:call-template name="show-name">
												<xsl:with-param name="name" select="n1:representedOrganization/n1:name"/>
											</xsl:call-template>
										</xsl:if>
									</xsl:when>
									<xsl:when test="n1:assignedAuthoringDevice/n1:softwareName">
										<xsl:value-of select="n1:assignedAuthoringDevice/n1:softwareName"/>
									</xsl:when>
									<xsl:when test="n1:representedOrganization">
										<xsl:call-template name="show-name">
											<xsl:with-param name="name" select="n1:representedOrganization/n1:name"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:for-each select="n1:id">
											<xsl:call-template name="show-id">
												<xsl:with-param name="id" select="."/>
											</xsl:call-template>
											<br/>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<xsl:if test="n1:addr | n1:telecom">
							<tr>
								<td class="td_header_role_name">
									<span class="td_label">Contact info</span>
								</td>
								<td class="td_header_role_value">
									<xsl:call-template name="show-contactInfo">
										<xsl:with-param name="contact" select="."/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!--  authenticator -->
	<xsl:template name="authenticator">
		<xsl:if test="n1:authenticator">
			<table class="header_table">
				<tbody>
					<tr>
						<xsl:for-each select="n1:authenticator">
							<tr>
								<td class="td_header_role_name">
									<span class="td_label">
										<xsl:text>Signed </xsl:text>
									</span>
								</td>
								<td class="td_header_role_value">
									<xsl:call-template name="show-name">
										<xsl:with-param name="name" select="n1:assignedEntity/n1:assignedPerson/n1:name"/>
									</xsl:call-template>
									<xsl:text> at </xsl:text>
									<xsl:call-template name="show-time">
										<xsl:with-param name="datetime" select="n1:time"/>
									</xsl:call-template>
								</td>
							</tr>
							<xsl:if test="n1:assignedEntity/n1:addr | n1:assignedEntity/n1:telecom">
								<tr>
									<td class="td_header_role_name">
										<span class="td_label">Contact info</span>
									</td>
									<td class="td_header_role_value">
										<xsl:call-template name="show-contactInfo">
											<xsl:with-param name="contact" select="n1:assignedEntity"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</tr>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- legalAuthenticator -->
	<xsl:template name="legalAuthenticator">
		<xsl:if test="n1:legalAuthenticator">
			<table class="header_table">
				<tbody>
					<tr>
						<td class="td_header_role_name">
							<span class="td_label">
								<xsl:text>Legal authenticator</xsl:text>
							</span>
						</td>
						<td class="td_header_role_value">
							<xsl:call-template name="show-assignedEntity">
								<xsl:with-param name="asgnEntity" select="n1:legalAuthenticator/n1:assignedEntity"/>
							</xsl:call-template>
							<xsl:text> </xsl:text>
							<xsl:call-template name="show-sig">
								<xsl:with-param name="sig" select="n1:legalAuthenticator/n1:signatureCode"/>
							</xsl:call-template>
							<xsl:if test="n1:legalAuthenticator/n1:time/@value">
								<xsl:text> at </xsl:text>
								<xsl:call-template name="show-time">
									<xsl:with-param name="datetime" select="n1:legalAuthenticator/n1:time"/>
								</xsl:call-template>
							</xsl:if>
						</td>
					</tr>
					<xsl:if test="n1:legalAuthenticator/n1:assignedEntity/n1:addr | n1:legalAuthenticator/n1:assignedEntity/n1:telecom">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">Contact info</span>
							</td>
							<td class="td_header_role_value">
								<xsl:call-template name="show-contactInfo">
									<xsl:with-param name="contact" select="n1:legalAuthenticator/n1:assignedEntity"/>
								</xsl:call-template>
							</td>
						</tr>
					</xsl:if>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- dataEnterer -->
	<xsl:template name="dataEnterer">
		<xsl:if test="n1:dataEnterer">
			<table class="header_table">
				<tbody>
					<tr>
						<td class="td_header_role_name">
							<span class="td_label">
								<xsl:text>Entered by</xsl:text>
							</span>
						</td>
						<td class="td_header_role_value">
							<xsl:call-template name="show-assignedEntity">
								<xsl:with-param name="asgnEntity" select="n1:dataEnterer/n1:assignedEntity"/>
							</xsl:call-template>
						</td>
					</tr>
					<xsl:if test="n1:dataEnterer/n1:assignedEntity/n1:addr | n1:dataEnterer/n1:assignedEntity/n1:telecom">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">Contact info</span>
							</td>
							<td class="td_header_role_value">
								<xsl:call-template name="show-contactInfo">
									<xsl:with-param name="contact" select="n1:dataEnterer/n1:assignedEntity"/>
								</xsl:call-template>
							</td>
						</tr>
					</xsl:if>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- componentOf -->
	<xsl:template name="componentOf">
		<xsl:if test="n1:componentOf">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:componentOf/n1:encompassingEncounter">
						<xsl:if test="n1:id">
							<xsl:choose>
								<xsl:when test="n1:code">
									<tr>
										<td class="td_header_role_name">
											<span class="td_label">
												<xsl:text>Encounter Id</xsl:text>
											</span>
										</td>
										<td class="td_header_role_value">
											<xsl:call-template name="show-id">
												<xsl:with-param name="id" select="n1:id"/>
											</xsl:call-template>
										</td>
									</tr>
									<tr>
										<td class="td_header_role_name">
											<span class="td_label">
												<xsl:text>Encounter Type</xsl:text>
											</span>
										</td>
										<td class="td_header_role_value">
											<xsl:call-template name="show-code">
												<xsl:with-param name="code" select="n1:code"/>
											</xsl:call-template>
										</td>
									</tr>
								</xsl:when>
								<xsl:otherwise>
									<tr>
										<td class="td_header_role_name">
											<span class="td_label">
												<xsl:text>Encounter Id</xsl:text>
											</span>
										</td>
										<td class="td_header_role_value">
											<xsl:call-template name="show-id">
												<xsl:with-param name="id" select="n1:id"/>
											</xsl:call-template>
										</td>
									</tr>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Encounter Date</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<xsl:if test="n1:effectiveTime">
									<xsl:choose>
										<xsl:when test="n1:effectiveTime/@value">
											<xsl:text>&#160;at&#160;</xsl:text>
											<xsl:call-template name="show-time">
												<xsl:with-param name="datetime" select="n1:effectiveTime"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:when test="n1:effectiveTime/n1:low">
											<xsl:text>&#160;From&#160;</xsl:text>
											<xsl:call-template name="show-time">
												<xsl:with-param name="datetime" select="n1:effectiveTime/n1:low"/>
											</xsl:call-template>
											<xsl:if test="n1:effectiveTime/n1:high">
												<xsl:text> to </xsl:text>
												<xsl:call-template name="show-time">
													<xsl:with-param name="datetime" select="n1:effectiveTime/n1:high"/>
												</xsl:call-template>
											</xsl:if>
										</xsl:when>
									</xsl:choose>
								</xsl:if>
							</td>
						</tr>
						<xsl:if test="n1:location/n1:healthCareFacility">
							<tr>
								<td class="td_header_role_name">
									<span class="td_label">
										<xsl:text>Encounter Location</xsl:text>
									</span>
								</td>
								<td class="td_header_role_value">
									<xsl:choose>
										<xsl:when test="n1:location/n1:healthCareFacility/n1:location/n1:name">
											<xsl:call-template name="show-name">
												<xsl:with-param name="name" select="n1:location/n1:healthCareFacility/n1:location/n1:name"/>
											</xsl:call-template>
											<xsl:for-each select="n1:location/n1:healthCareFacility/n1:serviceProviderOrganization/n1:name">
												<xsl:text> of </xsl:text>
												<xsl:call-template name="show-name">
													<xsl:with-param name="name" select="n1:location/n1:healthCareFacility/n1:serviceProviderOrganization/n1:name"/>
												</xsl:call-template>
											</xsl:for-each>
										</xsl:when>
										<xsl:when test="n1:location/n1:healthCareFacility/n1:code">
											<xsl:call-template name="show-code">
												<xsl:with-param name="code" select="n1:location/n1:healthCareFacility/n1:code"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>
											<xsl:if test="n1:location/n1:healthCareFacility/n1:id">
												<xsl:text>id: </xsl:text>
												<xsl:for-each select="n1:location/n1:healthCareFacility/n1:id">
													<xsl:call-template name="show-id">
														<xsl:with-param name="id" select="."/>
													</xsl:call-template>
												</xsl:for-each>
											</xsl:if>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="n1:responsibleParty">
							<tr>
								<td class="td_header_role_name">
									<span class="td_label">
										<xsl:text>Responsible party</xsl:text>
									</span>
								</td>
								<td class="td_header_role_value">
									<xsl:call-template name="show-assignedEntity">
										<xsl:with-param name="asgnEntity" select="n1:responsibleParty/n1:assignedEntity"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>
						<xsl:if test="n1:responsibleParty/n1:assignedEntity/n1:addr | n1:responsibleParty/n1:assignedEntity/n1:telecom">
							<tr>
								<td class="td_header_role_name">
									<span class="td_label">Contact info</span>
								</td>
								<td class="td_header_role_value">
									<xsl:call-template name="show-contactInfo">
										<xsl:with-param name="contact" select="n1:responsibleParty/n1:assignedEntity"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- custodian -->
	<xsl:template name="custodian">
		<xsl:if test="n1:custodian">
			<table class="header_table">
				<tbody>
					<tr>
						<td class="td_header_role_name">
							<span class="td_label">
								<xsl:text>Document maintained by</xsl:text>
							</span>
						</td>
						<td class="td_header_role_value">
							<xsl:choose>
								<xsl:when test="n1:custodian/n1:assignedCustodian/n1:representedCustodianOrganization/n1:name">
									<xsl:call-template name="show-name">
										<xsl:with-param name="name" select="n1:custodian/n1:assignedCustodian/n1:representedCustodianOrganization/n1:name"/>
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="n1:custodian/n1:assignedCustodian/n1:representedCustodianOrganization/n1:id">
										<xsl:call-template name="show-id"/>
										<xsl:if test="position()!=last()">
											<br/>
										</xsl:if>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</td>
					</tr>
					<xsl:if test="n1:custodian/n1:assignedCustodian/n1:representedCustodianOrganization/n1:addr |             n1:custodian/n1:assignedCustodian/n1:representedCustodianOrganization/n1:telecom">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">Contact info</span>
							</td>
							<td class="td_header_role_value">
								<xsl:call-template name="show-contactInfo">
									<xsl:with-param name="contact" select="n1:custodian/n1:assignedCustodian/n1:representedCustodianOrganization"/>
								</xsl:call-template>
							</td>
						</tr>
					</xsl:if>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- documentationOf -->
	<xsl:template name="documentationOf">
		<xsl:if test="n1:documentationOf">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:documentationOf">
						<xsl:if test="n1:serviceEvent/@classCode and n1:serviceEvent/n1:code">
							<xsl:variable name="displayName">
								<xsl:call-template name="show-actClassCode">
									<xsl:with-param name="clsCode" select="n1:serviceEvent/@classCode"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:if test="$displayName">
								<tr>
									<td class="td_header_role_name">
										<span class="td_label">
											<xsl:call-template name="firstCharCaseUp">
												<xsl:with-param name="data" select="$displayName"/>
											</xsl:call-template>
										</span>
									</td>
									<td class="td_header_role_value">
										<xsl:call-template name="show-code">
											<xsl:with-param name="code" select="n1:serviceEvent/n1:code"/>
										</xsl:call-template>
										<xsl:if test="n1:serviceEvent/n1:effectiveTime">
											<xsl:choose>
												<xsl:when test="n1:serviceEvent/n1:effectiveTime/@value">
													<xsl:text>&#160;at&#160;</xsl:text>
													<xsl:call-template name="show-time">
														<xsl:with-param name="datetime" select="n1:serviceEvent/n1:effectiveTime"/>
													</xsl:call-template>
												</xsl:when>
												<xsl:when test="n1:serviceEvent/n1:effectiveTime/n1:low">
													<xsl:text>&#160;from&#160;</xsl:text>
													<xsl:call-template name="show-time">
														<xsl:with-param name="datetime" select="n1:serviceEvent/n1:effectiveTime/n1:low"/>
													</xsl:call-template>
													<xsl:if test="n1:serviceEvent/n1:effectiveTime/n1:high">
														<xsl:text> to </xsl:text>
														<xsl:call-template name="show-time">
															<xsl:with-param name="datetime" select="n1:serviceEvent/n1:effectiveTime/n1:high"/>
														</xsl:call-template>
													</xsl:if>
												</xsl:when>
											</xsl:choose>
										</xsl:if>
									</td>
								</tr>
							</xsl:if>
						</xsl:if>
						<xsl:for-each select="n1:serviceEvent/n1:performer">
							<xsl:if test="not(preceding::n1:performer/n1:assignedEntity[n1:id/@extension = current()/n1:assignedEntity/n1:id/@extension])">
								<xsl:variable name="displayName">
									<xsl:call-template name="show-participationType">
										<xsl:with-param name="ptype" select="@typeCode"/>
									</xsl:call-template>
									<xsl:text> </xsl:text>
									<xsl:if test="n1:functionCode/@code">
										<xsl:call-template name="show-participationFunction">
											<xsl:with-param name="pFunction" select="n1:functionCode/@code"/>
										</xsl:call-template>
									</xsl:if>
								</xsl:variable>
								<tr>
									<td class="td_header_role_name">
										<span class="td_label">
											<xsl:call-template name="firstCharCaseUp">
												<xsl:with-param name="data" select="$displayName"/>
											</xsl:call-template>
										</span>
									</td>
									<td class="td_header_role_value">
										<table class="header_table internal_format">
											<tbody>
												<tr>
													<td class="td_header_role_value internal_format">
														<xsl:call-template name="show-assignedEntity">
															<xsl:with-param name="asgnEntity" select="n1:assignedEntity"/>
														</xsl:call-template>
													</td>
												</tr>
												<tr>
													<td class="td_header_role_value internal_format">
														<xsl:if test="n1:assignedEntity">
															<xsl:call-template name="show-contactInfo">
																<xsl:with-param name="contact" select="n1:assignedEntity"/>
															</xsl:call-template>
														</xsl:if>
													</td>
												</tr>
											</tbody>
										</table>
									</td>
								</tr>
							</xsl:if>
						</xsl:for-each>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- inFulfillmentOf -->
	<xsl:template name="inFulfillmentOf">
		<xsl:if test="n1:infulfillmentOf">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:inFulfillmentOf">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>In fulfillment of</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<xsl:for-each select="n1:order">
									<xsl:for-each select="n1:id">
										<xsl:call-template name="show-id"/>
									</xsl:for-each>
									<xsl:for-each select="n1:code">
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="show-code">
											<xsl:with-param name="code" select="."/>
										</xsl:call-template>
									</xsl:for-each>
									<xsl:for-each select="n1:priorityCode">
										<xsl:text>&#160;</xsl:text>
										<xsl:call-template name="show-code">
											<xsl:with-param name="code" select="."/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- informant -->
	<xsl:template name="informant">
		<xsl:if test="n1:informant">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:informant">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Informant</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<xsl:if test="n1:assignedEntity">
									<xsl:call-template name="show-assignedEntity">
										<xsl:with-param name="asgnEntity" select="n1:assignedEntity"/>
									</xsl:call-template>
								</xsl:if>
								<xsl:if test="n1:relatedEntity">
									<xsl:call-template name="show-relatedEntity">
										<xsl:with-param name="relatedEntity" select="n1:relatedEntity"/>
									</xsl:call-template>
								</xsl:if>
							</td>
						</tr>
						<xsl:choose>
							<xsl:when test="n1:assignedEntity/n1:addr | n1:assignedEntity/n1:telecom">
								<tr>
									<td class="td_header_role_name">
										<span class="td_label">Contact info</span>
									</td>
									<td class="td_header_role_value">
										<xsl:if test="n1:assignedEntity">
											<xsl:call-template name="show-contactInfo">
												<xsl:with-param name="contact" select="n1:assignedEntity"/>
											</xsl:call-template>
										</xsl:if>
									</td>
								</tr>
							</xsl:when>
							<xsl:when test="n1:relatedEntity/n1:addr | n1:relatedEntity/n1:telecom">
								<tr>
									<td class="td_header_role_name">
										<span class="td_label">Contact info</span>
									</td>
									<td class="td_header_role_value">
										<xsl:if test="n1:relatedEntity">
											<xsl:call-template name="show-contactInfo">
												<xsl:with-param name="contact" select="n1:relatedEntity"/>
											</xsl:call-template>
										</xsl:if>
									</td>
								</tr>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- informantionRecipient -->
	<xsl:template name="informationRecipient">
		<xsl:if test="n1:informationRecipient">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:informationRecipient">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Information recipient:</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<xsl:choose>
									<xsl:when test="not(normalize-space(n1:intendedRecipient/n1:informationRecipient/n1:name)='')">
										<xsl:for-each select="n1:intendedRecipient/n1:informationRecipient">
											<xsl:call-template name="show-name">
												<xsl:with-param name="name" select="n1:name"/>
											</xsl:call-template>
											<xsl:if test="position() != last()">
												<br/>
											</xsl:if>
										</xsl:for-each>
									</xsl:when>
									<xsl:when test="not(normalize-space(n1:intendedRecipient/n1:receivedOrganization/n1:name)='')">
										<xsl:for-each select="n1:intendedRecipient/n1:receivedOrganization">
											<xsl:call-template name="show-name">
												<xsl:with-param name="name" select="n1:name"/>
											</xsl:call-template>
											<xsl:if test="position() != last()">
												<br/>
											</xsl:if>
										</xsl:for-each>
									</xsl:when>									
									<xsl:otherwise>
										<xsl:for-each select="n1:intendedRecipient">
											<xsl:for-each select="n1:id">
												<xsl:call-template name="show-id"/>
											</xsl:for-each>
											<xsl:if test="position() != last()">
												<br/>
											</xsl:if>
											<br/>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
						<xsl:choose>
							<xsl:when test="not(normalize-space(n1:intendedRecipient/n1:addr)='' and normalize-space(n1:intendedRecipient/n1:telecom/@value)='')">
								<tr>
									<td class="td_header_role_name">
										<span class="td_label">Contact info</span>
									</td>
									<td class="td_header_role_value">
										<xsl:call-template name="show-contactInfo">
											<xsl:with-param name="contact" select="n1:intendedRecipient"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:when>
							<xsl:when test="not(normalize-space(n1:intendedRecipient/n1:receivedOrganization/n1:addr)='' and normalize-space(n1:intendedRecipient/n1:receivedOrganization/n1:telecom/@value)='')">
								<tr>
									<td class="td_header_role_name">
										<span class="td_label">Contact info</span>
									</td>
									<td class="td_header_role_value">
										<xsl:call-template name="show-contactInfo">
											<xsl:with-param name="contact" select="n1:intendedRecipient/n1:receivedOrganization"/>
										</xsl:call-template>
									</td>
								</tr>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- participant -->
	<xsl:template name="participant">
		<xsl:if test="n1:participant">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:participant">
						<tr>
							<td class="td_header_role_name">
								<xsl:variable name="participtRole">
									<xsl:call-template name="translateRoleAssoCode">
										<xsl:with-param name="classCode" select="n1:associatedEntity/@classCode"/>
										<xsl:with-param name="code" select="n1:associatedEntity/n1:code"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="$participtRole">
										<span class="td_label">
											<xsl:call-template name="firstCharCaseUp">
												<xsl:with-param name="data" select="$participtRole"/>
											</xsl:call-template>
										</span>
									</xsl:when>
									<xsl:otherwise>
										<span class="td_label">
											<xsl:text>Participant</xsl:text>
										</span>
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td class="td_header_role_value">
								<xsl:if test="n1:associatedEntity/n1:associatedPerson/n1:name/*">		
										<xsl:call-template name="show-associatedEntity">
										<xsl:with-param name="assoEntity" select="n1:associatedEntity"/>
										</xsl:call-template>
										<xsl:if test="n1:functionCode/@code">
											<xsl:call-template name="show-participationFunction">
												<xsl:with-param name="pFunction" select="n1:functionCode/@code"/>
											</xsl:call-template>
										</xsl:if>									
								</xsl:if>
								<xsl:if test="n1:time">
									<xsl:if test="n1:time/n1:low">
										<xsl:text> from </xsl:text>
										<xsl:call-template name="show-time">
											<xsl:with-param name="datetime" select="n1:time/n1:low"/>
										</xsl:call-template>
									</xsl:if>
									<xsl:if test="n1:time/n1:high">
										<xsl:text> to </xsl:text>
										<xsl:call-template name="show-time">
											<xsl:with-param name="datetime" select="n1:time/n1:high"/>
										</xsl:call-template>
									</xsl:if>
								</xsl:if>
								<xsl:if test="position() != last()">
									<br/>
								</xsl:if>
							</td>
						</tr>
						<xsl:if test="n1:associatedEntity/n1:addr | n1:associatedEntity/n1:telecom">
							<tr>
								<td class="td_header_role_name">
									<span class="td_label">
										<xsl:text>Contact info</xsl:text>
									</span>
								</td>
								<td class="td_header_role_value">
									<xsl:call-template name="show-contactInfo">
										<xsl:with-param name="contact" select="n1:associatedEntity"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:if>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- recordTarget -->
	<xsl:template name="recordTarget">
		<table class="header_table">
			<xsl:for-each select="/n1:ClinicalDocument/n1:recordTarget/n1:patientRole">
				<xsl:if test="not(n1:id/@nullFlavor)">
					<tr>
						<td class="td_header_role_name">
							<span class="td_label">
								<xsl:text>Patient</xsl:text>
							</span>
						</td>
						<td class="td_header_role_value">
							<xsl:call-template name="show-name">
								<xsl:with-param name="name" select="n1:patient/n1:name[not(@use) or @use != 'SRCH']"/>
							</xsl:call-template>
						</td>
					</tr>
					<xsl:if test="n1:patient/n1:name[@use='SRCH']">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Previous Name</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<xsl:call-template name="show-name">
									<xsl:with-param name="name" select="n1:patient/n1:name[@use='SRCH']"/>
								</xsl:call-template>
							</td>
						</tr>
					</xsl:if>
					<tr>
						<td class="td_header_role_name">
							<span class="td_label">
								<xsl:text>Date of birth</xsl:text>
							</span>
						</td>
						<td class="td_header_role_value">
							<xsl:call-template name="show-time">
								<xsl:with-param name="datetime" select="n1:patient/n1:birthTime"/>
							</xsl:call-template>
						</td>
					</tr>
					<tr>
						<td class="td_header_role_name">
							<span class="td_label">
								<xsl:text>Current Gender</xsl:text>
							</span>
						</td>
						<td class="td_header_role_value">
							<xsl:for-each select="n1:patient/n1:administrativeGenderCode">
								<xsl:call-template name="show-gender"/>
							</xsl:for-each>
						</td>
					</tr>
					<xsl:if test="n1:patient/n1:raceCode">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Race(s)</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<ul style="list-style: none;list-style-position:outside;margin:0;padding:0; ">
									<xsl:choose>
										<xsl:when test="n1:patient/n1:raceCode">
											<xsl:for-each select="n1:patient/n1:raceCode">
												<li>
													<xsl:call-template name="show-race-ethnicity"/>
												</li>
											</xsl:for-each>
											<xsl:for-each select="n1:patient/sdtc:raceCode">
												<li>
													<xsl:call-template name="show-extra-race"/>
												</li>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Information not available</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</ul>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="(n1:patient/n1:ethnicGroupCode)">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Ethnicity</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<ul style="list-style: none;list-style-position:outside;margin:0;padding:0; ">
									<xsl:choose>
										<xsl:when test="n1:patient/n1:ethnicGroupCode">
											<xsl:for-each select="n1:patient/n1:ethnicGroupCode">
												<li>
													<xsl:call-template name="show-race-ethnicity"/>
												</li>
											</xsl:for-each>
											<xsl:for-each select="n1:patient/sdtc:ethnicGroupCode">
											  <li>
												<xsl:call-template name="show-extra-race"/>
											  </li>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Information not available</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</ul>	
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="(n1:patient/n1:languageCommunication)">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Language(s)</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<ul style="list-style: none;list-style-position:outside;margin:0;padding:0; ">
									<xsl:choose>
										<xsl:when test="n1:patient/n1:languageCommunication">
											<xsl:for-each select="n1:patient/n1:languageCommunication">
												<li>
													<xsl:call-template name="show-language">
														<xsl:with-param name="languageNode" select="."/>
													</xsl:call-template>
												</li>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<li>
												<xsl:text>Information not available</xsl:text>
											</li>
										</xsl:otherwise>
									</xsl:choose>
								</ul>
							</td>
						</tr>
					</xsl:if>
					<tr>
						<td class="td_header_role_name">
							<span class="td_label">
								<xsl:text>Contact info</xsl:text>
							</span>
						</td>
						<td class="td_header_role_value">
							<xsl:call-template name="show-contactInfo">
								<xsl:with-param name="contact" select="."/>
							</xsl:call-template>
						</td>
					</tr>
					<tr>
						<td class="td_header_role_name">
							<span class="td_label">Patient IDs</span>
						</td>
						<td class="td_header_role_value">
							<xsl:for-each select="n1:id">
								<xsl:call-template name="show-id"/>
								<br/>
							</xsl:for-each>
						</td>
					</tr>
				</xsl:if>
			</xsl:for-each>
		</table>
	</xsl:template>
	<!-- relatedDocument -->
	<xsl:template name="relatedDocument">
		<xsl:if test="n1:relatedDocument">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:relatedDocument">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Related document</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<xsl:for-each select="n1:parentDocument">
									<xsl:for-each select="n1:id">
										<xsl:call-template name="show-id"/>
										<br/>
									</xsl:for-each>
								</xsl:for-each>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- authorization (consent) -->
	<xsl:template name="authorization">
		<xsl:if test="n1:authorization">
			<table class="header_table">
				<tbody>
					<xsl:for-each select="n1:authorization">
						<tr>
							<td class="td_header_role_name">
								<span class="td_label">
									<xsl:text>Consent</xsl:text>
								</span>
							</td>
							<td class="td_header_role_value">
								<xsl:choose>
									<xsl:when test="n1:consent/n1:code">
										<xsl:call-template name="show-code">
											<xsl:with-param name="code" select="n1:consent/n1:code"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="show-code">
											<xsl:with-param name="code" select="n1:consent/n1:statusCode"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
								<br/>
							</td>
						</tr>
					</xsl:for-each>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- setAndVersion -->
	<xsl:template name="setAndVersion">
		<xsl:if test="n1:setId and n1:versionNumber">
			<table class="header_table">
				<tbody>
					<tr>
						<td class="td_header_role_name">
							<xsl:text>SetId and Version</xsl:text>
						</td>
						<td class="td_header_role_value">
							<xsl:text>SetId: </xsl:text>
							<xsl:call-template name="show-id">
								<xsl:with-param name="id" select="n1:setId"/>
							</xsl:call-template>
							<xsl:text>  Version: </xsl:text>
							<xsl:value-of select="n1:versionNumber/@value"/>
						</td>
					</tr>
				</tbody>
			</table>
		</xsl:if>
	</xsl:template>
	<!-- show StructuredBody  -->
	<xsl:template match="n1:component/n1:structuredBody">
		<xsl:for-each select="n1:component/n1:section">
			<xsl:call-template name="section"/>
		</xsl:for-each>
	</xsl:template>
	<!-- show nonXMLBody -->
	<xsl:template match="n1:component/n1:nonXMLBody">
		<xsl:choose>
			<!-- if there is a reference, use that in an IFRAME -->
			<xsl:when test="n1:text/n1:reference">
				<xsl:variable name="source" select="string(n1:text/n1:reference/@value)"/>
				<xsl:variable name="lcSource" select="translate($source, $uc, $lc)"/>
				<xsl:variable name="scrubbedSource" select="translate($source, $simple-sanitizer-match, $simple-sanitizer-replace)"/>
				<xsl:message>
					<xsl:value-of select="$source"/>, <xsl:value-of select="$lcSource"/>
				</xsl:message>
				<xsl:choose>
					<xsl:when test="contains($lcSource,'javascript')">
						<p>
							<xsl:value-of select="$javascript-injection-warning"/>
						</p>
						<xsl:message>
							<xsl:value-of select="$javascript-injection-warning"/>
						</xsl:message>
					</xsl:when>
					<xsl:when test="not($source = $scrubbedSource)">
						<p>
							<xsl:value-of select="$malicious-content-warning"/>
						</p>
						<xsl:message>
							<xsl:value-of select="$malicious-content-warning"/>
						</xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<iframe name="nonXMLBody" id="nonXMLBody" WIDTH="80%" HEIGHT="600" src="{$source}" sandbox=""/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test='n1:text/@mediaType="text/plain"'>
				<pre>
					<xsl:value-of select="n1:text/text()"/>
				</pre>
			</xsl:when>
			<xsl:otherwise>
				<pre>Cannot display the text</pre>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- top level component/section: display title and text,
      and process any nested component/sections
    -->
	<xsl:template name="section">
		<xsl:call-template name="section-title">
			<xsl:with-param name="title" select="n1:title"/>
		</xsl:call-template>
		<xsl:call-template name="section-author"/>
		<xsl:call-template name="section-text"/>
		<xsl:for-each select="n1:component/n1:section">
			<xsl:call-template name="nestedSection">
				<xsl:with-param name="margin" select="2"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<!-- top level section title -->
	<xsl:template name="section-title">
		<xsl:param name="title"/>
		<xsl:choose>
			<xsl:when test="count(/n1:ClinicalDocument/n1:component/n1:structuredBody/n1:component[n1:section]) &gt; 1">
				<h3>
					<a name="{generate-id($title)}" href="#toc">
						<xsl:value-of select="$title"/>
					</a>
				</h3>
			</xsl:when>
			<xsl:otherwise>
				<h3>
					<xsl:value-of select="$title"/>
				</h3>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- section author -->
	<xsl:template name="section-author">
		<xsl:if test="count(n1:author)&gt;0">
			<div style="margin-left : 2em;">
				<b>
					<xsl:text>Section Author: </xsl:text>
				</b>
				<xsl:for-each select="n1:author/n1:assignedAuthor">
					<xsl:choose>
						<xsl:when test="n1:assignedPerson/n1:name">
							<xsl:call-template name="show-name">
								<xsl:with-param name="name" select="n1:assignedPerson/n1:name"/>
							</xsl:call-template>
							<xsl:if test="n1:representedOrganization">
								<xsl:text>, </xsl:text>
								<xsl:call-template name="show-name">
									<xsl:with-param name="name" select="n1:representedOrganization/n1:name"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:when>
						<xsl:when test="n1:assignedAuthoringDevice/n1:softwareName">
							<xsl:value-of select="n1:assignedAuthoringDevice/n1:softwareName"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:for-each select="n1:id">
								<xsl:call-template name="show-id"/>
								<br/>
							</xsl:for-each>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<br/>
			</div>
		</xsl:if>
	</xsl:template>
	<!-- top-level section Text   -->
	<xsl:template name="section-text">
		<div>
			<xsl:apply-templates select="n1:text"/>
		</div>
	</xsl:template>
	<!-- nested component/section -->
	<xsl:template name="nestedSection">
		<xsl:param name="margin"/>
		<h4 style="margin-left : {$margin}em;">
			<xsl:value-of select="n1:title"/>
		</h4>
		<div style="margin-left : {$margin}em;">
			<xsl:apply-templates select="n1:text"/>
		</div>
		<xsl:for-each select="n1:component/n1:section">
			<xsl:call-template name="nestedSection">
				<xsl:with-param name="margin" select="2*$margin"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<!--   paragraph  -->
	<xsl:template match="n1:paragraph">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	<!--   pre format  -->
	<xsl:template match="n1:pre">
		<pre>
			<xsl:apply-templates/>
		</pre>
	</xsl:template>
	<!--   Content w/ deleted text is hidden -->
	<xsl:template match="n1:content[@revised='delete']"/>
	<!--   content  -->
	<xsl:template match="n1:content">
		<span>
			<xsl:apply-templates select="@styleCode"/>
			<xsl:value-of select="." disable-output-escaping="yes"/>	
		</span>
	</xsl:template>
	<!-- line break -->
	<xsl:template match="n1:br">
		<xsl:element name="br">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<!--   list  -->
	<xsl:template match="n1:list">
		<xsl:if test="n1:caption">
			<p>
				<b>
					<xsl:apply-templates select="n1:caption"/>
				</b>
			</p>
		</xsl:if>
		<ul>
			<xsl:for-each select="n1:item">
				<li>
					<xsl:apply-templates/>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>
	<xsl:template match="n1:list[@listType='ordered']">
		<xsl:if test="n1:caption">
			<span style="font-weight:bold; ">
				<xsl:apply-templates select="n1:caption"/>
			</span>
		</xsl:if>
		<ol>
			<xsl:for-each select="n1:item">
				<li>
					<xsl:apply-templates/>
				</li>
			</xsl:for-each>
		</ol>
	</xsl:template>
	<!--   caption  -->
	<xsl:template match="n1:caption">
		<xsl:apply-templates/>
		<xsl:text>: </xsl:text>
	</xsl:template>
	<!--  Tables   -->
	<!--
    <xsl:template match="n1:table/@*|n1:thead/@*|n1:tfoot/@*|n1:tbody/@*|n1:colgroup/@*|n1:col/@*|n1:tr/@*|n1:th/@*|n1:td/@*">

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    -->
	<xsl:template name="output-attrs">
		<xsl:variable name="elem-name" select="local-name(.)"/>
		<xsl:for-each select="@*">
			<xsl:variable name="attr-name" select="local-name(.)"/>
			<xsl:variable name="source" select="."/>
			<xsl:variable name="lcSource" select="translate($source, $uc, $lc)"/>
			<xsl:variable name="scrubbedSource" select="translate($source, $simple-sanitizer-match, $simple-sanitizer-replace)"/>
			<xsl:choose>
				<xsl:when test="contains($lcSource,'javascript')">
					<p>
						<xsl:value-of select="$javascript-injection-warning"/>
					</p>
					<xsl:message terminate="yes">
						<xsl:value-of select="$javascript-injection-warning"/>
					</xsl:message>
				</xsl:when>
				<xsl:when test="$attr-name='styleCode'">
					<xsl:apply-templates select="."/>
				</xsl:when>
				<!--xsl:when test="not(document('')/xsl:stylesheet/xsl:variable[@name='table-elem-attrs']/in:tableElems/in:elem[@name=$elem-name]/in:attr[@name=$attr-name])"-->
        <!--<xsl:when test="not(/xsl:stylesheet/xsl:variable[@name='table-elem-attrs']/in:tableElems/in:elem[@name=$elem-name]/in:attr[@name=$attr-name])">-->
        <xsl:when test="not(				
				              ($elem-name='table' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='summary') or
				                  ($attr-name='width') or
				                  ($attr-name='border') or
				                  ($attr-name='frame') or
				                  ($attr-name='rules') or
				                  ($attr-name='cellspacing') or
				                  ($attr-name='cellpadding') )) or
			                ($elem-name='thead' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='align') or
				                  ($attr-name='char') or
				                  ($attr-name='charoff') or
				                  ($attr-name='valign') )) or
			                ($elem-name='tfoot' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='align') or
				                  ($attr-name='char') or
				                  ($attr-name='charoff') or
				                  ($attr-name='valign') )) or
			                ($elem-name='tbody' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='align') or
				                  ($attr-name='char') or
				                  ($attr-name='charoff') or
				                  ($attr-name='valign') )) or
			                ($elem-name='colgroup' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='span') or
				                  ($attr-name='width') or
				                  ($attr-name='align') or
				                  ($attr-name='char') or
				                  ($attr-name='charoff') or
				                  ($attr-name='valign') )) or
			                ($elem-name='col' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='span') or
				                  ($attr-name='width') or
				                  ($attr-name='align') or
				                  ($attr-name='char') or
				                  ($attr-name='charoff') or
				                  ($attr-name='valign') )) or
			                ($elem-name='tr' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='align') or
				                  ($attr-name='char') or
				                  ($attr-name='charoff') or
				                  ($attr-name='valign') )) or
			                ($elem-name='th' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='abbr') or
				                  ($attr-name='axis') or
				                  ($attr-name='headers') or
				                  ($attr-name='scope') or
				                  ($attr-name='rowspan') or
				                  ($attr-name='colspan') or
				                  ($attr-name='align') or
				                  ($attr-name='char') or
				                  ($attr-name='charoff') or
				                  ($attr-name='valign') )) or
			                ($elem-name='td' and (
				                  ($attr-name='ID') or
				                  ($attr-name='language') or
				                  ($attr-name='styleCode') or
				                  ($attr-name='abbr') or
				                  ($attr-name='axis') or
				                  ($attr-name='headers') or
				                  ($attr-name='scope') or
				                  ($attr-name='rowspan') or
				                  ($attr-name='colspan') or
				                  ($attr-name='align') or
				                  ($attr-name='char') or
				                  ($attr-name='charoff') or
				                  ($attr-name='valign') )) 
				                )">
					<xsl:message>
						<xsl:value-of select="$attr-name"/> is not legal in <xsl:value-of select="$elem-name"/>
					</xsl:message>
				</xsl:when>
				<xsl:when test="not($source = $scrubbedSource)">
					<p>
						<xsl:value-of select="$malicious-content-warning"/>
					</p>
					<xsl:message>
						<xsl:value-of select="$malicious-content-warning"/>
					</xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="n1:table | n1:thead | n1:tfoot | n1:tbody | n1:colgroup | n1:col | n1:tr | n1:th | n1:td">
		<xsl:element name="{local-name()}">
			<xsl:call-template name="output-attrs"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<!--
    <xsl:template match="n1:table">
        <table>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <xsl:template match="n1:thead">
        <thead>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </thead>
    </xsl:template>
    <xsl:template match="n1:tfoot">
        <tfoot>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </tfoot>
    </xsl:template>
    <xsl:template match="n1:tbody">
        <tbody>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </tbody>
    </xsl:template>
    <xsl:template match="n1:colgroup">
        <colgroup>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </colgroup>
    </xsl:template>
    <xsl:template match="n1:col">
        <col>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </col>
    </xsl:template>
    <xsl:template match="n1:tr">
        <tr>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    <xsl:template match="n1:th">
        <th>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </th>
    </xsl:template>
    <xsl:template match="n1:td">
        <td>
            <xsl:call-template name="output-attrs"/>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
-->
	<xsl:template match="n1:table/n1:caption">
		<span style="font-weight:bold; ">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<!--   RenderMultiMedia
     this currently only handles GIF's and JPEG's.  It could, however,
     be extended by including other image MIME types in the predicate
     and/or by generating <object> or <applet> tag with the correct
     params depending on the media type  @ID  =$imageRef  referencedObject
     -->
	<xsl:template name="check-external-image-whitelist">
		<xsl:param name="current-whitelist"/>
		<xsl:param name="image-uri"/>
		<xsl:choose>
			<xsl:when test="string-length($current-whitelist) &gt; 0">
				<xsl:variable name="whitelist-item">
					<xsl:choose>
						<xsl:when test="contains($current-whitelist,'|')">
							<xsl:value-of select="substring-before($current-whitelist,'|')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$current-whitelist"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="starts-with($image-uri,$whitelist-item)">
						<br clear="all"/>
						<xsl:element name="img">
							<xsl:attribute name="src"><xsl:value-of select="$image-uri"/></xsl:attribute>
						</xsl:element>
						<xsl:message>
							<xsl:value-of select="$image-uri"/> is in the whitelist</xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="check-external-image-whitelist">
							<xsl:with-param name="current-whitelist" select="substring-after($current-whitelist,'|')"/>
							<xsl:with-param name="image-uri" select="$image-uri"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<p>WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.</p>
				<xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="n1:renderMultiMedia">
		<xsl:variable name="imageRef" select="@referencedObject"/>
		<xsl:choose>
			<xsl:when test="//n1:regionOfInterest[@ID=$imageRef]">
				<!-- Here is where the Region of Interest image referencing goes -->
				<xsl:if test="//n1:regionOfInterest[@ID=$imageRef]//n1:observationMedia/n1:value[@mediaType='image/gif' or
 @mediaType='image/jpeg']">
					<xsl:variable name="image-uri" select="//n1:regionOfInterest[@ID=$imageRef]//n1:observationMedia/n1:value/n1:reference/@value"/>
					<xsl:choose>
						<xsl:when test="$limit-external-images='yes' and (contains($image-uri,':') or starts-with($image-uri,'\\'))">
							<xsl:call-template name="check-external-image-whitelist">
								<xsl:with-param name="current-whitelist" select="$external-image-whitelist"/>
								<xsl:with-param name="image-uri" select="$image-uri"/>
							</xsl:call-template>
							<!--
                            <p>WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.</p>
                            <xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.</xsl:message>
                            -->
						</xsl:when>
						<!--
                        <xsl:when test="$limit-external-images='yes' and starts-with($image-uri,'\\')">
                            <p>WARNING: non-local image found <xsl:value-of select="$image-uri"/></p>
                            <xsl:message>WARNING: non-local image found <xsl:value-of select="$image-uri"/>. Removing. If you wish non-local images preserved please set the limit-external-images param to 'no'.</xsl:message>
                        </xsl:when>
                        -->
						<xsl:otherwise>
							<br clear="all"/>
							<xsl:element name="img">
								<xsl:attribute name="src"><xsl:value-of select="$image-uri"/></xsl:attribute>
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<!-- Here is where the direct MultiMedia image referencing goes -->
				<xsl:if test="//n1:observationMedia[@ID=$imageRef]/n1:value[@mediaType='image/gif' or @mediaType='image/jpeg']">
					<br clear="all"/>
					<xsl:element name="img">
						<xsl:attribute name="src"><xsl:value-of select="//n1:observationMedia[@ID=$imageRef]/n1:value/n1:reference/@value"/></xsl:attribute>
					</xsl:element>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--    Stylecode processing
     Supports Bold, Underline and Italics display
     -->
	<xsl:template match="@styleCode">
		<xsl:attribute name="class"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	<!--
    <xsl:template match="//n1:*[@styleCode]">
        <xsl:if test="@styleCode='Bold'">
            <xsl:element name="b">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="@styleCode='Italics'">
            <xsl:element name="i">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="@styleCode='Underline'">
            <xsl:element name="u">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="contains(@styleCode,'Bold') and contains(@styleCode,'Italics') and not (contains(@styleCode, 'Underline'))">
            <xsl:element name="b">
                <xsl:element name="i">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:if test="contains(@styleCode,'Bold') and contains(@styleCode,'Underline') and not (contains(@styleCode, 'Italics'))">
            <xsl:element name="b">
                <xsl:element name="u">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:if test="contains(@styleCode,'Italics') and contains(@styleCode,'Underline') and not (contains(@styleCode, 'Bold'))">
            <xsl:element name="i">
                <xsl:element name="u">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:if test="contains(@styleCode,'Italics') and contains(@styleCode,'Underline') and contains(@styleCode, 'Bold')">
            <xsl:element name="b">
                <xsl:element name="i">
                    <xsl:element name="u">
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:if test="not (contains(@styleCode,'Italics') or contains(@styleCode,'Underline') or contains(@styleCode, 'Bold'))">
            <xsl:apply-templates/>
        </xsl:if>
    </xsl:template>
    -->
	<!--    Superscript or Subscript   -->
	<xsl:template match="n1:sup">
		<xsl:element name="sup">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<xsl:template match="n1:sub">
		<xsl:element name="sub">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	<!-- show-signature -->
	<xsl:template name="show-sig">
		<xsl:param name="sig"/>
		<xsl:choose>
			<xsl:when test="$sig/@code =&apos;S&apos;">
				<xsl:text>signed</xsl:text>
			</xsl:when>
			<xsl:when test="$sig/@code=&apos;I&apos;">
				<xsl:text>intended</xsl:text>
			</xsl:when>
			<xsl:when test="$sig/@code=&apos;X&apos;">
				<xsl:text>signature required</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!--  show-id -->
	<xsl:template name="show-id">
		<xsl:param name="id" select="."/>
		<xsl:choose>
			<xsl:when test="not($id)">
				<xsl:if test="not(@nullFlavor)">
					<xsl:if test="@extension">
						<xsl:value-of select="@extension"/>
					</xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="@root"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not($id/@nullFlavor)">
					<xsl:if test="$id/@extension">
						<xsl:value-of select="$id/@extension"/>
					</xsl:if>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$id/@root"/>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- show-name  -->
	<xsl:template name="show-name">
		<xsl:param name="name"/>
		<xsl:choose>
			<xsl:when test="$name/n1:family">
				<xsl:if test="$name/n1:prefix">
					<xsl:value-of select="$name/n1:prefix" disable-output-escaping="yes"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="$name/n1:given" disable-output-escaping="yes"/>
				<xsl:text> </xsl:text>				
				<xsl:if test="($name/n1:given)[2]">
					<xsl:value-of select="($name/n1:given)[2]" disable-output-escaping="yes"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="$name/n1:family" disable-output-escaping="yes"/>
				<xsl:if test="$name/n1:suffix">
					<xsl:text>, </xsl:text>
					<xsl:value-of select="$name/n1:suffix" disable-output-escaping="yes"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- show-gender  -->
	<xsl:template name="show-gender">
		<xsl:choose>
			<xsl:when test="@code   = &apos;M&apos;">
				<xsl:text>Male</xsl:text>
			</xsl:when>
			<xsl:when test="@code  = &apos;F&apos;">
				<xsl:text>Female</xsl:text>
			</xsl:when>
			<xsl:when test="@code  = &apos;U&apos;">
				<xsl:text>Undifferentiated</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- show-race-ethnicity  -->
	<xsl:template name="show-race-ethnicity">
		<xsl:choose>
			<xsl:when test="@displayName">
				<xsl:value-of select="@displayName"/>
			</xsl:when>
			<xsl:when test="@nullFlavor='ASKU'">
				<xsl:text>Declined to Specify</xsl:text>
			</xsl:when>
			<xsl:when test="@nullFlavor='UNK'">
				<xsl:text>Unknown</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@code"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- show-extra-race -->
	<xsl:template name="show-extra-race">
		<xsl:choose>
			<xsl:when test="@displayName">
				<xsl:value-of select="@displayName"/>
			</xsl:when>
			<xsl:when test="@nullFlavor='ASKU'">
				<xsl:text>Declined to Specify</xsl:text>
			</xsl:when>
			<xsl:when test="@nullFlavor='UNK'">
				<xsl:text>Unknown</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@code"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--  show-language-->
	<xsl:template name="show-language">		
		<xsl:param name="languageNode"/>
		<xsl:variable name="languageCodeNoTranslation" select="translate($languageNode/n1:languageCode/@code, $uc, $lc)"/>
		<xsl:variable name="languageCode">
			<xsl:choose>
				<xsl:when test="contains($languageCodeNoTranslation,'-')">
					<xsl:value-of select="substring-before($languageCodeNoTranslation, '-')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$languageCodeNoTranslation"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="languageCodeAdditionalInformation">
			<xsl:choose>
				<xsl:when test="contains($languageCodeNoTranslation,'-')">
					<xsl:value-of select="substring-after($languageCodeNoTranslation, '-')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$languageCode = 'aa'">
				<xsl:text>Afar</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'aar'">
				<xsl:text>Afar</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ab'">
				<xsl:text>Abkhazian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'abk'">
				<xsl:text>Abkhazian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ae'">
				<xsl:text>Avestan</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'af'">
				<xsl:text>Afrikaans</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'afr'">
				<xsl:text>Afrikaans</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ak'">
				<xsl:text>Akan</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'aka'">
				<xsl:text>Akan</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'am'">
				<xsl:text>Amharic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'amh'">
				<xsl:text>Amharic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'an'">
				<xsl:text>Aragonese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ar'">
				<xsl:text>Arabic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ara'">
				<xsl:text>Arabic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'arg'">
				<xsl:text>Aragonese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'as'">
				<xsl:text>Assamese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'asm'">
				<xsl:text>Assamese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'av'">
				<xsl:text>Avaric</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ava'">
				<xsl:text>Avaric</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ave'">
				<xsl:text>Avestan</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ay'">
				<xsl:text>Aymara</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'aym'">
				<xsl:text>Aymara</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'az'">
				<xsl:text>Azerbaijani</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'aze'">
				<xsl:text>Azerbaijani</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ba'">
				<xsl:text>Bashkir</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bak'">
				<xsl:text>Bashkir</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bam'">
				<xsl:text>Bambara</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'be'">
				<xsl:text>Belarusian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bel'">
				<xsl:text>Belarusian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ben'">
				<xsl:text>Bengali</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bg'">
				<xsl:text>Bulgarian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bh'">
				<xsl:text>Bihari</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bi'">
				<xsl:text>Bislama</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bih'">
				<xsl:text>Bihari</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bis'">
				<xsl:text>Bislama</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bm'">
				<xsl:text>Bambara</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bn'">
				<xsl:text>Bengali</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bo'">
				<xsl:text>Tibetan</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bod'">
				<xsl:text>Tibetan</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bos'">
				<xsl:text>Bosnian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'br'">
				<xsl:text>Breton</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bre'">
				<xsl:text>Breton</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bs'">
				<xsl:text>Bosnian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'bul'">
				<xsl:text>Bulgarian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ca'">
				<xsl:text>Catalan; Valencian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cat'">
				<xsl:text>Catalan; Valencian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ce'">
				<xsl:text>Chechen</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ces'">
				<xsl:text>Czech</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ch'">
				<xsl:text>Chamorro</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cha'">
				<xsl:text>Chamorro</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'che'">
				<xsl:text>Chechen</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'chu'">
				<xsl:text>Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'chv'">
				<xsl:text>Chuvash</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'co'">
				<xsl:text>Corsican</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cor'">
				<xsl:text>Cornish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cos'">
				<xsl:text>Corsican</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cr'">
				<xsl:text>Cree</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cre'">
				<xsl:text>Cree</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cs'">
				<xsl:text>Czech</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cu'">
				<xsl:text>Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cv'">
				<xsl:text>Chuvash</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cy'">
				<xsl:text>Welsh</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'cym'">
				<xsl:text>Welsh</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'da'">
				<xsl:text>Danish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'dan'">
				<xsl:text>Danish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'de'">
				<xsl:text>German</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'DeclineToSpecify'">
				<xsl:text>Declined to specify</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'deu'">
				<xsl:text>German</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'div'">
				<xsl:text>Divehi; Dhivehi; Maldivian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'dv'">
				<xsl:text>Divehi; Dhivehi; Maldivian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'dz'">
				<xsl:text>Dzongkha</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'dzo'">
				<xsl:text>Dzongkha</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ee'">
				<xsl:text>Ewe</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'el'">
				<xsl:text>Greek, Modern (1453-)</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'en'">
				<xsl:text>English</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'eng'">
				<xsl:text>English</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'eo'">
				<xsl:text>Esperanto</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'epo'">
				<xsl:text>Esperanto</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'es'">
				<xsl:text>Spanish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'est'">
				<xsl:text>Estonian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'et'">
				<xsl:text>Estonian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'eu'">
				<xsl:text>Basque</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'eus'">
				<xsl:text>Basque</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ewe'">
				<xsl:text>Ewe</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fa'">
				<xsl:text>Persian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fao'">
				<xsl:text>Faroese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fas'">
				<xsl:text>Persian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ff'">
				<xsl:text>Fulah</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fi'">
				<xsl:text>Finnish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fij'">
				<xsl:text>Fijian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fin'">
				<xsl:text>Finnish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fj'">
				<xsl:text>Fijian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fo'">
				<xsl:text>Faroese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fr'">
				<xsl:text>French</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fra'">
				<xsl:text>French</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fry'">
				<xsl:text>Western Frisian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ful'">
				<xsl:text>Fulah</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'fy'">
				<xsl:text>Western Frisian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ga'">
				<xsl:text>Irish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'gd'">
				<xsl:text>Gaelic; Scottish Gaelic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'gl'">
				<xsl:text>Galician</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'gla'">
				<xsl:text>Gaelic; Scottish Gaelic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'gle'">
				<xsl:text>Irish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'glg'">
				<xsl:text>Galician</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'glv'">
				<xsl:text>Manx</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'gn'">
				<xsl:text>Guarani</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'grn'">
				<xsl:text>Guarani</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'gu'">
				<xsl:text>Gujarati</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'guj'">
				<xsl:text>Gujarati</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'gv'">
				<xsl:text>Manx</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ha'">
				<xsl:text>Hausa</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hat'">
				<xsl:text>Haitian; Haitian Creole</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hau'">
				<xsl:text>Hausa</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'he'">
				<xsl:text>Hebrew</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'heb'">
				<xsl:text>Hebrew</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'her'">
				<xsl:text>Herero</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hi'">
				<xsl:text>Hindi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hin'">
				<xsl:text>Hindi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hmo'">
				<xsl:text>Hiri Motu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ho'">
				<xsl:text>Hiri Motu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hr'">
				<xsl:text>Croatian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hrv'">
				<xsl:text>Croatian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ht'">
				<xsl:text>Haitian; Haitian Creole</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hu'">
				<xsl:text>Hungarian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hun'">
				<xsl:text>Hungarian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hy'">
				<xsl:text>Armenian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hye'">
				<xsl:text>Armenian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'hz'">
				<xsl:text>Herero</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ia'">
				<xsl:text>Interlingua (International Auxiliary Language Association)</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ibo'">
				<xsl:text>Igbo</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'id'">
				<xsl:text>Indonesian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ido'">
				<xsl:text>Ido</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ie'">
				<xsl:text>Interlingue; Occidental</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ig'">
				<xsl:text>Igbo</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ii'">
				<xsl:text>Sichuan Yi; Nuosu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'iii'">
				<xsl:text>Sichuan Yi; Nuosu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ik'">
				<xsl:text>Inupiaq</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'iku'">
				<xsl:text>Inuktitut</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ile'">
				<xsl:text>Interlingue; Occidental</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ind'">
				<xsl:text>Indonesian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'io'">
				<xsl:text>Ido</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ipk'">
				<xsl:text>Inupiaq</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'is'">
				<xsl:text>Icelandic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'isl'">
				<xsl:text>Icelandic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'it'">
				<xsl:text>Italian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ita'">
				<xsl:text>Italian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'iu'">
				<xsl:text>Inuktitut</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ja'">
				<xsl:text>Japanese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'jav'">
				<xsl:text>Javanese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'jpn'">
				<xsl:text>Japanese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'jv'">
				<xsl:text>Javanese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ka'">
				<xsl:text>Georgian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kal'">
				<xsl:text>Kalaallisut; Greenlandic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kan'">
				<xsl:text>Kannada</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kas'">
				<xsl:text>Kashmiri</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kat'">
				<xsl:text>Georgian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kau'">
				<xsl:text>Kanuri</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kaz'">
				<xsl:text>Kazakh</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kg'">
				<xsl:text>Kongo</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'khm'">
				<xsl:text>Central Khmer</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ki'">
				<xsl:text>Kikuyu; Gikuyu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kik'">
				<xsl:text>Kikuyu; Gikuyu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kin'">
				<xsl:text>Kinyarwanda</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kir'">
				<xsl:text>Kirghiz; Kyrgyz</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kj'">
				<xsl:text>Kuanyama; Kwanyama</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kk'">
				<xsl:text>Kazakh</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kl'">
				<xsl:text>Kalaallisut; Greenlandic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'km'">
				<xsl:text>Central Khmer</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kn'">
				<xsl:text>Kannada</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ko'">
				<xsl:text>Korean</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kom'">
				<xsl:text>Komi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kon'">
				<xsl:text>Kongo</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kor'">
				<xsl:text>Korean</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kr'">
				<xsl:text>Kanuri</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ks'">
				<xsl:text>Kashmiri</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ku'">
				<xsl:text>Kurdish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kua'">
				<xsl:text>Kuanyama; Kwanyama</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kur'">
				<xsl:text>Kurdish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kv'">
				<xsl:text>Komi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'kw'">
				<xsl:text>Cornish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ky'">
				<xsl:text>Kirghiz; Kyrgyz</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'la'">
				<xsl:text>Latin</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lao'">
				<xsl:text>Lao</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lat'">
				<xsl:text>Latin</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lav'">
				<xsl:text>Latvian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lb'">
				<xsl:text>Luxembourgish; Letzeburgesch</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lg'">
				<xsl:text>Ganda</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'li'">
				<xsl:text>Limburgan; Limburger; Limburgish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lim'">
				<xsl:text>Limburgan; Limburger; Limburgish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lin'">
				<xsl:text>Lingala</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lit'">
				<xsl:text>Lithuanian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ln'">
				<xsl:text>Lingala</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lo'">
				<xsl:text>Lao</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lt'">
				<xsl:text>Lithuanian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ltz'">
				<xsl:text>Luxembourgish; Letzeburgesch</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lu'">
				<xsl:text>Luba-Katanga</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lub'">
				<xsl:text>Luba-Katanga</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lug'">
				<xsl:text>Ganda</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'lv'">
				<xsl:text>Latvian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mah'">
				<xsl:text>Marshallese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mal'">
				<xsl:text>Malayalam</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mar'">
				<xsl:text>Marathi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mg'">
				<xsl:text>Malagasy</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mh'">
				<xsl:text>Marshallese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mi'">
				<xsl:text>Maori</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mk'">
				<xsl:text>Macedonian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mkd'">
				<xsl:text>Macedonian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ml'">
				<xsl:text>Malayalam</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mlg'">
				<xsl:text>Malagasy</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mlt'">
				<xsl:text>Maltese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mn'">
				<xsl:text>Mongolian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mon'">
				<xsl:text>Mongolian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mr'">
				<xsl:text>Marathi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mri'">
				<xsl:text>Maori</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ms'">
				<xsl:text>Malay</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'msa'">
				<xsl:text>Malay</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mt'">
				<xsl:text>Maltese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'my'">
				<xsl:text>Burmese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'mya'">
				<xsl:text>Burmese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'na'">
				<xsl:text>Nauru</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nau'">
				<xsl:text>Nauru</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nav'">
				<xsl:text>Navajo; Navaho</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nb'">
				<xsl:text>Bokmål, Norwegian; Norwegian Bokmål</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nbl'">
				<xsl:text>Ndebele, South; South Ndebele</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nd'">
				<xsl:text>Ndebele, North; North Ndebele</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nde'">
				<xsl:text>Ndebele, North; North Ndebele</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ndo'">
				<xsl:text>Ndonga</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ne'">
				<xsl:text>Nepali</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nep'">
				<xsl:text>Nepali</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ng'">
				<xsl:text>Ndonga</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nl'">
				<xsl:text>Dutch; Flemish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nld'">
				<xsl:text>Dutch; Flemish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nn'">
				<xsl:text>Norwegian Nynorsk; Nynorsk, Norwegian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nno'">
				<xsl:text>Norwegian Nynorsk; Nynorsk, Norwegian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'no'">
				<xsl:text>Norwegian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nob'">
				<xsl:text>Bokmål, Norwegian; Norwegian Bokmål</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nor'">
				<xsl:text>Norwegian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nr'">
				<xsl:text>Ndebele, South; South Ndebele</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nv'">
				<xsl:text>Navajo; Navaho</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ny'">
				<xsl:text>Chichewa; Chewa; Nyanja</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'nya'">
				<xsl:text>Chichewa; Chewa; Nyanja</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'oj'">
				<xsl:text>Ojibwa</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'oji'">
				<xsl:text>Ojibwa</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'om'">
				<xsl:text>Oromo</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'or'">
				<xsl:text>Oriya</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ori'">
				<xsl:text>Oriya</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'orm'">
				<xsl:text>Oromo</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'os'">
				<xsl:text>Ossetian; Ossetic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'oss'">
				<xsl:text>Ossetian; Ossetic</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'pa'">
				<xsl:text>Panjabi; Punjabi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'pan'">
				<xsl:text>Panjabi; Punjabi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'pi'">
				<xsl:text>Pali</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'pl'">
				<xsl:text>Polish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'pli'">
				<xsl:text>Pali</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'pol'">
				<xsl:text>Polish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'por'">
				<xsl:text>Portuguese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ps'">
				<xsl:text>Pushto; Pashto</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'pt'">
				<xsl:text>Portuguese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'pus'">
				<xsl:text>Pushto; Pashto</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'qu'">
				<xsl:text>Quechua</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'que'">
				<xsl:text>Quechua</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'rm'">
				<xsl:text>Romansh</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'rn'">
				<xsl:text>Rundi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'roh'">
				<xsl:text>Romansh</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ru'">
				<xsl:text>Russian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'run'">
				<xsl:text>Rundi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'rus'">
				<xsl:text>Russian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'rw'">
				<xsl:text>Kinyarwanda</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sa'">
				<xsl:text>Sanskrit</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sag'">
				<xsl:text>Sango</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'san'">
				<xsl:text>Sanskrit</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sc'">
				<xsl:text>Sardinian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sd'">
				<xsl:text>Sindhi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'se'">
				<xsl:text>Northern Sami</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sg'">
				<xsl:text>Sango</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'si'">
				<xsl:text>Sinhala; Sinhalese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sin'">
				<xsl:text>Sinhala; Sinhalese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sk'">
				<xsl:text>Slovak</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sl'">
				<xsl:text>Slovenian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'slk'">
				<xsl:text>Slovak</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'slv'">
				<xsl:text>Slovenian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sm'">
				<xsl:text>Samoan</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sme'">
				<xsl:text>Northern Sami</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'smo'">
				<xsl:text>Samoan</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sn'">
				<xsl:text>Shona</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sna'">
				<xsl:text>Shona</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'snd'">
				<xsl:text>Sindhi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'so'">
				<xsl:text>Somali</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'som'">
				<xsl:text>Somali</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sot'">
				<xsl:text>Sotho, Southern</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'spa'">
				<xsl:text>Spanish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sq'">
				<xsl:text>Albanian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sqi'">
				<xsl:text>Albanian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sr'">
				<xsl:text>Serbian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'srd'">
				<xsl:text>Sardinian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'srp'">
				<xsl:text>Serbian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ss'">
				<xsl:text>Swati</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ssw'">
				<xsl:text>Swati</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'st'">
				<xsl:text>Sotho, Southern</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'su'">
				<xsl:text>Sundanese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sun'">
				<xsl:text>Sundanese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sv'">
				<xsl:text>Swedish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'sw'">
				<xsl:text>Swahili</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'swa'">
				<xsl:text>Swahili</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'swe'">
				<xsl:text>Swedish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ta'">
				<xsl:text>Tamil</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tah'">
				<xsl:text>Tahitian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tam'">
				<xsl:text>Tamil</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tat'">
				<xsl:text>Tatar</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'te'">
				<xsl:text>Telugu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tel'">
				<xsl:text>Telugu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tg'">
				<xsl:text>Tajik</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tgk'">
				<xsl:text>Tajik</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tgl'">
				<xsl:text>Tagalog</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'th'">
				<xsl:text>Thai</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tha'">
				<xsl:text>Thai</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ti'">
				<xsl:text>Tigrinya</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tir'">
				<xsl:text>Tigrinya</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tk'">
				<xsl:text>Turkmen</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tl'">
				<xsl:text>Tagalog</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tn'">
				<xsl:text>Tswana</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'to'">
				<xsl:text>Tonga (Tonga Islands)</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tr'">
				<xsl:text>Turkish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ts'">
				<xsl:text>Tsonga</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tsn'">
				<xsl:text>Tswana</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tso'">
				<xsl:text>Tsonga</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tt'">
				<xsl:text>Tatar</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tuk'">
				<xsl:text>Turkmen</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tur'">
				<xsl:text>Turkish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'tw'">
				<xsl:text>Twi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'twi'">
				<xsl:text>Twi</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ty'">
				<xsl:text>Tahitian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ug'">
				<xsl:text>Uighur; Uyghur</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'uig'">
				<xsl:text>Uighur; Uyghur</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'uk'">
				<xsl:text>Ukrainian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ukr'">
				<xsl:text>Ukrainian</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ur'">
				<xsl:text>Urdu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'urd'">
				<xsl:text>Urdu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'uz'">
				<xsl:text>Uzbek</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'uzb'">
				<xsl:text>Uzbek</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 've'">
				<xsl:text>Venda</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'ven'">
				<xsl:text>Venda</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'vi'">
				<xsl:text>Vietnamese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'vie'">
				<xsl:text>Vietnamese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'vo'">
				<xsl:text>Volapük</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'vol'">
				<xsl:text>Volapük</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'wa'">
				<xsl:text>Walloon</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'wln'">
				<xsl:text>Walloon</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'wo'">
				<xsl:text>Wolof</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'wol'">
				<xsl:text>Wolof</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'xh'">
				<xsl:text>Xhosa</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'xho'">
				<xsl:text>Xhosa</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'yi'">
				<xsl:text>Yiddish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'yid'">
				<xsl:text>Yiddish</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'yo'">
				<xsl:text>Yoruba</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'yor'">
				<xsl:text>Yoruba</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'za'">
				<xsl:text>Zhuang; Chuang</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'zh'">
				<xsl:text>Chinese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'zha'">
				<xsl:text>Zhuang; Chuang</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'zho'">
				<xsl:text>Chinese</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'zu'">
				<xsl:text>Zulu</xsl:text>
			</xsl:when>
			<xsl:when test="$languageCode = 'zul'">
				<xsl:text>Zulu</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$languageCode"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$languageCodeAdditionalInformation != ''"> 
			<xsl:text> [</xsl:text>
			<xsl:value-of select="$languageCodeAdditionalInformation"/>
			<xsl:text>]</xsl:text>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="not($languageNode/n1:languageCode/@nullFlavor) and translate($languageNode/n1:preferenceInd/@value, $uc, $lc) = 'true' " >
				<xsl:text> (Preferred)</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- show-contactInfo -->
	<xsl:template name="show-contactInfo">
		<xsl:param name="contact"/>
		<xsl:for-each select="$contact/n1:addr">
			<xsl:call-template name="show-address">
				<xsl:with-param name="address" select="."/>
			</xsl:call-template>
			<br/>
		</xsl:for-each>
		<xsl:for-each select="$contact/n1:telecom">
			<xsl:call-template name="show-telecom">
				<xsl:with-param name="telecom" select="."/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<!-- show-address -->
	<xsl:template name="show-address">
		<xsl:param name="address"/>
		<xsl:choose>
			<xsl:when test="$address">
				<xsl:if test="$address/@use">
					<xsl:text> </xsl:text>
					<xsl:call-template name="translateTelecomCode">
						<xsl:with-param name="code" select="$address/@use"/>
					</xsl:call-template>
					<xsl:text>:</xsl:text>
					<br/>
				</xsl:if>
				<xsl:for-each select="$address/n1:streetAddressLine">
					<xsl:value-of select="."/>
					<br/>
				</xsl:for-each>
				<xsl:if test="$address/n1:streetName">
					<xsl:value-of select="$address/n1:streetName"/>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$address/n1:houseNumber"/>
					<br/>
				</xsl:if>
				<xsl:if test="string-length($address/n1:city)>0">
					<xsl:value-of select="$address/n1:city"/>
				</xsl:if>
				<xsl:if test="string-length($address/n1:state)>0">
					<xsl:text>,&#160;</xsl:text>
					<xsl:value-of select="$address/n1:state"/>
				</xsl:if>
				<xsl:if test="string-length($address/n1:postalCode)>0">
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="$address/n1:postalCode"/>
				</xsl:if>
				<xsl:if test="string-length($address/n1:country)>0">
					<xsl:text>,&#160;</xsl:text>
					<xsl:value-of select="$address/n1:country"/>
				</xsl:if>
				<xsl:if test="$address/n1:useablePeriod">
				  <xsl:if test="$address/n1:useablePeriod/n1:low/@value">
					<br/>
					<xsl:text>Effective Date: </xsl:text>
					<xsl:call-template name="show-time">
					  <xsl:with-param name="datetime" select="$address/n1:useablePeriod/n1:low"/>
					</xsl:call-template>
				  </xsl:if>
				  <xsl:if test="$address/n1:useablePeriod/n1:high/@value">
					<br/>
					<xsl:text>Expiration Date: </xsl:text>
					<xsl:call-template name="show-time">
					  <xsl:with-param name="datetime" select="$address/n1:useablePeriod/n1:high"/>
					</xsl:call-template>
				  </xsl:if>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>address not available</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<br/>
	</xsl:template>
	<!-- show-telecom -->
	<xsl:template name="show-telecom">
		<xsl:param name="telecom"/>
		<xsl:choose>
			<xsl:when test="$telecom">
				<xsl:variable name="type" select="substring-before($telecom/@value, ':')"/>
				<xsl:variable name="value" select="substring-after($telecom/@value, ':')"/>
				<xsl:variable name="use" select="$telecom/@use"/>
				<xsl:if test="$value">
					<xsl:choose>
						<xsl:when test="$use and $type = 'tel'" >
							<xsl:call-template name="translateTelecomCode">
								<xsl:with-param name="code" select="$use"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="translateTelecomCode">
								<xsl:with-param name="code" select="$type"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>: </xsl:text>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$value"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Telecom information not available</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<br/>
	</xsl:template>
	<!-- show-recipientType -->
	<xsl:template name="show-recipientType">
		<xsl:param name="typeCode"/>
		<xsl:choose>
			<xsl:when test="$typeCode='PRCP'">Primary Recipient:</xsl:when>
			<xsl:when test="$typeCode='TRC'">Secondary Recipient:</xsl:when>
			<xsl:otherwise>Recipient:</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- Convert Telecom URL to display text -->
	<xsl:template name="translateTelecomCode">
		<xsl:param name="code"/>
		<!--xsl:value-of select="document('voc.xml')/systems/system[@root=$code/@codeSystem]/code[@value=$code/@code]/@displayName"/-->
		<!--xsl:value-of select="document('codes.xml')/*/code[@code=$code]/@display"/-->
		<xsl:choose>
			<!-- lookup table Telecom URI -->
			<xsl:when test="$code='tel'">
				<xsl:text>Tel</xsl:text>
			</xsl:when>
			<xsl:when test="$code='fax'">
				<xsl:text>Fax</xsl:text>
			</xsl:when>
			<xsl:when test="$code='http'">
				<xsl:text>Web</xsl:text>
			</xsl:when>
			<xsl:when test="$code='mailto'">
				<xsl:text>Email</xsl:text>
			</xsl:when>
			<xsl:when test="$code='H'">
				<xsl:text>Home Phone</xsl:text>
			</xsl:when>
			<xsl:when test="$code='HV'">
				<xsl:text>Vacation Home Phone</xsl:text>
			</xsl:when>
			<xsl:when test="$code='HP'">
				<xsl:text>Primary Home Phone</xsl:text>
			</xsl:when>
			<xsl:when test="$code='WP'">
				<xsl:text>Work Phone</xsl:text>
			</xsl:when>
			<xsl:when test="$code='PUB'">
				<xsl:text>Pub</xsl:text>
			</xsl:when>
			<xsl:when test="$code='PG'">
				<xsl:text>Pager</xsl:text>
			</xsl:when>
			<xsl:when test="$code='MC'">
				<xsl:text>Mobile Phone</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{$code='</xsl:text>
				<xsl:value-of select="$code"/>
				<xsl:text>'?}</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- convert RoleClassAssociative code to display text -->
	<xsl:template name="translateRoleAssoCode">
		<xsl:param name="classCode"/>
		<xsl:param name="code"/>
		<xsl:choose>
			<xsl:when test="$classCode='AFFL'">
				<xsl:text>affiliate</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='AGNT'">
				<xsl:text>agent</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='ASSIGNED'">
				<xsl:text>assigned entity</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='COMPAR'">
				<xsl:text>commissioning party</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='CON'">
				<xsl:text>contact</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='ECON'">
				<xsl:text>emergency contact</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='NOK'">
				<xsl:text>next of kin</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='SGNOFF'">
				<xsl:text>signing authority</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='GUARD'">
				<xsl:text>guardian</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='GUAR'">
				<xsl:text>guarantor</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='CIT'">
				<xsl:text>citizen</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='COVPTY'">
				<xsl:text>covered party</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='PRS'">
				<xsl:text>personal relationship</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='CAREGIVER'">
				<xsl:text>care giver</xsl:text>
			</xsl:when>
			<xsl:when test="$classCode='PROV'">
				<xsl:text>Provider</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>{$classCode='</xsl:text>
				<xsl:value-of select="$classCode"/>
				<xsl:text>'?}</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
    <xsl:choose>
      <xsl:when test="($code/@code) and ($code/@codeSystem='2.16.840.1.113883.5.111')">
        <xsl:text> </xsl:text>
          <xsl:choose>
            <xsl:when test="$code/@code='FTH'">
              <xsl:text>(Father)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MTH'">
              <xsl:text>(Mother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PRN'">
              <xsl:text>(Parent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NPRN'">
              <xsl:text>(Natural parent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='STPPRN'">
              <xsl:text>(Step parent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SONC'">
              <xsl:text>(Son)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='DAUC'">
              <xsl:text>(Daughter)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='CHILD'">
              <xsl:text>(Child)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='EXT'">
              <xsl:text>(Extended family member)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NBOR'">
              <xsl:text>(Neighbor)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SIGOTHR'">
              <xsl:text>(Significant other)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SPS'">
              <xsl:text>(Spouse)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='CHLDADOPT'">
              <xsl:text>(Adopted child)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='GRNDCHILD'">
              <xsl:text>(Grandchild)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='GRPRN'">
              <xsl:text>(Grandparent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NIENEPH'">
              <xsl:text>(Niece/Nephew)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='STPCHLD'">
              <xsl:text>(Stepchild)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='DOMPART'">
              <xsl:text>(Domestic partner)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='CHLDFOST'">
              <xsl:text>(Foster child)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SELF'">
              <xsl:text>(Self)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='BRO'">
              <xsl:text>(Brother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='EXT'">
              <xsl:text>(Extended family member)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='FTH'">
              <xsl:text>(Father)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='FRND'">
              <xsl:text>(Unrelated friend)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='GUARD'">
              <xsl:text>(Guardian)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MTH'">
              <xsl:text>(Mother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NCHILD'">
              <xsl:text>(Natural child)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SIB'">
              <xsl:text>(Sibling)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SIS'">
              <xsl:text>(Sister)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='ADOPT'">
              <xsl:text>(Adopted child)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='AUNT'">
              <xsl:text>(Aunt)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='CHLDINLAW'">
              <xsl:text>(Child in-law)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='COUSN'">
              <xsl:text>(Cousin)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='FAMMEMB'">
              <xsl:text>(Family Member)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='GPARNT'">
              <xsl:text>(Grandparent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='GGRPRN'">
              <xsl:text>(Great-grandparent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='HSIB'">
              <xsl:text>(Half-sibling)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MAUNT'">
              <xsl:text>(Maternal Aunt)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MCOUSN'">
              <xsl:text>(Maternal Cousin)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MGRPRN'">
              <xsl:text>(Maternal Grandparent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MGGRPRN'">
              <xsl:text>(Maternal Great-grandparent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MUNCLE'">
              <xsl:text>(Maternal Uncle)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NSIB'">
              <xsl:text>(Natural sibling)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PRNINLAW'">
              <xsl:text>(Parent in-law)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PAUNT'">
              <xsl:text>(Paternal Aunt)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PCOUSN'">
              <xsl:text>(Paternal Cousin)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PGRPRN'">
              <xsl:text>(Paternal Grandparent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PGGRPRN'">
              <xsl:text>(Paternal Great-grandparent)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PUNCLE'">
              <xsl:text>(Paternal Uncle)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SIBINLAW'">
              <xsl:text>(Sibling in-law)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='STEP'">
              <xsl:text>(Step child)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='STPSIB'">
              <xsl:text>(Step sibling)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='UNCLE'">
              <xsl:text>(Uncle)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='HBRO'">
              <xsl:text>(Half-brother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='HSIS'">
              <xsl:text>(Half-sister)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='HUSB'">
              <xsl:text>(Husband)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MGGRFTH'">
              <xsl:text>(Maternal Great grandfather)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MGGRMTH'">
              <xsl:text>(Maternal Great grandmother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='MGRMTH'">
              <xsl:text>(Maternal Grandmother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NBRO'">
              <xsl:text>(Natural brother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NMTH'">
              <xsl:text>(Natural mother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='NSIS'">
              <xsl:text>(Natural sister)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PGGRFTH'">
              <xsl:text>(Paternal Great grandfather)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PGGRMTH'">
              <xsl:text>(Paternal Great grandmother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PGRFTH'">
              <xsl:text>(Paternal Grandfather)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='PGRMTH'">
              <xsl:text>(Paternal Grandmother)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='ROOM'">
              <xsl:text>(Roommate)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SISINLAW'">
              <xsl:text>(Sister-in-law)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SON'">
              <xsl:text>(Natural son)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SONADOPT'">
              <xsl:text>(Adopted son)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SONFOST'">
              <xsl:text>(Foster son)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='SONINLAW'">
              <xsl:text>(Son-in-law)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='STPCHLD'">
              <xsl:text>(Stepchild)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='DAU'">
              <xsl:text>(Natural daughter)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='STPDAU'">
              <xsl:text>(Stepdaughter)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='STPSON'">
              <xsl:text>(Stepson)</xsl:text>
            </xsl:when>
            <xsl:when test="$code/@code='WIFE'">
              <xsl:text>(Wife)</xsl:text>
            </xsl:when>
          </xsl:choose>
      </xsl:when>
      <xsl:when test="$code/@displayName">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="$code/@displayName"/>
          <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="$code/@nullFlavor">
          <xsl:if test="$code/n1:translation/@displayName">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$code/n1:translation/@displayName"/>
            <xsl:text>)</xsl:text>
          </xsl:if>
      </xsl:when>
    </xsl:choose>
	</xsl:template>
	<!-- show time -->
	<xsl:template name="show-time">
		<xsl:param name="datetime"/>
		<xsl:choose>
		  <xsl:when test="$datetime/@nullFlavor">
		    <xsl:text> </xsl:text>
		  </xsl:when>
			<xsl:when test="not($datetime)">
				<xsl:call-template name="formatDateTime">
					<xsl:with-param name="date" select="@value"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="formatDateTime">
					<xsl:with-param name="date" select="$datetime/@value"/>
				</xsl:call-template>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- paticipant facility and date -->
	<xsl:template name="facilityAndDates">
		<table class="header_table">
			<tbody>
				<!-- facility id -->
				<tr>
					<td class="td_header_role_name">
						<span class="td_label">
							<xsl:text>Facility ID</xsl:text>
						</span>
					</td>
					<td class="td_header_role_value">
						<xsl:choose>
							<xsl:when test="count(/n1:ClinicalDocument/n1:participant
                                      [@typeCode='LOC'][@contextControlCode='OP']
                                      /n1:associatedEntity[@classCode='SDLOC']/n1:id)&gt;0">
								<!-- change context node -->
								<xsl:for-each select="/n1:ClinicalDocument/n1:participant
                                      [@typeCode='LOC'][@contextControlCode='OP']
                                      /n1:associatedEntity[@classCode='SDLOC']/n1:id">
									<xsl:call-template name="show-id"/>
									<!-- change context node again, for the code -->
									<xsl:for-each select="../n1:code">
										<xsl:text> (</xsl:text>
										<xsl:call-template name="show-code">
											<xsl:with-param name="code" select="."/>
										</xsl:call-template>
										<xsl:text>)</xsl:text>
									</xsl:for-each>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
                                Not available
                            </xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
				<!-- Period reported -->
				<tr>
					<td class="td_header_role_name">
						<span class="td_label">
							<xsl:text>First day of period reported</xsl:text>
						</span>
					</td>
					<td class="td_header_role_value">
						<xsl:call-template name="show-time">
							<xsl:with-param name="datetime" select="/n1:ClinicalDocument/n1:documentationOf
                                      /n1:serviceEvent/n1:effectiveTime/n1:low"/>
						</xsl:call-template>
					</td>
				</tr>
				<tr>
					<td class="td_header_role_name">
						<span class="td_label">
							<xsl:text>Last day of period reported</xsl:text>
						</span>
					</td>
					<td class="td_header_role_value">
						<xsl:call-template name="show-time">
							<xsl:with-param name="datetime" select="/n1:ClinicalDocument/n1:documentationOf
                                      /n1:serviceEvent/n1:effectiveTime/n1:high"/>
						</xsl:call-template>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	<!-- show assignedEntity -->
	<xsl:template name="show-assignedEntity">
		<xsl:param name="asgnEntity"/>
		<xsl:choose>
			<xsl:when test="$asgnEntity/n1:assignedPerson/n1:name">
				<xsl:call-template name="show-name">
					<xsl:with-param name="name" select="$asgnEntity/n1:assignedPerson/n1:name"/>
				</xsl:call-template>
				<xsl:if test="$asgnEntity/n1:representedOrganization/n1:name">
					<xsl:text> of </xsl:text>
					<xsl:value-of select="$asgnEntity/n1:representedOrganization/n1:name"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$asgnEntity/n1:representedOrganization">
				<xsl:value-of select="$asgnEntity/n1:representedOrganization/n1:name"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$asgnEntity/n1:id">
					<xsl:call-template name="show-id"/>
					<xsl:choose>
						<xsl:when test="position()!=last()">
							<xsl:text>, </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<br/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- show relatedEntity -->
	<xsl:template name="show-relatedEntity">
		<xsl:param name="relatedEntity"/>
		<xsl:choose>
			<xsl:when test="$relatedEntity/n1:relatedPerson/n1:name">
				<xsl:call-template name="show-name">
					<xsl:with-param name="name" select="$relatedEntity/n1:relatedPerson/n1:name"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- show associatedEntity -->
	<xsl:template name="show-associatedEntity">
		<xsl:param name="assoEntity"/>
		<xsl:choose>
			<xsl:when test="$assoEntity/n1:associatedPerson">
				<xsl:for-each select="$assoEntity/n1:associatedPerson/n1:name">
					<xsl:call-template name="show-name">
						<xsl:with-param name="name" select="."/>
					</xsl:call-template>
					<br/>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$assoEntity/n1:scopingOrganization">
				<xsl:for-each select="$assoEntity/n1:scopingOrganization">
					<xsl:if test="n1:name">
						<xsl:call-template name="show-name">
							<xsl:with-param name="name" select="n1:name"/>
						</xsl:call-template>
						<br/>
					</xsl:if>
					<xsl:if test="n1:standardIndustryClassCode">
						<xsl:value-of select="n1:standardIndustryClassCode/@displayName"/>
						<xsl:text> code:</xsl:text>
						<xsl:value-of select="n1:standardIndustryClassCode/@code"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="$assoEntity/n1:code">
				<xsl:call-template name="show-code">
					<xsl:with-param name="code" select="$assoEntity/n1:code"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$assoEntity/n1:id">
				<xsl:value-of select="$assoEntity/n1:id/@extension"/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="$assoEntity/n1:id/@root"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- show code
     if originalText present, return it, otherwise, check and return attribute: display name
     -->
	<xsl:template name="show-code">
		<xsl:param name="code"/>
		<xsl:variable name="this-codeSystem">
			<xsl:value-of select="$code/@codeSystem"/>
		</xsl:variable>
		<xsl:variable name="this-code">
			<xsl:value-of select="$code/@code"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$code/n1:originalText">
				<xsl:value-of select="$code/n1:originalText"/>
			</xsl:when>
			<xsl:when test="$code/@displayName">
				<xsl:value-of select="$code/@displayName"/>
			</xsl:when>
			<!--
         <xsl:when test="$the-valuesets/*/voc:system[@root=$this-codeSystem]/voc:code[@value=$this-code]/@displayName">
           <xsl:value-of select="$the-valuesets/*/voc:system[@root=$this-codeSystem]/voc:code[@value=$this-code]/@displayName"/>
         </xsl:when>
         -->
			<xsl:otherwise>
				<xsl:value-of select="$this-code"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- show classCode -->
	<xsl:template name="show-actClassCode">
		<xsl:param name="clsCode"/>
		<xsl:choose>
			<xsl:when test=" $clsCode = 'ACT' ">
				<xsl:text>healthcare service</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'ACCM' ">
				<xsl:text>accommodation</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'ACCT' ">
				<xsl:text>account</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'ACSN' ">
				<xsl:text>accession</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'ADJUD' ">
				<xsl:text>financial adjudication</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'CONS' ">
				<xsl:text>consent</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'CONTREG' ">
				<xsl:text>container registration</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'CTTEVENT' ">
				<xsl:text>clinical trial timepoint event</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'DISPACT' ">
				<xsl:text>disciplinary action</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'ENC' ">
				<xsl:text>encounter</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'INC' ">
				<xsl:text>incident</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'INFRM' ">
				<xsl:text>inform</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'INVE' ">
				<xsl:text>invoice element</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'LIST' ">
				<xsl:text>working list</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'MPROT' ">
				<xsl:text>monitoring program</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'PCPR' ">
				<xsl:text>care provision</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'PROC' ">
				<xsl:text>procedure</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'REG' ">
				<xsl:text>registration</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'REV' ">
				<xsl:text>review</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'SBADM' ">
				<xsl:text>substance administration</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'SPCTRT' ">
				<xsl:text>speciment treatment</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'SUBST' ">
				<xsl:text>substitution</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'TRNS' ">
				<xsl:text>transportation</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'VERIF' ">
				<xsl:text>verification</xsl:text>
			</xsl:when>
			<xsl:when test=" $clsCode = 'XACT' ">
				<xsl:text>financial transaction</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- show participationType -->
	<xsl:template name="show-participationType">
		<xsl:param name="ptype"/>
		<xsl:choose>
			<xsl:when test=" $ptype='PPRF' ">
				<xsl:text>Rendering  Provider</xsl:text>
			</xsl:when>
		<xsl:when test=" $ptype='SPRF' ">
				<xsl:text>Consulting  Provider</xsl:text>
			</xsl:when>
    	<xsl:when test=" $ptype='PRF' ">
				<xsl:text>Performer</xsl:text>
		</xsl:when>
		 <xsl:otherwise>
               <xsl:text>Other Provider</xsl:text>
          </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- show participationFunction -->
	<xsl:template name="show-participationFunction">
		<xsl:param name="pFunction"/>
		<xsl:choose>
			<!-- From the HL7 v3 ParticipationFunction code system -->
			<xsl:when test=" $pFunction = 'ADMPHYS' ">
				<xsl:text>(admitting physician)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'ANEST' ">
				<xsl:text>(anesthesist)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'ANRS' ">
				<xsl:text>(anesthesia nurse)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'ATTPHYS' ">
				<xsl:text>(attending physician)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'DISPHYS' ">
				<xsl:text>(discharging physician)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'FASST' ">
				<xsl:text>(first assistant surgeon)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'MDWF' ">
				<xsl:text>(midwife)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'NASST' ">
				<xsl:text>(nurse assistant)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'PCP' ">
				<xsl:text>(primary care physician)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'PRISURG' ">
				<xsl:text>(primary surgeon)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'RNDPHYS' ">
				<xsl:text>(rounding physician)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'SASST' ">
				<xsl:text>(second assistant surgeon)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'SNRS' ">
				<xsl:text>(scrub nurse)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'TASST' ">
				<xsl:text>(third assistant)</xsl:text>
			</xsl:when>
			<!-- From the HL7 v2 Provider Role code system (2.16.840.1.113883.12.443) which is used by HITSP -->
			<xsl:when test=" $pFunction = 'CP' ">
				<xsl:text>(consulting provider)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'PP' ">
				<xsl:text>(primary care provider)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'RP' ">
				<xsl:text>(referring provider)</xsl:text>
			</xsl:when>
			<xsl:when test=" $pFunction = 'MP' ">
				<xsl:text>(medical home provider)</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="formatDateTime">
		<xsl:param name="date"/>
		<!-- month -->
		<xsl:variable name="month" select="substring ($date, 5, 2)"/>
		<xsl:choose>
			<xsl:when test="$month='01'">
				<xsl:text>January </xsl:text>
			</xsl:when>
			<xsl:when test="$month='02'">
				<xsl:text>February </xsl:text>
			</xsl:when>
			<xsl:when test="$month='03'">
				<xsl:text>March </xsl:text>
			</xsl:when>
			<xsl:when test="$month='04'">
				<xsl:text>April </xsl:text>
			</xsl:when>
			<xsl:when test="$month='05'">
				<xsl:text>May </xsl:text>
			</xsl:when>
			<xsl:when test="$month='06'">
				<xsl:text>June </xsl:text>
			</xsl:when>
			<xsl:when test="$month='07'">
				<xsl:text>July </xsl:text>
			</xsl:when>
			<xsl:when test="$month='08'">
				<xsl:text>August </xsl:text>
			</xsl:when>
			<xsl:when test="$month='09'">
				<xsl:text>September </xsl:text>
			</xsl:when>
			<xsl:when test="$month='10'">
				<xsl:text>October </xsl:text>
			</xsl:when>
			<xsl:when test="$month='11'">
				<xsl:text>November </xsl:text>
			</xsl:when>
			<xsl:when test="$month='12'">
				<xsl:text>December </xsl:text>
			</xsl:when>
		</xsl:choose>
		<!-- day -->
		<xsl:choose>
			<xsl:when test='substring ($date, 7, 1)="0"'>
				<xsl:value-of select="substring ($date, 8, 1)"/>
				<xsl:text>, </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring ($date, 7, 2)"/>
				<xsl:text>, </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<!-- year -->
		<xsl:value-of select="substring ($date, 1, 4)"/>
		<!-- time and US timezone -->
		<xsl:if test="string-length($date) > 8">
			<xsl:text>, </xsl:text>
			<!-- time -->
			<xsl:variable name="time">
				<xsl:value-of select="substring($date,9,6)"/>
			</xsl:variable>
			<xsl:variable name="hh">
				<xsl:value-of select="substring($time,1,2)"/>
			</xsl:variable>
			<xsl:variable name="mm">
				<xsl:value-of select="substring($time,3,2)"/>
			</xsl:variable>
			<xsl:variable name="ss">
				<xsl:value-of select="substring($time,5,2)"/>
			</xsl:variable>
			<xsl:if test="string-length($hh)&gt;1">
				<xsl:value-of select="$hh"/>
				<xsl:if test="string-length($mm)&gt;1 and not(contains($mm,'-')) and not (contains($mm,'+'))">
					<xsl:text>:</xsl:text>
					<xsl:value-of select="$mm"/>
					<xsl:if test="string-length($ss)&gt;1 and not(contains($ss,'-')) and not (contains($ss,'+'))">
						<xsl:text>:</xsl:text>
						<xsl:value-of select="$ss"/>
					</xsl:if>
				</xsl:if>
			</xsl:if>
			<!-- time zone -->
			<xsl:variable name="tzon">
				<xsl:choose>
					<xsl:when test="contains($date,'+')">
						<xsl:text>+</xsl:text>
						<xsl:value-of select="substring-after($date, '+')"/>
					</xsl:when>
					<xsl:when test="contains($date,'-')">
						<xsl:text>-</xsl:text>
						<xsl:value-of select="substring-after($date, '-')"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<!-- reference: http://www.timeanddate.com/library/abbreviations/timezones/na/ -->
				<xsl:when test="$tzon = '-0500' ">
					<xsl:text>, EST</xsl:text>
				</xsl:when>
				<xsl:when test="$tzon = '-0600' ">
					<xsl:text>, CST</xsl:text>
				</xsl:when>
				<xsl:when test="$tzon = '-0700' ">
					<xsl:text>, MST</xsl:text>
				</xsl:when>
				<xsl:when test="$tzon = '-0800' ">
					<xsl:text>, PST</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$tzon"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- convert to lower case -->
	<xsl:template name="caseDown">
		<xsl:param name="data"/>
		<xsl:if test="$data">
			<xsl:value-of select="translate($data, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
		</xsl:if>
	</xsl:template>
	<!-- convert to upper case -->
	<xsl:template name="caseUp">
		<xsl:param name="data"/>
		<xsl:if test="$data">
			<xsl:value-of select="translate($data,'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
		</xsl:if>
	</xsl:template>
	<!-- convert first character to upper case -->
	<xsl:template name="firstCharCaseUp">
		<xsl:param name="data"/>
		<xsl:if test="$data">
			<xsl:call-template name="caseUp">
				<xsl:with-param name="data" select="substring($data,1,1)"/>
			</xsl:call-template>
			<xsl:value-of select="substring($data,2)"/>
		</xsl:if>
	</xsl:template>
	<!-- show-noneFlavor -->
	<xsl:template name="show-noneFlavor">
		<xsl:param name="nf"/>
		<xsl:choose>
			<xsl:when test=" $nf = 'NI' ">
				<xsl:text>no information</xsl:text>
			</xsl:when>
			<xsl:when test=" $nf = 'INV' ">
				<xsl:text>invalid</xsl:text>
			</xsl:when>
			<xsl:when test=" $nf = 'MSK' ">
				<xsl:text>masked</xsl:text>
			</xsl:when>
			<xsl:when test=" $nf = 'NA' ">
				<xsl:text>not applicable</xsl:text>
			</xsl:when>
			<xsl:when test=" $nf = 'UNK' ">
				<xsl:text>unknown</xsl:text>
			</xsl:when>
			<xsl:when test=" $nf = 'OTH' ">
				<xsl:text>other</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="addCSS">
		<style type="text/css">
			<xsl:text>
body {
  color: #003366;
  background-color: #FFFFFF;
  font-family: Verdana, Tahoma, sans-serif;
  font-size: 11px;
}

a {
  color: #003366;
  background-color: #FFFFFF;
}

h1 {
  font-size: 12pt;
  font-weight: bold;
}

h2 {
  font-size: 11pt;
  font-weight: bold;
}

h3 {
  font-size: 10pt;
  font-weight: bold;
}

h4 {
  font-size: 8pt;
  font-weight: bold;
}


table {
  line-height: 10pt;
  width: 100%;
}

th {
  background-color: #ffd700;
}

td {
  padding: 0.1cm 0.2cm;
  vertical-align: top;
  background-color: #ffffcc;
}

.h1center {
  font-size: 12pt;
  font-weight: bold;
  text-align: center;
  width: 80%;
}

.header_table{
  border: 1pt inset #00008b;
}

.td_label{
  font-weight: bold;
  color: white;
}

.td_header_role_name{
  width: 20%;
  background-color: #3399ff;
}

.td_header_role_value{
  width: 80%;
  background-color: #ccccff;
}

.Bold{
  font-weight: bold;
}

.Italics{
  font-style: italic;
}

.Underline{
  text-decoration:underline;
}

.internal_format
{
	list-style: none;
	list-style-position:outside;
	margin:0;
	padding:0;
	border:0;
	border-collapse: collapse;
}
          </xsl:text>
		</style>
	</xsl:template>
</xsl:stylesheet>
