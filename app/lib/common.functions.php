<?php

function time_elapsed_string($datetime, $full = false) {
    $now = new DateTime;
    $ago = new DateTime($datetime);
    $diff = $now->diff($ago);

    $diff->w = floor($diff->d / 7);
    $diff->d -= $diff->w * 7;

    $string = array(
        'y' => 'year',
        'm' => 'month',
        'w' => 'week',
        'd' => 'day',
        'h' => 'hour',
        'i' => 'minute',
        's' => 'second',
    );
    foreach ($string as $k => &$v) {
        if ($diff->$k) {
            $v = $diff->$k . ' ' . $v . ($diff->$k > 1 ? 's' : '');
        } else {
            unset($string[$k]);
        }
    }

    if (!$full) $string = array_slice($string, 0, 1);
    return $string ? implode(', ', $string) . ' ago' : 'just now';
}

function sec2min($sec, $sufix=false) {
    $min = (int) ((int)$sec / 60);
    $sec = (((int)$sec / 60) - $min)*60;

    $hour = 0;
    if ($min > 60) {
        $hour = (int) ((int)$min / 60);
        $min = (((int)$min / 60) - $hour)*60;
    }

    if ($sufix) {
        return ($hour?sprintf('%02d', $hour).'h:':'').sprintf('%02d', $min).'m:'.sprintf('%02d', $sec).'s';
    } else {
        return ($hour?sprintf('%02d', $hour).':':'').sprintf('%02d', $min).':'.sprintf('%02d', $sec).'';
    }
}

function pretty_bits($number, $sufix='') {
    return pretty_size($number, 1000, $sufix);
}
function pretty_bytes($number, $sufix='') {
    return pretty_size($number, 1024, $sufix);
}
function pretty_size($number, $quantifier=1000, $sufix='') {
    $prefixs = ($quantifier == 1000) ? array('k','M','G','T','P','E','Z','Y') : array('K','M','G','T','P','E','Z','Y') ;
    $i = 0;
    $prefix = '';
    while ($number > 900) {
        $number /= $quantifier;
        $prefix = ' '.$prefixs[$i++];
    }
    return round($number, 2).' '.$prefix.$sufix;
}

function array_value($array, $key, $default=NULL) {
    if (is_array($array) && array_key_exists($key, $array)) {
        return $array[$key];
    } else {
        return $default;
    }
}

function array_value_not_empty($array, $key, $default=NULL) {
	if (is_array($array) && array_key_exists($key, $array) && !empty($array[$key])) {
		return $array[$key];
	} else {
		return $default;
	}
}

function array_unshift_assoc(&$arr, $key, $val) {
    $arr = array_reverse($arr, true);
    $arr[$key] = $val;
    $arr = array_reverse($arr, true);
}

function array_push_assoc(&$arr, $key, $val) {
    $arr[$key] = $val;
}

function coalesce() {
    foreach(func_get_args() as $arg) {
        if ($arg) {
            return $arg;
        }
    }
    return null;
}

function array_to_text($data) {
    $str = '';
    if (is_array($data)) {
        $i = 0;
        foreach ($data as $k=>$d) {
            if (is_array($d)) {
                $str .= array_to_text($d);
            } else {
                $str .= $d;
                if (++$i != count($data)) {
                    $str .= "\t\t";
                }
            }
        }
        $str .= "\n";
    } else {
        $str .= $data."\n";
    }
    return $str;
}

function get_ip() {
    if (getenv("HTTP_CLIENT_IP")) {
        return getenv("HTTP_CLIENT_IP");
    } elseif(getenv("HTTP_X_FORWARDED_FOR")) {
        return getenv("HTTP_X_FORWARDED_FOR");
    } elseif(getenv("REMOTE_ADDR")) {
        return getenv("REMOTE_ADDR");
    } elseif(getenv("HTTP_X_REAL_IP")) {
        return getenv("HTTP_X_REAL_IP");
    }
    return null;
}
function get_referer() {
    if (getenv("HTTP_REFERER")) {
        return getenv("HTTP_REFERER");
    }
    return null;
}

function p($text) {
	echo "<pre>";
	print_r($text);
	echo "</pre>";
}
function v($text) {
    echo "<pre>";
    var_dump($text);
    echo "</pre>";
}
function d($text) {
	p($text);
	die();
}
function dv($var) {
	v($var);
	die();
}

function generate_password($length = 8) {
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $count = mb_strlen($chars);

    for ($i = 0, $result = ''; $i < $length; $i++) {
        $index = rand(0, $count - 1);
        $result .= mb_substr($chars, $index, 1);
    }

    return $result;
}


function log2file($indata, $filename, $def_size=10485760) {
    $text2wrt = '-- '.date("Y-m-j G:i:s");
    $text2wrt .= "\n";
    if (!is_array($indata)) {
        $indata = array('string'=>$indata);
    }

    $text2wrt .= "\n--- <[CDATA[ ---\n";
    foreach ($indata as $k=>$d) {
        if (is_array($d)) {
            $text2wrt .= $k.": ".print_r($d, true)."\n";
        } else {
            $text2wrt .= $k.": ".$d."\n";
        }
    }
    $text2wrt .= "\n--- CDATA]]> ---\n";

    $data['ip'] = get_ip();
    foreach ($data as $k=>$d) {
        if (is_array($d)) {
            $text2wrt .= $k.": ".print_r($d, true)."\n";
        } else {
            $text2wrt .= $k.": ".$d."\n";
        }
    }
    $text2wrt .= "\n-------\n";

    if (file_exists($filename) && filesize($filename) > $def_size) {
        rename($filename, $filename.'_'.date("Y-m-j_G:i:s").'.log');
    }
    if ($db2wrt = fopen($filename, 'a')) {
        fwrite($db2wrt, $text2wrt);
        fclose($db2wrt);
    }
}

function sprintf_array($subject, $replace, $pointer='%') {
    foreach ($replace as $key => $value) {
	if (!is_array($value)) {
        	$subject = str_replace($pointer.$key.$pointer, (string)$value, $subject);
	}
    }
    return $subject;
}

function rrmdir($dir) {
	$dir = rtrim($dir, '/').'/';
    if (!is_dir($dir)) {return false;}
    $files = array_diff(scandir($dir), array('.','..'));
    foreach ($files as $file) {
        (is_dir("$dir/$file")) ? rrmdir("$dir/$file") : unlink("$dir/$file");
    }
    return rmdir($dir);
}

function startsWith($haystack, $needle) {
    #return $needle === "" || strpos($haystack, $needle) === 0;
    $length = strlen($needle);
    return (substr($haystack, 0, $length) === $needle);
}
function endsWith($haystack, $needle) {
    #return $needle === "" || substr($haystack, -strlen($needle)) === $needle;
    $length = strlen($needle);
    if ($length == 0) {return true;}

    return (substr($haystack, -$length) === $needle);
}