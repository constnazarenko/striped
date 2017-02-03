<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="block[@controller = 'staticblock']">
    <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]" />
</xsl:template>

<xsl:template match="block[@controller = 'staticblock']/content">
    <div class="block statickblock">
        <xsl:if test="../@logged = 0">
            <xsl:attribute name="class">block hide-for-edit</xsl:attribute>
        </xsl:if>
        <xsl:if test="@canwrite=1 and not(/document/@code)">
            <div class="edit-links">
                <a href="{$server}staticblock/" id="{../@name}" class="overeditor link-edit">
                    <span>
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword">glb_edit</xsl:with-param>
                        </xsl:call-template>
                    </span>
                </a>
            </div>
        </xsl:if>
        <div id="{../@name}-contents">
            <div class="text"><xsl:value-of select="text" disable-output-escaping="yes" /></div>
        </div>
    </div>
</xsl:template>
    
</xsl:stylesheet>