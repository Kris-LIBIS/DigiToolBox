<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xb="http://com/exlibris/digitool/repository/api/xmlbeans">

    <xsl:param name="tag"/>
    <xsl:param name="action"/>
    <xsl:param name="value"/>

    <!-- This stylesheet updates a digital_entity's info using:
         - a tag to lookup the data to change
         - a action name (replace/append/remove)
         - a value to replace or append the tag's value with

         Wrap this digital_entity in a digital_entity_call with command=update
         and it will update the pid with the modified data.

         Parameters:
         - tag = XPATH expression that selects the correct data
         - action = one of "replace", "append" or "delete"
         - value = the value to replace or append the data with
    -->

    <xsl:output method="xml" indent="true" cdata-section-elements="value"/>

    <!-- in case it's a digital entity result, we change the main tag and add the command -->
    <xsl:template match="xb:digital_entity_result">
        <xsl:element name="xb:digital_entity_call" namespace="http://com/exlibris/digitool/repository/api/xmlbeans">
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
            <xsl:apply-templates select="control"/>
            <!-- mds, relations and stream_ref are deliberately omitted in the output -->
        </xsl:copy>
    </xsl:template>

    <!-- process xb:digital_entity/control element -->
    <xsl:template match="xb:digital_entity/control">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each select="node()">
                <xsl:copy>
                    <xsl:choose>
                        <xsl:when test="name()=$tag">
                            <xsl:call-template name="perform_action">
                                <xsl:with-param name="node" select="."/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="@*|node()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:copy>
            </xsl:for-each>
            <!-- mds, relations and stream_ref are deliberately omitted in the output -->
        </xsl:copy>
    </xsl:template>

    <xsl:template name="perform_action">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="$action = 'delete'">
                <xsl:attribute name="xsi:nil" namespace="http://www.w3.org/2001/XMLSchema-instance">true</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="@*[not(name() = 'xsi:nil' or name() = 'xmlns:xsi')]"/>
                <xsl:choose>
                    <xsl:when test="$action = 'append'"><xsl:value-of select="node()"/><xsl:value-of select="$value"/></xsl:when>
                    <xsl:when test="$action = 'replace'"><xsl:value-of select="$value"/></xsl:when>
                    <xsl:otherwise><xsl:apply-templates select="node()"/></xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- default template simpy copies everything -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
