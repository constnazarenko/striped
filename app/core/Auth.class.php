<?php
/**
 * Contains Auth class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009-13
 */

require_once('striped/app/core/CoreException.class.php');
require_once('striped/app/core/MSessions.class.php');
require_once('striped/app/core/PgSQLLayer.class.php');
require_once('striped/app/core/MySQLLayer.class.php');
require_once('striped/app/core/Translater.class.php');
require_once('striped/app/core/XMLEtc.class.php');
require_once('striped/app/lib/Responder.class.php');

################################################################################

/**
 * Authenticates and authorizes users
 *
 * @package Striped 3
 * @subpackage core
 * @abstract
 */
final class Auth {

    /**
     * Database access layer
     *
     * @var PgSQLLayer
     * @access protected
     */
    protected $db;

    /**
     * Hold an instance of the class
     *
     * @var Auth
     * @access private
     * @static
     */
    private static $instance;

    /**
     * Current user id
     *
     * @var int
     * @access private
     */
    private $id;

    /**
     * Users cache
     *
     * @var array
     * @access private
     */
    private $users_cache = array();

    /**
     * User's data
     *
     * @var array
     * @access private
     */
    private $user = array(
        'id'       => 0,
        'username' => 'guest',
        'logged'   => false,
        'superuser'=> false
    );

    /**
     * ETC for sessions
     *
     * @var SimpleXMLElement
     * @access private
     */
    private $etc;

    /**
     * Constructor
     *
     * @access private
     * @return void
     */
    private function __construct() {
        $xmletc = new XMLEtc('session');
        $this->etc = $xmletc->get();
        $glbetc = new XMLEtc('global');
        $etc = $glbetc->get();

        if ($etc->site->db && $etc->site->db->val() == 'mysql') {
            $this->db = MySQLLayer::instance();
        } else {
            $this->db = PgSQLLayer::instance();
        }

        Sessions::instance()->start();

        if (isset($_SESSION['userinfo']['id'])) {
            $response = Responder::instance();
            $response->setCookie(
                                 Sessions::instance()->getName(),
                                 session_id(),
                                 time() + ((isset($_COOKIE[Sessions::instance()->getName().'rem'])) ? $this->etc->cookie_extralifetime->val('int') : $this->etc->cookie_lifetime->val('int')),
                                 $this->etc->cookie_path->val(),
                                 $this->etc->cookie_domain->val(),
                                 $this->etc->cookie_secure->val('bool')
                                );
            $this->id = $_SESSION['userinfo']['id'];
            $this->setUserinfo();
            $this->fetchUserActions();
            $this->fetchUserRoles();
            $this->user['logged'] = true;
            $_SESSION['userinfo'] = $this->user;
        }
    }

    /**
     * Authorizes current user
     *
     * @param string $username
     * @param string $password
     * @param boolean $remember
     * @access public
     * @return bool
     */
    public function authorize($username, $password, $remember=false) {
        $this->kill();
        $username = strtolower(trim($username));
        if (!strpos($username, '-')) {
            $username .= '-';
        }
        $password = $this->genpass($username, trim($password));

        $username_parts = explode('-',$username);

        $this->id = $this->db->selectValue("SELECT au.id FROM auth_user AS au
                                                JOIN customer AS c ON (c.id = au.customer_id)
                                            WHERE
                                                customer_id = customer_id($1)
                                            AND au.username = $2
                                            AND au.password = $3
                                            AND au.active = TRUE
                                            AND (c.status_id = status_id('customer', 'active') OR c.status_id = status_id('customer', 'new'))",
                                            array($username_parts[0], array_value($username_parts, 1, ''), $password),
                                            'id');
        if (!$this->id) {
            return false;
        }

        return $this->_authorize($username, $password, $remember);
    }

    /**
     * Renew authorization of current user
     *
     * @access public
     * @return bool
     */
    public function reauthorize() {
        $user = $this->db->select('
            SELECT * FROM auth_user
                WHERE id = $1 AND active = TRUE',
            array($this->user('id', true)),
            false);
        if (!$user) {
            return false;
        }
        $this->kill();
        $this->id = $user['id'];
        return $this->_authorize($user['username'], $user['password'], isset($_COOKIE[Sessions::instance()->getName().'rem']));
    }

    /**
     * Authorizes current user
     *
     * @param string $username
     * @param string $password
     * @param boolean $remember
     * @access private
     * @return bool
     */
    private function _authorize($username, $password, $remember=false) {
        $sid = md5($username.$password);
        $response = Responder::instance();
        $response->setCookie(
                             Sessions::instance()->getName(),
                             $sid,
                             time() + (($remember) ? $this->etc->cookie_extralifetime->val('int') : $this->etc->cookie_lifetime->val('int')),
                             $this->etc->cookie_path->val(),
                             $this->etc->cookie_domain->val(),
                             $this->etc->cookie_secure->val('bool')
                            );
        if ($remember) {
            $response->setCookie(
                                 Sessions::instance()->getName().'rem',
                                 $remember,
                                 time() + $this->etc->cookie_extralifetime->val('int'),
                                 $this->etc->cookie_path->val(),
                                 $this->etc->cookie_domain->val(),
                                 $this->etc->cookie_secure->val('bool')
                                );
        }
        Sessions::instance()->crossup($sid);
        $this->setUserinfo();
        $this->fetchUserActions();
        $this->fetchUserRoles();
        $this->user['logged'] = true;
        $_SESSION['userinfo'] = $this->user;
        return true;
    }

    /**
     * Swicth to user
     *
     * @param string $username
     * @access public
     * @return bool
     */
    public function sudo($username) {
        $username = strtolower(trim($username));

        $username_parts = explode('-',$username);

        $this->kill(true, false);

        $this->id = $this->db->selectValue('SELECT id FROM auth_user WHERE customer_id = customer_id($1) AND username = $2', array($username_parts[0], array_value($username_parts, 1, '')), 'id');
        if (!$this->id) {
            return false;
        }

        $sid = md5($username.'temporary');

        $response = Responder::instance();
        $response->setCookie(
                             Sessions::instance()->getName(),
                             $sid,
                             time() + $this->etc->cookie_lifetime->val('int'),
                             $this->etc->cookie_path->val(),
                             $this->etc->cookie_domain->val(),
                             $this->etc->cookie_secure->val('bool')
                            );

        Sessions::instance()->crossup($sid);
        $this->setUserinfo();
        $this->fetchUserActions();
        $this->fetchUserRoles();
        $this->user['logged'] = true;
        $_SESSION['userinfo'] = $this->user;
        return true;
    }

    /**
     * Updates user's session
     *
     * @param int $uid
     * @access public
     * @return bool
     */
    public function update($uid) {
        if (!$user = $this->getUser($uid)) {
            return false;
        }
        $user['logged'] = true;
        $sid = md5($user['username'].$user['password']);

        Sessions::instance()->replace($sid, 'userinfo|'.serialize($user));
    }

    /**
     * Logs out user
     *
     * @param int $uid
     * @access public
     * @return bool
     */
    public function logout($uid) {
        if (!$user = $this->getUser($uid)) {
            return false;
        }
        $sid = md5($user['username'].$user['password']);
        return Sessions::instance()->destroy($sid);
    }

    /**
     * Generetes hash for passwords
     *
     * @param string $username
     * @param string $password
     * @access public
     * @return boolean
     */
    public function genpass($username, $password) {
        $username_parts = explode('-', $username);
        $cid = $this->db->selectValue('SELECT id FROM customer WHERE login = $1', array($username_parts[0]));
        if (!$cid) {
            throw new CoreException('Unkown customer', 403);
        }
        return hash('haval160,4', $cid.array_value($username_parts, 1, '').'stripedsec'.$password);
    }

    /**
     * Clears all session info - session, cookie...
     *
     * @access public
     * @param bool[optional] $cookie clean
     * @param bool[optional] $data kill from db
     * @return boolean
     */
    public function kill($cookie=true, $data=true) {
        $resp = Responder::instance();
        if ($cookie) {
            $resp->deleteCookie(
                                Sessions::instance()->getName(),
                                $this->etc->cookie_path->val(),
                                $this->etc->cookie_domain->val(),
                                $this->etc->cookie_secure->val('bool')
                               );
            $resp->deleteCookie(
                                Sessions::instance()->getName().'rem',
                                $this->etc->cookie_path->val(),
                                $this->etc->cookie_domain->val(),
                                $this->etc->cookie_secure->val('bool')
                               );
        }
        if ($data && isset($_SESSION['userinfo'])) {
            unset($_SESSION['userinfo']);
        }

        $this->users_cache = array();
        $this->user = array(
            'username' => 'guest',
            'logged'   => false
        );
        $this->id = null;
    }

    /**
     * Retrieves user's information
     *
     * @access private
     * @return void
     */
    private function setUserinfo() {
        $this->user = $this->_fetchUserinfo($this->id);
        $this->db->update('auth_user', array('lastvisit' => 'NOW()'), array('id' => $this->id));
    }

    /**
     * Retrieves user's information
     *
     * @access private
     * @param integer $user
     * @return void
     */
    private function _fetchUserinfo($user) {
        $ui = $this->db->select("
                    SELECT au.*, lang_name(au.lang_id) as lang, customer_name(au.customer_id) as customer_name, class_name(customer.type_id) = 'root' as superuser
                    FROM auth_user as au
                    LEFT JOIN customer ON (au.customer_id = customer.id)
                    WHERE au.id = $1
               ", array((int)$user), false);
        if ($ui['superuser'] != 't' && $ui['superuser'] != 1) {
            unset($ui['superuser']);
        }
        $ui['fullname'] = $ui['customer_name'].($ui['username']?'-'.$ui['username']:'');
        return $ui;
    }

    /**
     * Retrieves user's actions
     *
     * @access private
     * @return array
     */
    private function fetchUserActions() {
        $this->user['actions'] = $this->_fetchUserActions($this->id);
    }

    /**
     * Retrieves some user user's action
     *
     * @access private
     * @return array
     */
    private function _fetchUserActions($user) {
        $actions = $this->db->select('SELECT aua.category, aua.action FROM auth_user_action as aua WHERE user_id = $1', array((int)$this->id));
        $ua = array();
        foreach ($actions as $a) {
            if ($a['category'] == 'action') {
                $ch = $this->db->select("SELECT class_name(parent_id) as category, name as action FROM class WHERE parent_id = class_id('action', $1)", array($a['action']));
                foreach($ch as $c) {
                    $ua[$c['category']][$c['action']] = true;
                }
                continue;
            }
            $ua[$a['category']][$a['action']] = true;
        }
        return $ua;
    }

    /**
     * Retrieves user's roles
     *
     * @access private
     * @return array
     */
    private function fetchUserRoles() {
        $this->user['roles'] = $this->_fetchUserRoles($this->id);
    }

    /**
     * Retrieves some user user's roles
     *
     * @access private
     * @return array
     */
    private function _fetchUserRoles($user) {
        return $this->db->select('SELECT role_name(role_id) as role, role_id as id FROM auth_role_user WHERE user_id = $1', array((int)$this->id));
    }


    /**
     * Returns current user's info
     *
     * @access public
     * @param string[optional] $infoname
     * @param bool[optional] $strict
     * @return mixed
     */
    public function user($infoname=null, $strict=false) {
        if ($strict && !$this->user['logged']) {
            throw new CoreException(Translater::instance()->translate('auth_must_login'), CoreException::ERR_403);
        }

        if (!empty($infoname) && isset($this->user[$infoname])) {
            return $this->user[$infoname];
        } elseif(!empty($infoname)) {
            return false;
        }
        $this->user['sessid'] = session_id();
        return $this->user;
    }

    /**
     * Returns custom user's info
     *
     * @access public
     * @param int $id
     * @param string[optional] $infoname
     * @return mixed
     */
    public function getUser($id, $infoname=null) {
        $id = (int) $id;
        if (!isset($this->users_cache[$id])) {
            $this->users_cache[$id] = $this->_fetchUserinfo($id);
            $this->users_cache[$id]['actions'] = $this->_fetchUserActions($id);
            $this->users_cache[$id]['roles'] = $this->_fetchUserRoles($id);
        }
        if (!empty($infoname) && isset($this->users_cache[$id][$infoname])) {
            return $this->users_cache[$id][$infoname];
        } elseif(!empty($infoname)) {
            return false;
        }

        return $this->users_cache[$id];
    }

    /**
     * Returns custom user's info by his name
     *
     * @access public
     * @param string $username
     * @param string[optional] $infoname
     * @return bool|array|string
     */
    public function getUserByName($username, $infoname=null) {
        $uid = $this->db->selectValue('SELECT id FROM auth_user WHERE username = $1', array($username), 'id');
        return (!$uid) ? false : $this->getUser($uid, $infoname);
    }

    /**
     * Finds users by part of the name
     *
     * @access public
     * @param string $name_part
     * @return mixed
     */
    public function findUsers($name_part) {
        $userlist = $this->db->selectValues('SELECT username FROM auth_user WHERE username LIKE $1', array($name_part.'%'), 'username');
        return (!$userlist) ? false : $userlist;
    }

    /**
     * Sets langauge to user's profile in DB.
     *
     * @access public
     * @param string $lang
     * @return void
     */
    public function setUserLang($lang) {
        if ($this->user('id') && $this->user('lang') != $lang) {
            $this->db->pupdate('UPDATE auth_user SET lang_id = lang_id($1) WHERE id = $2', array($lang, $this->user('id')));
            $this->reauthorize();
        } else {
            $_SESSION['userinfo']['lang'] = $lang;
        }
    }

    /**
     * Logs access
     *
     * @access public
     * @param string $accesspoint
     * @param string[optional] $referer
     * @return void
     */
    public function logAccess($accesspoint, $params, $referer='NULL') {
        foreach ($params as $k => &$p) {
            if ($k == 'password' ||
                $k == 'cpassword' ||
                $k == 'password_confirm' ||
                $k == 'current_password' ||
                $k == 'reg_password' ||
                $k == 'pass' ||
                $k == 'passwd' ||
                $k == 'auth_password'
                ) {
                $p = '*****';
            }
        }
        $params["user_ip"] = get_ip();

        $data = array(
            'accesspoint'=>$accesspoint,
            'params'=>base64_encode(json_encode($params)),
            'referer'=>$referer
        );
        if ($this->user['logged']) {
            $data['user_id'] = $this->user('id');
        }

        $this->db->insert('global_log_access', $data);
    }

    /**
     * Gets Auth instance
     *
     * @access public
     * @return Auth
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }
}
