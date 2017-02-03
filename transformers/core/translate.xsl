<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="translate">
    <xsl:param name="keyword" />
    <xsl:variable name="cache" select="/document/translates/translate[@keyword = $keyword]" />
    <xsl:choose>
        <xsl:when test="$cache">
            <xsl:value-of select="$cache" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$keyword" disable-output-escaping="yes" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
    
</xsl:stylesheet>