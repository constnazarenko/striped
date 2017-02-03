<?php
/**
 * Contains CoreException class and error handler
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009-11
 */

require_once('striped/app/core/Router.class.php');
require_once('striped/app/core/SystemEtc.class.php');
require_once('striped/app/lib/Responder.class.php');
require_once('striped/app/lib/Transformer.class.php');
require_once('striped/app/lib/XMLTreeWriter.class.php');

################################################################################

/**
 * CoreException - creates error documents
 *
 * @package Striped 3
 * @subpackage core
 */
class CoreException extends Exception {
    /**
     * Error code 404 - page not found
     */
    const ERR_404 = 404;

    /**
     * Error code 403 - forbidden
     */
    const ERR_403 = 403;

    /**
     * Kernel panic
     */
    const ERR_KERNEL_PANIC = 0;

    /**
     * DataBase Management System error
     */
    const ERR_DBMS = 3;

    /**
     * Additional error data
     *
     * @var mixed
     * @access private
     */
    private $additional_data;

    /**
     * Responder instance
     *
     * @var Responder
     * @access private
     */
    private $response;

    /**
     * Log file name
     *
     * @var string
     * @access private
     */
    private $log_file;

    /**
     * Log file name
     *
     * @var string
     * @access private
     */
    private $max_log_size;

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
        parent::__construct($message, $code);
        $this->additional_data = $additional_data;
    }

    /**
     * Creates error page xml
     *
     * @access private
     * @return string
     */
    private function createErrorPage($log=false) {
        switch ($this->getCode()) {
            case E_ERROR: $errtype = 'Error'; break;
            case E_WARNING: $errtype = 'Warning'; break;
            case E_NOTICE: $errtype = 'Notice'; break;
            case E_STRICT: $errtype = 'Strict'; break;
            case self::ERR_403: $errtype = 'Forbidden'; break;
            case self::ERR_404: $errtype = 'Page not found'; break;
            case self::ERR_DBMS: $errtype = 'Database error'; break;
            default: $errtype = 'Unknown error type'; break;
        }
        $etc = SystemEtc::instance()->get();
        $transformer = new Transformer();
        $xmltree = XMLTreeWriter::instance();
        $xmltree->clear();
        if (!$log) {
            $transformer->setTransformer($etc->document->path->val().$etc->document->error->val());
        } else {
            $this->max_log_size = ($etc->logs->maxsize->val('float') * 1024);
            $this->log_file = ($this->getCode() != self::ERR_404 && $this->getCode() != self::ERR_403) ? $etc->logs->error->val() : ($this->getCode() != self::ERR_403 ? $etc->logs->error404->val() : $etc->logs->error403->val());
            $transformer->setTransformer($etc->document->path->val().$etc->document->errorlog->val());
        }

        $xmltree->startElement('document');
            if ($etc->site->debug->val('bool') || $log) {
                $xmltree->writeAttribute('debug', 1);
            }
            $router = Router::instance();
            $xmltree->writeAttribute('code', $this->getCode());
            $xmltree->writeAttribute('base', $etc->site->protocol.$etc->site->domain->val().$etc->site->root->val());
            $xmltree->writeAttribute('title', 'glb_sitename');
            $xmltree->writeAttribute('server', $router->getServer());
            $xmltree->writeAttribute('protocol', $router->getProtocol());
            $xmltree->writeAttribute('domain', $router->getDomain());
            $xmltree->writeAttribute('lang', $router->getLang());
            $xmltree->writeAttribute('requested_uri', $router->getRequestedURI());
            $xmltree->writeAttribute('requested_get', $router->getRequestedGET());
            $xmltree->writeAttribute('page_title', $router->getPageTitle());
            $xmltree->writeAttribute('page_keywords', $router->getPageKeywords());
            $xmltree->writeAttribute('page_description', $router->getPageDescription());
            $xmltree->writeAttribute('template', $router->getTemplate());
            $xmltree->writeAttribute('subdomain', $router->getSubdomain());
            $xmltree->writeAttribute('time', time());

            $xmltree->startElement('error');
                $xmltree->writeElement('type', $errtype);
                $xmltree->writeElement('message', $this->getMessage());
                $xmltree->writeElement('code', $this->getCode());

                if ($this->getCode() == self::ERR_404 || $this->getCode() == self::ERR_403) {
                    $xmltree->writeElement('ip', $_SERVER['REMOTE_ADDR']);
                    $xmltree->writeElement('request_uri', $_SERVER['REQUEST_URI']);
                    if (isset($_SERVER['HTTP_REFERER'])) {
                        $xmltree->writeElement('referer', $_SERVER['HTTP_REFERER']);
                    }
                }

                if ($etc->site->debug->val('bool') || $log) {
                    if (!empty($this->additional_data)) {
                        if (is_array($this->additional_data)) {
                            $xmltree->startElement('additionalData');
                                foreach ($this->additional_data as $key => $value) {
                                    $xmltree->startElement('item');
                                        if (is_string($key)) {
                                           $xmltree->writeAttribute('name', $key);
                                        }
                                        if (!is_array($value)) {
                                            $xmltree->text($value);
                                        } else {
                                            $xmltree->writeTree('items', $value);
                                        }
                                    $xmltree->endElement();
                                }
                            $xmltree->endElement();
                        } else {
                            $xmltree->writeElement('additionalData', $this->additional_data);
                        }
                    }

                    $xmltree->writeElement('file', $this->getFile());
                    $xmltree->writeElement('line', $this->getLine());
                    $xmltree->writeElement('trace', $this->getTraceAsString());
                }
            $xmltree->endElement();

            if ($this->getCode() == self::ERR_404 || $this->getCode() == self::ERR_403) {
                $router = Router::instance();
                $router->getErrorPageModules($this->getCode());
                new Modulator($router->getModules());
            }

        $xmltree->endElement();

        if ($etc->site->xml->val('bool') || (isset($_GET['xml']) && $etc->site->debug->val('bool'))) {
            header('Content-Type: text/xml; charset=utf-8');
            echo $xmltree->getDocument();
            exit();
        }
        $transformer->loadXML($xmltree->getDocument());
        return $transformer->transform();
    }

    /**
     * Gets an additional data
     *
     * @access public
     * @return mixed
     */
    public function getAdditionalData() {
        return $this->additional_data;
    }

    /**
     * Shows error page
     *
     * @access public
     * @return string
     */
    public function showErrorPage() {
        $response = Responder::instance();
        $response->clear();
        if ($this->getCode() == self::ERR_403 || $this->getCode() == self::ERR_404) {
           $response->setStatus($this->getCode());
        } else {
            $response->setStatus(500);
        }
        $response->write($this->createErrorPage());
        $response->respond(true);
    }

    /**
     * Write to log
     *
     * @access public
     * @return void
     */
    public function writeToLog() {
        $etc = SystemEtc::instance()->get();
        if (!$etc->logs->disabled || !$etc->logs->disabled->val('bool')) {
            $text2wrt = date("Y-m-j G:i:s");
            $text2wrt .= "\n";
            $text2wrt .= $this->createErrorPage(true);
            $text2wrt .= "-------\n";
            $filename = $etc->logs->dir.$this->log_file;

            if (file_exists($filename)) {
                $write_mode = (filesize($filename) > $this->max_log_size) ? 'w' : 'a' ;
            } else {
                $write_mode = 'a';
            }

            if ($db2wrt = fopen($filename, $write_mode)) {
                fwrite($db2wrt, $text2wrt);
                fclose($db2wrt);
            }
        }
    }

    /**
     * PHP errors handler
     *
     * @access public
     * @return void
     */
    public static function errorHandler($errno, $errstr, $errfile, $errline) {
        $me = new self($errstr, $errno, array('in file'=>$errfile, 'on line'=>$errline));
        $me->writeToLog();
        $etc = SystemEtc::instance()->get();
        if (!$etc->site->debug->val('bool')) {
            echo $me->getCode().' Oops! Something went wrong!';
            if (!($me->getCode() == E_WARNING || $me->getCode() == E_NOTICE || $me->getCode() == E_STRICT)) {
                exit();
            }
        } else {
            $me->showErrorPage();
        }
    }
}

/**
 * Error handling through the CoreException class
 *
 * @package Striped 3
 * @subpackage core
 */
set_error_handler(array('CoreException','errorHandler'));
