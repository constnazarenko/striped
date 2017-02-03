<?php
/**
 * Contains staticblock module class
 *
 * @package Striped 3
 * @subpackage blocks
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2012
 */

require_once('striped/app/core/BlockController.class.php');
require_once('striped/app/core/FormWriter.class.php');

################################################################################

/**
 * Creates static text blocks
 *
 * @package Striped 3
 * @subpackage blocks
 */
class staticblock extends BlockController {
    /**
     * staticblock name
     * @var string
     * @access private
     */
    private $name;

    /**
     * Constructor
     *
     * @access public
     * @return void
     */
    public function __construct($name, $type) {
        parent::__construct();
        $this->name = $name;
    }

    /**
     * Shows plain text content
     *
     * @access public
     * @return void
     */
    public function text() {
        $this->show();
    }

    /**
     * Shows html content
     *
     * @access public
     * @return void
     */
    public function html() {
        $this->show(true);
    }

    /**
     * Shows content
     *
     * @param boolean $html
     * @access private
     * @return void
     */
    private function show($html=false) {
        if ($this->actionAllowed('root.edit')) {
            $attrs = array('canwrite'=>1);
        } else {
            $attrs = null;
        }

        $block = $this->db->select('SELECT * FROM static_block WHERE name = $1 AND lang_id = lang_id($2) LIMIT 1', array($this->name, $this->router->getLang()), false);
        if (!$html) {
            $block['text'] = $this->textcleaner($block['text']);
        }
        $this->xml->writeTree('content', $block, 'item', $attrs);
    }

    /**
     * Gets text content through ajax
     *
     * @access public
     * @return void
     */
    public function ajax() {
        $text = $this->db->selectValue('SELECT text FROM static_block WHERE name = $1 AND lang_id = lang_id($2) LIMIT 1', array($this->router->getParams('name'), $this->router->getLang()));
        $result = array('text'=>$text, 'status'=>'ok');
        $this->JSONRespond($result);
    }

    /**
     * Edits text data
     *
     * @access public
     * @return void
     */
    public function edit() {
        if (!$this->actionAllowed('root.edit')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        $form = new FormWriter('staticblock');

        $form->add_field_data('staticblockname', $this->router->getParams('name'));
        $form->add_field_data('content', $this->db->selectValue('SELECT text FROM static_block WHERE name = $1 AND lang_id = lang_id($2) LIMIT 1', array($this->router->getParams('name'), $this->router->getLang())));

        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
            if ($id = $this->db->selectValue('SELECT id FROM static_block WHERE name = $1 AND lang_id = lang_id($2)', array($this->router->getParams('name'), $this->router->getLang()), 'id')) {
                $this->db->pupdate('UPDATE static_block SET text = $1 WHERE name = $2 AND lang_id = lang_id($3)', array($data['content'], $this->router->getParams('name'), $this->router->getLang()));
                $form->add_confirm($this->translate('glb_scs_reload'), 'content');
            } else {
                $tblock = array(
                    $data['staticblockname'],
                    $data['content'],
                    $this->router->getLang()
                );
                $this->db->begin();
                $this->db->pinsert('INSERT INTO static_block (name, text, lang_id) VALUES ($1, $2, lang_id($3))', $tblock);
                $id = $this->db->last_id();
                $this->db->commit();
                $form->add_confirm($this->translate('glb_scs_reload'), 'content');
            }
            //log action
            $this->logAction('Static block was edited: '.$data['staticblockname'], 'root.edit', $id);
        }
        $form->writeFormBlock();
    }

}
