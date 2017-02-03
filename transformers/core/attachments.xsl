<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="attachment" mode="file-image">
	<xsl:param name="canwrite">0</xsl:param>
	<xsl:param name="deletepath" />

    <div class="thumb killme">
        <a href="{xml/file[@size='large']}" class="overphoto"><img src="{xml/file[@size='tiny']}" width="{xml/file[@size='tiny']/@width}" height="{xml/file[@size='tiny']/@height}" alt="{title}" title="{title}" /></a>
        <xsl:if test="$canwrite=1 and $deletepath">
            <a href="{$server}{$deletepath}{id}" class="overphotokill overkill edit-button-no-hide">
                <span>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">glb_delete</xsl:with-param>
                    </xsl:call-template>                        
                </span>
            </a>
        </xsl:if>
    </div>
</xsl:template>

<xsl:template match="attachment" mode="file-audio">
	<xsl:param name="canwrite">0</xsl:param>
	<xsl:param name="deletepath" />

    <span class="killme">
    	<div class="track-play">
            <a href="{xml/file}" rel="audioplayer_{id}" title="{title}">
                <span>play</span>
            </a>
            <span id="audioplayer_{id}"></span>
        </div>
        <div class="track-download">
        	<a href="{xml/file}">
                <xsl:choose>
                    <xsl:when test="title != ''">
                        <xsl:value-of select="title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="xml/file"/>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
            <xsl:if test="$canwrite=1 and $deletepath">
                <xsl:text> (</xsl:text>
                <a href="{$server}{$deletepath}{id}" class="overkill">
                    <xsl:attribute name="title">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword">glb_delete</xsl:with-param>
                        </xsl:call-template>                        
                    </xsl:attribute>
                    <xsl:text>x</xsl:text>
                </a>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </div>
    </span>
</xsl:template>


<xsl:template match="attachment" mode="file-link">
	<xsl:param name="canwrite">0</xsl:param>
	<xsl:param name="deletepath" />

    <span class="killme">
        <a href="{xml/file}">
            <xsl:choose>
                <xsl:when test="title != ''">
                    <xsl:value-of select="title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="xml/file"/>
                </xsl:otherwise>
            </xsl:choose>
        </a>
        <xsl:if test="$canwrite=1 and $deletepath">
            <xsl:text> (</xsl:text>
            <a href="{$server}{$deletepath}{id}" class="overkill">
                <xsl:attribute name="title">
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">glb_delete</xsl:with-param>
                    </xsl:call-template>                        
                </xsl:attribute>
                <xsl:text>x</xsl:text>
            </a>
            <xsl:text>)</xsl:text>
        </xsl:if>
        <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </span>
</xsl:template>
    
</xsl:stylesheet>
