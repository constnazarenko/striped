<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template name="string-replace">
    <xsl:param name="string" />
    <xsl:param name="pattern" />
    <xsl:param name="replace" />
    <xsl:param name="d-o-e">yes</xsl:param>
    
    <xsl:variable name="result" select="concat(substring-before($string, $pattern), $replace, substring-after($string, $pattern))" />
    <xsl:choose>
        <xsl:when test="$result != '' and contains($result, $pattern)">
            <xsl:call-template name="string-replace">
                <xsl:with-param name="string" select="$result" />
                <xsl:with-param name="pattern" select="$pattern" />
                <xsl:with-param name="replace" select="$replace" />
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="$result != ''">
            <xsl:choose>
                <xsl:when test="$d-o-e = 'no'">
                    <xsl:value-of select="$result" disable-output-escaping="no" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$result" disable-output-escaping="yes" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$d-o-e = 'no'">
                    <xsl:value-of select="$string" disable-output-escaping="no" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$string" disable-output-escaping="yes" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cutting-fulltext">
    <xsl:param name="text" />
    <xsl:param name="d-o-e">yes</xsl:param>

    <xsl:call-template name="string-replace">
        <xsl:with-param name="string" select="$text" />
        <xsl:with-param name="pattern">&lt;hr/&gt;</xsl:with-param>
        <xsl:with-param name="replace"></xsl:with-param>
        <xsl:with-param name="d-o-e" select="$d-o-e" />
    </xsl:call-template>
</xsl:template>

<xsl:template name="cutting-first-cut">
    <xsl:param name="text" />
    <xsl:param name="more-link" />
    <xsl:param name="more-text">GLOBAL_READMORE</xsl:param>
    
    <xsl:variable name="first-part" select="substring-before($text, '&lt;hr/&gt;')" />
    <xsl:choose>
        <xsl:when test="$first-part != ''">
            <xsl:value-of select="$first-part" disable-output-escaping="yes" />
            
            <xsl:if test="$more-link != ''">
                <div class="more">
                    <a href="{$more-link}#first-cut">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="$more-text" />
                        </xsl:call-template>
                    </a>
                </div>
            </xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text" disable-output-escaping="yes" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="cutting-second-cut">
    <xsl:param name="text" />
    <xsl:param name="more-link" />
    <xsl:param name="more-text">GLOBAL_READMORE</xsl:param>
    
    <xsl:variable name="first-part" select="substring-before($text, '&lt;hr/&gt;')" />
    <xsl:choose>
        <xsl:when test="$first-part != ''">
            <xsl:variable name="second-part" select="substring-before(substring-after($text, '&lt;hr/&gt;'), '&lt;hr/&gt;')" />
            <xsl:value-of select="$first-part" disable-output-escaping="yes" />
            <xsl:value-of select="$second-part" disable-output-escaping="yes" />
            
            <xsl:if test="$more-link != ''">
                <div class="more">
                    <a href="{$more-link}#second-cut">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="$more-text" />
                        </xsl:call-template>
                    </a>
                </div>
            </xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text" disable-output-escaping="yes" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Склонение после числительных -->  
<xsl:template name="declension">  
    <!-- Число -->  
    <xsl:param name="number" select="number"/>  
      
    <!-- Именительный падеж (изображение) -->  
    <xsl:param name="nominative" select="nominative" />  
  
    <!-- Родительный падеж, единственное число (изображения) -->  
    <xsl:param name="genitive_singular" select="genitive_singular" />  
  
    <!-- Родительный падеж, множественное число (изображений) -->  
    <xsl:param name="genitive_plural" select="genitive_plural" />  

  
    <xsl:variable name="last_digit">  
       <xsl:value-of select="$number mod 10"/>  
    </xsl:variable>  
  
    <xsl:variable name="last_two_digits">  
       <xsl:value-of select="$number mod 100"/>  
    </xsl:variable>  
  
    <xsl:choose>  
       <xsl:when test="$last_digit = 1 and $last_two_digits != 11">  
          <xsl:value-of select="$nominative"/>  
       </xsl:when>  
       <xsl:when test="$last_digit = 2 and $last_two_digits != 12  
          or $last_digit = 3 and $last_two_digits != 13  
          or $last_digit = 4 and $last_two_digits != 14">  
          <xsl:value-of select="$genitive_singular"/>  
       </xsl:when>  
       <xsl:otherwise>  
          <xsl:value-of select="$genitive_plural"/>  
       </xsl:otherwise>  
    </xsl:choose>  
</xsl:template>  



<xsl:template name="nl2br">
    <xsl:param name="pText" select="."/>
    
    <xsl:choose>
        <xsl:when test="not(contains($pText, '&#xA;'))">
            <xsl:copy-of select="$pText"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="substring-before($pText, '&#xA;')"/>
            <br />
            <xsl:call-template name="nl2br">
                <xsl:with-param name="pText" select="substring-after($pText, '&#xA;')"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
    
</xsl:stylesheet>
