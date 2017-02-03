<?php
/**
 * Contains BlockController class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009-12
 */

require_once('striped/app/core/Auth.class.php');
require_once('striped/app/core/CoreException.class.php');
require_once('striped/app/core/MemcacheLayer.class.php');
require_once('striped/app/core/PgSQLLayer.class.php');
require_once('striped/app/core/MySQLLayer.class.php');
require_once('striped/app/core/Router.class.php');
require_once('striped/app/core/SystemEtc.class.php');
require_once('striped/app/core/Translater.class.php');
require_once('striped/app/lib/Responder.class.php');
require_once('striped/app/lib/Rights.class.php');
require_once('striped/app/lib/XMLTreeWriter.class.php');

################################################################################

/**
 * Service class for modules
 *
 * @package Striped 3
 * @subpackage core
 * @abstract
 */
abstract class BlockController {

    /**
     * Router instance
     *
     * @var Router
     * @access protected
     */
    protected $router;

    /**
     * System Etc
     *
     * @var SystemEtc
     * @access protected
     */
    protected $etc;

    /**
     * Output xml
     *
     * @var XMLTreeWriter
     * @access protected
     */
    protected $xml;

    /**
     * Database access layer
     *
     * @var PgSQLLayer
     * @access protected
     */
    protected $db;

    /**
     * Cache access layer
     *
     * @var MemcacheLayer
     * @access protected
     */
    protected $cache;

    /**
     * Rights
     *
     * @var Rights
     * @access protected
     */
    protected $rights;

    /**
     * Constructor
     *
     * @access public
     * @return void
     */
    public function __construct() {
        $this->router = Router::instance();
        $this->etc = SystemEtc::instance()->get();
        $this->xml = XMLTreeWriter::instance();

        if ($this->etc->site->db && $this->etc->site->db->val() == 'mysql') {
            $this->db = MySQLLayer::instance();
        } else {
            $this->db = PgSQLLayer::instance();
        }
        $this->cache = MemcacheLayer::instance();
    }


    /******************************/
    /*                            */
    /*        USER SECTION        */
    /*                            */
    /******************************/

    /**
     * Retranslates to Auth::user()
     *
     * @access protected
     * @param string[optional] $infoname
     * @param bool[optional] $strict
     * @return bool|array|string
     */
    protected function user($infoname=null, $strict=false) {
        return Auth::instance()->user($infoname, $strict);
    }


    /**
     * Checks if user can do
     *
     * @access protected
     * @param string $action
     * @return boolean
     */
    protected function actionAllowed($action) {
        $as = explode('.', $action, 2);
        $actions = Auth::instance()->user('actions');
        return array_value($as, 1) ? isset($actions[$as[0]][$as[1]]) : isset($actions[$as[0]]);
    }

    /**
     * Checks if user has role
     *
     * @access protected
     * @param string $role
     * @param integer $id
     * @return boolean
     */
    protected function hasRole($role=null,$id=null) {
        $roles = Auth::instance()->user('roles');
        foreach ($roles as $r) {
            if ($role && $role == $r['role']) {
                return true;
            }
            if ($id && $id == $r['id']) {
                return true;
            }
        }
        return false;
    }

    /**
     * Retranslates to Auth::getUser()
     *
     * @access protected
     * @param int $id
     * @param string[optional] $infoname
     * @return bool|array|string
     */
    protected function getUser($id, $infoname=null) {
        return Auth::instance()->getUser((int) $id, $infoname);
    }

    /**
     * Retranslates to Auth::getUserByName()
     *
     * @access protected
     * @param string $username
     * @param string[optional] $infoname
     * @return bool|array|string
     */
    protected function getUserByName($username, $infoname=null) {
        return Auth::instance()->getUserByName((string)$username, $infoname);
    }

    /**
     * Retranslates to Auth::findUser()
     *
     * @access protected
     * @param string $name_part
     * @return bool|array|string
     */
    protected function findUsers($name_part) {
        return Auth::instance()->findUsers((string) $name_part);
    }



    /******************************/
    /*                            */
    /*         REDIRECTS          */
    /*                            */
    /******************************/

    /**
     * Redirects page back to referer
     *
     * @param string $ending adds string to the end of the url
     * @return void
     */
    protected function redirectback($ending='') {
        if (!array_value($_SERVER,'HTTP_REFERER')) {
            $this->redirecttobase();
        } else {
            if (!empty($ending)) {
                $url = preg_replace('/[^#](#.*)/', '', $_SERVER['HTTP_REFERER']).$ending;
            } else {
                $url = $_SERVER['HTTP_REFERER'];
            }
            $this->_redirect($url);
        }
    }

    /**
     * Redirects page to url
     *
     * @param string $url
     * @return void
     */
    protected function redirecttourl($url) {
        $this->_redirect($url);
    }

    /**
     * Redirects page to root
     *
     * @return void
     */
    protected function redirecttobase() {
        $lng = ($this->user('lang')) ? $this->user('lang') : $this->router->getLang();
        $this->_redirect($this->router->getBase().$lng.'/');
    }

    /**
     * Redirects page to url
     *
     * @param string $url
     * @return void
     */
    private function _redirect($url) {
        Responder::instance()->setRedirect($url);
    }



    /******************************/
    /*                            */
    /*         RESPONDERS         */
    /*                            */
    /******************************/

    /**
     * Return true if there is an ajax identifire
     *
     * @return bool
     */
    protected function isAjax() {
        return ($this->getHeader('X_REQUESTED_WITH') == 'XMLHttpRequest');
    }

    /**
     * Respond to the client browser plain text
     *
     * @param string $data
     * @return void
     */
    protected function PlainTextRespond($data) {
        $response = Responder::instance();
        $response->setHeader('Content-Type','text/plain; charset=utf-8', false);
        $response->replace(array_to_text($data));
        $response->respond(true);
    }

    /**
     * Respond to the client browser through the ajax
     *
     * @param string $data
     * @return void
     */
    protected function AjaxRespond($data) {
        Responder::instance()->replace($data);
        Responder::instance()->respond(true);
    }

    /**
     * Respond to the client browser through the ajax
     * data encoded to JSON
     *
     * @param mixed $data
     * @return bool
     */
    protected function JSONRespond($data) {
        Responder::instance()->replace(json_encode($data));
        Responder::instance()->respond(true);
    }


    /**
     * Respond to the client browser through the ajax
     * data encoded to XML
     *
     * @param mixed $data
     * @return bool
     */
    protected function XMLRespond($data) {
        $this->xml->clear();
        $this->xml->writeTree('document', $data);

        $response = Responder::instance();
        $response->setHeader('Content-Type','text/xml; charset=utf-8', false);
        $response->replace($this->xml->getDocument(true));
        $response->respond(true);
    }

    /**
     * Return the value of the given HTTP header. Pass the header name as the
     * plain, HTTP-specified header name. Ex.: Ask for 'Accept' to get the
     * Accept header, 'Accept-Encoding' to get the Accept-Encoding header.
     *
     * @param string $header HTTP header name
     * @return string|false HTTP header value, or false if not found
     */
    protected function getHeader($header) {
        if (empty($header)) {
            throw new CoreException('An HTTP header name is required');
        }

        // Try to get it from the $_SERVER array first
        $temp = 'HTTP_' . strtoupper(str_replace('-', '_', $header));
        if (!empty($_SERVER[$temp])) {
            return $_SERVER[$temp];
        }

        // This seems to be the only way to get the Authorization header on
        // Apache
        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            if (!empty($headers[$header])) {
                return $headers[$header];
            }
        }

        return false;
    }



    /******************************/
    /*                            */
    /*          STRINGS           */
    /*                            */
    /******************************/

    /**
     * Retranslates to Translater::translate()
     *
     * @access protected
     * @param string $keyword
     * @param string[optional] $lang
     * @return string
     */
    protected function translate($keyword, $lang=null) {
        return Translater::instance()->translate($keyword, $lang);
    }

    /**
     * Cleans title for adding to a database
     *
     * @param string $text
     * @return string
     * @access protected
     */
    protected function titlecleaner($text, $noTypoMode=false) {
        require_once('striped/app/lib/Jevix.class.php');
        $jevix = new Jevix();
        $jevix->cfgSetTagCutWithContent(array('script', 'object', 'iframe', 'style'));
        $jevix->cfgSetAutoReplace(array('+/-', '(c)', '(C)', '(с)', '(С)', '(r)'), array('±', '©', '©', '©', '©', '®'));
        $jevix->cfgSetXHTMLMode(true);
        $jevix->cfgSetAutoBrMode(false);
        $jevix->cfgSetAutoLinkMode(false);
        $errors = null;
        return $this->entities_html2unicode($jevix->parse($text, $errors, $noTypoMode));
    }

    /**
     * Cleans seotitle for adding to a database
     *
     * @param string $text
     * @access public
     * @return string
     */
    public function seotitle($text) {
        return $this->seotitlecleaner($text);
    }
    public function seotitlecleaner($text) {
        $lat = array("A","B","V","G","D","E","E","YO","ZH","Z","I","I","I","Y","K","L","M","N","O","P","R","S","T","U","F","H","C","CH","SH","SCH","","Y","","E","YU","YA",
                        "a","b","v","g","d","e","e","yo","zh","z","i","i","i","y","k","l","m","n","o","p","r","s","t","u","f","h","c","ch","sh","sch","","y","","e","yu","ya", '-', '-');
        $cyr = array("А","Б","В","Г","Д","Е","Є","Ё","Ж","З","І","Ї","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я",
                        "а","б","в","г","д","е","є","ё","ж","з","і","ї","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я", ' ', '_');
        $new_value = strtolower(preg_replace("/[^.a-zA-Z0-9\-]/im", '', str_replace($cyr, $lat, $text)));
        return (empty($new_value)) ? md5(uniqid(rand(), true)) : $new_value ;
    }

    /**
     * Transliterate for input
     *
     * @param string $text
     * @access public
     * @return string
     */
    public function transliterate($text, $cyr2lat=true) {
        $lat = array("A","B","V","G","D","E","E","YO","ZH","Z","I","I","I","Y","K","L","M","N","O","P","R","S","T","U","F","H","C","CH","SH","SCH","","Y","","E","YU","YA",
                        "a","b","v","g","d","e","e","yo","zh","z","i","i","i","y","k","l","m","n","o","p","r","s","t","u","f","h","c","ch","sh","sch","","y","","e","yu","ya");
        $cyr = array("А","Б","В","Г","Д","Е","Є","Ё","Ж","З","І","Ї","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ъ","Ы","Ь","Э","Ю","Я",
                        "а","б","в","г","д","е","є","ё","ж","з","і","ї","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ъ","ы","ь","э","ю","я");
        if ($cyr2lat) {
            return str_replace($cyr, $lat, $text);
        } else {
            return str_replace($lat, $cyr, $text);
        }
    }

    /**
     * Switches keybord layout for input
     *
     * @param string $text
     * @access public
     * @return string
     */
    public function switchKeyLayout($text, $cyr2lat=true) {
        $lat = array('Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '}', 'A', 'S', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '"', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>',
                     'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', ']', 'a', 's', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", "'", 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.');
        $cyr = array('Й', 'Ц', 'У', 'К', 'Е', 'Н', 'Г', 'Ш', 'Щ', 'З', 'Х', 'Ъ', 'Ї', 'Ф', 'Ы', 'І', 'В', 'А', 'П', 'Р', 'О', 'Л', 'Д', 'Ж', 'Э', 'Є', 'Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю',
                     'й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ', 'ї', 'ф', 'ы', 'і', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э', "є", 'я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю');
        if ($cyr2lat) {
            return str_replace($cyr, $lat, $text);
        } else {
            return str_replace($lat, $cyr, $text);
        }
    }


    /**
     * Cleans texts for adding to a database
     *
     * @param string $text
     * @param bool[optional] $br auto br mode
     * @return string
     */
    protected function textcleaner($text, $br=false, $noTypoMode=false) {
        require_once('striped/app/lib/Jevix.class.php');
        $jevix = new Jevix();
        $jevix->cfgAllowTags(array('a', 'small', 'img', 'i', 'b', 'u', 'em', 'del', 'strong', 'li', 'ol', 'ul', 'dl', 'dt', 'dd', 'sup', 'acronym', 'h3', 'h4', 'h5', 'h6', 'hr', 'br', 'code', 'p', 'div', 'blockquote', 'object', 'embed', 'param', 'iframe', 'table', 'tr', 'td', 'th', 'span','pre'));
        $jevix->cfgSetTagShort(array('br','img', 'hr', 'param', 'embed'));
        $jevix->cfgSetTagPreformatted(array('code','pre'));
        $jevix->cfgSetTagCutWithContent(array('script'));
        $jevix->cfgAllowTagParams('span', array('class', 'style'));
        $jevix->cfgAllowTagParams('table', array('class'));
        $jevix->cfgAllowTagParams('td', array('class', 'colspan', 'rowspan'));
        $jevix->cfgAllowTagParams('th', array('class', 'colspan', 'rowspan'));
        $jevix->cfgAllowTagParams('div', array('class'));
        $jevix->cfgAllowTagParams('a', array('title', 'href', 'name', 'target'));
        $jevix->cfgAllowTagParams('iframe', array('scrolling', 'src', 'width', 'height'));
        $jevix->cfgAllowTagParams('object', array('width', 'height'));
        $jevix->cfgAllowTagParams('param', array('name', 'value'));
        $jevix->cfgAllowTagParams('embed', array('src', 'type', 'allowfullscreen', 'allowScriptAccess', 'width', 'height'));
        $jevix->cfgAllowTagParams('img', array('src', 'class', 'alt'=>'#text', 'title'=>'#text', 'align' => array('right', 'left', 'center'), 'width' => '#int', 'height' => '#int', 'hspace' => '#int', 'vspace' => '#int'));
        $jevix->cfgSetTagParamsRequired('img', 'src');
        //$jevix->cfgSetTagParamsRequired('a', 'href');
        $jevix->cfgSetTagParamDefault('a', 'rel', 'nofollow');
        //$jevix->cfgSetTagParamsAutoAdd('img', array('width' => '300', 'height' => '300'));
        $jevix->cfgSetAutoReplace(array('+/-', '(c)', '(C)', '(с)', '(С)', '(r)'), array('±', '©', '©', '©', '©', '®'));

        $jevix->cfgSetTagChilds('table', 'tr', true, true);
        $jevix->cfgSetTagChilds('tr', array('th', 'td'), true, true);
        $jevix->cfgSetXHTMLMode(true);
        $jevix->cfgSetAutoBrMode($br);
        $jevix->cfgSetAutoLinkMode(true);
        $jevix->cfgSetTagNoTypography('code');

        $errors = null;

        return $this->entities_html2unicode($jevix->parse($text, $errors, $noTypoMode));
    }

    /**
     * Cleans texts for adding to a database
     *
     * @param string $text
     * @param bool[optional] $br auto br mode
     * @return string
     */
    protected function textcleaner_strong($text, $br=false, $noTypoMode=false) {
        require_once('striped/app/lib/Jevix.class.php');
        $jevix = new Jevix();
        $jevix->cfgAllowTags(array('a', 'small', 'img', 'i', 'b', 'u', 'em', 'del', 'strong', 'br', 'code', 'blockquote'));
        $jevix->cfgSetTagShort(array('br','img'));
        $jevix->cfgSetTagPreformatted(array('code'));
        $jevix->cfgSetTagCutWithContent(array('script', 'object', 'iframe', 'style'));
        $jevix->cfgAllowTagParams('a', array('title', 'href', 'name', 'target'));
        $jevix->cfgAllowTagParams('img', array('src', 'class', 'alt'=>'#text', 'title'=>'#text', 'align' => array('right', 'left', 'center'), 'width' => '#int', 'height' => '#int', 'hspace' => '#int', 'vspace' => '#int'));
        $jevix->cfgSetTagParamsRequired('img', 'src');
        $jevix->cfgSetTagParamsRequired('a', 'href');
        $jevix->cfgSetTagParamDefault('a', 'rel', 'nofollow');
        //$jevix->cfgSetTagParamsAutoAdd('img', array('width' => '20', 'height' => '20'));
        $jevix->cfgSetAutoReplace(array('+/-', '(c)', '(C)', '(с)', '(С)', '(r)'), array('±', '©', '©', '©', '©', '®'));
        $jevix->cfgSetXHTMLMode(true);
        $jevix->cfgSetAutoBrMode($br);
        $jevix->cfgSetAutoLinkMode(true);
        $jevix->cfgSetTagNoTypography('code');

        $errors = null;

        return $this->entities_html2unicode($jevix->parse($text, $errors, $noTypoMode));
    }

    /**
     * Changes html string entities to num entities
     *
     * @param string $input
     * @access protected
     * @return string
     */
    protected function entities_html2unicode($input) {
        $htmlEntities = array_values(get_html_translation_table(HTML_ENTITIES, ENT_QUOTES));
        $entitiesDecoded = array_keys(get_html_translation_table(HTML_ENTITIES, ENT_QUOTES));
        $num = count($entitiesDecoded);
        for ($u = 0; $u < $num; $u++) {
            $utf8Entities[$u] = '&#'.ord($entitiesDecoded[$u]).';';
        }
        return str_replace ($htmlEntities, $utf8Entities, $input);
    }

    /**
     * Replaces occurances in string
     *
     * @param string $subject
     * @param array $replace
     * @param string[optional] $pointer
     * @access protected
     * @return string
     */
    protected function sprintf_array($subject, $replace, $pointer='%') {
        foreach ($replace as $key => $value) {
            if (!is_array($value)) {
                $subject = str_replace($pointer.$key.$pointer, (string)$value, $subject);
            }
        }
        return $subject;
    }


    /******************************/
    /*                            */
    /*         DATA TREES         */
    /*                            */
    /******************************/


    /**
     * Rebuilds tree array from plain array to multilevel array
     *
     * @access protected
     * @param array $array with params
     * @param int[optional] $start element's key to start from
     * @param string $subname element's name
     * @return array
     */
    protected function rebuildArrayTree($array, $level=1, $subname) {
        $tree_index = array();
        $tree = array();

        do {
            foreach ($array as $key => $leaf) {
                if ($leaf['level'] == $level) {
                    unset($array[$key]);
                    if (!empty($leaf['parent']) && isset($tree_index[$leaf['parent']])) {
                        $tree_index[$leaf['parent']][$subname][$leaf['id']] = $leaf;
                        $tree_index[$leaf['id']] =& $tree_index[$leaf['parent']][$subname][$leaf['id']];
                    } else {
                        $tree[$leaf['id']] = $leaf;
                        $tree_index[$leaf['id']] =& $tree[$leaf['id']];
                    }
                }
            }
            $level++;
        } while (!empty($array));

        return $tree;
    }

    /******************************/
    /*                            */
    /*            LOGS            */
    /*                            */
    /******************************/

    /**
     * Logs everything
     *
     * @param mixed $data to log
     * @param string[optional] $file to log into
     * @param int $def_size
     * @access protected
     * @return void
     */
    protected function log($indata, $file=null, $def_size=1024) {
        $text2wrt = '-- '.date("Y-m-j G:i:s");
        $text2wrt .= "\n";
        if (!is_array($indata)) {
            $indata = array('string'=>$indata);
        }
        $text2wrt .= "\n--- <[CDATA[ ---\n";
        foreach ($indata as $k=>$d) {
            if (is_array($d)) {
                $text2wrt .= $k.": ".print_r($d, true)."\n";
            } else {
                $text2wrt .= $k.": ".$d."\n";
            }
        }
        $text2wrt .= "\n--- CDATA]]> ---\n";

        $data[$this->user('id')] = $this->user('customer_name').'-'.$this->user('username');
        $data['ip'] = get_ip();
        foreach ($data as $k=>$d) {
            if (is_array($d)) {
                $text2wrt .= $k.": ".print_r($d, true)."\n";
            } else {
                $text2wrt .= $k.": ".$d."\n";
            }
        }
        $text2wrt .= "\n-------\n";
        $filename = $this->etc->logs->dir->val().((!is_null($file)) ? $file : $this->etc->logs->debug->val());

        if (file_exists($filename) && filesize($filename) > $this->etc->logs->maxsize->val('float') * $def_size) {
            rename($filename, $filename.'_'.date("Y-m-j_G:i:s").'.log');
        }
        if ($db2wrt = fopen($filename, 'a')) {
            fwrite($db2wrt, $text2wrt);
            fclose($db2wrt);
        }
    }


    /**
     * Logs actions
     *
     * @param string $action to log
     * @param string[optional] $link describe
     * @access protected
     * @return void
     */
    protected function logAction($action, $action_id=NULL, $object_id=NULL, $link=NULL) {

        $params = array($this->user('id')?$this->user('id'):NULL, $action, $object_id, $link);
        $names = 'user_id, action, object_id, link';
        $placeholders = '$1, $2, $3, $4';

        if ($action_id) {
            $action_id = explode('.', $action_id);
            $names .= ', action_id';
            if (array_value($action_id, 1, false)) {
                $placeholders .= ', action_id($5,$6)';
                $params[] = $action_id[0];
                $params[] = $action_id[1];
            } else {
                $placeholders .= ', action_id($5)';
                $params[] = $action_id[0];
            }
        }

        $this->db->pinsert('INSERT INTO global_log_action ('.$names.') VALUES ('.$placeholders.')', $params);
        #$this->log(array('action'=>$action, 'link'=>$link), 'actions.log', 10240);
    }

    /******************************/
    /*                            */
    /*     CROSS SESSION DATA     */
    /*                            */
    /******************************/

    /**
     * save errors to session or cache
     *
     * @param array $data
     * @return array
     * @access protected
     */
    protected function errorsSave($data) {
        $this->cache->set('action-run-errors', $data);
    }


    /**
     * fetch errors to session or cache
     *
     * @return array
     * @access protected
     */
    protected function errorsFetch() {
        $r = $this->cache->get('action-run-errors');
        $this->cache->delete('action-run-errors');
        return $r;
    }


    /**
     * save confirms to session or cache
     *
     * @param array $data
     * @return array
     * @access protected
     */
    protected function confirmsSave($data) {
        $this->cache->set('action-run-confirms', $data);
    }


    /**
     * fetch confirms to session or cache
     *
     * @return array
     * @access protected
     */
    protected function confirmsFetch() {
        $r = $this->cache->get('action-run-confirms');
        $this->cache->delete('action-run-confirms');
        return $r;
    }

}
