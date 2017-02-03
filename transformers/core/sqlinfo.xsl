<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

</xsl:stylesheet>