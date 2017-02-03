<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
<!ENTITY copy  "&#169;" >
<!ENTITY laquo  "&#171;" >
<!ENTITY raquo  "&#187;" >
]>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="utf-8"
        omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
        indent="yes" />

    <!-- FIXME: a hack -->
    <xsl:variable name="username">guest</xsl:variable>
    <xsl:variable name="ver">11</xsl:variable>
    <xsl:variable name="translate" select="/document/translates/translate" />

    <xsl:include href="../../transformers/document.xsl" />
    <xsl:include href="core/forms.xsl" />
    <xsl:include href="core/forms-short-view.xsl" />
    <xsl:include href="core/user.xsl" />
    <xsl:include href="core/translate.xsl" />
    <xsl:include href="blocks/include.xsl" />

    <xsl:template name="csslink">
        <link type="text/css" rel="stylesheet" href="striped/css/error.css" />
        <link type="text/css" rel="stylesheet" href="striped/css/forms.css" />
    </xsl:template>

    <xsl:template name="metas">
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <meta http-equiv="cache-control" content="public" />
        <meta name="charset" content="UTF-8" />
        <meta name="author" content="Constantine Nazarenko :::     http://nazarenko.me/" />
        <meta name="generator" content="Striped engine" />
        <meta name="robots" content="all" />
        <meta name="revisit-after" content="7 Days" />
    </xsl:template>

    <xsl:template name="jslink">
        <link rel="stylesheet" type="text/css" href="striped/css/js.css" />
        <link rel="stylesheet" type="text/css" href="striped/css/redmond/jquery-ui.custom.css" />

        <script type="text/javascript" src="striped/js/jquery.min.js"></script>
        <script type="text/javascript" src="striped/js/jquery-ui.custom.min.js"></script>
        <script type="text/javascript" src="striped/js/jquery.timers.js"></script>
        <script type="text/javascript" src="striped/js/jquery.easing.js"></script>
        <script type="text/javascript">
            var lang = '<xsl:value-of select="$lang" />';
            var server = '<xsl:value-of select="$server" />';
            var delete_confirm = '<xsl:call-template name="translate">
                            <xsl:with-param name="keyword">glb_delete_confirm</xsl:with-param>
                        </xsl:call-template>';
            var translate_wait = '<xsl:call-template name="translate">
                            <xsl:with-param name="keyword">GLOBAL_PLEASE_WAIT</xsl:with-param>
                        </xsl:call-template>';
            var translate_scroll_down = '<xsl:call-template name="translate">
                            <xsl:with-param name="keyword">COMMENTS_SCROLL_DOWN</xsl:with-param>
                        </xsl:call-template>';
            var translate_comments_delete = '<xsl:call-template name="translate">
                            <xsl:with-param name="keyword">COMMENTS_DELETE</xsl:with-param>
                        </xsl:call-template>';
            var translate_comments_restore = '<xsl:call-template name="translate">
                            <xsl:with-param name="keyword">COMMENTS_RESTORE</xsl:with-param>
                        </xsl:call-template>';
            var translate_are_you_sure_want = '<xsl:call-template name="translate">
                            <xsl:with-param name="keyword">GLOBAL_ARE_YOU_SURE_WANT</xsl:with-param>
                        </xsl:call-template>';
        </script>
    </xsl:template>

    <xsl:variable name="lang" select="/document/@lang" />
    <xsl:variable name="server" select="/document/@server" />

    <xsl:variable name="title">
        <xsl:value-of select="/document/error/type" />
        <xsl:text> (code: </xsl:text>
        <xsl:value-of select="/document/error/code" />
        <xsl:text>)</xsl:text>
    </xsl:variable>
    <xsl:variable name="base"><xsl:value-of select="/document/@base" /></xsl:variable>

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="document[@code]">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title><xsl:value-of select="$title" /></title>
                <base href="{$base}" />
                <xsl:call-template name="csslink" />
                <xsl:call-template name="jslink" />
            </head>
            <body>
                <xsl:apply-templates />
            </body>
        </html>
    </xsl:template>

    <xsl:template match="error">
        <h1><xsl:value-of select="$title" /></h1>
        <h2><xsl:value-of select="message" disable-output-escaping="yes" /></h2>
        <xsl:if test="/document/@debug">
            <xsl:choose>
                <xsl:when test="additionalData/item">
                    <dl>
                        <xsl:apply-templates select="additionalData/item" />
                    </dl>
                </xsl:when>
                <xsl:otherwise>
                    <p><xsl:value-of select="additionalData" /></p>
                </xsl:otherwise>
            </xsl:choose>
            <p>in file: <xsl:value-of select="file" />, on line: <xsl:value-of select="line" /></p>
            <fieldset>
                <legend>trace stack</legend>
                <textarea><xsl:value-of select="trace" disable-output-escaping="yes" /></textarea>
            </fieldset>
        </xsl:if>
    </xsl:template>

    <xsl:template match="document[@code='404']">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title><xsl:value-of select="$title" /></title>
                <base href="{$base}" />
                <xsl:call-template name="csslink" />
                <xsl:call-template name="jslink" />
            </head>
            <body>
                <xsl:apply-templates select="blocks/block[@name='root.menu']" />
                <xsl:apply-templates select="blocks/block[@name='lang_switcher']" />
                <xsl:apply-templates select="blocks/block[@name='header.menu']">
                    <xsl:with-param name="delimiter">|</xsl:with-param>
                </xsl:apply-templates>
                <h1>404</h1>
                <h2><xsl:value-of select="error/message" /></h2>
                <xsl:apply-templates select="blocks/block[@type='content']" />
                <xsl:apply-templates select="blocks/block[@name='footer.menu']">
                    <xsl:with-param name="delimiter">|</xsl:with-param>
                </xsl:apply-templates>
                <xsl:apply-templates select="pageinfo" />
                <xsl:apply-templates select="sqlinfo" />
            </body>
        </html>
    </xsl:template>

    <xsl:template match="document[@code='403']">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <title><xsl:value-of select="$title" /></title>
                <base href="{$base}" />
                <xsl:call-template name="csslink" />
                <xsl:call-template name="jslink" />
            </head>
            <body>
                <xsl:apply-templates select="blocks/block[@name='root.menu']" />
                <xsl:apply-templates select="blocks/block[@name='lang_switcher']" />
                <xsl:apply-templates select="blocks/block[@name='header.menu']">
                    <xsl:with-param name="delimiter">|</xsl:with-param>
                </xsl:apply-templates>
                <h1>403</h1>
                <h2><xsl:value-of select="error/message" /></h2>
                <xsl:apply-templates select="blocks/block[@type='content']" />
                <xsl:apply-templates select="blocks/block[@name='footer.menu']">
                    <xsl:with-param name="delimiter">|</xsl:with-param>
                </xsl:apply-templates>
                <xsl:apply-templates select="pageinfo" />
                <xsl:apply-templates select="sqlinfo" />
            </body>
        </html>
    </xsl:template>

    <xsl:template match="additionalData/item">
        <dt><xsl:value-of select="@name" /><xsl:text>:</xsl:text></dt>
        <dd>
            <xsl:choose>
                <xsl:when test="items/item">
                    <ul>
                        <xsl:apply-templates select="items/item" />
                    </ul>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()" />
                </xsl:otherwise>
            </xsl:choose>
        </dd>
    </xsl:template>

    <xsl:template match="items/item">
        <xsl:choose>
            <xsl:when test="items/item">
                <ul>
                    <xsl:apply-templates select="items/item" mode="additional" />
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <li><xsl:value-of select="text()" /><xsl:text>:</xsl:text></li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:include href="../../transformers/error.xsl" />

</xsl:stylesheet>