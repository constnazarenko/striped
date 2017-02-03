<?php
/**
 * Contains menu module class
 *
 * @package Striped 3
 * @subpackage blocks
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 * @version $Id: menu.class.php 4 2011-01-20 10:45:27Z tigra $
 */

require_once('striped/app/core/BlockController.class.php');
require_once('striped/app/lib/ClearedXMLElement.class.php');

################################################################################

/**
 * Creates menu items
 *
 * @package Striped 3
 * @subpackage blocks
 */
class menu extends BlockController {
    /**
     * Path to menu
     */
    const path = 'menu/';

    /**
     * Menu descriptors file extension
     */
    const ext = '.xml';

    /**
     * Block's name
     *
     * @var string
     * @access private
     */
    private $name;

    /**
     * Block's type
     *
     * @var string
     * @access private
     */
    private $type;

    /**
     * Constructor
     *
     * @access public
     * @return void
     */
    public function __construct($name, $type) {
        parent::__construct();
        $this->name = $name;
        $this->type = $type;
    }

    /**
     * Menu show
     *
     * @access public
     * @return void
     */
    public function show() {
        if ($this->type == 'root-service') {
            $this->xml->writeAttribute('css', 'striped/css/root.menu.css');
        }

        if (file_exists(self::path.$this->name.self::ext) && is_readable(self::path.$this->name.self::ext)) {
            $descriptor = simplexml_load_string(file_get_contents(self::path.$this->name.self::ext), 'ClearedXMLElement');
            $this->xml->writeDeclaratedRaw($descriptor->asXML());
        } else {
            throw new CoreException($this->translate('MENU_CANT_FIND_DESCRIPTOR'), 0, array('descriptor'=>self::path.$this->name.self::ext));
        }
    }

}