<?php
/**
 * Contains Assembler class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2012
 */

require_once('striped/app/core/Auth.class.php');
require_once('striped/app/core/BlockException.class.php');
require_once('striped/app/core/CoreException.class.php');
require_once('striped/app/core/Modulator.class.php');
require_once('striped/app/core/PgSQLLayer.class.php');
require_once('striped/app/core/MySQLLayer.class.php');
require_once('striped/app/core/Translater.class.php');
require_once('striped/app/core/Router.class.php');
require_once('striped/app/core/SystemEtc.class.php');
require_once('striped/app/lib/common.functions.php');
require_once('striped/app/lib/Responder.class.php');
require_once('striped/app/lib/Rights.class.php');
require_once('striped/app/lib/Transformer.class.php');
require_once('striped/app/lib/XMLTreeWriter.class.php');

################################################################################

date_default_timezone_set('UTC');

/**
 * Assembler class
 *
 * @package Striped 3
 * @subpackage core
 */
class Assembler {
    /**
     * Run document assembling
     *
     * @access public
     * @return void
     */
    public function run() {
        try {
            $response = Responder::instance();
            try {
                $etc = SystemEtc::instance()->get();
                $auth = Auth::instance();
                $mem = MemcacheLayer::instance();

                if ($etc->site->db && $etc->site->db->val() == 'mysql') {
                    $db = MySQLLayer::instance();
                } else {
                    $db = PgSQLLayer::instance();
                }

                $xml = XMLTreeWriter::instance();
                $xml->startElement('document');

                    $router = Router::instance();
                    $router->whoAmI();
                    $ref_header = (isset($_SERVER['HTTP_REFERER'])) ? $_SERVER['HTTP_REFERER'] : '' ;
                    $c_url = addcslashes($etc->site->protocol, '/').addcslashes($etc->site->domain, '/').addcslashes($etc->site->root, '/');
                    preg_match('/'.$c_url.'([a-zA-Z]{2})\/(.*)/', $ref_header, $refs);
                    $req_uri = $router->getRequestedURI();
                    $req_get = $router->getRequestedGET();
                    $page_ident = $router->getIdent();
                    if ($router->isLanglessIndex()) {
                        Responder::instance()->setRedirect($router->getServer().$req_uri.($req_get ? '?'.$req_get : ''));
                    #} elseif (empty($req_uri) && isset($refs[1]) && $refs[1] != $router->getLang() && !empty($refs[2])) {
                    #    Responder::instance()->setRedirect($router->getServer().$refs[2]);
                    }

                    //log access
                    $auth->logAccess($router->getServer().$router->getRequestedURI(), $router->getParams(), $ref_header?$ref_header:'NULL');

                    $page_cache = $mem->get($page_ident);
                    if (!$etc->site->debug->val('bool') && !$auth->user('logged') && $page_cache) {
                        $response = Responder::instance();
                        $response->setHeader('Content-Type','text/html; charset=utf-8', false);
                        $response->addTime('from cache', microtime(true) - TIME);
                        $response->write($page_cache);
                        $response->respond();
                        die('<!-- cached page -->');
                    }

                    if ($router->getGet('switchlang')) {
                        $auth->setUserLang($router->getLang());
                    }


                    $translater = Translater::instance();
                    $translater->addTranslateFiles('global');

                    $xml->writeAttribute('base', $router->getBase());
                    $xml->writeAttribute('server', $router->getServer());
                    $xml->writeAttribute('protocol', $router->getProtocol());
                    $xml->writeAttribute('domain', $router->getDomain());
                    $xml->writeAttribute('lang', $router->getLang());
                    $xml->writeAttribute('requested_uri', $router->getRequestedURI());
                    $xml->writeAttribute('requested_get', $router->getRequestedGET());
                    $xml->writeAttribute('site_title', $translater->translate('glb_sitename'));
                    $xml->writeAttribute('page_title', $router->getPageTitle());
                    $xml->writeAttribute('page_keywords', $router->getPageKeywords());
                    $xml->writeAttribute('page_description', $router->getPageDescription());
                    $xml->writeAttribute('debug', $etc->site->debug);
                    $xml->writeAttribute('template', $router->getTemplate());
                    $xml->writeAttribute('subdomain', $router->getSubdomain());
                    $xml->writeAttribute('time', time());

                    $xml->writeAttribute('edit-mode-available', 1);

                    $xml->startElement('seo');
                        $xml->writeElement('page_title', $router->getPageTitle());
                        $xml->writeElement('page_keywords', $router->getPageKeywords());
                        $xml->writeElement('page_description', $router->getPageDescription());
                    $xml->endElement();

                    $xml->writeTree('userinfo', $auth->user());

                    /* searching for modules */
                    new Modulator($router->getModules(), $router->getRouteParams());
                    /* getting page info */
                    if ($etc->site->pageinfo->val('bool') or (isset($_GET['pageinfo']) and $etc->site->debug->val('bool'))) {
                        $xml->startElement('pageinfo');
                            $xml->writeTree('page_modules', $router->getModules(), 'module');
                            $xml->writeTree('page_params', $router->getParams(), 'param');
                        $xml->endElement();
                    }

                    /* getting sql log history */
                    if ($etc->site->sqldebug->val('bool') or (isset($_GET['sqldebug']) and $etc->site->debug->val('bool'))) {
                        $xml->writeTree('sqlinfo', $db->getQueryLog(), 'query');
                    }
                $xml->endElement();

                $rss = ($router->getType() == 'rss') ? true : false;

                /* transforming geathered xml */
                $transformer = new Transformer();
                $transformer->setTransformer($etc->document->path->val().($rss ? $etc->document->rss->val() : $etc->document->main->val()));
                if ($auth->user('logged')) {
                    $page_ident = false;
                }
                $transformer->loadXML($xml->getDocument(true));
                $transformer->transformAndRespond($etc->site->xml->val('bool') || (isset($_GET['xml']) && $etc->site->debug->val('bool')), $rss, $page_ident);

            } catch (CoreException $ce) {
                $ce->writeToLog();
                $ce->showErrorPage();
            }
            $response->addTime('sql total', $db->getTotalTime());
            $response->respond();
        } catch (Exception $e) {
            $error_string = 'Critical error: '.$e->getMessage().
                            '<br />Code: '.$e->getCode().
                            '<br />In file: '.$e->getFile().
                            '<br />On line: '.$e->getLine().
                            '<br />Trace: '.$e->getTraceAsString();
            header('HTTP/1.1 503 Internal script error');
            if (!$etc->site->debug->val('bool') && (!isset($auth) || !$auth || !$auth->user('superuser'))) {
                $error_string = 'Oops! Something went really wrong!';
            }
            echo $error_string;
        }
    }
}