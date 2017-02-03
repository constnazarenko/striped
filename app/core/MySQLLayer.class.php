<?php
/**
 * Contains MySQLLayer class
 *
 * @package Striped 3
 * @subpackage core
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2013-14
 */

require_once('striped/app/core/CoreException.class.php');
require_once('striped/app/core/XMLEtc.class.php');

################################################################################

/**
 * MySQL database layer
 *
 * @package Striped 3
 * @subpackage core
 */
class MySQLLayer {
    /**
     * SQL link resource
     *
     * @var resource
     * @access private
     */
    private $link;

    /**
     * SQL result resource
     *
     * @var resource
     * @access private
     */
    private $result;

    /**
     * SQL query log
     *
     * @var array
     * @access private
     */
    private $query_log;

    /**
     * MySQLLayer instance
     *
     * @var MySQLLayer
     * @static
     * @access private
     */
    private static $instance;

    /**
     * SQL constants not for quoting
     *
     * @var array
     * @access private
     */
    private $sql_constants = array("NULL","TRUE","FALSE");


    /**
     * Constructor
     *
     * @access private
     * @return void
     */
    private function __construct() {
        $this->connect();
    }

    /**
     * Connects to the database server and selects the database if mentioned
     *
     * @param string $connection_string
     * @param int[optional] $port
     * @param string[optional] $encoding
     * @access protected
     * @return resource
     */
    public function connect() {
        if (!function_exists('mysqli_connect')) {
            throw new Exception('You have no MySQL PHP-connector.');
        }
        
        $xmletc = new XMLEtc('database');
        $etc = $xmletc->get();

        if (!$this->link = mysqli_connect($etc->mysql->host->val(), $etc->mysql->username->val(), $etc->mysql->password->val(), $etc->mysql->dbname->val(), $etc->mysql->port->val())) {
            throw new Exception('Error while connecting to the database server! '.mysqli_connect_errno());
        }
        unset($xmletc);
        unset($etc);

        $this->query("SET NAMES utf8;");
    }

    
    /**
     * Closes connection
     *
     * @access public
     * @return mixed
     */
    public function disconnect() {
        if ($this->link) {
            return mysqli_close($this->link);
        } else {
            return false;
        }
    }

    /**
     * Executes query and logs results
     *
     * @param string $query
     * @access public
     * @return resource
     */
    public function query($query) {
        $start_time = microtime(true);
        if (!$this->result = @mysqli_query($this->link, $query)) {
            throw new CoreException('Invalid MySQL query!', CoreException::ERR_DBMS, array($query, $this->error()));
        } else {
            $this->query_log[] = array('body'=>$query, 'time'=>(microtime(true) - $start_time), 'affected_rows'=>($this->affectedRows()), 'num_rows'=>($this->numRows()));
        }
        return $this->result;
    }

    /**
     * Executes query and logs results
     *
     * @param string $query
     * @param array[optional] $params
     * @access public
     * @return resource
     */
    public function pquery($query, $params=array()) {
        array_walk($params, array($this, 'quoteByReference'));
        $i = count($params);

        foreach (array_reverse($params) as $p) {
            $query = str_replace('$'.$i, $p, $query);
            $i -= 1;
        }

        return $this->query($query);
    }

    /**
     * Fetches result
     *
     * @param bool[optional] $assoc fetch type
     * @param bool[optional] $all only first occurance if false
     * @param string[optional] $name only this column sellected if is set
     * @access private
     * @return array
     */
    private function fetch($assoc=true, $all=true, $name=null) {
        if (!$this->checkResource()) {
            #throw new CoreException('Invalid MySQL resource!', CoreException::ERR_DBMS);
        }

        $fetch_func = 'mysqli_fetch';
        if ($assoc) {
            $fetch_func .= '_assoc';
        } else {
            $fetch_func .= '_array';
        }

        if ($all) {
            $result = array();
            while ($line = $fetch_func($this->result)) {
                if ($name !== null && isset($line[$name])) {
                   $result[] = $line[$name];
                } elseif ($name === null) {
                    $result[] = $line;
                }
            }
        } else {
            $result = $fetch_func($this->result);
            if ($name !== null) {
                $result = (isset($result[$name])) ? $result[$name] : false;
            }
        }

        return $result;
    }


    /**
     * Returns SQL error
     *
     * @access private
     * @return string
     */
    private function error() {
        if ($this->link) {
            return mysqli_error($this->link);
        } else {
            return false;
        }
    }

    /**
     * Prepares value to be added in SQL query
     *
     * @access public
     * @param string $value
     * @param string[optional] $type [string|str|array|integer|int|boolean|bool|float|double|timestamp]
     * @return mixed
     */
    public function quote($value, $type=null) {
        if (!$this->link) return false;
        if (in_array($value, $this->sql_constants)) {
            return $value;
        } elseif ($type != null) {
            switch ($type) {
                case 'function':
                    return $value;
                case 'integer':
                case 'int':
                    if (empty($value)) {
                        return 'NULL';
                    } else {
                        return (int)$value;
                    }
                case 'boolean':
                case 'bool':
                    if (empty($value)) {
                        return 'FALSE';
                    } else {
                        return 'TRUE';
                    }
                case 'float':
                    return (float)$value;
                case 'double':
                    return (double)$value;
                case 'timestamp':
                case 'array':
                case 'string':
                case 'str':
                default:
                    return "'".mysqli_escape_string($this->link, str_replace("\r",'',$value))."'";
            }
        } elseif (is_int($value)) {
            return (int)$value;
        } else {
            return "'".mysqli_escape_string($this->link, str_replace("\r",'',$value))."'";
        }
    }

    /**
     * Prepares value to be added in SQL query
     * By reference
     *
     * @param string $value
     * @access public
     * @return mixed
     */
    public function quoteByReference(&$value, $key) {
        $k = explode('::', $key);
        if (count($k) > 1) {
            $type = $k[1];
        } else {
            $type = null;
        }
        $value = $this->quote($value, $type);
    }

    /**
     * Prepares names to be added in SQL query
     *
     * @param string $value
     * @access public
     * @return string
     */
    public function quoteName($value) {
        $v = explode('::', $value);
        if (count($v) > 1) {
            $value = $v[0];
        }
        return mysqli_escape_string($this->link, str_replace("\r",'',$value));
    }

    /**
     * Prepares names to be added in SQL query
     * By referance
     *
     * @param string $value
     * @access public
     * @return string
     */
    public function quoteNameByReferance(&$value) {
        $value = $this->quoteName($value);
    }

    /**
     * Begins transaction
     *
     * @access public
     * @return void
     */
    public function begin() {
        $this->query("SET autocommit=0;");
        $this->query("START TRANSACTION;");
    }

    /**
     * Commits transaction
     *
     * @access public
     * @return void
     */
    public function commit() {
        $this->query("COMMIT;");
    }

    /**
     * Rolls back transaction
     *
     * @access public
     * @return void
     */
    public function rollback() {
        mysqli_rollback($this->link);
    }

    /**
     * Selects one value from query
     *
     * @param string $q query string
     * @param string[optional] $params
     * @param string[optional] $name of value
     * @access public
     * @return string|false
     */
    public function selectValue($q, $params=array(), $name=null) {
        $this->pquery($q, $params);
        if ($name !== null) {
            return $this->fetch(true, false, $name);
        } else {
            return $this->fetch(false, false, 0);
        }
    }

    /**
     * Selects one level array with one field value for each row
     *
     * @param string $q query string
     * @param string[optional] $params
     * @param string[optional] $name of value
     * @access public
     * @return array
     */
    public function selectValues($q, $params=array(), $name=null) {
        $this->pquery($q, $params);
        if ($name !== null) {
            return $this->fetch(true, true, $name);
        } else {
            return $this->fetch(false, true, 0);
        }
    }

    /**
     * Selects query result
     *
     * @param string $q query
     * @param bool[optional] $all only first occurance if false
     * @param bool[optional] $assoc fetch type
     * @access public
     * @return array
     */
    public function select($q, $params=array(), $all=true, $assoc=true) {
        $this->pquery($q, $params);
        return $this->fetch($assoc, $all);
    }

    /**
     * Select by where array
     *
     * @param string $table name
     * @param string[optional] $what
     * @param array[optional] $where
     * @param array[optional] $order
     * @access public
     * @return array
     */
    public function wselectValues($table, $what='*', array $where=null, array $order=null) {
        return $this->_wselect($table, $what, $where, $order, true);
    }

    /**
     * Select by where array
     *
     * @param string $table name
     * @param string[optional] $what
     * @param array[optional] $where
     * @param array[optional] $order
     * @access public
     * @return array
     */
    public function wselect($table, $what='*', array $where=null, array $order=null) {
        return $this->_wselect($table, $what, $where, $order);
    }


    /**
     * Select by where array
     *
     * @param string $table name
     * @param string[optional] $what
     * @param array[optional] $where
     * @param array[optional] $order
     * @access private
     * @return array
     */
    private function _wselect($table, $what='*', array $where=null, array $order=null, $values_only=false) {
        $values = array();
        $v = 1;
        $q = 'SELECT '.$what.' FROM '.$this->quoteName($table);

        if (!empty($where)) {
            $q .= ' WHERE ';
            foreach ($where as $key => $value) {
                $k = explode('::', $key);
                if (count($k) > 1) {
                    $key = $k[0];
                    $type = $k[1];
                } else {
                    $type = null;
                }
                if (is_array($value)) {
                    $arr = array();
                    foreach ($value as $val) {
                        $arr[] = "$".$v++."";
                        $values[] = $val;
                    }
                    $iwhere[] = $this->quoteName($key)." IN (".implode(',',$arr).")";
                } else {
                    $iwhere[] = $this->quoteName($key).'= $'.$v++;
                    $values[] = $value;
                }
            }
            $q .= implode(' AND ',$iwhere);
        }
        if (!empty($order)) {
            $q .= ' ORDER BY '.implode(', ',$order);
        }
        if ($values_only) {
            return $this->selectValues($q, $values);
        } else {
            return $this->select($q, $values);
        }
    }

    /**
     * Selects query result
     *
     * @param string $q query
     * @param bool[optional] $all only first occurance if false
     * @param bool[optional] $assoc fetch type
     * @access public
     * @return array
     */
    public function selectHash($q, $params=array(), $all=true) {
        $this->pquery($q, $params);
        $result = array();
        foreach($this->fetch(false, $all) as $f) {
            $result[$f[0]] = $f[1];
        }
        return $result;
    }

    /**
     * Selects ONE query result
     *
     * @param string $q query
     * @param bool[optional] $all only first occurance if false
     * @param bool[optional] $assoc fetch type
     * @access public
     * @return array
     */
    public function selectOne($q, $params=array(), $assoc=true) {
        return $this->select($q, $params, false, $assoc);
    }


    /**
     * Inserts into the database
     *
     * @param string $q query
     * @param array[optional] $data if is set - $q will be treated like table name
     * @param array[optional] $returning
     * @access public
     */
    public function insert($q, array $data = array()) {
        if (!empty($data)) {
            //quoting
            //array_walk($data, array($this, 'quoteByReference'));
            $names = array_keys($data);
            array_walk($names, array($this, 'quoteNameByReferance'));
            //getting together
            $q = 'INSERT INTO '.$this->quoteName($q).' ('.implode(', ', $names).') VALUES ($'.implode(', $', range(1,count($names))).')';
            return $this->pquery($q, $data);
        }

        return $this->query($q);
    }


    /**
     * Inserts into the database
     *
     * @param string $q query
     * @param array[optional] $data if is set - $q will be treated like table name
     * @access public
     */
    public function pinsert($q, array $data) {
        return $this->pquery($q, $data);
    }


    /**
     * Inserts multilevel array into the database
     *
     * @param string $table name
     * @param array $values array
     * @access public
     * @return int last insert id
     */
    public function insertRows($table, array $values) {
        $rows = array();
        $qvalues = array();
        $v = 1;
        foreach ($values as $row) {
        	foreach ($row as $r) {
        		$qvalues[] = $r;
        	}
            $rows[] = '($'.implode(', $', range($v, $v+(count($row)-1))).')';
            $v = $v+count($row);
        }

        $names = array_keys($values[0]);
        array_walk($names, array($this, 'quoteNameByReferance'));

        $q = 'INSERT INTO '.$this->quoteName($table).' ('.implode(', ', $names).') VALUES '.implode(', ', $rows);
        return $this->pinsert($q, $qvalues);
    }

    /**
     * Updates the database
     *
     * @param string $q query
     * @param array[optional] $data if is set - $q will be treated like table name
     * @param array[optional] $where
     * @param array[optional] $returning
     * @access public
     * @return int affected rows
     */
    public function update($q, array $data=null, array $where=null, $returning=null) {
        if (!empty($data)) {
        	$values = array();
        	$v = 1;
            foreach ($data as $key => $value) {
                $k = explode('::', $key);
                if (count($k) > 1) {
                    $key = $k[0];
                    $type = $k[1];
                } else {
                    $type = null;
                }

                if (is_null($value)) {
                    $idata[] = $this->quoteName($key).' = NULL';
                } else {
                    $idata[] = $this->quoteName($key).' = $'.$v++;
                    $values[] = $value;
                }
            }
            $q = 'UPDATE '.$this->quoteName($q).' SET '.implode(',',$idata);

            if (!empty($where)) {
                $q .= ' WHERE ';
                foreach ($where as $key => $value) {
                    $k = explode('::', $key);
                    if (count($k) > 1) {
                        $key = $k[0];
                        $type = $k[1];
                    } else {
                        $type = null;
                    }
                    $iwhere[] = $this->quoteName($key).' = $'.$v++;
                    $values[] = $value;
                }
                $q .= implode(' AND ',$iwhere);
            }
            if (!empty($returning)) {
            	$q .= ' RETURNING '.$returning;
            	return $this->selectValue($q, $values);
            }
            $this->pquery($q, $values);
            return $this->affectedRows();
        }

        $this->query($q);
        return $this->affectedRows();
    }

    /**
     * Updates the database parametrized
     *
     * @param string $q query
     * @param array $params
     * @access public
     * @return int affected rows
     */
    public function pupdate($q, array $params) {
        $this->pquery($q, $params);
        return $this->affectedRows();
    }

    /**
     * Deletes from the database
     *
     * @param string $q query
     * @param array[optional] $where if is set - $q will be treated like table name
     * @access public
     * @return int affected rows
     */
    public function delete($q, array $where=null, $full=false) {
        if (!$full) {
            $values = array();
            $v = 1;
            $q = 'DELETE FROM '.$this->quoteName($q);

            if (!empty($where)) {
                $q .= ' WHERE ';
                foreach ($where as $key => $value) {
                    $k = explode('::', $key);
                    if (count($k) > 1) {
                        $key = $k[0];
                        $type = $k[1];
                    } else {
                        $type = null;
                    }
                    if (is_array($value)) {
                        $arr = array();
                        foreach ($value as $val) {
                            $arr[] = "$".$v++."";
                            $values[] = $val;
                        }
                        $iwhere[] = $this->quoteName($key)." IN (".implode(',',$arr).")";
                    } else {
                        $iwhere[] = $this->quoteName($key).'= $'.$v++;
                        $values[] = $value;
                    }
                }
                $q .= implode(' AND ',$iwhere);
            }

        } else {
            $values = $where;
        }
        $this->pquery($q, $values);
        return $this->affectedRows();
    }

    /**
     * Deletes from the database
     *
     * @param string $q query
     * @param array[optional] $where if is set - $q will be treated like table name
     * @access public
     * @return int affected rows
     */
    public function pdelete($q, array $where=null) {
        return $this->delete($q, $where, true);
    }

    /**
     * Returns number of rows in result
     *
     * @access public
     * @return int|false
     */
    public function numRows() {
        if ($this->checkResource()) {
            return mysqli_num_rows($this->result);
        } else {
            return false;
        }
    }

    /**
     * Returns number of the affected rows
     *
     * @access public
     * @return int|false
     */
    public function affectedRows() {
        if ($this->link) {
            return mysqli_affected_rows($this->link);
        } else {
            return false;
        }
    }

    /**
     * Checks if var $result is a valid pgsql result
     *
     * @access private
     * @return bool
     */
    private function checkResource() {
        if (is_resource($this->result) && get_resource_type($this->result) == 'mysqli result') {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Retrieves query log
     *
     * @access public
     * @return array
     */
    public function getQueryLog() {
        return $this->query_log;
    }

    /**
     * Retrieves query log
     *
     * @access public
     * @return array
     */
    public function getTotalTime() {
        $time = 0;
        foreach ($this->query_log as $ql) {
            $time += $ql['time'];
        }
        return $time;
    }
    
    public function last_id() {
        return mysqli_insert_id($this->link);
    }

    /**
     * Forbidden
     */
    public function __clone() {
        trigger_error('Clone is not allowed.', E_USER_ERROR);
    }

    /**
     * Forbidden
     */
    public function __wakeup() {
        trigger_error('Deserializing is not allowed.', E_USER_ERROR);
    }

    /**
     * Gets PgSQLLayer instance
     *
     * @access public
     * @return PgSQLLayer
     */
    public static function instance() {
        if (!self::$instance instanceof self) {
            self::$instance = new self;
        }
        return self::$instance;
    }

}
