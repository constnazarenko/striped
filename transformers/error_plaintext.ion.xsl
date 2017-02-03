<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="utf-8"
        omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
        indent="no" />

    <xsl:variable name="title">
        <xsl:value-of select="/document/error/type" />
        <xsl:text> (code: </xsl:text>
        <xsl:value-of select="/document/error/code" />
        <xsl:text>)</xsl:text>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="document">
        <xsl:apply-templates select="error" />
    </xsl:template>

    <xsl:template match="error">
        <xsl:value-of select="$title" /><xsl:text>: </xsl:text><xsl:value-of select="message" />
        <xsl:choose>
            <xsl:when test="additionalData/item">
                <xsl:apply-templates select="additionalData/item" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>
</xsl:text>
                <xsl:value-of select="additionalData" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>
</xsl:text>
        <xsl:text> ip: </xsl:text><xsl:value-of select="ip" />
        <xsl:text>
</xsl:text>
        <xsl:text> referer: </xsl:text><xsl:value-of select="referer" />
        <xsl:text>
</xsl:text>
        <xsl:text> requested uri: </xsl:text><xsl:value-of select="request_uri" />
        <xsl:text>
</xsl:text>
        <xsl:text> in file: </xsl:text><xsl:value-of select="file" /><xsl:text> on line: </xsl:text><xsl:value-of select="line" />
        <xsl:text>
</xsl:text>
        <xsl:value-of select="trace" disable-output-escaping="yes" />
    </xsl:template>

    <xsl:template match="additionalData/item">
        <xsl:text>
 </xsl:text>
        <xsl:if test="@name">
            <xsl:value-of select="@name" /><xsl:text>: </xsl:text>
        </xsl:if><xsl:value-of select="." />
    </xsl:template>

</xsl:stylesheet>