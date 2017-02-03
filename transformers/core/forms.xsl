<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

</xsl:stylesheet>
