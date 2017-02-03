<?php
/**
 * Contains SystemEtc class (singleton)
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 * @version $Id: SystemEtc.class.php 4 2011-01-20 10:45:27Z tigra $
 */

require_once('striped/app/lib/ClearedXMLElement.class.php');

################################################################################

/**
 * Loads configuration xml file
 *
 * @package Striped 3
 * @subpackage core
 */
class SystemEtc {
    /**
     * Path to config file
     */
    const CONFIG_FILEPATH = 'etc/';

    /**
     * Config file name
     */
    const CONFIG_FILENAME = 'global.xml';

    /**
     * SystemEtc file instance
     *
     * @var ClearedXMLElement
     * @access private
     */
    private $system_config;

    /**
     * SystemEtc instance
     *
     * @var SystemEtc
     * @static
     * @access private
     */
    private static $instance;

    /**
     * Constructor
     *
     * @access protected
     * @return void
     */
    protected function __construct() {
        if (!file_exists(self::CONFIG_FILEPATH.self::CONFIG_FILENAME) || !is_readable(self::CONFIG_FILEPATH.self::CONFIG_FILENAME)) {
            trigger_error('ERR_DEV_NO_CONFIG', E_USER_ERROR);
        } else {
            $this->system_config = simplexml_load_string(file_get_contents(self::CONFIG_FILEPATH.self::CONFIG_FILENAME), 'ClearedXMLElement');
        }
    }

    /**
     * Gets SystemEtc file instance
     *
     * @access public
     * @return ClearedXMLElement
     */
    public function get() {
        return $this->system_config;
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
     * Gets SystemEtc instance
     *
     * @access public
     * @return SystemEtc
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }
}