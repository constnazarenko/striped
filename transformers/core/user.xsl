<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="userlink">
    <xsl:param name="customer_name" />
    <xsl:param name="username" />
    <xsl:param name="realname" />
    
    <a href="user/{$customer_name}-{$username}/" class="username-link">
        <xsl:if test="$customer_name != ''">
            <b><xsl:value-of select="$customer_name" />::</b>
        </xsl:if>
        <xsl:value-of select="$username" />
    </a>
</xsl:template>

<xsl:template name="userlink-tiny">
    <xsl:param name="customer_name" />
    <xsl:param name="username" />
    <xsl:param name="realname" />
    
    <a href="user/{$customer_name}-{$username}/" class="username-link-tiny">
        <xsl:if test="$customer_name != ''">
            <b><xsl:value-of select="$customer_name" />::</b>
        </xsl:if>
        <xsl:value-of select="$username" />
    </a>
</xsl:template>

<xsl:template name="userlink-link">
    <xsl:param name="username" />
    
    <xsl:text>users/</xsl:text>
    <xsl:value-of select="$username" />
    <xsl:text>/</xsl:text>
</xsl:template>

</xsl:stylesheet>
