<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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
    
</xsl:stylesheet>