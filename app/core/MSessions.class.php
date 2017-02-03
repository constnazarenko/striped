<?php
/**
 * Contains Memcache Sessions class.
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2011
 * @version $Id: MSessions.class.php 14 2011-01-20 12:49:14Z tigra $
 */

require_once('striped/app/core/MemcacheLayer.class.php');
require_once('striped/app/core/XMLEtc.class.php');
require_once('striped/app/lib/Responder.class.php');

/**
 * Allows to authenticate user
 *
 * @package Striped 3
 * @subpackage core
 * @final
 */
final class Sessions {
    /**
     * Session name
     *
     * @var string
     * @access private
     */
    private $sessionName = 'Striped3SID';

    /**
     * Session id
     *
     * @var string
     * @access private
     */
    private $sessionId;

    /**
     * Session id
     *
     * @var string
     * @access private
     */
    private $sessionData;

    /**
     * Timeout for session expire.
     *
     * @var int time to wait
     * @access private
     */
    private $timeout;

    /**
     * Cookies lifetime and garbage collector
     *
     * @var int max lifetime
     * @access private
     */
    private $cookieLifetime;

    /**
     * Sessions instance
     *
     * @var Sessions
     * @access private
     * @static
     */
    private static $instance;

    /**
     * Constructor
     *
     * @access protected
     * @return void
     */
    protected function __construct() {
        $xmletc = new XMLEtc('session');
        $etc = $xmletc->get();

        $this->timeout = $etc->timeout->val('int');
        $this->cookieLifetime = $etc->cookie_extralifetime->val('int');
        $this->sessionName = $etc->session_name->val();

        session_set_save_handler(
            array($this, 'open'),
            array($this, 'close'),
            array($this, 'read'),
            array($this, 'write'),
            array($this, 'destroy'),
            array($this, 'gc')
        );
        session_name($this->sessionName);

        session_set_cookie_params($this->cookieLifetime, $etc->cookie_path->val(), $etc->cookie_domain->val(), $etc->cookie_secure->val('bool'));

        if (isset($_COOKIE[$this->sessionName])) {
            $mc = MemcacheLayer::instance();
            if ($mc->get($_COOKIE[$this->sessionName])) {
                $this->crossup($_COOKIE[$this->sessionName]);
            } else {
                $response = Responder::instance();
                $response->deleteCookie(
                    $this->sessionName,
                    $etc->cookie_path->val(),
                    $etc->cookie_domain->val(),
                    $etc->cookie_secure->val('bool')
                );
            }
        }
    }

    /**
     * Get session name
     *
     * @access public
     * @return string
     */
    public function getName() {
        return $this->sessionName;
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
     * Gets MSessions instance
     *
     * @access public
     * @return MSessions
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    /**
     * Opens session
     *
     * @access public
     * @param string $savePath
     * @param string $sessionName
     * @return boolean
     */
    public function open($savePath, $sessionName) {
        return true;
    }

    /**
     * Closes session
     *
     * @access public
     * @return bool
     */
    public function close() {
        return true;
    }

    /**
     * Crosses up session id
     *
     * @access public
     * @return bool
     */
    public function crossup($sessionId) {
        $mc = MemcacheLayer::instance();
        $c_sid = session_id();

        if (!empty($c_sid)) {
            $mc->delete($c_sid, 0);
        }
        session_id($sessionId);
        $this->sessionId = $sessionId;
        $this->sessionData = $mc->get($sessionId);
        session_decode($mc->get($sessionId));
    }

    /**
     * Reads session
     * Must be used instead of open method
     *
     * @access public
     * @param string $sessionId
     * @return mixed
     */
    public function read($sessionId) {
        $this->sessionId = $sessionId;
        if (!empty($this->sessionData)) {
            return $this->sessionData;
        } else {
            $mc = MemcacheLayer::instance();
            $this->sessionData = $mc->get($this->sessionId);
            if ($this->sessionData === false) {
                $this->sessionData = '';
            }
            return $this->sessionData;
        }
    }

    /**
     * Write session data to DB
     *
     * @access public
     * @param string $sessionId
     * @param mixed $data
     * @return mixed
     */
    public function write($sessionId, $data) {
        $mc = MemcacheLayer::instance();
        return $mc->set($sessionId, $data, MEMCACHE_COMPRESSED, $this->timeout);
    }

    /**
     * Destroy session
     *
     * @access public
     * @param string $sessionId
     * @return bool
     */
    public function destroy($sessionId=null) {
        if (empty($sessionId)) {
            $sessionId = $this->sessionId;
        }
        $mc = MemcacheLayer::instance();
        return $mc->delete($this->sessionId);
    }

    /**
     * Garbage collector
     *
     * @access public
     * @param int $maxLifeTime session max lifetime
     * @return bool
     */
    public function gc($maxLifeTime) {
        return true;
    }

    /**
     * Replace
     *
     * @access public
     * @param int $maxLifeTime session max lifetime
     * @return bool
     */
    public function replace($sessionId, $sessionData) {
        $mc = MemcacheLayer::instance();
        $mc->replace($sessionId, $sessionData, MEMCACHE_COMPRESSED,$this->timeout);
    }

    /**
     * Sarts session
     *
     * @access public
     * @return void
     */
    public function start() {
        session_start();
        if ($this->sessionId) {
            $mc = MemcacheLayer::instance();
            $mc->prolongate($this->sessionId, $this->timeout);
        }
    }

}