<?php
/**
 * Contains Mailer class
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009-11
 */

################################################################################

/**
 * Mailer class
 *
 * @package Striped 3
 * @subpackage lib
 * @final
 */
final class Mailer {

    const EOL = "\n";

    /**
     * Recipients' e-mails
     *
     * @var array
     * @access private
     */
    private $to = array();

    /**
     * Copy recipients' e-mails
     *
     * @var array
     * @access private
     */
    private $cc = array();

    /**
     * Hidden copy recipients' e-mails
     *
     * @var array
     * @access private
     */
    private $bcc = array();

    /**
     * Sender's e-mail
     *
     * @var string
     * @access private
     */
    private $from;

    /**
     * Letter's headers
     *
     * @var array
     * @access private
     */
    private $headers = array();

    /**
     * Letter's subject
     *
     * @var string
     * @access private
     */
    private $subject;

    /**
     * Letter's text
     *
     * @var string
     * @access private
     */
    private $text;

    /**
     * Letter's html
     *
     * @var string
     * @access private
     */
    private $html;

    /**
     * Reply-to e-mail
     *
     * @var string
     * @access private
     */
    private $replyto;

    /**
     * Letter's charset
     *
     * @var string
     * @access private
     */
    private $charset = 'UTF-8';

    /**
     * Attachments
     *
     * @var array
     * @access private
     */
    private $attachments = array();

    /**
     * Constructor
     *
     * @return public
     */
    public function __construct() {
        $this->headers[] = 'X-Mailer: Striped';
        $this->headers[] = 'Mime-Version: 1.0';
        $this->headers[] = 'X-Priority: 3';
    }

    /**
     * Clears all previouse setted data
     *
     * @return public
     * @return Mailer
     */
    public function clear() {
        $this->to = array();
        $this->cc = array();
        $this->bcc = array();
        $this->headers = array();
        $this->from = NULL;
        $this->subject = NULL;
        $this->text = NULL;
        $this->html = NULL;
        $this->replyto = NULL;
        $this->charset = 'UTF-8';
        $this->attachments = array();
        return $this;
    }

    /**
     * Adds custom header
     *
     * @param string $header
     * @return Mailer
     */
    public function header($header) {
        $this->headers[] = (string)$header ;
        return $this;
    }

    /**
     * Sets recipients' e-mails
     *
     * @param string $email
     * @param string $name
     * @return Mailer
     */
    public function to($email, $name=null) {
        $this->to[] = ($name) ? '=?'.$this->charset.'?B?'.base64_encode($name).'?=<'.$email.'>' : $email ;
        return $this;
    }

    /**
     * Sets sender's e-mail
     *
     * @param string $email
     * @param string $name
     * @return Mailer
     */
    public function from($email, $name=null) {
        $this->from = ($name) ? '=?'.$this->charset.'?B?'.base64_encode($name).'?=<'.$email.'>' : $email ;
        return $this;
    }

    /**
     * Sets reply-to e-mail
     *
     * @param string $email
     * @param string $name
     * @return Mailer
     */
    public function replyto($email, $name=null) {
        $this->replyto = ($name) ? '=?'.$this->charset.'?B?'.base64_encode($name).'?=<'.$email.'>' : $email ;
        return $this;
    }

    /**
     * Sets letter's copy to e-mail
     *
     * @param string $email
     * @param string $name
     * @return Mailer
     */
    public function cc($email, $name=null) {
        $this->cc[] = ($name) ? '=?'.$this->charset.'?B?'.base64_encode($name).'?=<'.$email.'>' : $email ;
        return $this;
    }

    /**
     * Sets letter's hidden copy to e-mail
     *
     * @param string $email
     * @param string $name
     * @return Mailer
     */
    public function bcc($email, $name=null) {
        $this->bcc[] = ($name) ? '=?'.$this->charset.'?B?'.base64_encode($name).'?=<'.$email.'>' : $email ;
        return $this;
    }

    /**
     * Sets letter's subject
     *
     * @param string $str
     * @return Mailer
     */
    public function subject($str) {
        $this->subject = '=?'.$this->charset.'?B?'.base64_encode($str).'?=';
        return $this;
    }

    /**
     * Sets letter's text
     *
     * @param string $str
     * @return Mailer
     */
    public function text($text) {
        $this->text = $text;
        return $this;
    }

    /**
     * Sets letter's html
     *
     * @param string $str
     * @return Mailer
     */
    public function html($html) {
        $this->html = '<html><head><meta http-equiv="Content-Type" content="text/html; charset='.$this->charset.'"></head><body>'.$html.'</body></html>';
        return $this;
    }

    /**
     * Adds attachment
     *
     * @param array $file
     * @return Mailer
     */
    public function attach($files) {
        if (!is_array($files)) {
            $files = array($files);
        }
        foreach ($files as $file) {
            if (!file_exists($file)) {
                throw new Exception('Attached file doesn\'t exsists ('.$file.')');
            }
            $path_parts = pathinfo($file);
            $filename = $path_parts['filename'].(array_value_not_empty($path_parts, 'extension') ? '.'.$path_parts['extension'] : '');
            $this->attachParsed($filename, trim(shell_exec("file -b --mime-type ".$file)), file_get_contents($file));
        }

        return $this;
    }

    /**
     * Adds attachment
     *
     * @param string $filename
     * @param string $type
     * @param string $content
     * @return Mailer
     */
    public function attachParsed($filename, $type, $content) {
        $attach = 'Content-Type: '.$type.'; name="'.$filename.'"'.self::EOL;
        $attach .= 'Content-Disposition: attachment; '.self::EOL.' filename="'.$filename.'"'.self::EOL;
        $attach .= 'Content-Transfer-Encoding: base64'.self::EOL.self::EOL;
        $attach .= chunk_split(base64_encode($content));

        $this->attachments[] = $attach;
        return $this;
    }

    /**
     * Sends letter
     *
     * @return void
     */
    public function send() {

        $mime_boundary1 = md5(time()).rand(1000,9999);
        $mime_boundary2 = md5(time()).rand(1000,9999);

        // headers
        $this->headers[] = 'From: '.$this->from;
        $this->headers[] = ($this->replyto) ? 'Reply-To: '.$this->replyto : 'Reply-To: '.$this->from;
        $this->headers[] = 'Return-Path: '.$this->from;
        if (!empty($this->cc)) {
            $this->headers[] = 'Cc: '.implode(',', $this->cc);
        }
        if (!empty($this->bcc)) {
            $this->headers[] = 'Bcc: '.implode(',', $this->bcc);
        }

        $letter = '';

        if (!empty($this->attachments)) {
            $this->headers[] = 'Content-Type: multipart/mixed; '.self::EOL.' boundary="'.$mime_boundary1.'"';
            // letter
            $letter .= "This is a multi-part message in MIME format.".self::EOL.self::EOL;
            $letter .= '--'.$mime_boundary1.self::EOL;
        }

        if (!empty($this->text) && !empty($this->html)) {
            if (empty($this->attachments)) {
                $this->headers[] = 'Content-Type: multipart/alternative; '.self::EOL.' boundary="'.$mime_boundary2.'"';
            } else {
                $letter .= 'Content-Type: multipart/alternative; '.self::EOL.' boundary="'.$mime_boundary2.'"'.self::EOL.self::EOL;
            }
            # Text Version
            $letter .= '--'.$mime_boundary2.self::EOL;
        }

        if (!empty($this->text)) {
            if (empty($this->attachments) && empty($this->html)) {
                $this->headers[] = 'Content-Type: text/plain; charset='.$this->charset;
                $this->headers[] = 'Content-Disposition: inline';
                $this->headers[] = 'Content-Transfer-Encoding: 8bit';
            } else {
                $letter .= 'Content-Type: text/plain; charset='.$this->charset.self::EOL;
                $letter .= 'Content-Disposition: inline'.self::EOL;
                $letter .= 'Content-Transfer-Encoding: 8bit'.self::EOL.self::EOL;
            }
            $letter .= $this->text.self::EOL.self::EOL;
        }

        if (!empty($this->text) && !empty($this->html)) {
            # HTML Version
            $letter .= '--'.$mime_boundary2.self::EOL;
        }

        if (!empty($this->html)) {
            if (empty($this->attachments) && empty($this->text)) {
                $this->headers[] = 'Content-Type: text/html; charset='.$this->charset;
                $this->headers[] = 'Content-Disposition: inline';
                $this->headers[] = 'Content-Transfer-Encoding: 8bit';
            } else {
                $letter .= 'Content-Type: text/html; charset='.$this->charset.self::EOL;
                $letter .= 'Content-Disposition: inline'.self::EOL;
                $letter .= 'Content-Transfer-Encoding: 8bit'.self::EOL.self::EOL;
            }
            $letter .= $this->html.self::EOL.self::EOL;
        }

        if (!empty($this->text) && !empty($this->html)) {
            $letter .= '--'.$mime_boundary2.'--'.self::EOL;
        }

        if (!empty($this->attachments)) {
            foreach ($this->attachments as $attach) {
                $letter .= '--'.$mime_boundary1.self::EOL;
                $letter .= $attach.self::EOL;
            }
            $letter .= '--'.$mime_boundary1.'--';
        }

        mail(implode(',', $this->to), $this->subject, $letter, implode(self::EOL, $this->headers));
        return  $this;
    }
}