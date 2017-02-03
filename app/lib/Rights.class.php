<?php
/**
 * Contains BlockController class
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/    
 * @copyright Constantine Nazarenko 2009
 * @version $Id: Rights.class.php 4 2011-01-20 10:45:27Z tigra $
 */

################################################################################

/**
 * Service class for modules
 *
 * @package Striped 3
 * @subpackage lib
 * @final
 */
final class Rights {
    /**
     * Instance's owner identifier
     *
     * @var int
     * @access private
     */
    private $instance_owner;

    /**
     * Instance's groups identifiers
     *
     * @var array
     * @access private
     */
    private $instance_groups;

    /**
     * Instance's strict groups identifiers - user must be member of all them at once
     *
     * @var array
     * @access private
     */
    private $instance_groups_strict;

    /**
     * Owner's permissions
     *
     * @var int
     * @access private
     */
    private $permissions_owner = false;

    /**
     * Group's permissions
     *
     * @var int
     * @access private
     */
    private $permissions_group = false;

    /**
     * Other's permissions
     *
     * @var int
     * @access private
     */
    private $permissions_other = false;

    /**
     * Sets right permissions for current instance
     *
     * @access public
     * @return Rights
     */
    public function setPermissions($owner, $group, $other) {
        $this->permissions_owner = $owner;
        $this->permissions_group = $group;
        $this->permissions_other = $other;
        return $this;
    }

    /**
     * Sets right permissions for current instance
     *
     * @access public
     * @param int $instance_owner
     * @param int[optional] $from_group if is set - user must be a member of this group
     * @return Rights
     */
    public function setOwner($instance_owner, $from_group=null) {
        $this->instance_owner = $instance_owner;
        $this->instance_owners_group = $from_group;
        return $this;
    }

    /**
     * Sets right permissions for current instance
     *
     * @access public
     * @param array|int $instance_groups
     * @param bool[optional] $strict user must be a member of all of the groups
     * @return Rights
     */
    public function setGroup($instance_groups, $strict=false) {
        if (!is_array($instance_groups)) {
            $instance_groups = array($instance_groups);
        }
        if ($strict) {
            $this->instance_groups_strict = $instance_groups;
        } else {
            $this->instance_groups = $instance_groups;
        }
        return $this;
    }

    /**
     * Detects if user can do current action
     *
     * @access public
     * @param int[optional] $user_id
     * @param array[optional] $users_groups
     * @return boolean
     */
    public function canExecute($user_id=null, $users_groups=array()) {
        if (!is_array($users_groups)) {
            $users_groups = array($users_groups);
        }
        if (empty($this->instance_owners_group)) {
            $is_owner = (!empty($user_id) && !empty($this->instance_owner) && $user_id === $this->instance_owner) ? true : false;
        } else {
            $is_owner = (!empty($user_id) && !empty($this->instance_owner) && $user_id === $this->instance_owner && in_array($this->instance_owners_group, $users_groups)) ? true : false;
        }

        $in_group = false;

        if ($this->instance_groups_strict) {
            $in_group = true;
            foreach ($this->instance_groups_strict as $grp) {
                $in_group = (in_array($grp, $users_groups)) ? true : false ;
                if (!$in_group) {
                    break;
                }
            }
        }

        if ($this->instance_groups && !$in_group) {
            foreach ($this->instance_groups as $grp) {
                $in_group = (in_array($grp, $users_groups)) ? true : false ;
                if ($in_group) {
                    break;
                }
            }
        }

        return ($this->permissions_other || ($in_group && $this->permissions_group) || ($is_owner && $this->permissions_owner)) ? true : false;
    }
}