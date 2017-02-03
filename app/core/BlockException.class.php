<?php
/**
 * Contains BlockException class and error handler
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2012
 */

require_once('striped/app/core/CoreException.class.php');
require_once('striped/app/core/SystemEtc.class.php');
require_once('striped/app/lib/Responder.class.php');
require_once('striped/app/lib/Transformer.class.php');
require_once('striped/app/lib/XMLTreeWriter.class.php');

################################################################################

/**
 * BlockException - creates error documents
 *
 * @package Striped 3
 * @subpackage core
 */
class BlockException extends CoreException {

    /**
     * Constructor
     *
     * @access public
     * @param string $message
     * @param int $code
     * @param mixed $additional_data
     * @return void
     */
    public function __construct($message, $code=self::ERR_KERNEL_PANIC, $additional_data=null) {
        parent::__construct($message, $code, $additional_data);
    }

}
