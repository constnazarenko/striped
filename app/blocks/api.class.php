<?php
/**
 * Contains API module class
 *
 * @package Striped 3
 * @subpackage blocks
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2012
 */

require_once('striped/app/core/BlockController.class.php');

################################################################################

/**
 * API
 *
 * @package Striped 3
 * @subpackage blocks
 */
class api extends BlockController {
    /**
    * Path to modules folder
    */
    const MODULES_PATH = 'striped/app/blocks/';

    /**
     * Path to custom modules folder
     */
    const MODULES_CUSTPATH = 'blocks/';

    /**
     * modules files extension
     */
    const EXT = '.class.php';

    /**
     * Shows content
     *
     * @access public
     * @return void
     */
    public function process() {
        #check if api disabled
        if ($this->etc->api->disabled->val('bool')) {
            Responder::instance()->setStatus(405);
            $this->respond(array('error'=>$this->translate('api_err_disabled')));
        }

        #authorize
        $this->authorize();

        #check cached blocking
        if ($this->cache->get('api-block-customer-'.$this->user('customer_name'))) {
            Responder::instance()->setStatus(405);
            $this->respond(array('error'=>$this->translate('api_err_limit_blocked')));
        }

        #check request limits
        foreach ($this->etc->api->limits->limit as $limit) {
            if ($this->etc->site->db && $this->etc->site->db->val() == 'mysql') {
                $limit_chk = $this->db->selectValue("SELECT count(*)
                    FROM global_log_action
                    JOIN auth_user as au ON (au.id = global_log_action.user_id)
                    WHERE action_id = action_id('api', 'request') AND time > DATE_SUB(CONCAT(CURDATE(),' ',CURTIME()),INTERVAL ".$limit->attr('time').") AND au.customer_id = $1",
                    array((int)$this->user('customer_id')));
            } else {
                $limit_chk = $this->db->selectValue("SELECT count(*)
                    FROM global_log_action
                    JOIN auth_user as au ON (au.id = global_log_action.user_id)
                    WHERE action_id = action_id('api', 'request') AND time > now() - $1::interval AND au.customer_id = $2",
                    array($limit->attr('time'), (int)$this->user('customer_id')));
            }



            if ($limit_chk > $limit->attr('count','int')) {
                $this->cache->set('api-block-customer-'.$this->user('customer_name'), true, MEMCACHE_COMPRESSED, $limit->attr('cache'));
                Responder::instance()->setStatus(405);
                $this->respond(array('error'=>$this->translate('api_err_limit_exceeded').' LIMIT: '.$limit->attr('count','int').' requests per '.$limit->attr('time','str')));
            }

            if ($limit_chk == $limit->attr('count','int') - $limit->attr('notify','int') && $this->user('email')) {

                $mp = array(
                        'customer' => $this->user('fullname'),
                        'time' => $limit->attr('time'),
                        'count' => $limit->attr('count','int'),
                        'current' => $limit_chk,
                        'sitename' => $this->translate('glb_sitename'),
                        'sitelink' => $this->router->getBase().$this->router->getLang().'/'
                        );
                $body = $this->sprintf_array($this->translate('api_mail_body'), $mp);

                require_once('striped/app/lib/Mailer64.class.php');
                //mail notification to site maintainer
                $mailer = new Mailer();
                $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                ->to($this->user('email'), $this->user('fullname'));
                if ($this->etc->api->notify && $this->etc->api->notify->val('boolean')) {
                    $mailer->bcc($this->etc->mail->to, $this->etc->mail->to_name);
                }
                $mailer->subject($this->translate('api_mail_subj'))
                ->text($body)
                ->send();
            }
        }

        #execute
        $module = $this->router->getParams('module');
        $action = 'api_'.$this->router->getParams('action');

        //log action
        $this->logAction("API request: ".$module."->".$action."()", 'api.request');

        if (file_exists(self::MODULES_CUSTPATH.$module.self::EXT)) {
            include_once(self::MODULES_CUSTPATH.$module.self::EXT);
            $class = 'custom_'.$module;
            $instance = new $class($action,'api');
        } elseif (file_exists(self::MODULES_PATH.$module.self::EXT)) {
            include_once(self::MODULES_PATH.$module.self::EXT);
            $instance = new $module($action,'api');
        } else {
            Responder::instance()->setStatus(404);
            $this->respond(array('error'=>'Module "'.$module.'" doesn\'t exist.'));
        }

        if (method_exists($instance, $action)) {
            try {
                $result = $instance->$action($this->router->getParams());
            } catch (BlockException $be) {
                Responder::instance()->setStatus($be->getCode());
                $be->writeToLog();
                $result['error'] = $be->getMessage();
            }
            $this->respond($result);
        } else {
            Responder::instance()->setStatus(404);
            $this->respond(array('error'=>'Action "'.$this->router->getParams('action').'" doesn\'t exist.'));
        }
    }

    /**
     * Responds in needed format
     *
     * @access public
     * @return void
     */
    public function authorize() {
        if (!$this->user('logged') && !isset($_SERVER['PHP_AUTH_USER'])) {
            $this->respond(array('error'=>'You have to be authorized to see this.'), true);
        } elseif (!$this->user('logged') && !Auth::instance()->authorize($_SERVER['PHP_AUTH_USER'], $_SERVER['PHP_AUTH_PW'])) {
            $this->respond(array('error'=>'Wrong username or password.'), true);
        }
    }

    /**
     * Responds in needed format
     *
     * @access public
     * @return void
     */
    public function respond($data, $auth=false) {
        if ($auth) {
            $response = Responder::instance();
            $response->setHeader('WWW-Authenticate','Basic realm="Striped API"', true);
            $response->setStatus('401');
        }
        if ($this->router->getParams('respond') === 'json') {
            $this->JSONRespond($data);
        } elseif ($this->router->getParams('respond') === 'plaintext') {
            $this->PlainTextRespond($data);
        /*} elseif ($this->router->getParams('respond') === 'text') {
            if (!is_array($data)) {
                $data = array($data);
            }
            $respond = '';
            $title = false;
            foreach ($data as $k=>$d) {
                if (!is_array($d)) {
                    $respond .= $k.": ".$d;
                } else {
                    if (!$title) {
                        $respond .= implode("\t", array_keys($d))."\n";
                        $title = true;
                    }
                    $respond .= implode("\t", $d);
                }
                $respond .= "\n";
            }
            $this->PlainTextRespond($respond);*/
        } else {
            $this->XMLRespond($data);
        }

        exit;
    }
}
