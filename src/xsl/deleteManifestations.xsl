<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xb="http://com/exlibris/digitool/repository/api/xmlbeans">

    <!-- This stylesheet deletes a digital_entity's manifestation relations -->

    <xsl:output method="xml" indent="true" cdata-section-elements="value"/>

    <!-- in case it's a digital entity result, we change the main tag and add the command -->
    <xsl:template match="xb:digital_entity_result">
        <xsl:element name="xb:digital_entity_call">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="xb:digital_entity"/>
            <xsl:element name="command">update</xsl:element>
         </xsl:element>
    </xsl:template>

    <!-- process xb:digital_entity element -->
    <xsl:template match="xb:digital_entity">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="pid"/>
            <xsl:apply-templates select="relations"/>
        </xsl:copy>
    </xsl:template>

    <!-- process relations, any existing manifestation relations will be removed -->
    <xsl:template match="xb:digital_entity/relations">
        <xsl:element name="{name()}">
            <xsl:attribute name="cmd">delete_and_insert_all</xsl:attribute>
            <xsl:apply-templates select="@*"/>
        </xsl:element>
    </xsl:template>

    <!-- default template simpy copies everything -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>