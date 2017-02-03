<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

</xsl:stylesheet>