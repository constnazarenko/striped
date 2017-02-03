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

    <!-- ######### /home/tigra/www/subs/subs/transformers/error.xsl ########## -->

<xsl:template match="document[@code='404']">
    <html>
        <head>
            <xsl:call-template name="metas" />
            <title><xsl:value-of select="$title" /></title>
            <base href="{$base}" />
            <xsl:call-template name="csslink" />
            <xsl:call-template name="csslink-custom" />
            <xsl:call-template name="jslink" />
            <xsl:call-template name="jslink-custom" />
        </head>
        <body>
            <xsl:apply-templates select="blocks/block[@name='root.menu']" />
            <div id="container">
                <div id="wrapper">
                    <div id="header">
                        <div style="margin-left: 20px;">
                            <div class="fleft"><xsl:apply-templates select="blocks/block[@type='header-left']" /></div>
                            <div class="fright"><xsl:apply-templates select="blocks/block[@type='header-right']" /></div>
                            <div class="clear"></div>
                        </div>
                        <h1 class="{$lang} fleft"><a href="{$server}"><xsl:value-of select="$title"/></a></h1>
                        <div class="fleft" style="width: 600px;">
                            <xsl:apply-templates select="blocks/block[@type='header']" />
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div id="content">
                        <div class="middle">
                            <h1 style="font-size: 80px;">404</h1>
                            <h2><xsl:value-of select="error/message" /></h2>
                            <p><xsl:apply-templates select="blocks/block[@controller='staticblock' and @name = 'error404']" /></p>
                        </div>
                    </div>
                    <div id="footer">
                        <xsl:apply-templates select="blocks/block[@type='footer']" />
                        <div class="clear"></div>
                    </div>
                </div>
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template match="document[@code='403']">
    <html>
        <head>
            <xsl:call-template name="metas" />
            <title><xsl:value-of select="$title" /></title>
            <base href="{$base}" />
            <xsl:call-template name="csslink" />
            <xsl:call-template name="csslink-custom" />
            <xsl:call-template name="jslink" />
            <xsl:call-template name="jslink-custom" />
        </head>
        <body>
            <xsl:apply-templates select="blocks/block[@name='root.menu']" />
            <div id="container">
                <div id="wrapper">
                    <div id="header">
                        <div style="margin-left: 20px;">
                            <div class="fleft"><xsl:apply-templates select="blocks/block[@type='header-left']" /></div>
                            <div class="fright"><xsl:apply-templates select="blocks/block[@type='header-right']" /></div>
                            <div class="clear"></div>
                        </div>
                        <h1 class="{$lang} fleft"><a href="{$server}"><xsl:value-of select="$title"/></a></h1>
                        <div class="fleft" style="width: 600px;">
                            <xsl:apply-templates select="blocks/block[@type='header']" />
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
                            <h1 style="font-size: 80px;">403</h1>
                            <xsl:apply-templates select="blocks/block[@type='content']" />
                        </div>
                    </div>
                    <div id="footer">
                        <xsl:apply-templates select="blocks/block[@type='footer']" />
                        <div class="clear"></div>
                    </div>
                </div>
            </div>
        </body>
    </html>
</xsl:template>



</xsl:stylesheet>