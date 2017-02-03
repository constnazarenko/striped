<?php
/**
 * Contains captha module class
 *
 * @package Striped 2
 * @subpackage blocks
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2010
 */

require_once('striped/app/core/BlockController.class.php');
require_once('striped/app/lib/Scaptcha.class.php');

################################################################################

/**
 * Creates static text blocks
 *
 * @package Striped 2
 * @subpackage blocks
 */
class captcha extends BlockController {
    /**
     * Shows captcha image
     *
     * @access public
     * @return void
     */
    public function show() {
        $captcha = new Scaptcha();
        $_SESSION['captcha_keystring'] = $captcha->getKeyString();
        exit();
    }

    /**
     * Shows captcha stored key string
     *
     * @access public
     * @return void
     */
    public function validate() {
    	$result = array_value($_SESSION, 'captcha_keystring', null) === $this->router->getPost('code');
    	if (array_value($_SESSION, 'captcha_keystring', null) && !$result) {
    		unset($_SESSION['captcha_keystring']);
    	}
        $this->JSONRespond($result);
        exit();
    }

}