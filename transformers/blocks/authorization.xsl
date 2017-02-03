<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

</xsl:stylesheet>