<?php
/**
 * Contains authorization module class
 *
 * @package Striped 3
 * @subpackage blocks
 * @author K.Nazarenko     http://nazarenko.me/
 * @copyright Kostiantyn Nazarenko 2012
 */

require_once('striped/app/core/Auth.class.php');
require_once('striped/app/core/BlockController.class.php');
require_once('striped/app/core/FormWriter.class.php');
require_once('striped/app/lib/Mailer64.class.php');
require_once('striped/app/lib/Pager.class.php');

################################################################################

/**
 * Authorizes users
 *
 * @package Striped 3
 * @subpackage blocks
 */
class authorization extends BlockController {

    /**
     * Constructor
     *
     * @access public
     */
    public function __construct() {
        parent::__construct();

        $actions = array('auth.delete', 'auth.edit', 'auth.register', 'auth.userlist', 'root.customerlist', 'root.customermanage', 'root.customerdelete');
        foreach ($actions as $a) {
            $this->xml->writeAttribute($a, (int) $this->actionAllowed($a));
        }
    }

    /**
     * Generates login area block
     *
     * @access public
     * @return void
     */
    public function loginLink() {
        if ($this->user('logged')) {
            $this->xml->writeTree('userinfo', $this->user());
        }
    }

    /**
     * Generates login area block
     *
     * @access public
     * @return void
     */
    public function loginArea() {
        if ($this->user('logged')) {
            $this->xml->writeTree('userinfo', $this->user());
        } else {
            $form = new FormWriter('auth.loginblock');

            $form->add_field_data('remember', 1);

            if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {

                if (!$form->has_error()) {

                    $username_parts = explode('-', $data['username']);

                    $cid = $this->db->selectValue('SELECT id FROM customer WHERE login = $1', array($username_parts[0]));
                    if (!$cid) {
                        $form->add_error($this->translate('Unkown customer'));
                    } elseif (!Auth::instance()->authorize($data['username'], $data['password'], (bool) $data['remember'])) {
                        $form->add_error($this->translate('au_err_g_wrong_up'));
                    } else {
                        $form->add_confirm($this->translate('au_lb_success'));
                    }
                }

                if ($form->has_error() && $this->isAjax()) {
                    $result = array(
                        'status' => 'error',
                        'messages' => $form->get_errors()
                    );
                    $this->JSONRespond($result);
                } elseif (!$form->has_error() && $this->isAjax()) {
                    $result = array(
                        'status' => 'confirm',
                        'messages' => $form->get_confirms()
                    );
                    $this->JSONRespond($result);
                } elseif (!$form->has_error() && array_value_not_empty($data, 'gohome')) {
                    $this->redirecttobase();
                } elseif (!$form->has_error()) {
                    $this->redirectback();
                }
            }

            $form->writeFormBlock();
        }
    }

    /**
     * Generates login page
     *
     * @access public
     * @return void
     */
    public function loginPage() {
        if ($this->user('logged')) {
            $this->redirecttobase();
        } else {
            $form = new FormWriter('auth.loginblock');

            $form->add_field_data('remember', 1);

            if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {

                if (!$form->has_error()) {

                    $username_parts = explode('-', $data['username']);

                    $cid = $this->db->selectValue('SELECT id FROM customer WHERE login = $1', array($username_parts[0]));
                    if (!$cid) {
                        $form->add_error($this->translate('Unkown customer'));
                    } elseif (!Auth::instance()->authorize($data['username'], $data['password'], (bool) $data['remember'])) {
                        $form->add_error($this->translate('au_err_g_wrong_up'));
                    } else {
                        $form->add_confirm($this->translate('au_lb_success'));
                    }
                }

                if ($form->has_error() && $this->isAjax()) {
                    $result = array(
                            'status' => 'error',
                            'messages' => $form->get_errors()
                    );
                    $this->JSONRespond($result);
                } elseif (!$form->has_error() && $this->isAjax()) {
                    $result = array(
                            'status' => 'confirm',
                            'messages' => $form->get_confirms()
                    );
                    $this->JSONRespond($result);
                } elseif (!$form->has_error() && array_value_not_empty($data, 'gohome')) {
                    $this->redirecttobase();
                } elseif (!$form->has_error()) {
                    $this->redirectback();
                }
            }

            $form->writeFormBlock();
        }
    }



    /**
     * Switch user
     *
     * @access public
     * @return void
     */
    public function sudo() {
        $form = new FormWriter('auth.sudo');

        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
            if (!$this->actionAllowed('root.sudo')) {
                throw new CoreException($this->translate('glb_403'), 403);
            }

            $username_parts = explode('-', $data['username']);
            if (!$this->db->selectValue('SELECT id FROM auth_user WHERE customer_id = customer_id($1) AND username = $2', array($username_parts[0], array_value($username_parts, 1, '')), 'id')) {
                $form->add_error($this->translate('au_err_g_wrong_up'));
            } else {
                Auth::instance()->sudo($data['username']);
                $form->add_confirm($this->translate('glb_scs_reload'));
            }
        }

        $form->writeFormBlock();
    }



    /**
     * Generates register form
     *
     * @access public
     * @return void
     */
    public function register() {
        $form = new FormWriter('auth.register');
        $form->add_field_data('redirectto', array_value($_SERVER, 'HTTP_REFERER'));

        if (!$this->user('superuser')) {
            $form->remove_field('type');
            $form->remove_field('role');
        }
        if (array_value($_SESSION, 'ref')) {
            $form->add_field_data('ref', $_SESSION['ref']);
        }

        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
            $data['customer'] = strtolower(trim($data['customer']));
            if ($this->db->selectValue('SELECT id FROM customer WHERE login=$1', array($data['customer']))) {
                $form->add_error($this->translate('au_err_cname_exists'), 'customer');
            }
            $ref = (int) base64_decode($data['ref']);
            $referer = $this->db->select('SELECT id, login FROM customer WHERE id=$1', array($ref), FALSE);
            if ($data['ref'] && !$referer) {
                $form->add_error($this->translate('au_err_ref_not_exists'), 'ref');
            } elseif (!$data['ref']) {
                $referer_id = NULL;
            } else {
                $referer_id = $referer['id'];
            }


            if (!$form->has_error()) {
                /*** REGISTERING NEW CUSTOMER ***/
                if (!$form->has_error()) {
                    if (!$this->user('superuser')) {
                        $c_type = 'free';
                    } else {
                        $c_type = $data['type'];
                    }

                    if ($referer_id) {
                        $this->db->pinsert("
                        INSERT INTO customer
                        (login, type_id,                    referer_id) VALUES
                        ($1,    type_id('customer', $2),    $3)
                        ", array($data['customer'], $c_type, $referer_id));
                    } else {
                        $this->db->pinsert("
                        INSERT INTO customer
                        (login, type_id) VALUES
                        ($1,    type_id('customer', $2))
                        ", array($data['customer'], $c_type));
                    }                    $new_id = $this->db->last_id();
                }

                /*** REGISTERING NEW USER ***/
                $nuser = array(
                    'username' => '',
                    'customer_id' => $new_id,
                    'email' => $data['email'],
                    'icq' => $data['icq'],
                    'skype' => $data['skype'],
                    'active' => 'TRUE',
                );
                $nuser['password'] = Auth::instance()->genpass($data['customer'].'-', trim($data['password']));

                $uid = $this->db->insert('auth_user', $nuser, 'id');

                /*** ASSIGNING ROLE TO USER ***/
                if ($this->user('superuser')) {
                    foreach ($data['role'] as $rl) {
                        /*if (!$this->db->selectValue("
                            SELECT id
                            FROM auth_role WHERE id NOT IN
                            (SELECT role_id FROM auth_role_action WHERE action_id NOT IN
                            (SELECT action_id(category, action) FROM select_user_actions_full($1)) GROUP BY role_id)
                            AND id = role_id($2)
                            ", array($this->user('id'), $rl))) {
                            throw new CoreException("You haven't this role and couldn't assign it to others");
                        }*/
                        $this->db->selectValue("SELECT user_assign_role(user_id($1, ''), role_id($2))", array($data['customer'], $rl));
                    }
                } else {
                    $this->db->selectValue("SELECT user_assign_role(user_id($1, ''), role_id('user'))", array($data['customer']));
                }


                #sending mail to user
                $mail_params = array(
                    'link' => ($this->etc->referer && $this->etc->referer->host->val('bool')?$this->etc->referer->host->val():$this->router->getServer()).'?ref='.rtrim(base64_encode($new_id), '='),
                    'username' => $data['customer'],
                    'password' => $data['password'],
                    'email' => $data['email'],
                    'skype' => $data['skype'],
                    'icq' => $data['icq'],
                    'referer' => ($referer) ? $referer['login'] : NULL ,

                    'sitelink' => $this->router->getBase(),
                    'sitename' => $this->translate('glb_sitename')
                );

                $text = $this->sprintf_array($this->translate('au_rg_email_text'), $mail_params);
                $html = $this->sprintf_array($this->translate('au_rg_email_html'), $mail_params);

                $mailer = new Mailer();
                $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                ->to($data['email'])
                ->subject($this->translate('au_rg_email_subj'))
                ->text($text)->html($html)->send();

                $text = $this->sprintf_array($this->translate('au_notify'), $mail_params);
                //mail notification to site maintainer
                $mailer = new Mailer();
                $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                ->to($this->etc->mail->to)
                ->subject($this->translate('au_rg_email_subj'))
                ->text($text)
                ->send();

                #mail ends here

                if (!$this->user('logged')) {
                    //log in user
                    Auth::instance()->authorize($data['customer'].'-', $data['password']);
                }
                $this->redirecttobase();
                $form->add_confirm('New user has been successfuly registered');
            }
        }

        if ($this->user('superuser')) {
            $form->add_field_data('type', $this->db->selectHash("SELECT name,name FROM class WHERE parent_id = class_id('type','customer') ORDER BY name ASC"));
            $roles = $this->db->selectHash("
                    SELECT name, name
                    FROM auth_role
                    ORDER BY name ASC
                    ");
            $form->add_field_data('role', $roles);
        }

        $form->writeFormBlock();
    }





    /**
     * Generates register form
     *
     * @access public
     * @return void
     */
    public function lightning() {
        $form = new FormWriter('auth.register');

        $form->remove_field('type');
        $form->remove_field('role');
        $form->remove_field('customer');
        $form->remove_field('password');
        $form->remove_field('cpassword');
        $form->remove_field('ref');

        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
            $e = explode('@',$data['email']);
            $i = 0;
            do {
                $data['customer'] = strtolower(trim($e[0])).($i>0?$i:'');
                $i++;
            } while($this->db->selectValue('SELECT id FROM customer WHERE login=$1', array($data['customer'])));

            if (!$form->has_error()) {
                /*** REGISTERING NEW CUSTOMER ***/
                $c_type = 'free';
                $this->db->pinsert("
                        INSERT INTO customer
                        (login, type_id) VALUES
                        ($1,    type_id('customer', $2))
                        ", array($data['customer'], $c_type));
                $new_id = $this->db->last_id();

                /*** REGISTERING NEW USER ***/
                $nuser = array(
                    'username' => '',
                    'customer_id' => $new_id,
                    'email' => $data['email'],
                    'active' => 'TRUE',
                );
                $password = generate_password();
                $nuser['password'] = Auth::instance()->genpass($data['customer'].'-', $password);

                $uid = $this->db->insert('auth_user', $nuser, 'id');

                /*** ASSIGNING ROLE TO USER ***/
                $this->db->selectValue("SELECT user_assign_role(user_id($1, ''), role_id('user'))", array($data['customer']));

                #sending mail to user
                $mail_params = array(
                    'link' => ($this->etc->referer->host->val('bool')?$this->etc->referer->host->val():$this->router->getServer()).'?ref='.rtrim(base64_encode($new_id), '='),
                    'username' => $data['customer'],
                    'password' => $password,
                    'email' => $data['email'],
                    'skype' => $data['skype'],
                    'icq' => $data['icq'],

                    'sitelink' => $this->router->getBase(),
                    'sitename' => $this->translate('glb_sitename')
                );

                $text = $this->sprintf_array($this->translate('au_rg_email_text'), $mail_params);
                $html = $this->sprintf_array($this->translate('au_rg_email_html'), $mail_params);

                $mailer = new Mailer();
                $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                ->to($data['email'])
                ->subject($this->translate('au_rg_email_subj'))
                ->text($text)->html($html)->send();

                $text = $this->sprintf_array($this->translate('au_notify'), $mail_params);
                //mail notification to site maintainer
                $mailer = new Mailer();
                $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                ->to($this->etc->mail->to)
                ->subject($this->translate('au_rg_email_subj'))
                ->text($text)
                ->send();

                #mail ends here

                $form->add_confirm('New user has been successfuly registered');
            }
        }

        $form->writeFormBlock();
    }






    /**
     * Adds new user
     *
     * @access public
     * @return void
     */
    public function userAdd() {
        if (!$this->actionAllowed('auth.register')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        $form = new FormWriter('auth.useradd');
        $form->add_field_data('redirectto', array_value($_SERVER, 'HTTP_REFERER'));

        if (!$this->user('superuser')) {
            $form->remove_field('customer');
        }

        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
            $data['username'] = strtolower(trim($data['username']));
            $data['customer'] = $this->user('superuser') ? $data['customer'] : $this->user('customer_id');
            if ($this->db->selectValue('SELECT id FROM auth_user WHERE username=$1 and customer_id=$2', array($data['username'], $data['customer']))) {
                $form->add_error($this->translate('au_err_uname_exists'), 'username');
            }

            if (!$form->has_error()) {
                //adding user
                $nuser = array(
                    'username' => $data['username'],
                    'customer_id' => $data['customer'],
                    'email' => $data['email'],
                    'skype' => $data['skype'],
                    'icq' => $data['icq'],
                    'active' => 'TRUE'
                );
                $cname = $this->db->selectValue('SELECT login FROM customer WHERE id = $1', array($nuser['customer_id']));
                $nuser['password'] = Auth::instance()->genpass($cname.'-'.$data['username'], trim($data['password']));

                $this->db->insert('auth_user', $nuser, 'id');
                $new_id = $this->db->last_id();

                /*** ASSIGNING ROLE TO USER ***/
                if ($this->user('superuser')) {
                    foreach ($data['role'] as $rl) {
                        /*if (!$this->db->selectValue("
                            SELECT id
                            FROM auth_role WHERE id NOT IN
                            (SELECT role_id FROM auth_role_action WHERE action_id NOT IN
                            (SELECT action_id(category, action) FROM select_user_actions_full($1)) GROUP BY role_id)
                            AND id = role_id($2)
                            ", array($this->user('id'), $rl))) {
                                throw new CoreException("You haven't this role and couldn't assign it to others");
                        }*/
                        $this->db->selectValue("SELECT user_assign_role($1, role_id($2))", array($new_id, $rl));
                    }
                } else {
                    $this->db->selectValue("SELECT user_assign_role($1, role_id('user'))", array($new_id));
                }


                #sending mail to user
                $mail_params = array(
                    'link' => ($this->etc->referer && $this->etc->referer->host->val('bool')?$this->etc->referer->host->val():$this->router->getServer()).'?ref='.rtrim(base64_encode($new_id), '='),
                    'username' => $cname.'-'.$data['username'],
                    'password' => $data['password'],
                    'email' => $data['email'],
                    'skype' => $data['skype'],
                    'icq' => $data['icq'],

                    'sitelink' => $this->router->getBase(),
                    'sitename' => $this->translate('glb_sitename')
                );

                $text = $this->sprintf_array($this->translate('au_rg_email_text'), $mail_params);
                $html = $this->sprintf_array($this->translate('au_rg_email_html'), $mail_params);

                $mailer = new Mailer();
                $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                ->to($data['email'])
                ->subject($this->translate('au_rg_email_subj'))
                ->text($text)->html($html)->send();

                $text = $this->sprintf_array($this->translate('au_notify'), $mail_params);
                //mail notification to site maintainer
                $mailer = new Mailer();
                $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                ->to($this->etc->mail->to)
                ->subject($this->translate('au_rg_email_subj'))
                ->text($text)
                ->send();

                #mail ends here


                if (!$this->user('logged')) {
                //log in user
                        Auth::instance()->authorize($data['username'], $data['password']);
                $this->redirecttobase();
                } else {
                    $this->redirecttourl($data['redirectto']);
                }
                $form->add_confirm('New user has been successfuly registered');
            }
        }

        if ($this->user('superuser')) {
            $form->add_field_data('customer', $this->db->selectHash("SELECT id, login FROM customer WHERE (status_id = status_id('customer', 'active') OR status_id = status_id('customer', 'new')) AND parent_id IS NULL ORDER BY login;"));
        }
        $roles = $this->db->selectHash("
                SELECT name, name
                FROM auth_role
            ORDER BY name ASC
            ");
        $form->add_field_data('role', $roles);


        $form->writeFormBlock();
    }



    /**
     * Generates forgotten password request form
     *
     * @access public
     * @return void
     */
    public function forgotten() {
            $form = new FormWriter('auth.forgotten');

            if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
                $loe = strtolower(trim($data['usernameoremail']));

                $not_exist = false;
                $id = $this->db->selectValue('SELECT id FROM auth_user WHERE email=$1 AND active=TRUE', array($loe), 'id');
                if (!$id) {
                    $not_exist = true;
                }
                $username_parts = explode('-', $loe);
                if ($not_exist) {
                    $id = $this->db->selectValue('SELECT id FROM auth_user WHERE customer_id = customer_id($1) AND username = $2 AND active=TRUE', array($username_parts[0], array_value($username_parts, 1, '')), 'id');
                    if ($id) {
                        $not_exist = false;
                    }
                }
                if ($not_exist) {
                    $form->add_error($this->translate('au_frg_err_not_exists'), 'usernameoremail');
                } else {
                    $user = $this->db->select('SELECT *, customer_name(customer_id) as customer_name FROM auth_user WHERE id = $1', array($id), false);
                    if (empty($user['email'])) {
                        $form->add_error('User has no email');
                    }
                }
                if (!$form->has_error()) {

                    $mail_params['link'] = $this->router->getServer().'forgotten/'.md5($user['id'].$user['password'].$user['email'].'password');
                    $mail_params['sitelink'] = $this->router->getBase();
                    $mail_params['sitename'] = $this->translate('glb_sitename');

                    $text = $this->sprintf_array($this->translate('au_frg_email_text'), $mail_params);
                    $html = $this->sprintf_array($this->translate('au_frg_email_html'), $mail_params);

                    $mailer = new Mailer();
                    $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                    ->to($user['email'], $user['customer_name'].'-'.$user['username'])
                    ->subject($this->translate('au_frg_email_subj'))
                    ->text($text)->html($html)->send();

                    $form->add_confirm($this->translate('au_frg_email_sent'));
                }
            }
        $form->writeFormBlock();
    }


    /**
     * Generates forgotten password update
     *
     * @access public
     * @return void
     */
    public function forgottenUpdate() {
        if ($this->user('logged')) {
            $this->redirecttobase();
        }
        if ($this->etc->site->db && $this->etc->site->db->val() == 'mysql') {
            $user = $this->db->select("SELECT *, customer_name(customer_id) as customer_name FROM auth_user WHERE MD5(CONCAT(id, password, email, 'password'))  = $1 AND active = TRUE", array($this->router->getParams('hash')), false);
        } else {
            $user = $this->db->select("SELECT *, customer_name(customer_id) as customer_name FROM auth_user WHERE MD5(id || password || email || 'password')  = $1 AND active = TRUE", array($this->router->getParams('hash')), false);
        }
        if($user) {
            $form = new FormWriter('auth.forgottenUpdate');

            $login =  $user['customer_name'].($user['username']?'-'.$user['username']:'');
            $form->add_field_data('login',$login);

            if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
                Auth::instance()->logout($user['id']);

                $this->db->update('auth_user', array('password'=>Auth::instance()->genpass($login, $data['password'])), array('id'=>$user['id']));

                Auth::instance()->authorize($login, $data['password']);

                $mail_params['username'] = $login;
                $mail_params['password'] = $data['password'];
                $mail_params['sitelink'] = $this->router->getBase();
                $mail_params['sitename'] = $this->translate('glb_sitename');

                $text = $this->sprintf_array($this->translate('au_passup_text'), $mail_params);
                $html = $this->sprintf_array($this->translate('au_passup_html'), $mail_params);

                $mailer = new Mailer();
                $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                ->to($user['email'], $login)
                ->subject($this->translate('au_passup_subj'))
                ->text($text)->html($html)->send();

                $this->redirecttourl($this->router->getUserlink($login));
            }
            $form->writeFormBlock();
        } else {
            $this->xml->writeElement('error', $this->translate('au_frg_err_wrong_link'));
        }
    }


    /**
     * Activate user
     *
     * @access public
     * @return void
     */
    public function activate() {
        if (!$this->router->getParams('uid')) {
            throw new CoreException($this->translate('au_reqparams'));
        }
        if (!$this->actionAllowed('auth.edit')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        $this->db->update("auth_user", array("active" => "TRUE"), array('id' => $this->router->getParams('uid')));
        //log action
        $this->logAction("user ACTIVATED", 'auth.edit', $this->router->getParams('uid'));
        $this->redirectback();
    }


    /**
     * Deactive user
     *
     * @access public
     * @return void
     */
    public function deactivate() {
        if (!$this->router->getParams('uid')) {
            throw new CoreException($this->translate('au_reqparams'));
        }
        if (!$this->actionAllowed('auth.edit')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        $this->db->update("auth_user", array("active" => "FALSE"), array('id' => $this->router->getParams('uid')));
        //log action
        $this->logAction("user DEACTIVATED", 'auth.edit', $this->router->getParams('uid'));
        $this->redirectback();
    }


    /**
     * Assign role to user
     *
     * @access public
     * @return void
     */
    public function addUsersRole() {
        if (!$this->router->getParams('uid', 'PARAM')) {
            throw new CoreException($this->translate('au_reqparams'));
        }
        if (!$this->actionAllowed('auth.edit')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        $form = new FormWriter('auth.adduserrole');
        $form->add_field_data('redirectto', array_value($_SERVER, 'HTTP_REFERER'));

        $user = $this->getUser($this->router->getParams('uid', 'PARAM'));
        if (!$user) {
            throw new CoreException('No such user.');
        }
        if (!$this->user('superuser') && $user['customer_id'] !== $this->user('customer_id')) {
            throw new CoreException('User of another customer - access denied.');
        }

        $form->add_field_data('username', $user['customer_name'].'::'.$user['username']);
        $roles = $this->db->selectHash("
                    SELECT id, name
                    FROM auth_role
                    ");
        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams(null, 'POST'))) {
            /*if (!$this->db->selectValue("
                    SELECT id
                    FROM auth_role WHERE id NOT IN
                        (SELECT role_id FROM auth_role_action WHERE action_id NOT IN
                            (SELECT action_id(category, action) FROM select_user_actions_full($1)) GROUP BY role_id)
                    AND id = $2
                    ", array($this->user('id'), $data['rid']))) {
                throw new CoreException("You haven't this role and couldn't assign it to others");
            }*/
            $r = $this->db->selectValue('SELECT user_assign_role($1, $2)', array((int)$user['id'], (int)$data['rid']));
            if ($r == 'f') {
                $form->add_error('Already has this role', 'rid');
            } else {
                Auth::instance()->update($user['id']);
                //log action
                $this->logAction("role \"".$roles[$data['rid']]."\" GRANTED to user \"".$user['customer_name'].'-'.$user['username']."\"", 'auth.edit', $user['id']);
                $this->redirecttourl($data['redirectto']);
            }
        }

        $form->add_field_data('uid', $this->router->getParams('uid'));

        $form->add_field_data('rid', $roles);

        $form->writeFormBlock();
    }


    /**
     * Removes user's group
     *
     * @access public
     * @return void
     */
    public function deleteUsersRole() {
        if (!$this->router->getParams('uid', 'PARAM') || !$this->router->getParams('rid', 'PARAM')) {
            throw new CoreException($this->translate('au_reqparams'));
        }
        if (!$this->actionAllowed('auth.edit')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }

        $user = $this->getUser($this->router->getParams('uid', 'PARAM'));
        if (!$user) {
            throw new CoreException('No such user.');
        }
        if (!$this->user('superuser') && $user['customer_id'] !== $this->user('customer_id')) {
            throw new CoreException('User of another customer - access denied.');
        }

        /*if (!$this->db->selectValue("
                    SELECT id
                    FROM auth_role WHERE id NOT IN
                        (SELECT role_id FROM auth_role_action WHERE action_id NOT IN
                            (SELECT action_id(category, action) FROM select_user_actions_full($1)) GROUP BY role_id)
                    AND id = $2
                    ", array($this->user('id'), $this->router->getParams('rid', 'PARAM')))) {
            throw new CoreException("You haven't this role and couldn't revoke it from others");
        }*/
        $r = $this->db->selectValue('SELECT user_revoke_role($1, $2)', array((int)$user['id'], (int)$this->router->getParams('rid', 'PARAM')));
        Auth::instance()->update($user['id']);
        //log action
        $this->logAction("role ".$this->router->getParams('rid', 'PARAM')." REVOKED from user \"".$user['customer_name'].'-'.$user['username']."\"", 'auth.edit', $user['id']);
        $this->redirectback();
    }



    /**
     * Generates customers list
     *
     * @access public
     * @return void
     */
    public function customerlist() {
        if (!$this->actionAllowed('root.customerlist')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }

        /*init pager*/
        $total = $this->db->selectValue('SELECT COUNT(id) as count FROM customer');
        $pager = new Pager(
                            (int) $this->router->getParams('page'),
                            100,
                            $total,
                            $this->router->getAlias());


        $users = $this->db->select("
            SELECT *,
                 customer_name(referer_id) as referer_name,
                 type_name(type_id) as type,
                 status_name(status_id) as status
            FROM customer
            ORDER BY status_id DESC, login ASC
            ".$pager->getLimit());

        if ($this->etc->referer && !$this->etc->referer->disabled->val('bool')) {
            $this->xml->writeAttribute('referer', 1);
            $this->xml->writeAttribute('referer_host', $this->etc->referer->host->val('bool')?$this->etc->referer->host->val():$this->router->getServer());
        }

        foreach ($users as $k=>$u) {
            $users[$k]['ref'] = rtrim(base64_encode($u['id']), '=');
        }

        $this->xml->writeTree('customerlist', $users, 'customer');
        /*generate pager*/
        $pager->generate($this->xml);
        $this->xml->writeTree('errors', $this->errorsFetch(), 'error');
        $this->xml->writeTree('confirms', $this->confirmsFetch(), 'confirm');
    }



    public function limitscheck() {
        $limits = array();
        foreach ($this->etc->api->limits->limit as $limit) {
            if ($this->etc->site->db && $this->etc->site->db->val() == 'mysql') {
                $limits[] = $this->db->selectValue("SELECT CONCAT(count(*),'/".$limit->attr('count')." | ".$limit->attr('time')."')
                        FROM global_log_action
                        JOIN auth_user as au ON (au.id = global_log_action.user_id)
                        WHERE action_id = action_id('api', 'request') AND time > DATE_SUB(CONCAT(CURDATE(),' ',CURTIME()),INTERVAL ".$limit->attr('time').") AND au.customer_id = customer_id($1)", array($this->router->getParam('customer')));
            } else {
                $limits[] = $this->db->selectValue("SELECT count(*) || '/".$limit->attr('count')." | ".$limit->attr('time')."'
                        FROM global_log_action
                        JOIN auth_user as au ON (au.id = global_log_action.user_id)
                        WHERE action_id = action_id('api', 'request') AND time > now() - '".$limit->attr('time')."'::interval AND au.customer_id = customer_id($1)", array($this->router->getParam('customer')));
            }
        }

        $this->JSONRespond(array("cid"=>$this->db->selectValue("SELECT customer_id($1)",array($this->router->getParam('customer'))),"limits"=>implode('<br/>',$limits)));
    }



    /**
     * Add customer
     *
     * @access public
     * @return void
     */
    public function customerAdd() {
        if (!$this->actionAllowed('root.customermanage')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        $form = new FormWriter('auth.customeradd');
        $form->add_field_data('redirectto', array_value($_SERVER, 'HTTP_REFERER'));

        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams(null, 'POST'))) {
            if ($this->db->selectValue("SELECT id FROM customer WHERE login = $1", array($data['customer']))) {
                $form->add_error($this->translate('au_err_uname_exists'), 'customer');
            }
            if (!$form->has_error()) {
                $this->db->pinsert("INSERT INTO customer (login, status_id, type_id) VALUES ($1, status_id('customer', $2), type_id('customer', $3))", array($data['customer'], $data['status'], $data['type']));
                $new_id = $this->db->last_id();
                $this->redirecttourl($data['redirectto']);
            }
        }
        $form->add_field_data('status', $this->db->selectHash("SELECT name,name FROM class WHERE parent_id = class_id('status','customer') ORDER BY name ASC"));
        $form->add_field_data('type', $this->db->selectHash("SELECT name,name FROM class WHERE parent_id = class_id('type','customer') ORDER BY name ASC"));

        $form->writeFormBlock();
    }


    /**
     * Generates users list (for moderators)
     *
     * @access public
     * @return void
     */
    public function userlist() {
        if (!$this->actionAllowed('auth.userlist')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        #init pager
        $total = $this->db->selectValue('SELECT COUNT(id) as count FROM auth_user'.(!$this->user('superuser')?' WHERE customer_id = $1':''), (!$this->user('superuser')?array($this->user('customer_id')):array()));
        $pager = new Pager(
                (int) $this->router->getParams('page'),
                1000,
                $total,
                $this->router->getAlias());
        $users = $this->db->select("
                SELECT au.*,
                customer_name(au.customer_id) as customer_name
                FROM auth_user as au
                ".(!$this->user('superuser')?'WHERE customer_id = $1':'')."
                ORDER BY customer_name ASC, au.username ASC
                ".$pager->getLimit(),
                (!$this->user('superuser')?array($this->user('customer_id')):array()));
        foreach ($users as $key=>$user) {
            $users[$key]['roles'] = $this->db->select('SELECT role_name(role_id) as name, role_id as id FROM auth_role_user WHERE user_id = $1', array((int)$user['id']));
            $users[$key]['roles']['nodename'] = 'role';
        }
        $this->xml->writeTree('userlist', $users, 'user');
        #generate pager
        $pager->generate($this->xml);

        $this->xml->writeTree('roles', $this->db->selectValues("
                SELECT id
                FROM auth_role
                "), 'role');
        $this->xml->writeTree('errors', $this->errorsFetch(), 'error');
        $this->xml->writeTree('confirms', $this->confirmsFetch(), 'confirm');
    }

    /**
     * User's profile
     *
     * @access public
     * @return void
     */
    public function profile() {
        $u_param = $this->router->getParams('username');
        if (!$u_param && !$this->user('logged')) {
            throw new CoreException($this->translate('Nobody\'s home...'), 404);
        } elseif ($u_param) {
            $u_parts = explode('-', $u_param);
            $username = array_value($u_parts, 1 , '');
            $customer = $u_parts[0];
        } else {
            $username = $this->user('username');
            $customer = $this->user('customer_name');
        }
        $user = $this->db->select("
            SELECT au.*,
                   customer_name(au.customer_id) as customer_name
            FROM auth_user as au
            WHERE au.customer_id = customer_id($1) AND au.username=$2 LIMIT 1", array($customer, $username), false);
        if (!$user) {
            throw new CoreException($this->translate('glb_404'), 404, array('requested subdomain'=>$this->router->getSubdomain()));
        }
        if ($this->etc->referer && !$this->etc->referer->disabled->val('bool')) {
            $user['ref_link'] = ($this->etc->referer->host->val('bool')?$this->etc->referer->host->val():$this->router->getServer()).'?ref='.rtrim(base64_encode($user['customer_id']), '=');
        }


        if ($user['id'] == $this->user('id')) {
            $user['attr']['owner'] = 1;
        }
        $this->xml->writeTree('user', $user);
    }


    /**
     * Own profile edtit
     *
     * @access public
     * @return void
     */
    public function profileEdit() {
        if (!$this->user('logged')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        $form = new FormWriter('auth.profile');

        $form->add_field_data('email', $this->user('email',true));
        $form->add_field_data('skype', $this->user('skype',true));
        $form->add_field_data('icq', $this->user('icq',true));
        $form->add_field_data('username', $this->user('customer_name',true).($this->user('username',true)?'-'.$this->user('username',true):''));

        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
            $pq = 'SELECT id FROM auth_user WHERE customer_id = $1 AND username=$2 AND password = $3';
            $uid = $this->db->selectValue($pq, array($this->user('customer_id'), $this->user('username'), Auth::instance()->genpass($this->user('customer_name').'-'.$this->user('username'), $data['current_password'])), 'id');
            if ($uid !== $this->user('id')) {
                $form->add_error($this->translate('au_frg_err_wrong_pass'), 'current_password');
            }

            if (!$form->has_error()) {
                $idata = array(
                    'email' => $data['email'],
                    'icq' => $data['icq'],
                    'skype' => $data['skype']
                );
                if (!empty($data['password'])) {
                    $idata['password'] = $password = Auth::instance()->genpass($this->user('customer_name').'-'.$this->user('username'), $data['password']);
                } else {
                    $password = $this->user('password');
                }

                if (!empty($idata)) {
                    $this->db->update('auth_user', $idata, array('id'=>$this->user('id')));
                }

                if (!$form->has_error()) {
                    //relog in user
                    Auth::instance()->reauthorize();
                    $this->redirecttourl($this->router->getServer().'profile/');
                }
            }
        }

        $form->writeFormBlock();
    }


    /**
     * User's profile edit
     *
     * @access public
     * @return void
     */
    public function userEdit() {
        if (!$this->user('superuser')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }

        $u_param = $this->router->getParams('user');
        $u_parts = explode('-', $u_param);
        $username = array_value($u_parts, 1 , '');
        $customer = $u_parts[0];

        $user = $this->db->select('SELECT * FROM auth_user WHERE customer_id = customer_id($1) AND username=$2', array($customer, $username), false);
        if (!$user['id']) {
            throw new CoreException($this->translate('No such user'), 404);
        }

        $form = new FormWriter('auth.profile');

        $form->add_field_data('email', $user['email']);
        $form->add_field_data('skype', $user['skype']);
        $form->add_field_data('icq', $user['icq']);
        $form->add_field_data('username', $customer.($username?'-'.$username:''));
        $form->remove_field('current_password');

        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {
            $idata = array(
                'email' => $data['email'],
                'icq' => $data['icq'],
                'skype' => $data['skype']
            );
            if (!empty($data['password'])) {
                $idata['password'] = Auth::instance()->genpass($customer.'-'.$username, $data['password']);
            }
            $this->db->update('auth_user', $idata, array('id'=>$user['id']));

            if (!$form->has_error()) {
                //relog in user
                Auth::instance()->reauthorize();
                $this->redirecttourl($this->router->getServer().'user/'.$customer.'-'.$username);
            }
        }

        $form->writeFormBlock();
    }

    /**
     * Show access log
     *
     * @access public
     * @return void
     */
    public function accessLog() {
        if (!$this->actionAllowed('root.logs')) {
            throw new CoreException($this->translate('glb_403'), 403);
        }
        /*init pager*/
        $total = $this->db->selectValue('SELECT COUNT(*) as count FROM global_log_access', array(), 'count');
        $pager = new Pager(
                        (int) $this->router->getParams('page'),
                        100,
                        $total,
                        $this->router->getAlias());
        $records = $this->db->select("
            SELECT au.username,
                   customer_name(au.customer_id) as customer_name,
                   user_id,
                   accesspoint,
                   referer,
                   params,
                   time
            FROM global_log_access
            LEFT JOIN auth_user as au ON (au.id = user_id)
            ORDER BY time DESC ".$pager->getLimit()
        );
        foreach ($records as $k=>$r) {
            $records[$k]['params'] = $this->_compactParams(json_decode(base64_decode($r['params']), true));
            $records[$k]['params']['nodename'] = 'param';
        }
        $this->xml->writeTree('log', $records, 'record');
        /*generate pager*/
        $pager->generate($this->xml);
    }
    private function _compactParams($in_params) {
        $params = array();
        foreach ($in_params as $p=>$v) {
            if (is_array($v)) {
                $params[] = array('name'=>$p, 'value'=>$this->_compactParams($v));
            } else {
                $params[] = array('name'=>$p, 'value'=>$v);
            }
        }
        return $params;
    }



    /**
     * Show actions log
     *
     * @access public
     * @return void
     */
    public function actionsLog() {
        if ($this->actionAllowed('root.logs')) {
            /*init pager*/
            $total = $this->db->selectValue('SELECT COUNT(*) as count FROM global_log_action', array(), 'count');
            $pager = new Pager(
                                (int) $this->router->getParams('page'),
                                100,
                                $total,
                                $this->router->getAlias());
            $records = $this->db->select("
                SELECT au.username,
                       c.login as customer_name,
                       user_id,
                       action,
                       link,
                       time
                FROM global_log_action
                LEFT JOIN auth_user as au ON (au.id = user_id)
                LEFT JOIN customer as c ON (c.id = au.customer_id)
                  ORDER BY time DESC
                ".$pager->getLimit()
            );
            $this->xml->writeTree('log', $records, 'record');
            /*generate pager*/
            $pager->generate($this->xml);
        } else {
            throw new CoreException($this->translate('glb_403'), 403);
        }
    }



    /**
     * Generates users autocomplete list
     *
     * @access public
     * @return void
     */
    public function usercomplete() {
        $q = $this->router->getParams('query');
        if ($this->user('superuser')) {
            if ($this->etc->site->db && $this->etc->site->db->val() == 'mysql') {
                $users = (!empty($q) && strpos($q, 'g:') === false) ? $this->db->selectValues("
                    SELECT username
                    FROM view_user
                    WHERE username LIKE $1
                    ORDER BY CASE WHEN LEFT(username, $3) = $2 THEN 1 ELSE 2 END ASC, username ASC", array('%'.$q.'%', $q, strlen($q))) : array() ;
            } else {
                /*$users = (!empty($q) && strpos($q, 'g:') === false) ? $this->db->selectValues("
                    SELECT username
                    FROM view_user
                    WHERE username LIKE $1
                    ORDER BY CASE WHEN LEFT(username, $3) = $2 THEN 1 ELSE 2 END ASC, username ASC", array('%'.$q.'%', $q, strlen($q))) : array() ;
                : array() ;*/
                $users = (!empty($q) && strpos($q, 'g:') === false) ? $this->db->selectValues("
                    SELECT username
                    FROM view_user
                    WHERE username LIKE $1
                    ORDER BY username !~$2 ASC,username ASC", array('%'.$q.'%', '^'.$q)) : array() ;
            }
            if (strpos($q, 'g:') !== false) {
                $gq = str_replace('g:', '', $q);
            } else {
                $gq = $q;
            }
        } else {
            $users = array();
        }
        /*$groups = (!empty($gq)) ? $this->db->selectValues("SELECT name FROM auth_groups WHERE name LIKE ".$this->db->quote('%'.$gq.'%')." ORDER BY name !~".$this->db->quote('^'.$gq)." ASC,name ASC", 'name') : $this->db->selectValues("SELECT name FROM auth_groups ORDER BY name ASC", 'name');
        foreach ($groups as $gkey=>$group) {
            $groups[$gkey] = 'g:'.$group;
        }*/
        $result = array(
                'query' => $q,
                'suggestions' => $users#array_merge($groups, $users)
        );
        $this->JSONRespond($result);
    }


    /**
     * Logout user from current computer
     *
     * @access public
     * @return void
     */
    public function logout() {
        Auth::instance()->kill(true, false);
        $this->redirecttobase();
    }

    /**
     * Logout user from all computers
     *
     * @access public
     * @return void
     */
    public function logoutAll() {
        Auth::instance()->kill();
        $this->redirecttobase();
    }


    /******************************/
    /*                            */
    /*     RUN ACTION DIVISION    */
    /*                            */
    /******************************/


    /**
     * Run api action
     *
     * @access public
     * @return void
     */
    public function run() {
        if (!$this->actionAllowed('auth')) {
            throw new CoreException('Access denied!', 403);
        }
        $m = 'api_'.$this->router->getParams('action');
        if (method_exists($this, $m)) {
            $result = $this->$m();
            $this->errorsSave($result['errors']);
            $this->confirmsSave($result['confirms']);
        } else {
            $this->errorsSave(array('Action "'.$m.'" doesn\'t exist'));
        }
        if (!$this->router->getParams('redirect')) {
            $this->redirectback();
        } else {
            $this->redirecttourl($this->router->getParams('redirect'));
        }
    }

    /**
     * Check api action
     *
     * @access public
     * @param string name
     * @return void
     */
    public function actionCheck($name) {
        if (!$this->actionAllowed($name)) {
            throw new BlockException('Access denied!', 403);
        }

        $result['errors'] = array();
        $result['confirms'] = array();

        $ids = $this->router->getParams('id');
        if (!is_array($ids)) {
            $ids = array($ids);
        }
        if (empty($ids)) {
            $result['errors'][] = 'Nothing chosen';
            return $result;
        }
        $i = 1;
        $placeholder = array();
        $value = array();
        foreach ($ids as $id) {
            $placeholder[] = '$'.$i++;
            $value[] = $id;
        }
        $this->checked_ids = $this->db->selectHash("SELECT id, status_name(status_id) as status FROM customer WHERE id IN (".implode(',', $placeholder).")", $value);
        if (empty($this->checked_ids)) {
            $result['errors'][] = 'Nothing found';
            return $result;
        }

        return $result;
    }


    /**
     * Delete user
     *
     * @access public
     * @return void
     */
    public function api_deleteUser() {
        if (!$this->actionAllowed('auth.delete')) {
            throw new BlockException('Access denied!', 403);
        }

        $result['errors'] = array();
        $result['confirms'] = array();

        $ids = $this->router->getParams('id');
        if (!is_array($ids)) {
            $ids = array($ids);
        }
        if (empty($ids)) {
            $result['errors'][] = 'Nothing chosen';
            return $result;
        }
        $i = 1;
        $placeholder = array();
        $value = array();
        foreach ($ids as $id) {
            $placeholder[] = '$'.$i++;
            $value[] = $id;
        }
        $this->checked_ids = $this->db->selectHash("SELECT id, id FROM auth_user WHERE id IN (".implode(',', $placeholder).")", $value);
        if (empty($this->checked_ids)) {
            $result['errors'][] = 'Nothing found';
            return $result;
        }
        foreach ($this->checked_ids as $k=>$ci) {
            $this->db->begin();
            $d = $this->db->select("SELECT * FROM auth_user WHERE id = $1", array($k));
                 $this->db->pdelete("DELETE FROM auth_user WHERE id = $1", array($k));
            $this->db->commit();
            $msg = $result['confirms'][] = 'id:'.$d[0]['id'].' username:'.$d[0]['username'].' - OK';
            //log action
            $this->logAction("DELETE user: ".$msg, 'auth.delete', $d[0]['id']);
        }

        return $result;
    }


    /**
     * Delete customer
     *
     * @access public
     * @return void
     */
    public function api_deleteCustomer() {
        $result = $this->actionCheck('root.customerdelete');
        if (!empty($result['errors'])) {
            return $result;
        }
        foreach ($this->checked_ids as $k=>$ci) {
            switch ($ci) {
                case 'deleted':
                    $msg = $result['confirms'][] = 'id:'.$k.' - Customer is already deleted';
                    break;
                default:
                    $this->db->begin();
                    $d = $this->db->select("SELECT * FROM customer WHERE id = $1", array($k));
                         $this->db->pupdate("UPDATE customer SET status_id = status_id('customer', 'deleted') WHERE id = $1", array($k));
                    $this->db->commit();
                    $msg = $result['confirms'][] = 'id:'.$k.' login:'.$d[0]['login'].' - OK';
            }
            //log action
            $this->logAction("DELETE customer: ".$msg, 'root.customerdelete', $d[0]['id']);
        }

        return $result;
    }


    /**
     * Undelete customer
     *
     * @access public
     * @return void

    public function api_undeleteCustomer() {
        $result = $this->actionCheck('root.customerdelete');
        if (!empty($result['errors'])) {
            return $result;
        }
        foreach ($this->checked_ids as $k=>$ci) {
            if ($ci != 'deleted') {
                $msg = $result['errors'][] = 'id:'.$k.' - Customer is not deleted';
            } else {
                $d = $this->db->pupdate("UPDATE customer SET status_id = status_id('customer', 'active') WHERE id = $1 RETURNING *", array($k));
                $msg = $result['confirms'][] = 'id:'.$k.' login:'.$d[0]['login'].' - OK';
            }
            //log action
            $this->logAction("UNDELETE customer: ".$msg, 'root.customerdelete', $d[0]['id']);
        }

        return $result;
    }*/



    /**
     * Block customer
     *
     * @access public
     * @return void
     */
    public function api_blockCustomer() {
        $result = $this->actionCheck('root.customerdelete');
        if (!empty($result['errors'])) {
            return $result;
        }
        foreach ($this->checked_ids as $k=>$ci) {
            switch ($ci) {
                case 'blocked':
                    $msg = $result['confirms'][] = 'id:'.$k.' - Customer is already blocked';
                    break;
                case 'deleted':
                    $msg = $result['errors'][] = 'id:'.$k.' - Customer deleted';
                    break;
                default:
                    $this->db->begin();
                    $d = $this->db->select("SELECT * FROM customer WHERE id = $1", array($k));
                    $this->db->pupdate("UPDATE customer SET status_id = status_id('customer', 'blocked') WHERE id = $1", array($k));
                    $this->db->commit();
                    $msg = $result['confirms'][] = 'id:'.$k.' login:'.$d[0]['login'].' - OK';
            }
            //log action
            $this->logAction("BLOCK customer: ".$msg, 'root.customermanage', $k);
        }

        return $result;
    }


    /**
     * Block customer
     *
     * @access public
     * @return void
     */
    public function api_unblockCustomer() {
        $result = $this->actionCheck('root.customerdelete');
        if (!empty($result['errors'])) {
            return $result;
        }
        foreach ($this->checked_ids as $k=>$ci) {
            switch ($ci) {
                case 'active':
                    $msg = $result['confirms'][] = 'id:'.$k.' - Customer is already active';
                    break;
                case 'deleted':
                    $msg = $result['errors'][] = 'id:'.$k.' - Customer deleted';
                    break;
                default:
                    $this->db->begin();
                    $d = $this->db->select("SELECT * FROM customer WHERE id = $1", array($k));
                    $this->db->pupdate("UPDATE customer SET status_id = status_id('customer', 'active') WHERE id = $1", array($k));
                    $this->db->commit();
                    $msg = $result['confirms'][] = 'id:'.$k.' login:'.$d[0]['login'].' - OK';
            }
            //log action
            $this->logAction("UNBLOCK customer: ".$msg, 'root.customermanage', $k);
        }

        return $result;
    }

}
