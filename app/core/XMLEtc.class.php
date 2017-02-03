<?php
/**
 * Contains SystemEtc class (singleton)
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 */

require_once('striped/app/lib/ClearedXMLElement.class.php');

################################################################################

/**
 * Loads configuration xml file
 *
 * @package Striped 3
 * @subpackage lib
 */
class XMLEtc {
    /**
     * Path to config file
     */
    const CONFIG_FILEPATH = 'etc/';

    /**
     * Extension of the config file
     */
    const CONFIG_EXTENSION = '.xml';

    /**
     * Config file name
     *
     * @var string
     * @access private
     */
    private $config_name;

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
     * @param string $name of the config
     * @access protected
     * @return void
     */
    public function __construct($name) {
        $this->config_name = $name;
        if (!file_exists(self::CONFIG_FILEPATH.$this->config_name.self::CONFIG_EXTENSION) || !is_readable(self::CONFIG_FILEPATH.$this->config_name.self::CONFIG_EXTENSION)) {
            trigger_error('ERR_DEV_NO_CONFIG', E_USER_ERROR);
        } else {
            $this->system_config = simplexml_load_string(file_get_contents(self::CONFIG_FILEPATH.$this->config_name.self::CONFIG_EXTENSION), 'ClearedXMLElement');
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
}