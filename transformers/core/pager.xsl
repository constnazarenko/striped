<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="pager">
    <div class="pager">
        <div class="side-ward">
            <xsl:if test="prev">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="prefix" />
                        <xsl:value-of select="prev/@seo" />
                        <xsl:value-of select="postfix" />
                        <xsl:if test="$requested_get != ''">
                            <xsl:text>?</xsl:text>
                            <xsl:value-of select="$requested_get" />
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">glb_pgr_prv</xsl:with-param>
                    </xsl:call-template>
                </a>
            </xsl:if>
            <xsl:if test="next">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="prefix" />
                        <xsl:value-of select="next/@seo" />
                        <xsl:value-of select="postfix" />
                        <xsl:if test="$requested_get != ''">
                            <xsl:text>?</xsl:text>
                            <xsl:value-of select="$requested_get" />
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">glb_pgr_nxt</xsl:with-param>
                    </xsl:call-template>
                </a>
            </xsl:if>
        </div>
        <div class="pages">
            <xsl:if test="first">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="prefix" />
                        <xsl:value-of select="first/@seo" />
                        <xsl:value-of select="postfix" />
                        <xsl:if test="$requested_get != ''">
                            <xsl:text>?</xsl:text>
                            <xsl:value-of select="$requested_get" />
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">glb_pgr_fst</xsl:with-param>
                    </xsl:call-template>
                </a>
            </xsl:if>
            <xsl:apply-templates select="pages/page" />
            <xsl:if test="last">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="prefix" />
                        <xsl:value-of select="last/@seo" />
                        <xsl:value-of select="postfix" />
                        <xsl:if test="$requested_get != ''">
                            <xsl:text>?</xsl:text>
                            <xsl:value-of select="$requested_get" />
                        </xsl:if>
                    </xsl:attribute>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">glb_pgr_lst</xsl:with-param>
                    </xsl:call-template>
                </a>
            </xsl:if>
            <div class="clear"></div>
        </div>
    </div>
</xsl:template>

<xsl:template match="pager/pages/page">
    <xsl:choose>
        <xsl:when test="@current = 1">
            <span>
                <xsl:value-of select="text()" />
            </span>
        </xsl:when>
        <xsl:otherwise>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="../../prefix" />
                    <xsl:value-of select="@seo" />
                    <xsl:value-of select="../../postfix" />
                    <xsl:if test="$requested_get != ''">
                        <xsl:text>?</xsl:text>
                        <xsl:value-of select="$requested_get" />
                    </xsl:if>
                </xsl:attribute>
                <xsl:value-of select="text()" />
            </a>
        </xsl:otherwise>
    </xsl:choose>
    
</xsl:template>

</xsl:stylesheet>