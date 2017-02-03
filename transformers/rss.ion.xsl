<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="utf-8"
        omit-xml-declaration="no"
        indent="no" />

    <!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/include.xsl ########## -->

<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/document.xsl ########## -->

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



<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/datetime.xsl ########## -->

<xsl:variable name="translates" select="/document/translates" />

<xsl:template name="human-from-dd-m-yyyy">
    <xsl:param name="dd-m-yyyy" />
    
    <xsl:value-of select="concat(substring-before($dd-m-yyyy, '.'), ' ', $translates/translate[@keyword='MONTH' and @ident=substring-before(substring-after($dd-m-yyyy, '.'), '.')], ' ', substring-after(substring-after($dd-m-yyyy, '.'), '.'))" />
</xsl:template>

<!-- ** Calculate UTC ISO8601 date and time from UNIX timestamp
     *
     * @param unix UNIX timestamp to convert
     * @return ISO formatted date in GMT/UTC
     * -->
<xsl:template name="human-from-unix">
    <xsl:param name="unix" />
    <xsl:param name="timezone">2</xsl:param>
    <xsl:param name="daylight" />
    <xsl:param name="time-only">0</xsl:param>
    <xsl:param name="date-only">0</xsl:param>
    <xsl:param name="gmt">0</xsl:param>
    
    <xsl:variable name="unix-local">
        <xsl:choose>
            <xsl:when test="$daylight != ''">
                <xsl:value-of select="$unix + (($timezone + $daylight) * 3600)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$unix + ($timezone * 3600)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Calculate number of leap years that have passed before the previous year -->
    <xsl:variable name="unix-numleapdays" select="floor(($unix-local - 94694400) div 126230400) + 1"/>
    
    <!-- Year, taking previous leap years into account but not taking into account that current year might be a leap year -->
    <xsl:variable name="year-temp" select="floor(($unix-local - $unix-numleapdays * 86400) div 31536000) + 1970" />
    
    <!-- Meaningless most of the time; on 31st December of a leap year, gives a value between 1 and 86399 indicating the
         number of seconds we are beyond a 365-day year; $year-temp above will incorrectly give the following year on
         31st December of leap years because the year has more than 31536000 seconds, so this is used as a correction
         factor -->
    <xsl:variable name="extra-seconds-this-year" select="$unix-local - $unix-numleapdays * 86400 - ($year-temp - 1970) * 31536000" />
    
    <xsl:variable name="year">
        <xsl:choose>
            <xsl:when test="($year-temp mod 4 = 1) and $extra-seconds-this-year > 0 and $extra-seconds-this-year &lt; 86400">
                <xsl:value-of select="$year-temp - 1" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$year-temp" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="hour" select="floor(($unix-local mod 86400) div 3600)" />
    <xsl:variable name="minute" select="floor(($unix-local mod 3600) div 60)" />
    <xsl:variable name="second" select="$unix-local mod 60" />
    
    <!-- The day of the year from 1-366, taking into account previous leap years -->
    <xsl:variable name="yday" select="floor(($unix-local - ($year - 1970)*31536000) div 86400) - $unix-numleapdays + 1" />
    
    <!-- The day of the year for the purposes of calculating a display month -->
    <!-- Shifts all leap year days from and including 29th February back one day
         so the normal month/date lookup tables can be used -->
    <xsl:variable name="yday-leap">
        <xsl:choose>
            <xsl:when test="$yday >= 60 and $year mod 4 = 0">
                <xsl:value-of select="$yday - 1" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$yday" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Work out month from leap-adjusted year day -->
    <xsl:variable name="month">
        <xsl:choose>
            <xsl:when test="$yday-leap &lt;= 31">1</xsl:when>
            <xsl:when test="$yday-leap &lt;= 59">2</xsl:when>
            <xsl:when test="$yday-leap &lt;= 90">3</xsl:when>
            <xsl:when test="$yday-leap &lt;= 120">4</xsl:when>
            <xsl:when test="$yday-leap &lt;= 151">5</xsl:when>
            <xsl:when test="$yday-leap &lt;= 181">6</xsl:when>
            <xsl:when test="$yday-leap &lt;= 212">7</xsl:when>
            <xsl:when test="$yday-leap &lt;= 243">8</xsl:when>
            <xsl:when test="$yday-leap &lt;= 273">9</xsl:when>
            <xsl:when test="$yday-leap &lt;= 304">10</xsl:when>
            <xsl:when test="$yday-leap &lt;= 334">11</xsl:when>
            <xsl:otherwise>12</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Lookup date from table; day 60 of leap years is 29th February -->
    <xsl:variable name="date">
        <xsl:choose>
            <xsl:when test="$yday != 60 or $year mod 4 != 0">
                <xsl:value-of select="$yday-leap - substring('000031059090120151181212243273304334', 3 * $month - 2, 3)" />
            </xsl:when>
            <xsl:otherwise>29</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="wday">
        <xsl:call-template name="day-of-week">
            <xsl:with-param name="year" select="$year" />
            <xsl:with-param name="month" select="$month" />
            <xsl:with-param name="date" select="$date" />
        </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="wday-gmt">
        <xsl:choose>
            <xsl:when test="$wday = 0">Sun</xsl:when>
            <xsl:when test="$wday = 1">Mon</xsl:when>
            <xsl:when test="$wday = 2">Tue</xsl:when>
            <xsl:when test="$wday = 3">Wed</xsl:when>
            <xsl:when test="$wday = 4">Thu</xsl:when>
            <xsl:when test="$wday = 5">Fri</xsl:when>
            <xsl:when test="$wday = 6">Sat</xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="month-gmt">
        <xsl:choose>
            <xsl:when test="$month = 1">Jan</xsl:when>
            <xsl:when test="$month = 2">Feb</xsl:when>
            <xsl:when test="$month = 3">Mar</xsl:when>
            <xsl:when test="$month = 4">Apr</xsl:when>
            <xsl:when test="$month = 5">May</xsl:when>
            <xsl:when test="$month = 6">Jun</xsl:when>
            <xsl:when test="$month = 7">Jul</xsl:when>
            <xsl:when test="$month = 8">Aug</xsl:when>
            <xsl:when test="$month = 9">Sep</xsl:when>
            <xsl:when test="$month = 10">Oct</xsl:when>
            <xsl:when test="$month = 11">Nov</xsl:when>
            <xsl:when test="$month = 12">Dec</xsl:when>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="daylight-check">
       <xsl:if test="$daylight = ''">
            <xsl:call-template name="daylight-offset">
                <xsl:with-param name="year" select="$year" />
                <xsl:with-param name="month" select="$month" />
                <xsl:with-param name="date" select="$date" />
                <xsl:with-param name="hour" select="$hour" />
                <xsl:with-param name="timezone" select="$timezone" />
            </xsl:call-template>
        </xsl:if>
    </xsl:variable>
   
    <xsl:choose>
        <xsl:when test="$daylight-check = 1">
            <xsl:call-template name="human-from-unix">
                <xsl:with-param name="unix" select="$unix" />
                <xsl:with-param name="timezone" select="$timezone" />
                <xsl:with-param name="daylight" select="$daylight-check" />
                <xsl:with-param name="date-only" select="$date-only" />
                <xsl:with-param name="time-only" select="$time-only" />
                <xsl:with-param name="gmt" select="$gmt" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$gmt = 1">
                    <xsl:value-of select="concat($wday-gmt, ', ', format-number($date, '00'), ' ', $month-gmt, ' ', $year, ' ', format-number($hour, '00'), ':', format-number($minute, '00'), ':', format-number($second, '00'), ' GMT')" />
                </xsl:when>
                <xsl:when test="$date-only = 1">
                    <xsl:value-of select="concat($date, ' ', $translates/translate[@keyword='MONTH' and @ident=$month], ' ', $year)" />
                </xsl:when>
                <xsl:when test="$time-only = 1">
                    <xsl:value-of select="concat(format-number($hour, '00'), ':', format-number($minute, '00'))" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($date, ' ', $translates/translate[@keyword='MONTH' and @ident=$month], ' ', $year, ', ', format-number($hour, '00'), ':', format-number($minute, '00'))" />
                </xsl:otherwise>
            </xsl:choose>
                
        </xsl:otherwise>
    </xsl:choose>
    
</xsl:template>


<!-- ** Finds out if there needed daylight offset 
     * -->
<xsl:template name="daylight-offset">
    <xsl:param name="year" />
    <xsl:param name="month" />
    <xsl:param name="date" />
    <xsl:param name="hour" />
    <xsl:param name="timezone" />
    <xsl:param name="rules">eu</xsl:param>
    
    <xsl:choose>
        <!-- EU DST: last Sunday in March 1am UTC to the last Sunday in October 1am UTC -->
        <!-- http://webexhibits.org/daylightsaving/g.html -->
        <xsl:when test="$rules='eu'">

            <xsl:variable name="lastSundayInMarch">
                <xsl:call-template name="date-of-last-day">
                    <xsl:with-param name="lastOfMonthDay">
                        <xsl:call-template name="day-of-week">
                            <xsl:with-param name="year" select="$year" />
                            <xsl:with-param name="month">3</xsl:with-param>
                            <xsl:with-param name="date">31</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="wantedDay">0</xsl:with-param>
                    <xsl:with-param name="daysInMonth">31</xsl:with-param>
                </xsl:call-template>
            </xsl:variable>

            <xsl:variable name="lastSundayInOctober">
                <xsl:call-template name="date-of-last-day">
                    <xsl:with-param name="lastOfMonthDay">
                        <xsl:call-template name="day-of-week">
                            <xsl:with-param name="year" select="$year" />
                            <xsl:with-param name="month">10</xsl:with-param>
                            <xsl:with-param name="date">31</xsl:with-param>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="wantedDay">0</xsl:with-param>
                    <xsl:with-param name="daysInMonth">31</xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="($month >= 4 and $month &lt;= 9) or
                    ($month = 3 and $date > $lastSundayInMarch) or
                    ($month = 3 and $date = $lastSundayInMarch and $hour - substring($timezone, 2, 2) >= 1) or
                    ($month = 10 and $date &lt; $lastSundayInOctober) or
                    ($month = 10 and $date = $lastSundayInOctober and $hour - substring($timezone, 2, 2) &lt; 1)">
                    <xsl:text>1</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:when>
    </xsl:choose>

</xsl:template>


<!-- ** Calculate day of the week from date/month/year
     *
     * Adapted from XSLT Cookbook, pg. 77
     *
     * @param year 4-digit year number
     * @param month Month in the year (1-12)
     * @param date Date in the month
     * @return Integer from 0-6 representing the day of the week (0 = Sunday)
     * -->
<xsl:template name="day-of-week">
    <xsl:param name="year" />
    <xsl:param name="month" />
    <xsl:param name="date" />
    
    <xsl:variable name="a" select="floor((14 - $month) div 12)" />
    <xsl:variable name="y" select="$year - $a" />
    <xsl:variable name="m" select="$month + 12 * $a - 2" />
    
    <xsl:value-of select="($date + $y + floor($y div 4) - floor($y div 100) + floor($y div 400) + floor((31 * $m) div 12)) mod 7" />
</xsl:template>


<!-- ** Calculate date of last weekday in month (0=Sunday) when the last of the month is day x (0=Sunday)
     *
     * @param lastOfMonthDay The day (0-6 where 0 = Sunday) of the last date of the month
     * @param wantedDay The date for which to calculate the weekday (must be in the last 7 days of the month)
     * @return The day (0-6 where 0 = Sunday) of the date specified in $wantedDay
     * -->
<xsl:template name="date-of-last-day">
    <xsl:param name="lastOfMonthDay" />
    <xsl:param name="wantedDay" />
    <xsl:param name="daysInMonth" />
    
    <xsl:value-of select="$daysInMonth - ((($lastOfMonthDay - $wantedDay) + 7) mod 7)" />
</xsl:template>


<xsl:template name="day-of-month">
    <xsl:param name="unix" />
    
    <!-- Calculate number of leap years that have passed before the previous year -->
    <xsl:variable name="unix-numleapdays" select="floor(($unix - 94694400) div 126230400) + 1"/>
    
    <!-- Year, taking previous leap years into account but not taking into account that current year might be a leap year -->
    <xsl:variable name="year-temp" select="floor(($unix - $unix-numleapdays * 86400) div 31536000) + 1970" />
    
    <!-- Meaningless most of the time; on 31st December of a leap year, gives a value between 1 and 86399 indicating the
         number of seconds we are beyond a 365-day year; $year-temp above will incorrectly give the following year on
         31st December of leap years because the year has more than 31536000 seconds, so this is used as a correction
         factor -->
    <xsl:variable name="extra-seconds-this-year" select="$unix - $unix-numleapdays * 86400 - ($year-temp - 1970) * 31536000" />
    
    <xsl:variable name="year">
        <xsl:choose>
            <xsl:when test="($year-temp mod 4 = 1) and $extra-seconds-this-year > 0 and $extra-seconds-this-year &lt; 86400">
                <xsl:value-of select="$year-temp - 1" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$year-temp" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="hour" select="floor(($unix mod 86400) div 3600)+3" />
    <xsl:variable name="minute" select="floor(($unix mod 3600) div 60)" />
    <xsl:variable name="second" select="$unix mod 60" />
    
    <!-- The day of the year from 1-366, taking into account previous leap years -->
    <xsl:variable name="yday" select="floor(($unix - ($year - 1970)*31536000) div 86400) - $unix-numleapdays + 1" />
    
    <!-- The day of the year for the purposes of calculating a display month -->
    <!-- Shifts all leap year days from and including 29th February back one day
         so the normal month/date lookup tables can be used -->
    <xsl:variable name="yday-leap">
        <xsl:choose>
            <xsl:when test="$yday >= 60 and $year mod 4 = 0">
                <xsl:value-of select="$yday - 1" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$yday" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Work out month from leap-adjusted year day -->
    <xsl:variable name="month">
        <xsl:choose>
            <xsl:when test="$yday-leap &lt;= 31">1</xsl:when>
            <xsl:when test="$yday-leap &lt;= 59">2</xsl:when>
            <xsl:when test="$yday-leap &lt;= 90">3</xsl:when>
            <xsl:when test="$yday-leap &lt;= 120">4</xsl:when>
            <xsl:when test="$yday-leap &lt;= 151">5</xsl:when>
            <xsl:when test="$yday-leap &lt;= 181">6</xsl:when>
            <xsl:when test="$yday-leap &lt;= 212">7</xsl:when>
            <xsl:when test="$yday-leap &lt;= 243">8</xsl:when>
            <xsl:when test="$yday-leap &lt;= 273">9</xsl:when>
            <xsl:when test="$yday-leap &lt;= 304">10</xsl:when>
            <xsl:when test="$yday-leap &lt;= 334">11</xsl:when>
            <xsl:otherwise>12</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- Lookup date from table; day 60 of leap years is 29th February -->
    <xsl:variable name="date">
        <xsl:choose>
            <xsl:when test="$yday != 60 or $year mod 4 != 0">
                <xsl:value-of select="$yday-leap - substring('000031059090120151181212243273304334', 3 * $month - 2, 3)" />
            </xsl:when>
            <xsl:otherwise>29</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="$date" />
</xsl:template>


<xsl:template name="seconds-to-minutes">
    <xsl:param name="time" />

    <xsl:variable name="minutes" select="floor($time div 60)" />
    <xsl:variable name="seconds" select="$time mod 60" />

    <xsl:value-of select="format-number($minutes, '00')" />:<xsl:value-of select="format-number($seconds, '00')" />
</xsl:template>
    

<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/forms.xsl ########## -->

<xsl:template match="formblock">
    <xsl:apply-templates select="form" />
</xsl:template>

<!-- FROM OUTPUT -->
<xsl:template match="form">
    <xsl:if test="@title != ''">
        <h2>
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="@title" />
            </xsl:call-template>
        </h2>
    </xsl:if>

    <div class="form-wrapper">
        <xsl:choose>
            <xsl:when test="@ajax = 'validate'">
                <xsl:attribute name="class">form-wrapper validate</xsl:attribute>
            </xsl:when>
            <xsl:when test="@ajax = 'ajax'">
                <xsl:attribute name="class">form-wrapper ajax</xsl:attribute>
            </xsl:when>
            <xsl:when test="@ajax = 'textmode'">
                <xsl:attribute name="class">form-wrapper textmode</xsl:attribute>
            </xsl:when>
            <xsl:when test="@ajax = 'ajax-w-v'">
                <xsl:attribute name="class">form-wrapper ajax-w-v</xsl:attribute>
            </xsl:when>
            <xsl:when test="@ajax = 'textmode-w-v'">
                <xsl:attribute name="class">form-wrapper textmode-w-v</xsl:attribute>
            </xsl:when>
        </xsl:choose>

        <fieldset>
            <xsl:if test="@label != ''">
                <legend>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword" select="@label" />
                    </xsl:call-template>
                </legend>
            </xsl:if>

            <xsl:if test="../errors/error and count(../formdata/fieldgroup) > 1">
                <div class="warning">
                    <ul><li><strong>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">frm_errs_warn</xsl:with-param>
                    </xsl:call-template>
                    </strong></li></ul>
                </div>
            </xsl:if>

            <form method="{@method}" name="{@name}">
                <xsl:attribute name="action">
                    <xsl:if test="@local=1"><xsl:value-of select="$server" /></xsl:if>
                    <xsl:value-of select="@action" />
                </xsl:attribute>
                <xsl:if test="fieldgroup/field[@chosen]">
                    <xsl:attribute name="class">chosenFORM</xsl:attribute>
                </xsl:if>

                <xsl:if test="@enctype != ''">
                    <xsl:attribute name="enctype"><xsl:value-of select="@enctype" /></xsl:attribute>
                </xsl:if>
                <xsl:if test="@reload = '1'">
                    <xsl:attribute name="class">reload</xsl:attribute>
                </xsl:if>

                <input type="hidden" name="formname" value="{@name}" />
                <xsl:if test="../@action">
                    <input type="hidden" name="action" value="{../@action}" />
                </xsl:if>


                <xsl:choose>
                    <xsl:when test="count(../formdata/fieldgroup) > 0">
                        <xsl:variable name="this" select="."/>
                        <xsl:for-each select="../formdata/fieldgroup">
                            <xsl:apply-templates select="$this/fieldgroup">
                                <xsl:with-param name="thisname" select="@name"/>
                            </xsl:apply-templates>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="fieldgroup"/>
                    </xsl:otherwise>
                </xsl:choose>

            </form>
        </fieldset>
    </div>
</xsl:template>



<xsl:template match="fieldgroup">
    <xsl:param name="thisname" select="@name" />

    <xsl:variable name="formdata" select="../../formdata" />
    <xsl:variable name="confirms" select="../../confirms" />
    <xsl:variable name="errors" select="../../errors" />
    <xsl:variable name="this" select="." />

    <xsl:if test="$confirms/confirm[@group=$thisname]">
        <div class="confirm">
            <ul>
                <xsl:apply-templates select="$confirms/confirm[@group=$thisname]" />
            </ul>
        </div>
    </xsl:if>

    <xsl:if test="$errors/error[@group=$thisname]">
        <div class="error">
            <ul>
                <xsl:apply-templates select="$errors/error[@group=$thisname]" />
            </ul>
        </div>
    </xsl:if>

    <div id="{@name}_response" class="form-response"></div>
    <input type="hidden" name="group[{$thisname}]" value="{$thisname}" />
    <xsl:apply-templates select="field">
        <xsl:with-param name="group" select="$thisname" />
        <xsl:with-param name="js-validate">
            <xsl:choose>
                <xsl:when test="../../form/@ajax = 'validate' or ../../form/@ajax = 'ajax' or ../../form/@ajax = 'textmode'">1</xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:with-param>
    </xsl:apply-templates>

</xsl:template>



<xsl:template match="errors/error">
    <li><xsl:value-of select="message" disable-output-escaping="yes" /></li>
</xsl:template>



<xsl:template match="confirms/confirm">
    <li><xsl:value-of select="text()" disable-output-escaping="yes" /></li>
</xsl:template>



<xsl:template match="field">
    <xsl:param name="group" />
    <xsl:param name="js-validate">0</xsl:param>

    <xsl:variable name="formdata" select="../../../formdata" />
    <xsl:variable name="confirms" select="../../../confirms" />
    <xsl:variable name="errors" select="../../../errors" />
    <xsl:variable name="multioptions" select="../../../multioptions" />
    <xsl:variable name="this" select="." />

    <xsl:choose>

        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -        HIDDEN       - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'hidden'">
            <input type="{@type}" name="{@name}[{$group}]" class="{@type} {@class}">
                <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                    <xsl:attribute name="value"><xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" /></xsl:attribute>
                </xsl:if>
            </input>
        </xsl:when>

        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -      DELIMITER      - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'delimiter'">
            <div class="field delimiter {@class}">
                <xsl:if test="title != '' and not(@value_as_title)">
                    <strong>
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                    </strong>
                </xsl:if>
                <xsl:if test="@value_as_title = 1">
                    <strong>
                        <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                            <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" disable-output-escaping="yes" />
                        </xsl:if>
                    </strong>
                </xsl:if>
                <xsl:if test="description != ''">
                    <div class="description">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="description" />
                        </xsl:call-template>
                    </div>
                </xsl:if>
                <div class="clear"></div>
            </div>
        </xsl:when>
        
        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -        IMAGE        - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'image'">
            <div class="field image {@class}">
                <img>
                    <xsl:attribute name="src">
                        <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                            <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" />
                        </xsl:if>
                    </xsl:attribute>
                </img>
                <div class="clear"></div>
            </div>
        </xsl:when>
        
        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -         TEXT        - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'text' or @type = 'password' or @type = 'color' or @type = 'date' or @type = 'datetime'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <div class="inputer">
                        <xsl:if test="@multiple = '1'">
                            <xsl:attribute name="class">inputer hiddenfield</xsl:attribute>
                        </xsl:if>
                        <input type="{@type}" name="{@name}[{$group}]" id="{@name}-{$group}" class="text {@class}">
                            <xsl:if test="@disabled = 1">
                                <xsl:attribute name="disabled" />
                            </xsl:if>
                            <xsl:if test="not(@type = 'text' or @type = 'password')">
                                <xsl:attribute name="type">text</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="@required = 1 and $js-validate = 1">
                                <xsl:attribute name="class">text required</xsl:attribute>
                            </xsl:if>
                            <xsl:if test="patterns/pattern and $js-validate = 1">
                                <xsl:apply-templates select="patterns/pattern" />
                            </xsl:if>
                            <xsl:attribute name="value">
                                <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                                    <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" />
                                </xsl:if>
                            </xsl:attribute>
                        </input>
                    </div>
                    <xsl:if test="@multiple = '1' and $formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                        <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                            <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="multi-input">
                                <xsl:with-param name="metanode" select="current()" />
                                <xsl:with-param name="group" select="$group" />
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="$js-validate = 1 or @type = 'color' or @type = 'date' or @type = 'datetime' or @autocomplete != ''">
                        <script type="text/javascript">
                            <xsl:text>$(document).ready(function(){</xsl:text>
                                <xsl:if test="@type = 'date' or @type = 'datetime'">
                                    <xsl:variable name="dt-control">
                                        <xsl:text>date</xsl:text>
                                        <xsl:if test="@type = 'datetime'">
                                            <xsl:text>time</xsl:text>
                                        </xsl:if>
                                        <xsl:text>picker</xsl:text>
                                    </xsl:variable>
                                    <xsl:variable name="dt-format">
                                        <xsl:choose>
                                            <xsl:when test="@format">
                                                <xsl:text>dateFormat: '</xsl:text><xsl:value-of select="@format" /><xsl:text>'</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>dateFormat: 'yy-mm-dd'</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="@type = 'datetime'">
                                            <xsl:choose>
                                                <xsl:when test="@timeformat">
                                                    <xsl:text>, timeFormat: '</xsl:text><xsl:value-of select="@timeformat" /><xsl:text>'</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text>, timeFormat: 'HH:mm'</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                    </xsl:variable>
                                    <xsl:text>$("#</xsl:text><xsl:value-of select="@name" />-<xsl:value-of select="$group" /><xsl:text>").</xsl:text><xsl:value-of select="$dt-control" /><xsl:text>({</xsl:text><xsl:value-of select="$dt-format" /><xsl:text>});</xsl:text>
                                </xsl:if>

                                <xsl:if test="@type = 'color'">
                                    <xsl:text>$("#</xsl:text><xsl:value-of select="@name" />-<xsl:value-of select="$group" /><xsl:text>").colorpicker({
                                        parts:          ['map', 'bar', 'hex', 'hsv', 'rgb', 'alpha', 'lab', 'cmyk', 'preview', 'swatches'],
                                        /*colorFormat:  'RGBA',*/
                                        alpha:          false,
                                        showOn:         'both',
                                        regional:       '</xsl:text><xsl:value-of select="$lang" /><xsl:text>',
                                        buttonColorize: true,
                                        showNoneButton: false,
                                        okOnEnter: true,
                                        altField: "#</xsl:text><xsl:value-of select="@name" />-<xsl:value-of select="$group" /><xsl:text>",
                                        altProperties: 'border-color,color',
                                        altAlpha: true
                                    });</xsl:text>
                                </xsl:if>
                                
                                <xsl:if test="$js-validate = 1">
                                    <xsl:if test="@required = 1">
                                        <xsl:text>$.validator.messages.required</xsl:text>
                                        <xsl:text> = jQuery.format('</xsl:text>
                                        <xsl:call-template name="translate">
                                            <xsl:with-param name="keyword">frm_err_required_AJAX</xsl:with-param>
                                        </xsl:call-template>
                                        <xsl:text>');</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="patterns/pattern">
                                        <xsl:apply-templates select="patterns/pattern" mode="messages" />
                                    </xsl:if>
                                </xsl:if>
                                
                                <xsl:if test="@autocomplete != ''">
                                    <xsl:text>$('#</xsl:text><xsl:value-of select="@name" />-<xsl:value-of select="$group" /><xsl:text>').autocomplete({ </xsl:text>
                                        <xsl:text>serviceUrl:'</xsl:text><xsl:value-of select="@autocomplete" /><xsl:text>',</xsl:text>
                                        <xsl:text>minChars:1,</xsl:text>
                                        <xsl:choose>
                                            <xsl:when test="@ac_delimiter">
                                                <xsl:text>delimiter: /(</xsl:text><xsl:value-of select="@ac_delimiter" /><xsl:text>)\s*/,</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>delimiter: /( |,|;)\s*/,</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text>maxHeight:190</xsl:text>
                                        <xsl:if test="@cyr2lat = 1">
                                            <xsl:text>, cyr2lat: true</xsl:text>
                                        </xsl:if>
                                    <xsl:text>});</xsl:text>
                                </xsl:if>
                            <xsl:text>});</xsl:text>
                        </script>
                    </xsl:if>
                    
                    <xsl:if test="@multiple = 1 and not(@disabled) and not(@stable_amount)">
                        <a href="javascript:void(0);" class="multifield">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword">frm_multifields</xsl:with-param>
                            </xsl:call-template>
                        </a>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>
        
        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -         LIST        - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'list'">
            <div class="field">
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="list">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -       CAPTCHA       - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'captcha'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <div style="width: 200px; height: 70px;"><img src="{$base}captcha" id='captcha'/></div>
                    <input type="{@type}" name="{@name}[{$group}]" id="{@name}" class="text captcha">
                        <xsl:attribute name="class">text required</xsl:attribute>
                        <xsl:attribute name="value">
                            <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                                <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" />
                            </xsl:if>
                        </xsl:attribute>
                    </input>
                    <xsl:if test="$js-validate = 1">
                        <script type="text/javascript">
                            <xsl:text>$.validator.messages.required</xsl:text>
                            <xsl:text> = jQuery.format('</xsl:text>
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword">frm_err_required_AJAX</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>');</xsl:text>

                            <xsl:text>
                            $(document).ready(function(){
                                chk = false;
                                $.validator.addMethod("captcha", function(value, element) {
                                    $.ajax({
                                        type: "POST",
                                        url: "captcha/validate",
                                        data: "code="+value,
                                        dataType:"html",
                                        async: false,
                                        cache: false,
                                        timeout: 30000
                                    }).done(function(data) {
                                        chk = data;
                                    });
                                    if (chk != 'true') {
                                    	$("#captcha").attr('src', '</xsl:text><xsl:value-of select="$base"/><xsl:text>captcha?'+Math.random())
                                    }
                                    return chk == 'true'? true : false;
                                    
                                }, "</xsl:text><xsl:call-template name="translate">
                                <xsl:with-param name="keyword">frm_err_captcha</xsl:with-param>
                            </xsl:call-template><xsl:text>");
                                
                                jQuery.validator.addClassRules({
                                    captcha : { captcha : true }
                                });
                            
                            });
                            </xsl:text>

                        </script>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -         FILE        - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'file'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    
                    <xsl:choose>
                        <xsl:when test="@set=1">
                        
                            <xsl:for-each select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value/field">
    
                                <div class="thumb killme">
                                    <xsl:for-each select="$this/files/file">
                                        <xsl:if test="@id = xml/file[@size = current()/@id]/@size">
                                            <a href="{xml/file[@size = current()/@id]}" class="">
                                                <xsl:value-of select="@id"/>
                                            </a>
                                        </xsl:if>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                    <xsl:text> | </xsl:text>
                                    <a href="{$server}portfolio/delete-photo/{photos_id}" class="overphotokill overkill">
                                        <span>
                                        <xsl:call-template name="translate">
                                            <xsl:with-param name="keyword">glb_delete</xsl:with-param>
                                        </xsl:call-template>
                                        </span>
                                    </a>
                                </div>
    
                            </xsl:for-each>
                            
                        </xsl:when>
                        <xsl:otherwise>
                        
                            <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value != ''">
                                <xsl:choose>
                                    <xsl:when test="@aslink = 1">
                                        <div class="image-container">
                                            <a href="{$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value}" target="_blank">
                                                <xsl:call-template name="translate">
                                                    <xsl:with-param name="keyword">frm_link</xsl:with-param>
                                                </xsl:call-template>
                                            </a>
                                        </div>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <div class="image-container">
                                            <img src="{$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value}" alt="" />
                                        </div>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                        
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <div class="file-input">
                        <xsl:choose>
                            <xsl:when test="@set=1 and @multiple=1">
                                <xsl:choose>
                                    <xsl:when test="@names = 1">
                                        <xsl:attribute name="class">file-input file-set hiddenfield with-names</xsl:attribute>
                                        <input type="text" name="{@name}[{$group}]" class="text" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">file-input file-set hiddenfield</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="@multiple=1">
                                <xsl:choose>
                                    <xsl:when test="@names = 1">
                                        <xsl:attribute name="class">file-input hiddenfield with-names</xsl:attribute>
                                        <input type="text" name="{@name}[{$group}]" class="text" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">file-input hiddenfield</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="@names = 1">
                                <input type="text" name="{@name}_title[{$group}]" class="text"/>
                            </xsl:when>
                        </xsl:choose>

                        <xsl:choose>
                            <xsl:when test="@set = 1">
                                <xsl:for-each select="files/file">
                                    <br />
                                    <xsl:call-template name="translate">
                                        <xsl:with-param name="keyword" select="text()" />
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <input type="file" name="{../../@name}[{@id}]" class="file" />
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <input type="{@type}" name="{@name}[{$group}]" class="{@type}" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    
                    <xsl:if test="@multiple = 1">
                        <a href="javascript:void(0);" class="multifile">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword">frm_multifiles</xsl:with-param>
                            </xsl:call-template>
                        </a>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -      TEXTAREA       - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'textarea'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <textarea name="{@name}[{$group}]" id="{@name}" class="{@type} {@class}">
                        <xsl:if test="@disabled = 1">
                            <xsl:attribute name="disabled" />
                        </xsl:if>
                        <xsl:if test="@height">
                            <xsl:attribute name="style">
                                <xsl:text>height: </xsl:text><xsl:value-of select="@height" /><xsl:text>px;</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@required = 1 and $js-validate = 1">
                            <xsl:attribute name="class"><xsl:value-of select="@type" /><xsl:text> </xsl:text><xsl:value-of select="@class" /><xsl:text> </xsl:text>required</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@wysiwyg != '' and @wysiwyg != 0">
                            <xsl:attribute name="class">
                                <xsl:value-of select="@type" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="@class" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="@wysiwyg" />
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="patterns/pattern and $js-validate = 1">
                            <xsl:apply-templates select="patterns/pattern" />
                        </xsl:if>
                        <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                            <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" />
                        </xsl:if>
                    </textarea>
                    <xsl:if test="$js-validate = 1">
                        <script type="text/javascript">
                            <xsl:if test="@required = 1">
                                <xsl:text>$.validator.messages.required</xsl:text>
                                <xsl:text> = jQuery.format('</xsl:text>
                                <xsl:call-template name="translate">
                                    <xsl:with-param name="keyword">frm_err_required_AJAX</xsl:with-param>
                                </xsl:call-template>
                                <xsl:text>');</xsl:text>
                            </xsl:if>
                            <xsl:if test="patterns/pattern">
                                <xsl:apply-templates select="patterns/pattern" mode="messages" />
                            </xsl:if>
                        </script>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -        SELECT       - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type='select'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <select name="{@name}[{$group}]" id="{@name}-{$group}" class="{@type}">
                        <xsl:if test="@disabled = 1">
                            <xsl:attribute name="disabled" />
                        </xsl:if>
                        <xsl:if test="@multiple = 1">
                            <xsl:attribute name="multiple" />
                            <xsl:attribute name="name"><xsl:value-of select="@name"/>[<xsl:value-of select="$group"/>][]</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@height != ''">
                            <xsl:attribute name="style">height: <xsl:value-of select="@height" />px;</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@required = 1 and $js-validate = 1">
                            <xsl:attribute name="class"><xsl:value-of select="@type" /> required</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@chosen = 1">
                            <xsl:attribute name="class"><xsl:value-of select="@type" /><xsl:text> chosen-select</xsl:text><xsl:if test="@required = 1 and $js-validate = 1"> required</xsl:if></xsl:attribute>
                        </xsl:if>
                        <xsl:if test="patterns/pattern and $js-validate = 1">
                            <xsl:apply-templates select="patterns/pattern" />
                        </xsl:if>
                        <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                            <xsl:choose>
                                <xsl:when test="@i18n = 1">
                                    <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options[@lang=$lang]/option" mode="select" />
                                    <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options[@lang=$lang]/optgroup" mode="select" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="select" />
                                    <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="select" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </select>
                    <xsl:if test="@chosen = 1">
                        <script type="text/javascript">
                            jQuery(function($) {
                                <xsl:if test="@multiple = 1">
                                var order = [
                                <xsl:for-each select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option[@checked or @value = ../../value]">
                                    <xsl:sort select="@weight"/>
                                    <xsl:text>'</xsl:text><xsl:value-of select="@value" /><xsl:text>'</xsl:text>
                                    <xsl:if test="position()!=last()">,</xsl:if>
                                </xsl:for-each>
                                ];
                                </xsl:if>
                                <xsl:text>$("#</xsl:text><xsl:value-of select="@name" />-<xsl:value-of select="$group" /><xsl:text>").chosen({width:"95%"})</xsl:text><xsl:if test="@multiple = 1">.setSelectionOrder(order)</xsl:if><xsl:text>;</xsl:text>


                            });
                        </script>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>
        
        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -    AMOUNT-SELECT    - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'amount-select'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                
                    <xsl:choose>
                        <xsl:when test="@multiple=1 and $multioptions/group[@name=$group]/field[@name=current()/@name]">
                        
                            <div class="amount-select with-names hiddenfield">
                                <input type="text" name="{@name}[{$group}]" class="microtext" value="" />
                                
                                <select name="{@name}[{$group}]" id="{@name}" class="{@type}">
                                    <xsl:if test="@disabled = 1">
                                        <xsl:attribute name="disabled" />
                                    </xsl:if>
                                    <xsl:if test="@required = 1 and $js-validate = 1">
                                        <xsl:attribute name="class"><xsl:value-of select="@type" /> required</xsl:attribute>
                                    </xsl:if>
                                    <xsl:if test="patterns/pattern and $js-validate = 1">
                                        <xsl:apply-templates select="patterns/pattern" />
                                    </xsl:if>
                                    
                                    <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="select" />
                                    <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="select" />
                                </select>
                            </div>
                    
                            <xsl:for-each select="$multioptions/group[@name=$group]/field[@name=current()/@name]">
                                <div class="amount-select">
                                    <input type="text" name="{@name}[{$group}][{position()-1}][amount]" class="microtext" value="{@amount}" />
                                    
                                    <select name="{@name}[{$group}][{position()-1}][value]" id="{@name}" class="{@type}">
                                        <xsl:if test="@disabled = 1">
                                            <xsl:attribute name="disabled" />
                                        </xsl:if>
                                        <xsl:if test="@multiple = 1">
                                            <xsl:attribute name="name"><xsl:value-of select="@name" />[<xsl:value-of select="$group" />]</xsl:attribute>
                                        </xsl:if>
                                        <xsl:if test="@required = 1 and $js-validate = 1">
                                            <xsl:attribute name="class"><xsl:value-of select="@type" /> required</xsl:attribute>
                                        </xsl:if>
                                        <xsl:if test="patterns/pattern and $js-validate = 1">
                                            <xsl:apply-templates select="patterns/pattern" />
                                        </xsl:if>
                                        
                                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="select">
                                            <xsl:with-param name="selected" select="@value" />
                                        </xsl:apply-templates>
                                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="select">
                                            <xsl:with-param name="selected" select="@value" />
                                        </xsl:apply-templates>
                                    </select>
                                    <a class="multifilekill">remove</a>
                                </div>
                            </xsl:for-each>
                    
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="amount-select with-names">
                                <xsl:choose>
                                    <xsl:when test="@multiple=1">
                                        <xsl:attribute name="class">amount-select hiddenfield with-names</xsl:attribute>
                                        <input type="text" name="{@name}[{$group}]" class="microtext" value="" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <input type="text" name="{@name}[{$group}][amount]" class="microtext"/>                                    
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                                <select name="{@name}[{$group}][value]" id="{@name}" class="{@type}">
                                    <xsl:if test="@disabled = 1">
                                        <xsl:attribute name="disabled" />
                                    </xsl:if>
                                    <xsl:if test="@multiple = 1">
                                        <xsl:attribute name="name"><xsl:value-of select="@name" />[<xsl:value-of select="$group" />]</xsl:attribute>
                                    </xsl:if>
                                    <xsl:if test="@required = 1 and $js-validate = 1">
                                        <xsl:attribute name="class"><xsl:value-of select="@type" /> required</xsl:attribute>
                                    </xsl:if>
                                    <xsl:if test="patterns/pattern and $js-validate = 1">
                                        <xsl:apply-templates select="patterns/pattern" />
                                    </xsl:if>
                                    
                                    <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="select" />
                                    <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="select" />
                                </select>
                            </div>
                        </xsl:otherwise>                        
                    </xsl:choose>
                    
                    <xsl:if test="@multiple = 1">
                        <a href="javascript:void(0);" class="multiamountselect">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword">frm_multifields</xsl:with-param>
                            </xsl:call-template>
                        </a>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>
        
        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -       CHECKBOX      - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type='checkbox'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="checkbox">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="checkbox">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -        RADIO        - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type='radio'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="radio">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="radio">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <!-- - - - - - - - - - - - - - - - - -->
        <!-- - - -       BUTTONS       - - - -->
        <!-- - - - - - - - - - - - - - - - - -->
        <xsl:when test="@type = 'buttonset'">
            <div class="field buttonset">
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <xsl:apply-templates select="buttons/button | buttons/link" />
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

    </xsl:choose>
</xsl:template>



<xsl:template match="options/option" mode="list">
    <xsl:param name="metanode" />
    <xsl:param name="group" />
    
    <div class="inputer">
        <div class="subtitle"><xsl:value-of select="text()" disable-output-escaping="yes" /></div>
    </div>
</xsl:template>



<xsl:template match="options/option" mode="multi-input">
    <xsl:param name="metanode" />
    <xsl:param name="group" />
    
    <div class="inputer">
        <xsl:if test="$metanode/@subtitle">
            <div class="subtitle"><xsl:value-of select="@value" /></div>
        </xsl:if>
        <input type="{$metanode/@type}" name="{$metanode/@name}[{$group}][{@value}]" id="{$metanode/@name}{position()}" class="text" value="{text()}">
            <xsl:if test="$metanode/@disabled = 1">
                <xsl:attribute name="disabled" />
            </xsl:if>
            <xsl:if test="not($metanode/@type = 'text' or $metanode/@type = 'password')">
                <xsl:attribute name="type">text</xsl:attribute>
            </xsl:if>
            <xsl:if test="$metanode/@required = 1">
                <xsl:attribute name="class">text required</xsl:attribute>
            </xsl:if>
            <xsl:if test="$metanode/patterns/pattern">
                <xsl:apply-templates select="$metanode/patterns/pattern" />
            </xsl:if>
        </input>
        <xsl:if test="not($metanode/@disabled) and not($metanode/@stable_amount)">
            <a class="multifilekill">
                <xsl:attribute name="onclick">$(this).closest("div").animate({opacity: 0 }, 500, function() {$(this).remove();});</xsl:attribute>
                <xsl:text>remove</xsl:text>
            </a>
        </xsl:if>
    </div>
</xsl:template>



<xsl:template match="optgroup" mode="select">
    <xsl:param name="selected" />
    
    <optgroup label="{@label}">
        <xsl:apply-templates select="option" mode="select">
            <xsl:with-param name="selected" select="$selected"/>
        </xsl:apply-templates>
    </optgroup>
</xsl:template>



<xsl:template match="option" mode="select">
    <xsl:param name="selected" />
    
    <option value="{@value}">
        <xsl:if test="@checked or $selected = @value or @value = ../../value">
            <xsl:attribute name="selected" />
        </xsl:if>
        <xsl:if test="@disabled = 1">
            <xsl:attribute name="disabled" />
        </xsl:if>
        <xsl:value-of select="text()" disable-output-escaping="yes"/>
    </option>
</xsl:template>




<xsl:template match="optgroup" mode="checkbox">
    <xsl:param name="metanode" />
    <xsl:param name="group" />
    
    <div class="division"><xsl:value-of select="@label"/></div>
    <xsl:apply-templates select="option" mode="checkbox">
        <xsl:with-param name="metanode" select="$metanode" />
        <xsl:with-param name="group" select="$group" />
        <xsl:with-param name="pos" select="position()" />
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="option" mode="checkbox">
    <xsl:param name="metanode" />
    <xsl:param name="group" />
    <xsl:param name="pos">0</xsl:param>

    <label>
        <xsl:if test="@disabled = 1">
            <xsl:attribute name="class">deleted</xsl:attribute>
        </xsl:if>
        <input type="{$metanode/@type}" name="{$metanode/@name}[{$group}][{$pos}{position() - 1}]" value="{@value}" class="{$metanode/@type}">
            <xsl:if test="@checked">
                <xsl:attribute name="checked" />
            </xsl:if>
            <xsl:if test="@disabled = 1">
                <xsl:attribute name="disabled" />
            </xsl:if>
            <xsl:if test="count(../option) = 1">
                <xsl:attribute name="name"><xsl:value-of select="$metanode/@name" />[<xsl:value-of select="$group" />]</xsl:attribute>
                <xsl:attribute name="id"><xsl:value-of select="$metanode/@name" />[<xsl:value-of select="$group" />]</xsl:attribute>
            </xsl:if>
            <xsl:if test="$metanode/@onclick">
                <xsl:attribute name="onclick"><xsl:value-of select="$metanode/@onclick" /></xsl:attribute>
            </xsl:if>
        </input>
        
        <xsl:value-of select="text()" disable-output-escaping="yes" />
    </label>
    <br/>
</xsl:template>






<xsl:template match="optgroup" mode="radio">
    <xsl:param name="metanode" />
    <xsl:param name="group" />
    
    <div class="division"><xsl:value-of select="@label"/></div>
    <xsl:apply-templates select="option" mode="radio">
        <xsl:with-param name="metanode" select="$metanode" />
        <xsl:with-param name="group" select="$group" />
    </xsl:apply-templates>
</xsl:template>


<xsl:template match="option" mode="radio">
    <xsl:param name="metanode" />
    <xsl:param name="group" />

    <label>
        <xsl:if test="$metanode/@disabled = 1">
            <xsl:attribute name="class">deleted</xsl:attribute>
        </xsl:if>
        <input type="{$metanode/@type}" name="{$metanode/@name}[{$group}]" value="{@value}" class="{$metanode/@type}">
            <xsl:if test="$metanode/@disabled = 1">
                <xsl:attribute name="disabled" />
            </xsl:if>
            <xsl:if test="@checked">
                <xsl:attribute name="checked" />
            </xsl:if>
            <xsl:if test="@onclick">
                <xsl:attribute name="onclick"><xsl:value-of select="@onclick" /></xsl:attribute>
            </xsl:if>
        </input>
        
        <xsl:value-of select="text()" disable-output-escaping="yes" />
    </label>
    <br/>
</xsl:template>



<xsl:template match="button">
    <input type="{@type}" class="{@type}">
        <xsl:attribute name="value">
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="@title" />
            </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="title">
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="@title" />
            </xsl:call-template>
        </xsl:attribute>
        <xsl:if test="@onclick">
            <xsl:attribute name="onclick"><xsl:value-of select="@onclick" /></xsl:attribute>
        </xsl:if>
        <xsl:if test="@src">
            <xsl:attribute name="src"><xsl:value-of select="@src" /></xsl:attribute>
        </xsl:if>
    </input>
</xsl:template>



<xsl:template match="link">
    <a href="{@href}" class="{@class}">
        <xsl:attribute name="title">
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="@title" />
            </xsl:call-template>
        </xsl:attribute>
        <xsl:if test="@onclick">
            <xsl:attribute name="onclick"><xsl:value-of select="@onclick" /></xsl:attribute>
        </xsl:if>
        <xsl:call-template name="translate">
            <xsl:with-param name="keyword" select="@title" />
        </xsl:call-template>
    </a>
</xsl:template>



<xsl:template match="pattern">
    <xsl:choose>
        <xsl:when test="@preset = 'date'">
            <xsl:attribute name="date">true</xsl:attribute>
        </xsl:when>
        <xsl:when test="@preset = 'digits'">
            <xsl:attribute name="digits">true</xsl:attribute>
        </xsl:when>
        <xsl:when test="@preset = 'email'">
            <xsl:attribute name="email">true</xsl:attribute>
        </xsl:when>
        <xsl:when test="@preset = 'minlength'">
            <xsl:attribute name="minlength"><xsl:value-of select="item" /></xsl:attribute>
        </xsl:when>
        <xsl:when test="@preset = 'maxlength'">
            <xsl:attribute name="maxlength"><xsl:value-of select="item" /></xsl:attribute>
        </xsl:when>
        <xsl:when test="@preset = 'length'">
            <xsl:attribute name="minlength"><xsl:value-of select="item[position() = 1]" /></xsl:attribute>
            <xsl:attribute name="maxlength"><xsl:value-of select="item[position() = 2]" /></xsl:attribute>
        </xsl:when>
    </xsl:choose>
</xsl:template>



<xsl:template match="pattern" mode="messages">
    <xsl:text>$.validator.messages.</xsl:text>
    <xsl:value-of select="@preset" />
    <xsl:text> = jQuery.format('</xsl:text>
    <xsl:call-template name="translate">
        <xsl:with-param name="keyword" select="@message" />
    </xsl:call-template>
    <xsl:text>');</xsl:text>
</xsl:template>



<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/forms-short-view.xsl ########## -->

<xsl:template match="formblock" mode="short-view">
    <xsl:apply-templates select="form" mode="short-view" />
</xsl:template>

<!-- FROM OUTPUT -->
<xsl:template match="form" mode="short-view">
    <form method="{@method}" name="{@name}" class="short-view">
        <xsl:attribute name="action">
            <xsl:if test="@local=1"><xsl:value-of select="$server" /></xsl:if>
            <xsl:value-of select="@action" />
        </xsl:attribute>

        <xsl:if test="@enctype != ''">
            <xsl:attribute name="enctype"><xsl:value-of select="@enctype" /></xsl:attribute>
        </xsl:if>
        <xsl:if test="@reload = '1'">
            <xsl:attribute name="class">reload</xsl:attribute>
        </xsl:if>

        <input type="hidden" name="formname" value="{@name}" />
        <xsl:if test="../@action">
            <input type="hidden" name="action" value="{../@action}" />
        </xsl:if>
        

        <xsl:choose>
            <xsl:when test="count(../formdata/fieldgroup) > 0">
                <xsl:variable name="this" select="."/>
                <xsl:for-each select="../formdata/fieldgroup">
                    <xsl:apply-templates select="$this/fieldgroup" mode="short-view" >
                        <xsl:with-param name="thisname" select="@name"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="fieldgroup" mode="short-view" />
            </xsl:otherwise>
        </xsl:choose>
    
    </form>

    <xsl:if test="fieldgroup/field[@chosen]">
        <script type="text/javascript">
            $('.chosen-select').chosen({width:"95%"});
        </script>
    </xsl:if>
</xsl:template>



<xsl:template match="fieldgroup" mode="short-view">
    <xsl:param name="thisname" select="@name" />
    
    <xsl:variable name="this" select="." />
    <xsl:variable name="formdata" select="../formdata" />
    <xsl:variable name="errors" select="../errors" />
    <xsl:variable name="confirms" select="../confirms" />

    <xsl:if test="$errors/error[@group=$thisname]">
        <div class="error">
            <ul>
                <xsl:apply-templates select="$errors/error[@group=$thisname]" />
            </ul>
        </div>
    </xsl:if>
    
    <xsl:if test="$confirms/confirm[@group=$thisname]">
        <div class="confirm">
            <ul>
                <xsl:apply-templates select="$confirms/confirm[@group=$thisname]" />
            </ul>
        </div>
    </xsl:if>

    <div id="{@name}_response" class="form-response"></div>
    <input type="hidden" name="group[{$thisname}]" value="{$thisname}" />
    <xsl:apply-templates select="field" mode="short-view">
        <xsl:with-param name="group" select="$thisname" />
        <xsl:with-param name="js-validate">
            <xsl:choose>
                <xsl:when test="../../form/@ajax = 'validate' or ../../form/@ajax = 'ajax' or ../../form/@ajax = 'textmode'">1</xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:with-param>
    </xsl:apply-templates>

</xsl:template>



<xsl:template match="field" mode="short-view">
    <xsl:param name="group" />
    <xsl:param name="js-validate">0</xsl:param>
    
    <xsl:variable name="formdata" select="../../../formdata" />
    <xsl:variable name="errors" select="../../../errors" />
    <xsl:variable name="confirms" select="../../../confirms" />
    <xsl:variable name="this" select="." />

    <xsl:choose>

        <xsl:when test="@type = 'hidden'">
            <input type="{@type}" name="{@name}[{$group}]" class="{@type}">
                <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                    <xsl:attribute name="value"><xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" /></xsl:attribute>
                </xsl:if>
            </input>
        </xsl:when>

        <xsl:when test="@type = 'delimiter'">
            <div class="field delimiter">
                <xsl:if test="title != '' and not(@value_as_title)">
                    <strong>
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                    </strong>
                </xsl:if>
                <xsl:if test="@value_as_title = 1">
                    <strong>
                        <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                            <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" disable-output-escaping="yes" />
                        </xsl:if>
                    </strong>
                </xsl:if>
                <xsl:if test="description != ''">
                    <div class="description">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="description" />
                        </xsl:call-template>
                    </div>
                </xsl:if>
                <div class="clear"></div>
            </div>
        </xsl:when>
        
        <xsl:when test="@type = 'image'">
            <div class="field image">
                <img>
                    <xsl:attribute name="src">
                        <xsl:choose>
                            <xsl:when test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                                <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </img>
                <div class="clear"></div>
            </div>
        </xsl:when>
        
        <xsl:when test="@type = 'text' or @type = 'password' or @type = 'date' or @type = 'datetime'">
            <div class="field text">
                <xsl:variable name="thispos" select="position()" />
                <xsl:if test="../field[position() = $thispos+1]/@type='buttonset'">
                    <xsl:attribute name="class">field text short-field</xsl:attribute>
                </xsl:if>
                
                <input type="{@type}" name="{@name}[{$group}]" id="{@name}" class="text toggleTitle">
                    <xsl:if test="@disabled = 1">
                        <xsl:attribute name="disabled" />
                    </xsl:if>
                    <xsl:attribute name="type">text toggleTitle</xsl:attribute>
                    <xsl:attribute name="title">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                    </xsl:attribute>

                    <xsl:attribute name="value">
                        <xsl:choose>
                            <xsl:when test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                                <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </input>
            </div>
        </xsl:when>
        
        <xsl:when test="@type = 'list'">
            <div class="field">
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <xsl:choose>
                        <xsl:when test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                            <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="list">
                                <xsl:with-param name="metanode" select="current()" />
                                <xsl:with-param name="group" select="$group" />
                            </xsl:apply-templates>
                        </xsl:when>
                    </xsl:choose>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <xsl:when test="@type = 'captcha'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <div style="width: 200px; height: 70px;"><img src="{$base}captcha"/></div>
                    <input type="{@type}" name="{@name}[{$group}]" id="{@name}" class="text">
                        <xsl:if test="@required = 1">
                            <xsl:attribute name="class">text required</xsl:attribute>
                        </xsl:if>
                        <xsl:attribute name="value">
                            <xsl:choose>
                                <xsl:when test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                                    <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" />
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                    </input>
                    <xsl:if test="$js-validate = 1">
                        <script type="text/javascript">
                            <xsl:if test="@required = 1">
                                <xsl:text>$.validator.messages.required</xsl:text>
                                <xsl:text> = jQuery.format('</xsl:text>
                                <xsl:call-template name="translate">
                                    <xsl:with-param name="keyword">frm_err_required_AJAX</xsl:with-param>
                                </xsl:call-template>
                                <xsl:text>');</xsl:text>
                            </xsl:if>
                        </script>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <xsl:when test="@type = 'file'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    
                    <xsl:choose>
                        <xsl:when test="@set=1">
                        
                            <xsl:for-each select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value/field">
    
                                <div class="thumb killme">
                                    <xsl:for-each select="$this/files/file">
                                        <xsl:if test="@id = xml/file[@size = current()/@id]/@size">
                                            <a href="{xml/file[@size = current()/@id]}" class="">
                                                <xsl:value-of select="@id"/>
                                            </a>
                                        </xsl:if>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                    <xsl:text> | </xsl:text>
                                    <a href="{$server}portfolio/delete-photo/{photos_id}" class="overphotokill overkill"><span>delete</span></a>
                                </div>
    
                            </xsl:for-each>
                            
                        </xsl:when>
                        <xsl:otherwise>
                        
                            <xsl:choose>
                                <xsl:when test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value != ''">
                                    <xsl:choose>
                                        <xsl:when test="@aslink = 1">
                                            <div class="image-container">
                                                <a href="{$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value}" target="_blank">
                                                    <xsl:call-template name="translate">
                                                        <xsl:with-param name="keyword">frm_link</xsl:with-param>
                                                    </xsl:call-template>
                                                </a>
                                            </div>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <div class="image-container">
                                                <img src="{$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value}" alt="" />
                                            </div>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <div class="file-input">
                        <xsl:choose>
                            <xsl:when test="@set=1 and @multiple=1">
                                <xsl:choose>
                                    <xsl:when test="@names = 1">
                                        <xsl:attribute name="class">file-input file-set hiddenfield with-names</xsl:attribute>
                                        <input type="text" name="{@name}[{$group}]" class="text" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">file-input file-set hiddenfield</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="@multiple=1">
                                <xsl:choose>
                                    <xsl:when test="@names = 1">
                                        <xsl:attribute name="class">file-input hiddenfield with-names</xsl:attribute>
                                        <input type="text" name="{@name}[{$group}]" class="text" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">file-input hiddenfield</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="@names = 1">
                                <input type="text" name="{@name}_title[{$group}]" class="text"/>
                            </xsl:when>
                        </xsl:choose>

                        <xsl:choose>
                            <xsl:when test="@set = 1">
                                <xsl:for-each select="files/file">
                                    <br /><xsl:value-of select="." /><input type="file" name="{../../@name}[{@id}]" class="file" />
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <input type="{@type}" name="{@name}[{$group}]" class="{@type}" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    
                    <xsl:if test="@multiple = 1">
                        <a href="#" class="multifile">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword">frm_multifiles</xsl:with-param>
                            </xsl:call-template>
                        </a>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <xsl:when test="@type = 'textarea'">
            <div class="field">
                <xsl:if test="$errors/error[@group=$group and fields/field = current()/@name]">
                    <xsl:attribute name="class">field errorfield</xsl:attribute>
                </xsl:if>
                <div class="title">
                    <xsl:if test="title != ''">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword" select="title" />
                        </xsl:call-template>
                        <xsl:if test="@required = 1">
                            <span title="required">*</span>
                        </xsl:if>
                        <xsl:text>:</xsl:text>
                    </xsl:if>
                    <xsl:if test="description != ''">
                        <div class="description">
                            <xsl:call-template name="translate">
                                <xsl:with-param name="keyword" select="description" />
                            </xsl:call-template>
                        </div>
                    </xsl:if>
                </div>
                <div class="control">
                    <textarea name="{@name}[{$group}]" id="{@name}" class="{@type} {@class}">
                        <xsl:if test="@disabled = 1">
                            <xsl:attribute name="disabled" />
                        </xsl:if>
                        <xsl:if test="@height">
                            <xsl:attribute name="style">
                                <xsl:text>height: </xsl:text><xsl:value-of select="@height" /><xsl:text>px;</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@required = 1 and $js-validate = 1">
                            <xsl:attribute name="class"><xsl:value-of select="@type" /> <xsl:value-of select="@class" /> required</xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@wysiwyg != '' and @wysiwyg != 0">
                            <xsl:attribute name="class">
                                <xsl:value-of select="@type" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="@class" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="@wysiwyg" />
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="patterns/pattern and $js-validate = 1">
                            <xsl:apply-templates select="patterns/pattern" />
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                                <xsl:value-of select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/value" />
                            </xsl:when>
                        </xsl:choose>
                    </textarea>
                    <xsl:if test="$js-validate = 1">
                        <script type="text/javascript">
                            <xsl:if test="@required = 1">
                                <xsl:text>$.validator.messages.required</xsl:text>
                                <xsl:text> = jQuery.format('</xsl:text>
                                <xsl:call-template name="translate">
                                    <xsl:with-param name="keyword">frm_err_required_AJAX</xsl:with-param>
                                </xsl:call-template>
                                <xsl:text>');</xsl:text>
                            </xsl:if>
                            <xsl:if test="patterns/pattern">
                                <xsl:apply-templates select="patterns/pattern" mode="messages" />
                            </xsl:if>
                        </script>
                    </xsl:if>
                </div>
                <div class="clear"></div>
            </div>
        </xsl:when>

        <xsl:when test="@type='select'">
            <div class="field select">
                
                <select name="{@name}[{$group}]" id="{@name}" class="{@type}">
                    <xsl:if test="@chosen = 1">
                        <xsl:attribute name="class"><xsl:value-of select="@type" /><xsl:text> chosen-select</xsl:text><xsl:if test="@required = 1 and $js-validate = 1"> required</xsl:if></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@disabled = 1">
                        <xsl:attribute name="disabled" />
                    </xsl:if>
                    <xsl:if test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                        <xsl:choose>
                            <xsl:when test="@i18n = 1">
                                <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options[@lang=$lang]/option" mode="select" />
                                <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options[@lang=$lang]/optgroup" mode="select" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="select" />
                                <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="select" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </select>
            </div>
        </xsl:when>
        
        <xsl:when test="@type='checkbox'">
            <div class="field">
                <xsl:choose>
                    <xsl:when test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="checkbox">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="checkbox">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                    </xsl:when>
                </xsl:choose>
            </div>
        </xsl:when>

        <xsl:when test="@type='radio'">
            <div class="field">
                <xsl:choose>
                    <xsl:when test="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]">
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/option" mode="radio">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                        <xsl:apply-templates select="$formdata/fieldgroup[@name=$group]/field[@name = current()/@name]/options/optgroup" mode="radio">
                            <xsl:with-param name="metanode" select="current()" />
                            <xsl:with-param name="group" select="$group" />
                        </xsl:apply-templates>
                    </xsl:when>
                </xsl:choose>
            </div>
        </xsl:when>

        <xsl:when test="@type = 'buttonset'">
            <div class="field button {@class}">
                <xsl:apply-templates select="buttons/button | buttons/link" />
            </div>
        </xsl:when>

    </xsl:choose>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/translate.xsl ########## -->

<xsl:template name="translate">
    <xsl:param name="keyword" />
    <xsl:variable name="cache" select="/document/translates/translate[@keyword = $keyword]" />
    <xsl:choose>
        <xsl:when test="$cache">
            <xsl:value-of select="$cache" disable-output-escaping="yes" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$keyword" disable-output-escaping="yes" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
    

<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/sqlinfo.xsl ########## -->

<xsl:template match="sqlinfo">
    <div class="block">
        <link rel="stylesheet" type="text/css" href="striped/css/queries.css" />
        <h1>SQL Queries</h1>
        <table id="sqlqueries">
            <thead>
                <tr>
                    <th class="zero">#</th>
                    <th class="first">query</th>
                    <th class="second">time</th>
                    <th class="third">affected rows</th>
                    <th class="fourth">num rows</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]" />
            </tbody>
        </table>
    </div>
</xsl:template>

<xsl:template match="query[parent::sqlinfo]">
    <tr>
        <td><xsl:value-of select="position()" /></td>
        <td><xsl:value-of select="body" /></td>
        <td><xsl:value-of select="time" /></td>
        <td><xsl:value-of select="affected_rows" /></td>
        <td><xsl:value-of select="num_rows" /></td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/pageinfo.xsl ########## -->

<xsl:template match="pageinfo">
    <div class="block">
        <link rel="stylesheet" type="text/css" href="striped/css/pageinfo.css" />
        <xsl:apply-templates  />
    </div>
</xsl:template>

<xsl:template match="page_modules">
    <h1>Blocks</h1>
    <table class="pageinfo">
        <thead>
            <tr>
                <th class="first">controller</th>
                <th class="second">action</th>
                <th class="third">name</th>
                <th class="fourth">type</th>
            </tr>
        </thead>
        <tbody>
            <xsl:apply-templates mode="page_modules" />
        </tbody>
    </table>
</xsl:template>

<xsl:template match="*" mode="page_modules">
    <tr>
        <td><xsl:value-of select="controller" /></td>
        <td><xsl:value-of select="action" /></td>
        <td><xsl:value-of select="name" /></td>
        <td><xsl:value-of select="type" /></td>
    </tr>
</xsl:template>

<xsl:template match="page_params">
    <h1>Parameters</h1>
    <table class="pageinfo">
        <thead>
            <tr>
                <th>name</th>
                <th>value</th>
            </tr>
        </thead>
        <tbody>
            <xsl:apply-templates mode="page_params" />
        </tbody>
    </table>
</xsl:template>

<xsl:template match="*" mode="page_params">
    <tr>
        <td><xsl:value-of select="name(.)" /></td>
        <td>
            <xsl:choose>
                <xsl:when test="text() != ''"><xsl:value-of select="text()" /></xsl:when>
                <xsl:when test="node()">
                    <xsl:for-each select="node()">
                        <xsl:value-of select="name(.)" /><xsl:text>: </xsl:text>
                        <xsl:choose>
                            <xsl:when test="text() != ''">
                                <xsl:value-of select="text()" />
                            </xsl:when>
                            <xsl:otherwise>[empty]</xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>| </xsl:text>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>[empty]</xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/user.xsl ########## -->

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



<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/pager.xsl ########## -->

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


<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/strings.xsl ########## -->

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
    


<!-- ######### /home/tigra/www/subs/subs/striped/transformers/core/attachments.xsl ########## -->

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
    





    <!-- ######### /home/tigra/www/subs/subs/striped/transformers/blocks/include.xsl ########## -->

<!-- ######### /home/tigra/www/subs/subs/striped/transformers/blocks/menu.xsl ########## -->

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


<!-- ######### /home/tigra/www/subs/subs/striped/transformers/blocks/lang_switcher.xsl ########## -->

<xsl:template match="block[@name = 'lang_switcher']">
    <xsl:if test="count(languages/language) > 1">
        <div class="block langswitcher">
            <xsl:apply-templates select="languages/language" />
            <div class="clear"></div>
        </div>
        <div class="clear"></div>
    </xsl:if>
</xsl:template>

<xsl:template match="language[ancestor::block[@name = 'lang_switcher']]">
    <a href="{$base}{@id}/{$requested_uri}?switchlang=1" title="{@title}">
        <xsl:if test="../../current = @id">
            <xsl:attribute name="class">active</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="@title" />
    </a>
</xsl:template>



<!-- ######### /home/tigra/www/subs/subs/striped/transformers/blocks/authorization.xsl ########## -->

<xsl:template match="block[@name = 'login-area']">
    <div class="block login-area">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]"/>
        <xsl:if test="not(userinfo/id)">
            <div class="forget-to-register">
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">glb_fgt_link</xsl:with-param>
                </xsl:call-template>
                <xsl:text> | </xsl:text>
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">glb_reg_link</xsl:with-param>
                </xsl:call-template>
            </div>
        </xsl:if>
    </div>
</xsl:template>


<xsl:template match="block[@name = 'login-link']">
    <div class="block login-area">
        <xsl:choose>
            <xsl:when test="userinfo/id">
                <xsl:apply-templates select="userinfo" />
            </xsl:when>
            <xsl:otherwise>
                <a href="{$server}login/">
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_login</xsl:with-param>
                    </xsl:call-template>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>


<xsl:template match="userinfo">
    <a href="profile/" class="username-link">
        <xsl:if test="customer_name != ''">
            <b><xsl:value-of select="customer_name" /></b>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="realname != ''">
                <b>::</b>
                <xsl:value-of select="realname" />
            </xsl:when>
            <xsl:when test="username != ''">
                <b>::</b>
                <xsl:value-of select="username" />
            </xsl:when>
        </xsl:choose>
    </a>
    <xsl:text> (</xsl:text>
    <a href="{$server}logout">
        <xsl:call-template name="translate">
            <xsl:with-param name="keyword">au_logout</xsl:with-param>
        </xsl:call-template>
    </a>
    <xsl:text>)</xsl:text>
</xsl:template>


<xsl:template match="block[@name = 'login-area']" mode="short-view">
    <div class="block login-area">
    	<xsl:if test="not(userinfo/id)">
            <div class="">
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">glb_fgt_link</xsl:with-param>
                </xsl:call-template>
                <xsl:text> | </xsl:text>
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">glb_reg_link</xsl:with-param>
                </xsl:call-template>
            </div>
        </xsl:if>
        
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]" mode="short-view" />
        <div class="clear"></div>
    </div>
</xsl:template>

<xsl:template match="userinfo" mode="short-view">
    <xsl:call-template name="userlink">
        <xsl:with-param name="customer_name" select="customer_name" />
        <xsl:with-param name="username" select="username" />
        <xsl:with-param name="realname" select="realname" />
    </xsl:call-template>
    <xsl:text> (</xsl:text>
    <a href="{$server}logout">
        <xsl:call-template name="translate">
            <xsl:with-param name="keyword">au_logout</xsl:with-param>
        </xsl:call-template>
    </a>
    <xsl:text>, </xsl:text>
    <a href="{$server}logout-all">
        <xsl:call-template name="translate">
            <xsl:with-param name="keyword">AUTH_LB_LOGOUT_ALL</xsl:with-param>
        </xsl:call-template>
    </a>
    <xsl:text>)</xsl:text>
 </xsl:template>
 

<xsl:template match="block[@name = 'register' or @name = 'userAdd']">
    <div class="block">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]"/>
    </div>
</xsl:template>

<xsl:template match="block[@name = 'forgotten']">
    <div class="block">
        <xsl:choose>
            <xsl:when test="error != ''">
                <div class="empty">
                    <xsl:value-of select="error" disable-output-escaping="yes" />
                </div>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]"/></xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>


<xsl:template match="block[@name = 'userlist']">
    <form action="{$server}auth/do" method="post">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>
                <xsl:if test="@auth.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'deleteUser')" class="kill" />
                </xsl:if>
                
                <xsl:if test="@auth.register = 1">
                    <input type="button" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="window.location.href = '{$server}user/register'" />
                </xsl:if>
            </div>
        </div>
        
        <xsl:if test="errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
        <xsl:if test="confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
        <table class="tech fixOnScrollTable fixed-table">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword">au_lb_uname</xsl:with-param>
                        </xsl:call-template>
                    </th>
                    <th width="240">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword">au_lastvst</xsl:with-param>
                        </xsl:call-template>
                    </th>
                    <th width="240">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword">au_roles</xsl:with-param>
                        </xsl:call-template>
                    </th>
                    <th width="70">
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword">au_active</xsl:with-param>
                        </xsl:call-template>
                    </th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="userlist/user" />
            </tbody>
        </table>
        <xsl:apply-templates select="pager" />
    </form>
</xsl:template>



<xsl:template match="block[@name = 'userlist']/userlist/user">
    <tr>
        <xsl:choose>
            <xsl:when test="active != 1 and active != 't'">
                <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td>
            <xsl:call-template name="userlink">
                <xsl:with-param name="customer_name" select="customer_name" />
                <xsl:with-param name="username" select="username" />
            </xsl:call-template>
        </td>
        <td>
            <xsl:value-of select="lastvisit" />
        </td>
        <td>
            <xsl:apply-templates select="roles/role" />
            <xsl:if test="../../@auth.edit = 1">
                <a href="userrole/add/{id}" class="link-add fright"><span>assign role to user</span></a>
            </xsl:if>
        </td>
        <td>
            <xsl:choose>
                <xsl:when test="active = 1 or active = 't'">
                    <a class="clightgreen ask-confirm" title="deactivate user '{customer_name}-{username}'">
                        <xsl:if test="../../@auth.edit = 1">
                            <xsl:attribute name="href">user/deactivate/<xsl:value-of select="id"/></xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword">au_active_t</xsl:with-param>
                        </xsl:call-template>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <a class="clightred ask-confirm" title="activate user '{customer_name}-{username}'">
                        <xsl:if test="../../@auth.edit = 1">
                            <xsl:attribute name="href">user/activate/<xsl:value-of select="id"/></xsl:attribute>
                        </xsl:if>
                        <xsl:call-template name="translate">
                            <xsl:with-param name="keyword">au_active_f</xsl:with-param>
                        </xsl:call-template>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>


<xsl:template match="block[@name = 'userlist']/userlist/user/roles/role">
    <xsl:choose>
        <xsl:when test="../../../../@auth.edit = 1 and ../../../../roles/role[text() = current()/id]">
            <a href="userrole/delete/{../../id}/{id}" class="ask-confirm" title="revoke users's role '{name}'">
                <xsl:value-of select="name" />
            </a>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="translate">
                <xsl:with-param name="keyword" select="name" />
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="position()!=last()">, </xsl:if>
</xsl:template>


<xsl:template match="block[@name = 'addusertogroup']">
    <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]"/>
</xsl:template>


<xsl:template match="block[@name = 'customerAdd']">
    <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]"/>
</xsl:template>


<xsl:template match="block[@name = 'customerList']">
    <form action="{$server}auth/do" method="post">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>
                <xsl:if test="@root.customerdelete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'deleteCustomer')" class="kill" />
                    <input type="submit" value="{$translate[@keyword='glb_block']}" onclick="$.fn.assignAction(this, 'blockCustomer')" />
                    <input type="submit" value="{$translate[@keyword='glb_activate']}" onclick="$.fn.assignAction(this, 'unblockCustomer')" />
                </xsl:if>
                
                <xsl:if test="@root.customermanage = 1">
                    <input type="button" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="window.location.href = '{$server}customer/register'" />
                </xsl:if>
            </div>
        </div>

        <xsl:if test="errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>


        <script>
            <![CDATA[
            jQuery(function($) {
                $('#customertb .limits').click(function(){
                    $(this).text('working...');
                    url = server + 'customer/limits/' + $(this).attr('rel');
                    jQuery.getJSON(url, function( data ) {
                       $("#customertb #cid_"+data.cid+" .limits").html(data.limits); 
                    });
                    return false;
                });
                $('#customertb .limits-heading').click(function(){
                    $('#customertb .limits').click();
                });
            });
            ]]>
        </script>
        <style>
            .limits {
                cursor: pointer;
                border-bottom: 1px dotted gray;
            }
            .limits-heading {
                cursor: pointer;
                border-bottom: 1px dotted gray;
            }
        </style>

        <table class="tech" id="customertb">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th><xsl:value-of select="$translate[@keyword='au_lb_cname']" /></th>
                    <xsl:if test="@referer = 1">
                        <th><xsl:value-of select="$translate[@keyword='au_ref_link']" /></th>
                    </xsl:if>
                    <th width="150"><span class="limits-heading"><xsl:value-of select="$translate[@keyword='au_api_limits']" /></span></th>
                    <th width="50"><xsl:value-of select="$translate[@keyword='glb_type']" /></th>
                    <th width="50"><xsl:value-of select="$translate[@keyword='glb_status']" /></th>
                    <th width="50"><xsl:value-of select="'regget from'" /></th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates select="customerlist/customer" />
            </tbody>
        </table>
        <xsl:apply-templates select="pager" />

    </form>
</xsl:template>


<xsl:template match="block[@name = 'customerList']/customerlist/customer">
    <tr id="cid_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'">
                <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td>
            <xsl:value-of select="login" />
        </td>
        <xsl:if test="../../@referer = 1">
            <td>
                <xsl:apply-templates select="../../@referer_host" />?ref=<xsl:apply-templates select="ref" />
            </td>
        </xsl:if>
        <td>
            <span class="limits" rel="{login}"><span style="color: #080">[count limits]</span></span>
        </td>
        
        <td>
            <xsl:value-of select="type" />
        </td>
        <td>
            <span class="clightred ask-confirm">
                <xsl:if test="status = 'active'">
                    <xsl:attribute name="class">clightgreen</xsl:attribute>
                </xsl:if>
                
                <xsl:value-of select="status"/>
            </span>
        </td>
        <td>
            <xsl:value-of select="referer_name" />
        </td>
    </tr>
</xsl:template>


<!-- profile -->
<xsl:template match="block[@name = 'profile']">
    <div class="users-profile">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]"/>
    </div>
</xsl:template>


<xsl:template match="block[@name = 'profile']/user">
    <h2><xsl:value-of select="realname" /></h2>
    <xsl:choose>
        <xsl:when test="@owner = 1">
            <a href="{$server}profile/edit" class="profile-edit">
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">glb_edit</xsl:with-param>
                </xsl:call-template>
            </a>
        </xsl:when>
        <xsl:when test="$superuser = 't' and ../@auth.edit = 1">
            <a href="{$server}user/{customer_name}-{username}/edit" class="profile-edit">
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">glb_edit</xsl:with-param>
                </xsl:call-template>
            </a>
        </xsl:when>
    </xsl:choose>
    <div class="right-side">
        <dl>
            <dt>
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">au_lb_cname</xsl:with-param>
                </xsl:call-template>
                <xsl:text>:</xsl:text>
            </dt>
            <dd><xsl:value-of select="customer_name" /></dd>
            <dt>
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">au_lb_uname</xsl:with-param>
                </xsl:call-template>
                <xsl:text>:</xsl:text>
            </dt>
            <dd><xsl:value-of select="username" /></dd>
            <xsl:if test="$superuser = 't' and ../@auth.edit = 1">
                <dt>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_lb_email</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text>:</xsl:text>
                </dt>
                <dd><xsl:value-of select="email" /></dd>
            </xsl:if>
            
            <dt>
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">au_lb_skype</xsl:with-param>
                </xsl:call-template>
                <xsl:text>:</xsl:text>
            </dt>
            <dd><xsl:value-of select="skype" /></dd>
            
            <dt>
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">au_lb_icq</xsl:with-param>
                </xsl:call-template>
                <xsl:text>:</xsl:text>
            </dt>
            <dd><xsl:value-of select="icq" /></dd>
                
            <dt>
                <xsl:call-template name="translate">
                    <xsl:with-param name="keyword">au_lastvst</xsl:with-param>
                </xsl:call-template>
                <xsl:text>:</xsl:text>
            </dt>
            <dd>
                <xsl:value-of select="lastvisit"/>
            </dd>
            
            <xsl:if test="ref_link">
                <dt>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_ref_link</xsl:with-param>
                    </xsl:call-template>
                    <xsl:text>:</xsl:text>
                </dt>
                <dd><xsl:value-of select="ref_link" /></dd>
            </xsl:if>
        </dl>
    </div>
    <div class="clear"></div>
</xsl:template>


<!-- accessLog -->
<xsl:template match="block[@name = 'accessLog']">
    <table class="tech">
        <thead>
            <tr>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_lb_uname</xsl:with-param>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_lb_uname</xsl:with-param>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_logs_accesspoint</xsl:with-param>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_logs_referer</xsl:with-param>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_logs_params</xsl:with-param>
                    </xsl:call-template>
                </th>
            </tr>
        </thead>
        <tbody>
            <xsl:apply-templates select="log/record" />
        </tbody>
    </table>
    <xsl:apply-templates select="pager" />
</xsl:template>

<xsl:template match="block[@name = 'accessLog']/log/record">
    <tr>
        <td style="min-width: 120px;">
            <xsl:value-of select="time" />
        </td>
        <td style="min-width: 120px;">
            <xsl:value-of select="customer_name" />
            <xsl:text>-</xsl:text>
            <xsl:value-of select="username" />
            <xsl:text> (</xsl:text>
            <xsl:value-of select="user_id" />
            <xsl:text>)</xsl:text>
        </td>
        <td style="min-width: 300px;">
            <textarea style="width: 90%; height: 90%; border: none; background: #e8eef7; color: #036;">
                <xsl:value-of select="accesspoint" />
            </textarea>
        </td>
        <td style="min-width: 300px;">
            <textarea style="width: 90%; height: 90%; border: none; background: #e8eef7; color: #036;">
                <xsl:value-of select="referer" />
            </textarea>
        </td>
        <td>
            <xsl:apply-templates select="params/param" mode="recur"/>
        </td>
    </tr>
</xsl:template>


<xsl:template match="param" mode="recur">
    <xsl:param name="sublevel">0</xsl:param>
    
    <xsl:choose>
        <xsl:when test="$sublevel = 1">
            <xsl:if test="position() = 1">[</xsl:if>
            
            <small><b><i><xsl:value-of select="name"/></i></b></small><xsl:text>: </xsl:text>
                
            <xsl:choose>
                <xsl:when test="value/param">
                    <xsl:apply-templates select="value/param" mode="recur">
                        <xsl:with-param name="sublevel">1</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise><small><i><xsl:value-of select="value"/></i></small></xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="position() != last()">, </xsl:if>
            <xsl:if test="position() = last()">]</xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <b><xsl:value-of select="name"/></b><xsl:text>: </xsl:text>
            
            <xsl:choose>
                <xsl:when test="value/param">
                    <xsl:apply-templates select="value/param" mode="recur">
                        <xsl:with-param name="sublevel">1</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise><i><xsl:value-of select="value"/></i></xsl:otherwise>
            </xsl:choose>
            
            <xsl:if test="position() != last()">
                <br/>
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
        
</xsl:template>


<!-- actionsLog -->
<xsl:template match="block[@name = 'actionsLog']">
    <table class="tech">
        <thead>
            <tr>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_logs_time</xsl:with-param>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_lb_uname</xsl:with-param>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_logs_action</xsl:with-param>
                    </xsl:call-template>
                </th>
                <th>
                    <xsl:call-template name="translate">
                        <xsl:with-param name="keyword">au_logs_link</xsl:with-param>
                    </xsl:call-template>
                </th>
            </tr>
        </thead>
        <tbody>
            <xsl:apply-templates select="log/record" />
        </tbody>
    </table>
    <xsl:apply-templates select="pager" />
</xsl:template>

<xsl:template match="block[@name = 'actionsLog']/log/record">
    <tr>
        <td>
            <xsl:value-of select="time" />
        </td>
        <td>
            <xsl:value-of select="customer_name" />-<xsl:value-of select="username" />
            <xsl:text> (</xsl:text>
            <xsl:value-of select="user_id" />
            <xsl:text>)</xsl:text>
        </td>
        <td>
            <xsl:value-of select="action" />
        </td>
        <td>
            <xsl:choose>
                <xsl:when test="link != ''">
                    <a href="{link}" target="_top" >#</a>
                </xsl:when>
                <xsl:otherwise>-</xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/striped/transformers/blocks/staticblock.xsl ########## -->

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
    

<!-- ######### /home/tigra/www/subs/subs/striped/transformers/blocks/referer.xsl ########## -->

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
    

<!-- ######### /home/tigra/www/subs/subs/striped/transformers/blocks/feedback.xsl ########## -->

<xsl:template match="block[@controller = 'feedback']">
    <xsl:apply-templates  select="*[not(local-name() = 'jss') and not(local-name() = 'csss')]" />
</xsl:template>
    




    <!-- ######### /home/tigra/www/subs/subs/transformers/include.xsl ########## -->

<!-- ######### /home/tigra/www/subs/subs/transformers/document.xsl ########## -->

<xsl:template name="csslink-custom">
    <link rel="stylesheet" type="text/css" href="css/global.css?ver={$ver}" />
    <xsl:if test="/document/blocks/block/formblock or /document/blocks/block/commentsblock">
        <link rel="stylesheet" type="text/css" href="striped/css/forms.css?ver={$ver}" />
    </xsl:if>
    <xsl:if test="/document/blocks/block/commentsblock">
        <link rel="stylesheet" type="text/css" href="striped/css/comments.css?ver={$ver}" />
    </xsl:if>
    <xsl:if test="/document/blocks/@css">
        <link rel="stylesheet" type="text/css" href="{/document/blocks/@css}?ver={$ver}" />
    </xsl:if>
    <xsl:apply-templates select="/document/blocks/block[@css!='']" mode="css" />
    <xsl:apply-templates select="//csss/css[not(.=preceding::css)]" mode="css">
        <xsl:sort data-type="text" order="ascending" case-order="upper-first" />
    </xsl:apply-templates>
</xsl:template>

<xsl:template name="jslink-custom">
    <script type="text/javascript" src="js/global.js?ver={$ver}"></script>
</xsl:template>

<xsl:template match="/document[@template='custom']">
    <html>
        <head>
            <xsl:call-template name="metas" />
            <title><xsl:value-of select="$title" /></title>
            <xsl:call-template name="favicon" />
            <xsl:call-template name="csslink-custom" />
            <xsl:call-template name="jslink" />
            <xsl:call-template name="jslink-custom" />
        </head>
        <body>
            <xsl:apply-templates select="blocks/block[@name='root.menu']" />
            <div id="container">
                <div id="wrapper">
                    <div id="overheader">
                        <div class="item">
                            <xsl:value-of select="$translate[@keyword='glb_now']"/>: <b>
                                <xsl:call-template name="human-from-unix">
                                    <xsl:with-param name="unix" select="/document/@time"/>
                                    <xsl:with-param name="timezone">0</xsl:with-param>
                                </xsl:call-template>
                            </b>
                        </div>
                        <div class="item"><xsl:value-of select="$translate[@keyword='glb_lastcron']"/>: <b>
                                <xsl:choose>
                                    <xsl:when test="string(number(/document/blocks/block[@controller='pulse']/cron)) != 'NaN'">
                                    <xsl:call-template name="human-from-unix">
                                        <xsl:with-param name="unix" select="/document/blocks/block[@controller='pulse']/cron"/>
                                        <xsl:with-param name="timezone">0</xsl:with-param>
                                    </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:value-of select="/document/blocks/block[@controller='pulse']/cron" disable-output-escaping="yes" /></xsl:otherwise>
                                </xsl:choose>
                                </b>
                                
                        </div>
                        <div class="item"><xsl:value-of select="$translate[@keyword='glb_tasks']"/>: <b><xsl:value-of select="/document/blocks/block[@controller='pulse']/tasks"/></b></div>

                        <div class="clear"></div>
                    </div>
                    <div id="header">
                        <div class="overheader">
                            <div class="fleft"><xsl:apply-templates select="blocks/block[@type='header-left']" /></div>
                            <div class="fright"><xsl:apply-templates select="blocks/block[@type='header-right']" /></div>
                            <div class="clear"></div>
                        </div>
                        <h1 class="{$lang} fleft"><a href="{$server}"><xsl:value-of select="$site-title"/></a></h1>
                        <div class="topmenu">
                            <xsl:apply-templates select="blocks/block[@type='header']" />
                            <div class="clear"></div>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div id="content">
                        <xsl:if test="blocks/block[@type='r-block']">
                            <div class="right">
                                <xsl:apply-templates select="blocks/block[@type='r-block']" />
                            </div>
                        </xsl:if>
                        <xsl:if test="blocks/block[@type='l-block']">
                            <div class="left">
                                <xsl:apply-templates select="blocks/block[@type='l-block']" />
                            </div>
                        </xsl:if>
                        <div class="middle">
                            <xsl:if test="$page-title != ''">
                                <h2><xsl:value-of select="$page-title" /></h2>
                            </xsl:if>
                            <xsl:apply-templates select="blocks/block[@type='content']" />
                        </div>
                    </div>
                    <div id="footer">
                        <xsl:apply-templates select="blocks/block[@type='footer']" />
                        <div class="clear"></div>
                    </div>
                </div>
            </div>
            <xsl:comment> stats placeholder </xsl:comment>
            <xsl:apply-templates select="pageinfo" />
            <xsl:apply-templates select="sqlinfo" />
        </body>
    </html>
</xsl:template>



    <xsl:template name="yesno">
        <xsl:param name="data"/>

        <td>
            <xsl:choose>
                <xsl:when test="$data = 1">
                    <xsl:attribute name="class">yes</xsl:attribute>
                    <xsl:text>yes</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">no</xsl:attribute>
                    <xsl:text>no</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>

    <xsl:template name="datano">
        <xsl:param name="data"/>

        <td>
            <xsl:choose>
                <xsl:when test="$data != '' and $data != 0">
                    <xsl:attribute name="class">yes</xsl:attribute>
                    <xsl:value-of select="$data"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">no</xsl:attribute>
                    <xsl:text>no</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>


    <xsl:template name="zero">
        <xsl:param name="data"/>

        <td>
            <xsl:choose>
                <xsl:when test="$data != ''">
                    <xsl:value-of select="$data"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">no</xsl:attribute>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>



    <xsl:template name="rawzero">
        <xsl:param name="data"/>

        <xsl:choose>
            <xsl:when test="$data != ''">
                <xsl:value-of select="$data"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>0</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>




<!-- ######### /home/tigra/www/subs/subs/transformers/task.xsl ########## -->

<xsl:template match="block[@controller = 'task']">
    <div class="task">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'task']/task">
    <form class="table" action="{$server}task/do" method="post">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <xsl:if test="../@task.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_cancel']}" onclick="$.fn.assignAction(this, 'cancel')" />
                    <input type="submit" value="{$translate[@keyword='glb_restart']}" onclick="$.fn.assignAction(this, 'restart')" />
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" />
                </xsl:if>
            </div>
        </div>

         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" disable-output-escaping="yes" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <script>
            jQuery(function($) {
                $.fn.sendReport = function (obj) {
                    var params = $(obj).closest('tr').find('.params .json').text();
                    var created = $(obj).closest('tr').find('.created').text();
                    var type = $(obj).closest('tr').find('.type').text();
                    $(".reportForm form .reportParams").val(params);
                    $(".reportForm form .reportMessage").val('Error in task: ' + type + '\nOccured: ' + created);
                    $.fn.reportToggle($(".reportForm form .reportMessage"));
                };
            });
        </script>

        <table class="tech fixOnScrollTable">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th><xsl:value-of select="$translate[@keyword='glb_type']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='glb_status']"/></th>
                    <th width="80">created</th>
                    <th width="80">params</th>
                    <th width="80">+</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="task"><xsl:apply-templates select="task"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="6" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'task']/task/task">
    <tr>
        <xsl:choose>
            <xsl:when test="status = 'deleted' or status = 'stopped'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'error'"><xsl:attribute name="class">marked-red</xsl:attribute></xsl:when>
            <xsl:when test="status = 'done'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
            <xsl:when test="status = 'progress'"><xsl:attribute name="class">marked-orange</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td class="type"><xsl:value-of select="type" /></td>
        <td>
            <xsl:value-of select="status" />
            <xsl:if test="status_message != ''">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="status_message" />
                <xsl:text>)</xsl:text>
            </xsl:if>
        </td>
        <td class="created" title="restarted: {restarted}"><xsl:value-of select="created" /></td>
        <td class="params">
            <a href="javascript:void(0);" onclick="$(this).hide().siblings('a, div').show();">show</a>
            <a href="javascript:void(0);" onclick="$(this).siblings('div').hide().siblings('a').show();$(this).hide();" style="display: none;">hide</a><br/>
            <div class="json" style="display: none;">
                <xsl:value-of select="params" disable-output-escaping="yes" />
            </div>
        </td>
        <td>
            <xsl:choose>
                <xsl:when test="status = 'error'"><a href="javascript:void(0);" onclick="$.fn.sendReport(this)">send report</a></xsl:when>
                <xsl:otherwise>+</xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/stats.xsl ########## -->

<xsl:template match="block[@controller = 'stats']">
    <div class="stats">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>

<!-- #### IN #### -->
<xsl:template match="block[@controller = 'stats' and @action = 'showin']/stats">
    <h2>IN stats</h2>        
    <table class="tech fixOnScrollTable">
        <thead>
            <tr>
                <th>sid</th>
                <th><a href="javascript:void(0);" onclick="$(this).closest('table').find('td.ua a, td.ua span').toggle();">ua</a></th>
                <th>niche</th>
                <th>t page</th>
                <th>page</th>
                <th>ip</th>
                <th><a href="javascript:void(0);" onclick="$(this).closest('table').find('td.referer a, td.referer span').toggle();">referer</a></th>
                <th>proxy</th>
                <th>no cookie</th>
                <th>ipunique</th>
                <th>country</th>
                <th>in trader</th>
                <th>type</th>
                <th>time</th>
                <th>processed</th>
            </tr>
        </thead>
        <tbody>
            <xsl:choose>
                <xsl:when test="stats"><xsl:apply-templates select="stats"/></xsl:when>
                <xsl:otherwise>
                    <tr>
                        <td colspan="15" style="text-align: center;">
                            <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                        </td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>
        </tbody>
    </table>
</xsl:template>

<xsl:template match="block[@controller = 'stats' and @action = 'showin']/stats/stats">
    <tr>
        <td><xsl:value-of select="sid" /></td>
        <td class="ua">
            <xsl:if test="ua != ''">
                <a href="javascript:void(0);" onclick="$(this).hide().siblings('a, span').show();">show</a>
                <a href="javascript:void(0);" onclick="$(this).siblings('span').hide().siblings('a').show();$(this).hide();" style="display: none;">hide</a>
                <br /><span style="display: none;"><xsl:value-of select="ua" /></span>
            </xsl:if>
        </td>
        <td><xsl:value-of select="niche_id" /></td>
        <td><xsl:value-of select="pagetype" /></td>
        <td><xsl:value-of select="page" /></td>
        <td><xsl:value-of select="ip" /></td>
        <td class="referer">
            <xsl:if test="referer != ''">
                <a href="javascript:void(0);" onclick="$(this).hide().siblings('a, span').show();">show</a>
                <a href="javascript:void(0);" onclick="$(this).siblings('span').hide().siblings('a').show();$(this).hide();" style="display: none;">hide</a>
                <br /><span style="display: none;"><xsl:value-of select="referer" /></span>
            </xsl:if>
        </td>

        <xsl:call-template name="yesno">
            <xsl:with-param name="data" select="isproxy"/>
        </xsl:call-template>

        <xsl:call-template name="yesno">
            <xsl:with-param name="data" select="nocookie"/>
        </xsl:call-template>

        <xsl:call-template name="yesno">
            <xsl:with-param name="data" select="ipunique"/>
        </xsl:call-template>
        <td><xsl:value-of select="country" /><xsl:text> : </xsl:text><xsl:value-of select="country_type" /></td>
        <xsl:call-template name="datano">
            <xsl:with-param name="data" select="trader"/>
        </xsl:call-template>
        <td><xsl:value-of select="type" /></td>
        <td><xsl:value-of select="time" /></td>
        <td>
            <xsl:value-of select="processed" />
            <xsl:text> - </xsl:text>
            <xsl:choose>
                <xsl:when test="processed = 1">OK</xsl:when>
                <xsl:when test="processed = 2">bot (no cookie)</xsl:when>
                <xsl:when test="processed = 3">click overlimited</xsl:when>
                <xsl:otherwise>not processed yet</xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>

<!-- #### OUT #### -->
<xsl:template match="block[@controller = 'stats' and @action = 'showout']/stats">
    <h2>OUT stats</h2>  
    <table class="tech fixOnScrollTable">
        <thead>
            <tr>
                <th>sid</th>
                <th><a href="javascript:void(0);" onclick="$(this).closest('table').find('td.ua a, td.ua span').toggle();">ua</a></th>
                <th>gallery</th>
                <th>thumb</th>
                <th>niche</th>
                <th>t page</th>
                <th>page</th>
                <th>ip</th>
                <th><a href="javascript:void(0);" onclick="$(this).closest('table').find('td.referer a, td.referer span').toggle();">referer</a></th>
                <th>time</th>
                <th>out trader</th>
                <th>unique</th>
                <th>nocookie</th>
                <th>overclick</th>
                <th>country</th>
                <th>type</th>
                <th>processed</th>
            </tr>
        </thead>
        <tbody>
            <xsl:choose>
                <xsl:when test="stats"><xsl:apply-templates select="stats"/></xsl:when>
                <xsl:otherwise>
                    <tr>
                        <td colspan="17" style="text-align: center;">
                            <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                        </td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>
        </tbody>
    </table>
</xsl:template>

<xsl:template match="block[@controller = 'stats' and @action='showout']/stats/stats">
    <tr>
        <td><xsl:value-of select="sid" /></td>
        <td class="ua">
            <xsl:if test="ua != ''">
                <a href="javascript:void(0);" onclick="$(this).hide().siblings('a, span').show();">show</a>
                <a href="javascript:void(0);" onclick="$(this).siblings('span').hide().siblings('a').show();$(this).hide();" style="display: none;">hide</a>
                <br /><span style="display: none;"><xsl:value-of select="ua" /></span>
            </xsl:if>
        </td>
        <td><a href="{$server}gallery/{gallery_id}"><xsl:value-of select="gallery_id" /></a></td>
        <td><xsl:value-of select="thumb_id" /></td>
        <td><xsl:value-of select="niche_id" /></td>
        <td><xsl:value-of select="pagetype" /></td>
        <td><xsl:value-of select="page" /></td>
        <td><xsl:value-of select="ip" /></td>
        <td class="referer">
            <xsl:if test="referer != ''">
                <a href="javascript:void(0);" onclick="$(this).hide().siblings('a, span').show();">show</a>
                <a href="javascript:void(0);" onclick="$(this).siblings('span').hide().siblings('a').show();$(this).hide();" style="display: none;">hide</a>
                <br /><span style="display: none;"><xsl:value-of select="referer" /></span>
            </xsl:if>
        </td>
        <td><xsl:value-of select="time" /></td>

        <xsl:call-template name="datano">
            <xsl:with-param name="data" select="trader"/>
        </xsl:call-template>

        <xsl:call-template name="yesno">
            <xsl:with-param name="data" select="isunique"/>
        </xsl:call-template>

        <xsl:call-template name="yesno">
            <xsl:with-param name="data" select="nocookie"/>
        </xsl:call-template>

        <xsl:call-template name="yesno">
            <xsl:with-param name="data" select="overclick"/>
        </xsl:call-template>


        <td><xsl:value-of select="country" /><xsl:text> : </xsl:text><xsl:value-of select="country_type" /></td>
        <td><xsl:value-of select="type" /></td>

        <td>
            <xsl:value-of select="processed" />
            <xsl:text> - </xsl:text>
            <xsl:choose>
                <xsl:when test="processed = 1">OK</xsl:when>
                <xsl:when test="processed = 2">bot (no cookie)</xsl:when>
                <xsl:when test="processed = 3">click overlimited</xsl:when>
                <xsl:otherwise>not processed yet</xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>

<!-- #### EXIT #### -->
<xsl:template match="block[@controller = 'stats' and @action = 'showexit']/stats">
    <h2>EXITS stats</h2>  
    <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th rowspan="2">name</th>

                    <th colspan="7" class="odd">1 hour</th>

                    <th colspan="7">24 hour</th>
                </tr>
                <tr>
                    <th class="odd">raw in</th>
                    <th class="odd">unique in</th>
                    <th class="odd">click</th>
                    <th class="odd">raw_out</th>
                    <th class="odd">skim</th>
                    <th class="odd">ratio</th>
                    <th class="odd" title="productivity">prod.</th>

                    <th>raw in</th>
                    <th>unique in</th>
                    <th>click</th>
                    <th>raw_out</th>
                    <th>skim</th>
                    <th>ratio</th>
                    <th title="productivity">prod.</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="child::node()"><xsl:apply-templates select="child::node()"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="15" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th rowspan="2">name</th>

                    <th class="odd">raw in</th>
                    <th class="odd">unique in</th>
                    <th class="odd">click</th>
                    <th class="odd">raw_out</th>
                    <th class="odd">skim</th>
                    <th class="odd">ratio</th>
                    <th class="odd" title="productivity">prod.</th>

                    <th>raw in</th>
                    <th>unique in</th>
                    <th>click</th>
                    <th>raw_out</th>
                    <th>skim</th>
                    <th>ratio</th>
                    <th title="productivity">prod.</th>
                </tr>
                <tr>
                    <th colspan="7" class="odd">1 hour</th>

                    <th colspan="7">24 hour</th>
                </tr>
            </tfoot>
        </table>
</xsl:template>

<xsl:template match="block[@controller = 'stats' and @action='showexit']/stats/*">
    <tr>
        <td><xsl:value-of select="local-name()" /></td>
        
        <xsl:call-template name="zero">
            <xsl:with-param name="data" select="h1/raw_in"/>
        </xsl:call-template>
        <td>
            <xsl:choose>
                <xsl:when test="h1/unique_in != ''">
                    <xsl:value-of select="h1/unique_in"/>
                    <xsl:text> (</xsl:text>
                    <xsl:choose>
                        <xsl:when test="h1/unique_in = '' or h1/raw_in = ''">0%</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="format-number(h1/unique_in div h1/raw_in, '#,###%')" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">no</xsl:attribute>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <xsl:call-template name="zero">
            <xsl:with-param name="data" select="h1/click"/>
        </xsl:call-template>
        <xsl:call-template name="zero">
            <xsl:with-param name="data" select="h1/raw_out"/>
        </xsl:call-template>

        <td>
            <xsl:choose>
                <xsl:when test="h1/raw_out = '' or h1/click = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(h1/raw_out div h1/click, '#,###%')" />
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <td>
            <xsl:choose>
                <xsl:when test="h1/raw_out = '' or h1/raw_in = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(h1/raw_out div h1/raw_in, '#,###%')" />
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <td>
            <xsl:choose>
                <xsl:when test="h1/click = '' or h1/raw_in = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(h1/click div h1/raw_in, '#,###%')" />
                </xsl:otherwise>
            </xsl:choose>
        </td>
        
        <xsl:call-template name="zero">
            <xsl:with-param name="data" select="h24/raw_in"/>
        </xsl:call-template>
        <td>
            <xsl:choose>
                <xsl:when test="h24/unique_in != ''">
                    <xsl:value-of select="h24/unique_in"/>
                    <xsl:text> (</xsl:text>
                    <xsl:choose>
                        <xsl:when test="h24/unique_in = '' or h24/raw_in = ''">0%</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="format-number(h24/unique_in div h24/raw_in, '#,###%')" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">no</xsl:attribute>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <xsl:call-template name="zero">
            <xsl:with-param name="data" select="h24/click"/>
        </xsl:call-template>
        <xsl:call-template name="zero">
            <xsl:with-param name="data" select="h24/raw_out"/>
        </xsl:call-template>

        <td>
            <xsl:choose>
                <xsl:when test="h24/raw_out = '' or h24/click = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(h24/raw_out div h24/click, '#,###%')" />
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <td>
            <xsl:choose>
                <xsl:when test="h24/raw_out = '' or h24/raw_in = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(h24/raw_out div h24/raw_in, '#,###%')" />
                </xsl:otherwise>
            </xsl:choose>
        </td>
        <td>
            <xsl:choose>
                <xsl:when test="h24/click = '' or h24/raw_in = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="format-number(h24/click div h24/raw_in, '#,###%')" />
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </tr>
</xsl:template>





<!-- #### NOTRADES #### -->
<xsl:template match="block[@controller = 'stats' and @action = 'shownotrades']/stats">
    <h2>NOTRADES in referers</h2>  
    <xsl:choose>
        <xsl:when test="h24/item"><xsl:apply-templates select="h24/item"/></xsl:when>
        <xsl:otherwise>
            <div class="empty"><xsl:value-of select="$translate[@keyword='glb_empty']"/></div>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="block[@controller = 'stats' and @action='shownotrades']/stats/h24/item">
    <xsl:value-of select="referer" /> #<b><xsl:value-of select="total" /></b># (<a href='javascript:void(0);' onclick="$('#traderForm traderurl').val('{encoded}')">add trader</a>)
    <xsl:if test="position() != last()">, </xsl:if>
</xsl:template>

<!-- ## LAYOUT ## -->
<xsl:template match="block[@controller = 'stats' and @action = 'showlayout']/stats">
    <h2>LAYOUT stats</h2>  
    <table class="tech fixOnScrollTable">
        <thead>
            <tr>
                <th>page</th>
                <th>position</th>
                <th>gallery</th>
                <th>thumb</th>
                <th>showed</th>
                <th>time</th>
            </tr>
        </thead>
        <tbody>
            <xsl:choose>
                <xsl:when test="stats"><xsl:apply-templates select="stats"/></xsl:when>
                <xsl:otherwise>
                    <tr>
                        <td colspan="6" style="text-align: center;">
                            <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                        </td>
                    </tr>
                </xsl:otherwise>
            </xsl:choose>
        </tbody>
    </table>
</xsl:template>

<xsl:template match="block[@controller = 'stats' and @action='showlayout']/stats/stats">
    <tr>
        <td><xsl:value-of select="page" /></td>
        <td><xsl:value-of select="position" /></td>
        <td><a href="{$server}gallery/{gallery_id}"><xsl:value-of select="gallery_id" /></a></td>
        <td><xsl:value-of select="thumb_id" /></td>
        <td><xsl:value-of select="showed" /></td>
        <td><xsl:value-of select="time" /></td>
    </tr>
</xsl:template>





<!-- ## PLACE ## -->
<xsl:template match="block[@controller = 'stats' and @action = 'showplace']/stats">
    <h2>PLACE stats</h2>        
    <xsl:choose>
        <xsl:when test="stats"><xsl:apply-templates select="stats"/></xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$translate[@keyword='glb_empty']"/>
        </xsl:otherwise>
    </xsl:choose>
    <div class="clear"></div>
</xsl:template>

<xsl:template match="block[@controller = 'stats' and @action = 'showplace']/stats/stats">
    <xsl:if test="preceding-sibling::*[1]/page != page or position() = 1">
        <div class="clear">PAGE: <xsl:value-of select="page"/></div>
    </xsl:if>
    <div class="position" title="page:{page} - position:{position} - ctr:{clicked div showed}">
        <xsl:attribute name="style">
            <xsl:text>background: #</xsl:text>
            <xsl:choose>
                <xsl:when test="(clicked div showed) &lt; 0.01">225486</xsl:when>
                <xsl:when test="(clicked div showed) &lt; 0.04">3380CB</xsl:when>
                <xsl:when test="(clicked div showed) &lt; 0.08">74A8DC</xsl:when>
                <xsl:when test="(clicked div showed) &lt; 0.12">BAD3ED</xsl:when>
                <xsl:when test="(clicked div showed) &lt; 0.15">FFDCA8</xsl:when>
                <xsl:when test="(clicked div showed) &lt; 0.2">FFBA51</xsl:when>
                <xsl:when test="(clicked div showed) &lt; 0.25">FF9A00</xsl:when>
                <xsl:when test="(clicked div showed) &lt; 0.3">FF4700</xsl:when>
                <xsl:when test="(clicked div showed) &lt; 0.5">FF000B</xsl:when>
                <xsl:otherwise>9A0E14</xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="clicked"/>/<xsl:value-of select="showed"/>
    </div>
</xsl:template>

<!-- ## PYRAMID ## -->
<xsl:template match="block[@controller = 'stats' and @action = 'showpyramid']/stats">
    <h2>PYRAMID stats</h2>        
    <xsl:choose>
        <xsl:when test="stats"><xsl:apply-templates select="stats"/></xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$translate[@keyword='glb_empty']"/>
        </xsl:otherwise>
    </xsl:choose>
    <div class="clear"></div>
</xsl:template>

<xsl:template match="block[@controller = 'stats' and @action = 'showpyramid']/stats/stats">
    <div class="pyramid_rank">
        <xsl:attribute name="class">
            <xsl:text>pyramid_rank </xsl:text>
            <xsl:choose>
                <xsl:when test="rank &lt; 10">r1</xsl:when>
                <xsl:when test="rank &lt; 25">r2</xsl:when>
                <xsl:when test="rank &lt; 50">r3</xsl:when>
                <xsl:when test="rank &lt; 2500">r4</xsl:when>
                <xsl:when test="rank &lt; 3750">r5</xsl:when>
                <xsl:when test="rank &lt; 5000">r6</xsl:when>
                <xsl:when test="rank &lt; 10000">r7</xsl:when>
                <xsl:when test="rank &lt; 50000">r8</xsl:when>
                <xsl:when test="rank &lt; 75000">r9</xsl:when>
                <xsl:otherwise>r10</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <strong><xsl:value-of select="name"/></strong>

        <xsl:text> / click: </xsl:text>
        <xsl:call-template name="rawzero">
            <xsl:with-param name="data" select="click"/>
        </xsl:call-template>

        <xsl:text> / in: </xsl:text>
        <xsl:call-template name="rawzero">
            <xsl:with-param name="data" select="raw_in"/>
        </xsl:call-template>

        <xsl:text> / out: </xsl:text>
        <xsl:call-template name="rawzero">
            <xsl:with-param name="data" select="raw_out"/>
        </xsl:call-template>

        <xsl:text> / ratio: </xsl:text>
        <xsl:call-template name="rawzero">
            <xsl:with-param name="data" select="ratio"/>
        </xsl:call-template>%

        <xsl:text> / return: </xsl:text>
        <xsl:call-template name="rawzero">
            <xsl:with-param name="data" select="rturn"/>
        </xsl:call-template>%
        <div class="rank"><xsl:value-of select="rank"/></div>
    </div>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/gallery.xsl ########## -->

<xsl:template match="block[@controller = 'gallery']">
    <div class="gallery">
        <xsl:apply-templates select="pager"/>
        <xsl:apply-templates select="formblock"/>
        <xsl:apply-templates select="gallery"/>
        <xsl:apply-templates select="pager"/>
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'gallery']/gallery">
    <form class="table chosenFORM" action="{$server}gallery/do" method="post">
        <div class="functions-container first">
            <div class="functions fixOnScroll">
                <span class="strong" style="padding-top: 1px;"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <div style="position: absolute; z-index: 999; left: 50%; width: 200px; margin-left -50px;">
                    <a href="#" class="subformclick"><xsl:value-of select="$translate[@keyword='gal_setsame']"/></a>
                    <div class="subform">
                        <select name="tpl_id" class="chosen-select" data-placeholder="Choose template">
                            <xsl:for-each select="../tpls/item">
                                <option value="{id}"><xsl:value-of select="name"/></option>
                            </xsl:for-each>
                        </select><br/>

                        <select name="sponsor_id" class="chosen-select" data-placeholder="{$translate[@keyword='gal_choosesponsor']}">
                            <xsl:for-each select="../sponsors/item">
                                <option value="{id}"><xsl:value-of select="name"/></option>
                            </xsl:for-each>
                        </select><br/>

                        <select name="category_id[]" multiple="multiple" class="chosen-select" data-placeholder="{$translate[@keyword='gal_choosecategory']}">
                            <xsl:for-each select="../categories/item">
                                <option value="{id}"><xsl:value-of select="name"/></option>
                            </xsl:for-each>
                        </select><br/>

                        <input type="text" name="tag" id="tag-subform" title="{$translate[@keyword='gal_choosetag']}" class="text toggleTitle" />

                        <script type="text/javascript">
                            $('.chosen-select').chosen({width:"140px",no_results_text:'Oops, nothing found!'});
                            $(document).ready(function(){$('#tag-subform').autocomplete({serviceUrl:'video/tag/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});
                        </script>

                        <input type="submit" value="{$translate[@keyword='glb_save']}" onclick="$.fn.assignAction(this, 'shareedit')" />
                        <a href="javascript:void(0);" onclick="$('body').click()" class="red"><xsl:value-of select="$translate[@keyword='frm_cancel']"/></a>
                    </div>
                </div>



                <xsl:if test="../@gallery.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_block']}" onclick="$.fn.assignAction(this, 'block')" />
                    <input type="submit" value="{$translate[@keyword='glb_activate']}" onclick="$.fn.assignAction(this, 'activate')" />
                    <!--input type="submit" value="rethumb" onclick="$.fn.assignAction(this, 'rethumb')" /-->
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'edit')" />
                </xsl:if>

                <xsl:if test="../@vcdn = 1">
                    <input type="submit" value="{$translate[@keyword='gal_cdnize']}" onclick="$.fn.assignAction(this, 'cdnize')" />
                </xsl:if>

                <xsl:if test="../@gallery.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                </xsl:if>


                <xsl:if test="1=0 and ../@gallery.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'add')" />
                </xsl:if>

                <div style="float: right; padding: 3px 5px 0 0;"><xsl:value-of select="$translate[@keyword='gal_total']"/>: <xsl:value-of select="../@total"/>, <xsl:value-of select="$translate[@keyword='gal_rotated']"/>: <xsl:value-of select="../@rotated"/></div>
            </div>
        </div>

        <div class="functions-container second">
            <div class="functions ">
                <span class="strong" style="padding-top: 1px;"><xsl:value-of select="$translate[@keyword='glb_orderby']"/>:</span>
                <select name="order">
                    <xsl:for-each select="../orders/node()">
                        <option value="{name(.)}">
                            <xsl:if test="../../@order = name(current())">
                                <xsl:attribute name="selected">selected</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="text()"/>
                        </option>
                    </xsl:for-each>
                </select>
                <select name="vector">
                    <option value="desc">desc</option>
                    <option value="asc"><xsl:if test="../@vector = 'asc'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>asc</option>
                </select>

                <xsl:choose>
                    <xsl:when test="../@action = 'showvideo'">
                        <input type="button" value="↵" onclick="location.href = '{$server}video/order/' + $(this).prevAll('select[name=order]').val() + '|' + $(this).prevAll('select[name=vector]').val()"/>
                    </xsl:when>
                    <xsl:when test="../@action = 'showimage'">
                        <input type="button" value="↵" onclick="location.href = '{$server}image/order/' + $(this).prevAll('select[name=order]').val() + '|' + $(this).prevAll('select[name=vector]').val()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <input type="button" value="↵" onclick="location.href = '{$server}gallery/order/' + $(this).prevAll('select[name=order]').val() + '|' + $(this).prevAll('select[name=vector]').val()"/>
                    </xsl:otherwise>
                </xsl:choose>


                <div style="float:right;">
                    <xsl:if test="../sponsors/item">
                        <select name="sponsor">
                            <xsl:for-each select="../sponsors/item">
                                <option value="{id}">
                                    <xsl:if test="../../@sponsor = current()/id">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="name"/>
                                </option>
                            </xsl:for-each>
                        </select>
                        <xsl:choose>
                            <xsl:when test="../@action = 'showvideo'">
                                <input type="button" value="↵" onclick="location.href = '{$server}video/filter/sponsor/' + $(this).prevAll('select[name=sponsor]').val()"/>
                            </xsl:when>
                            <xsl:when test="../@action = 'showimage'">
                                <input type="button" value="↵" onclick="location.href = '{$server}image/filter/sponsor/' + $(this).prevAll('select[name=sponsor]').val()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <input type="button" value="↵" onclick="location.href = '{$server}gallery/filter/sponsor/' + $(this).prevAll('select[name=sponsor]').val()"/>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:if>
                </div>
            </div>
        </div>

         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>id</th>
                    <xsl:if test="../@vcdn = 1">
                        <th>vcdn</th>
                    </xsl:if>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_best']" disable-output-escaping="yes"/></th>
                    <th>
                        <xsl:for-each select="../statparams/node()">
                            <span title="{local-name()}"><xsl:value-of select="text()" /></span>
                            <xsl:if test="position() != last()">
                                <xsl:text> / </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_title']" disable-output-escaping="yes"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_duration']" disable-output-escaping="yes"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_views']" disable-output-escaping="yes"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_rate']" disable-output-escaping="yes"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_categories']" disable-output-escaping="yes"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_tags']" disable-output-escaping="yes"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_created']" disable-output-escaping="yes"/></th>
                    <xsl:if test="not(@type) or @type = ''"><th><xsl:value-of select="$translate[@keyword='gal_tbl_type']" disable-output-escaping="yes"/></th></xsl:if>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_sponsor']" disable-output-escaping="yes"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_status']" disable-output-escaping="yes"/></th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="13" style="text-align: center;">
                                <xsl:if test="../@vcdn = 1">
                                    <xsl:attribute name="colspan">14</xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>id</th>
                    <xsl:if test="../@vcdn = 1">
                        <th>vcdn</th>
                    </xsl:if>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_best']"/></th>
                    <th>
                        <xsl:for-each select="../statparams/node()">
                            <span title="{local-name()}"><xsl:value-of select="text()" /></span>
                            <xsl:if test="position() != last()">
                                <xsl:text> / </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_title']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_duration']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_views']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_rate']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_categories']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_tags']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_created']"/></th>
                    <xsl:if test="not(@type) or @type = ''"><th><xsl:value-of select="$translate[@keyword='glb_type']"/></th></xsl:if>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_sponsor']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gal_tbl_status']"/></th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'gallery']/gallery/item">
    <tr id="g-{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
            <xsl:when test="status = 'error'"><xsl:attribute name="class">marked-red</xsl:attribute></xsl:when>
            <xsl:when test="status = 'grabbing' or status = 'rethumb'"><xsl:attribute name="class">marked-orange</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td><a href="{$server}{type}/{id}"><xsl:value-of select="id"/></a></td>
        <xsl:if test="../../@vcdn = 1">
            <td>
                <nobr>
                <xsl:choose>
                    <xsl:when test="vcdn_status != ''"><xsl:value-of select="$translate[@keyword=concat('gal_vcdn_',current()/vcdn_status)]"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$translate[@keyword='gal_vcdn_not_uploaded']"/></xsl:otherwise>
                </xsl:choose>
                </nobr>
            </td>
        </xsl:if>
        <td>
            <img src="/storage/{subid}/{id}/thumbs/{name}" height="15" style="cursor: pointer;" />
            <!-- xsl:if test="rotated = 1">ROT</xsl:if -->
        </td>
        <td>
            <xsl:variable name="this" select="." />
            <xsl:for-each select="../../statparams/node()">
                <span title="{name(.)}">
                    <xsl:if test="../../@order = current()">
                        <xsl:attribute name="style">font-weight: bold;</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$this/*[name() = local-name(current())]" />
                </span>

                <xsl:if test="position() != last()">
                    <xsl:text> / </xsl:text>
                </xsl:if>
            </xsl:for-each>

        </td>
        <td>
            <a href="{$server}{type}/{id}"><xsl:value-of select="title" /></a>
            <div><small><xsl:value-of select="description" /></small></div>
        </td>
        <td><xsl:value-of select="duration" /></td>
        <td><xsl:value-of select="views" /></td>
        <td><xsl:value-of select="likes" />/<xsl:value-of select="dislikes" /> = <xsl:value-of select="rate" /></td>
        <td>
            <xsl:if test="not(niches/item)">---</xsl:if>
            <xsl:for-each select="niches/item">
                <xsl:value-of select="name"/>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </td>
        <td>
            <xsl:if test="not(tags/item)">---</xsl:if>
            <xsl:for-each select="tags/item">
                <xsl:value-of select="text()"/>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </td>
        <td title="{$translate[@keyword='gal_tbl_published']}: {published}"><xsl:value-of select="created" /></td>
        <xsl:if test="not(../@type) or ../@type = ''"><td><xsl:value-of select="type" /></td></xsl:if>
        <td><xsl:value-of select="sponsor" /></td>
        <td><xsl:value-of select="status" /></td>
    </tr>
</xsl:template>

















<xsl:template match="block[@controller = 'gallery' and @action = 'showone']/gallery">

    <form class="table" action="{$server}gallery/do" method="post">
        <div class="functions-container">
            <div class="functions">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <input type="hidden" value="{id}" name="id[]" />

                <xsl:if test="../@gallery.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_block']}" onclick="$.fn.assignAction(this, 'block')" />
                    <input type="submit" value="{$translate[@keyword='glb_activate']}" onclick="$.fn.assignAction(this, 'activate')" />
                    <!--input type="submit" value="rethumb" onclick="$.fn.assignAction(this, 'rethumb')" /-->
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'edit')" />
                </xsl:if>

                <xsl:if test="../@vcdn = 1">
                    <input type="submit" value="{$translate[@keyword='gal_cdnize']}" onclick="$.fn.assignAction(this, 'cdnize')" />
                </xsl:if>

                <xsl:if test="../@gallery.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                </xsl:if>

            </div>
        </div>

        <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <script type="text/javascript" src="/kt_player/kt_player.js"></script>
        <xsl:for-each select="videos/item">
            <div style="float: right;">
                <div id="kt_player{i}" style="visibility: hidden">
                    <a href="http://adobe.com/go/getflashplayer">This page requires Adobe Flash Player</a>
                </div>
                <script type="text/javascript">
                    var flashvars = {
                        video_url: '<xsl:value-of select="video_url"/>',
                        preview_url: '<xsl:value-of select="thumb_url"/>',
                        skin: '2',
                        bt: '0',
                        embed: '0'
                    }
                    var params = {allowfullscreen: 'true', allowscriptaccess: 'always'};
                    kt_player('kt_player<xsl:value-of select="i" />', '/kt_player/kt_player.swf', '320', '210', flashvars, params);
                </script>
            </div>
        </xsl:for-each>

        <div style="float: right; position:relative;">
            <xsl:if test="../@gallery.add = 1">
                <div style="position: absolute; z-index:10;">
                <input type="submit" value="{$translate[@keyword='gal_change_cover']}" class="right-action" onclick="$.fn.assignAction(this, 'changeCover')" /><input type="submit" value="{$translate[@keyword='gal_drop_cover']}" class="right-action" onclick="$.fn.assignAction(this, 'dropCover')" />
                </div>
            </xsl:if>
            <img src="{cover}" height="210"/>
        </div>



        <div><strong><xsl:value-of select="$translate[@keyword='gal_tbl_title']" />: </strong><b class="green"><xsl:value-of select="title"/></b></div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_seotitle']" />: </strong><xsl:value-of select="seotitle"/><small class="gray">.html</small></div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_tbl_created']" />: </strong><xsl:value-of select="created"/></div>
        <div>
            <strong><xsl:value-of select="$translate[@keyword='gal_tbl_published']" />: </strong>
            <xsl:choose>
                <xsl:when test="published != '0000-00-00 00:00:00'"><xsl:value-of select="published"/></xsl:when>
                <xsl:otherwise><span class="red"><xsl:value-of select="$translate[@keyword='gal_not_published']" /></span></xsl:otherwise>
            </xsl:choose>
        </div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_tbl_duration']" />: </strong><xsl:value-of select="duration"/></div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_description']" />: </strong><xsl:value-of select="description"/><xsl:if test="description = ''">---</xsl:if></div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_fhg_url']" />: </strong><xsl:value-of select="url"/><xsl:if test="url = ''">---</xsl:if></div>
        <div><strong><xsl:value-of select="$translate[@keyword='glb_type']" />: </strong><xsl:value-of select="type"/></div>
        <div><strong><xsl:value-of select="$translate[@keyword='glb_status']" />: </strong><xsl:value-of select="status"/></div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_template']" />: </strong>
            <xsl:choose>
                <xsl:when test="gm_name = ''">default</xsl:when>
                <xsl:otherwise><xsl:value-of select="gm_name"/></xsl:otherwise>
            </xsl:choose>
            <xsl:text> (</xsl:text>
            <a href="/watch/{id}/{seotitle}.html"><xsl:value-of select="$translate[@keyword='gal_face_link']" /></a>
            <xsl:text>)</xsl:text>
        </div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_tbl_sponsor']" />: </strong>
            <xsl:choose>
                <xsl:when test="sponsor = ''"><xsl:value-of select="$translate[@keyword='gal_nosponsor']" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="sponsor"/></xsl:otherwise>
            </xsl:choose>
        </div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_tbl_categories']" />: </strong>
            <xsl:if test="not(niches/item)">---</xsl:if>
            <xsl:for-each select="niches/item">
                <xsl:value-of select="name"/>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </div>
        <div><strong><xsl:value-of select="$translate[@keyword='gal_tbl_tags']" />: </strong>
            <xsl:if test="not(tags/item)">---</xsl:if>
            <xsl:for-each select="tags/item">
                <xsl:value-of select="text()"/>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </div>

        <xsl:if test="../@vcdn = 1">
            <div>
                <strong>vCDN: </strong>
                <xsl:choose>
                    <xsl:when test="vcdn_status != ''"><xsl:value-of select="$translate[@keyword=concat('gal_vcdn_',current()/vcdn_status)]"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$translate[@keyword='gal_vcdn_not_uploaded']"/></xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>

            <div class="clear"></div>
    </form>

    <xsl:apply-templates select="files" />

</xsl:template>

<xsl:template match="block[@controller = 'gallery' and @action = 'showone']/gallery/files">
    <form class="table" action="{$server}gallery/do" method="post">
        <div class="functions-container first">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>
                <input type="hidden" value="{../id}" name="gallery_id" />

                <xsl:if test="../../@gallery.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'deleteFile')" class="kill" />
                </xsl:if>
                <xsl:if test="../../@gallery.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'addFile')" />
                </xsl:if>
            </div>
        </div>

        <div class="functions-container second">
            <div class="functions ">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_orderby']"/>:</span>
                <select name="order">
                    <xsl:for-each select="../../orders/node()">
                        <option value="{name(.)}">
                            <xsl:if test="../../@order = name(current())">
                                <xsl:attribute name="selected">selected</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="text()"/>
                        </option>
                    </xsl:for-each>
                </select>
                <select name="vector">
                    <option value="desc">desc</option>
                    <option value="asc"><xsl:if test="../../@vector = 'asc'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>asc</option>
                </select>
                <input type="button" value="↵" onclick="location.href = '{$server}gallery/{../id}/order/' + $(this).prevAll('select[name=order]').val() + '/' + $(this).prevAll('select[name=vector]').val()"/>
            </div>
        </div>

         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th width="340">thmb</th>
                    <th>name</th>
                    <th>type</th>
                    <th>status</th>
                    <th>showed</th>
                    <th>clicked</th>
                    <th>ctr</th>
                    <th>rating</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="9" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'gallery' and @action = 'showone']/gallery/files/item">
    <tr>
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'error'"><xsl:attribute name="class">marked-red</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td><img src="{url}thumbs/{name}" /></td>
        <td>
            <a href="{url}large/{name}"><xsl:value-of select="name" /></a>
        </td>
        <td><xsl:value-of select="type" /></td>
        <td><xsl:value-of select="status" /></td>
        <td><xsl:if test="../../../@order='showed'"><xsl:attribute name="class">orderedby</xsl:attribute></xsl:if><xsl:value-of select="showed" /></td>
        <td><xsl:if test="../../../@order='clicked'"><xsl:attribute name="class">orderedby</xsl:attribute></xsl:if><xsl:value-of select="clicked" /></td>
        <td><xsl:if test="../../../@order='ctr'"><xsl:attribute name="class">orderedby</xsl:attribute></xsl:if><xsl:value-of select="ctr" /></td>
        <td><xsl:if test="../../../@order='rating'"><xsl:attribute name="class">orderedby</xsl:attribute></xsl:if><xsl:value-of select="rating" /></td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/gallerymaker.xsl ########## -->

<xsl:template match="block[@controller = 'gallerymaker']">
    <div class="gallerymaker">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'gallerymaker']/gallerymaker">
    <form class="table" action="{$server}gallerymaker/do" method="post">
        <div class="functions-container first">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <xsl:if test="../@gallerymaker.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'edit')" />
                </xsl:if>

                <xsl:if test="../@gallerymaker.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                </xsl:if>

                <xsl:if test="../@gallerymaker.edit = 1">
                    <input type="submit" value="{$translate[@keyword='gm_proc_subs']}" onclick="$.fn.assignAction(this, 'renderSubs')" />
                </xsl:if>

                <xsl:if test="../@gallerymaker.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'add')" />
                </xsl:if>

            </div>
        </div>

         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>id</th>
                    <th><xsl:value-of select="$translate[@keyword='gm_tpl_name']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gm_tpls']"/></th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="4" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>id</th>
                    <th><xsl:value-of select="$translate[@keyword='gm_tpl_name']"/></th>
                    <th><xsl:value-of select="$translate[@keyword='gm_tpls']"/></th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'gallerymaker']/gallerymaker/item">
    <tr>
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
            <xsl:when test="status = 'error'"><xsl:attribute name="class">marked-red</xsl:attribute></xsl:when>
            <xsl:when test="status = 'grabbing' or status = 'rethumb'"><xsl:attribute name="class">marked-orange</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td><xsl:value-of select="id"/></td>
        <td>
            <xsl:value-of select="name" />
            <xsl:if test="error">
                <b style="color: red;"> - <xsl:value-of select="error" /></b>
            </xsl:if>
        </td>
        <td><input type='hidden' name='name[{id}]'/>
        <xsl:apply-templates select="tpls/item" />
        <xsl:text> ||||| </xsl:text>
        <xsl:apply-templates select="subs/item" />

        <a href="javascript:void(0);" onclick="$(this).closest('table').find('input[type=checkbox]').prop('checked', false);$(this).closest('tr').find('input[type=checkbox]').prop('checked',true);$.fn.assignAction(this, 'addTPL'); $(this).closest('form').submit()" class="link-add" style="float: right; margin-left: 20px;">+</a></td>
    </tr>
</xsl:template>


<xsl:template match="tpls/item">
    <xsl:if test="text() != 'main.tpl'">
    	<span>
    		<xsl:attribute name="style">
    			<xsl:choose>
    				<xsl:when test="not(../../subs/item[text() = current()/@name])">color:#000080;</xsl:when>
    				<xsl:otherwise>color:#008000;</xsl:otherwise>
    			</xsl:choose>
    		</xsl:attribute>
            <xsl:value-of select="text()"/>
        </span>
        <xsl:text> </xsl:text>
        (<a href="javascript:void(0);" onclick="$(this).closest('table').find('input[type=checkbox]').prop('checked', false);$(this).closest('td').find('input[type=hidden]').val('{@name}');$(this).closest('tr').find('input[type=checkbox]').prop('checked',true);$.fn.assignAction(this, 'editTPL'); $(this).closest('form').submit()" title="{$translate[@keyword='glb_edit']}">e</a>)
        (<a href="javascript:void(0);" onclick="$(this).closest('table').find('input[type=checkbox]').prop('checked', false);$(this).closest('td').find('input[type=hidden]').val('{@name}');$(this).closest('tr').find('input[type=checkbox]').prop('checked',true);$.fn.assignAction(this, 'deleteTPL'); $(this).closest('form').submit()" title="{$translate[@keyword='glb_delete']}">x</a>)
        <xsl:if test="position() != last() and following-sibling::text() != 'main.tpl'">
            <xsl:text>, </xsl:text>
        </xsl:if>
    </xsl:if>
</xsl:template>


<xsl:template match="subs/item">
	<xsl:if test="not(../../tpls/item[@name = current()/text()])">
       	<span style="color:#dd0000;">
			<xsl:value-of select="text()"/>
		</span>
		<xsl:text> </xsl:text>
	</xsl:if>
</xsl:template>



<xsl:template match="block[@controller = 'gallerymaker' and @action = 'showone']/gallerymaker">
    <h2><xsl:value-of select="title"/></h2>

    <form class="table" action="{$server}gallerymaker/do" method="post">
        <div class="functions-container">
            <div class="functions">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <input type="hidden" value="{id}" name="id[]" />

                <xsl:if test="../@gallerymaker.edit = 1">
                    <input type="submit" value="block" onclick="$.fn.assignAction(this, 'block')" />
                    <input type="submit" value="activate" onclick="$.fn.assignAction(this, 'activate')" />
                    <input type="submit" value="rethumb" onclick="$.fn.assignAction(this, 'rethumb')" />
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'edit')" />
                </xsl:if>

                <xsl:if test="../@gallerymaker.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                </xsl:if>

                <xsl:if test="1=0 and ../@gallerymaker.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'add')" />
                </xsl:if>
            </div>
        </div>

        <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <div><strong><xsl:value-of select="$translate[@keyword='glb_date']" />created: </strong><xsl:value-of select="created"/></div>
        <div><strong><xsl:value-of select="$translate[@keyword='glb_description']" />descr.: </strong><xsl:value-of select="description"/></div>
        <div><strong><xsl:value-of select="$translate[@keyword='glb_url']" />URL: </strong><xsl:value-of select="url"/></div>
        <div><strong><xsl:value-of select="$translate[@keyword='glb_seotitle']" />SEOtitle: </strong><xsl:value-of select="seotitle"/></div>
        <div><strong><xsl:value-of select="$translate[@keyword='glb_type']" />: </strong><xsl:value-of select="type"/></div>
        <div><strong><xsl:value-of select="$translate[@keyword='glb_status']" />: </strong><xsl:value-of select="status"/></div>
    </form>

    <xsl:apply-templates select="files" />

</xsl:template>



<xsl:template match="block[@controller = 'gallerymaker' and @action = 'showone']/gallerymaker/files">
    <form class="table" action="{$server}gallerymaker/do" method="post">
        <div class="functions-container first">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <xsl:if test="../../@gallerymaker.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'deleteFile')" class="kill" />
                </xsl:if>
            </div>
        </div>

        <div class="functions-container second">
            <div class="functions ">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_orderby']"/>:</span>
                <select name="order">
                    <xsl:for-each select="../../orders/node()">
                        <option value="{name(.)}">
                            <xsl:if test="../../@order = name(current())">
                                <xsl:attribute name="selected">selected</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="text()"/>
                        </option>
                    </xsl:for-each>
                </select>
                <select name="vector">
                    <option value="desc">desc</option>
                    <option value="asc"><xsl:if test="../../@vector = 'asc'"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>asc</option>
                </select>
                <input type="button" value="↵" onclick="location.href = '{$server}gallerymaker/{../id}/order/' + $(this).prevAll('select[name=order]').val() + '/' + $(this).prevAll('select[name=vector]').val()"/>
            </div>
        </div>

         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th width="340">thmb</th>
                    <th>name</th>
                    <th>size</th>
                    <th>type</th>
                    <th>status</th>
                    <th>showed</th>
                    <th>clicked</th>
                    <th>ctr</th>
                    <th>rating</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="5" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'gallerymaker' and @action = 'showone']/gallerymaker/files/item">
    <tr>
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'error'"><xsl:attribute name="class">marked-red</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td><img src="{url}thumbs/{name}" /></td>
        <td>
            <a href="{url}original/{name}"><xsl:value-of select="name" /></a>
        </td>
        <td><xsl:value-of select="size" /></td>
        <td><xsl:value-of select="type" /></td>
        <td><xsl:value-of select="status" /></td>
        <td><xsl:if test="../../../@order='showed'"><xsl:attribute name="class">orderedby</xsl:attribute></xsl:if><xsl:value-of select="showed" /></td>
        <td><xsl:if test="../../../@order='clicked'"><xsl:attribute name="class">orderedby</xsl:attribute></xsl:if><xsl:value-of select="clicked" /></td>
        <td><xsl:if test="../../../@order='ctr'"><xsl:attribute name="class">orderedby</xsl:attribute></xsl:if><xsl:value-of select="ctr" /></td>
        <td><xsl:if test="../../../@order='rating'"><xsl:attribute name="class">orderedby</xsl:attribute></xsl:if><xsl:value-of select="rating" /></td>
    </tr>
</xsl:template>

<!-- ######### /home/tigra/www/subs/subs/transformers/grabber.xsl ########## -->

<xsl:template match="block[@controller = 'grabber']">
    <div class="grabber">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'grabber']/grabber">
    <form class="table" action="{$server}grabber/do" method="post">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <div style="position: absolute; left: 50%; width: 100px; margin-left -50px;">total: <xsl:value-of select="../@total"/></div>

                <xsl:if test="../@grabber.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_restart']}" onclick="$.fn.assignAction(this, 'restart')" />
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                </xsl:if>

                <!--xsl:if test="../@grabber.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'add')" />
                </xsl:if-->
            </div>
        </div>

         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <script type='text/javascript'>
            jQuery(function($) {
                $.fn.tick = function() {
                    $('body').oneTime(5000, function(){$.fn.tickGo();});
                }
                $.fn.tickGo = function() {
                    idata = new Array();

                    $('#queue tbody tr td.id').each(function(index, value){
                        console.log(value);

                        idata.push($(value).find('input').val());
                    });

                    $.getJSON(server+'grabber/status', {'ids':idata}, function(data) {
                        $(data).each(function(i,cur) {
                            if (!cur.error) {
                                reerror = /error/

                                if (reerror.test(cur.status)) {
                                    $('#row_'+cur.id).addClass('marked-red');
                                }
                                $('#row_'+cur.id+' td.status').text(cur.status);
                                $('#row_'+cur.id+' td.type').text(cur.type);
                                if (cur.gallery_id) {
                                    $('#row_'+cur.id+' td.title a').attr('href','gallery/'+cur.gallery_id);
                                } else {
                                    $('#row_'+cur.id+' td.title a').removeAttr('href');
                                }
                                $('#row_'+cur.id+' td.title a').text(cur.title);
                                $('#row_'+cur.id+' td.title small').text(cur.description);


                            } else if (cur.error == 'deleted') {
                                $('#row_'+cur.id).addClass('marked-orange').oneTime(760, function(){$(this).remove();});
                            }
                        });
                    });
                    $.fn.tick();
                }
                $.fn.tickGo();
            });
        </script>

        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>url</th>
                    <th>title</th>
                    <th>created</th>
                    <th>status</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="5" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>url</th>
                    <th>title</th>
                    <th>created</th>
                    <th>status</th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'grabber']/grabber/item">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td class="id"><input type="checkbox" name="id[]" value="{id}" /></td>
        <td class="url">
            <a href="{url}"><xsl:value-of select="url" /></a>
        </td>
        <td class="title">
            <a href="gallery/{gallery_id}"><xsl:value-of select="title" /></a>
            <div><small><xsl:value-of select="description" /></small></div>
        </td>
        <td><xsl:value-of select="created" /></td>
        <td class="status"><xsl:value-of select="status" /></td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/settings.xsl ########## -->


<xsl:template match="block[@controller = 'settings']">
    <div class="settings form-wrapper">
        <fieldset>
        <form action="" method="post">
             <xsl:if test="errors/error">
                <div class="error">
                    <ul>
                        <xsl:for-each select="errors/error">
                            <li><xsl:value-of select="text()" /></li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>

            <xsl:if test="confirms/confirm">
                <div class="confirm">
                    <ul>
                        <xsl:for-each select="confirms/confirm">
                            <li><xsl:value-of select="text()" /></li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>

            <input type="hidden" name="formname" value="settings"/>
            <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
            <div class="field buttonset">
                <div class="control" style="width:100%;"><input type="submit" value="{$translate[@keyword='frm_submit']}"/></div>
                <div class="clear"></div>
            </div>

        </form>
        </fieldset>
    </div>
</xsl:template>


<xsl:template match="block[@controller = 'settings' and (@action = 'general' or @action = 'cdn' or @action = 'rotator' or @action = 'trade' or @action = 'profiles' or @action = 'profilesEdit')]">
    <div class="task">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'settings' and (@action = 'profiles' or @action = 'profilesEdit')]">
    <div class="task">
        <xsl:apply-templates select="profiles" />

        <div class="settings form-wrapper">
            <fieldset>
            <form action="" method="post" enctype="multipart/form-data">
                 <xsl:if test="formblock/errors/error">
                    <div class="error">
                        <ul>
                            <xsl:for-each select="formblock/errors/error">
                                <li>
                                    <xsl:choose>
                                        <xsl:when test="message != ''"><xsl:value-of select="message" /></xsl:when>
                                        <xsl:otherwise><xsl:value-of select="text()" /></xsl:otherwise>
                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </xsl:if>

                <xsl:if test="formblock/confirms/confirm">
                    <div class="confirm">
                        <ul>
                            <xsl:for-each select="formblock/confirms/confirm">
                                <li>
                                    <xsl:choose>
                                        <xsl:when test="message != ''"><xsl:value-of select="message" /></xsl:when>
                                        <xsl:otherwise><xsl:value-of select="text()" /></xsl:otherwise>
                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </xsl:if>

                <input type="hidden" name="formname" value="settings.profiles"/>
                <input type="hidden" name="group[main]" value="main"/>

                <style>
                    .subfield {
                        float: left;
                        margin-right: 10px;
                    }
                    .chosen-select {
                        width: 150px;
                    }
                </style>

                <div class="field">
                    <div class="subfield">
                        <div class="title" style="width:100%;"><b><xsl:value-of select="$translate[@keyword='set_name']" /></b></div>
                        <div style="">
                            <input type="text" name="name[main]" value="{formblock/formdata/fieldgroup/field[@name='name']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'name']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_ext']" />
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_ext_?']" /></span>
                        </div>
                        <div style="">
                            <input type="text" name="ext[main]" value="{formblock/formdata/fieldgroup/field[@name='ext']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'ext']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_format']" />
                        </div>
                        <div style="">
                            <select name="format[main]">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'ext']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format']/options/option">
                                    <option value="{@value}"><xsl:value-of select="text()"/></option>
                                </xsl:for-each>
                            </select>
                        </div>
                    </div>
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_bitrate']" />
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_bitrate_?']" /></span>
                        </div>
                        <div style="">
                            <input type="text" name="bitrate[main]" value="{formblock/formdata/fieldgroup/field[@name='bitrate']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'bitrate']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>
                    <div class="clear"></div>
                </div>


                <div class="field">
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_converter']" />
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_converter_?']" /></span>
                        </div>
                        <div style="">
                            <input type="text" name="converter[main]" value="{formblock/formdata/fieldgroup/field[@name='converter']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'converter']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_streamer']" />
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_streamer_?']" /></span>
                        </div>
                        <div style="">
                            <input type="text" name="streamer[main]" value="{formblock/formdata/fieldgroup/field[@name='streamer']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'streamer']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_mogrify']" />
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_mogrify_?']" /></span>
                        </div>
                        <div style="">
                            <input type="text" name="mogrify[main]" value="{formblock/formdata/fieldgroup/field[@name='mogrify']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'mogrify']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>

                    <div class="clear"></div>
                </div>


                <div class="field">
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_convert_cmd']" />
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_convert_cmd_?']" /></span>
                        </div>
                        <div style="">
                            <input type="text" name="convert_cmd[main]" value="{formblock/formdata/fieldgroup/field[@name='convert_cmd']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'convert_cmd']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_thumber_cmd']" />
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thumber_cmd_?']" /></span>
                        </div>
                        <div style="">
                            <input type="text" name="thumber_cmd[main]" value="{formblock/formdata/fieldgroup/field[@name='thumber_cmd']/value}" >
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'thumber_cmd']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>
                    <div class="subfield">
                        <div class="title" style="width:100%;">
                            <xsl:value-of select="$translate[@keyword='set_mogrify_cmd']" />
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_mogrify_cmd_?']" /></span>
                        </div>
                        <div style="">
                            <input type="text" name="mogrify_cmd[main]" value="{formblock/formdata/fieldgroup/field[@name='mogrify_cmd']/value}" >
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'mogrify_cmd']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>
                    </div>

                    <div class="clear"></div>
                </div>


                <div class="field">
                    <div class="subfield">
                        <label><input type="checkbox" name="resize[main]" value="1" onclick="$(this).closest('.field').find('.none').toggle($(this).prop('checked')).find('input').eq(0).focus();"><xsl:if test="formblock/formdata/fieldgroup/field[@name='resize']/value = 1"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_resize_video']" />?</label>
                    </div>
                    <div class="subfield none">
                        <xsl:if test="formblock/formdata/fieldgroup/field[@name='resize']/value = 1"><xsl:attribute name="style">display: block; </xsl:attribute></xsl:if>
                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='set_w']" />:</div>
                        <div style="float: left;">
                            <input type="text" name="w[main]" style="width: 30px;" value="{formblock/formdata/fieldgroup/field[@name='w']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'w']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;"><xsl:value-of select="$translate[@keyword='set_h']" />:</div>
                        <div style="float: left;">
                            <input type="text" name="h[main]" style="width: 30px;" value="{formblock/formdata/fieldgroup/field[@name='h']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'h']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 10px; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='set_aspect']" />:</div>
                        <div style="float: left; margin: 3px 3px 0 0;">
                            <label><input type="radio" name="aspect[main]" value="1"><xsl:if test="formblock/formdata/fieldgroup/field[@name='aspect']/value = 1"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_aspect1']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_aspect1_?']" /></span>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;">
                            <label><input type="radio" name="aspect[main]" value="2" ><xsl:if test="formblock/formdata/fieldgroup/field[@name='aspect']/value = 2"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_aspect2']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_aspect2_?']" /></span>
                        </div>
                    </div>
                    <div class="clear"></div>
                </div>


                <!-- SMALLER THUMB -->
                <div class="field">
                    <div class="subfield">
                        <div class="title" style="width: auto; margin: 3px 3px 0 0; padding-left: 5px;"><b><xsl:value-of select="$translate[@keyword='set_smaller_thmb']" /></b>:<span class="help"><xsl:value-of select="$translate[@keyword='set_smaller_thmb_?']" /></span></div>
                    </div>

                    <div class="clear"></div>
                    <div class="subfield">
                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='set_w']" />:</div>
                        <div style="float: left;">
                            <input type="text" name="st_w[main]" style="width: 30px;" value="{formblock/formdata/fieldgroup/field[@name='st_w']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'st_w']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;"><xsl:value-of select="$translate[@keyword='set_h']" />:</div>
                        <div style="float: left;">
                            <input type="text" name="st_h[main]" style="width: 30px;" value="{formblock/formdata/fieldgroup/field[@name='st_h']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'st_h']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;"><xsl:value-of select="$translate[@keyword='set_q']" />:</div>
                        <div style="float: left;">
                            <input type="text" name="st_q[main]" style="width: 30px;" value="{formblock/formdata/fieldgroup/field[@name='st_q']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'st_q']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>

                        <div class="clear"></div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='set_thmb_aspect']" />:</div>
                        <div style="float: left; margin: 3px 3px 0 0;">
                            <label><input type="radio" name="st_aspect[main]" value="1" onclick="$(this).closest('.field').find('.none').hide();$(this).closest('div').next('.none').show();"><xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 1"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_thmb_aspect1']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thmb_aspect1_?']" /></span>
                        </div>
                        <div class="none" style="float: left; margin: 3px 3px 0 0;">
                            <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 1"><xsl:attribute name="style">float: left; margin: 3px 3px 0 0; display: block;</xsl:attribute></xsl:if>
                            <select name="st_aspect_gravity[main]">
                                <option value="Center">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'Center'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_Center']" />
                                </option>
                                <option value="North">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'North'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_North']" />
                                </option>
                                <option value="NorthWest">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'NorthWest'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_NorthWest']" />
                                </option>
                                <option value="West">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'West'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_West']" />
                                </option>
                                <option value="SouthWest">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'SouthWest'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_SouthWest']" />
                                </option>
                                <option value="South">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'South'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_South']" />
                                </option>
                                <option value="SouthEast">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'SouthEast'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_SouthEast']" />
                                </option>
                                <option value="East">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'East'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_East']" />
                                </option>
                                <option value="NorthEast">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect_gravity']/value = 'NorthEast'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_NorthEast']" />
                                </option>
                            </select>
                        </div>


                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;">
                            <label><input type="radio" name="st_aspect[main]" value="2" onclick="$(this).closest('.field').find('.none').hide();$(this).closest('div').next('.none').show().find('input').eq(0).focus();" ><xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 2"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_thmb_aspect2']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thmb_aspect2_?']" /></span>
                        </div>
                        <div class="none fleft">
                            <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 2"><xsl:attribute name="style">display: block;</xsl:attribute></xsl:if>
                            <div style="float: left; margin: 3px 3px 0 0;"><xsl:value-of select="$translate[@keyword='set_thmb_aspect_color']" /></div>
                            <div style="float: left; margin: 3px 3px 0 0;">
                                <input type="text" name="st_aspect_color[main]" id="st_aspect_color" title="color" class="text" style="width: 60px;" value="{formblock/formdata/fieldgroup/field[@name='st_aspect_color']/value}" />
                            </div>
                        </div>


                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;">
                            <label><input type="radio" name="st_aspect[main]" value="3" onclick="$(this).closest('.field').find('.none').hide();" ><xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 3"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_thmb_aspect3']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thmb_aspect3_?']" /></span>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;">
                            <label><input type="radio" name="st_aspect[main]" value="4" onclick="$(this).closest('.field').find('.none').hide();" ><xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 4"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_thmb_aspect4']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thmb_aspect4_?']" /></span>
                        </div>
                    </div>
                    <div class="clear"></div>
                </div>


                <!-- BIGGER THUMB -->
                <div class="field">
                    <div class="subfield">
                        <div class="title" style="width: auto; margin: 3px 3px 0 0; padding-left: 5px;"><b><xsl:value-of select="$translate[@keyword='set_bigger_thmb']" /></b>:<span class="help"><xsl:value-of select="$translate[@keyword='set_bigger_thmb_?']" /></span></div>
                    </div>

                        <div class="clear"></div>
                    <div class="subfield">
                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='set_w']" />:</div>
                        <div style="float: left;">
                            <input type="text" name="bt_w[main]" style="width: 30px;" value="{formblock/formdata/fieldgroup/field[@name='bt_w']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'bt_w']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;"><xsl:value-of select="$translate[@keyword='set_h']" />:</div>
                        <div style="float: left;">
                            <input type="text" name="bt_h[main]" style="width: 30px;" value="{formblock/formdata/fieldgroup/field[@name='bt_h']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'bt_h']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;"><xsl:value-of select="$translate[@keyword='set_q']" />:</div>
                        <div style="float: left;">
                            <input type="text" name="bt_q[main]" style="width: 30px;" value="{formblock/formdata/fieldgroup/field[@name='bt_q']/value}">
                                <xsl:if test="formblock/errors/error[@group='main' and fields/field = 'bt_q']/message"><xsl:attribute name="class">error</xsl:attribute></xsl:if>
                            </input>
                        </div>

                        <div class="clear"></div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='set_thmb_aspect']" />:</div>
                        <div style="float: left; margin: 3px 3px 0 0;">
                            <label><input type="radio" name="bt_aspect[main]" value="1" onclick="$(this).closest('.field').find('.none').hide();$(this).closest('div').next('.none').show();" ><xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 1"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_thmb_aspect1']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thmb_aspect1_?']" /></span>
                        </div>
                        <div class="none" style="float: left; margin: 3px 3px 0 0;">
                            <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect']/value = 1"><xsl:attribute name="style">float: left; margin: 3px 3px 0 0; display: block;</xsl:attribute></xsl:if>
                            <select name="bt_aspect_gravity[main]">
                                <option value="Center">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'Center'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_Center']" />
                                </option>
                                <option value="North">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'North'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_North']" />
                                </option>
                                <option value="NorthWest">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'NorthWest'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_NorthWest']" />
                                </option>
                                <option value="West">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'West'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_West']" />
                                </option>
                                <option value="SouthWest">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'SouthWest'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_SouthWest']" />
                                </option>
                                <option value="South">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'South'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_South']" />
                                </option>
                                <option value="SouthEast">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'SouthEast'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_SouthEast']" />
                                </option>
                                <option value="East">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'East'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_East']" />
                                </option>
                                <option value="NorthEast">
                                    <xsl:if test="formblock/formdata/fieldgroup/field[@name='bt_aspect_gravity']/value = 'NorthEast'">
                                        <xsl:attribute name="selected">selected</xsl:attribute>
                                    </xsl:if>
                                    <xsl:value-of select="$translate[@keyword='set_thmb_aspect_gravity_NorthEast']" />
                                </option>
                            </select>
                        </div>


                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;">
                            <label><input type="radio" name="bt_aspect[main]" value="2" onclick="$(this).closest('.field').find('.none').hide();$(this).closest('div').next('.none').show().find('input').eq(0).focus();" ><xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 2"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_thmb_aspect2']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thmb_aspect2_?']" /></span>
                        </div>
                        <div class="none fleft">
                            <xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 2"><xsl:attribute name="style">float: left; margin: 3px 3px 0 0; display: block;</xsl:attribute></xsl:if>
                            <div style="float: left; margin: 3px 3px 0 0;"><xsl:value-of select="$translate[@keyword='set_thmb_aspect_color']" /></div>
                            <div style="float: left; margin: 3px 3px 0 0;">
                                <input type="text" name="bt_aspect_color[main]" id="bt_aspect_color" title="color" class="text" style="width: 60px;" value="{formblock/formdata/fieldgroup/field[@name='bt_aspect_color']/value}" />
                            </div>
                        </div>


                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;">
                            <label><input type="radio" name="bt_aspect[main]" value="3" onclick="$(this).closest('.field').find('.none').hide();"  ><xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 3"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_thmb_aspect3']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thmb_aspect3_?']" /></span>
                        </div>

                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px;">
                            <label><input type="radio" name="bt_aspect[main]" value="4" onclick="$(this).closest('.field').find('.none').hide();"  ><xsl:if test="formblock/formdata/fieldgroup/field[@name='st_aspect']/value = 4"><xsl:attribute name="checked">checked</xsl:attribute></xsl:if></input> <xsl:value-of select="$translate[@keyword='set_thmb_aspect4']" /></label>
                            <span class="help"><xsl:value-of select="$translate[@keyword='set_thmb_aspect4_?']" /></span>
                        </div>
                    </div>
                    <div class="clear"></div>
                </div>




                <script type="text/javascript">
                    <xsl:text>$(document).ready(function(){</xsl:text>
                        <xsl:text>$("#st_aspect_color,#bt_aspect_color").colorpicker({
                            /*colorFormat:  'RGBA',*/
                            parts:              ['map', 'bar', 'hex', 'preview', 'footer'],
                            alpha:          false,
                            showOn:         'focus click alt',
                            modal:          false,
                            regional:       '</xsl:text><xsl:value-of select="$lang" /><xsl:text>',
                            buttonColorize: false,
                            showNoneButton: false,
                            showCloseButton:    false,
                            showCancelButton:   false,
                            closeOnEscape:      true,
                            okOnEnter: true,
                            altProperties: 'border-color,color',
                            altAlpha: false,
                            layout: {
                                map:        [0, 1, 1, 1],   // Left, Top, Width, Height (in table cells).
                                bar:        [1, 1, 1, 1],
                                hex:        [1, 0, 1, 1],
                                preview:    [0, 0, 1, 1]
                            },
                            part:   {
                                map:        { size: 128 },
                                bar:        { size: 128 },
                                hex:        { size: 128 }
                            }
                        });</xsl:text>
                    <xsl:text>});</xsl:text>
                </script>



                <div class="field buttonset">
                    <div class="control" style="width:100%;"><input type="submit" value="{$translate[@keyword='frm_submit']}"/></div>
                    <div class="clear"></div>
                </div>

            </form>
            </fieldset>
        </div>

    </div>
</xsl:template>


<xsl:template match="block[@controller = 'settings' and @action = 'profiles']/profiles">
    <xsl:apply-templates select="item"/>
</xsl:template>
<xsl:template match="block[@controller = 'settings' and @action = 'profiles']/profiles/item">
    <div class="video_profile killme">
        <a href="settings/profiles/edit/{id}"><xsl:value-of select="$translate[@keyword='glb_edit']"/></a><a href="settings/profiles/delete/{id}" class="red overkill fright" ><xsl:value-of select="$translate[@keyword='glb_delete']"/></a>
        <dl>
            <dt><xsl:value-of select="$translate[@keyword='set_name']" /></dt><dd>: <b><xsl:apply-templates select="name"/></b></dd>
            <dt><xsl:value-of select="$translate[@keyword='set_ext']" /></dt><dd>: <xsl:apply-templates select="video/ext"/></dd>
            <xsl:if test="video/resize = 1">
                <dt><xsl:value-of select="$translate[@keyword='set_resize_video']" /></dt><dd>: <xsl:apply-templates select="video/w"/>x<xsl:apply-templates select="video/h"/></dd>
            </xsl:if>
            <dt><xsl:value-of select="$translate[@keyword='set_smaller_thmb']" /></dt><dd>: <xsl:apply-templates select="st/w"/>x<xsl:apply-templates select="st/h"/></dd>
            <dt><xsl:value-of select="$translate[@keyword='set_bigger_thmb']" /></dt><dd>: <xsl:apply-templates select="bt/w"/>x<xsl:apply-templates select="bt/h"/></dd>
        </dl>
    </div>
</xsl:template>





<!-- COUNTRIES -->
<xsl:template match="block[@controller = 'settings' and @action='country']">
    <h2><xsl:value-of select="$translate[@keyword='set_cntr_list']"/></h2>

    <p><xsl:value-of select="$translate[@keyword='set_cntr_descr']"/></p>

    <style>
    #country_good, #country_normal, #country_bad {margin-right: 30px; float: left;}
    #country_good {width: 20%;}
    #country_normal {width: 20%;}
    #country_bad {width: 50%;}

    .connectedSortable {
        height:600px; width: 100%;
        list-style-type: none;
        margin: 0; padding: 0;
    }

      .connectedSortable li {
        cursor: pointer;
        float: left;
        border: 1px solid #fad42e;
        background: #fbec88;
        color: #363636;
        margin: 0 2px 2px 0; padding: 0 5px;
        font-size: 12px; }
    </style>

    <div class="confirm" id="cntrresult" style="position: absolute;right:0;display:none;">saved</div>

    <xsl:apply-templates select="country/*"/>

    <script>
      $(function() {
        $.fn.saveCountries = function() {
            cntr = {'good':[],'normal':[],'bad':[]}
            $.each(cntr, function(type,vv){
                $('#country_'+type+' li').each(function(k,v){
                    cntr[type].push([$(v).attr('id'), $(v).text()])
                })
            });

            $.post('<xsl:value-of select="$base"/>settings/country/save', {'country':cntr}, function(data) {

            }, 'json').done(function() {
                $('#cntrresult').show(200).hide(1000);
            })
            .fail(function() {
                $('#cntrresult').addClass('error').text('connection problems').show(200);
            });

        }
        $( "#country_good ul, #country_normal ul, #country_bad ul" ).sortable({
            connectWith: ".connectedSortable",
            beforeStop: function( event, ui ) {
                $.fn.saveCountries();
            }
        }).disableSelection();
      });
    </script>

    <div class="clear"></div>

</xsl:template>

<xsl:template match="block[@controller = 'settings']/country/*">
    <div id="country_{local-name()}">
        <h3><xsl:value-of select="local-name()"/></h3>
        <ul class="connectedSortable">
            <xsl:apply-templates select="item"/>
        </ul>
        <div class="clear"></div>
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'settings']/country/*/item">
    <li id="{id}"><xsl:if test="position()=last()"><xsl:attribute name="style">clear: right;</xsl:attribute></xsl:if><xsl:value-of select="name"/></li>
</xsl:template>



<!-- USERAGENTS -->
<xsl:template match="block[@controller = 'settings']/useragents">
    <div class="field delimiter">
        <h2><xsl:value-of select="$translate[@keyword='set_ua']"/></h2>
    </div>
    <div class="field">
        <div class="control" style="width:100%;"><textarea name="useragents" style="height:300px;"><xsl:value-of select="text()"/></textarea></div>
        <div class="clear"></div>
    </div>
</xsl:template>



<!-- BOTLIST -->
<xsl:template match="block[@controller = 'settings']/botlist">
    <div class="field delimiter">
        <h2><xsl:value-of select="$translate[@keyword='set_bots_list']"/></h2>
    </div>
    <div class="field">
        <div class="control" style="width:100%;"><textarea name="botlist" style="height:300px;"><xsl:value-of select="text()"/></textarea></div>
        <div class="clear"></div>
    </div>
</xsl:template>



<!-- VOCABULARIES -->
<xsl:template match="block[@controller = 'settings']/vocs">
    <div class="field delimiter">
        <h2><xsl:value-of select="$translate[@keyword='set_voc_list']"/></h2>
    </div>
    <div class="field fleft" style="width:33%;">
        <div class="title" style="width:200px;"><xsl:value-of select="$translate[@keyword='set_voc1']"/></div>
        <div class="control" style="width:100%;"><textarea name="voc1" style="height:300px;"><xsl:value-of select="voc1"/></textarea></div>
        <div class="clear"></div>
    </div>
    <div class="field fleft" style="width:33%;">
        <div class="title" style="width:200px;"><xsl:value-of select="$translate[@keyword='set_voc2']"/></div>
        <div class="control" style="width:100%;"><textarea name="voc2" style="height:300px;"><xsl:value-of select="voc2"/></textarea></div>
        <div class="clear"></div>
    </div>
    <div class="field fleft" style="width:33%;">
        <div class="title" style="width:200px;"><xsl:value-of select="$translate[@keyword='set_voc3']"/></div>
        <div class="control" style="width:100%;"><textarea name="voc3" style="height:300px;"><xsl:value-of select="voc3"/></textarea></div>
        <div class="clear"></div>
    </div>
</xsl:template>



<!-- TEMPLATES -->
<xsl:template match="block[@controller = 'settings']/tpls">
    <div class="field delimiter">
        <h2><xsl:value-of select="$translate[@keyword='set_tpls_title']"/></h2>
    </div>
    <xsl:if test="cj">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_cjniche']"/></div>
            <div class="control" style="width:100%;"><textarea name="cj" style="height:300px;"><xsl:value-of select="cj"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
    <xsl:if test="cjmulti">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_multiniche']"/></div>
            <div class="control" style="width:100%;"><textarea name="cjmulti" style="height:300px;"><xsl:value-of select="cjmulti"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>

    <xsl:if test="tube">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_tubeface']"/></div>
            <div class="control" style="width:100%;"><textarea name="tube" style="height:300px;"><xsl:value-of select="tube"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
    <xsl:if test="catlist">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_tubecats']"/></div>
            <div class="control" style="width:100%;"><textarea name="catlist" style="height:300px;"><xsl:value-of select="catlist"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
    <xsl:if test="cat">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_tubecat']"/></div>
            <div class="control" style="width:100%;"><textarea name="cat" style="height:300px;"><xsl:value-of select="cat"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
    <xsl:if test="tag">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_tubetag']"/></div>
            <div class="control" style="width:100%;"><textarea name="tag" style="height:300px;"><xsl:value-of select="tag"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
    <xsl:if test="new">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_newest']"/></div>
            <div class="control" style="width:100%;"><textarea name="new" style="height:300px;"><xsl:value-of select="new"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
    <xsl:if test="top">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_top']"/></div>
            <div class="control" style="width:100%;"><textarea name="top" style="height:300px;"><xsl:value-of select="top"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
    <xsl:if test="popular">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_pop']"/></div>
            <div class="control" style="width:100%;"><textarea name="popular" style="height:300px;"><xsl:value-of select="popular"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
    <xsl:if test="pics">
        <div class="field fleft">
            <div class="title"><xsl:value-of select="$translate[@keyword='set_tpls_pic']"/></div>
            <div class="control" style="width:100%;"><textarea name="pics" style="height:300px;"><xsl:value-of select="pics"/></textarea></div>
            <div class="clear"></div>
        </div>
    </xsl:if>
</xsl:template>



<!-- RAW -->
<xsl:template match="block[@controller = 'settings']/settings">
        <xsl:for-each select="child::*">
            <xsl:variable name="group" select="local-name()" />

            <div class="field delimiter">
                <h2><xsl:value-of select="$group" /></h2>
            </div>
            <xsl:for-each select="child::*">
                <div class="field">
                    <div class="title"><xsl:value-of select="local-name()" /></div>
                    <div class="control">
                        <xsl:choose>
                            <xsl:when test="text() = 'true' or text() = 'false'">
                                <input type="checkbox" name="set[{$group}][{local-name()}]" value="true">
                                    <xsl:if test="text() = 'true'">
                                        <xsl:attribute name="checked">1</xsl:attribute>
                                    </xsl:if>
                                </input>
                            </xsl:when>
                            <xsl:otherwise><input type="text" class="text" name="set[{$group}][{local-name()}]" value="{text()}" /></xsl:otherwise>
                        </xsl:choose>
                    </div>
                    <div class="clear"></div>
                </div>
            </xsl:for-each>
        </xsl:for-each>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/niche.xsl ########## -->

<xsl:template match="block[@controller = 'niche']">
    <div class="niche">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'niche']/niche">
    <form class="table" action="{$server}niche/do" method="post">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>
                
                <xsl:if test="../@settings.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'edit')" />
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'add')" />
                </xsl:if>
            </div>
        </div>
        
         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
            
        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>name</th>
                    <th>keyword</th>
                    <th>custom template</th>
                    <th>custom thumb</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="5" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'niche']/niche/item">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td class="id"><input type="checkbox" name="id[]" value="{id}" /></td>
        <td class="url">
            <xsl:value-of select="name" />
        </td>
        <td><xsl:value-of select="keyword" /></td>
        <xsl:call-template name="yesno"><xsl:with-param name="data" select="tpl"/></xsl:call-template>
        <xsl:call-template name="yesno"><xsl:with-param name="data" select="img"/></xsl:call-template>
    </tr>
</xsl:template>



<!-- ######### /home/tigra/www/subs/subs/transformers/cache.xsl ########## -->

<xsl:template match="block[@controller = 'cache']">
    <div class="settings form-wrapper">
        <fieldset>
        <form action="{$server}settings/global" method="post">
             <xsl:if test="errors/error">
                <div class="error">
                    <ul>
                        <xsl:for-each select="errors/error">
                            <li><xsl:value-of select="text()" /></li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>
            
            <xsl:if test="confirms/confirm">
                <div class="confirm">
                    <ul>
                        <xsl:for-each select="confirms/confirm">
                            <li><xsl:value-of select="text()" /></li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>
           
            <input type="hidden" name="formname" value="settings"/>

            <div class="confirm"><a href="{$server}cache/droppages">Recreate cached pages</a><br/>
            <a href="{$server}cache/dropgalleries">Recreate galleries</a><br/>
            <a href="{$server}cache/limitpergallery">Block redundant thumbs</a></div>
            <div class="error">
                <a href="{$server}cache/dropstats">Drop ALL STATISTICS</a><br/>
                <a href="{$server}cache/dropblockedthumbs">Drop blocked thumbs</a>
            </div>
            <!--div><a href="{$server}cache/recreategalleries">Recreate cached GALLERIES pages one be one</a></div-->

            <!--div class="field buttonset">
                <div class="title"></div>
                <div class="control"><input type="submit" value="{$translate[@keyword='frm_submit']}"/></div>
                <div class="clear"></div>
            </div-->
            
        </form>
        </fieldset>
    </div>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/sponsor.xsl ########## -->

<xsl:template match="block[@controller = 'sponsor']">
    <div class="sponsor">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>

<xsl:template match="block[@controller = 'sponsor']/sponsor">
    <form class="table" action="{$server}sponsor/do" method="post">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>
                
                <xsl:if test="../@sponsor.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_block']}" onclick="$.fn.assignAction(this, 'block')" />
                    <input type="submit" value="{$translate[@keyword='glb_activate']}" onclick="$.fn.assignAction(this, 'activate')" />
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'edit')" />
                </xsl:if>
                
                <xsl:if test="../@sponsor.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                </xsl:if>

                <xsl:if test="../@sponsor.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'add')" />
                </xsl:if>
            </div>
        </div>
        
         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>name</th>
                    <th>url</th>
                    <th>domain</th>
                    <th>status</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="5" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>name</th>
                    <th>url</th>
                    <th>domain</th>
                    <th>status</th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'sponsor']/sponsor/item">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td><xsl:value-of select="name" /></td>
        <td>
            <a href="{url}"><xsl:value-of select="url" /></a>
        </td>
        <td><xsl:value-of select="domain" /></td>
        <td><xsl:value-of select="status" /></td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/trader.xsl ########## -->

<xsl:template match="block[@controller = 'trader']">
    <div class="trader">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>

<!-- ### GROUP ### -->
<xsl:template match="block[@controller = 'trader']/group">
    <h2>Groups list</h2>
    <form class="table" action="{$server}trader/do" method="post">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <div style="position: absolute; left: 50%; width: 100px; margin-left -50px;">
                    <a href="#" class="subformclick">set same for few</a>
                    <div class="subform">
                        <input type="text" name="ratio" title="ratio" class="text toggleTitle" /><br/>
                        <input type="text" name="rturn" title="return" class="text toggleTitle" /><br/>
                        <input type="text" name="skimscheme" title="skimscheme" class="text toggleTitle" /><br/>

                        <input type="submit" value="{$translate[@keyword='glb_save']}" onclick="$.fn.assignAction(this, 'shareeditGroup')" />
                        <a href="javascript:void(0);" onclick="$('body').click()" class="red"><xsl:value-of select="$translate[@keyword='frm_cancel']"/></a>
                    </div>
                </div>
                
                <xsl:if test="../@trader.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_block']}" onclick="$.fn.assignAction(this, 'blockGroup')" />
                    <input type="submit" value="{$translate[@keyword='glb_activate']}" onclick="$.fn.assignAction(this, 'activateGroup')" />
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'editGroup')" />
                </xsl:if>
                
                <xsl:if test="../@trader.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'deleteGroup')" class="kill" />
                </xsl:if>

                <xsl:if test="../@trader.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'addGroup')" />
                </xsl:if>
            </div>
        </div>
        
         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>name</th>
                    <th>ratio</th>
                    <th>rturn</th>
                    <th>skimscheme</th>
                    <th>status</th>
                    <th>type</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="7" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>name</th>
                    <th>ratio</th>
                    <th>rturn</th>
                    <th>skimscheme</th>
                    <th>status</th>
                    <th>type</th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'trader']/group/item">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td style="color:#{color};"><xsl:value-of select="name" /></td>
        <td><xsl:value-of select="ratio" /></td>
        <td><xsl:value-of select="rturn" /></td>
        <td><xsl:value-of select="skimscheme" /></td>
        <td><xsl:value-of select="status" /></td>
        <td><xsl:value-of select="type" /></td>
    </tr>
</xsl:template>


<!-- ### TRADER LIST ### -->
<xsl:template match="block[@controller = 'trader']/trader">
    <h2 class="first">Traders list</h2>
    <form class="table" action="{$server}trader/do" method="post" id="traderForm">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>
                <input type="hidden" name="traderurl"/>

                <div style="position: absolute; left: 55%; width: 100px; margin-left -50px;">
                    <a href="#" class="subformclick">set same for few</a>
                    <div class="subform">
                        <input type="text" name="ratio" title="ratio" class="text toggleTitle" /><br/>
                        <input type="text" name="rturn" title="return" class="text toggleTitle" /><br/>
                        <input type="text" name="skimscheme" title="skimscheme" class="text toggleTitle" /><br/>
                        <input type="text" name="forces" title="forces" class="text toggleTitle" /><br/>
                        <select name="trader_group[]" multiple="multiple" class="chosen-select" data-placeholder="choose group">
                            <xsl:for-each select="group/item">
                                <option value="{id}" style="color:#{color};"><xsl:value-of select="name"/></option>
                            </xsl:for-each>
                        </select><br/>
                        <input type="text" name="newgroup" title="add new group" class="text toggleTitle" style="width: 89px; padding: 0 2px;" />
                        <input type="text" name="newcolor" id="newcolor" title="color" class="text toggleTitle" style="width: 45px; margin-left:0px; padding: 0 2px;" />
                        <script type="text/javascript">
                            <xsl:text>$(document).ready(function(){</xsl:text>
                                <xsl:text>$("#newcolor").colorpicker({
                                    /*colorFormat:  'RGBA',*/
                                    parts:              ['map', 'bar', 'hex', 'preview', 'footer'],
                                    alpha:          false,
                                    showOn:         'focus click alt',
                                    modal:          false,
                                    regional:       '</xsl:text><xsl:value-of select="$lang" /><xsl:text>',
                                    buttonColorize: false,
                                    showNoneButton: false,
                                    showCloseButton:    false,
                                    showCancelButton:   false,
                                    closeOnEscape:      true,
                                    okOnEnter: true,
                                    altField: "#newcolor",
                                    altProperties: 'border-color,color',
                                    altAlpha: false,
                                    layout: {
                                        map:        [0, 1, 1, 1],   // Left, Top, Width, Height (in table cells).
                                        bar:        [1, 1, 1, 1],
                                        hex:        [1, 0, 1, 1],
                                        preview:    [0, 0, 1, 1]                           
                                    },
                                    part:   {
                                        map:        { size: 128 },
                                        bar:        { size: 128 },
                                        hex:        { size: 128 }
                                    }
                                });</xsl:text>
                            <xsl:text>});</xsl:text>

                            $('.chosen-select').chosen({width:"140px",no_results_text:'Oops, nothing found!'});
                        </script>


                        <input type="submit" value="{$translate[@keyword='glb_save']}" onclick="$.fn.assignAction(this, 'shareedit')" />
                        <a href="javascript:void(0);" onclick="$('body').click()" class="red"><xsl:value-of select="$translate[@keyword='frm_cancel']"/></a>
                    </div>
                </div>
                
                <xsl:if test="../@trader.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_block']}" onclick="$.fn.assignAction(this, 'block')" />
                    <input type="submit" value="{$translate[@keyword='glb_activate']}" onclick="$.fn.assignAction(this, 'activate')" />
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'edit')" />
                </xsl:if>

                <xsl:if test="../@trader.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                </xsl:if>

                <xsl:if test="../@trader.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'add')" />
                </xsl:if>
            </div>
        </div>
        
         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th rowspan="2" width="25"><input type="checkbox" class="check-all" /></th>
                    <th rowspan="2">name<br/><small>domain</small></th>
                    <th rowspan="2">ident</th>
                    <th rowspan="2">groups</th>
                    <th rowspan="2">skim scheme</th>
                    <th rowspan="2">forces</th>
                    <th rowspan="2">rank</th>
                    <th rowspan="2">status</th>

                    <th colspan="8" class="odd">1 hour</th>

                    <th colspan="8">24 hour</th>
                </tr>
                <tr>
                    <th class="odd">raw in</th>
                    <th class="odd">unique in</th>
                    <th class="odd">click</th>
                    <th class="odd">trade</th>
                    <th class="odd">out</th>
                    <th class="odd">skim</th>
                    <th class="odd">ratio</th>
                    <th class="odd" title="productivity">prod.</th>

                    <th>raw in</th>
                    <th>unique in</th>
                    <th>click</th>
                    <th>trade</th>
                    <th>out</th>
                    <th>skim</th>
                    <th>ratio</th>
                    <th title="productivity">prod.</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="26" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th rowspan="2" width="25"><input type="checkbox" class="check-all" /></th>
                    <th rowspan="2">name<br/><small>domain</small></th>
                    <th rowspan="2">ident</th>
                    <th rowspan="2">groups</th>
                    <th rowspan="2">skim scheme</th>
                    <th rowspan="2">forces</th>
                    <th rowspan="2">rank</th>
                    <th rowspan="2">status</th>

                    <th class="odd">raw in</th>
                    <th class="odd">unique in</th>
                    <th class="odd">click</th>
                    <th class="odd">trade</th>
                    <th class="odd">out</th>
                    <th class="odd">skim</th>
                    <th class="odd">ratio</th>
                    <th class="odd" title="productivity">prod.</th>

                    <th>raw in</th>
                    <th>unique in</th>
                    <th>click</th>
                    <th>trade</th>
                    <th>out</th>
                    <th>skim</th>
                    <th>ratio</th>
                    <th title="productivity">prod.</th>
                </tr>
                <tr>
                    <th class="odd" colspan="8">1 hour</th>

                    <th colspan="8">24 hour</th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'trader']/trader/item">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td><a href="{url}"><xsl:value-of select="name" /></a><br/>(<small><xsl:value-of select="domain" />)</small></td>
        <td>
            <xsl:choose>
                <xsl:when test="ident != ''"><xsl:value-of select="ident" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="id" /></xsl:otherwise>
            </xsl:choose>
        </td>
        <td>
            <xsl:for-each select="group/item">
                <span style="color:#{color};"><xsl:value-of select="name"/></span>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </td>
        <td><xsl:value-of select="skimscheme" /></td>
        <td><xsl:value-of select="forces" /></td>
        <td>
            <xsl:attribute name="class">
                <xsl:text>pyramid_rank </xsl:text>
                <xsl:choose>
                    <xsl:when test="rank &lt; 10">r1</xsl:when>
                    <xsl:when test="rank &lt; 25">r2</xsl:when>
                    <xsl:when test="rank &lt; 50">r3</xsl:when>
                    <xsl:when test="rank &lt; 2500">r4</xsl:when>
                    <xsl:when test="rank &lt; 3750">r5</xsl:when>
                    <xsl:when test="rank &lt; 5000">r6</xsl:when>
                    <xsl:when test="rank &lt; 10000">r7</xsl:when>
                    <xsl:when test="rank &lt; 50000">r8</xsl:when>
                    <xsl:when test="rank &lt; 75000">r9</xsl:when>
                    <xsl:otherwise>r10</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="rank" />
        </td>
        <td><xsl:value-of select="status" /></td>

        
        <xsl:apply-templates select="h1" />

        <xsl:apply-templates select="h24" />
        
    </tr>
</xsl:template>



<!-- ### NO TRADE LIST ### -->
<xsl:template match="block[@controller = 'trader']/notrade">
    <h3>NO Trades list</h3>
    <form class="table" action="{$server}trader/do" method="post" id="traderForm">
        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th rowspan="2" width="25"><input type="checkbox" class="check-all" /></th>
                    <th rowspan="2">referer<br/><small>domain</small></th>

                    <th colspan="8" class="odd">1 hour</th>

                    <th colspan="8">24 hour</th>
                </tr>
                <tr>
                    <th class="odd">raw in</th>
                    <th class="odd">unique in</th>
                    <th class="odd">click</th>
                    <th class="odd">trade</th>
                    <th class="odd">out</th>
                    <th class="odd">skim</th>
                    <th class="odd">ratio</th>
                    <th class="odd" title="productivity">prod.</th>

                    <th>raw in</th>
                    <th>unique in</th>
                    <th>click</th>
                    <th>trade</th>
                    <th>out</th>
                    <th>skim</th>
                    <th>ratio</th>
                    <th title="productivity">prod.</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="20" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th rowspan="2" width="25"><input type="checkbox" class="check-all" /></th>
                    <th rowspan="2">referer<br/><small>domain</small></th>

                    <th class="odd">raw in</th>
                    <th class="odd">unique in</th>
                    <th class="odd">click</th>
                    <th class="odd">trade</th>
                    <th class="odd">out</th>
                    <th class="odd">skim</th>
                    <th class="odd">ratio</th>
                    <th class="odd" title="productivity">prod.</th>

                    <th>raw in</th>
                    <th>unique in</th>
                    <th>click</th>
                    <th>trade</th>
                    <th>out</th>
                    <th>skim</th>
                    <th>ratio</th>
                    <th title="productivity">prod.</th>
                </tr>
                <tr>
                    <th class="odd" colspan="8">1 hour</th>

                    <th colspan="8">24 hour</th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'trader']/notrade/item">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{id}" /></td>
        <td><a href="http://{referer}/"><xsl:value-of select="referer" /></a></td>
        
        <xsl:apply-templates select="h1" />

        <xsl:apply-templates select="h24" />
        
    </tr>
</xsl:template>


<!-- ### EXITs ### -->
<xsl:template match="block[@controller = 'trader']/exit">
    <h3>EXITs list</h3>
    <form class="table" action="{$server}trader/do" method="post" id="traderForm">


        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th rowspan="2">type</th>

                    <th colspan="8" class="odd">1 hour</th>

                    <th colspan="8">24 hour</th>
                </tr>
                <tr>
                    <th class="odd">raw in</th>
                    <th class="odd">unique in</th>
                    <th class="odd">click</th>
                    <th class="odd">trade</th>
                    <th class="odd">out</th>
                    <th class="odd">skim</th>
                    <th class="odd">ratio</th>
                    <th class="odd" title="productivity">prod.</th>

                    <th>raw in</th>
                    <th>unique in</th>
                    <th>click</th>
                    <th>trade</th>
                    <th>out</th>
                    <th>skim</th>
                    <th>ratio</th>
                    <th title="productivity">prod.</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="child::node()"><xsl:apply-templates select="child::node()"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="19" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th rowspan="2">type</th>

                    <th class="odd">raw in</th>
                    <th class="odd">unique in</th>
                    <th class="odd">click</th>
                    <th class="odd">trade</th>
                    <th class="odd">out</th>
                    <th class="odd">skim</th>
                    <th class="odd">ratio</th>
                    <th class="odd" title="productivity">prod.</th>

                    <th>raw in</th>
                    <th>unique in</th>
                    <th>click</th>
                    <th>out</th>
                    <th>trade</th>
                    <th>skim</th>
                    <th>ratio</th>
                    <th title="productivity">prod.</th>
                </tr>
                <tr>
                    <th class="odd" colspan="8">1 hour</th>

                    <th colspan="8">24 hour</th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'trader']/exit/*">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><xsl:value-of select="local-name()" /></td>
        
        <xsl:apply-templates select="h1" />

        <xsl:apply-templates select="h24" />
        
    </tr>
</xsl:template>



<xsl:template match="h1|h24">
    <xsl:call-template name="zero"><!-- in -->
        <xsl:with-param name="data" select="raw_in"/>
    </xsl:call-template>

    <td><!-- unique -->
        <xsl:choose>
            <xsl:when test="unique_in != ''">
                <xsl:value-of select="unique_in"/>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="unique_in = '' or raw_in = ''">0%</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="format-number(unique_in div raw_in, '####%')" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">no</xsl:attribute>
                <xsl:text>0</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </td>

    <xsl:call-template name="zero"><!-- click -->
        <xsl:with-param name="data" select="click"/>
    </xsl:call-template>
    <xsl:call-template name="zero"><!-- out -->
        <xsl:with-param name="data" select="raw_out"/>
    </xsl:call-template>

    <td title="raw out to this thrader (out / raw in)"><!-- return -->
        <xsl:choose>
            <xsl:when test="raw_rturn != ''">
                <xsl:value-of select="raw_rturn"/>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="raw_in = '' or raw_rturn = ''">0%</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="format-number(raw_rturn div raw_in, '####.##%')" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">no</xsl:attribute>
                <xsl:text>0</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </td>

    <td title="raw out / click"><!-- skim -->
        <xsl:choose>
            <xsl:when test="raw_out = '' or click = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-number(raw_out div click, '####%')" />
            </xsl:otherwise>
        </xsl:choose>
    </td>
    <td title="raw return / raw in"><!-- ratio -->
        <xsl:choose>
            <xsl:when test="not(raw_rturn) or raw_rturn = '' or raw_in = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-number(raw_rturn div raw_in, '####%')" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="ratio != '' or ../group/item[ratio != ''] or ../../etc/trader/ratio != ''">
            <xsl:text> (</xsl:text><b><xsl:choose>
                <xsl:when test="ratio != ''"><xsl:value-of select="ratio" /></xsl:when>
                <xsl:when test="../group/item[ratio != '']">
                    <xsl:for-each select="../group/item">
                        <xsl:sort select="ratio" data-type="number" order="descending"/>
                        <xsl:if test="position() = 1"><xsl:value-of select="ratio"/></xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="../../etc/trader/ratio" />
                </xsl:otherwise>
            </xsl:choose></b><xsl:text>%)</xsl:text>
        </xsl:if>
    </td>
    <td title="click / raw in"><!-- productivity -->
        <xsl:choose>
            <xsl:when test="click = '' or raw_in = ''"><xsl:attribute name="class">no</xsl:attribute>0%</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-number(click div raw_in, '####%')" />
            </xsl:otherwise>
        </xsl:choose>
    </td>
</xsl:template>


<!-- ### TOPLIST ### -->
<xsl:template match="block[@controller = 'trader']/toplist">
    <h2 class="first">Traders TOP lists</h2>
    <form class="table" action="{$server}trader/do" method="post" id="traderForm">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>
                
                <xsl:if test="../@trader.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'editToplist')" />
                </xsl:if>

                <xsl:if test="../@trader.delete = 1">
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'deleteToplist')" class="kill" />
                </xsl:if>

                <xsl:if test="../@trader.add = 1">
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'addToplist')" />
                </xsl:if>
            </div>
        </div>
        
         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>name</th>
                    <th>inculde string</th>
                    <th>group</th>
                    <th>repeat</th>
                    <th>rebuild</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="25" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
            <tfoot>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>name</th>
                    <th>inculde string</th>
                    <th>group</th>
                    <th>repeat</th>
                    <th>rebuild</th>
                </tr>
            </tfoot>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'trader']/toplist/item">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'deleted'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td><input type="checkbox" name="id[]" value="{name}" /></td>
        <td><xsl:value-of select="name" /></td>
        <td><input type="text" value='&lt;!--#include virtual="/toplist/{name}.html" --&gt;' style="width: 350px;"/></td>
        <td>
            <xsl:choose>
                <xsl:when test="groups != ''">
                    <xsl:for-each select="groups/item">
                        <span style="color:#{color};"><xsl:value-of select="name"/></span>
                        <xsl:if test="position() != last()">, </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>--</xsl:otherwise>
            </xsl:choose>
        </td>
        <td><xsl:value-of select="repeat" /></td>
        <td><xsl:value-of select="rebuild" /></td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/report.xsl ########## -->

<xsl:template match="block[@controller = 'report']">
    <div class="report">
        <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
    </div>
</xsl:template>



<xsl:template match="block[@controller = 'report' and @name = 'reportForm']">
    <style>
        #reportFormContainer {
            width: 20px;
            position: fixed;
            right: 0;
            z-index: 999999;
            overflow: hidden;
        }
        .reportForm {
            width: 400px;
            position: relative;
            right: 0;
            z-index: 999999;
        }
        .reportForm fieldset {
            background: white;
            padding-left: 2px;
        }
        .reportForm .field {
            position: relative;
        }
        .reportForm .title {
            transform: rotate(-90deg);
            transform-origin: left top;
            position: absolute;
            width: 200px!important; height: 20px;
            left: 0px; top: 200px;
            cursor: pointer;
        }
        .reportForm .control {
            width: 350px!important;
        }
    </style>
    <script>
        jQuery(function($) {
            $(".reportForm form .reportMessage").closest('.field').find('.title').click(function(){$.fn.reportToggle($(this));});
            $.fn.reportToggle = function(obj) {
                var rt = '20px';
                if ($(obj).closest("#reportFormContainer").css('width') == '20px') {
                    rt = '400px';
                }
                $(obj).closest("#reportFormContainer").animate({'width':rt});
            }
        });
    </script>
    <div id="reportFormContainer">
        <div class="reportForm">
            <xsl:apply-templates select="*[not(local-name() = 'jss') and not(local-name() = 'csss') and not(local-name() = 'errors') and not(local-name() = 'confirms')]" />
        </div>
    </div>
</xsl:template>




<xsl:template match="block[@controller = 'report']/report">
    <form class="table" action="{$server}report/do" method="post">
        <div class="functions-container">
            <div class="functions fixOnScroll">
                <span class="strong"><xsl:value-of select="$translate[@keyword='glb_actions']"/>:</span>
                <input type="hidden" name="redirect" value="{$current_url}?{$requested_get}" />
                <input type="hidden" name="action"/>

                <xsl:if test="../@report.edit = 1">
                    <input type="submit" value="{$translate[@keyword='glb_edit']}" onclick="$.fn.assignAction(this, 'edit')" />
                    <input type="submit" value="get in work" onclick="$.fn.assignAction(this, 'process')" />
                    <input type="submit" value="done" onclick="$.fn.assignAction(this, 'block')" />
                    <input type="submit" value="{$translate[@keyword='glb_delete']}" onclick="$.fn.assignAction(this, 'delete')" class="kill" />
                    <input type="submit" value="{$translate[@keyword='glb_add']}" class="right-action" onclick="$.fn.assignAction(this, 'add')" />
                </xsl:if>
            </div>
        </div>

         <xsl:if test="../errors/error">
            <div class="error">
                <ul>
                    <xsl:for-each select="../errors/error">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <xsl:if test="../confirms/confirm">
            <div class="confirm">
                <ul>
                    <xsl:for-each select="../confirms/confirm">
                        <li><xsl:value-of select="text()" /></li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>

        <table class="tech fixOnScrollTable" id="queue">
            <thead>
                <tr>
                    <th width="25"><input type="checkbox" class="check-all" /></th>
                    <th>user</th>
                    <th>message</th>
                    <th>params</th>
                    <th>status</th>
                </tr>
            </thead>
            <tbody>
                <xsl:choose>
                    <xsl:when test="item"><xsl:apply-templates select="item"/></xsl:when>
                    <xsl:otherwise>
                        <tr>
                            <td colspan="5" style="text-align: center;">
                                <xsl:value-of select="$translate[@keyword='glb_empty']"/>
                            </td>
                        </tr>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
        </table>
    </form>
</xsl:template>

<xsl:template match="block[@controller = 'report']/report/item">
    <tr id="row_{id}">
        <xsl:choose>
            <xsl:when test="status = 'blocked' or status = 'processed'"><xsl:attribute name="class">disabled</xsl:attribute></xsl:when>
            <xsl:when test="status = 'progress'"><xsl:attribute name="class">marked-orange</xsl:attribute></xsl:when>
            <xsl:when test="status = 'new'"><xsl:attribute name="class">marked-green</xsl:attribute></xsl:when>
        </xsl:choose>
        <td class="id"><input type="checkbox" name="id[]" value="{id}" /></td>
        <td><xsl:value-of select="customer" />-<xsl:value-of select="username" /></td>
        <td><pre><xsl:value-of select="message" /></pre></td>
        <td><xsl:apply-templates select="params/param" mode="recur"/></td><!-- from authorization.xsl -->
        <td><xsl:value-of select="status" /></td>
    </tr>
</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/video.xsl ########## -->

<xsl:template match="block[@controller = 'video' and @action='add']">
    <div class="settings form-wrapper">
        <fieldset>
        <form action="" method="post" enctype="multipart/form-data" class="chosenFORM">
             <xsl:if test="formblock/errors/error">
                <div class="error">
                    <ul>
                        <xsl:for-each select="formblock/errors/error">
                            <li><xsl:value-of select="message" /></li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>

            <xsl:if test="formblock/confirms/confirm">
                <div class="confirm">
                    <ul>
                        <xsl:for-each select="formblock/confirms/confirm">
                            <li><xsl:value-of select="message" /></li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>

            <input type="hidden" name="formname" value="video.add"/>
            <input type="hidden" name="action" value="add"/>
            <input type="hidden" name="group[main]" value="main"/>

            <style>
                .subfield {
                    float: left;
                    margin-right: 10px;
                }
                .chosen-select {
                    width: 150px;
                }
            </style>

            <div class="field">
                <div class="subfield">
                    <div class="title" style="width:100px;"><xsl:value-of select="$translate[@keyword='vid_template']"/></div>
                    <div style="">
                        <select name="tpl_id[main]" class="chosen-select">
                            <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='tpl_id']/options/option">
                                <option value="{@value}"><xsl:value-of select="text()"/></option>
                            </xsl:for-each>
                        </select>
                    </div>
                </div>
                <div class="subfield">
                    <div class="title" style="width:100px;"><xsl:value-of select="$translate[@keyword='vid_sponsor']"/></div>
                    <div style="">
                        <select name="sponsor_id[main]" data-placeholder="{$translate[@keyword='vid_choose_sponsor']}" class="chosen-select">
                            <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='sponsor_id']/options/option">
                                <option value="{@value}"><xsl:value-of select="text()"/></option>
                            </xsl:for-each>
                        </select>
                    </div>
                    <script type="text/javascript">$(document).ready(function(){$('#sponsor-main').autocomplete({serviceUrl:'sponsor/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                </div>

                <div class="subfield">
                    <div class="title" style="width:150px;"><xsl:value-of select="$translate[@keyword='vid_cats']"/></div>
                    <div style="">
                        <select name="niche_id[main][]" data-placeholder="{$translate[@keyword='vid_choose_category']}" class="chosen-select" multiple="multiple" style="width:350px;">
                            <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='niche_id']/options/option">
                                <option value="{@value}"><xsl:value-of select="text()"/></option>
                            </xsl:for-each>
                        </select>
                    </div>
                    <script type="text/javascript">$(document).ready(function(){$('#niche-main').autocomplete({serviceUrl:'niche/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                </div>

                <div class="subfield">
                    <div class="title" style="width:150px;"><xsl:value-of select="$translate[@keyword='vid_tags']"/></div>
                    <div style="">
                        <input type="text" name="tag[main]" id="tag-main" style="width: 150px" value="" />
                    </div>
                    <script type="text/javascript">$(document).ready(function(){$('#tag-main').autocomplete({serviceUrl:'video/tag/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                </div>

                <div class="clear"></div>
            </div>

            <div class="field">
                <div class="subfield">
                    <div class="title" style="width:300px;"><xsl:value-of select="$translate[@keyword='vid_titlescheme']"/> (<a href="settings/dics/" target="_blank"><xsl:value-of select="$translate[@keyword='vid_vocs']"/></a>)</div>
                    <div style="">
                        <input type="text" name="title[main]" id="title-main" style="width: 300px" value="{formblock/formdata/fieldgroup/field[@name='title']/value}" />
                    </div>
                </div>

                <div class="clear"></div>
            </div>


            <div class="field">
                <div class="subfield">
                    <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='vid_qp']"/>:</div>
                    <div style="float: left;">
                        <select name="quality_profile[main]">
                            <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='quality_profile']/options/option">
                                <option value="{@value}"><xsl:value-of select="text()"/></option>
                            </xsl:for-each>
                        </select>
                    </div>
                </div>
                <div class="subfield">
                    <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='vid_tpv']"/>:</div>
                    <div style="float: left;">
                        <input type="text" name="gallery_thumbs[main]" style="width: 50px" value="{formblock/formdata/fieldgroup/field[@name='gallery_thumbs']/value}" />
                    </div>
                </div>

                <div class="clear"></div>
            </div>

            <div class="field">
                <div class="subfield">
                    <label><input type="checkbox" name="convert[main]" id="convert-main" value="1" onclick="$(this).closest('.field').nextAll('.none').toggle($(this).prop('checked')); $(this).closest('.field').find('.none').toggle($(this).prop('checked'));" /> <xsl:value-of select="$translate[@keyword='vid_convert']"/>?</label>
                </div>

                <div class="clear"></div>
            </div>

            <div class="field none">
                <div class="subfield">
                    <label><input type="checkbox" name="slice[main]" value="1" onclick="$(this).closest('.field').find('.none').toggle($(this).prop('checked')).find('input[name=video_length\\[main\\]]').focus();" /> <xsl:value-of select="$translate[@keyword='vid_slice']"/>?</label>
                </div>
                <div class="subfield none">
                    <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='vid_slice_duration']"/>:</div>
                    <div style="float: left;">
                        <input type="text" name="video_length[main]" style="width: 50px" value="{formblock/formdata/fieldgroup/field[@name='video_length']/value}" />
                    </div>
                </div>
                <div class="subfield none">
                    <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='vid_video_per_gal']"/>:</div>
                    <div style="float: left;">
                        <input type="text" name="gallery_length[main]" style="width: 50px" value="{formblock/formdata/fieldgroup/field[@name='gallery_length']/value}" />
                    </div>
                </div>

                <div class="clear"></div>
            </div>

            <script type="text/javascript">
                $('.chosen-select').chosen({width:"95%",no_results_text:'<xsl:value-of select="$translate[@keyword='vid_oops']"/>!'});
                jQuery(function($) {
                    $("input[name=tasktype\\[main\\]]").click(function(){$('.subform').hide(250);$('#'+$(this).val()).show(250)});
                    $( "#tabs" ).tabs();
                });
            </script>

            <div id="tabs">
                <ul>
                    <li><a href="{$server}{$requested_uri}#local" rel="local" onclick="$('#tasktype').val($(this).attr('rel'))"><b><xsl:value-of select="$translate[@keyword='vid_tab_local']"/></b></a></li>
                    <li><a href="{$server}{$requested_uri}#ftp" rel="ftp" onclick="$('#tasktype').val($(this).attr('rel'))"><b><xsl:value-of select="$translate[@keyword='vid_tab_ftp']"/></b></a></li>
                    <li><a href="{$server}{$requested_uri}#download" rel="download" onclick="$('#tasktype').val($(this).attr('rel'))"><b><xsl:value-of select="$translate[@keyword='vid_tab_download']"/></b></a></li>
                    <li><a href="{$server}{$requested_uri}#upload" rel="upload" onclick="$('#tasktype').val($(this).attr('rel'))"><b><xsl:value-of select="$translate[@keyword='vid_tab_upload']"/></b></a></li>
                    <li><a href="{$server}{$requested_uri}#grablist" rel="grablist" onclick="$('#tasktype').val($(this).attr('rel'))"><b><xsl:value-of select="$translate[@keyword='vid_tab_grab']"/></b></a></li>
                </ul>

                <input type="hidden" name="tasktype[main]" value="local" id="tasktype"/>


                <!-- !!! -->
                <div id="local" class="subform">

                    <div class="field">
                        <div class="subfield">
                            <div class="title" style="width:350px;"><xsl:value-of select="$translate[@keyword='vid_local_dir']"/> <span class="help"><xsl:value-of select="$translate[@keyword='vid_local_dir_?']" /></span></div>
                            <div style="">
                                <input type="text" name="videodata[main]" id="videodata-main" style="width: 300px" value="{formblock/formdata/fieldgroup/field[@name='videodata']/value}" />
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="subfield">
                            <label><input type="checkbox" name="delete[main]" value="1" /> <xsl:value-of select="$translate[@keyword='vid_delete_src']"/>?</label>
                        </div>

                        <div class="clear"></div>
                    </div>
                </div>


                <!-- !!! -->
                <div id="ftp" class="subform" style="display:none;">
                    <div class="field">
                        <div class="subfield">
                            <div class="title" style="width:250px;"><xsl:value-of select="$translate[@keyword='vid_ftp_host']"/></div>
                            <div style="">
                                <input type="text" name="ftp_host[main]" style="width: 250px" value="{formblock/formdata/fieldgroup/field[@name='ftp_host']/value}" class="required" />
                            </div>
                        </div>
                        <div class="subfield">
                            <div class="title" style="width:50px;"><xsl:value-of select="$translate[@keyword='vid_port']"/></div>
                            <div style="">
                                <input type="text" name="ftp_port[main]" style="width: 30px" value="{formblock/formdata/fieldgroup/field[@name='ftp_port']/value}" />
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="subfield">
                            <label><input type="checkbox" name="ftp_anon[main]" value="1" checked="checked" onclick="$(this).closest('.field').find('.none').toggle(!$(this).prop('checked'));" /> <xsl:value-of select="$translate[@keyword='vid_anonymous']"/></label>
                        </div>
                        <div class="subfield none">
                            <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='vid_ftp_user']"/>:</div>
                            <div style="float: left;">
                                <input type="text" name="ftp_user[main]" style="width: 50px" value="{formblock/formdata/fieldgroup/field[@name='ftp_user']/value}" class="required" />
                            </div>
                        </div>
                        <div class="subfield none">
                            <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='vid_ftp_pass']"/>:</div>
                            <div style="float: left;">
                                <input type="text" name="ftp_pwd[main]" style="width: 50px" value="{formblock/formdata/fieldgroup/field[@name='ftp_pwd']/value}" />
                            </div>
                        </div>
                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="subfield">
                            <div class="title" style="width:250px;"><xsl:value-of select="$translate[@keyword='vid_ftp_subdir']"/></div>
                            <div style="">
                                <input type="text" name="ftp_dir[main]" style="width: 250px" value="{formblock/formdata/fieldgroup/field[@name='ftp_dir']/value}" />
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="subfield">
                            <div class="title" style="width:250px;"><xsl:value-of select="$translate[@keyword='vid_ftp_local']"/></div>
                            <div style="">
                                <input type="text" name="ftp_videodata[main]" style="width: 250px" value="{formblock/formdata/fieldgroup/field[@name='videodata']/value}" />
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="subfield">
                            <label><input type="checkbox" checked="checked" name="ftp_localdelete[main]" value="1" /> <xsl:value-of select="$translate[@keyword='vid_ftp_del_loc']"/>?</label>
                        </div>

                        <div class="clear"></div>
                    </div>

                    <div class="field">

                        <div class="subfield">
                            <label><input type="checkbox" name="ftp_delete[main]" value="1" /> <xsl:value-of select="$translate[@keyword='vid_del_src']"/>?</label>
                        </div>

                        <div class="clear"></div>
                    </div>
                </div>

                <!-- !!! -->
                <div id="download" class="subform" style="display:none;">

                    <div class="field">
                        <div class="subfield" style="width:100%;">
                            <div class="title" style="width:350px;"><xsl:value-of select="$translate[@keyword='vid_dwn_links']"/> <small></small></div>
                            <div style="">
                                <textarea name="download_files[main]" class="textarea" style="width:100%; height:200px;">
                                    <xsl:value-of select="formblock/formdata/fieldgroup/field[@name='download_files']/value"/>
                                </textarea>
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="subfield">
                            <label><input type="checkbox" name="download_file_save[main]" value="1" onclick="$(this).closest('.field').find('.none').toggle($(this).prop('checked'))" /> <xsl:value-of select="$translate[@keyword='vid_dwn_save']"/>?</label>
                        </div>


                        <div class="subfield none">
                            <!--div class="title" style="width:350px;">Local directory <small>(to save uploaded original file)</small></div-->
                            <div style="">
                                <input type="text" name="download_videodata[main]" style="width: 300px" value="{formblock/formdata/fieldgroup/field[@name='videodata']/value}" />
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>
                </div>

                <!-- !!! -->
                <div id="upload" class="subform" style="display:none;">

                    <div class="field">
                        <div class="subfield">
                            <div class="title" style="width:350px;"><xsl:value-of select="$translate[@keyword='vid_file']"/><span class="help"><xsl:value-of select="$translate[@keyword='vid_file_?1']" />: <xsl:value-of select="@upload_max_filesize"/>B; <xsl:value-of select="$translate[@keyword='vid_file_?2']" />: <xsl:value-of select="@post_max_size"/>B</span></div>
                            <div style="">
                                <input type="file" name="upload_file[]" style="width: 300px" multiple="multiple" />
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="subfield">
                            <label><input type="checkbox" name="upload_file_save[main]" value="1" onclick="$(this).closest('.field').find('.none').toggle($(this).prop('checked'))" /> <xsl:value-of select="$translate[@keyword='vid_file_save']"/>?</label>
                        </div>


                        <div class="subfield none">
                            <div style="">
                                <input type="text" name="upload_videodata[main]" style="width: 300px" value="{formblock/formdata/fieldgroup/field[@name='videodata']/value}" />
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>
                </div>


                <!-- !!! -->
                <div id="grablist" class="subform" style="display:none;">
                    <div class="field">
                        <div class="title" style="width:100%;"><xsl:value-of select="$translate[@keyword='vid_grab_urls']"/> <span class="help"><xsl:value-of select="$translate[@keyword='vid_grab_urls_?']"/></span>:</div>
                        <div class="subfield" style="width:100%;">
                            <textarea name="urls[main]" class="textarea" style="width:100%; height:200px;"></textarea>
                        </div>

                        <div class="subfield" style="width:100%;">
                            <div class="title" style="width: auto;padding-top:4px;"><xsl:value-of select="$translate[@keyword='vid_grab_upllist']"/>:</div>
                            <input type="file" name="urls-file[main]" class="file" />
                        </div>

                        <input type="hidden" name="do_gallery[main]" value="1" />

                        <div class="title" style="width: auto;padding-top:3px;"><xsl:value-of select="$translate[@keyword='vid_grab_format']"/>:</div>
                        <div class="subfield" style="margin: 0 0 0 5px;">
                            <select name="format1[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format1']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>
                        <div class="subfield" style="margin-right: 0;">
                            <select name="format2[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format2']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>
                        <div class="subfield" style="margin-right: 0;">
                            <select name="format3[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format3']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>
                        <div class="subfield" style="margin-right: 0;">
                            <select name="format4[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format4']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>
                        <div class="subfield" style="margin-right: 0;">
                            <select name="format5[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format5']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>

                        <div class="subfield"><a href="javascript:void(0);" onclick="$(this).hide().closest('.subfield').nextAll('.none').show()"><xsl:text> </xsl:text><xsl:value-of select="$translate[@keyword='vid_more_formats']"/></a></div>

                        <div class="subfield none" style="margin-right: 0;">
                            <select name="format6[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format6']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>
                        <div class="subfield none" style="margin-right: 0;">
                            <select name="format7[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format7']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>
                        <div class="subfield none" style="margin-right: 0;">
                            <select name="format8[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format8']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>
                        <div class="subfield none" style="margin-right: 0;">
                            <select name="format9[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format9']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                            <xsl:text>|</xsl:text>
                        </div>
                        <div class="subfield none" style="margin-right: 0;">
                            <select name="format10[main]" class="select" style="width: 100px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format10']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="title" style="width: auto;padding-top:3px;margin-right:3px;"><xsl:value-of select="$translate[@keyword='vid_grab_sep1']"/>:</div>
                        <div class="subfield">
                            <input type="text" name="separator[main]" class="text" maxlength="1" value="{formblock/formdata/fieldgroup/field[@name='separator']/value}" style="padding: 0 5px;width:10px" onclick="$(this).select();"/>
                        </div>
                        <div class="title" style="width: auto;padding-top:3px;margin-right:3px;"><xsl:value-of select="$translate[@keyword='vid_grab_sep2']"/>:</div>
                        <div class="subfield">
                            <input type="text" name="separator2[main]" class="text" maxlength="1" value="{formblock/formdata/fieldgroup/field[@name='separator2']/value}" style="padding: 0 5px;width:10px" onclick="$(this).select();"/>
                        </div>

                        <input type="hidden" name="video[main]" value="1"/>
                        <input type="hidden" name="video_thumb[main]" value="1"/>
                        <input type="hidden" name="video_host[main]" value="1"/>

                        <div class="clear"></div>
                    </div>
                </div>

            </div>


            <div class="field buttonset">
                <div class="control" style="width:100%;"><input type="submit" value="{$translate[@keyword='frm_submit']}"/></div>
                <div class="clear"></div>
            </div>

        </form>
        </fieldset>
    </div>

</xsl:template>


<xsl:template match="block[@controller = 'video' and @action='parse']">
    <xsl:if test="not(@ident)">
        <a href="{$server}video/parse/xham"><img src='{$base}images/tube_xham.png'/></a>
    </xsl:if>

    <xsl:if test="@ident">
        <div class="settings form-wrapper">
            <fieldset>
            <form action="" method="post" enctype="multipart/form-data" class="chosenFORM">
                 <xsl:if test="formblock/errors/error">
                    <div class="error">
                        <ul>
                            <xsl:for-each select="formblock/errors/error">
                                <li><xsl:value-of select="message" /></li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </xsl:if>

                <xsl:if test="formblock/confirms/confirm">
                    <div class="confirm">
                        <ul>
                            <xsl:for-each select="formblock/confirms/confirm">
                                <li><xsl:value-of select="message" /></li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </xsl:if>

                <input type="hidden" name="formname" value="video.parse"/>
                <input type="hidden" name="action" value="parse"/>
                <input type="hidden" name="group[main]" value="main"/>

                <style>
                    .subfield {
                        float: left;
                        margin-right: 10px;
                    }
                    .chosen-select {
                        width: 150px;
                    }
                </style>

                <div class="field">
                    <div class="subfield">
                        <div class="title" style="width:100px;"><xsl:value-of select="$translate[@keyword='vid_template']"/></div>
                        <div style="">
                            <select name="tpl_id[main]" class="chosen-select">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='tpl_id']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                    </div>
                    <div class="subfield">
                        <div class="title" style="width:100px;"><xsl:value-of select="$translate[@keyword='vid_sponsor']"/></div>
                        <div style="">
                            <select name="sponsor_id[main]" data-placeholder="{$translate[@keyword='vid_choose_sponsor']}" class="chosen-select">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='sponsor_id']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <script type="text/javascript">$(document).ready(function(){$('#sponsor-main').autocomplete({serviceUrl:'sponsor/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                    </div>

                    <div class="subfield">
                        <div class="title" style="width:150px;"><xsl:value-of select="$translate[@keyword='vid_cats']"/></div>
                        <div style="">
                            <select name="niche_id[main][]" data-placeholder="{$translate[@keyword='vid_choose_category']}" class="chosen-select" multiple="multiple" style="width:350px;">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='niche_id']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <script type="text/javascript">$(document).ready(function(){$('#niche-main').autocomplete({serviceUrl:'niche/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                    </div>

                    <div class="subfield">
                        <div class="title" style="width:150px;"><xsl:value-of select="$translate[@keyword='vid_tags']"/></div>
                        <div style="">
                            <input type="text" name="tag[main]" id="tag-main" style="width: 150px" value="{formblock/formdata/fieldgroup/field[@name='tag']/value}" />
                        </div>
                        <script type="text/javascript">$(document).ready(function(){$('#tag-main').autocomplete({serviceUrl:'video/tag/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                    </div>

                    <div class="clear"></div>
                </div>


                <div class="field">
                    <div class="subfield">
                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='vid_qp']"/>:</div>
                        <div style="float: left;">
                            <select name="quality_profile[main]">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='quality_profile']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                    </div>
                    <div class="subfield">
                        <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='vid_tpv']"/>:</div>
                        <div style="float: left;">
                            <input type="text" name="gallery_thumbs[main]" style="width: 50px" value="{formblock/formdata/fieldgroup/field[@name='gallery_thumbs']/value}" />
                        </div>
                    </div>

                    <div class="clear"></div>
                </div>

                <div class="field">
                    <div class="subfield">
                        <label>
                            <input type="checkbox" name="convert[main]" value="1">
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='convert']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input>
                            <xsl:value-of select="$translate[@keyword='vid_convert']"/>?
                        </label>
                    </div>

                    <div class="clear"></div>
                </div>

                <div class="field">
                    <div class="subfield">
                        <div class="title"><nobr><b><xsl:value-of select="$translate[@keyword='vid_ignore']"/>:</b></nobr></div>
                    </div>

                    <div class="subfield" style="margin-right: 0;">
                        <label>
                            <input type="checkbox" name="ignore_date[main]" value="1" onclick="$(this).closest('.subfield').next('.subfield').toggle($(this).prop('checked'));" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_date']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input>
                            <xsl:value-of select="$translate[@keyword='vid_ignore_date']"/>
                        </label>
                    </div>
                    <div class="subfield">
                        <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_date']/options/option[not(@value=1 and @checked=1)]">
                            <xsl:attribute name="class">subfield none</xsl:attribute>
                        </xsl:if>
                        <input type="text" name="ignore_date_v[main]" value="{formblock/formdata/fieldgroup/field[@name='ignore_date_v']/value}" style="width: 30px; height: 13px;" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$translate[@keyword='vid_ignore_date_day']"/>
                    </div>

                    <div class="subfield" style="margin-right: 0;">
                        <label>
                            <input type="checkbox" name="ignore_rating[main]" value="1" onclick="$(this).closest('.subfield').next('.subfield').toggle($(this).prop('checked'));" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_rating']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_ignore_rating']"/>
                        </label>
                    </div>
                    <div class="subfield">
                        <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_rating']/options/option[not(@value=1 and @checked=1)]">
                            <xsl:attribute name="class">subfield none</xsl:attribute>
                        </xsl:if>
                        <input type="text" name="ignore_rating_v[main]" value="{formblock/formdata/fieldgroup/field[@name='ignore_rating_v']/value}" style="width: 30px; height: 13px;" />%
                    </div>

                    <div class="subfield" style="margin-right: 0;">
                        <label>
                            <input type="checkbox" name="ignore_views[main]" value="1" onclick="$(this).closest('.subfield').next('.subfield').toggle($(this).prop('checked'));" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_views']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_ignore_views']"/>
                        </label>
                    </div>
                    <div class="subfield">
                        <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_views']/options/option[not(@value=1 and @checked=1)]">
                            <xsl:attribute name="class">subfield none</xsl:attribute>
                        </xsl:if>
                        <input type="text" name="ignore_views_v[main]" value="{formblock/formdata/fieldgroup/field[@name='ignore_views_v']/value}" style="width: 30px; height: 13px;" />
                    </div>

                    <div class="subfield" style="margin-right: 0;">
                        <label>
                            <input type="checkbox" name="ignore_comments[main]" value="1" onclick="$(this).closest('.subfield').next('.subfield').toggle($(this).prop('checked'));" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_comments']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_ignore_comments']"/>
                        </label>
                    </div>
                    <div class="subfield">
                        <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_comments']/options/option[not(@value=1 and @checked=1)]">
                            <xsl:attribute name="class">subfield none</xsl:attribute>
                        </xsl:if>
                        <input type="text" name="ignore_comments_v[main]" value="{formblock/formdata/fieldgroup/field[@name='ignore_comments_v']/value}" style="width: 30px; height: 13px;" />
                    </div>




                    <div class="subfield" style="margin-right: 0;">
                        <label>
                            <input type="checkbox" name="ignore_dur_less[main]" value="1" onclick="$(this).closest('.subfield').next('.subfield').toggle($(this).prop('checked'));" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_dur_less']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_ignore_dur_less']"/>
                        </label>
                    </div>
                    <div class="subfield">
                        <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_dur_less']/options/option[not(@value=1 and @checked=1)]">
                            <xsl:attribute name="class">subfield none</xsl:attribute>
                        </xsl:if>
                        <input type="text" name="ignore_dur_less_v[main]" value="{formblock/formdata/fieldgroup/field[@name='ignore_dur_less_v']/value}" style="width: 30px; height: 13px;" />sec
                    </div>

                    <div class="subfield" style="margin-right: 0;">
                        <label>
                            <input type="checkbox" name="ignore_dur_more[main]" value="1" onclick="$(this).closest('.subfield').next('.subfield').toggle($(this).prop('checked'));" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_dur_more']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_ignore_dur_more']"/>
                        </label>
                    </div>
                    <div class="subfield">
                        <xsl:if test="formblock/formdata/fieldgroup/field[@name='ignore_dur_more']/options/option[not(@value=1 and @checked=1)]">
                            <xsl:attribute name="class">subfield none</xsl:attribute>
                        </xsl:if>
                        <input type="text" name="ignore_dur_more_v[main]" value="{formblock/formdata/fieldgroup/field[@name='ignore_dur_more_v']/value}" style="width: 30px; height: 13px;" />sec
                    </div>

                    <div class="clear"></div>
                </div>

                <div class="field">
                    <div class="subfield">
                        <div class="title"><nobr><b><xsl:value-of select="$translate[@keyword='vid_parse']"/>:</b></nobr></div>
                    </div>

                    <div class="subfield">
                        <label>
                            <input type="checkbox" name="parse_title[main]" value="1" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_title']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_parse_title']"/>
                        </label>
                    </div>

                    <div class="subfield">
                        <label>
                            <input type="checkbox" name="parse_descr[main]" value="1" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_descr']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_parse_descr']"/>
                        </label>
                    </div>

                    <div class="subfield">
                        <label>
                            <input type="checkbox" name="parse_rating[main]" value="1" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_rating']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_parse_rating']"/>
                        </label>
                    </div>

                    <div class="subfield">
                        <label>
                            <input type="checkbox" name="parse_views[main]" value="1" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_views']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_parse_views']"/>
                        </label>
                    </div>

                    <div class="subfield">
                        <label>
                            <input type="checkbox" name="parse_cats[main]" value="1" onclick="$(this).closest('.subfield').next('.subfield').toggle($(this).prop('checked'));" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_cats']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_parse_cats']"/>
                        </label>
                    </div>
                    <div class="subfield">
                        <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_cats']/options/option[not(@value=1 and @checked=1)]">
                            <xsl:attribute name="class">subfield none</xsl:attribute>
                        </xsl:if>
                        <label>
                            <input type="checkbox" name="parse_cats_create[main]" value="1" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_cats_create']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_parse_cats_create']"/>
                        </label>
                    </div>

                    <div class="subfield">
                        <label>
                            <input type="checkbox" name="parse_tags[main]" value="1" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_tags']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_parse_tags']"/>
                        </label>
                    </div>

                    <!--div class="subfield">
                        <label>
                        <input type="checkbox" name="parse_comment[main]" value="1" >
                                <xsl:if test="formblock/formdata/fieldgroup/field[@name='parse_comment']/options/option[@value=1 and @checked=1]">
                                    <xsl:attribute name="checked">checked</xsl:attribute>
                                </xsl:if>
                            </input> <xsl:value-of select="$translate[@keyword='vid_parse_comments']"/>
                        </label>
                    </div-->
                    <div class="clear"></div>
                </div>

                <div class="field">
                    <div class="subfield">
                        <div><xsl:value-of select="$translate[@keyword='vid_parse_page']"/></div>
                        <input type="text" name="url[main]" value="{formblock/formdata/fieldgroup/field[@name='url']/value}" style="width: 400px;"/>
                    </div>

                    <div class="clear"></div>
                </div>

                <div class="field">
                    <div class="subfield">
                        <div class="title" style="width: auto;padding: 4px 2px 0 0;"><nobr><xsl:value-of select="$translate[@keyword='vid_parse_limit']"/>: </nobr></div>
                        <input type="text" name="limit[main]" value="{formblock/formdata/fieldgroup/field[@name='limit']/value}" style="width: 30px;"/>
                    </div>

                    <div class="subfield">
                        <div class="title" style="width: auto;padding: 4px 2px 0 0;"><nobr><xsl:value-of select="$translate[@keyword='vid_parse_start']"/>: </nobr></div>
                        <input type="text" name="start[main]" value="{formblock/formdata/fieldgroup/field[@name='start']/value}" style="width: 30px;"/>
                    </div>

                    <div class="clear"></div>
                </div>

                <script type="text/javascript">
                    $('.chosen-select').chosen({width:"95%",no_results_text:'<xsl:value-of select="$translate[@keyword='vid_oops']"/>!'});
                    jQuery(function($) {
                        $("input[name=tasktype\\[main\\]]").click(function(){$('.subform').hide(250);$('#'+$(this).val()).show(250)});
                        $( "#tabs" ).tabs();
                    });
                </script>

                <div class="field buttonset">
                    <div class="control" style="width:100%;"><input type="submit" value="{$translate[@keyword='frm_submit']}"/></div>
                    <div class="clear"></div>
                </div>

            </form>
            </fieldset>
        </div>
    </xsl:if>

</xsl:template>


<!-- ######### /home/tigra/www/subs/subs/transformers/image.xsl ########## -->

<xsl:template match="block[@controller = 'image']">
    <div class="settings form-wrapper">
        <fieldset>
        <form action="" method="post" enctype="multipart/form-data" class="chosenFORM">
             <xsl:if test="formblock/errors/error">
                <div class="error">
                    <ul>
                        <xsl:for-each select="formblock/errors/error">
                            <li><xsl:value-of select="message" /></li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>

            <xsl:if test="formblock/confirms/confirm">
                <div class="confirm">
                    <ul>
                        <xsl:for-each select="formblock/confirms/confirm">
                            <li><xsl:value-of select="message" /></li>
                        </xsl:for-each>
                    </ul>
                </div>
            </xsl:if>

            <input type="hidden" name="formname" value="image.add"/>
            <input type="hidden" name="action" value="add"/>
            <input type="hidden" name="group[main]" value="main"/>

            <style>
                .subfield {
                    float: left;
                    margin-right: 10px;
                }
                .chosen-select {
                    width: 150px;
                }
            </style>

            <div class="field">
                <div class="subfield">
                    <div class="title" style="width:100px;"><xsl:value-of select="$translate[@keyword='img_template']"/></div>
                    <div style="">
                        <select name="tpl_id[main]" class="chosen-select">
                            <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='tpl_id']/options/option">
                                <option value="{@value}"><xsl:value-of select="text()"/></option>
                            </xsl:for-each>
                        </select>
                    </div>
                </div>
                <div class="subfield">
                    <div class="title" style="width:100px;"><xsl:value-of select="$translate[@keyword='img_sponsor']"/></div>
                    <div style="">
                        <select name="sponsor_id[main]" data-placeholder="{$translate[@keyword='img_choose_sponsor']}" class="chosen-select">
                            <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='sponsor_id']/options/option">
                                <option value="{@value}"><xsl:value-of select="text()"/></option>
                            </xsl:for-each>
                        </select>
                    </div>
                    <script type="text/javascript">$(document).ready(function(){$('#sponsor-main').autocomplete({serviceUrl:'sponsor/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                </div>

                <div class="subfield">
                    <div class="title" style="width:150px;"><xsl:value-of select="$translate[@keyword='img_cats']"/></div>
                    <div style="">
                        <select name="niche_id[main][]" data-placeholder="{$translate[@keyword='img_choose_category']}" class="chosen-select" multiple="multiple" style="width:350px;">
                            <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='niche_id']/options/option">
                                <option value="{@value}"><xsl:value-of select="text()"/></option>
                            </xsl:for-each>
                        </select>
                    </div>
                    <script type="text/javascript">$(document).ready(function(){$('#niche-main').autocomplete({serviceUrl:'niche/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                </div>

                <div class="subfield">
                    <div class="title" style="width:150px;"><xsl:value-of select="$translate[@keyword='img_tags']"/></div>
                    <div style="">
                        <input type="text" name="tag[main]" id="tag-main" style="width: 150px" value="" />
                    </div>
                    <script type="text/javascript">$(document).ready(function(){$('#tag-main').autocomplete({serviceUrl:'image/tag/autocomplete',minChars:1,delimiter: /(,|;)\s*/,maxHeight:190});});</script>
                </div>

                <div class="clear"></div>
            </div>

            <div class="field">
                <div class="subfield">
                    <div class="title" style="width:300px;"><xsl:value-of select="$translate[@keyword='img_titlescheme']"/> (<a href="settings/dics/" target="_blank"><xsl:value-of select="$translate[@keyword='img_vocs']"/></a>)</div>
                    <div style="">
                        <input type="text" name="title[main]" id="title-main" style="width: 300px" value="{formblock/formdata/fieldgroup/field[@name='title']/value}" />
                    </div>
                </div>

                <div class="clear"></div>
            </div>


            <div class="field">
                <div class="subfield">
                    <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='img_qp']"/>:</div>
                    <div style="float: left;">
                        <select name="quality_profile[main]">
                            <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='quality_profile']/options/option">
                                <option value="{@value}"><xsl:value-of select="text()"/></option>
                            </xsl:for-each>
                        </select>
                    </div>
                </div>
                <div class="subfield">
                    <div style="float: left; margin: 3px 3px 0 0; padding-left: 5px; border-left: 2px solid darkblue;"><xsl:value-of select="$translate[@keyword='img_ipg']"/>:</div>
                    <div style="float: left;">
                        <input type="text" name="gallery_thumbs[main]" style="width: 50px" value="{formblock/formdata/fieldgroup/field[@name='gallery_thumbs']/value}" />
                    </div>
                </div>

                <div class="clear"></div>
            </div>

            <script type="text/javascript">
                $('.chosen-select').chosen({width:"95%",no_results_text:'<xsl:value-of select="$translate[@keyword='img_oops']"/>!'});
                jQuery(function($) {
                    $("input[name=tasktype\\[main\\]]").click(function(){$('.subform').hide(250);$('#'+$(this).val()).show(250)});
                    $( "#tabs" ).tabs();
                });
            </script>

            <div id="tabs">
                <ul>
                    <li><a href="{$server}{$requested_uri}#local" rel="local" onclick="$('#tasktype').val($(this).attr('rel'))"><b><xsl:value-of select="$translate[@keyword='img_tab_local']"/></b></a></li>
                    <li><a href="{$server}{$requested_uri}#grablist" rel="grablist" onclick="$('#tasktype').val($(this).attr('rel'))"><b><xsl:value-of select="$translate[@keyword='img_tab_grab']"/></b></a></li>
                </ul>

                <input type="hidden" name="tasktype[main]" value="local" id="tasktype"/>


                <!-- !!! -->
                <div id="local" class="subform">

                    <div class="field">
                        <div class="subfield">
                            <div class="title" style="width:350px;"><xsl:value-of select="$translate[@keyword='img_local_dir']"/> <span class="help"><xsl:value-of select="$translate[@keyword='img_local_dir_?']" /></span></div>
                            <div style="">
                                <input type="text" name="imagedata[main]" id="imagedata-main" style="width: 300px" value="{formblock/formdata/fieldgroup/field[@name='imagedata']/value}" />
                            </div>
                        </div>

                        <div class="clear"></div>
                    </div>

                    <div class="field">
                        <div class="subfield">
                            <label><input type="checkbox" name="delete[main]" value="1" /> <xsl:value-of select="$translate[@keyword='img_delete_src']"/>?</label>
                        </div>

                        <div class="clear"></div>
                    </div>
                </div>

                <!-- !!! -->
                <div id="grablist" class="subform" style="display:none;">
                    <div class="field">
                        <div class="title" style="width:100%;"><xsl:value-of select="$translate[@keyword='img_grab_urls']"/> <span class="help"><xsl:value-of select="$translate[@keyword='img_grab_urls_?']"/></span>:</div>
                        <div class="subfield" style="width:100%;">
                            <textarea name="urls[main]" class="textarea" style="width:100%; height:200px;"></textarea>
                        </div>

                        <div class="subfield" style="width:100%;">
                            <div class="title" style="width: auto;padding-top:4px;"><xsl:value-of select="$translate[@keyword='img_grab_upllist']"/>:</div>
                            <input type="file" name="urls-file[main]" class="file" />
                        </div>

                        <input type="hidden" name="do_gallery[main]" value="1" />

                        <div class="title" style="width: auto;padding-top:3px;"><xsl:value-of select="$translate[@keyword='img_grab_format']"/>:</div>
                        <div class="subfield">
                            <select name="format1[main]" class="select">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format1']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <div class="subfield">
                            <select name="format2[main]" class="select">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format2']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <div class="subfield">
                            <select name="format3[main]" class="select">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format3']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <div class="subfield">
                            <select name="format4[main]" class="select">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format4']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <div class="subfield">
                            <select name="format5[main]" class="select">
                                <xsl:for-each select="formblock/formdata/fieldgroup/field[@name='format5']/options/option">
                                    <option value="{@value}">
                                        <xsl:if test="@checked = 1">
                                            <xsl:attribute name="selected">selected</xsl:attribute>
                                        </xsl:if>
                                        <xsl:value-of select="text()"/>
                                    </option>
                                </xsl:for-each>
                            </select>
                        </div>
                        <div class="title" style="width: auto;padding-top:3px;margin-right:3px;"><xsl:value-of select="$translate[@keyword='img_grab_sep1']"/>:</div>
                        <div class="subfield">
                            <input type="text" name="separator[main]" class="text" maxlength="1" value="|" style="padding: 0 5px;width:5px" onclick="$(this).select();"/>
                        </div>
                        <div class="title" style="width: auto;padding-top:3px;margin-right:3px;"><xsl:value-of select="$translate[@keyword='img_grab_sep2']"/>:</div>
                        <div class="subfield">
                            <input type="text" name="separator2[main]" class="text" maxlength="1" value=";" style="padding: 0 5px;width:5px" onclick="$(this).select();"/>
                        </div>

                        <input type="hidden" name="image[main]" value="1"/>
                        <input type="hidden" name="image_host[main]" value="1"/>

                        <div class="clear"></div>
                    </div>
                </div>


            </div>


            <div class="field buttonset">
                <div class="control" style="width:100%;"><input type="submit" value="{$translate[@keyword='frm_submit']}"/></div>
                <div class="clear"></div>
            </div>

        </form>
        </fieldset>
    </div>
</xsl:template>






    
</xsl:stylesheet>