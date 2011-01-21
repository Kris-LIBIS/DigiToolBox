<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xb="http://com/exlibris/digitool/repository/api/xmlbeans">

    <xsl:param name="pid"/>
    <xsl:param name="old_pid"/>
    <xsl:param name="usage"/>
    <xsl:param name="clear_entity_type">false</xsl:param>
    <xsl:param name="copyControl">false</xsl:param>
    <xsl:param name="copyMetadata">false</xsl:param>
    <xsl:param name="copyRelations">false</xsl:param>

    <!-- This stylesheet copies a digital_entity that was retrieved
         into a new digital_entity with:
         - a new pid
         - a new usage type (optional)
         - all shared metadata linked to the new pid (optionally)
         - all relations copied (optionally)
         - no stream-ref
         Wrap this digital_entity in a digital_entity_call with command=update
         and it will update the new pid with the selected data of the original pid.

         Note that all the control fields are copied from the original pid,
         including ingest info, note, status, partitions and unit.

         Parameters:
         - pid = new pid
         - usage = new pid's usage type (default: null - means no change)
         - copyControl = copy the control section? (default: false)
         - copyMetadata = copy the shared metadata section? (default: false)
         - copyRelations = copy the relations section? (default: false)
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
            <xsl:if test="$copyControl">
                <xsl:apply-templates select="control"/>
            </xsl:if>
            <xsl:if test="$copyMetadata">
                <xsl:apply-templates select="mds"/>
            </xsl:if>
            <xsl:if test="$copyRelations">
                <xsl:apply-templates select="relations"/>
            </xsl:if>
            <!-- stream_ref is deliberately omitted in the output -->
        </xsl:copy>
    </xsl:template>

    <!-- modify pid element -->
    <xsl:template match="xb:digital_entity/pid">
        <xsl:element name="{name()}">
            <xsl:value-of select="$pid"/>
        </xsl:element>
    </xsl:template>

    <!-- optionally modify usage_type element -->
    <xsl:template match="xb:digital_entity/control/usage_type">
        <xsl:choose>
            <xsl:when test="$usage = null or $usage = ''">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{name()}">
                    <xsl:value-of select="$usage"/>
                </xsl:element>
            </xsl:otherwise>
         </xsl:choose>
    </xsl:template>

    <!-- optionally clear entity_type element -->
    <xsl:template match="xb:digital_entity/control/entity_type">
        <xsl:choose>
            <xsl:when test="$clear_entity_type">
                <xsl:element name="{name()}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
         </xsl:choose>
    </xsl:template>

    <!-- process the metadata entries -->
    <xsl:template match="xb:digital_entity/mds">
        <xsl:element name="{name()}">
            <xsl:attribute name="cmd">delete_and_insert_delta</xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <!-- only shared md records will be copied to the new pid -->
            <xsl:apply-templates select="md[@shared='true']"/>
        </xsl:element>
    </xsl:template>

    <!-- adds a new shared metadata record to the pid -->
    <xsl:template match="xb:digital_entity/mds/md">
        <xsl:element name="{name()}">
            <!-- md will be shared in the new pid -->
            <xsl:attribute name="link_to_exists">true</xsl:attribute>
            <xsl:attribute name="cmd">insert</xsl:attribute>
            <!-- we retain only mid since it is shared -->
            <xsl:apply-templates select="mid"/>
        </xsl:element>
    </xsl:template>

    <!-- process relations, any existing relations will be removed -->
    <xsl:template match="xb:digital_entity/relations">
        <xsl:element name="{name()}">
            <xsl:attribute name="cmd">delete_and_insert_all</xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="relation[type = 'manifestation']"/>
            <xsl:element name="relation">
                <xsl:element name="type">manifestation</xsl:element>
                <xsl:element name="pid"><xsl:value-of select="$old_pid"/></xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- default template simpy copies everything -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
