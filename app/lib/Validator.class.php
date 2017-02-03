<?php
/**
 * Contains Validator class
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009-11
 */

################################################################################

/**
 * Validator class
 * Validates data
 *
 * @package Striped 3
 * @subpackage lib
 */
class Validator {
    /**
     * Lenght more than and less than
     *
     * @param string $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function length($string, $params) {
        if (strlen($string) >= $params[0] && strlen($string) <= $params[1]) {
            return $string;
        } else {
            return false;
        }
    }

    /**
     * Check minimal length
     *
     * @param string $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function minlength($string, $params) {
        if (strlen($string) >= $params[0]) {
            return $string;
        } else {
            return false;
        }
    }

    /**
     * Check maximum length
     *
     * @param string $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function maxlength($string, $params) {
        if (strlen($string) <= $params[0]) {
            return $string;
        } else {
            return false;
        }
    }

    /**
     * Numeric in range
     *
     * @param string $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function range($num, $params) {
        if ($num >= $params[0] && $num <= $params[1]) {
            return $num;
        } else {
            return false;
        }
    }

    /**
     * Numeric lesser than
     *
     * @param string $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function lt($num, $params) {
        if ($num < $params[0]) {
            return $num;
        } else {
            return false;
        }
    }

    /**
     * Numeric greater than
     *
     * @param string $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function gt($num, $params) {
        if ($num > $params[0]) {
            return $num;
        } else {
            return false;
        }
    }

    /**
     * Numeric lesser than
     *
     * @param string $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function lte($num, $params) {
        if ($num <= $params[0]) {
            return $num;
        } else {
            return false;
        }
    }

    /**
     * Numeric greater than
     *
     * @param string $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function gte($num, $params) {
        if ($num >= $params[0]) {
            return $num;
        } else {
            return false;
        }
    }

    /**
     * Check if string is e-mail
     *
     * @param string $string
     * @access public
     * @return bool
     * @static
     */
    public static function email($string) {
    	if (preg_match('/^[a-z0-9_.+-]+@([a-z0-9-]+\.)+[a-z]{2,4}$/i', trim($string))) {
            return trim($string);
        } else {
            return false;
        }
    }

    /**
     * Check if string is stack of e-mail
     *
     * @param string $string
     * @access public
     * @return bool
     * @static
     */
    public static function emails($string) {
        if (preg_match('/^([a-z0-9_.+-]+@([a-z0-9-]+\.)+[a-z]{2,4},? ?)+$/i', trim($string))) {
            return trim($string);
        } else {
            return false;
        }
    }

    /**
     * Check if string is phone number
     *
     * @param string $string
     * @access public
     * @return bool
     * @static
     */
    public static function phone($string) {
        if (preg_match('/^[+]?[()0-9 -]{3,20}$/', trim($string))) {
            return trim($string);
        } else {
            return false;
        }
    }

    /**
     * Check if string is integer =)
     *
     * @param string $string
     * @access public
     * @return bool
     * @static
     */
    public static function integer($string) {
        if (preg_match('/^[0-9]*$/', trim($string))) {
            return trim($string);
        } else {
            return false;
        }
    }

    /**
    * Check if string is valid date-time format for PostgreSQL
    *
    * @param string $string
    * @access public
    * @return bool
    * @static
    */
    public static function datetime($string) {
    	if (preg_match('/^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}(:[0-9]{2})?)?$/', trim($string))) {
    		return trim($string);
    	} else {
    		return false;
    	}
    }

    /**
    * Check if string is valid date-time format for PostgreSQL
    *
    * @param string $string
    * @access public
    * @return bool
    * @static
    */
    public static function ipv4($ip) {
    	if (filter_var(trim($ip), FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
    		return trim($ip);
    	} else {
    		return false;
    	}
    }

    /**
     * RegExp check
     *
     * @param string|array $string
     * @param array $params
     * @access public
     * @return bool
     * @static
     */
    public static function regexp($data, $params) {
        if (is_string($data) && preg_match($params[0], trim($data))) {
            return trim($data);
        } elseif (is_array($data)) {
            $flag = $data;
            foreach ($data as $d) {
                if (!preg_match($params[0], trim($d))) {
                    $flag = false;
                }
            }
            return $flag;
        } else {
            return false;
        }
    }
}
