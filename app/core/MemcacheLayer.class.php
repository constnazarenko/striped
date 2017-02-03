<?php
/**
 * Contains MemcacheLayer class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2011
 * @version $Id: MemcacheLayer.class.php 4 2011-01-20 10:45:27Z tigra $
 */

require_once('striped/app/core/CoreException.class.php');
require_once('striped/app/core/XMLEtc.class.php');

################################################################################

/**
 * Memcache database layer
 *
 * @package Striped 3
 * @subpackage core
 */
class MemcacheLayer extends Memcache {
    /**
     * MemcacheLayer instance
     *
     * @var MemcacheLayer
     * @static
     * @access private
     */
    private static $instance;

    /**
     * Constructor
     *
     * @access private
     * @return void
     */
    private function __construct() {
        $xmletc = new XMLEtc('database');
        $etc = $xmletc->get();

        if (!$this->connect($etc->memcahce->host->val(), $etc->memcahce->port->val('int'), $etc->memcahce->timeout->val('int'))) {
            throw new CoreException('Could not connect to Memcache');
        }
    }

    /**
     * Prolongates row expiring
     *
     * @access public
     * @return void
     */
    public function prolongate($key, $expire) {
        $this->set($key, $this->get($key), MEMCACHE_COMPRESSED, $expire);
    }

    /**
     * Closes connection
     *
     * @access public
     * @return mixed
     */
    public function disconnect() {
        $this->memcache->close();
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
     * Gets MemcacheLayer instance
     *
     * @access public
     * @return MemcacheLayer
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }

}
