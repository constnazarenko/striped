<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="pageinfo">
    <div class="block">
        <link rel="stylesheet" type="text/css" href="striped/css/pageinfo.css" />
        <xsl:apply-templates  />
    </div>
</xsl:template>

<xsl:template match="page_modules">
    <h1>Blocks</h1>
    <table class="pageinfo">
        <thead>
            <tr>
                <th class="first">controller</th>
                <th class="second">action</th>
                <th class="third">name</th>
                <th class="fourth">type</th>
            </tr>
        </thead>
        <tbody>
            <xsl:apply-templates mode="page_modules" />
        </tbody>
    </table>
</xsl:template>

<xsl:template match="*" mode="page_modules">
    <tr>
        <td><xsl:value-of select="controller" /></td>
        <td><xsl:value-of select="action" /></td>
        <td><xsl:value-of select="name" /></td>
        <td><xsl:value-of select="type" /></td>
    </tr>
</xsl:template>

<xsl:template match="page_params">
    <h1>Parameters</h1>
    <table class="pageinfo">
        <thead>
            <tr>
                <th>name</th>
                <th>value</th>
            </tr>
        </thead>
        <tbody>
            <xsl:apply-templates mode="page_params" />
        </tbody>
    </table>
</xsl:template>

<xsl:template match="*" mode="page_params">
    <tr>
        <td><xsl:value-of select="name(.)" /></td>
        <td>
            <xsl:choose>
                <xsl:when test="text() != ''"><xsl:value-of select="text()" /></xsl:when>
                <xsl:when test="node()">
                    <xsl:for-each select="node()">
                        <xsl:value-of select="name(.)" /><xsl:text>: </xsl:text>
                        <xsl:choose>
                            <xsl:when test="text() != ''">
                                <xsl:value-of select="text()" />
                            </xsl:when>
                            <xsl:otherwise>[empty]</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>| </xsl:text>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>[empty]</xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>

</xsl:stylesheet>