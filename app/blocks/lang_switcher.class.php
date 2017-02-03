<?php
/**
 * Contains lang_switcher module class
 *
 * @package Striped 3
 * @subpackage blocks
 * @author Constantine Nazarenko     http://nazarenko.me/    
 * @copyright Constantine Nazarenko 2009
 * @version $Id: lang_switcher.class.php 4 2011-01-20 10:45:27Z tigra $
 */

require_once('striped/app/core/BlockController.class.php');

################################################################################

/**
 * Creates menu items
 *
 * @package Striped 3
 * @subpackage blocks
 */
class lang_switcher extends BlockController {

    /**
     * Main menu action
     *
     * @access public
     * @return void
     */
    public function switcher() {
        $this->xml->writeRaw($this->etc->languages->asXML());
        $this->xml->writeElement('current', $this->router->getLang());
    }

}