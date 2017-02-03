<?php
/**
 * Contains Translater class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 */

require_once('striped/app/core/Router.class.php');
require_once('striped/app/core/SystemEtc.class.php');
require_once('striped/app/lib/ClearedXMLElement.class.php');
require_once('striped/app/lib/XMLTreeWriter.class.php');

################################################################################

/**
 * Works with translates
 *
 * @package Striped 3
 * @subpackage core
 */
final class Translater {
    /**
     * Files extension
     */
    const EXT = '.xml';

   /**
     * Path to translates directory
     */
    const TRANSLATES_PATH = 'striped/translates/';

    /**
     * Path to custom translates directory
     */
    const TRANSLATES_CUSTPATH = 'translates/';

    /**
     * Translater instance
     *
     * @var Translater
     * @static
     * @access private
     */
    private static $instance;

    /**
     * Translates xml
     *
     * @var XMLTreeWriter
     * @access private
     */
    private $translates_xml = array();

    /**
     * Log of already loaded files
     *
     * @var array
     * @access private
     */
    private $cache_log = array();

    /**
     * Translates array
     *
     * @var array
     * @access private
     */
    private $translates = array();

    /**
     * Gets Translater instance
     *
     * @access public
     * @return Translater
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }

    /**
     * Adds translate files
     *
     * @access public
     * @param array|string $files
     * @return Translater
     */
    public function addTranslateFiles($files) {
        if (!is_array($files)) {
            $files = array($files);
        }
        $files = array_unique($files);

        foreach ($files as $file) {
            $translates = array();
            $custtranslates = array();

            $path = $file.'.'.Router::instance()->getLang().self::EXT;

            if (!in_array($file, $this->cache_log)) {
                //get normal back-end translates
                if (file_exists(self::TRANSLATES_PATH.$path) && is_readable(self::TRANSLATES_PATH.$path)) {
                    $this->translates_xml[$file]['normal'] = simplexml_load_string(file_get_contents(self::TRANSLATES_PATH.$path), 'ClearedXMLElement');
                    foreach ($this->translates_xml[$file]['normal']->children() as $new_child) {
                        $this->translates[Router::instance()->getLang()][$new_child->attr('keyword')] = $new_child->val();
                    }
                }
                //get custom back-end translates
                if (file_exists(self::TRANSLATES_CUSTPATH.$path) && is_readable(self::TRANSLATES_CUSTPATH.$path)) {
                    $this->translates_xml[$file]['custom'] = simplexml_load_string(file_get_contents(self::TRANSLATES_CUSTPATH.$path), 'ClearedXMLElement');
                    foreach ($this->translates_xml[$file]['custom']->children() as $new_child) {
                        $this->translates[Router::instance()->getLang()][$new_child->attr('keyword')] = $new_child->val();
                    }
                }
                $this->cache_log[] = $file;
            }

        }
        return $this;
    }

    /**
     * Adds translate files for all languages
     *
     * @access public
     * @param array|string $files
     * @return Translater
     */
    public function addTranslateFilesAllLangs($files) {
        if (!is_array($files)) {
            $files = array($files);
        }
        $files = array_unique($files);
        $etc = SystemEtc::instance()->get();
        $languages = $etc->languages->val('array');
        $languages = $languages['language'];
        if (!is_array($languages)) {
        	$languages = array($languages);
        }

        foreach ($files as $file) {
            foreach ($languages as $lng) {
                $path = $file.'.'.$lng.self::EXT;
                if (file_exists(self::TRANSLATES_PATH.$path) && is_readable(self::TRANSLATES_PATH.$path)) {
                    $new_xml = simplexml_load_string(file_get_contents(self::TRANSLATES_PATH.$path), 'ClearedXMLElement');
                    foreach ($new_xml->children() as $new_child) {
                        $this->translates[$lng][$new_child->attr('keyword')] = $new_child->val();
                    }
                }
                if (file_exists(self::TRANSLATES_CUSTPATH.$path) && is_readable(self::TRANSLATES_CUSTPATH.$path)) {
                    $new_xml = simplexml_load_string(file_get_contents(self::TRANSLATES_CUSTPATH.$path), 'ClearedXMLElement');
                    foreach ($new_xml->children() as $new_child) {
                        $this->translates[$lng][$new_child->attr('keyword')] = $new_child->val();
                    }
                }
            }

        }
        return $this;
    }

    /**
     * Writes translates to output xml
     *
     * @return void
     */
    public function writeTranslates() {
        $xml = XMLTreeWriter::instance();
        $xml->startElement('translates');
            foreach($this->translates_xml as $t_xml) {
                if (isset($t_xml['custom'])) {
                    $xml->writeRaw(str_replace('</translates>', '', str_replace('<translates>', '', preg_replace('/<\?xml.*\?>/', '', $t_xml['custom']->asXML()))));
                }
                if (isset($t_xml['normal'])) {
                    $xml->writeRaw(str_replace('</translates>', '', str_replace('<translates>', '', preg_replace('/<\?xml.*\?>/', '', $t_xml['normal']->asXML()))));
                }
            }
        $xml->endElement();
    }

    /**
     * Clear translates
     *
     * @param string $keyword
     * @return string
     */
    public function clear() {
        $this->cache_log = array();
        $this->translates = array();
        $this->translates_xml = array();
    }

    /**
     * Translates strings by keywords to needed language
     *
     * @param string $keyword
     * @param string $lang
     * @return string
     */
    public function translate($keyword, $lang=null) {
        if (!$lang) {
            $lang = Router::instance()->getLang();
        }
        if (isset($this->translates[$lang][(string) $keyword])) {
            return $this->translates[$lang][(string) $keyword];
        }
        return (string) $keyword;
    }
}