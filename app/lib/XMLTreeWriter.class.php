<?php
/**
 * Contains XMLTreeWriter class
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 * @version $Id: XMLTreeWriter.class.php 4 2011-01-20 10:45:27Z tigra $
 */

################################################################################

/**
 * Transforms array to xml-tree
 *
 * @package Striped 3
 * @subpackage lib
 */
class XMLTreeWriter extends XMLWriter {
    /**
     * XMLTreeWriter instance
     *
     * @var XMLTreeWriter
     * @static
     * @access private
     */
    private static $instance;

    /**
     * Constructor
     *
     * @param bool[optional] $flush kills starting tag
     * @access public
     */
    public function __construct($flush=false) {
        $this->openMemory();
        $this->startDocument('1.0','UTF-8');
        $this->flush($flush);
    }

    /**
     * Transforms array to xml-tree
     * keyword "xmldata" writes xml-raw directly
     *
     * @param string $tree_name
     * @param array $stack some data
     * @param string[optional] $item_name
     * @param array[optional] $attributes some atrributes if needed
     * @param array[optional] $as_xml treat table cells as XML data
     * @access public
     * @sample $xml->writeTree('sampleTree', array('xmldata'=>'<xmlnode attr="12">1</xmlnode>','tes'=>'ok','ok'=>array('attributes'=>array('attr1'=>1,'attr2'=>'true'),'tes'=>'ok','ok'=>'yes')), 'item', array('attr1'=>1,'attr2'=>'true'), array('xmldata1', 'xmldata2'));
     * @return void
     */
    public function writeTree($tree_name, $stack, $item_name='item', $attributes=null, $as_xml = array()) {
        if (!is_array($as_xml)) {
            $as_xml = array($as_xml);
        }
        if (empty($stack)) {
            if(is_array($attributes)) {
                $this->startElement($tree_name);
                foreach($attributes as $name=>$value) {
                    $this->writeAttribute($name, $value);
                }
                $this->endElement();
            } else {
                $this->writeElement($tree_name);
            }
        } else {
            if (!is_array($stack)) {
                $stack = array('selftext'=>$stack);
            }

            if (isset($stack['selfname'])) {
                $tree_name = $stack['selfname'];
                unset($stack['selfname']);
            }

            $this->startElement($tree_name);

            if(is_array($attributes)) {
                foreach($attributes as $name=>$value) {
                    $this->writeAttribute($name, $value);
                }
            } elseif (isset($stack['attr'])) {
                foreach($stack['attr'] as $name=>$value) {
                    $this->writeAttribute($name, $value);
                }
                unset($stack['attr']);
            }

            if (isset($stack['nodename'])) {
                $item_name = $stack['nodename'];
                unset($stack['nodename']);
            }

            $lock = false;
            if (isset($stack['selftext'])) {
                if (!is_array($stack['selftext'])) {
                    $this->text($stack['selftext']);
                    $lock = true;
                } else {
                    $stack = $stack['selftext'];
                }
            }

            if (!$lock) {
                   foreach($stack as $name=>$value) {
                    if(!is_string($name)) {
                        $name = $item_name;
                    }
                    if (in_array($name, $as_xml)) {
                        $this->startElement($name);
                        $this->writeDeclaratedRaw($value);
                        $this->endElement();
                    } else {
                        if (!is_array($value)) {
                            if (!preg_match('#^[0-9].*#', $name)) {
                                $this->writeElement(preg_replace("/\s|-|\./", "",$name), $value);
                            } else {
                                $this->writeElement('numeric_name_error__'.$name, $value);
                            }
                        } else {
                            if (isset($value['attr'])) {
                                $attr = $value['attr'];
                                unset($value['attr']);
                            } else {
                                $attr = null;
                            }
                            $this->writeTree($name, $value, $item_name, $attr, $as_xml);
                        }
                    }
                }
            }

            $this->endElement();
        }
    }

    /**
     * Add include to xml
     *
     * @access public
     * @param string $path
     * @param boolean $method
     * @return void
     */
    public function writeInclude($path, $method = false) {
        $string = '#include virtual="'.$path.'"';
        if ($method) {
            $string .= ' wait="yes"';
        }
        $this->writeComment($string);
    }

    /**
     * Write a raw XML text with declaration
     *
     * @access public
     * @param string $content XML string
     * @return bool
     */
    public function writeDeclaratedRaw($content) {
        return $this->writeRaw(preg_replace('/^[^<]*<\?xml [^\(?>)]*\?>\n?/', '', $content, 1));
    }

    /**
     * Makes proper array for XML parser
     *
     * @deprecated
     * @param SimpleXMLElement $xml
     * @access private
     * @return array
     */
    public function simpleXMLToArray($xml){
        $return = array();
        if(!($xml instanceof SimpleXMLElement)) {
            return $return;
        }
        $name = $xml->getName();
        $_value = trim((string)$xml);
        if(strlen($_value) == 0) {
            $_value = null;
        }

        if($_value !== null) {
               $return['selftext'] = $_value;
        }

        $children = array();
        $k = array();
        foreach($xml->children() as $elementName => $child) {
            $value = $this->simpleXMLToArray($child);
            if(isset($k[$elementName])) {
                $children[] = $value;
            } else {
                $children[] = $value;
                $children['nodename'] = $elementName;
            }
        }

        if(count($children) > 0) {
            $return = array_merge($return, $children);
        }

        $attributes = array();
        foreach($xml->attributes() as $name => $value) {
            $attributes[$name] = trim($value);
        }
        if(count($attributes) > 0) {
               $return['attr'] = $attributes;
        }
        return $return;
    }

    /**
     * Clears xml document
     *
     * @access public
     * @return string
     */
    public function clear($flush=false) {
        $this->openMemory();
        $this->startDocument('1.0','UTF-8');
        $this->flush($flush);
    }

    /**
     * Returns xml document
     *
     * @param bool[optional] $flush clears buffer
     * @access public
     * @return string
     */
    public function getDocument($flush=true) {
        $this->endDocument();
        return $this->outputMemory($flush);
    }

    /**
     * Forbidden
     */
    public function __clone() {
        trigger_error('Clone is not allowed.', E_USER_ERROR);
    }

    /**
     * Forbidden
     */
    public function __wakeup() {
        trigger_error('Deserializing is not allowed.', E_USER_ERROR);
    }

    /**
     * Gets XMLTreeWriter instance
     *
     * @access public
     * @return XMLTreeWriter
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }

}