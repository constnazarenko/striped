<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="block[@controller = 'referer']">
    <div class="server">
        <xsl:if test="formblock">
            <div class="form-filter">
                <xsl:apply-templates select="formblock" mode="short-view" />
                <div class="clear"></div>
            </div>
        </xsl:if>
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'formblock')]" />
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'referer']/customers">
    <h2>Registered</h2>
    <table class="tech fixOnScrollTable">
        <thead>
            <tr>
                <th width="200"><xsl:value-of select="$translate[@keyword='ref_time']" /></th>
                <th><xsl:value-of select="$translate[@keyword='ref_referer']" /></th>
                <th><xsl:value-of select="$translate[@keyword='glb_customer']" /></th>
            </tr>
        </thead>
        <tbody>
            <xsl:choose>
                <xsl:when test="customer"><xsl:apply-templates select="customer"/></xsl:when>
                <xsl:otherwise><tr><td colspan="3" style="text-align: center;"><xsl:value-of select="$translate[@keyword='glb_empty']"/></td></tr></xsl:otherwise>
            </xsl:choose>
        </tbody>
    </table>
</xsl:template>

<xsl:template match="block[@controller = 'referer']/customers/customer">
    <tr>
        <td><xsl:value-of select="time" /></td>
        <td><xsl:value-of select="referer" /></td>
        <td><xsl:value-of select="login" /></td>
    </tr>
</xsl:template>



<xsl:template match="block[@controller = 'referer']/refs">
    <xsl:if test="@reflink != ''">
        <h2><xsl:value-of select="$translate[@keyword='ref_your_link']" /> - <xsl:value-of select="@reflink" /></h2>
    </xsl:if>
    <h2>Hits</h2>
    <table class="tech fixOnScrollTable">
        <thead>
            <tr>
                <th><xsl:value-of select="$translate[@keyword='ref_time']" /></th>
                <th><xsl:value-of select="$translate[@keyword='ref_referer']" /></th>
                <th><xsl:value-of select="$translate[@keyword='ref_http_referer']" /></th>
                <th><xsl:value-of select="$translate[@keyword='ref_ip']" /></th>
                <th><xsl:value-of select="$translate[@keyword='ref_access_point']" /></th>
            </tr>
        </thead>
        <tbody>
            <xsl:choose>
                <xsl:when test="ref"><xsl:apply-templates select="ref"/></xsl:when>
                <xsl:otherwise><tr><td colspan="6" style="text-align: center;"><xsl:value-of select="$translate[@keyword='glb_empty']"/></td></tr></xsl:otherwise>
            </xsl:choose>
        </tbody>
    </table>
</xsl:template>

<xsl:template match="block[@controller = 'referer']/refs/ref">
    <tr>
        <td><xsl:value-of select="time" /></td>
        <td><xsl:value-of select="customer" /></td>
        <td><xsl:value-of select="http_referer" /></td>
        <td><xsl:value-of select="ip" /></td>
        <td><xsl:value-of select="accesspoint" /></td>
    </tr>
</xsl:template>
    
</xsl:stylesheet>