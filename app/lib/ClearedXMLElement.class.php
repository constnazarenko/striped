<?php
/**
 * Contains ClearedXMLElement class
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 */

/**
 * ClearedXMLElement class
 *
 * @package Striped 3
 * @subpackage lib
 */
class ClearedXMLElement extends SimpleXMLElement {
    /**
     * Returns attributes as a string
     *
     * @param string $name attribute name
     * @param string[optional] $get [string|str|array|integer|int|boolean|bool|float|double]
     * @access public
     * @return string
     */
    public function attr($name, $get='string') {
        foreach ($this->attributes() as $key => $val) {
            if ($key == $name) {
                switch ($get) {
                    case 'array':
                        return (array)$val;
                    case 'integer':
                    case 'int':
                        return (int)$val;
                    case 'boolean':
                    case 'bool':
                        if ((is_numeric((string)$val) && (string)$val == '0') || (string)$val == 'false' || (string)$val == '') {
                            return false;
                        } else {
                            return true;
                        }
                    case 'float':
                        return (float)$val;
                    case 'double':
                        return (double)$val;
                    case 'string':
                    case 'str':
                    default:
                        return (string)$val;
                }
            }
        }
        return null;
    }

    /**
     * Returns value as a string or something like that =)
     *
     * @param string[optional] $get [string|str|array|integer|int|boolean|bool|float|double]
     * @param string[optional] $subname for arrays
     * @access public
     * @return mixed
     */
    public function val($get='string', $subname=null) {
        switch ($get) {
            case 'array':
                if (!$subname) {
                    return (array)$this;
                }
                $narr = (array)$this;
                return $narr[$subname];
            case 'integer':
            case 'int':
                return (int)$this;
            case 'boolean':
            case 'bool':
                if ((is_numeric((string)$this) && (string)$this == '0') || (string)$this == 'false' || (string)$this == '') {
                    return false;
                } else {
                    return true;
                }
            case 'float':
                return (float)$this;
            case 'double':
                return (double)$this;
            case 'string':
            case 'str':
            default:
                return (string)$this;
        }
    }
}