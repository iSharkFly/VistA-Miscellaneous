<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:cda="urn:hl7-org:v3"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                version="1.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output method="text"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
            <xsl:variable name="p_1" select="1+    count(preceding-sibling::*[name()=name(current())])"/>
            <xsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<xsl:value-of select="$p_1"/>]</xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>']</xsl:text>
            <xsl:variable name="p_2"
                          select="1+   count(preceding-sibling::*[local-name()=local-name(current())])"/>
            <xsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<xsl:value-of select="$p_2"/>]</xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <xsl:apply-templates select="/" mode="M6"/>
      <xsl:apply-templates select="/" mode="M7"/>
      <xsl:apply-templates select="/" mode="M8"/>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


<!--PATTERN p-2.16.840.1.113883.10.20.12-errorsHL7 QRDA Category I Header (Section 2) - errors validation phase-->


	<!--RULE -->
<xsl:template match="/" priority="1006" mode="M6">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:realmCode[@code = &#34;US&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-I: The realmCode element SHALL be present where the value of @code is US.
     (.//cda:realmCode[@code = "US"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:typeId[@root = &#34;2.16.840.1.113883.1.3&#34; and @extension = &#34;POCD_HD000040&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-2: The value of typeId/@root SHALL be 2.16.840.1.113883.1.3 and value of 
       typeId/@extension SHALL be POCD_HD000040.
     (.//cda:typeId[@root = "2.16.840.1.113883.1.3" and @extension = "POCD_HD000040"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(cda:ClinicalDocument/cda:templateId) = 0"/>
         <xsl:otherwise>
            <xsl:message>
      Error: CONF-QRDA1-3 The CMS EHR QRDA Report SHALL contain at least one ClincalDocument/templateId element
     (not(cda:ClinicalDocument/cda:templateId) = 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:templateId/@root=&#34;2.16.840.1.113883.10.20.12&#34; and .//cda:templateId/@root=&#34;2.16.840.1.113883.3.249.11.100.1&#34;"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-4: The value of one ClinicalDocument/templateId/@root SHALL be
       2.16.840.1.113883.10.20.12 and PQRI QRDA category I templateId 'root' value SHALL be 2.16.840.1.113883.3.249.11.100.1.
     (.//cda:templateId/@root="2.16.840.1.113883.10.20.12" and .//cda:templateId/@root="2.16.840.1.113883.3.249.11.100.1")</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;2.16.840.1.113883.10.20.12&#34;]" priority="1005"
                 mode="M6">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:code) = 1 and cda:code[@code=&#34;55182-0&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-7: A QRDA Category I report SHALL contain exactly one
       ClinicalDocument/code with a value of 55182-0 2.16.840.1.113883.6.1
       LOINC STATIC.
     (count(cda:code) = 1 and cda:code[@code="55182-0" and @codeSystem="2.16.840.1.113883.6.1"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(translate(cda:title,'QWERTYUIOPASDFGHJKLZXCVBNM','qwertyuiopasdfghjklzxcvbnm'),'qrda incidence report') or                   contains(translate(cda:title,'QWERTYUIOPASDFGHJKLZXCVBNM','qwertyuiopasdfghjklzxcvbnm'),'quality measure report')"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-8: A QRDA Category I report SHALL contain exactly one
       ClinicalDocument/title element valued with a case-insensitive, text
       string containing "QRDA Incidence Report" or "Quality measure
       Report".
     (contains(translate(cda:title,'QWERTYUIOPASDFGHJKLZXCVBNM','qwertyuiopasdfghjklzxcvbnm'),'qrda incidence report') or contains(translate(cda:title,'QWERTYUIOPASDFGHJKLZXCVBNM','qwertyuiopasdfghjklzxcvbnm'),'quality measure report'))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(cda:effectiveTime/@value) &gt;= 8"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-10 The effectiveTime value attribute value SHALL be at least precise to the day YYYYMMDD.
     (string-length(cda:effectiveTime/@value) &gt;= 8)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:confidentialityCode[@code=&#34;N&#34; and @codeSystem=&#34;2.16.840.1.113883.5.25&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
      Error: CONF-QRDA1-12: The confidentialityCode 'codeSystem' attribute value SHALL be '2.16.840.1.113883.5.25. The confidentialityCode 'codeSystem' attribute value SHALL be '2.16.840.1.113883.5.25
     (cda:confidentialityCode[@code="N" and @codeSystem="2.16.840.1.113883.5.25"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(cda:setId) = 0"/>
         <xsl:otherwise>
            <xsl:message>
      Error: CONF-QRDA1-13: setId element is missing. The 'setId' element SHALL be present.
     (not(cda:setId) = 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(cda:versionNumber) = 0"/>
         <xsl:otherwise>
            <xsl:message>
      Error: CONF-QRDA1-16  versionNumber element is missing. The 'versionNumber' element SHALL be present. 
     (not(cda:versionNumber) = 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:versionNumber/@value castable as xs:integer"/>
         <xsl:otherwise>
            <xsl:message>
      Error: CONF-QRDA1-17: versionNumber/@value SHALL be an integer
      (cda:versionNumber/@value castable as xs:integer)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:recordTarget/cda:patientRole) = 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-18: A QRDA Category I report SHALL contain exactly one
       ClinicalDocument/recordTarget/PatientRole.
     (count(cda:recordTarget/cda:patientRole) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:recordTarget/cda:patientRole/cda:id[@root = &#34;2.16.840.1.113883.4.1&#34; or @root = &#34;2.16.840.1.113883.4.2&#34; or @root = &#34;2.16.840.1.113883.4.3.40&#34; or @root = &#34;2.16.840.1.113883.4.3.49&#34; or @root = &#34;2.16.840.1.113883.4.3.38&#34; or @root = &#34;2.16.840.1.113883.4.3.37&#34; or @root = &#34;2.16.840.1.113883.4.3.36&#34; or @root = &#34;2.16.840.1.113883.4.3.35&#34; or @root = &#34;2.16.840.1.113883.4.3.34&#34; or @root = &#34;2.16.840.1.113883.4.3.48&#34; or @root = &#34;2.16.840.1.113883.4.3.32&#34; or @root = &#34;2.16.840.1.113883.4.3.39&#34; or @root = &#34;2.16.840.1.113883.4.3.15&#34; or @root = &#34;2.16.840.1.113883.4.3.51&#34; or @root = &#34;2.16.840.1.113883.4.3.53&#34; or @root = &#34;2.16.840.1.113883.4.3.54&#34; or @root = &#34;2.16.840.1.113883.4.3.55&#34; or @root = &#34;2.16.840.1.113883.4.3.56&#34; or @root = &#34;2.16.840.1.113883.4.3.42&#34; or @root = &#34;2.16.840.1.113883.4.3.47&#34; or @root = &#34;2.16.840.1.113883.4.3.41&#34; or @root = &#34;2.16.840.1.113883.4.3.46&#34; or @root = &#34;2.16.840.1.113883.4.3.45&#34; or @root = &#34;2.16.840.1.113883.4.3.31&#34; or @root = &#34;2.16.840.1.113883.4.3.50&#34; or @root = &#34;2.16.840.1.113883.4.3.30&#34; or @root = &#34;2.16.840.1.113883.4.3.44&#34; or @root = &#34;2.16.840.1.113883.4.3.16&#34; or @root = &#34;2.16.840.1.113883.4.3.5&#34; or @root = &#34;2.16.840.1.113883.4.3.9&#34; or @root = &#34;2.16.840.1.113883.4.3.8&#34; or @root = &#34;2.16.840.1.113883.4.3.6&#34; or @root = &#34;2.16.840.1.113883.4.3.33&#34; or @root = &#34;2.16.840.1.113883.4.3.11&#34; or @root = &#34;2.16.840.1.113883.4.3.10&#34; or @root = &#34;2.16.840.1.113883.4.3.12&#34; or @root = &#34;2.16.840.1.113883.4.3.4&#34; or @root = &#34;2.16.840.1.113883.4.3.2&#34; or @root = &#34;2.16.840.1.113883.4.3.1&#34; or @root = &#34;2.16.840.1.113883.4.3&#34; or @root = &#34;2.16.840.1.113883.4.3.17&#34; or @root = &#34;2.16.840.1.113883.4.3.26&#34; or @root = &#34;2.16.840.1.113883.4.3.29&#34; or @root = &#34;2.16.840.1.113883.4.3.18&#34; or @root = &#34;2.16.840.1.113883.4.3.28&#34; or @root = &#34;2.16.840.1.113883.4.3.25&#34; or @root = &#34;2.16.840.1.113883.4.3.24&#34; or @root = &#34;2.16.840.1.113883.4.3.23&#34; or @root = &#34;2.16.840.1.113883.4.3.13&#34; or @root = &#34;2.16.840.1.113883.4.3.22&#34; or @root = &#34;2.16.840.1.113883.4.3.21&#34; or @root = &#34;2.16.840.1.113883.4.3.20&#34; or @root = &#34;2.16.840.1.113883.4.3.19&#34; or @root = &#34;2.16.840.1.113883.4.3.27&#34; or @root = &#34;2.16.840.1.113883.4.4&#34; or @root = &#34;2.16.840.1.113883.4.5&#34; and @extension = &#34;*&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-19 @root contains OID for the coding system used to identify the patient.  The value of @extension is the unique patient identifier the EHR sysetm uses fo record activity on a patient.  Commonly used OIDs for entries to identify patient sucha as SSN, TIN, DLN, etc. are available at Appendix_L-OIDs tab of the Downloadable Resources table.
     (cda:recordTarget/cda:patientRole/cda:id[@root = "2.16.840.1.113883.4.1" or @root = "2.16.840.1.113883.4.2" or @root = "2.16.840.1.113883.4.3.40" or @root = "2.16.840.1.113883.4.3.49" or @root = "2.16.840.1.113883.4.3.38" or @root = "2.16.840.1.113883.4.3.37" or @root = "2.16.840.1.113883.4.3.36" or @root = "2.16.840.1.113883.4.3.35" or @root = "2.16.840.1.113883.4.3.34" or @root = "2.16.840.1.113883.4.3.48" or @root = "2.16.840.1.113883.4.3.32" or @root = "2.16.840.1.113883.4.3.39" or @root = "2.16.840.1.113883.4.3.15" or @root = "2.16.840.1.113883.4.3.51" or @root = "2.16.840.1.113883.4.3.53" or @root = "2.16.840.1.113883.4.3.54" or @root = "2.16.840.1.113883.4.3.55" or @root = "2.16.840.1.113883.4.3.56" or @root = "2.16.840.1.113883.4.3.42" or @root = "2.16.840.1.113883.4.3.47" or @root = "2.16.840.1.113883.4.3.41" or @root = "2.16.840.1.113883.4.3.46" or @root = "2.16.840.1.113883.4.3.45" or @root = "2.16.840.1.113883.4.3.31" or @root = "2.16.840.1.113883.4.3.50" or @root = "2.16.840.1.113883.4.3.30" or @root = "2.16.840.1.113883.4.3.44" or @root = "2.16.840.1.113883.4.3.16" or @root = "2.16.840.1.113883.4.3.5" or @root = "2.16.840.1.113883.4.3.9" or @root = "2.16.840.1.113883.4.3.8" or @root = "2.16.840.1.113883.4.3.6" or @root = "2.16.840.1.113883.4.3.33" or @root = "2.16.840.1.113883.4.3.11" or @root = "2.16.840.1.113883.4.3.10" or @root = "2.16.840.1.113883.4.3.12" or @root = "2.16.840.1.113883.4.3.4" or @root = "2.16.840.1.113883.4.3.2" or @root = "2.16.840.1.113883.4.3.1" or @root = "2.16.840.1.113883.4.3" or @root = "2.16.840.1.113883.4.3.17" or @root = "2.16.840.1.113883.4.3.26" or @root = "2.16.840.1.113883.4.3.29" or @root = "2.16.840.1.113883.4.3.18" or @root = "2.16.840.1.113883.4.3.28" or @root = "2.16.840.1.113883.4.3.25" or @root = "2.16.840.1.113883.4.3.24" or @root = "2.16.840.1.113883.4.3.23" or @root = "2.16.840.1.113883.4.3.13" or @root = "2.16.840.1.113883.4.3.22" or @root = "2.16.840.1.113883.4.3.21" or @root = "2.16.840.1.113883.4.3.20" or @root = "2.16.840.1.113883.4.3.19" or @root = "2.16.840.1.113883.4.3.27" or @root = "2.16.840.1.113883.4.4" or @root = "2.16.840.1.113883.4.5" and @extension = "*"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:recordTarget/cda:patientRole/cda:patient/cda:name) &gt;= 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error:  CONF-QRDA1-23 patient's legal 'name' element is expected at least once. The patient's legal 'name' element SHALL be submitted at least exactly once.
     (count(cda:recordTarget/cda:patientRole/cda:patient/cda:name) &gt;= 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given) &gt;= 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error:  CONF-QRDA1-24 patient's legal name 'given' (first name) element is expected at least once. The patient's legal 'given' (first name) element SHALL be submitted at least exactly once.
     (count(cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given) &gt;= 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given/@value) &lt;= 30"/>
         <xsl:otherwise>
            <xsl:message>
       Error:  CONF-QRDA1-24 patient's legal name 'given' (first name) element value length SHALL not be more than 30 characters. patient's legal name 'given' (first name) element value length SHALL not be more than 30 characters.
     (string-length(cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given/@value) &lt;= 30)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family) &gt;= 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error:  CONF-QRDA1-25 patient's legal name 'family' (last name) element is expected at least once. The patient's legal 'family' (last name) element SHALL be submitted at least exactly once.
     (count(cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family) &gt;= 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family/@value) &lt;= 30"/>
         <xsl:otherwise>
            <xsl:message>
       Error:  CONF-QRDA1-25 patient's legal name 'family' (last name) element value length SHALL not be more than 30 characters. patient's legal name 'family' (last name) element value length SHALL not be more than 30 characters.
     (string-length(cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family/@value) &lt;= 30)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:recordTarget/cda:patientRole/cda:patient/cda:ethnicGroupCode[@codeSystem=&#34;2.16.840.1.113883.5.50&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-26 The patient's ethnic group code 'codeSystem' attribute value SHALL be '2.16.840.1.113883.5.50'.
     (cda:recordTarget/cda:patientRole/cda:patient/cda:ethnicGroupCode[@codeSystem="2.16.840.1.113883.5.50"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:recordTarget/cda:patientRole/cda:patient/cda:ethnicGroupCode[@code = &#34;2135-2&#34; or @code = &#34;2137-8&#34; or @code = &#34;2138-6&#34; or @code = &#34;2139-4&#34; or @code = &#34;2140-2&#34; or @code = &#34;2141-0&#34; or @code = &#34;2142-8&#34; or @code = &#34;2143-6&#34; or @code = &#34;2144-4&#34; or @code = &#34;2145-1&#34; or @code = &#34;2146-9&#34; or @code = &#34;2148-5&#34; or @code = &#34;2149-3&#34; or @code = &#34;2150-1&#34; or @code = &#34;2151-9&#34; or @code = &#34;2152-7&#34; or @code = &#34;2153-5&#34; or @code = &#34;2155-0&#34; or @code = &#34;2156-8&#34; or @code = &#34;2157-6&#34; or @code = &#34;2158-4&#34; or @code = &#34;2159-2&#34; or @code = &#34;2160-0&#34; or @code = &#34;2161-8&#34; or @code = &#34;2162-6&#34; or @code = &#34;2163-4&#34; or @code = &#34;2165-9&#34; or @code = &#34;2166-7&#34; or @code = &#34;2167-5&#34; or @code = &#34;2168-3&#34; or @code = &#34;2169-1&#34; or @code = &#34;2170-9&#34; or @code = &#34;2171-7&#34; or @code = &#34;2172-5&#34; or @code = &#34;2173-3&#34; or @code = &#34;2174-1&#34; or @code = &#34;2175-8&#34; or @code = &#34;2176-6&#34; or @code = &#34;2178-2&#34; or @code = &#34;2180-8&#34; or @code = &#34;2182-4&#34; or @code = &#34;2184-0&#34; or @code = &#34;2186-5&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-26  The patient's ethnic group 'code' value SHALL be valid according to Appendix_M-Ethnicity in the posted Downloadable Resource table.
     (cda:recordTarget/cda:patientRole/cda:patient/cda:ethnicGroupCode[@code = "2135-2" or @code = "2137-8" or @code = "2138-6" or @code = "2139-4" or @code = "2140-2" or @code = "2141-0" or @code = "2142-8" or @code = "2143-6" or @code = "2144-4" or @code = "2145-1" or @code = "2146-9" or @code = "2148-5" or @code = "2149-3" or @code = "2150-1" or @code = "2151-9" or @code = "2152-7" or @code = "2153-5" or @code = "2155-0" or @code = "2156-8" or @code = "2157-6" or @code = "2158-4" or @code = "2159-2" or @code = "2160-0" or @code = "2161-8" or @code = "2162-6" or @code = "2163-4" or @code = "2165-9" or @code = "2166-7" or @code = "2167-5" or @code = "2168-3" or @code = "2169-1" or @code = "2170-9" or @code = "2171-7" or @code = "2172-5" or @code = "2173-3" or @code = "2174-1" or @code = "2175-8" or @code = "2176-6" or @code = "2178-2" or @code = "2180-8" or @code = "2182-4" or @code = "2184-0" or @code = "2186-5"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode)"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-27 The 'administrativeGenderCode' element SHALL be present.
     ((cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode[@codeSystem = &#34;2.16.840.1.113883.5.1&#34;])"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-27 The patient's administrativeGenderCode 'codeSystem' attribute value SHALL be '2.16.840.1.113883.5.1'.
     ((cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode[@codeSystem = "2.16.840.1.113883.5.1"]))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode[@code=&#34;M&#34; or @code=&#34;F&#34; or @code=&#34;UN&#34;])"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-27 The patient's administrative gender 'code'  value SHALL be valid according to Appendix_N-Gender in the posted Downloadable Resource table.
     ((cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode[@code="M" or @code="F" or @code="UN"]))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:patient/cda:raceCode)"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-28 The 'raceCode' element SHALL be present.
     ((cda:recordTarget/cda:patientRole/cda:patient/cda:raceCode))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:patient/cda:raceCode[@codeSystem = &#34;2.16.840.1.113883.5.104&#34;])"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-28 The patient's raceCode 'codeSystem' attribute value SHALL be '2.16.840.1.113883.5.104'.
     ((cda:recordTarget/cda:patientRole/cda:patient/cda:raceCode[@codeSystem = "2.16.840.1.113883.5.104"]))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:patient/cda:raceCode[@code = &#34;1002-5&#34; or @code = &#34;1004-1&#34; or @code = &#34;1006-6&#34; or @code = &#34;1008-2&#34; or @code = &#34;1010-8&#34; or @code = &#34;1011-6&#34; or @code = &#34;1012-4&#34; or @code = &#34;1013-2&#34; or @code = &#34;1014-0&#34; or @code = &#34;1015-7&#34; or @code = &#34;1016-5&#34; or @code = &#34;1017-3&#34; or @code = &#34;1018-1&#34; or @code = &#34;1019-9&#34; or @code = &#34;1021-5&#34; or @code = &#34;1022-3&#34; or @code = &#34;1023-1&#34; or @code = &#34;1024-9&#34; or @code = &#34;1026-4&#34; or @code = &#34;1028-0&#34; or @code = &#34;1030-6&#34; or @code = &#34;1031-4&#34; or @code = &#34;1033-0&#34; or @code = &#34;1035-5&#34; or @code = &#34;1037-1&#34; or @code = &#34;1039-7&#34; or @code = &#34;1041-3&#34; or @code = &#34;1042-1&#34; or @code = &#34;1044-7&#34; or @code = &#34;1045-4&#34; or @code = &#34;1046-2&#34; or @code = &#34;1047-0&#34; or @code = &#34;1048-8&#34; or @code = &#34;1049-6&#34; or @code = &#34;1050-4&#34; or @code = &#34;1051-2&#34; or @code = &#34;1053-8&#34; or @code = &#34;1054-6&#34; or @code = &#34;1055-3&#34; or @code = &#34;1056-1&#34; or @code = &#34;1057-9&#34; or @code = &#34;1058-7&#34; or @code = &#34;1059-5&#34; or @code = &#34;1060-3&#34; or @code = &#34;1061-1&#34; or @code = &#34;1062-9&#34; or @code = &#34;1063-7&#34; or @code = &#34;1064-5&#34; or @code = &#34;1065-2&#34; or @code = &#34;1066-0&#34; or @code = &#34;1068-6&#34; or @code = &#34;1069-4&#34; or @code = &#34;1070-2&#34; or @code = &#34;1071-0&#34; or @code = &#34;1072-8&#34; or @code = &#34;1073-6&#34; or @code = &#34;1074-4&#34; or @code = &#34;1076-9&#34; or @code = &#34;1078-5&#34; or @code = &#34;1080-1&#34; or @code = &#34;1082-7&#34; or @code = &#34;1083-5&#34; or @code = &#34;1084-3&#34; or @code = &#34;1086-8&#34; or @code = &#34;1088-4&#34; or @code = &#34;1089-2&#34; or @code = &#34;1090-0&#34; or @code = &#34;1091-8&#34; or @code = &#34;1092-6&#34; or @code = &#34;1093-4&#34; or @code = &#34;1094-2&#34; or @code = &#34;1095-9&#34; or @code = &#34;1096-7&#34; or @code = &#34;1097-5&#34; or @code = &#34;1098-3&#34; or @code = &#34;1100-7&#34; or @code = &#34;1102-3&#34; or @code = &#34;1103-1&#34; or @code = &#34;1104-9&#34; or @code = &#34;1106-4&#34; or @code = &#34;1108-0&#34; or @code = &#34;1109-8&#34; or @code = &#34;1110-6&#34; or @code = &#34;1112-2&#34; or @code = &#34;1114-8&#34; or @code = &#34;1115-5&#34; or @code = &#34;1116-3&#34; or @code = &#34;1117-1&#34; or @code = &#34;1118-9&#34; or @code = &#34;1119-7&#34; or @code = &#34;1120-5&#34; or @code = &#34;1121-3&#34; or @code = &#34;1123-9&#34; or @code = &#34;1124-7&#34; or @code = &#34;1125-4&#34; or @code = &#34;1126-2&#34; or @code = &#34;1127-0&#34; or @code = &#34;1128-8&#34; or @code = &#34;1129-6&#34; or @code = &#34;1130-4&#34; or @code = &#34;1131-2&#34; or @code = &#34;1132-0&#34; or @code = &#34;1133-8&#34; or @code = &#34;1134-6&#34; or @code = &#34;1135-3&#34; or @code = &#34;1136-1&#34; or @code = &#34;1137-9&#34; or @code = &#34;1138-7&#34; or @code = &#34;1139-5&#34; or @code = &#34;1140-3&#34; or @code = &#34;1141-1&#34; or @code = &#34;1142-9&#34; or @code = &#34;1143-7&#34; or @code = &#34;1144-5&#34; or @code = &#34;1145-2&#34; or @code = &#34;1146-0&#34; or @code = &#34;1147-8&#34; or @code = &#34;1148-6&#34; or @code = &#34;1150-2&#34; or @code = &#34;1151-0&#34; or @code = &#34;1153-6&#34; or @code = &#34;1155-1&#34; or @code = &#34;1156-9&#34; or @code = &#34;1157-7&#34; or @code = &#34;1158-5&#34; or @code = &#34;1159-3&#34; or @code = &#34;1160-1&#34; or @code = &#34;1162-7&#34; or @code = &#34;1163-5&#34; or @code = &#34;1165-0&#34; or @code = &#34;1167-6&#34; or @code = &#34;1169-2&#34; or @code = &#34;1171-8&#34; or @code = &#34;1173-4&#34; or @code = &#34;1175-9&#34; or @code = &#34;1176-7&#34; or @code = &#34;1178-3&#34; or @code = &#34;1180-9&#34; or @code = &#34;1182-5&#34; or @code = &#34;1184-1&#34; or @code = &#34;1186-6&#34; or @code = &#34;1187-4&#34; or @code = &#34;1189-0&#34; or @code = &#34;1191-6&#34; or @code = &#34;1193-2&#34; or @code = &#34;1194-0&#34; or @code = &#34;1195-7&#34; or @code = &#34;1196-5&#34; or @code = &#34;1197-3&#34; or @code = &#34;1198-1&#34; or @code = &#34;1199-9&#34; or @code = &#34;1200-5&#34; or @code = &#34;1201-3&#34; or @code = &#34;1202-1&#34; or @code = &#34;1203-9&#34; or @code = &#34;1204-7&#34; or @code = &#34;1205-4&#34; or @code = &#34;1207-0&#34; or @code = &#34;1209-6&#34; or @code = &#34;1211-2&#34; or @code = &#34;1212-0&#34; or @code = &#34;1214-6&#34; or @code = &#34;1215-3&#34; or @code = &#34;1216-1&#34; or @code = &#34;1217-9&#34; or @code = &#34;1218-7&#34; or @code = &#34;1219-5&#34; or @code = &#34;1220-3&#34; or @code = &#34;1222-9&#34; or @code = &#34;1223-7&#34; or @code = &#34;1224-5&#34; or @code = &#34;1225-2&#34; or @code = &#34;1226-0&#34; or @code = &#34;1227-8&#34; or @code = &#34;1228-6&#34; or @code = &#34;1229-4&#34; or @code = &#34;1230-2&#34; or @code = &#34;1231-0&#34; or @code = &#34;1233-6&#34; or @code = &#34;1234-4&#34; or @code = &#34;1235-1&#34; or @code = &#34;1236-9&#34; or @code = &#34;1237-7&#34; or @code = &#34;1238-5&#34; or @code = &#34;1239-3&#34; or @code = &#34;1240-1&#34; or @code = &#34;1241-9&#34; or @code = &#34;1242-7&#34; or @code = &#34;1243-5&#34; or @code = &#34;1244-3&#34; or @code = &#34;1245-0&#34; or @code = &#34;1246-8&#34; or @code = &#34;1247-6&#34; or @code = &#34;1248-4&#34; or @code = &#34;1250-0&#34; or @code = &#34;1252-6&#34; or @code = &#34;1254-2&#34; or @code = &#34;1256-7&#34; or @code = &#34;1258-3&#34; or @code = &#34;1260-9&#34; or @code = &#34;1262-5&#34; or @code = &#34;1264-1&#34; or @code = &#34;1265-8&#34; or @code = &#34;1267-4&#34; or @code = &#34;1269-0&#34; or @code = &#34;1271-6&#34; or @code = &#34;1272-4&#34; or @code = &#34;1273-2&#34; or @code = &#34;1275-7&#34; or @code = &#34;1277-3&#34; or @code = &#34;1279-9&#34; or @code = &#34;1281-5&#34; or @code = &#34;1282-3&#34; or @code = &#34;1283-1&#34; or @code = &#34;1285-6&#34; or @code = &#34;1286-4&#34; or @code = &#34;1287-2&#34; or @code = &#34;1288-0&#34; or @code = &#34;1289-8&#34; or @code = &#34;1290-6&#34; or @code = &#34;1291-4&#34; or @code = &#34;1292-2&#34; or @code = &#34;1293-0&#34; or @code = &#34;1294-8&#34; or @code = &#34;1295-5&#34; or @code = &#34;1297-1&#34; or @code = &#34;1299-7&#34; or @code = &#34;1301-1&#34; or @code = &#34;1303-7&#34; or @code = &#34;1305-2&#34; or @code = &#34;1306-0&#34; or @code = &#34;1307-8&#34; or @code = &#34;1309-4&#34; or @code = &#34;1310-2&#34; or @code = &#34;1312-8&#34; or @code = &#34;1313-6&#34; or @code = &#34;1314-4&#34; or @code = &#34;1315-1&#34; or @code = &#34;1317-7&#34; or @code = &#34;1319-3&#34; or @code = &#34;1321-9&#34; or @code = &#34;1323-5&#34; or @code = &#34;1325-0&#34; or @code = &#34;1326-8&#34; or @code = &#34;1327-6&#34; or @code = &#34;1328-4&#34; or @code = &#34;1329-2&#34; or @code = &#34;1331-8&#34; or @code = &#34;1332-6&#34; or @code = &#34;1333-4&#34; or @code = &#34;1334-2&#34; or @code = &#34;1335-9&#34; or @code = &#34;1336-7&#34; or @code = &#34;1337-5&#34; or @code = &#34;1338-3&#34; or @code = &#34;1340-9&#34; or @code = &#34;1342-5&#34; or @code = &#34;1344-1&#34; or @code = &#34;1345-8&#34; or @code = &#34;1346-6&#34; or @code = &#34;1348-2&#34; or @code = &#34;1350-8&#34; or @code = &#34;1352-4&#34; or @code = &#34;1354-0&#34; or @code = &#34;1356-5&#34; or @code = &#34;1358-1&#34; or @code = &#34;1359-9&#34; or @code = &#34;1360-7&#34; or @code = &#34;1361-5&#34; or @code = &#34;1363-1&#34; or @code = &#34;1365-6&#34; or @code = &#34;1366-4&#34; or @code = &#34;1368-0&#34; or @code = &#34;1370-6&#34; or @code = &#34;1372-2&#34; or @code = &#34;1374-8&#34; or @code = &#34;1376-3&#34; or @code = &#34;1378-9&#34; or @code = &#34;1380-5&#34; or @code = &#34;1382-1&#34; or @code = &#34;1383-9&#34; or @code = &#34;1384-7&#34; or @code = &#34;1385-4&#34; or @code = &#34;1387-0&#34; or @code = &#34;1389-6&#34; or @code = &#34;1391-2&#34; or @code = &#34;1392-0&#34; or @code = &#34;1393-8&#34; or @code = &#34;1394-6&#34; or @code = &#34;1395-3&#34; or @code = &#34;1396-1&#34; or @code = &#34;1397-9&#34; or @code = &#34;1398-7&#34; or @code = &#34;1399-5&#34; or @code = &#34;1400-1&#34; or @code = &#34;1401-9&#34; or @code = &#34;1403-5&#34; or @code = &#34;1405-0&#34; or @code = &#34;1407-6&#34; or @code = &#34;1409-2&#34; or @code = &#34;1411-8&#34; or @code = &#34;1412-6&#34; or @code = &#34;1413-4&#34; or @code = &#34;1414-2&#34; or @code = &#34;1416-7&#34; or @code = &#34;1417-5&#34; or @code = &#34;1418-3&#34; or @code = &#34;1419-1&#34; or @code = &#34;1420-9&#34; or @code = &#34;1421-7&#34; or @code = &#34;1422-5&#34; or @code = &#34;1423-3&#34; or @code = &#34;1424-1&#34; or @code = &#34;1425-8&#34; or @code = &#34;1426-6&#34; or @code = &#34;1427-4&#34; or @code = &#34;1428-2&#34; or @code = &#34;1429-0&#34; or @code = &#34;1430-8&#34; or @code = &#34;1431-6&#34; or @code = &#34;1432-4&#34; or @code = &#34;1433-2&#34; or @code = &#34;1434-0&#34; or @code = &#34;1435-7&#34; or @code = &#34;1436-5&#34; or @code = &#34;1437-3&#34; or @code = &#34;1439-9&#34; or @code = &#34;1441-5&#34; or @code = &#34;1442-3&#34; or @code = &#34;1443-1&#34; or @code = &#34;1445-6&#34; or @code = &#34;1446-4&#34; or @code = &#34;1448-0&#34; or @code = &#34;1450-6&#34; or @code = &#34;1451-4&#34; or @code = &#34;1453-0&#34; or @code = &#34;1454-8&#34; or @code = &#34;1456-3&#34; or @code = &#34;1457-1&#34; or @code = &#34;1458-9&#34; or @code = &#34;1460-5&#34; or @code = &#34;1462-1&#34; or @code = &#34;1464-7&#34; or @code = &#34;1465-4&#34; or @code = &#34;1466-2&#34; or @code = &#34;1467-0&#34; or @code = &#34;1468-8&#34; or @code = &#34;1469-6&#34; or @code = &#34;1470-4&#34; or @code = &#34;1471-2&#34; or @code = &#34;1472-0&#34; or @code = &#34;1474-6&#34; or @code = &#34;1475-3&#34; or @code = &#34;1476-1&#34; or @code = &#34;1478-7&#34; or @code = &#34;1479-5&#34; or @code = &#34;1480-3&#34; or @code = &#34;1481-1&#34; or @code = &#34;1482-9&#34; or @code = &#34;1483-7&#34; or @code = &#34;1484-5&#34; or @code = &#34;1485-2&#34; or @code = &#34;1487-8&#34; or @code = &#34;1489-4&#34; or @code = &#34;1490-2&#34; or @code = &#34;1491-0&#34; or @code = &#34;1492-8&#34; or @code = &#34;1493-6&#34; or @code = &#34;1494-4&#34; or @code = &#34;1495-1&#34; or @code = &#34;1496-9&#34; or @code = &#34;1497-7&#34; or @code = &#34;1498-5&#34; or @code = &#34;1499-3&#34; or @code = &#34;1500-8&#34; or @code = &#34;1501-6&#34; or @code = &#34;1502-4&#34; or @code = &#34;1503-2&#34; or @code = &#34;1504-0&#34; or @code = &#34;1505-7&#34; or @code = &#34;1506-5&#34; or @code = &#34;1507-3&#34; or @code = &#34;1508-1&#34; or @code = &#34;1509-9&#34; or @code = &#34;1510-7&#34; or @code = &#34;1511-5&#34; or @code = &#34;1512-3&#34; or @code = &#34;1513-1&#34; or @code = &#34;1514-9&#34; or @code = &#34;1515-6&#34; or @code = &#34;1516-4&#34; or @code = &#34;1518-0&#34; or @code = &#34;1519-8&#34; or @code = &#34;1520-6&#34; or @code = &#34;1521-4&#34; or @code = &#34;1522-2&#34; or @code = &#34;1523-0&#34; or @code = &#34;1524-8&#34; or @code = &#34;1525-5&#34; or @code = &#34;1526-3&#34; or @code = &#34;1527-1&#34; or @code = &#34;1528-9&#34; or @code = &#34;1529-7&#34; or @code = &#34;1530-5&#34; or @code = &#34;1531-3&#34; or @code = &#34;1532-1&#34; or @code = &#34;1533-9&#34; or @code = &#34;1534-7&#34; or @code = &#34;1535-4&#34; or @code = &#34;1536-2&#34; or @code = &#34;1537-0&#34; or @code = &#34;1538-8&#34; or @code = &#34;1539-6&#34; or @code = &#34;1541-2&#34; or @code = &#34;1543-8&#34; or @code = &#34;1545-3&#34; or @code = &#34;1547-9&#34; or @code = &#34;1549-5&#34; or @code = &#34;1551-1&#34; or @code = &#34;1552-9&#34; or @code = &#34;1553-7&#34; or @code = &#34;1554-5&#34; or @code = &#34;1556-0&#34; or @code = &#34;1558-6&#34; or @code = &#34;1560-2&#34; or @code = &#34;1562-8&#34; or @code = &#34;1564-4&#34; or @code = &#34;1566-9&#34; or @code = &#34;1567-7&#34; or @code = &#34;1568-5&#34; or @code = &#34;1569-3&#34; or @code = &#34;1570-1&#34; or @code = &#34;1571-9&#34; or @code = &#34;1573-5&#34; or @code = &#34;1574-3&#34; or @code = &#34;1576-8&#34; or @code = &#34;1578-4&#34; or @code = &#34;1579-2&#34; or @code = &#34;1580-0&#34; or @code = &#34;1582-6&#34; or @code = &#34;1584-2&#34; or @code = &#34;1586-7&#34; or @code = &#34;1587-5&#34; or @code = &#34;1588-3&#34; or @code = &#34;1589-1&#34; or @code = &#34;1590-9&#34; or @code = &#34;1591-7&#34; or @code = &#34;1592-5&#34; or @code = &#34;1593-3&#34; or @code = &#34;1594-1&#34; or @code = &#34;1595-8&#34; or @code = &#34;1596-6&#34; or @code = &#34;1597-4&#34; or @code = &#34;1598-2&#34; or @code = &#34;1599-0&#34; or @code = &#34;1600-6&#34; or @code = &#34;1602-2&#34; or @code = &#34;1603-0&#34; or @code = &#34;1604-8&#34; or @code = &#34;1605-5&#34; or @code = &#34;1607-1&#34; or @code = &#34;1609-7&#34; or @code = &#34;1610-5&#34; or @code = &#34;1611-3&#34; or @code = &#34;1612-1&#34; or @code = &#34;1613-9&#34; or @code = &#34;1614-7&#34; or @code = &#34;1615-4&#34; or @code = &#34;1616-2&#34; or @code = &#34;1617-0&#34; or @code = &#34;1618-8&#34; or @code = &#34;1619-6&#34; or @code = &#34;1620-4&#34; or @code = &#34;1621-2&#34; or @code = &#34;1622-0&#34; or @code = &#34;1623-8&#34; or @code = &#34;1624-6&#34; or @code = &#34;1625-3&#34; or @code = &#34;1626-1&#34; or @code = &#34;1627-9&#34; or @code = &#34;1628-7&#34; or @code = &#34;1629-5&#34; or @code = &#34;1630-3&#34; or @code = &#34;1631-1&#34; or @code = &#34;1632-9&#34; or @code = &#34;1633-7&#34; or @code = &#34;1634-5&#34; or @code = &#34;1635-2&#34; or @code = &#34;1636-0&#34; or @code = &#34;1637-8&#34; or @code = &#34;1638-6&#34; or @code = &#34;1639-4&#34; or @code = &#34;1640-2&#34; or @code = &#34;1641-0&#34; or @code = &#34;1643-6&#34; or @code = &#34;1645-1&#34; or @code = &#34;1647-7&#34; or @code = &#34;1649-3&#34; or @code = &#34;1651-9&#34; or @code = &#34;1653-5&#34; or @code = &#34;1654-3&#34; or @code = &#34;1655-0&#34; or @code = &#34;1656-8&#34; or @code = &#34;1657-6&#34; or @code = &#34;1659-2&#34; or @code = &#34;1661-8&#34; or @code = &#34;1663-4&#34; or @code = &#34;1665-9&#34; or @code = &#34;1667-5&#34; or @code = &#34;1668-3&#34; or @code = &#34;1670-9&#34; or @code = &#34;1671-7&#34; or @code = &#34;1672-5&#34; or @code = &#34;1673-3&#34; or @code = &#34;1675-8&#34; or @code = &#34;1677-4&#34; or @code = &#34;1679-0&#34; or @code = &#34;1680-8&#34; or @code = &#34;1681-6&#34; or @code = &#34;1683-2&#34; or @code = &#34;1685-7&#34; or @code = &#34;1687-3&#34; or @code = &#34;1688-1&#34; or @code = &#34;1689-9&#34; or @code = &#34;1690-7&#34; or @code = &#34;1692-3&#34; or @code = &#34;1694-9&#34; or @code = &#34;1696-4&#34; or @code = &#34;1697-2&#34; or @code = &#34;1698-0&#34; or @code = &#34;1700-4&#34; or @code = &#34;1702-0&#34; or @code = &#34;1704-6&#34; or @code = &#34;1705-3&#34; or @code = &#34;1707-9&#34; or @code = &#34;1709-5&#34; or @code = &#34;1711-1&#34; or @code = &#34;1712-9&#34; or @code = &#34;1713-7&#34; or @code = &#34;1715-2&#34; or @code = &#34;1717-8&#34; or @code = &#34;1718-6&#34; or @code = &#34;1719-4&#34; or @code = &#34;1720-2&#34; or @code = &#34;1722-8&#34; or @code = &#34;1724-4&#34; or @code = &#34;1725-1&#34; or @code = &#34;1726-9&#34; or @code = &#34;1727-7&#34; or @code = &#34;1728-5&#34; or @code = &#34;1729-3&#34; or @code = &#34;1730-1&#34; or @code = &#34;1731-9&#34; or @code = &#34;1732-7&#34; or @code = &#34;1733-5&#34; or @code = &#34;1735-0&#34; or @code = &#34;1737-6&#34; or @code = &#34;1739-2&#34; or @code = &#34;1740-0&#34; or @code = &#34;1741-8&#34; or @code = &#34;1742-6&#34; or @code = &#34;1743-4&#34; or @code = &#34;1744-2&#34; or @code = &#34;1745-9&#34; or @code = &#34;1746-7&#34; or @code = &#34;1747-5&#34; or @code = &#34;1748-3&#34; or @code = &#34;1749-1&#34; or @code = &#34;1750-9&#34; or @code = &#34;1751-7&#34; or @code = &#34;1752-5&#34; or @code = &#34;1753-3&#34; or @code = &#34;1754-1&#34; or @code = &#34;1755-8&#34; or @code = &#34;1756-6&#34; or @code = &#34;1757-4&#34; or @code = &#34;1758-2&#34; or @code = &#34;1759-0&#34; or @code = &#34;1760-8&#34; or @code = &#34;1761-6&#34; or @code = &#34;1762-4&#34; or @code = &#34;1763-2&#34; or @code = &#34;1764-0&#34; or @code = &#34;1765-7&#34; or @code = &#34;1766-5&#34; or @code = &#34;1767-3&#34; or @code = &#34;1768-1&#34; or @code = &#34;1769-9&#34; or @code = &#34;1770-7&#34; or @code = &#34;1771-5&#34; or @code = &#34;1772-3&#34; or @code = &#34;1773-1&#34; or @code = &#34;1774-9&#34; or @code = &#34;1775-6&#34; or @code = &#34;1776-4&#34; or @code = &#34;1777-2&#34; or @code = &#34;1778-0&#34; or @code = &#34;1779-8&#34; or @code = &#34;1780-6&#34; or @code = &#34;1781-4&#34; or @code = &#34;1782-2&#34; or @code = &#34;1783-0&#34; or @code = &#34;1784-8&#34; or @code = &#34;1785-5&#34; or @code = &#34;1786-3&#34; or @code = &#34;1787-1&#34; or @code = &#34;1788-9&#34; or @code = &#34;1789-7&#34; or @code = &#34;1790-5&#34; or @code = &#34;1791-3&#34; or @code = &#34;1792-1&#34; or @code = &#34;1793-9&#34; or @code = &#34;1794-7&#34; or @code = &#34;1795-4&#34; or @code = &#34;1796-2&#34; or @code = &#34;1797-0&#34; or @code = &#34;1798-8&#34; or @code = &#34;1799-6&#34; or @code = &#34;1800-2&#34; or @code = &#34;1801-0&#34; or @code = &#34;1802-8&#34; or @code = &#34;1803-6&#34; or @code = &#34;1804-4&#34; or @code = &#34;1805-1&#34; or @code = &#34;1806-9&#34; or @code = &#34;1807-7&#34; or @code = &#34;1808-5&#34; or @code = &#34;1809-3&#34; or @code = &#34;1811-9&#34; or @code = &#34;1813-5&#34; or @code = &#34;1814-3&#34; or @code = &#34;1815-0&#34; or @code = &#34;1816-8&#34; or @code = &#34;1817-6&#34; or @code = &#34;1818-4&#34; or @code = &#34;1819-2&#34; or @code = &#34;1820-0&#34; or @code = &#34;1821-8&#34; or @code = &#34;1822-6&#34; or @code = &#34;1823-4&#34; or @code = &#34;1824-2&#34; or @code = &#34;1825-9&#34; or @code = &#34;1826-7&#34; or @code = &#34;1827-5&#34; or @code = &#34;1828-3&#34; or @code = &#34;1829-1&#34; or @code = &#34;1830-9&#34; or @code = &#34;1831-7&#34; or @code = &#34;1832-5&#34; or @code = &#34;1833-3&#34; or @code = &#34;1834-1&#34; or @code = &#34;1835-8&#34; or @code = &#34;1837-4&#34; or @code = &#34;1838-2&#34; or @code = &#34;1840-8&#34; or @code = &#34;1842-4&#34; or @code = &#34;1844-0&#34; or @code = &#34;1845-7&#34; or @code = &#34;1846-5&#34; or @code = &#34;1847-3&#34; or @code = &#34;1848-1&#34; or @code = &#34;1849-9&#34; or @code = &#34;1850-7&#34; or @code = &#34;1851-5&#34; or @code = &#34;1852-3&#34; or @code = &#34;1853-1&#34; or @code = &#34;1854-9&#34; or @code = &#34;1855-6&#34; or @code = &#34;1856-4&#34; or @code = &#34;1857-2&#34; or @code = &#34;1858-0&#34; or @code = &#34;1859-8&#34; or @code = &#34;1860-6&#34; or @code = &#34;1861-4&#34; or @code = &#34;1862-2&#34; or @code = &#34;1863-0&#34; or @code = &#34;1864-8&#34; or @code = &#34;1865-5&#34; or @code = &#34;1866-3&#34; or @code = &#34;1867-1&#34; or @code = &#34;1868-9&#34; or @code = &#34;1869-7&#34; or @code = &#34;1870-5&#34; or @code = &#34;1871-3&#34; or @code = &#34;1872-1&#34; or @code = &#34;1873-9&#34; or @code = &#34;1874-7&#34; or @code = &#34;1875-4&#34; or @code = &#34;1876-2&#34; or @code = &#34;1877-0&#34; or @code = &#34;1878-8&#34; or @code = &#34;1879-6&#34; or @code = &#34;1880-4&#34; or @code = &#34;1881-2&#34; or @code = &#34;1882-0&#34; or @code = &#34;1883-8&#34; or @code = &#34;1884-6&#34; or @code = &#34;1885-3&#34; or @code = &#34;1886-1&#34; or @code = &#34;1887-9&#34; or @code = &#34;1888-7&#34; or @code = &#34;1889-5&#34; or @code = &#34;1891-1&#34; or @code = &#34;1892-9&#34; or @code = &#34;1893-7&#34; or @code = &#34;1894-5&#34; or @code = &#34;1896-0&#34; or @code = &#34;1897-8&#34; or @code = &#34;1898-6&#34; or @code = &#34;1899-4&#34; or @code = &#34;1900-0&#34; or @code = &#34;1901-8&#34; or @code = &#34;1902-6&#34; or @code = &#34;1903-4&#34; or @code = &#34;1904-2&#34; or @code = &#34;1905-9&#34; or @code = &#34;1906-7&#34; or @code = &#34;1907-5&#34; or @code = &#34;1908-3&#34; or @code = &#34;1909-1&#34; or @code = &#34;1910-9&#34; or @code = &#34;1911-7&#34; or @code = &#34;1912-5&#34; or @code = &#34;1913-3&#34; or @code = &#34;1914-1&#34; or @code = &#34;1915-8&#34; or @code = &#34;1916-6&#34; or @code = &#34;1917-4&#34; or @code = &#34;1918-2&#34; or @code = &#34;1919-0&#34; or @code = &#34;1920-8&#34; or @code = &#34;1921-6&#34; or @code = &#34;1922-4&#34; or @code = &#34;1923-2&#34; or @code = &#34;1924-0&#34; or @code = &#34;1925-7&#34; or @code = &#34;1926-5&#34; or @code = &#34;1927-3&#34; or @code = &#34;1928-1&#34; or @code = &#34;1929-9&#34; or @code = &#34;1930-7&#34; or @code = &#34;1931-5&#34; or @code = &#34;1932-3&#34; or @code = &#34;1933-1&#34; or @code = &#34;1934-9&#34; or @code = &#34;1935-6&#34; or @code = &#34;1936-4&#34; or @code = &#34;1937-2&#34; or @code = &#34;1938-0&#34; or @code = &#34;1939-8&#34; or @code = &#34;1940-6&#34; or @code = &#34;1941-4&#34; or @code = &#34;1942-2&#34; or @code = &#34;1943-0&#34; or @code = &#34;1944-8&#34; or @code = &#34;1945-5&#34; or @code = &#34;1946-3&#34; or @code = &#34;1947-1&#34; or @code = &#34;1948-9&#34; or @code = &#34;1949-7&#34; or @code = &#34;1950-5&#34; or @code = &#34;1951-3&#34; or @code = &#34;1952-1&#34; or @code = &#34;1953-9&#34; or @code = &#34;1954-7&#34; or @code = &#34;1955-4&#34; or @code = &#34;1956-2&#34; or @code = &#34;1957-0&#34; or @code = &#34;1958-8&#34; or @code = &#34;1959-6&#34; or @code = &#34;1960-4&#34; or @code = &#34;1961-2&#34; or @code = &#34;1962-0&#34; or @code = &#34;1963-8&#34; or @code = &#34;1964-6&#34; or @code = &#34;1966-1&#34; or @code = &#34;1968-7&#34; or @code = &#34;1969-5&#34; or @code = &#34;1970-3&#34; or @code = &#34;1972-9&#34; or @code = &#34;1973-7&#34; or @code = &#34;1974-5&#34; or @code = &#34;1975-2&#34; or @code = &#34;1976-0&#34; or @code = &#34;1977-8&#34; or @code = &#34;1978-6&#34; or @code = &#34;1979-4&#34; or @code = &#34;1980-2&#34; or @code = &#34;1981-0&#34; or @code = &#34;1982-8&#34; or @code = &#34;1984-4&#34; or @code = &#34;1985-1&#34; or @code = &#34;1986-9&#34; or @code = &#34;1987-7&#34; or @code = &#34;1988-5&#34; or @code = &#34;1990-1&#34; or @code = &#34;1992-7&#34; or @code = &#34;1993-5&#34; or @code = &#34;1994-3&#34; or @code = &#34;1995-0&#34; or @code = &#34;1996-8&#34; or @code = &#34;1997-6&#34; or @code = &#34;1998-4&#34; or @code = &#34;1999-2&#34; or @code = &#34;2000-8&#34; or @code = &#34;2002-4&#34; or @code = &#34;2004-0&#34; or @code = &#34;2006-5&#34; or @code = &#34;2007-3&#34; or @code = &#34;2008-1&#34; or @code = &#34;2009-9&#34; or @code = &#34;2010-7&#34; or @code = &#34;2011-5&#34; or @code = &#34;2012-3&#34; or @code = &#34;2013-1&#34; or @code = &#34;2014-9&#34; or @code = &#34;2015-6&#34; or @code = &#34;2016-4&#34; or @code = &#34;2017-2&#34; or @code = &#34;2018-0&#34; or @code = &#34;2019-8&#34; or @code = &#34;2020-6&#34; or @code = &#34;2021-4&#34; or @code = &#34;2022-2&#34; or @code = &#34;2023-0&#34; or @code = &#34;2024-8&#34; or @code = &#34;2025-5&#34; or @code = &#34;2026-3&#34; or @code = &#34;2028-9&#34; or @code = &#34;2029-7&#34; or @code = &#34;2030-5&#34; or @code = &#34;2031-3&#34; or @code = &#34;2032-1&#34; or @code = &#34;2033-9&#34; or @code = &#34;2034-7&#34; or @code = &#34;2035-4&#34; or @code = &#34;2036-2&#34; or @code = &#34;2037-0&#34; or @code = &#34;2038-8&#34; or @code = &#34;2039-6&#34; or @code = &#34;2040-4&#34; or @code = &#34;2041-2&#34; or @code = &#34;2042-0&#34; or @code = &#34;2043-8&#34; or @code = &#34;2044-6&#34; or @code = &#34;2045-3&#34; or @code = &#34;2046-1&#34; or @code = &#34;2047-9&#34; or @code = &#34;2048-7&#34; or @code = &#34;2049-5&#34; or @code = &#34;2050-3&#34; or @code = &#34;2051-1&#34; or @code = &#34;2052-9&#34; or @code = &#34;2054-5&#34; or @code = &#34;2056-0&#34; or @code = &#34;2058-6&#34; or @code = &#34;2060-2&#34; or @code = &#34;2061-0&#34; or @code = &#34;2062-8&#34; or @code = &#34;2063-6&#34; or @code = &#34;2064-4&#34; or @code = &#34;2065-1&#34; or @code = &#34;2066-9&#34; or @code = &#34;2067-7&#34; or @code = &#34;2068-5&#34; or @code = &#34;2069-3&#34; or @code = &#34;2070-1&#34; or @code = &#34;2071-9&#34; or @code = &#34;2072-7&#34; or @code = &#34;2073-5&#34; or @code = &#34;2074-3&#34; or @code = &#34;2075-0&#34; or @code = &#34;2076-8&#34; or @code = &#34;2078-4&#34; or @code = &#34;2079-2&#34; or @code = &#34;2080-0&#34; or @code = &#34;2081-8&#34; or @code = &#34;2082-6&#34; or @code = &#34;2083-4&#34; or @code = &#34;2085-9&#34; or @code = &#34;2086-7&#34; or @code = &#34;2087-5&#34; or @code = &#34;2088-3&#34; or @code = &#34;2089-1&#34; or @code = &#34;2090-9&#34; or @code = &#34;2091-7&#34; or @code = &#34;2092-5&#34; or @code = &#34;2093-3&#34; or @code = &#34;2094-1&#34; or @code = &#34;2095-8&#34; or @code = &#34;2096-6&#34; or @code = &#34;2097-4&#34; or @code = &#34;2098-2&#34; or @code = &#34;2100-6&#34; or @code = &#34;2101-4&#34; or @code = &#34;2102-2&#34; or @code = &#34;2103-0&#34; or @code = &#34;2104-8&#34; or @code = &#34;2106-3&#34; or @code = &#34;2108-9&#34; or @code = &#34;2109-7&#34; or @code = &#34;2110-5&#34; or @code = &#34;2111-3&#34; or @code = &#34;2112-1&#34; or @code = &#34;2113-9&#34; or @code = &#34;2114-7&#34; or @code = &#34;2115-4&#34; or @code = &#34;2116-2&#34; or @code = &#34;2118-8&#34; or @code = &#34;2119-6&#34; or @code = &#34;2120-4&#34; or @code = &#34;2121-2&#34; or @code = &#34;2122-0&#34; or @code = &#34;2123-8&#34; or @code = &#34;2124-6&#34; or @code = &#34;2125-3&#34; or @code = &#34;2126-1&#34; or @code = &#34;2127-9&#34; or @code = &#34;2129-5&#34; or @code = &#34;2131-1&#34; or @code = &#34;2500-7&#34;])"/>
         <xsl:otherwise>
            <xsl:message>
     Error: CONF-QRDA1-28 The patient's race 'code' attribute value SHALL be valid according to Appendix_O-Race in the posted Downloadable Resource table.
      ((cda:recordTarget/cda:patientRole/cda:patient/cda:raceCode[@code = "1002-5" or @code = "1004-1" or @code = "1006-6" or @code = "1008-2" or @code = "1010-8" or @code = "1011-6" or @code = "1012-4" or @code = "1013-2" or @code = "1014-0" or @code = "1015-7" or @code = "1016-5" or @code = "1017-3" or @code = "1018-1" or @code = "1019-9" or @code = "1021-5" or @code = "1022-3" or @code = "1023-1" or @code = "1024-9" or @code = "1026-4" or @code = "1028-0" or @code = "1030-6" or @code = "1031-4" or @code = "1033-0" or @code = "1035-5" or @code = "1037-1" or @code = "1039-7" or @code = "1041-3" or @code = "1042-1" or @code = "1044-7" or @code = "1045-4" or @code = "1046-2" or @code = "1047-0" or @code = "1048-8" or @code = "1049-6" or @code = "1050-4" or @code = "1051-2" or @code = "1053-8" or @code = "1054-6" or @code = "1055-3" or @code = "1056-1" or @code = "1057-9" or @code = "1058-7" or @code = "1059-5" or @code = "1060-3" or @code = "1061-1" or @code = "1062-9" or @code = "1063-7" or @code = "1064-5" or @code = "1065-2" or @code = "1066-0" or @code = "1068-6" or @code = "1069-4" or @code = "1070-2" or @code = "1071-0" or @code = "1072-8" or @code = "1073-6" or @code = "1074-4" or @code = "1076-9" or @code = "1078-5" or @code = "1080-1" or @code = "1082-7" or @code = "1083-5" or @code = "1084-3" or @code = "1086-8" or @code = "1088-4" or @code = "1089-2" or @code = "1090-0" or @code = "1091-8" or @code = "1092-6" or @code = "1093-4" or @code = "1094-2" or @code = "1095-9" or @code = "1096-7" or @code = "1097-5" or @code = "1098-3" or @code = "1100-7" or @code = "1102-3" or @code = "1103-1" or @code = "1104-9" or @code = "1106-4" or @code = "1108-0" or @code = "1109-8" or @code = "1110-6" or @code = "1112-2" or @code = "1114-8" or @code = "1115-5" or @code = "1116-3" or @code = "1117-1" or @code = "1118-9" or @code = "1119-7" or @code = "1120-5" or @code = "1121-3" or @code = "1123-9" or @code = "1124-7" or @code = "1125-4" or @code = "1126-2" or @code = "1127-0" or @code = "1128-8" or @code = "1129-6" or @code = "1130-4" or @code = "1131-2" or @code = "1132-0" or @code = "1133-8" or @code = "1134-6" or @code = "1135-3" or @code = "1136-1" or @code = "1137-9" or @code = "1138-7" or @code = "1139-5" or @code = "1140-3" or @code = "1141-1" or @code = "1142-9" or @code = "1143-7" or @code = "1144-5" or @code = "1145-2" or @code = "1146-0" or @code = "1147-8" or @code = "1148-6" or @code = "1150-2" or @code = "1151-0" or @code = "1153-6" or @code = "1155-1" or @code = "1156-9" or @code = "1157-7" or @code = "1158-5" or @code = "1159-3" or @code = "1160-1" or @code = "1162-7" or @code = "1163-5" or @code = "1165-0" or @code = "1167-6" or @code = "1169-2" or @code = "1171-8" or @code = "1173-4" or @code = "1175-9" or @code = "1176-7" or @code = "1178-3" or @code = "1180-9" or @code = "1182-5" or @code = "1184-1" or @code = "1186-6" or @code = "1187-4" or @code = "1189-0" or @code = "1191-6" or @code = "1193-2" or @code = "1194-0" or @code = "1195-7" or @code = "1196-5" or @code = "1197-3" or @code = "1198-1" or @code = "1199-9" or @code = "1200-5" or @code = "1201-3" or @code = "1202-1" or @code = "1203-9" or @code = "1204-7" or @code = "1205-4" or @code = "1207-0" or @code = "1209-6" or @code = "1211-2" or @code = "1212-0" or @code = "1214-6" or @code = "1215-3" or @code = "1216-1" or @code = "1217-9" or @code = "1218-7" or @code = "1219-5" or @code = "1220-3" or @code = "1222-9" or @code = "1223-7" or @code = "1224-5" or @code = "1225-2" or @code = "1226-0" or @code = "1227-8" or @code = "1228-6" or @code = "1229-4" or @code = "1230-2" or @code = "1231-0" or @code = "1233-6" or @code = "1234-4" or @code = "1235-1" or @code = "1236-9" or @code = "1237-7" or @code = "1238-5" or @code = "1239-3" or @code = "1240-1" or @code = "1241-9" or @code = "1242-7" or @code = "1243-5" or @code = "1244-3" or @code = "1245-0" or @code = "1246-8" or @code = "1247-6" or @code = "1248-4" or @code = "1250-0" or @code = "1252-6" or @code = "1254-2" or @code = "1256-7" or @code = "1258-3" or @code = "1260-9" or @code = "1262-5" or @code = "1264-1" or @code = "1265-8" or @code = "1267-4" or @code = "1269-0" or @code = "1271-6" or @code = "1272-4" or @code = "1273-2" or @code = "1275-7" or @code = "1277-3" or @code = "1279-9" or @code = "1281-5" or @code = "1282-3" or @code = "1283-1" or @code = "1285-6" or @code = "1286-4" or @code = "1287-2" or @code = "1288-0" or @code = "1289-8" or @code = "1290-6" or @code = "1291-4" or @code = "1292-2" or @code = "1293-0" or @code = "1294-8" or @code = "1295-5" or @code = "1297-1" or @code = "1299-7" or @code = "1301-1" or @code = "1303-7" or @code = "1305-2" or @code = "1306-0" or @code = "1307-8" or @code = "1309-4" or @code = "1310-2" or @code = "1312-8" or @code = "1313-6" or @code = "1314-4" or @code = "1315-1" or @code = "1317-7" or @code = "1319-3" or @code = "1321-9" or @code = "1323-5" or @code = "1325-0" or @code = "1326-8" or @code = "1327-6" or @code = "1328-4" or @code = "1329-2" or @code = "1331-8" or @code = "1332-6" or @code = "1333-4" or @code = "1334-2" or @code = "1335-9" or @code = "1336-7" or @code = "1337-5" or @code = "1338-3" or @code = "1340-9" or @code = "1342-5" or @code = "1344-1" or @code = "1345-8" or @code = "1346-6" or @code = "1348-2" or @code = "1350-8" or @code = "1352-4" or @code = "1354-0" or @code = "1356-5" or @code = "1358-1" or @code = "1359-9" or @code = "1360-7" or @code = "1361-5" or @code = "1363-1" or @code = "1365-6" or @code = "1366-4" or @code = "1368-0" or @code = "1370-6" or @code = "1372-2" or @code = "1374-8" or @code = "1376-3" or @code = "1378-9" or @code = "1380-5" or @code = "1382-1" or @code = "1383-9" or @code = "1384-7" or @code = "1385-4" or @code = "1387-0" or @code = "1389-6" or @code = "1391-2" or @code = "1392-0" or @code = "1393-8" or @code = "1394-6" or @code = "1395-3" or @code = "1396-1" or @code = "1397-9" or @code = "1398-7" or @code = "1399-5" or @code = "1400-1" or @code = "1401-9" or @code = "1403-5" or @code = "1405-0" or @code = "1407-6" or @code = "1409-2" or @code = "1411-8" or @code = "1412-6" or @code = "1413-4" or @code = "1414-2" or @code = "1416-7" or @code = "1417-5" or @code = "1418-3" or @code = "1419-1" or @code = "1420-9" or @code = "1421-7" or @code = "1422-5" or @code = "1423-3" or @code = "1424-1" or @code = "1425-8" or @code = "1426-6" or @code = "1427-4" or @code = "1428-2" or @code = "1429-0" or @code = "1430-8" or @code = "1431-6" or @code = "1432-4" or @code = "1433-2" or @code = "1434-0" or @code = "1435-7" or @code = "1436-5" or @code = "1437-3" or @code = "1439-9" or @code = "1441-5" or @code = "1442-3" or @code = "1443-1" or @code = "1445-6" or @code = "1446-4" or @code = "1448-0" or @code = "1450-6" or @code = "1451-4" or @code = "1453-0" or @code = "1454-8" or @code = "1456-3" or @code = "1457-1" or @code = "1458-9" or @code = "1460-5" or @code = "1462-1" or @code = "1464-7" or @code = "1465-4" or @code = "1466-2" or @code = "1467-0" or @code = "1468-8" or @code = "1469-6" or @code = "1470-4" or @code = "1471-2" or @code = "1472-0" or @code = "1474-6" or @code = "1475-3" or @code = "1476-1" or @code = "1478-7" or @code = "1479-5" or @code = "1480-3" or @code = "1481-1" or @code = "1482-9" or @code = "1483-7" or @code = "1484-5" or @code = "1485-2" or @code = "1487-8" or @code = "1489-4" or @code = "1490-2" or @code = "1491-0" or @code = "1492-8" or @code = "1493-6" or @code = "1494-4" or @code = "1495-1" or @code = "1496-9" or @code = "1497-7" or @code = "1498-5" or @code = "1499-3" or @code = "1500-8" or @code = "1501-6" or @code = "1502-4" or @code = "1503-2" or @code = "1504-0" or @code = "1505-7" or @code = "1506-5" or @code = "1507-3" or @code = "1508-1" or @code = "1509-9" or @code = "1510-7" or @code = "1511-5" or @code = "1512-3" or @code = "1513-1" or @code = "1514-9" or @code = "1515-6" or @code = "1516-4" or @code = "1518-0" or @code = "1519-8" or @code = "1520-6" or @code = "1521-4" or @code = "1522-2" or @code = "1523-0" or @code = "1524-8" or @code = "1525-5" or @code = "1526-3" or @code = "1527-1" or @code = "1528-9" or @code = "1529-7" or @code = "1530-5" or @code = "1531-3" or @code = "1532-1" or @code = "1533-9" or @code = "1534-7" or @code = "1535-4" or @code = "1536-2" or @code = "1537-0" or @code = "1538-8" or @code = "1539-6" or @code = "1541-2" or @code = "1543-8" or @code = "1545-3" or @code = "1547-9" or @code = "1549-5" or @code = "1551-1" or @code = "1552-9" or @code = "1553-7" or @code = "1554-5" or @code = "1556-0" or @code = "1558-6" or @code = "1560-2" or @code = "1562-8" or @code = "1564-4" or @code = "1566-9" or @code = "1567-7" or @code = "1568-5" or @code = "1569-3" or @code = "1570-1" or @code = "1571-9" or @code = "1573-5" or @code = "1574-3" or @code = "1576-8" or @code = "1578-4" or @code = "1579-2" or @code = "1580-0" or @code = "1582-6" or @code = "1584-2" or @code = "1586-7" or @code = "1587-5" or @code = "1588-3" or @code = "1589-1" or @code = "1590-9" or @code = "1591-7" or @code = "1592-5" or @code = "1593-3" or @code = "1594-1" or @code = "1595-8" or @code = "1596-6" or @code = "1597-4" or @code = "1598-2" or @code = "1599-0" or @code = "1600-6" or @code = "1602-2" or @code = "1603-0" or @code = "1604-8" or @code = "1605-5" or @code = "1607-1" or @code = "1609-7" or @code = "1610-5" or @code = "1611-3" or @code = "1612-1" or @code = "1613-9" or @code = "1614-7" or @code = "1615-4" or @code = "1616-2" or @code = "1617-0" or @code = "1618-8" or @code = "1619-6" or @code = "1620-4" or @code = "1621-2" or @code = "1622-0" or @code = "1623-8" or @code = "1624-6" or @code = "1625-3" or @code = "1626-1" or @code = "1627-9" or @code = "1628-7" or @code = "1629-5" or @code = "1630-3" or @code = "1631-1" or @code = "1632-9" or @code = "1633-7" or @code = "1634-5" or @code = "1635-2" or @code = "1636-0" or @code = "1637-8" or @code = "1638-6" or @code = "1639-4" or @code = "1640-2" or @code = "1641-0" or @code = "1643-6" or @code = "1645-1" or @code = "1647-7" or @code = "1649-3" or @code = "1651-9" or @code = "1653-5" or @code = "1654-3" or @code = "1655-0" or @code = "1656-8" or @code = "1657-6" or @code = "1659-2" or @code = "1661-8" or @code = "1663-4" or @code = "1665-9" or @code = "1667-5" or @code = "1668-3" or @code = "1670-9" or @code = "1671-7" or @code = "1672-5" or @code = "1673-3" or @code = "1675-8" or @code = "1677-4" or @code = "1679-0" or @code = "1680-8" or @code = "1681-6" or @code = "1683-2" or @code = "1685-7" or @code = "1687-3" or @code = "1688-1" or @code = "1689-9" or @code = "1690-7" or @code = "1692-3" or @code = "1694-9" or @code = "1696-4" or @code = "1697-2" or @code = "1698-0" or @code = "1700-4" or @code = "1702-0" or @code = "1704-6" or @code = "1705-3" or @code = "1707-9" or @code = "1709-5" or @code = "1711-1" or @code = "1712-9" or @code = "1713-7" or @code = "1715-2" or @code = "1717-8" or @code = "1718-6" or @code = "1719-4" or @code = "1720-2" or @code = "1722-8" or @code = "1724-4" or @code = "1725-1" or @code = "1726-9" or @code = "1727-7" or @code = "1728-5" or @code = "1729-3" or @code = "1730-1" or @code = "1731-9" or @code = "1732-7" or @code = "1733-5" or @code = "1735-0" or @code = "1737-6" or @code = "1739-2" or @code = "1740-0" or @code = "1741-8" or @code = "1742-6" or @code = "1743-4" or @code = "1744-2" or @code = "1745-9" or @code = "1746-7" or @code = "1747-5" or @code = "1748-3" or @code = "1749-1" or @code = "1750-9" or @code = "1751-7" or @code = "1752-5" or @code = "1753-3" or @code = "1754-1" or @code = "1755-8" or @code = "1756-6" or @code = "1757-4" or @code = "1758-2" or @code = "1759-0" or @code = "1760-8" or @code = "1761-6" or @code = "1762-4" or @code = "1763-2" or @code = "1764-0" or @code = "1765-7" or @code = "1766-5" or @code = "1767-3" or @code = "1768-1" or @code = "1769-9" or @code = "1770-7" or @code = "1771-5" or @code = "1772-3" or @code = "1773-1" or @code = "1774-9" or @code = "1775-6" or @code = "1776-4" or @code = "1777-2" or @code = "1778-0" or @code = "1779-8" or @code = "1780-6" or @code = "1781-4" or @code = "1782-2" or @code = "1783-0" or @code = "1784-8" or @code = "1785-5" or @code = "1786-3" or @code = "1787-1" or @code = "1788-9" or @code = "1789-7" or @code = "1790-5" or @code = "1791-3" or @code = "1792-1" or @code = "1793-9" or @code = "1794-7" or @code = "1795-4" or @code = "1796-2" or @code = "1797-0" or @code = "1798-8" or @code = "1799-6" or @code = "1800-2" or @code = "1801-0" or @code = "1802-8" or @code = "1803-6" or @code = "1804-4" or @code = "1805-1" or @code = "1806-9" or @code = "1807-7" or @code = "1808-5" or @code = "1809-3" or @code = "1811-9" or @code = "1813-5" or @code = "1814-3" or @code = "1815-0" or @code = "1816-8" or @code = "1817-6" or @code = "1818-4" or @code = "1819-2" or @code = "1820-0" or @code = "1821-8" or @code = "1822-6" or @code = "1823-4" or @code = "1824-2" or @code = "1825-9" or @code = "1826-7" or @code = "1827-5" or @code = "1828-3" or @code = "1829-1" or @code = "1830-9" or @code = "1831-7" or @code = "1832-5" or @code = "1833-3" or @code = "1834-1" or @code = "1835-8" or @code = "1837-4" or @code = "1838-2" or @code = "1840-8" or @code = "1842-4" or @code = "1844-0" or @code = "1845-7" or @code = "1846-5" or @code = "1847-3" or @code = "1848-1" or @code = "1849-9" or @code = "1850-7" or @code = "1851-5" or @code = "1852-3" or @code = "1853-1" or @code = "1854-9" or @code = "1855-6" or @code = "1856-4" or @code = "1857-2" or @code = "1858-0" or @code = "1859-8" or @code = "1860-6" or @code = "1861-4" or @code = "1862-2" or @code = "1863-0" or @code = "1864-8" or @code = "1865-5" or @code = "1866-3" or @code = "1867-1" or @code = "1868-9" or @code = "1869-7" or @code = "1870-5" or @code = "1871-3" or @code = "1872-1" or @code = "1873-9" or @code = "1874-7" or @code = "1875-4" or @code = "1876-2" or @code = "1877-0" or @code = "1878-8" or @code = "1879-6" or @code = "1880-4" or @code = "1881-2" or @code = "1882-0" or @code = "1883-8" or @code = "1884-6" or @code = "1885-3" or @code = "1886-1" or @code = "1887-9" or @code = "1888-7" or @code = "1889-5" or @code = "1891-1" or @code = "1892-9" or @code = "1893-7" or @code = "1894-5" or @code = "1896-0" or @code = "1897-8" or @code = "1898-6" or @code = "1899-4" or @code = "1900-0" or @code = "1901-8" or @code = "1902-6" or @code = "1903-4" or @code = "1904-2" or @code = "1905-9" or @code = "1906-7" or @code = "1907-5" or @code = "1908-3" or @code = "1909-1" or @code = "1910-9" or @code = "1911-7" or @code = "1912-5" or @code = "1913-3" or @code = "1914-1" or @code = "1915-8" or @code = "1916-6" or @code = "1917-4" or @code = "1918-2" or @code = "1919-0" or @code = "1920-8" or @code = "1921-6" or @code = "1922-4" or @code = "1923-2" or @code = "1924-0" or @code = "1925-7" or @code = "1926-5" or @code = "1927-3" or @code = "1928-1" or @code = "1929-9" or @code = "1930-7" or @code = "1931-5" or @code = "1932-3" or @code = "1933-1" or @code = "1934-9" or @code = "1935-6" or @code = "1936-4" or @code = "1937-2" or @code = "1938-0" or @code = "1939-8" or @code = "1940-6" or @code = "1941-4" or @code = "1942-2" or @code = "1943-0" or @code = "1944-8" or @code = "1945-5" or @code = "1946-3" or @code = "1947-1" or @code = "1948-9" or @code = "1949-7" or @code = "1950-5" or @code = "1951-3" or @code = "1952-1" or @code = "1953-9" or @code = "1954-7" or @code = "1955-4" or @code = "1956-2" or @code = "1957-0" or @code = "1958-8" or @code = "1959-6" or @code = "1960-4" or @code = "1961-2" or @code = "1962-0" or @code = "1963-8" or @code = "1964-6" or @code = "1966-1" or @code = "1968-7" or @code = "1969-5" or @code = "1970-3" or @code = "1972-9" or @code = "1973-7" or @code = "1974-5" or @code = "1975-2" or @code = "1976-0" or @code = "1977-8" or @code = "1978-6" or @code = "1979-4" or @code = "1980-2" or @code = "1981-0" or @code = "1982-8" or @code = "1984-4" or @code = "1985-1" or @code = "1986-9" or @code = "1987-7" or @code = "1988-5" or @code = "1990-1" or @code = "1992-7" or @code = "1993-5" or @code = "1994-3" or @code = "1995-0" or @code = "1996-8" or @code = "1997-6" or @code = "1998-4" or @code = "1999-2" or @code = "2000-8" or @code = "2002-4" or @code = "2004-0" or @code = "2006-5" or @code = "2007-3" or @code = "2008-1" or @code = "2009-9" or @code = "2010-7" or @code = "2011-5" or @code = "2012-3" or @code = "2013-1" or @code = "2014-9" or @code = "2015-6" or @code = "2016-4" or @code = "2017-2" or @code = "2018-0" or @code = "2019-8" or @code = "2020-6" or @code = "2021-4" or @code = "2022-2" or @code = "2023-0" or @code = "2024-8" or @code = "2025-5" or @code = "2026-3" or @code = "2028-9" or @code = "2029-7" or @code = "2030-5" or @code = "2031-3" or @code = "2032-1" or @code = "2033-9" or @code = "2034-7" or @code = "2035-4" or @code = "2036-2" or @code = "2037-0" or @code = "2038-8" or @code = "2039-6" or @code = "2040-4" or @code = "2041-2" or @code = "2042-0" or @code = "2043-8" or @code = "2044-6" or @code = "2045-3" or @code = "2046-1" or @code = "2047-9" or @code = "2048-7" or @code = "2049-5" or @code = "2050-3" or @code = "2051-1" or @code = "2052-9" or @code = "2054-5" or @code = "2056-0" or @code = "2058-6" or @code = "2060-2" or @code = "2061-0" or @code = "2062-8" or @code = "2063-6" or @code = "2064-4" or @code = "2065-1" or @code = "2066-9" or @code = "2067-7" or @code = "2068-5" or @code = "2069-3" or @code = "2070-1" or @code = "2071-9" or @code = "2072-7" or @code = "2073-5" or @code = "2074-3" or @code = "2075-0" or @code = "2076-8" or @code = "2078-4" or @code = "2079-2" or @code = "2080-0" or @code = "2081-8" or @code = "2082-6" or @code = "2083-4" or @code = "2085-9" or @code = "2086-7" or @code = "2087-5" or @code = "2088-3" or @code = "2089-1" or @code = "2090-9" or @code = "2091-7" or @code = "2092-5" or @code = "2093-3" or @code = "2094-1" or @code = "2095-8" or @code = "2096-6" or @code = "2097-4" or @code = "2098-2" or @code = "2100-6" or @code = "2101-4" or @code = "2102-2" or @code = "2103-0" or @code = "2104-8" or @code = "2106-3" or @code = "2108-9" or @code = "2109-7" or @code = "2110-5" or @code = "2111-3" or @code = "2112-1" or @code = "2113-9" or @code = "2114-7" or @code = "2115-4" or @code = "2116-2" or @code = "2118-8" or @code = "2119-6" or @code = "2120-4" or @code = "2121-2" or @code = "2122-0" or @code = "2123-8" or @code = "2124-6" or @code = "2125-3" or @code = "2126-1" or @code = "2127-9" or @code = "2129-5" or @code = "2131-1" or @code = "2500-7"]))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime)"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-29 The 'birthTime' element SHALL be present.
     ((cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime/@value) &gt;= 8"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-30 The birthTime value attribute value SHALL be at least precise to the day (YYYYMMDD).
     (string-length(cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime/@value) &gt;= 8)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:recordTarget/cda:patientRole/cda:providerOrganization) = 1"/>
         <xsl:otherwise>
            <xsl:message>
     Error: CONF-QRDA1-31  The report SHALL contain exactly one /recordTarget/patientRole/providerOrganization.
      (count(cda:recordTarget/cda:patientRole/cda:providerOrganization) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:id[@root=&#34;2.16.840.1.113883.4.6&#34;])"/>
         <xsl:otherwise>
            <xsl:message>
     Error: CONF-QRDA1-32 The id 'root' attribute value SHALL be '2.16.840.1.113883.4.6'.
      ((cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:id[@root="2.16.840.1.113883.4.6"]))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="npi"
                    select="cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:id/@extension"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="((sum(for $j in (for $i in reverse(string-to-codepoints($npi))[position() mod 2 = 0] return ($i - 48) * 2, for $i in reverse(string-to-codepoints($npi))[position() mod 2 = 1] return ($i - 48)) return ($j mod 10, $j idiv 10)) + 24) mod 10) = 0"/>
         <xsl:otherwise>
            <xsl:message>
  Error: CONF-QRDA1-32 cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:id[@extension that containst the NPI Failed the NPI validation test!!
   (((sum(for $j in (for $i in reverse(string-to-codepoints($npi))[position() mod 2 = 0] return ($i - 48) * 2, for $i in reverse(string-to-codepoints($npi))[position() mod 2 = 1] return ($i - 48)) return ($j mod 10, $j idiv 10)) + 24) mod 10) = 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:name)"/>
         <xsl:otherwise>
            <xsl:message>
  Warning: CONF-QRDA1-33 recordTarget/patientRole/providerOrganization/name element SHOULD be present
   ((cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:name))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr) &gt;= 1"/>
         <xsl:otherwise>
            <xsl:message>
  Error: CONF-QRDA1-34 At least one recordTarget/patientRole/providerOrganization/name element SHALL be present
   (count(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr) &gt;= 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr/cda:streetAddressLine)"/>
         <xsl:otherwise>
            <xsl:message>
  Warning: CONF-QRDA1-35 recordTarget/patientRole/providerOrganization/addr/streetAddressLine) element MAY be present
   ((cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr/cda:streetAddressLine))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr/cda:city)"/>
         <xsl:otherwise>
            <xsl:message>
  Warning: CONF-QRDA1-36 recordTarget/patientRole/providerOrganization/addr/city) element MAY be present
   ((cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr/cda:city))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(&#34;AL AK AZ AR AS CA CO CT DE DC FL GA GU HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC MP ND OH OK OR PA PR RI SC SD TN TX UT VT VI VA WA WV WI WY&#34;,cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr/cda:state)"/>
         <xsl:otherwise>
            <xsl:message>
  Error: CONF-QRDA1-37 recordTarget/patientRole/providerOrganization/addr/state) element SHALL be present and shall be one of the states in the Appendix_V-States Downloadable Resource
   (contains("AL AK AZ AR AS CA CO CT DE DC FL GA GU HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC MP ND OH OK OR PA PR RI SC SD TN TX UT VT VI VA WA WV WI WY",cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr/cda:state))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr/cda:postalCode)"/>
         <xsl:otherwise>
            <xsl:message>
  Warning: CONF-QRDA1-38 recordTarget/patientRole/providerOrganization/addr/postalCode) element MAY be present
   ((cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:addr/cda:postalCode))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:asOrganizationPartOf) = 1"/>
         <xsl:otherwise>
            <xsl:message>
  Error: CONF-QRDA1-39 Report SHALL contain exactly one recordTarget/patientRole/providerOrganization/asOrganizationPartOf element.
   (count(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:asOrganizationPartOf) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:asOrganizationPartOf/cda:wholeOrganization) = 1"/>
         <xsl:otherwise>
            <xsl:message>
  Error: CONF-QRDA1-40 Report SHALL contain exactly one recordTarget/patientRole/providerOrganization/asOrganizationPartOf/wholeOrganization element.
   (count(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:asOrganizationPartOf/cda:wholeOrganization) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:id[@root = &#34;2.16.840.1.113883.4.2&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
    Error:  CONF-QRDA1-41 The id 'root' attribute value SHALL be '2.16.840.1.113883.4.2'.
   (cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:id[@root = "2.16.840.1.113883.4.2"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:id/@extension) = &#34;9&#34;"/>
         <xsl:otherwise>
            <xsl:message>
  Error: CONF-QRDA1-41 The patient's provider's organization's id 'extension' attribute value SHALL be present as the provider's TIN (nine-digit value in XXXXXXXXX format). 
   (string-length(cda:recordTarget/cda:patientRole/cda:providerOrganization/cda:asOrganizationPartOf/cda:wholeOrganization/cda:id/@extension) = "9")</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:author)= 1"/>
         <xsl:otherwise>
            <xsl:message>
  CONF-QRDA1-42 Report SHALL contain exactly one /clinicalDocument/author.
   (count(cda:author)= 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:author/cda:time"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-43 The /clinicalDocument/author/time element shall be present.
   (cda:author/cda:time)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(cda:author/cda:time/@value) &gt;= 8"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA1-44 The effectiveTime value attribute value SHALL be at least precise to the day YYYYMMDD.
   (string-length(cda:author/cda:time/@value) &gt;= 8)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:author/cda:assignedAuthor"/>
         <xsl:otherwise>
            <xsl:message>
     Error: CONF-QRDA1-45 clinicalDocument/author/assignedAuthor element SHALL be present.
   (cda:author/cda:assignedAuthor)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:author/cda:assignedAuthor/cda:id[@root=&#34;2.16.840.1.113883.249.6&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
     Error: CONF-QRDA1-46 clinicalDocument/author/assignedAuthor/id element SHALL be present.  The id @root SHALL be 2.16.840.1.113883.249.6 and the @extension SHALL be the CMS Approved Qualified Software Version.
   (cda:author/cda:assignedAuthor/cda:id[@root="2.16.840.1.113883.249.6"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:author/cda:assignedAuthor/cda:assignedPerson) &lt;= 1"/>
         <xsl:otherwise>
            <xsl:message>                  
     Warning: CONF-QRDA1-47 and 48: A QRDA Category I report MAY contain a ClinicalDocument/author/assignedAuthor/assignedPerson element and if present may contain exactly one.
   (count(cda:author/cda:assignedAuthor/cda:assignedPerson) &lt;= 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:author/cda:assignedAuthor/cda:assignedPerson/name) &gt;= 0"/>
         <xsl:otherwise>
            <xsl:message>                  
       Error: CONF-QRDA1-49: A QRDA Category I report MAY contain at least one legal name ClinicalDocument/author/assignedAuthor/assignedPerson/name.
   (count(cda:author/cda:assignedAuthor/cda:assignedPerson/name) &gt;= 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:author/cda:assignedAuthor/cda:assignedPerson/cda:name/cda:given) &gt;= 0"/>
         <xsl:otherwise>
            <xsl:message>                  
       Error: CONF-QRDA1-50: A QRDA Category I report MAY contain at least one ClinicalDocument/author/assignedAuthor/assignedPerson/name/given.
   (count(cda:author/cda:assignedAuthor/cda:assignedPerson/cda:name/cda:given) &gt;= 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:author/cda:assignedAuthor/cda:assignedPerson/cda:name/cda:family) &gt;= 0"/>
         <xsl:otherwise>
            <xsl:message>                  
       Error: CONF-QRDA1-51: A QRDA Category I report MAY contain at least one ClinicalDocument/author/assignedAuthor/assignedPerson/name/family.
   (count(cda:author/cda:assignedAuthor/cda:assignedPerson/cda:name/cda:family) &gt;= 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:author/cda:assignedAuthor/cda:representedOrganization) &lt;= 1"/>
         <xsl:otherwise>
            <xsl:message>                  
       Error: CONF-QRDA1-52: A QRDA Category I report MAY contain one ClinicalDocument/author/assignedAuthor/representedOrganization.
   (count(cda:author/cda:assignedAuthor/cda:representedOrganization) &lt;= 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:author/cda:assignedAuthor/cda:representeOrganization/cda:id[@root=&#34;*&#34;]) &gt;= 0"/>
         <xsl:otherwise>
            <xsl:message>                  
       Error: CONF-QRDA1-53: A QRDA Category I report MAY contain a ClinicalDocument/author/assignedAuthor/representedOrganization/id element with @root containing the OID of the authoring organization.
   (count(cda:author/cda:assignedAuthor/cda:representeOrganization/cda:id[@root="*"]) &gt;= 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:author/cda:assignedAuthor/cda:representeOrganization/name) &gt;= 0"/>
         <xsl:otherwise>
            <xsl:message>                  
       Error: CONF-QRDA1-54: A QRDA Category I report MAY contain a ClinicalDocument/author/assignedAuthor/representedOrganization/name element.
   (count(cda:author/cda:assignedAuthor/cda:representeOrganization/name) &gt;= 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:informant) = 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-10: A QRDA Category I report SHALL contain exactly one
       ClinicalDocument/informant, which represents the reporting facility.
       CONF-QRDA-I-11: An organization source of information SHALL be represented with
       informant.
     (count(cda:informant) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:id/@root or                   cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:id[@nullFlavor=&#34;MSK&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-12: A QRDA Category I report SHALL contain exactly one
       custodian/assignedCustodian/representedCustodianOrganization/
       id element.
       CONF-QRDA-I-13: The value of custodian/assignedCustodian/
       representedCustodianOrganization/id element @root SHALL be the id
       root of the custodian organization.
     (cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:id/@root or cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization/cda:id[@nullFlavor="MSK"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(cda:legalAuthenticator) or count(cda:legalAuthenticator/cda:time) = 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-15: If present, a QRDA Category I report legalAuthenticator SHALL
       contain exactly one ClinicalDocument/legalAuthenticator/time element.
     (not(cda:legalAuthenticator) or count(cda:legalAuthenticator/cda:time) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(cda:legalAuthenticator) or count(cda:legalAuthenticator/cda:signatureCode) = 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-16: If present, a QRDA Category I report legalAuthenticator SHALL
        contain exactly one signatureCode element.
     (not(cda:legalAuthenticator) or count(cda:legalAuthenticator/cda:signatureCode) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(cda:legalAuthenticator) or                   cda:legalAuthenticator/cda:signatureCode[@code=&#34;S&#34;] or                   cda:legalAuthenticator/cda:signatureCode[@nullFlavor=&#34;MSK&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-17: The value of a QRDA ClinicalDocument/signatureCode/@code
       SHALL be S.
     (not(cda:legalAuthenticator) or cda:legalAuthenticator/cda:signatureCode[@code="S"] or cda:legalAuthenticator/cda:signatureCode[@nullFlavor="MSK"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(cda:legalAuthenticator) or                   cda:legalAuthenticator/cda:assignedEntity"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-18: If present, a QRDA Category I report legalAuthenticator SHALL
       contain exactly one assignedEntity element that represents the legal
       authenticator of the document.
     (not(cda:legalAuthenticator) or cda:legalAuthenticator/cda:assignedEntity)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(cda:legalAuthenticator) or                   cda:legalAuthenticator/cda:assignedEntity/cda:id"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-19: The ClinicalDocument/legalAuthenticator/assigned entity
       SHALL contain an id element.
     (not(cda:legalAuthenticator) or cda:legalAuthenticator/cda:assignedEntity/cda:id)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:component/cda:structuredBody"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-20: A QRDA Category I report SHALL contain exactly one
       ClinicalDocument/component/structuredBody.
     (cda:component/cda:structuredBody)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:section/cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]) &gt; 0"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-21: A QRDA Category I report SHALL contain at least one and MAY contain
       more than one Measure section each containing information about a single measure.
     (count(.//cda:section/cda:code[@code="55186-1" and @codeSystem="2.16.840.1.113883.6.1"]) &gt; 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]"
                 priority="1004"
                 mode="M6">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="self::cda:section[parent::cda:component[parent::cda:structuredBody[parent::cda:component[parent::cda:ClinicalDocument]]]] or                   parent::cda:section[@code=&#34;55185-3&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]/cda:component"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-22: The Measure section SHALL be a top-level section if it is not part of a
       measure set.
     (self::cda:section[parent::cda:component[parent::cda:structuredBody[parent::cda:component[parent::cda:ClinicalDocument]]]] or parent::cda:section[@code="55185-3" and @codeSystem="2.16.840.1.113883.6.1"]/cda:component)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:templateId"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-33: The Measure section SHALL contain at least one templateId uniquely
        identifying each Measure name and version
     (cda:templateId)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(parent::cda:section[@code=&#34;55185-3&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]/cda:entry) or                   contains(translate(cda:title,&#34;QWERTYUIOPASDFGHJKLZXCVBNM&#34;,&#34;qwertyuiopasdfghjklzxcvbnm&#34;),&#34;measure section: &#34;)"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-36: A non-nested Measure section SHALL be valued with section/title
       with a case-insensitive, text string containing "measure section:
       &lt;measure name&gt;".
     (not(parent::cda:section[@code="55185-3" and @codeSystem="2.16.840.1.113883.6.1"]/cda:entry) or contains(translate(cda:title,"QWERTYUIOPASDFGHJKLZXCVBNM","qwertyuiopasdfghjklzxcvbnm"),"measure section: "))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(parent::cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section) or                   contains(translate(cda:title,&#34;QWERTYUIOPASDFGHJKLZXCVBNM&#34;,&#34;qwertyuiopasdfghjklzxcvbnm&#34;),&#34;measure section&#34;)"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-37: A nested Measure section SHALL be valued with section/title with
        a case-insensitive, text string containing "measure section".
     (not(parent::cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section) or contains(translate(cda:title,"QWERTYUIOPASDFGHJKLZXCVBNM","qwertyuiopasdfghjklzxcvbnm"),"measure section"))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:section[cda:code[@code = &#34;55187-9&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]) = 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-39: A Measure section SHALL contain exactly one nested Reporting
       Parameters section (as described in Section 2.4.3 Reporting Parameters
       Section).
     (count(.//cda:section[cda:code[@code = "55187-9" and @codeSystem="2.16.840.1.113883.6.1"]]) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:section[cda:code[@code = &#34;55188-7&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]) = 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-40: A Measure section SHALL contain exactly one nested Patient Data
        section (as described in Section 2.4.4 Patient Data Section).
     (count(.//cda:section[cda:code[@code = "55188-7" and @codeSystem="2.16.840.1.113883.6.1"]]) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:entry/cda:act[@classCode=&#34;ACT&#34; and @moodCode=&#34;DEF&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-42: Each measure SHALL be represented with act.
       CONF-QRDA-I-43: For each act in the Measure section, the value for act/@classCode
       in a measure act SHALL be ACT 2.16.840.1.113883.5.6 ActClass STATIC.
       CONF-QRDA-I-44: For each act in the Measure section the act/@moodCode in a
       measure act SHALL be DEF 2.16.840.1.113883.5.1001 ActMood STATIC.
     (cda:entry/cda:act[@classCode="ACT" and @moodCode="DEF"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]/cda:entry/cda:act[@classCode=&#34;ACT&#34; and @moodCode=&#34;DEF&#34;]"
                 priority="1003"
                 mode="M6">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:code"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-45: For each act in the Measure section there SHALL be an act/code
       reflecting the measure name and version.
     (cda:code)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:code[@code=&#34;55185-3&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]"
                 priority="1002"
                 mode="M6">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:section[cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]) = 1"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-24: The Measure Set section SHALL contain one nested Measure section
       and SHALL NOT contain more than one nested Measure section.
     (count(.//cda:section[cda:code[@code="55186-1" and @codeSystem="2.16.840.1.113883.6.1"]]) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:templateId"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-26: The Measure Set section SHALL contain a templateId uniquely
       identifying the Measure Set name and version.
     (cda:templateId)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(translate(cda:title,'QWERTYUIOPASDFGHJKLZXCVBNM','qwertyuiopasdfghjklzxcvbnm'),'measure set: ')"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-29: The Measure Set section SHALL be valued with section/title with a
       case-insensitive, text string containing "Measure set: &lt;measure set
       name&gt;".
     (contains(translate(cda:title,'QWERTYUIOPASDFGHJKLZXCVBNM','qwertyuiopasdfghjklzxcvbnm'),'measure set: '))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(.//cda:section/cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]) &gt; 0 "/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-31: The nested Measure section SHALL contain at least one measure that
        belongs to the measure set.
     (count(.//cda:section/cda:code[@code="55186-1" and @codeSystem="2.16.840.1.113883.6.1"]) &gt; 0)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:code[@code=&#34;55187-9&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]"
                 priority="1001"
                 mode="M6">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(translate(cda:title,&#34;QWERTYUIOPASDFGHJKLZXCVBNM&#34;,&#34;qwertyuiopasdfghjklzxcvbnm&#34;),&#34;reporting parameters&#34;)"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-49: The Reporting Parameters section SHALL be valued with
       section/title with a case-insensitive, text string containing "Reporting
       Parameters".
     (contains(translate(cda:title,"QWERTYUIOPASDFGHJKLZXCVBNM","qwertyuiopasdfghjklzxcvbnm"),"reporting parameters"))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:entry/cda:act[@classCode=&#34;ACT&#34; and @moodCode=&#34;EVN&#34;]/cda:code[@code=&#34;252116004&#34; and @codeSystem=&#34;2.16.840.1.113883.6.96&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-50: The Reporting Parameters section SHALL contain exactly one
       Observation Parameters Act, represented as an act.
       CONF-QRDA-I-51: The value for act/@classCode in an Observation Parameters Act
       SHALL be ACT 2.16.840.1.113883.5.6 ActClass STATIC.
       CONF-QRDA-I-52: The value for act/@moodCode in an Observation Parameters Act
       SHALL be EVN 2.16.840.1.113883.5.1001 ActMood STATIC.
       CONF-QRDA-I-53: The value for act/code SHALL be 252116004 Observation
       Parameters 2.16.840.1.113883.6.96 SNOMED-CT STATIC.
     (cda:entry/cda:act[@classCode="ACT" and @moodCode="EVN"]/cda:code[@code="252116004" and @codeSystem="2.16.840.1.113883.6.96"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:entry/cda:act[@classCode=&#34;ACT&#34; and @moodCode=&#34;EVN&#34;][cda:code[@code=&#34;252116004&#34; and @codeSystem=&#34;2.16.840.1.113883.6.96&#34;]]/cda:effectiveTime[cda:low and cda:high]"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-54: The reporting time period SHALL be represented with an
       effectiveTime/low element combined with a high element representing
       respectively the first and last days of the period reported.
     (cda:entry/cda:act[@classCode="ACT" and @moodCode="EVN"][cda:code[@code="252116004" and @codeSystem="2.16.840.1.113883.6.96"]]/cda:effectiveTime[cda:low and cda:high])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:code[@code=&#34;55188-7&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]"
                 priority="1000"
                 mode="M6">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(translate(cda:title,&#34;QWERTYUIOPASDFGHJKLZXCVBNM&#34;,&#34;qwertyuiopasdfghjklzxcvbnm&#34;),&#34;patient data&#34;)"/>
         <xsl:otherwise>
            <xsl:message>
       Error: CONF-QRDA-I-57: The Patient Data section SHALL be valued with section/title with a
       case-insensitive, text string containing "Patient Data".
     (contains(translate(cda:title,"QWERTYUIOPASDFGHJKLZXCVBNM","qwertyuiopasdfghjklzxcvbnm"),"patient data"))</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

   <!--PATTERN p-2.16.840.1.113883.10.20.12-warningsHL7 QRDA Category I Header (Section 2) - warning validation phase-->


	<!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;2.16.840.1.113883.10.20.12&#34;]" priority="1000"
                 mode="M7">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:legalAuthenticator) = 1"/>
         <xsl:otherwise>
            <xsl:message>
       Warning: CONF-QRDA-I-14: A QRDA Category I report SHOULD contain exactly one
       legalAuthenticator element.
     (count(cda:legalAuthenticator) = 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

   <!--PATTERN p-2.16.840.1.113883.10.20.12-notesHL7 QRDA Category I Header (Section 2) - note validation phase-->


	<!--RULE -->
<xsl:template match="*[cda:templateId/@root=&#34;2.16.840.1.113883.10.20.12&#34;]" priority="1003"
                 mode="M8">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(cda:component/cda:structuredBody/cda:component/cda:section/cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]) &gt; 1"/>
         <xsl:otherwise>
            <xsl:message>
       Note: CONF-QRDA-I-21: A QRDA Category I report ... MAY contain
       more than one non-nested top-level Measure section each containing
       information about a single measure.
     (count(cda:component/cda:structuredBody/cda:component/cda:section/cda:code[@code="55186-1" and @codeSystem="2.16.840.1.113883.6.1"]) &gt; 1)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test=".//cda:section/cda:code[@code=&#34;55185-3&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Note: CONF-QRDA-I-23: A QRDA Category I report MAY contain one or more Measure Set
       sections.
     (.//cda:section/cda:code[@code="55185-3" and @codeSystem="2.16.840.1.113883.6.1"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:component/cda:structuredBody/cda:component/cda:section/cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;] and                   .//cda:section/cda:code[@code=&#34;55185-3&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]"/>
         <xsl:otherwise>
            <xsl:message>
       Note: CONF-QRDA-I-25: A QRDA Category I report MAY contain both Measure Set sections and
       individual top-level Measure sections.
     (cda:component/cda:structuredBody/cda:component/cda:section/cda:code[@code="55186-1" and @codeSystem="2.16.840.1.113883.6.1"] and .//cda:section/cda:code[@code="55185-3" and @codeSystem="2.16.840.1.113883.6.1"])</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]"
                 priority="1002"
                 mode="M8">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:text"/>
         <xsl:otherwise>
            <xsl:message>
       Note: CONF-QRDA-I-41: The Measure section MAY contain a section/text element for the
       description of the measure(s).
     (cda:text)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:code[@code=&#34;55186-1&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]/cda:entry/cda:act[@classCode=&#34;ACT&#34; and @moodCode=&#34;DEF&#34;]"
                 priority="1001"
                 mode="M8">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:text"/>
         <xsl:otherwise>
            <xsl:message>
       Note: CONF-QRDA-I-46: Each measure act MAY contain an act/text element containing a
        description of the measure.
     (cda:text)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="*[cda:code[@code=&#34;55185-3&#34; and @codeSystem=&#34;2.16.840.1.113883.6.1&#34;]]"
                 priority="1000"
                 mode="M8">

		<!--ASSERT -->
<xsl:choose>
         <xsl:when test="cda:text"/>
         <xsl:otherwise>
            <xsl:message>
       Note: CONF-QRDA-I-30: The Measure Set section MAY contain a section/text element for
       the description of the measure set or MAY contain a formal representation of
       a description of the measure set.
     (cda:text)</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
</xsl:stylesheet>