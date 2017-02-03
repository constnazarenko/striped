<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="block[@controller = 'menu']">
    <xsl:param name="delimiter" />
    <xsl:param name="notail">0</xsl:param>

    <xsl:value-of select="menu/node()"/>
    <ul class="menu">
        <xsl:apply-templates select="menu/node()[name(.)='item' or name(.)='delimiter']">
            <xsl:with-param name="delimiter" select="$delimiter" />
            <xsl:with-param name="notail" select="$notail" />
        </xsl:apply-templates>
    </ul>
</xsl:template>

<!-- root.menu -->
<xsl:template match="block[@name = 'root.menu']">
    <xsl:param name="delimiter" />
    <xsl:param name="notail" />

    <xsl:if test="menu != '' and $actions/root">
        <div class="root-menu">
            <ul>
                <xsl:apply-templates select="menu/node()">
                    <xsl:with-param name="delimiter" select="$delimiter" />
                    <xsl:with-param name="notail" select="$notail" />
                </xsl:apply-templates>
            </ul>
            <div class="clear"></div>
        </div>
    </xsl:if>
</xsl:template>
<!-- ^root.menu^ -->

<xsl:template match="delimiter[ancestor::block[@controller = 'menu']]">
    <xsl:variable name="cat" select="substring-before(@rights, '.')"/>
    <xsl:variable name="act" select="substring-after(@rights, '.')"/>
    <xsl:if test="not(@rights) or $actions/*[local-name() = $cat]/*[local-name() = $act] or ($cat = '' and $act = '' and $actions/*[local-name() = current()/@rights] )">
        <li class="delimiter">
            <xsl:choose>
                <xsl:when test="@title != ''">
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword" select="@title" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>---</xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:if>
</xsl:template>

<xsl:template match="item[ancestor::block[@controller = 'menu']]">
    <xsl:param name="delimiter" />
    <xsl:param name="notail" />
    <xsl:variable name="cat" select="substring-before(@rights, '.')"/>
    <xsl:variable name="act" select="substring-after(@rights, '.')"/>
    <xsl:if test="not(@rights) or $actions/*[local-name() = $cat]/*[local-name() = $act] or ($cat = '' and $act = '' and $actions/*[local-name() = current()/@rights] )">
        <li>
            <xsl:variable name='murl'>
                <xsl:choose>
                    <xsl:when test="@match != ''"><xsl:value-of select="@match"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="@url"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <!-- $requested_uri = @url -->
                <xsl:when test="$murl and (starts-with($requested_uri, $murl) and ($murl != '' or $requested_uri = ''))">
                    <xsl:attribute name="class">
                        <xsl:text>active</xsl:text>
                        <xsl:if test="@name!=''">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="@name" />
                        </xsl:if>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@name!=''">
                    <xsl:attribute name="class">
                        <xsl:value-of select="@name" />
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>

            <xsl:if test="item or delimiter">
                <ul>
                    <xsl:apply-templates select="item | delimiter">
                        <xsl:with-param name="delimiter" select="$delimiter" />
                        <xsl:with-param name="notail" select="$notail" />
                    </xsl:apply-templates>
                </ul>
            </xsl:if>

            <xsl:choose>
                <xsl:when test="@url">
                    <a>
                        <xsl:if test="@class!=''">
                            <xsl:attribute name="class">
                                <xsl:value-of select="@class" />
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="@absolute = 1">
                                    <xsl:value-of select="@url" />
                                </xsl:when>
                                <xsl:when test="@local = 1">
                                    <xsl:value-of select="$server" />
                                    <xsl:value-of select="@url" />
                                </xsl:when>
                                <xsl:when test="@disabled = 1">
                                    <xsl:text>javascript:void(0);</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$base" />
                                    <xsl:value-of select="$lang_url" />
                                    <xsl:value-of select="@url" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="@title" />
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <span>
                        <xsl:if test="@class!=''">
                            <xsl:attribute name="class">
                                <xsl:value-of select="@class" />
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="@title" />
                        </xsl:call-template>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </li>
        <xsl:if test="$delimiter and position() != last()">
            <li><xsl:value-of select="$delimiter" /></li>
        </xsl:if>
    </xsl:if>
    <xsl:if test="position() = last() and not($notail)">
        <li class="menu-tail"></li>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>