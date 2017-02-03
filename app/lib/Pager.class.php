<?php
/**
 * Contains Pager class
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009
 * @version $Id: Pager.class.php 38 2011-01-22 02:52:16Z tigra $
 */

################################################################################

/**
 * Pager generator
 *
 * @package Striped 3
 * @subpackage lib
 * @final
 */
final class Pager {
    /**
     * Amount of shown pages after current
     */
    const prepage = 5;

    /**
     * Amount of shown pages before current
     */
    const postpage = 5;

    /**
     * Page
     *
     * @var int
     * @access private
     */
    private $page;

    /**
     * Page seo page
     *
     * @var int
     * @access private
     */
    private $page_seo;

    /**
     * Items per page
     *
     * @var int
     * @access private
     */
    private $perpage;

    /**
     * Last page
     *
     * @var int
     * @access private
     */
    private $last;

    /**
     * MySQL limit
     *
     * @var string
     * @access private
     */
    private $limit;

    /**
     * URL prefix
     *
     * @var string
     * @access private
     */
    private $prefix='';

    /**
     * URL postfix
     *
     * @var string
     * @access private
     */
    private $postfix='';

    /**
     * Constructor
     *
     * @access public
     * @param int[optional] $page
     * @param int $perpage
     * @param int $total
     * @param string[optional] $route (with :path param)
     * @return bool
     */
    public function __construct($page_seo, $perpage, $total, $route='') {
        $this->perpage = (int) $perpage;
        $this->last = ceil((int)$total/$this->perpage);

        if ((int) $page_seo === 0) {
            $this->page = 1;
            $this->page_seo = $this->last;
        } else {
            $this->page = (int) $this->last - $page_seo + 1;
            $this->page_seo = $page_seo;
        }

        if (!empty($route)) {
            $fixes = explode(':page', $route);
            if (isset($fixes[0])) {
                $this->prefix = rtrim($fixes[0], '/').'/';
            }
            if (isset($fixes[1])) {
                $this->postfix = ltrim($fixes[1], '/');
            }
        }

        $start = ($this->page*$this->perpage) - $this->perpage;
        if ($start < 0) {
            $this->limit = null;
            //throw new CoreException('Page not found', 404);
        } else {
            $this->limit = ' LIMIT '.$this->perpage.' OFFSET '.$start.' ';
        }
    }

    /**
     * Returns MySQL limit string
     *
     * @access public
     * @return string
     */
    public function getLimit() {
        return $this->limit;
    }

    /**
     * Generates pages XML
     *
     * @access public
     * @param XMLTreeWriter $xml
     * @return void
     */
    public function generate($xml) {
        if ($this->last > 1) {
            $xml->startElement('pager');
                $xml->writeElement('prefix', $this->prefix);
                $xml->writeElement('postfix', $this->postfix);
                if ($this->page - self::prepage > 1) {
                    $xml->startElement('first');
                        $xml->writeAttribute('seo', $this->last);
                        $xml->text(1);
                    $xml->endElement();
                }
                if ($this->page + self::postpage < $this->last) {
                    $xml->startElement('last');
                        $xml->writeAttribute('seo', 1);
                        $xml->text($this->last);
                    $xml->endElement();
                }
                if ($this->page_seo + 1 <= $this->last) {
                    $xml->startElement('prev');
                        $xml->writeAttribute('seo', $this->page_seo + 1);
                        $xml->text($this->page - 1);
                    $xml->endElement();
                }
                if ($this->page_seo - 1 > 0) {
                    $xml->startElement('next');
                        $xml->writeAttribute('seo', $this->page_seo - 1);
                        $xml->text($this->page + 1);
                    $xml->endElement();
                }

                $xml->startElement('pages');
                    $f = ($this->page - self::prepage > 0) ? $this->page - self::prepage : 1 ;
                    $l = ($this->page + self::postpage <= $this->last) ? $this->page + self::postpage : $this->last ;
                    $o = ($this->page_seo + self::postpage <= $this->last) ? $this->page_seo + self::postpage : $this->last ;
                    for ($i=$f; $i<=$l; $i++) {
                        $xml->startElement('page');
                            if ($i == $this->page) {
                                $xml->writeAttribute('current', 1);
                            }
                            $xml->writeAttribute('seo', $o--);
                            $xml->text($i);
                        $xml->endElement();
                    }
                $xml->endElement();
            $xml->endElement();
        }
    }

}