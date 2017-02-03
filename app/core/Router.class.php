<?php
/**
 * Contains Router class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009-11
 */

require_once('striped/app/core/Auth.class.php');
require_once('striped/app/core/SystemEtc.class.php');
require_once('striped/app/lib/ClearedXMLElement.class.php');

################################################################################

/**
 * Resolves requested URL and mapping it
 *
 * @package Striped 3
 * @subpackage core
 */
class Router {
    /**
     * Path to config file
     */
    const CONFIG_FILEPATH = 'etc/';

    /**
     * Config file name
     */
    const CONFIG_FILENAME = 'routes.xml';

    /**
     * Router instance
     *
     * @var Router
     * @static
     * @access private
     */
    private static $instance;

    /**
     * Routes config
     *
     * @var ClearedXMLElement
     * @access private
     */
    private $routes_config;

    /**
     * Current route config
     *
     * @var ClearedXMLElement
     * @access private
     */
    private $croute;

    /**
     * Modules list for current page
     *
     * @var array
     * @access private
     */
    private $modules = array();

    /**
     * Language identifier
     *
     * @var string
     * @access private
     */
    private $lang;

    /**
     * Component parameters
     *
     * @var array
     * @access private
     */
    private $parameters = array();


    /*
     * Parameters passed by GET method
     *
     * @var array
     * @access private
     */
    private $getparams = array();


    /**
     * Parameters passed by POST method
     *
     * @var array
     * @access private
     */
    private $postparams = array();

    /**
     * current route
     *
     * @var string
     * @access private
     */
    private $route;

    /**
     * current alias
     *
     * @var string
     * @access private
     */
    private $alias;

    /**
     * base url
     *
     * @var string
     * @access private
     */
    private $base_url;

    /**
     * server url
     *
     * @var string
     * @access private
     */
    private $server_url;

    /**
     * protocol
     *
     * @var string
     * @access private
     */
    private $protocol = '';

    /**
     * domain
     *
     * @var string
     * @access private
     */
    private $domain = '';

    /**
     * template
     *
     * @var string
     * @access private
     */
    private $template;

    /**
     * page title
     *
     * @var string
     * @access private
     */
    private $pagetitle = '';

    /**
     * page keywords
     *
     * @var string
     * @access private
     */
    private $pagekeywords = '';

    /**
     * page description
     *
     * @var string
     * @access private
     */
    private $pagedescription = '';

    /**
     * subdomain
     *
     * @var ClearedXMLElement
     * @access private
     */
    private $subdomain = '';

    /**
     * subdomain name
     *
     * @var string
     * @access private
     */
    private $subdomain_name = '';

    /**
     * request URL (without base and params)
     *
     * @var string
     * @access private
     */
    private $requested_page_uri = '';

    /**
     * true if we are on langless index
     *
     * @var boolean
     * @access private
     */
    private $langless_index = false;

    /**
     * true if there is only one language
     *
     * @var boolean
     * @access private
     */
    private $onlylang = false;

    /**
     * Route paremeters
     *
     * @var array
     * @access private
     */
    private $route_params = array();

    /**
     * Constructor
     *
     * @access public
     * @return void
     */
    public function __construct() {
        if (!file_exists(self::CONFIG_FILEPATH.self::CONFIG_FILENAME) || !is_readable(self::CONFIG_FILEPATH.self::CONFIG_FILENAME)) {
            trigger_error('ERR_DEV_NO_CONFIG', E_USER_ERROR);
        } else {
            if (!function_exists('ioncube_file_is_encoded') || !ioncube_file_is_encoded()) {
                $this->routes_config = simplexml_load_string(file_get_contents(self::CONFIG_FILEPATH.self::CONFIG_FILENAME), 'ClearedXMLElement');
            } else {
                $this->routes_config = simplexml_load_string(ioncube_read_file(self::CONFIG_FILEPATH.self::CONFIG_FILENAME), 'ClearedXMLElement');
            }
        }

        if (get_magic_quotes_gpc()) {
            function stripslashes_deep($value) {
                $value = is_array($value) ?
                            array_map('stripslashes_deep', $value) :
                            stripslashes($value);
                return $value;
            }

            $_POST = array_map('stripslashes_deep', $_POST);
            $_GET = array_map('stripslashes_deep', $_GET);
            $_COOKIE = array_map('stripslashes_deep', $_COOKIE);
            $_REQUEST = array_map('stripslashes_deep', $_REQUEST);
        }
    }


    /**
     * Searches for current route
     *
     * @access public
     * @param bool $routme
     * @return void
     */
    public function whoAmI($routme=true) {
        $etc = SystemEtc::instance()->get();

        $this->getparams = $_GET;
        $this->postparams = $_POST;

        $this->protocol = $etc->site->protocol;

        $this->base_url = $this->protocol.$etc->site->domain->val().$etc->site->root->val();
        $this->domain = $etc->site->domain->val();
        $this->server_url = rtrim($this->base_url,'/').'/';

        /* cutting off site root and additional parameters */
        if (isset($_SERVER['REQUEST_URI'])) {
            $p = explode('?', substr_replace($_SERVER['REQUEST_URI'], '', 0, strlen($etc->site->root->val())), 2);
            $this->requested_page_uri = rtrim($p[0], '/');
        } else {
            $this->requested_page_uri = '';
        }

        /* check if domain is correct and redirect if else*/
        if ($etc->site->redirect->val() && isset($_SERVER['HTTP_HOST']) && $_SERVER['HTTP_HOST'] !== $this->domain) {
            $responder = Responder::instance();
            $responder->setRedirect($this->server_url.(isset($_SERVER['REQUEST_URI'])?ltrim($_SERVER['REQUEST_URI'], '/') :''));
        }

        /* searching for language identifier */
        if (preg_match('/^([a-z]{2})(\/|$)/', $this->requested_page_uri, $match_url)) {
            $this->lang = $match_url[1];
            $uri_lang = true;
            $this->requested_page_uri = preg_replace('/^([a-z]{2})(\/|$)/', '', $this->requested_page_uri);
        } /*
         * DISABLED: lang identifier on subdomain
         * elseif (preg_match('/^([a-z]{2})\..*$/', $_SERVER['HTTP_HOST'], $matches)) {
            $uri_lang = true;
            $this->lang = $matches[1];
        } */elseif (isset($_SESSION['userinfo']['lang'])) {
            $this->lang = $_SESSION['userinfo']['lang'];
        }

        $this->onlylang = !(count($etc->languages->language) > 1);

        if (!$this->onlylang && $this->requested_page_uri == '' && !isset($uri_lang)) {
            $this->langless_index = true;
        }

        /* check lang and set default on empty or wrong */
        $lang = $etc->languages->xpath('language[@id = "'.$this->lang.'"]');
        if (!isset($lang[0]) || empty($lang[0])) {

            /* trying to get browser's default language */
            if (isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])) {
                $most_brws_lang = null;
                $most_brws_priority = 0;
                $result_brws_langs = array();
                // break up string into pieces (languages and q factors)
                preg_match_all('/([a-z]{1,8}(-[a-z]{1,8})?)\s*(;\s*q\s*=\s*(1|0\.[0-9]+))?/i', $_SERVER['HTTP_ACCEPT_LANGUAGE'], $lang_parse);
                if (count($lang_parse[1])) {
                    // create a list like "en" => 0.8
                    $brws_langs = array();
                    $brws_langs = array_combine($lang_parse[1], $lang_parse[4]);
                    foreach ($brws_langs as $bl => $val) {
                        if (!isset($result_brws_langs[substr($bl, 0, 2)]) || $result_brws_langs[substr($bl, 0, 2)] < $val) {
                            $result_brws_langs[substr($bl, 0, 2)] = ($val === '') ? 1 : $val ;
                        }
                    }
                }
                foreach ($etc->languages->language as $lang_node) {
                    if (isset($result_brws_langs[$lang_node->attr('id')]) && $result_brws_langs[$lang_node->attr('id')] > $most_brws_priority) {
                        $most_brws_lang = $lang_node->attr('id');
                        $most_brws_priority = $result_brws_langs[$lang_node->attr('id')];
                    }
                }
            }

            if (Auth::instance()->user('lang')) {
                $this->lang = Auth::instance()->user('lang');
            } elseif (!isset($most_brws_lang) || $most_brws_lang == null) {
                /* getting system default language if */
                if ($deflang = $etc->languages->xpath('language[@default = "1"]')) {
                    $this->lang = $deflang[0]->attr('id');
                } else {
                    throw new CoreException('There is no default language and none chosen.', CoreException::ERR_KERNEL_PANIC);
                }
            } else {
                $this->lang = $most_brws_lang;
            }
        }

        $_SESSION['userinfo']['lang'] = $this->lang;
        if (!$this->onlylang) {
            $this->server_url .= $this->lang.'/';
        }

        if ($routme) {
            /* searching for subdomain */
            if (preg_match('/^([^.]{4,20})\..*$/', str_replace($etc->site->domain->val(), '', array_value($_SERVER,'HTTP_HOST')), $matches) && isset($matches[1])) {
                $this->subdomain_name = $matches[1];
            }
            $subdomains = array();
            foreach ($this->routes_config->subdomain as $sbd) {
                $subdomains[] = $sbd->attr('name');
            }

            /* getting all routes for current subdomain */
            $subdomain = !empty($this->subdomain_name) ? in_array($this->subdomain_name, $subdomains) ? $this->subdomain_name : '*' : '' ;
            $sbdm = $this->routes_config->xpath('subdomain[@name="'.$subdomain.'"]');
            if (!isset($sbdm[0])) {
                throw new CoreException('Wrong subdomain name.', CoreException::ERR_404, array('real'=>$this->subdomain_name, 'parsed'=>$subdomain));
            } else {
                $this->subdomain = $sbdm[0];
            }
            /* subdomain template */
            $this->template = $sbdm[0]->attr('template');

            $sbd_routes = array();
            foreach ($this->subdomain->route as $route) {
                $sbd_routes[] = $route->attr('path');
                if ($route->attr('alias', 'bool')) {
                    $sbd_routes[] = $route->attr('alias');
                }
            }

            /* sorting subdomains */
            usort($sbd_routes, array($this, 'sortRoutes'));

            /* matching the most like */
            $route_found = false;
            $request = explode('/', $this->requested_page_uri);

            foreach($sbd_routes as $route_path) {
                if($this->compareRoutes(explode('/', rtrim($route_path, '/')), $request)) {
                    $cr = $this->subdomain->xpath('route[@path="'.$route_path.'" or @alias="'.$route_path.'"]');
                    $this->route = $route_path;
                    if (!isset($cr[0])) {
                        throw new CoreException('Error while fetching found route.', CoreException::ERR_KERNEL_PANIC, array('route path'=>$route_path));
                    } else {
                        $this->alias = $cr[0]->attr('alias', 'bool') ? $cr[0]->attr('alias') : $route_path ;
                        $this->croute = $cr[0];
                        /* route template */
                        if ($cr[0]->attr('template', 'bool')) {
                            $this->template = $cr[0]->attr('template');
                        }
                        /* route title */
                        if ($cr[0]->attr('title', 'bool')) {
                            $this->pagetitle = $cr[0]->attr('title');
                        }
                        /* route keywords */
                        if ($cr[0]->attr('keywords', 'bool')) {
                            $this->pagekeywords = $cr[0]->attr('keywords');
                        }
                        /* route description */
                        if ($cr[0]->attr('description', 'bool')) {
                            $this->pagedescription = $cr[0]->attr('description');
                        }
                        /* route type */
                        if ($cr[0]->attr('type', 'bool')) {
                            $this->type = $cr[0]->attr('type');
                        } else {
                            $this->type = 'xhtml';
                        }
                    }
                    $route_found = true;
                    break;
                }
            }

            if (!$route_found) {
                throw new CoreException('Page not found.', CoreException::ERR_404, array('uri'=>$this->requested_page_uri));
            }

            $this->geatherModules();
        }
    }

    /**
     * Geathering all modules for error page
     *
     * @access public
     * @return void
     */
    public function getErrorPageModules($code) {
        $cr = $this->routes_config->xpath('errorpage[@code="'.$code.'"]');
        if (!isset($cr[0])) {
            throw new CoreException('Error while fetching ERROR PAGE route.', CoreException::ERR_KERNEL_PANIC, array('route path'=>$route_path));
        } else {
            $this->croute = $cr[0];
            /* route type */
            if ($cr[0]->attr('type', 'bool')) {
                $this->type = $cr[0]->attr('type');
            } else {
                $this->type = 'xhtml';
            }
        }
        $this->geatherModules();
    }

    /**
     * Geathering all modules for current page
     *
     * @access private
     * @return void
     */
    private function geatherModules() {
        /* getting global modules for all site */
        foreach ($this->routes_config->global as $module) {
            $this->fetchModules($module);
        }
        /* excludes modules for current subdomain */
        foreach ($this->subdomain->exclude as $module) {
            if ($module->attr('name') == '*') {
                $this->modules = array();
                continue;
            }
            $this->fetchModules($module, false);
        }
        /* getting global modules for current subdomain */
        foreach ($this->subdomain->global as $module) {
            $this->fetchModules($module);
        }
        /* excludes module for current route */
        foreach ($this->croute->exclude as $module) {
            if ($module->attr('name') == '*') {
                $this->modules = array();
                continue;
            }
            $this->fetchModules($module, false);
        }
        /* getting modules for current route */
        foreach ($this->croute->include as $module) {
            $this->fetchModules($module);
        }
        /* getting parameters for current route */
        if ($this->croute->params->param) {
            foreach ($this->croute->params->param as $param) {
                $this->route_params[$param->attr('name')] = $param->val();
            }
        }
    }

    /**
     * Fetching data from xml config string
     *
     * @access private
     * @param ClearedXMLElement $module_xml
     * @param bool[optional] $include - if false - excudes module instead of including
     * @return void
     */
    private function fetchModules($module_xml, $include=true) {
        if (!Auth::instance()->user('superuser') && $module_xml->attr('logged') !== NULL && (($module_xml->attr('logged') === "0" && Auth::instance()->user('logged')) || ($module_xml->attr('logged') === "1" && !Auth::instance()->user('logged')))) {
            $include = false;
        }
        if ($include) {
            $this->modules[$module_xml->attr('name')] = array(
                'controller' => $module_xml->attr('controller'),
                'action' => $module_xml->attr('action'),
                'name' => $module_xml->attr('name'),
                'type' => $module_xml->attr('type'),
                'params' => null
            );
            if ($module_xml->params->param) {
                $rarr = array();
                foreach ($module_xml->params->param as $param) {
                    $rarr[$param->attr('name')] = $param->val();
                }
                $this->modules[$module_xml->attr('name')]['params'] = $rarr;
            }
            if ($module_xml->attr('logged') !== NULL) {
                $this->modules[$module_xml->attr('name')]['logged'] = $module_xml->attr('logged');
            }
        } elseif (isset($this->modules[$module_xml->attr('name')])) {
            unset($this->modules[$module_xml->attr('name')]);
        }
    }

    /**
     * Sorts routes from longer to shorter
     * @callback function for uksort
     *
     * @access private
     * @param string $a first string
     * @param string $b second string
     * @return int
     */
    private function sortRoutes($a, $b) {
        $as = explode('/', rtrim($a, '/'));
        $bs = explode('/', rtrim($b, '/'));
        if (count($as) > count($bs)) {
            return -1;
        } elseif (count($as) < count($bs)) {
            return 1;
        } else {
            if (empty($as) && empty($bs)) {
                return 0;
            } elseif (empty($as) || (strpos($as[(count($as)-1)], ':') === 0 && !empty($bs))) {
                return 1;
            } elseif (empty($bs) || (strpos($bs[(count($bs)-1)], ':') === 0 && !empty($as))) {
                return -1;
            }
            return strlen($bs[(count($bs)-1)]) - strlen($as[(count($as)-1)]);
        }
    }

    /**
     * Compares route to requested page uri
     *
     * @access private
     * @param array $a - route in config
     * @param array $b - requested page uri
     * @return bool
     */
    private function compareRoutes($a, $b) {
        if ($a === $b) {
            return true;
        } elseif (end($a) == '*') {
            $length = count($a)-1;
            array_splice($a, $length);
            $p = array_splice($b, $length);

            if ($this->compareRoutes($a, $b)) {
                $current_name = null;
                $params = array();
                foreach ($p as $param) {
                    if (!$current_name) {
                        $current_name = $param;
                    } else {
                        if (isset($this->parameters[$current_name]) && !is_array($this->parameters[$current_name])) {
                            $this->parameters[$current_name] = array($this->parameters[$current_name]);
                            $this->parameters[$current_name][] = urldecode($param);
                        } elseif(isset($this->parameters[$current_name])) {
                            $this->parameters[$current_name][] = urldecode($param);
                        } else {
                            $this->parameters[$current_name] = urldecode($param);
                        }
                        $current_name = null;
                    }
                }
                return true;
            } else {
                return false;
            }

        } elseif (count($a) == count($b)) {
            $named_params = array();
            foreach ($a as $key=>$segment) {
                if (strpos($segment, ':') !== false) {
                    $named_params[str_replace(':', '', $segment)] = urldecode($b[$key]);
                    continue;
                } elseif ($segment != $b[$key]) {
                    return false;
                }
            }
            $this->parameters = array_merge($this->parameters, $named_params);
            return true;
        }
        return false;
    }

    /**
     * Returns page title
     *
     * @access public
     * @return string
     */
    public function getPageTitle() {
        return $this->pagetitle;
    }

    /**
     * Returns page keywords
     *
     * @access public
     * @return string
     */
    public function getPageKeywords() {
        return $this->pagekeywords;
    }

    /**
     * Returns page keywords
     *
     * @access public
     * @return string
     */
    public function getPageDescription() {
        return $this->pagedescription;
    }

    /**
     * Changes page title
     *
     * @access public
     * @return string
     */
    public function setPageTitle($title) {
        $this->pagetitle = $title;
    }

    /**
     * Changes page keywords
     *
     * @access public
     * @return string
     */
    public function setPageKeywords($keywords) {
        $this->pagekeywords = $keywords;
    }

    /**
     * Changes page description
     *
     * @access public
     * @return string
     */
    public function setPageDescription($description) {
        $this->pagedescription = $description;
    }

    /**
     * Gets language submited language abbreviation
     *
     * @access public
     * @return string
     */
    public function getLang($default = false) {
        if(!$default) {
            return $this->lang;
        } else {
            $etc = SystemEtc::instance()->get();
            $lang = $etc->languages->xpath('language[@default = "1"]');
            return $lang[0]->attr('id');
        }
    }

    /**
     * Gets current template
     *
     * @access public
     * @return string
     */
    public function getTemplate() {
        return $this->template;
    }

    /**
     * Gets all parameters or defined parameter
     *
     * @access public
     * @param string[optional] $param_id defined parameter id
     * @param string[optional] $method GET or POST or PARAM
     * @return mixed
     */
    public function getParams($param_id=null, $method=null) {
        if ($method === 'GET') {
            $parameters = $this->getparams;
        } elseif($method === 'POST') {
            $parameters = $this->postparams;
        } elseif($method === 'PARAM') {
            $parameters = $this->parameters;
        } else {
            $parameters = array_merge($this->getparams, $this->postparams, $this->parameters);
        }
        if ($param_id !== null) {
            if (isset($parameters[$param_id])) {
                return $parameters[$param_id];
            } else {
                return null;
            }
        } else {
            return $parameters;
        }
    }

    /**
     * Gets parameter
     *
     * @access public
     * @param string[optional] $param_id defined parameter id
     * @return mixed
     */
    public function getParam($param_id=null) {
        return $this->getParams($param_id, 'PARAM');
    }

    /**
     * Gets GET data
     *
     * @access public
     * @param string[optional] $param_id defined parameter id
     * @return mixed
     */
    public function getGet($param_id=null) {
        return $this->getParams($param_id, 'GET');
    }

    /**
     * Get page ident
     *
     * @access public
     * @param string[optional] $param_id defined parameter id
     * @return mixed
     */
    public function getIdent() {
        return md5($this->getServer().$this->getRequestedURI().serialize($this->getParams()));
    }

    /**
     * Gets POST data
     *
     * @access public
     * @param string[optional] $param_id defined parameter id
     * @return mixed
     */
    public function getPost($param_id=null) {
        return $this->getParams($param_id, 'POST');
    }

    /**
     * Gets current route
     *
     * @access public
     * @return string
     */
    public function getRoute() {
        return $this->route;
    }

    /**
     * Gets current alias
     *
     * @access public
     * @return string
     */
    public function getAlias() {
        return $this->alias;
    }

    /**
     * Gets base URL
     *
     * @access public
     * @return string
     */
    public function getBase() {
        return $this->base_url;
    }

    /**
     * Gets server URL
     *
     * @access public
     * @return string
     */
    public function getServer() {
        return $this->server_url;
    }

    /**
     * Gets link to user's page (by name)
     *
     * @access public
     * @param string $username
     * @return string
     */
    public function getUserlink($username) {
        return $this->server_url.'user/'.$username.'/';
    }

    /**
     * Gets request URL (without base and params)
     *
     * @access public
     * @return string
     */
    public function getRequestedURI() {
        return $this->requested_page_uri;
    }

    /**
     * Gets request URL (without base and params)
     *
     * @access public
     * @return string
     */
    public function getRequestedGET() {
        $prms = array();
        foreach ($this->getGet() as $k=>$v) {
            if (is_array($v)) {
                $prms[] = $this->_grgARR($k,$v);
            } else {
                $prms[] = $k.'='.$v;
            }
        }
        return implode('&', $prms);
    }
    private function _grgARR($k,$v) {
        $prms = array();
        foreach ($v as $kk=>$vv) {
            if (is_array($vv)) {
                $prms[] = $k.$this->_grgARR('['.$kk.']',$vv);
            } else {
                $prms[] = $k.'['.$kk.']='.$vv;
            }
        }
        return implode('&', $prms);
    }

    /**
     * Gets protocol
     *
     * @access public
     * @return string
     */
    public function getProtocol() {
        return $this->protocol;
    }

    /**
     * Gets domain name
     *
     * @access public
     * @return string
     */
    public function getDomain() {
        return $this->domain;
    }

    /**
     * Gets subdomain name
     *
     * @access public
     * @return string
     */
    public function getSubdomain() {
        return $this->subdomain_name;
    }

    /**
     * Gets modules list
     *
     * @access public
     * @return array
     */
    public function getModules() {
        return $this->modules;
    }

    /**
     * Gets route parameters list
     *
     * @access public
     * @return array
     */
    public function getRouteParams() {
        return $this->route_params;
    }


    /**
     * Says true if we are on index page, and lang not set in URL
     *
     * @access public
     * @return boolean
     */
    public function isLanglessIndex() {
        return $this->langless_index;
    }

    /**
     * Gets route type
     *
     * @access public
     * @return array
     */
    public function getType() {
        return $this->type;
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
     * Gets URLResolver instance
     *
     * @access public
     * @return Router
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }
}
