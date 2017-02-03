<?php
/**
 * Contains Modulator class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009-11
 * @version $Id: Modulator.class.php 4 2011-01-20 10:45:27Z tigra $
 */

require_once('striped/app/core/SystemEtc.class.php');
require_once('striped/app/core/Translater.class.php');

################################################################################

/**
 * Executes modules
 *
 * @package Striped 3
 * @subpackage core
 */
class Modulator {

    /**
     * Path to modules folder
     */
    const MODULES_PATH = 'striped/app/blocks/';

    /**
     * Path to custom modules folder
     */
    const MODULES_CUSTPATH = 'blocks/';

    /**
     * Path to modules folder
     */
    const EXT = '.class.php';

    /**
     * Constructor
     *
     * @access public
     * @param array $modules
     * @return void
     */
    public function __construct($modules, $params=array()) {

        $xml = XMLTreeWriter::instance();
        $translater = Translater::instance();

        $xml->startElement('blocks');
        foreach ($params as $name=>$param) {
            $xml->writeAttribute($name, $param);
        }
        foreach ($modules as $module) {
            $xml->startElement('block');
                $xml->writeAttribute('controller', $module['controller']);
                $xml->writeAttribute('action', $module['action']);
                $xml->writeAttribute('name', $module['name']);
                $xml->writeAttribute('type', $module['type']);
                if (isset($module['logged'])) {
                    $xml->writeAttribute('logged', $module['logged']);
                }

                $translater->addTranslateFiles($module['controller']);
                if (file_exists(self::MODULES_CUSTPATH.$module['controller'].self::EXT)) {
                    try {
                        include_once(self::MODULES_CUSTPATH.$module['controller'].self::EXT);
                        $class = 'custom_'.$module['controller'];
                        $instance = new $class($module['name'], $module['type']);
                    } catch (BlockException $be) {
                        throw new CoreException($be->getMessage(), $be->getCode(), $be->getAdditionalData());
                    }
                } elseif (file_exists(self::MODULES_PATH.$module['controller'].self::EXT)) {
                    try {
                        include_once(self::MODULES_PATH.$module['controller'].self::EXT);
                        $instance = new $module['controller']($module['name'], $module['type'], $module['params']);
                    } catch (BlockException $be) {
                        throw new CoreException($be->getMessage(), $be->getCode(), $be->getAdditionalData());
                    }
                } else {
                    throw new CoreException('Module doesn\'t exist.', 500, $module);
                }

                if (method_exists($instance, $module['action'])) {
                    $instance->$module['action']();
                } else {
                    throw new CoreException('Action doesn\'t exists.', 500, $module);
                }

                if ($module['params']) {
                    $xml->writeTree('params', $module['params']);
                }

            $xml->endElement();
        }
        $xml->endElement();

        $translater->writeTranslates();
    }

}