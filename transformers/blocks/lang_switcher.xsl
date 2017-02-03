<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="block[@name = 'lang_switcher']">
    <xsl:if test="count(languages/language) > 1">
        <div class="block langswitcher">
            <xsl:apply-templates select="languages/language" />
            <div class="clear"></div>
        </div>
        <div class="clear"></div>
    </xsl:if>
</xsl:template>

<xsl:template match="language[ancestor::block[@name = 'lang_switcher']]">
    <a href="{$base}{@id}/{$requested_uri}?switchlang=1" title="{@title}">
        <xsl:if test="../../current = @id">
            <xsl:attribute name="class">active</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@title" />
    </a>
</xsl:template>

</xsl:stylesheet>
