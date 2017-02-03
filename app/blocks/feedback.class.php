<?php
/**
 * Contains feedback module class
 *
 * @package Striped
 * @subpackage blocks
 * @author K.Nazarenko     http://nazarenko.me/
 * @copyright Kostyantyn Nazarenko 2010
 */

require_once('striped/app/core/BlockController.class.php');
require_once('striped/app/core/FormWriter.class.php');
require_once('striped/app/lib/Mailer64.class.php');

################################################################################

/**
 * Provides feedback mail functionality
 *
 * @package Striped
 * @subpackage blocks
 */
class feedback extends BlockController {
    /**
     * Feedback form page
     *
     * @access public
     * @return void
     */
    public function show() {
        $form = new FormWriter('feedback');
        $descr = $form->get_form_descriptor(true);
        foreach ($descr->fieldgroup->field as $field) {
            if ($field->attr('name', 'str')) {
                $form->add_field_data($field->attr('name', 'str'), $this->user($field->attr('name', 'str')));
            }
        }
        if ($data = $form->get_valid_data_if_form_sent($this->router->getParams())) {

            $body = array();
            foreach ($data as $name=>$value) {
                $body[] = $this->translate($form->get_field_title($name)).': '.$value;
            }

            $mail_params['body'] = implode("\n", $body);

            $mail_params['browser'] = $_SERVER["HTTP_USER_AGENT"];
            $mail_params['hostname'] = gethostbyaddr($_SERVER['REMOTE_ADDR']);
            $mail_params['ip'] = $_SERVER["REMOTE_ADDR"];

            $text = $this->sprintf_array($this->translate('FEEDBACK_EMAIL_BODY_TEXT'), $mail_params);
            $mail_params['body'] = nl2br($mail_params['body']);
            $html = $this->sprintf_array($this->translate('FEEDBACK_EMAIL_BODY_HTML'), $mail_params);

            $mailer = new Mailer();
            $mailer->from($this->etc->mail->from, $this->etc->mail->from_name)
                    ->to($this->etc->mail->to, $this->etc->mail->to_name)
                    ->subject($this->translate('FEEDBACK_EMAIL_SUBJECT'))
                    ->text($text)->html($html)->send();

            $form->add_confirm($this->translate('FEEDBACK_SUCCESSFULY_SENT'), 'content');
        }
        $form->writeFormBlock();
    }

}
