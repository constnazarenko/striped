<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="block[@controller = 'feedback']">
    <xsl:apply-templates  select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]" />
</xsl:template>
    
</xsl:stylesheet>