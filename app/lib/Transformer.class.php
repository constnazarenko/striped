<?php
/**
 * Contains Transformer class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 */

require_once('striped/app/lib/Responder.class.php');
require_once('striped/app/core/MemcacheLayer.class.php');

################################################################################

/**
 * Transformer class - translate data to valid http-response
 *
 * @package Striped 3
 * @subpackage core
 */
class Transformer {
    /**
     * DOMDocument object
     *
     * @var DOMDocument
     * @access private
     */
    private $document;

    /**
     * Transformer
     *
     * @var string
     * @access private
     */
    private $transformer;

    /**
     * Render time
     *
     * @var string
     * @access private
     */
    private $rendertime;

    /**
     * Save to cache
     *
     * @var string
     * @access private
     */
    private $save;

    /**
     * Class constructor
     *
     * @access public
     * @return void
     */
    public function __construct() {
        $this->document = new DOMDocument('1.0', 'UTF-8');
    }

    /**
     * Sets transformer filename
     *
     * @access public
     * @param string $path
     * @return void
     */
    public function setTransformer($path,$save=false) {
        $this->transformer = $path;
        $this->save = $save;
    }

    /**
     * Sets DOMDocument
     *
     * @access public
     * @param DOMDocument $doc
     * @return void
     */
    public function loadDOMDocument(DOMDocument $doc) {
        $this->document = $doc;
    }

    /**
     * Loads DOMDocument from XML-string
     *
     * @access public
     * @param string $xml_sring
     * @return void
     */
    public function loadXML($xml_sring) {
        $this->document->loadXML(mb_convert_encoding($xml_sring, 'UTF-8', 'UTF-8'));
    }


    /**
     * Performs document transformation and echos the result
     *
     * @param bool[optional] $xml doesn't transform anything and just shows xml
     * @param bool[optional] $rss sets the xml headers for showing rss
     * @access public
     * @return void
     */
    public function transformAndRespond($xml=false, $rss=false, $cacheit=false) {
        $response = Responder::instance();

        if ($xml) {
            $response->setHeader('Content-Type','text/xml; charset=utf-8', false);
            $response->write($this->document->saveXML());
        } else {
            if ($rss) {
                $response->setHeader('Content-Type','text/xml; charset=utf-8', false);
            } else {
                $response->setHeader('Content-Type','text/html; charset=utf-8', false);
            }
            $page = $this->transform();
            if ($cacheit) {
                $mem = MemcacheLayer::instance();
                if (!$mem->get($cacheit)) {
                    $mem->set($cacheit, $page, MEMCACHE_COMPRESSED, 60);
                } else {
                    $mem->replace($cacheit, $page, MEMCACHE_COMPRESSED, 60);
                }
            }
            $response->addTime('xslt rendering', $this->rendertime);
            $response->write($page);
            //$router = Router::instance();
            //$mc = MemcacheLayer::instance();
            //$mc->set($router->getRequestedURI(), $page);
        }
    }

    /**
     * Performs document transformation
     *
     * @access public
     * @return string
     */
    public function transform() {
        $time = microtime(true);
        $xsltProcessor = new XSLTProcessor;

        $xsltProcessor->importStylesheet($this->getDocument());
        $result = $xsltProcessor->transformToXML($this->document);
        $this->rendertime = microtime(true) - $time;
        return $result;
    }

    /**
     * Performs document transformation
     *
     * @access public
     * @return string
     */
    public function getRendertime() {
        return $this->rendertime;
    }

    private function getDocument() {
        $xsltDocument = new DOMDocument('1.0', 'UTF-8');
        #TODO ioncubing
        if (!function_exists('ioncube_file_is_encoded') || !ioncube_file_is_encoded()) {
            if (!file_exists($this->transformer)) {
                throw new Exception('Transformer file not exists. ('.$this->transformer.')');
            }
            if (!@$xsltDocument->load($this->transformer)) {
                throw new Exception('Error while loading transformer file. ('.$this->transformer.')');
            }
        } else {
            $pi = pathinfo($this->transformer);
            $f = $pi['dirname'].'/'.$pi['filename'].'.ion.'.$pi['extension'];
            if (!file_exists($f)) {
                throw new Exception('Transformer file not exists. ('.$f.')');
            }
            if (!@$xsltDocument->loadXML(mb_convert_encoding(ioncube_read_file($f), 'UTF-8', 'UTF-8'))) {
                throw new Exception('Error while loading transformer file with IONCube. ('.$f.')');
            }
        }

        return $xsltDocument;
    }
}