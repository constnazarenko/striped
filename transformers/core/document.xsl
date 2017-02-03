<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="site-title">
    <xsl:value-of select="/document/@site_title" />
</xsl:variable>

<xsl:variable name="page-title">
    <xsl:choose>
        <xsl:when test="/document/seo/page_title != /document/@page_title">
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="/document/seo/page_title" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="/document/@page_title" />
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="title">
    <xsl:apply-templates select="/document/blocks/block[@title]" mode="title" />

    <xsl:if test="$page-title != ''">
        <xsl:call-template name="translate">
            <xsl:with-param name="keyword" select="$page-title" />
        </xsl:call-template>
        <xsl:text> - </xsl:text>
    </xsl:if>
    <xsl:value-of select="$site-title" />
</xsl:variable>

<xsl:template match="block" mode="title">
    <xsl:value-of select="@title" />
    <xsl:text> — </xsl:text>
</xsl:template>

<xsl:variable name="page-keywords">
    <xsl:choose>
        <xsl:when test="/document/seo/page_keywords != /document/@page_keywords">
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="/document/seo/page_keywords" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="/document/@page_keywords" />
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="page-description">
    <xsl:choose>
        <xsl:when test="/document/seo/page_description != /document/@page_description">
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="/document/seo/page_description" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="/document/@page_description" />
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>

<xsl:variable name="base" select="/document/@base" />
<xsl:variable name="server" select="/document/@server" />
<xsl:variable name="requested_uri" select="/document/@requested_uri" />
<xsl:variable name="requested_get" select="/document/@requested_get" />
<xsl:variable name="current_url">
    <xsl:value-of select="$server" />
    <xsl:if test="$requested_uri != ''">
    	<xsl:value-of select="$requested_uri" />
    	<xsl:text>/</xsl:text>
    </xsl:if>
</xsl:variable>
<xsl:variable name="protocol" select="/document/@protocol" />
<xsl:variable name="domain" select="/document/@domain" />
<xsl:variable name="subdomain" select="/document/@subdomain" />
<xsl:variable name="lang" select="/document/@lang" />
<xsl:variable name="lang_url">
    <xsl:if test="/document/blocks/block[@name = 'lang_switcher']/languages/language and count(/document/blocks/block[@name = 'lang_switcher']/languages/language) > 1">
        <xsl:value-of select="$lang" />
        <xsl:text>/</xsl:text>
    </xsl:if>
</xsl:variable>
<xsl:variable name="time" select="/document/@time" />
<xsl:variable name="superuser" select="/document/userinfo/superuser" />
<xsl:variable name="actions" select="/document/userinfo/actions" />
<xsl:variable name="user_id" select="/document/userinfo/id" />
<xsl:variable name="logged" select="/document/userinfo/logged" />
<xsl:variable name="username" select="/document/userinfo/username" />
<xsl:variable name="translate" select="/document/translates/translate" />

<xsl:variable name="edit-mode-available" select="/document/@edit-mode-available" />

<xsl:template name="metas">
    <base href="{$base}" />
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta http-equiv="cache-control" content="public" />
    <meta http-equiv="content-language" content="{$lang}" />
    <meta name="charset" content="UTF-8" />
    <xsl:if test="$page-description != ''">
        <meta name="description" content="{$page-description}" />
    </xsl:if>
    <xsl:if test="$page-keywords != ''">
        <meta name="keywords" content="{$page-keywords}" />
    </xsl:if>
    <meta name="generator" content="Striped engine" />
    <meta name="robots" content="all" />
</xsl:template>

<xsl:template name="favicon">
    <link rel="icon" type="image/x-icon" href="{$base}favicon.ico?ver={$ver}" />
    <link rel="shortcut icon" type="image/x-icon" href="{$base}favicon.ico?ver={$ver}" />
    <link rel="shortcut icon" type="image/vnd.microsoft.icon" href="{$base}favicon.ico?ver={$ver}" />
</xsl:template>

<xsl:template name="csslink">
    <link rel="stylesheet" type="text/css" href="striped/css/global.css?ver={$ver}" />
    <link rel="stylesheet" type="text/css" href="css/system.global.css?ver={$ver}" />
    <xsl:if test="/document/blocks/block/formblock">
        <link rel="stylesheet" type="text/css" href="striped/css/forms.css?ver={$ver}" />
    </xsl:if>
    <xsl:if test="/document/blocks/@css">
        <link rel="stylesheet" type="text/css" href="{/document/blocks/@css}?ver={$ver}" />
    </xsl:if>
    <xsl:apply-templates select="/document/blocks/block[@css!='']" mode="css" />
    <xsl:apply-templates select="//csss/css[not(.=preceding::css)]" mode="css">
        <xsl:sort data-type="text" order="ascending" case-order="upper-first" />
    </xsl:apply-templates>
</xsl:template>
<xsl:template match="block" mode="css">
    <link rel="stylesheet" type="text/css" href="{@css}?ver={$ver}" />
</xsl:template>
<xsl:template match="css" mode="css">
    <link rel="stylesheet" type="text/css" href="{text()}?ver={$ver}" />
</xsl:template>

<xsl:template name="jslink">
    <link rel="stylesheet" type="text/css" href="striped/css/js.css?ver={$ver}" />
    <link rel="stylesheet" type="text/css" href="striped/css/redmond/jquery-ui.custom.css?ver={$ver}" />
    <link rel="stylesheet" type="text/css" href="striped/css/jquery.colorpicker.css?ver={$ver}" />
    
    <script type="text/javascript" src="striped/js/jquery.min.js?ver={$ver}"></script>
    <script type="text/javascript" src="striped/js/jquery-ui.custom.min.js?ver={$ver}"></script>
    <script type="text/javascript" src="striped/js/jquery-ui-timepicker-addon.js?ver={$ver}"></script>

    <script type="text/javascript" src="striped/js/colorpicker/jquery.colorpicker.js?ver={$ver}"></script>
    <script type="text/javascript" src="striped/js/colorpicker/i18n/jquery.ui.colorpicker-{$lang}.js?ver={$ver}"></script>

    <script type="text/javascript" src="striped/js/jquery.timers.js?ver={$ver}"></script>
    <script type="text/javascript" src="striped/js/jquery.easing.js?ver={$ver}"></script>
    <script type="text/javascript" src="striped/js/global.js?ver={$ver}"></script>
    <script type="text/javascript" src="striped/js/jquery.cookies.js?ver={$ver}"></script>
    <xsl:if test="$edit-mode-available">
        <script type="text/javascript" src="striped/js/editor.js?ver={$ver}"></script>
    </xsl:if>
    <script type="text/javascript">
        var lang = '<xsl:value-of select="$lang" />';
        var base = '<xsl:value-of select="$base" />';
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
        var translate_close_unsaved = '<xsl:call-template name="translate">
                        <xsl:with-param name="keyword">glb_close_unsaved</xsl:with-param>
                    </xsl:call-template>';
        var translate_changes_unsaved = '<xsl:call-template name="translate">
                        <xsl:with-param name="keyword">glb_changes_unsaved</xsl:with-param>
                    </xsl:call-template>';
    </script>
    <xsl:if test="/document/blocks/@js">
        <script type="text/javascript" src="{/document/blocks/@js}?ver={$ver}"></script>
    </xsl:if>
    <xsl:apply-templates select="/document/blocks/block[@js!='']" mode="js" />
    <xsl:apply-templates select="//jss/js[not(.=preceding::js)]" mode="js">
    	<xsl:sort data-type="text" order="ascending" case-order="upper-first" />
    </xsl:apply-templates>
</xsl:template>
<xsl:template match="block" mode="js">
    <script type="text/javascript" src="{@js}?ver={$ver}"></script>
</xsl:template>
<xsl:template match="js" mode="js">
    <script type="text/javascript" src="{text()}?ver={$ver}"></script>
</xsl:template>

<xsl:template match="/document">
    <html>
        <head>
            <xsl:call-template name="metas" />
            <title>
                <xsl:value-of select="$title" />
            </title>
            <xsl:call-template name="favicon" />
            <xsl:call-template name="csslink" />
            <xsl:call-template name="jslink" />
            <script type="text/javascript">
            	$(document).ready(function(){
            		$("form").submit(function(){
            			window.parent.$.fn.setFrameChanged(false);
            			window.onbeforeunload = null;
            		});
            		$("form input, form textarea").keypress(function(){
            			window.parent.$.fn.setFrameChanged(true);
            			window.onbeforeunload = function() {return translate_changes_unsaved;}
            		});
            		$("form checkbox, form radio, form select").change(function(){
            			window.parent.$.fn.setFrameChanged(true);
            			window.onbeforeunload = function() {return translate_changes_unsaved;}
            		});
	            });
	        </script>
        </head>
        <body>
            <div id="wrapper">
                <xsl:apply-templates select="blocks/block[@name='root.menu']" />
                <xsl:apply-templates select="blocks/block[@name='lang_switcher']" />
                <xsl:apply-templates select="blocks/block[@name='header.menu']">
                    <xsl:with-param name="delimiter">|</xsl:with-param>
                </xsl:apply-templates>
                <xsl:if test="$page-title != ''">
                    <h2><xsl:value-of select="$page-title" /></h2>
                </xsl:if>
                <xsl:apply-templates select="blocks/block[@type='content']" />
                <xsl:apply-templates select="blocks/block[@name='footer.menu']">
                    <xsl:with-param name="delimiter">|</xsl:with-param>
                </xsl:apply-templates>
                <xsl:comment> stats placeholder </xsl:comment>
                <xsl:apply-templates select="pageinfo" />
                <xsl:apply-templates select="sqlinfo" />
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template match="/document[@template='rss']">
    <rss version="2.0">
        <channel>
            <title><xsl:value-of select="$title" /></title>
            <link><xsl:value-of select="$base" /></link>
            <description><xsl:value-of select="$title" /></description>

            <xsl:apply-templates select="blocks/block[@type='content']" />
        </channel>
    </rss>
</xsl:template>

<xsl:template match="blocks">
    <xsl:apply-templates />
</xsl:template>

<xsl:template match="blocks/block[@name='auto']">
    <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]"/>
</xsl:template>

<xsl:template match="blocks/block[@name='html']">
    <xsl:value-of select="html" disable-output-escaping="yes" />
</xsl:template>

<xsl:template match="block">
    <div class="catcher">Catched block without template.<br/>Name: <xsl:value-of select="@name" />.<br/>Controller: <xsl:value-of select="@controller" />.<br/>Action: <xsl:value-of select="@action" />.</div>
</xsl:template>

</xsl:stylesheet>
