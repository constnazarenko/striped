<?php
/**
 * Contains referer module class
 *
 * @package Striped 3
 * @subpackage blocks
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2013
 */

require_once('striped/app/core/BlockController.class.php');

################################################################################

/**
 * Log referers for referral discounts
 *
 * @package Striped 3
 * @subpackage blocks
 */
class referer extends BlockController {
    /**
     * Logs referer through API
     *
     * @access public
     * @return void
     */
    public function api_log() {

        $result = array();
        $ip = $this->router->getParams('ip');
        $ref = $this->router->getParams('ref');
        $referer = $this->router->getParams('referer');
        $accesspoint = $this->router->getParams('accesspoint');

        if (!$ip || !$ref) {
            $result['error'] = 'Not enough params. ip:"'.$ip.'"; ref:"'.$ref.'"; referer: "'.$referer.'"; accesspoint:"'.$accesspoint.'"';
            return $result;
        }

        $decoded = (int) base64_decode($ref);
        $c_id = $this->db->selectValue('SELECT id FROM customer WHERE id = $1', array($decoded));
        if (!$c_id) {
            $result['error'] = 'There is no such customer.';
            return $result;
        }
        $this->db->insert('global_log_referer', array('accesspoint'=>$accesspoint, 'http_referer'=>$referer, 'referer_id'=>$c_id, 'ip'=>$ip));
        $result['confirm'] = 'Referer logged.';

        return $result;
    }


    /**
     * Log referer 
     *
     * @access public
     * @return void
     */
    public function logit() {
        $ip = get_ip();
        $ref = $this->router->getGet('ref');
        $referer = get_referer();
        $accesspoint = $this->router->getServer().$this->router->getRequestedURI();

        if (!$ip || !$ref) {
            return;
        }

        $decoded = (int) base64_decode($ref);
        $c_id = $this->db->selectValue('SELECT id FROM customer WHERE id = $1', array($decoded));
        if (!$c_id) {
            return;
        }
        $this->db->insert('global_log_referer', array('accesspoint'=>$accesspoint, 'http_referer'=>$referer, 'referer_id'=>$c_id, 'ip'=>$ip));

        $_SESSION['ref'] = $ref;
    }

    /**
     * Referers
     *
     * @access public
     * @return void
     */
    public function referers() {
        if (!$this->actionAllowed('pixcdn.stats')) {
            throw new BlockException($this->translate('glb_403'), 403);
        }
        $form = new FormWriter('pixcdn.tasks');
        $d = $form->get_valid_data_if_form_sent($this->router->getGet());

        if ($this->user("superuser")) {
            $form->add_field_data('customer', array(''=>$this->translate('glb_all')) + $this->db->selectHash("SELECT login, login FROM customer WHERE parent_id IS NULL AND type_id != type_id('customer', 'root') AND status_id = status_id('customer','active') ORDER BY login;"));
            $form->writeFormBlock();
        }
        
        if (!$this->user('superuser') || ($this->user('superuser') && array_value($d, 'customer'))) {
            $customer = $this->user('superuser') && array_value($d, 'customer') ? array_value($d, 'customer') : $this->user('customer_name') ;
            $customers = $this->db->select("SELECT *, to_char(auth_user.registered, 'DD Month YYYY HH24:MI:SS') as time, customer_name(referer_id) as referer FROM customer LEFT JOIN auth_user ON (auth_user.customer_id = customer.id)WHERE referer_id = customer_id($1)", array($customer));
        } elseif($this->user('superuser')) {
            $customers = $this->db->select("SELECT *, to_char(auth_user.registered, 'DD Month YYYY HH24:MI:SS') as time, customer_name(referer_id) as referer FROM customer LEFT JOIN auth_user ON (auth_user.customer_id = customer.id)WHERE referer_id IS NOT NULL");
        }
        $this->xml->writeTree('customers', $customers, 'customer');
        

        if (!$this->user('superuser') || ($this->user('superuser') && array_value($d, 'customer'))) {
            $customer = $this->user('superuser') && array_value($d, 'customer') ? array_value($d, 'customer') : $this->user('customer_name') ;
            /*init pager*/
            $total = $this->db->selectValue("SELECT COUNT(*) FROM global_log_referer WHERE referer_id = customer_id($1)", array($customer));
            $pager = new Pager(
                    (int) $this->router->getParams('page'),
                    20,
                    $total,
                    $this->router->getAlias());
            $st_where = $this->user('superuser') ? "" : " " ;
            $referers = $this->db->select("SELECT *, to_char(global_log_referer.time, 'DD Month YYYY HH24:MI:SS') as time, customer_name(referer_id) as customer FROM global_log_referer WHERE referer_id = customer_id($1) ".$st_where." ORDER BY global_log_referer.time DESC ".$pager->getLimit(), array($customer));
            
        } elseif($this->user('superuser')) {
            /*init pager*/
            $total = $this->db->selectValue("SELECT COUNT(*) FROM global_log_referer");
            $pager = new Pager(
                    (int) $this->router->getParams('page'),
                    20,
                    $total,
                    $this->router->getAlias());

            $referers = $this->db->select("SELECT *, to_char(global_log_referer.time, 'DD Month YYYY HH24:MI:SS') as time, customer_name(referer_id) as customer FROM global_log_referer ORDER BY global_log_referer.time DESC ".$pager->getLimit());
        }
        foreach ($referers as $k=>$r) {
            $r['http_referer'] = trim($r['http_referer']);
            $referers[$k] = $r;
        }

        if ($this->etc->referer && !$this->etc->referer->disabled->val('bool')) {
            $reflink = ($this->etc->referer->host->val('bool')?$this->etc->referer->host->val():$this->router->getServer()).'?ref='.rtrim(base64_encode($this->user('customer_id')), '=');
        } else {
            $reflink = '';
        }

        $this->xml->writeTree('refs', $referers, 'ref', array('reflink'=>$reflink));
        
        /*generate pager*/
        $pager->generate($this->xml);

        $this->xml->writeTree('errors', $this->errorsFetch(), 'error');
        $this->xml->writeTree('confirms', $this->confirmsFetch(), 'confirm');
    }

}
