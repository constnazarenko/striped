<?php
/**
 * Contains the Responder class (singleton).
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 * @version $Id: Responder.class.php 4 2011-01-20 10:45:27Z tigra $
 */

/**
 * HTTP-responce.
 *
 * @package Striped 3
 * @subpackage lib
 * @final
 */
final class Responder {
    /**
     * Responder instance
     *
     * @var Responder
     * @static
     * @access private
     */
    private static $instance;

    /**
     * @access private
     * @var string response status string
     */
    private $statusLine;

    /**
     * @access private
     * @var array headers
     */
    private $headers;

    /**
     * @access private
     * @var array cookies
     */
    private $cookies;

    /**
     * @access private
     * @var string response body
     */
    private $body;

    /**
     * Time for statistics
     *
     * @access private
     * @var string response body
     */
    private $time = array();

    /**
     * @access private
     * @var array response codes list
     */
    private $reasonPhrases = array(
        //1xx: Informational
        100 => 'Continue',
        101 => 'Switching Protocols',
        102 => 'Processing',
        //2xx: Success
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        203 => 'Non-Authoritative Information',
        204 => 'No Content',
        205 => 'Reset Content',
        206 => 'Partial Content',
        207 => 'Multi-Status',
        226 => 'IM Used',
        //3xx: Redirection
        300 => 'Multiple Choices',
        301 => 'Moved Permanently',
        302 => 'Found',
        303 => 'See Other',
        304 => 'Not Modified',
        305 => 'Use Proxy',
        307 => 'Temporary Redirect',
        //4xx: Client Error
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Time-out',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Request Entity Too Large',
        414 => 'Request-URI Too Large',
        415 => 'Unsupported Media Type',
        416 => 'Requested range not satisfiable',
        417 => 'Expectation Failed',
        422 => 'Unprocessable Entity',
        423 => 'Locked',
        424 => 'Failed Dependency',
        425 => 'Unordered Collection',
        426 => 'Upgrade Required',
        449 => 'Retry With',
        456 => 'Unrecoverable Error',
        //5xx: Server Error
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Time-out',
        505 => 'HTTP Version not supported',
        506 => 'Variant Also Negotiates',
        507 => 'Insufficient Storage',
        508 => 'Loop Detected',
        509 => 'Bandwidth Limit Exceeded',
        510 => 'Not Extended'
    );

    /**
     * Constructor
     *
     * @access private
     * @return void
     */
    private function __construct() {
        $this->clear();
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
     * Gets Responder instance
     *
     * @access public
     * @return Responder
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    /**
     * Sets response status
     *
     * @access public
     * @param int $statusCode
     * @param string $reasonPhrase
     * @return void
     */
    public function setStatus($statusCode, $reasonPhrase=null) {
        if (!isset($reasonPhrase)) {
            $reasonPhrase = (isset($this->reasonPhrases[$statusCode]) ? $this->reasonPhrases[$statusCode] : '');
        }
        $this->statusLine = 'HTTP/1.1 '.$statusCode.' '.$reasonPhrase;
    }

    /**
     * Sets response header
     *
     * @access public
     * @param string $name
     * @param string $value
     * @param boolean $replace
     * @return void
     */
    public function setHeader($name, $value, $replace = true) {
        if ((!$replace) && isset($this->headers[$name])) {
            return;
        }
        $this->headers[$name] = $value;
    }

    /**
     * Sets cookie
     *
     * @access public
     * @param string $name
     * @param string $value
     * @param int $expire
     * @param string $path
     * @param string $domain
     * @param bool $secure
     * @return void
     */
    public function setCookie($name, $value='', $expire='', $path='', $domain='', $secure=false) {
        $this->cookies[$name] = compact('value', 'expire', 'path', 'domain', 'secure');
    }

    /**
     * Deletes cookie
     *
     * @access public
     * @param string $name
     * @param string $path
     * @param string $domain
     * @param bool $secure
     * @return void
     */
    public function deleteCookie($name, $path = '', $domain = '', $secure = false) {
        $this->setCookie($name, '', (time() - 1), $path, $domain, $secure);
    }

    /**
     * Sets redirection url
     *
     * @param string $location
     * @return void
     * @access public
     */
    public function setRedirect($location) {
        $this->setHeader('Location', $location);
        $this->respond(true);
    }

    /**
     * Adds data to the response body
     *
     * @access public
     * @param string $data
     * @return void
     */
    public function write($data) {
        $this->body .= $data;
    }

    /**
     * Replace data in the response body
     *
     * @access public
     * @param string $data
     * @return void
     */
    public function replace($data) {
        $this->body = $data;
    }

    /**
     * Clears all response data to default
     *
     * @access public
     * @param string $data
     * @return void
     */
    public function clear() {
        $this->setStatus(200);
        $this->headers = array();
        $this->cookies = array();
        $this->body = '';
    }

    /**
     * Add stats time
     *
     * @access public
     * @param string $data
     * @return void
     */
    public function addTime($reason, $time) {
        $this->time[$reason] = $time;
    }

    /**
     * Sends the response
     *
     * @access public
     * @param [optional]bool $exit after respond
     * @return void
     */
    public function respond($exit=false) {
        $stats = "<!--\n";
        $stats .= "mem(MB): ".(memory_get_usage() / 1024 / 1024)."\n";
        $stats .= "peak mem(MB): ".(memory_get_peak_usage() / 1024 / 1024)."\n";
        $stats .= "exec time(s): ".(microtime(true) - TIME)."\n";

        foreach ($this->time as $r=>$t) {
            $stats .= $r.": ".$t."\n";
        }

        $stats .= "-->";
        $this->body = str_replace('<!-- stats placeholder -->', $stats, $this->body);
        if (!headers_sent($filename, $linenum)) {
            header($this->statusLine);
            $this->setHeader("Content-Length", mb_strlen($this->body));
            foreach ($this->headers as $name => $value) {
                header($name.': '.$value);
            }
            foreach ($this->cookies as $name => $params) {
                setcookie($name, $params['value'], $params['expire'], $params['path'], $params['domain'], $params['secure']);
            }
        } else {
            trigger_error('Headers was already sent in file: '.$filename.', on line: '.$linenum);
        }
        echo $this->body;

        if ($exit) {
            exit();
        }
    }
}
