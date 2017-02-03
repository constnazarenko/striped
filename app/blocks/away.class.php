<?php
/**
 * Contains away module class
 *
 * @package Striped 3
 * @subpackage blocks
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2013
 */

require_once('striped/app/core/BlockController.class.php');

################################################################################

/**
 * Go to link
 *
 * @package Striped 3
 * @subpackage blocks
 */
class away extends BlockController {
    /**
     * staticblock name
     * @var string
     * @access private
     */
    private $params;

    /**
     * Constructor
     *
     * @access public
     * @return void
     */
    public function __construct($name, $type, $params) {
        parent::__construct();
        $this->params = $params;
    }

    /**
     * Shows content
     *
     * @access public
     * @return void
     */
    public function go() {
        if ($this->router->getParams('link')) {
            $url = urldecode($this->router->getParams('link'));
            if (preg_match('#^https?://#i', $url) !== 1) {
                $url = 'http://'.$url;
            }
            $this->redirecttourl($url);
        } else {
            $this->redirectback();
        }
    }

    /**
     * Shows content
     *
     * @access public
     * @return void
     */
    public function redirect() {
        if ($this->params['link']) {
            $this->redirecttourl($this->params['link']);
        } else {
            $this->redirecttobase();
        }
    }

}
