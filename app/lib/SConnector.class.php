<?php
/**
 * Contains SConnector class
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2008-11
 */

################################################################################

/**
 * SConnector class
 *
 * @package Striped 3
 * @subpackage lib
 */
class SConnector {
    /**
     * Method POST
     *
     */
    const POST = 'POST';

    /**
     * Method GET
     *
     */
    const GET = 'GET';

    /**
     * Headers delimiter
     *
     */
    const EOHL = "\r\n";

    /**
     * Host name
     *
     * @var string
     * @access private
     */
    private $feed_hostname;

    /**
     * Path to feed
     *
     * @var string
     * @access private
     */
    private $feed_path;

    /**
     * Port number
     *
     * @var integer
     * @access private
     */
    private $feed_port;

    /**
     * connection timeout (seconds)
     *
     * @var integer
     * @access private
     */
    private $feed_timeout;

    /**
     * Connection method (get or post)
     *
     * @var string
     * @access private
     */
    private $feed_method = self::GET;

    /**
     * Default encoding
     *
     * @var string
     * @access private
     */
    private $feed_encoding = 'utf-8';

    /**
     * HTTP authorize data
     *
     * @var array
     * @access private
     */
    private $feed_auth = array();

    /**
     * Additional headers
     *
     * @var array
     * @access private
     */
    private $feed_headers = array();

    /**
     * Additional parameters
     *
     * @var array
     * @access private
     */
    private $feed_params = array();

    /**
     * Stream resorce
     *
     * @var resource
     * @access private
     */
    private $stream_pointer;

    /**
     * Constructor
     *
     * @param string $host hostname
     * @param string $path path to feed
     * @param integer[optional] $port port
     * @param integer[optional] $timeout timeout (seconds)
     * @access public
     * @return void
     */
    public function __construct($host, $path, $port=80, $timeout=30) {
        $this->feed_hostname = $host;
        $this->feed_path = $path;
        $this->feed_port = $port;
        $this->feed_timeout = $timeout;

        $this->setHeaders('Host', $host);
        $this->setHeaders('Connection', 'Close');
    }

    /**
     * Sets login and password for HTTP authorization
     *
     * @param string $username username
     * @param string $password password
     * @param string[optional] $type HTTP authorization type
     * @access public
     * @return void
     */
    public function setAuthData($username, $password, $type='Basic') {
        $this->feed_auth['username'] = $username;
        $this->feed_auth['password'] = $password;
        $this->feed_auth['type'] = $type;
        return $this;
    }

    /**
     * Sets additional parameters
     *
     * @param array $params [name]=>value
     * @access public
     * @return void
     */
    public function setParams(array $params) {
        foreach ($params as $name=>$value) {
            $this->setParam($name, $value);
        }
        return $this;
    }

    /**
     * Sets additional parameter
     *
     * @param string $name parameter name
     * @param string $value parameter value
     * @access public
     * @return void
     */
    public function setParam($name, $value) {
        $this->feed_params[$name] = $value;
        return $this;
    }

    /**
     * Sets additional headers
     *
     * @param string $name header name
     * @param string $value header value
     * @param boolean[optional] $overwrite overwrite existing header
     * @access public
     * @return void
     */
    public function setHeaders($name, $value, $overwrite=true) {
        if (!isset($this->feed_headers[$name]) || $overwrite) {
            $this->feed_headers[$name] = $value;
        }
        return $this;
    }

    /**
     * Sets connection method
     *
     * @param string $method method type
     * @access public
     * @return void
     */
    public function setMethod($method) {
        $this->feed_method = $method;
        return $this;
    }

    /**
     * Connects to the server
     *
     * @access public
     * @param [optional]bool $return_only_body
     * @param [optional]bool $result_is_xml
     * @return void
     */
    public function connect($return_only_body=false, $result_is_xml=false) {

        /* connecting to remote server */
        if (!@is_resource($this->stream_pointer = fsockopen($this->feed_hostname, $this->feed_port, $errno, $errstr, $this->feed_timeout))) {
            throw new Exception('Could not connect to the remote server. '.$errno.': '.$errstr);
        }

        /* creates parameters string, if any exist */
        if (!empty($this->feed_params)) {
            foreach ($this->feed_params as $key => $value) {
                $param[] = $key.'='.$value;
            }
            $params = implode('&', $param);
        }

        /* in order of connection type we create headers and seting up parameters */
        if ($this->feed_method == self::POST) {
            $output[] = 'POST '.$this->feed_path.' HTTP/1.1';
            if (isset($params)) {
                $output[] = 'Content-Type: application/x-www-form-urlencoded';
                $output[] = 'Content-Length: '.strlen($params);
                $output[] = $params;
            }
        } else {
            $output[] = "GET ".$this->feed_path;
            end($output);
            $current_key = key($output);
            if (isset($params)) {
                $output[$current_key] .= '?'.$params;
            }
            $output[$current_key] .= " HTTP/1.1";
        }

        /* adding authorization if special parameters are given */
        if (!empty($this->feed_auth)) {
            $output[] = 'Authorization: '.$this->feed_auth['type'].' '.base64_encode($this->feed_auth['username'].':'.$this->feed_auth['password']);
        }

        /* geathering addition parameters */
        if (!empty($this->feed_headers)) {
            foreach ($this->feed_headers as $key => $value) {
                $header[] = $key.': '.$value;
            }
            $output[] = implode(self::EOHL, $header);
        }

        /* ending "EOL" symbol for headers */
        $output[] = self::EOHL;

        /* imploding output and writing to opened socket */
        if (!fwrite($this->stream_pointer, implode(self::EOHL, $output))) {
            throw new Exception('Error while writing into resorce.');
        }

        $contents = '';
        while (!feof($this->stream_pointer)) {
          $contents .= fread($this->stream_pointer, 8192);
        }

        if (!fclose($this->stream_pointer)) {
            throw new Exception('Error while disconnecting resourse.');
        }
        log2file($contents, 'log/sconnector.log');

        if ($return_only_body) {
            $result = $this->prepare($contents, $result_is_xml);
            return $result['body'];
        } else {
            return $this->prepare($contents, $result_is_xml);
        }
    }

    /**
     * Breaks up retrieved data as headers and body.
     *
     * @param string $data retrieved data
     * @param string[otional] $result_is_xml if set - provides additional cleaning
     * @access private
     * @return array
     */
    private function prepare($data, $result_is_xml = false) {
        $dataset = preg_split('/'.self::EOHL.self::EOHL.'/', trim($data), 2);

        $last = '';
        $formed_headers = array();
        foreach (preg_split('/'.self::EOHL.'/', $dataset[0]) as $value) {
            $splited_header = preg_split('/:/', $value, 2);
            $hname = strtolower(trim($splited_header[0]));
            if (isset($splited_header[1])) {
                $hvalue = trim($splited_header[1]);
            } else {
                $hvalue = '';
            }

            if (!preg_match('/^\s/', $value) && !isset($formed_headers[$hname])) {
                $formed_headers[$hname] = $hvalue;
                $last = $hname;
            } elseif(!preg_match('/^\s/', $value) && isset($formed_headers[$hname])) {
                if (is_array($formed_headers[$hname])) {
                    $formed_headers[$hname][] = $hvalue;
                } else {
                    $formed_headers[$hname] = array($formed_headers[$hname], $hvalue);
                }
                $last = $hname;
            } else {
                if (is_array($formed_headers[$last])) {
                    $formed_headers[$last][] = trim($value);
                } else {
                    $formed_headers[$last] = array($formed_headers[$last], trim($value));
                }
            }
        }
        $outdata['headers'] = $formed_headers;

        if (isset($dataset[1])) {

            if (!isset($outdata['headers']['content-disposition']) && isset($outdata['headers']['content-type'])) {
                $c_type = explode(';', is_array($outdata['headers']['content-type']) ? implode(' ', $outdata['headers']['content-type']) : $outdata['headers']['content-type']);
                if (trim($c_type[0]) == 'multipart/mixed' || trim($c_type[0]) == 'multipart/alternative') {
                    $boundary = trim(str_replace('boundary=', '', trim($c_type[1])));
                } else {
                    $outdata['mime'] = $c_type[0];
                }
            }

            if (isset($boundary)) {
                $bodys = explode('--'.$boundary, $dataset[1]);

                foreach ($bodys as $body) {
                    if (!empty($body) && strpos($body, '--') !== 0) {
                        $outdata['body'][] = $this->prepare($body, false);
                    }
                }

            } else {
                if ($result_is_xml) {
                    $iter = preg_replace('/^[^<]*<\?xml [^\(?>)]*\?>\n?/', '', $dataset[1], 1);
                    $outdata['body'] = preg_replace('/[^>]*$/', '', $iter, 1);
                } else {
                    $outdata['body'] = $dataset[1];
                }
                if (isset($outdata['headers']['content-transfer-encoding']) && trim($outdata['headers']['content-transfer-encoding']) === 'base64') {
                    $outdata['body'] = base64_decode($outdata['body']);
                } elseif (isset($outdata['headers']['content-transfer-encoding']) && trim($outdata['headers']['content-transfer-encoding']) === 'quoted-printable') {
                    $outdata['body'] = quoted_printable_decode($outdata['body']);
                }
                if (isset($outdata['headers']['content-disposition'])) {
                    $outdata['attachment'] = true;
                    $matches = array();
                    preg_match('/filename="?([^";]*)"?;?$/',(is_array($outdata['headers']['content-disposition']))?implode(' ', $outdata['headers']['content-disposition']):$outdata['headers']['content-disposition'],$matches);
                    if (isset($matches[1])) {
                        mb_internal_encoding("UTF-8");
                        $outdata['filename'] = mb_decode_mimeheader($matches[1]);
                    }
                }

                if (isset($outdata['headers']['content-type'])) {
                    $matches = array();
                    preg_match('/charset="?([^";]*)"?;?$/',(is_array($outdata['headers']['content-type']))?implode(' ', $outdata['headers']['content-type']):$outdata['headers']['content-type'],$matches);
                    if (isset($matches[1]) && strtolower($matches[1]) !== 'utf-8' && strtolower($matches[1]) !== 'utf8') {
                        $outdata['body'] = iconv($matches[1], 'utf-8', $outdata['body']);
                    }
                }
            }
        } else {
            $outdata['body'] = '';
        }
        return $outdata;
    }
}
