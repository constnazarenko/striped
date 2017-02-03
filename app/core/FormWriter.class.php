<?php
/**
 * Contains FormWriter class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2009-14
 * @version $Id: FormWriter.class.php 25 2011-01-20 17:07:43Z tigra $
 */

require_once('striped/app/core/Translater.class.php');
require_once('striped/app/lib/ClearedXMLElement.class.php');
require_once('striped/app/lib/Validator.class.php');
require_once('striped/app/lib/XMLTreeWriter.class.php');

################################################################################

/**
 * Builds and validates forms
 * FormWriter class
 *
 * @package Striped 3
 * @subpackage core
 */
class FormWriter {
    /**
     * Name of the form (identifier for descriptor file)
     *
     * @var string
     * @access private
     */
    private $descriptor_name = null;

    /**
     * Path to directory
     *
     * @var string
     * @access private
     */
    private $path_to_fdf = 'forms/';

    /**
     * Path to system directory
     *
     * @var string
     * @access private
     */
    private $path_to_sys_fdf = 'striped/forms/';

    /**
     * Form descriptor extension
     *
     * @var string
     * @access private
     */
    private $ext = '.xml';

    /**
     * Form data
     *
     * @var array
     * @access private
     */
    private $formdata = array();

    /**
     * Form descriptor string
     *
     * @var string
     * @access private
     */
    private $descriptor = false;

    /**
     * Errors duplicator
     *
     * @var array
     * @access private
     */
    private $errors = false;

    /**
     * Confirms duplicator
     *
     * @var array
     * @access private
     */
    private $confirms = false;

    /**
     * Form data
     *
     * @var array
     * @access private
     */
    private $_data = array();

    /**
     * Form confirms
     *
     * @var array
     * @access private
     */
    private $_data_confirms = array('nodename' => 'confirm');

    /**
     * Form errors
     *
     * @var array
     * @access private
     */
    private $_data_errors = array('nodename' => 'error');

    /**
     * Submited data
     *
     * @var array
     * @access private
     */
    private $_submited_data = array();

    /**
     * Multioptions data
     *
     * @var array
     * @access private
     */
    private $_multioptions = array();

    /**
     * Disabled options
     *
     * @var array
     * @access private
     */
    private $disabled_options = array();

    /**
     * Form data
     *
     * @var array
     * @access private
     */
    private $_validdata = array();

    /**
     * Form was processed already
     *
     * @var array
     * @access private
     */
    private $processed = false;

    /**
     * Last used group
     *
     * @var string
     * @access private
     */
    private $last_group;

    /**
     * Constructor
     *
     * @param string $name form descriptor name
     * @param string[optional] $lang current language
     * @access public
     * @return void
     */
    public function __construct($name) {
        $this->descriptor_name = $name;
        $ion = (function_exists('ioncube_file_is_encoded') && ioncube_file_is_encoded());
        $n_loc = $this->path_to_fdf.$this->descriptor_name.$this->ext;
        $n_core = $this->path_to_sys_fdf.$this->descriptor_name.$this->ext;
        if (file_exists($n_loc)) {
            $n = $n_loc;
        } elseif (file_exists($n_core)) {
            $n = $n_core;
        } else {
            throw new Exception("Form description file (".$this->descriptor_name.") doesn't exists!");
        }
        $this->descriptor = !$ion ? file_get_contents($n) : ioncube_read_file($n) ;

        //inserting form name
        $form = simplexml_load_string($this->descriptor, 'ClearedXMLElement');
        $dom = dom_import_simplexml($form);
        $dom->setAttribute('name', $name);
        $this->descriptor = $form->asXML();
        $this->set_groupname('main');
    }

    /**
     * Gets content from the form description file
     *
     * @param boolean $simplexml if true - returns SmipleXML object, else - string
     * @access public
     * @return SimpleXMLElement
     */
    public function get_form_descriptor($simplexml=false) {
        if (!$simplexml) {
            return preg_replace('/<\?xml.*\?>/', '', $this->descriptor);
        } else {
            return simplexml_load_string($this->descriptor, 'ClearedXMLElement');
        }
        return false;
    }


    /**
     * Sets current group name
     *
     * @access public
     * @return array
     */
    public function set_groupname($name) {
        $this->last_group = $name;
    }

    /**
     * Removes field from form
     *
     * @param string $field field name
     * @param string $group group name
     * @return void
     */
    public function remove_field($field, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        $form = simplexml_load_string($this->descriptor, 'ClearedXMLElement');
        $remove = $form->xpath("//fieldgroup[@name = '".$group."']/field[@name = '".$field."']");
        if(count($remove) > 0) {
            $dom = dom_import_simplexml($remove[0]);
            $dom->parentNode->removeChild($dom);
            $this->descriptor = $form->asXML();
        }
    }

    /**
     * Adds submited for field
     *
     * @param string $name field name
     * @param mixed $data field value
     * @param string $group fieldgroup name
     * @access private
     * @return void
     */
    private function add_submited_data($name, $data, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        if (empty($name) || !is_string($name)) {
            throw new Exception('Wrong name of added data to from!');
        }
        $this->_submited_data[$group][$name] = $data;
    }

    /**
     * Adds data for field
     *
     * @param string $name field name
     * @param mixed $data field value
     * @param mixed $checked checked values
     * @param string $group fielgroup name
     * @access public
     * @return void
     */
    public function add_field_data($name, $data, $checked=array(), $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        if (empty($name) || !is_string($name)) {
            throw new Exception('Wrong name of added data to from!');
        }
        if (is_array($data)) {
            $this->add_field_options($name, $data, $group, $checked);
        } else {
            $this->add_field_value($name, $data, $group);
        }
    }

    /**
     * Adds options for field
     *
     * @param string $name field name
     * @param array[strict] $options field values
     * @param string $group fielgroup name
     * @param mixed $checked checked values
     * @access private
     * @return void
     */
    private function add_field_options($name, array $options, $group, $checked) {
        if (!$group) {
            $group = $this->last_group;
        }
        $select = array('nodename' => 'option');
        $opts = array();
        $grid = 0;
        if (isset($this->_submited_data[$group][str_replace('[]', '', $name)])) {
            $checked = $this->_submited_data[$group][str_replace('[]', '', $name)];
        }
        if (!is_array($checked)) {
            $checked = array($checked);
        }
        $disabled_options = array();
        if (isset($this->disabled_options[$group][str_replace('[]', '', $name)])) {
            $disabled_options = $this->disabled_options[$group][str_replace('[]', '', $name)];
        }
        if (!is_array($disabled_options)) {
            $disabled_options = array($disabled_options);
        }
        foreach ($options as $key => $value) {
            if (is_array($value)) {
                $opts[$grid]['attr'] = array('label'=>$key);
                $opts[$grid]['selfname'] = 'optgroup';
                foreach ($value as $grkey => $grvalue) {
                    $output = array('attr' => array('value'=>$grkey), 'selftext'=>$grvalue);
                    if (!empty($checked)) {
                        foreach ($checked as $ck => $cv) {
                            if ($cv == $grkey) {
                                $output['attr']['checked'] = 1;
                                $output['attr']['weight'] = $ck;
                            }
                        }
                    }
                    if (!empty($disabled_options) && in_array($grkey, $disabled_options)) {
                        $output['attr']['disabled'] = 1;
                    }
                    $opts[$grid][] = $output;
                }
                $grid++;
            } else {
                $output = array('attr' => array('value'=>$key), 'selftext'=>$value);
                if (!empty($checked)) {
                    foreach ($checked as $ck => $cv) {
                        if ($cv == $key) {
                            $output['attr']['checked'] = 1;
                            $output['attr']['weight'] = $ck;
                        }
                    }
                }
                if (!empty($disabled_options) && in_array($key, $disabled_options)) {
                    $output['attr']['disabled'] = 1;
                }
                $opts[] = $output;
            }
        }

        if (!empty($opts)) {
            if (!isset($this->_data[$group][$name])) {
                $this->_data[$group][$name]['attr'] = array('name'=>$name);
            }

            $result = array_merge($select, $opts);
            $this->_data[$group][$name]['options'] = $result;
        }
    }

    /**
     * Adds checker for options
     *
     * @param string $name field name
     * @param mixed $checked checked values
     * @param string[optional] $group fielgroup name
     * @access public
     * @return void
     */
    public function add_checked_options($name, $checked, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        $this->_submited_data[$group][$name] = $checked;
    }

    /**
     * Adds checker for multioptions
     *
     * @param string $name field name
     * @param mixed $checked checked values
     * @param string[optional] $group fielgroup name
     * @access public
     * @return void
     */
    public function add_checked_multioptions($name, $checked, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        $this->_multioptions[$group][$name] = $checked;
    }

    /**
     * Adds disabled options
     *
     * @param string $name field name
     * @param mixed $checked checked values
     * @param string[optional] $group fielgroup name
     * @access public
     * @return void
     */
    public function add_disabled_options($name, $disabled, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        if (!is_array($disabled)) {
            $disabled = array($disabled);
        }
        $this->disabled_options[$group][str_replace('[]', '', $name)] = $disabled;
    }

    /**
     * Adds value for field
     *
     * @param string $name field name
     * @param mixed $value field value
     * @param string $group fielgroup name
     * @access private
     * @return void
     */
    private function add_field_value($name, $value, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        if (!isset($this->_data[$group][$name])) {
            $this->_data[$group][$name]['attr'] = array('name'=>$name);
        }
        $this->_data[$group][$name]['value'] = $value;
    }

    /**
     * Returns formdata array
     *
     * @access public
     * @return array
     */
    public function get_form_data() {
        if (isset($this->_data)) {
            foreach ($this->_data as $group => &$fieldgroup) {
                $fieldgroup = array_values($fieldgroup);
                $fieldgroup['nodename'] = 'field';
                $fieldgroup['attr'] = array('name' => $group);
            }
            $this->_data = array_values($this->_data);
            $this->_data['nodename'] = 'fieldgroup';
        }

        return $this->_data;
    }


    /**
     * Returns current group name
     *
     * @access public
     * @return array
     */
    public function get_groupname() {
        return $this->last_group;
    }

    /**
     * Returns from confirms array
     *
     * @access public
     * @return array
     */
    public function get_form_confirms() {
        return $this->_data_confirms;
    }

    /**
     * Returns from errors array
     *
     * @access public
     * @return array
     */
    public function get_form_errors() {
        return $this->_data_errors;
    }


    /**
     * Returns multioptions array
     *
     * @access public
     * @return array
     */
    public function get_multioptions() {
        $multioptions = array();
        $multioptions['nodename'] = 'group';
        foreach ($this->_multioptions as $group => $fieldgroup) {
            $multioptions[$group]['nodename'] = 'field';
            $multioptions[$group]['attr'] = array('name' => $group);

            foreach ($fieldgroup as $field => $values) {
                foreach ($values as $v) {
                    $multioptions[$group][] = array('attr' => array('name' => $field) + $v);
                }
            }

        }

        return $multioptions;
    }

    /**
     * Adds confirm message to the form
     *
     * @param string $message
     * @param string[optional] $field name. if mentioned confirm will be associated with this field
     * @param string[optional] $group fieldgroup name
     * @access public
     * @return void
     */
    public function add_confirm($message, $field=null, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        $confirm = array(
            'selftext' => (string) $message
        );
        if (is_string($field) && !empty($field)) {
            $confirm['attr']['field'] = (string) $field;
        }
        $confirm['attr']['group'] = (string) $group;
        $this->confirms[] = array('message' => $message, 'field' => $field);
        $this->_data_confirms[] = $confirm;
    }

    /**
     * Adds error message to the form
     *
     * @param string $message
     * @param string[optional] $field name. if mentioned error will be associated with this field
     * @param string[optional] $group fieldgroup name
     * @access public
     * @return void
     */
    public function add_error($message, $field=null, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        $error = array(
            'message' => (string) $message
        );
        if (!is_array($field)) {$field = array($field);}
        foreach ($field as $f) {
            if (is_string($f) && !empty($f)) {
                $error['fields'][] = (string) $f;
            }
        }
        if (isset($error['fields'])) {$error['fields']['nodename'] = 'field';}
        $error['attr']['group'] = (string) $group;
        $this->errors[] = array('message' => $message, 'field' => $field);
        $this->_data_errors[] = $error;
    }

    /**
     * Checks if there was form submited && valid form data sent
     * and returns recieved valid data
     *
     * @param array $data submited form data
     * @param string[optional] $group fieldgroup name
     * @access public
     * @return bool|array
     */
    public function get_valid_data_if_form_sent($data, $group=null, $all=false) {
        if ($this->is_form_sent($data) && $all) {
            foreach (array_keys($data['group']) as $group) {
                $this->is_form_valid($data, $group);
            }
            return $this->get_valid_data();
        } elseif ($this->is_form_sent($data) && !$group) {
            if ($this->is_form_valid($data, $this->last_group)) {
                return $this->get_valid_data();
            } else {
                return false;
            }

        } elseif (isset($data['formname']) && $data['formname'] == $this->descriptor_name && isset($data['group']) && $group && $this->is_form_valid($data, $group)) {
            return $this->get_valid_data($group);
        }
        return false;
    }


    /**
     * Checks if there was form submited && valid form data sent
     *
     * @param array $data submited form data
     * @param string[optional] $group fieldgroup name
     * @access public
     * @return bool|array
     */
    public function is_form_proccessed() {
        return $this->processed;
    }


    /**
     * Checks if there was form submited && valid form data sent
     *
     * @param array $data submited form data
     * @param string[optional] $group fieldgroup name
     * @access public
     * @return bool|array
     */
    public function is_form_sent($data) {
        if (isset($data['formname']) && $data['formname'] == $this->descriptor_name && isset($data['group'])) {
            $this->processed = true;
            return true;
        }
        return false;
    }


    /**
     * Validates form
     *
     * @param array $data submited form data
     * @param string[optional] $group fieldgroup name
     * @access public
     * @return bool
     */
    public function is_form_valid($data, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        $valid = true;
        $form = $this->get_form_descriptor(true);
        $fields = $form->xpath('//fieldgroup/field');#[@name="'.$group.'"]
        if (empty($fields)) {
            throw new Exception('Fieldgroup doesn\'t exists ('.$group.')');
        }
        #$this->last_group = $group;

        /* checking fields */
        foreach ($fields as $field) {
            if (isset($ident)) {
                unset($ident);
            }
            if (isset($value)) {
                unset($value);
            }

            if (!$field->attr('name')) {
                continue;
            }
            $validField = true;

            $name = (string) $field->attr('name');
            $regexp = '/\[([^\]]*)\]/';
            preg_match($regexp, $name, $subname);
            if (isset($subname[1]) && !empty($subname[1])) {
                $sname = preg_replace($regexp, '', $name);
                $ident = $subname[1];
                $value = $data[$sname][$group][$ident];
                $fname = $name;
            } else {
                $fname = str_replace('[]', '', $name);
                if (isset($data[$fname][$group])) {
                    $value = $data[$fname][$group];
                }
            }

            /* validating required fields */
            if (
                $field->attr('required', 'bool')
                &&
                 (
                   (($field->attr('type') != 'file') && (!isset($value) || $value === ''))
                   ||
                   (
                     $field->attr('type') == 'file'
                     &&
                     (
                       (!isset($_FILES[$fname]['name']) || empty($_FILES[$fname]['name']))
                       ||
                       (isset($_FILES[$fname]['name'][0]) && empty($_FILES[$fname]['name'][0]))
                     )
                   )
                 )
               ) {
                $this->add_error(sprintf($this->translate('frm_err_required'), (!empty($field->title)) ? $this->translate($field->title) : $fname ), $name, $group);
                $validField = false;
            }

            /* validating captcha */
            if ($field->attr('type') == 'captcha' && (!isset($_SESSION['captcha_keystring']) || !isset($value) || $_SESSION['captcha_keystring'] !== $value)) {
                $this->add_error(sprintf($this->translate('frm_err_captcha'), (!empty($field->title)) ? $this->translate($field->title) : $fname ), $name, $group);
                $validField = false;
            } elseif ($field->attr('type') == 'captcha') {
                unset($_SESSION['captcha_keystring']);
            }

            /* validating linked fields */
            if ($validField && $field->attr('linkedto') && (!isset($data[$field->attr('linkedto')][$group]) || $data[$field->attr('linkedto')][$group] !== $value)) {
                $linked_title = $form->xpath('//field[@name="'.$field->attr('linkedto').'"]/title');
                $this->add_error(sprintf($this->translate('frm_err_linked'), $this->translate($field->title), $this->translate($linked_title[0])), $name, $group);
                $validField = false;
            }

            /* validating fields by patterns */
            if ($validField && isset($value) && $value !== '' && isset($field->patterns->pattern)) {
                foreach ($field->patterns->pattern as $pattern) {
                    if (!isset($pattern['preset'])) {
                        throw new Exception('Unknown preset for "' . $name . '" field in "' . $this->descriptor_name . '" form');
                    }
                    $preset = (string) $pattern['preset'];

                    if (method_exists('Validator', $preset)) {
                        $params = array();
                        foreach ($pattern->item as $item) {
                            $params[] = $item->val();
                        }
                        if (($valid_value = Validator::$preset($value, $params)) === false) {
                            $validField = false;
                            if (isset($pattern['message'])) {
                                $this->add_error($this->sprintf_array($this->translate((string) $pattern['message']), array_merge(array('title'=>$this->translate($field->title)), $params)), $fname, $group);
                            } else {
                                $this->add_error('Unknow error', $fname, $group);
                            }
                            break;
                        } else {
                            $value = $valid_value;
                        }
                    } else {
                        $validField = false;
                        $this->add_error('Unknown validator "'.$preset.'"', $fname, $group);
                        break;
                    }
                }
            }
            $valid = $validField && $valid;

            if (!isset($value) && $field->attr('type') == 'checkbox') {
                $this->_validdata[$group][$fname] = 0;
                continue;
            } elseif (!isset($value) || ($field->attr('type') == 'select' && $value === '') || $field->attr('type') == 'captcha') {
                $this->add_submited_data($fname, '', $group);
                continue;
            }

            $this->add_field_data($fname, $value, array(), $group);
            $this->add_submited_data($fname, $value, $group);
            if ($valid && isset($ident)) {
                $this->_validdata[$group][$sname][$ident] = $value;
            } elseif ($valid) {
                $this->_validdata[$group][$fname] = $value;
            }
        }
        return $valid;
    }

    /**
     * Replaces occurances in string
     *
     * @param string $str subject
     * @param array $args replace
     * @param string[optional] $pointer
     * @access private
     * @return string
     */
    private function sprintf_array($str, $args, $pointer='%') {
        foreach ($args as $key => $value) {
            $str = str_replace($pointer.$key, (string)$value, $str);
        }
        return $str;
    }

    /**
     * Returns valid data array
     *
     * @access public
     * @return array
     */
    public function get_valid_data($group=null) {
        if ($group) {
            return $this->_validdata[$group];
        } elseif (count($this->_validdata) == 1) {
            return end($this->_validdata);
        } else {
            return $this->_validdata;
        }
    }

    /**
     * Returns field title by name
     *
     * @param string $name
     * @param string[optional] $group fieldgroup name
     * @access public
     * @return string
     */
    public function get_field_title($name, $group=null) {
        if (!$group) {
            $group = $this->last_group;
        }
        $descriptor = $this->get_form_descriptor(true);
        $title = $descriptor->xpath('/form/fieldgroup[@name="'.$group.'"]/field[@name="'.$name.'"]/title');
        return $title[0]->val();
    }

    /**
     * Returns error messages
     *
     * @access public
     * @param [optional]bool $text_only
     * @return array
     */
    public function get_errors($text_only=false) {
        if (!$text_only) {
            return $this->errors;
        } else {
            $errors = array();
            foreach ($this->errors as $error) {
                $errors[] =  $error['message'];
            }
            return $errors;
        }
    }

    /**
     * Returns true if occured some error
     *
     * @access public
     * @return bool
     */
    public function has_error() {
        return $this->errors;
    }

    /**
     * Returns confirm messages
     *
     * @access public
     * @param [optional]bool $text_only
     * @return array
     */
    public function get_confirms($text_only=false) {
        if (!$text_only) {
            return $this->confirms;
        } else {
            $confirms = array();
            foreach ($this->confirms as $confirm) {
                $confirms[] =  $confirm['message'];
            }
            return $confirms;
        }
    }

    /**
     * Writes formblock with all data inside
     *
     * @access public
     * @param string action
     * @return void
     */
    public function writeFormBlock($action=null) {
        $xml = XMLTreeWriter::instance();
        $xml->startElement('formblock');
            if ($action) {
                $xml->writeAttribute('action', $action);
            }
            $xml->writeRaw($this->get_form_descriptor());
            $xml->writeTree('formdata', $this->get_form_data());
            $xml->writeTree('confirms', $this->get_form_confirms());
            $xml->writeTree('errors', $this->get_form_errors());
            $xml->writeTree('multioptions', $this->get_multioptions());
        $xml->endElement();

        $descriptor = $this->get_form_descriptor(true);

        $wysiwyg = (boolean) $descriptor->xpath("/form/fieldgroup/field[@wysiwyg]");
        $autocomplete = (boolean) $descriptor->xpath("/form/fieldgroup/field[@autocomplete]");
        $chosen = (boolean) $descriptor->xpath("/form/fieldgroup/field[@chosen]");
        $validate = (boolean) $descriptor->xpath("/form[@ajax = 'validate' or @ajax = 'ajax' or @ajax = 'textmode']");
        $editables = (boolean) $descriptor->xpath("/form[@ajax = 'textmode' or @ajax = 'textmode-w-v']");
        $multifiles = (boolean) $descriptor->xpath("/form/fieldgroup/field[(@type='file' or @type='text' or @type='amount-select') and @multiple='1']");

        $xml->startElement('jss');
        	$xml->writeElement('js', 'striped/js/jquery.form.js');
        	if ($wysiwyg) {
        		$xml->writeElement('js', 'striped/js/tiny_mce/jquery.tinymce.js');
        		$xml->writeElement('js', 'striped/js/wysiwyg.js');
        		$xml->writeElement('js', 'js/wysiwyg.js');
        	}
        	if ($autocomplete) {
        		$xml->writeElement('js', 'striped/js/jquery.autocomplete.js');
        	}
        	if ($validate) {
        		$xml->writeElement('js', 'striped/js/jquery.validate.min.js');
        		$xml->writeElement('js', 'striped/js/jquery.validate.js');
        	}
        	if ($editables) {
        		$xml->writeElement('js', 'striped/js/jquery.editables.js');
        	}
        	if ($multifiles) {
        		$xml->writeElement('js', 'striped/js/jquery.multifiles.js');
        	}
            if ($chosen) {
                $xml->writeElement('js', 'striped/js/chosen.jquery.min.js');
                $xml->writeElement('js', 'striped/js/chosen.order.jquery.min.js');
            }
        $xml->endElement();

        if ($chosen) {
            $xml->startElement('csss');
            $xml->writeElement('css', 'striped/css/chosen.min.css');
            $xml->endElement();
        }
    }

    /**
     * Retranslates to Translater::translate()
     *
     * @access private
     * @param string $keyword
     * @return string
     */
    private function translate($keyword) {
        return Translater::instance()->translate($keyword);
    }

}