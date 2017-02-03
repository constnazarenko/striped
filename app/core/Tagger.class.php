<?php
/**
 * Contains Tagger class
 *
 * @package Striped 3
 * @subpackage lib
 * @author Constantine Nazarenko     http://nazarenko.me/
 * @copyright Constantine Nazarenko 2013
 */

require_once('striped/app/core/BlockController.class.php');

################################################################################

/**
 * Tags generator
 *
 * @package Striped 2
 * @subpackage lib
 * @final
 */
final class Tagger extends BlockController {
    private $psql = true;

    public function __construct($psql=true) {
        $this->psql = $psql;
        parent::__construct();
    }

    /**
     * Finds tag's id
     *
     * @param string $title
     * @param int $keyword
     * @access public
     * @return int
     */
    public function getTagId($name, $keyword='glb') {
        return $this->db->selectValue('SELECT id FROM tag WHERE keyword=$1 AND name = $2', array($keyword, $name));
    }


    /**
     * Finds tag's id
     *
     * @param string $title
     * @param int $keyword
     * @access public
     * @return int
     */
    public function getTagIdOrCreate($name, $keyword='glb') {
        $id = $this->db->selectValue('SELECT id FROM tag WHERE keyword=$1 AND name = $2', array($keyword, $name));
        if (!$id) {
            $this->db->pinsert("INSERT INTO tag (keyword,name) VALUES ($1,$2)", array($keyword, $name));
            $id = $this->db->last_id();
        }
        return $id;
    }



    /**
     * Finds all tags for item
     *
     * @param string $item_id
     * @param string $keyword
     * @access public
     * @return array
     */
    public function get($item_id) {
        return $this->db->selectValues('SELECT tag.name FROM tag2item
                    RIGHT JOIN tag ON (tag2item.tag_id = tag.id)
                    WHERE tag2item.item_id = $1', array($item_id));
    }


    /**
     * Finds all tags for item
     *
     * @param string $item_id
     * @param string $keyword
     * @access public
     * @return array
     */
    public function getString($item_id) {
        return implode(', ',$this->get($item_id));
    }

    /**
    * Finds all tags for item
    *
    * @param string $item_id
    * @param string $keyword
    * @access public
    * @return array
    */
    public function getItemsByTag($tag, $keyword='glb') {
    	return $this->db->selectValues('SELECT item_id FROM tag
                    RIGHT JOIN tag2item ON (tag2item.tag_id = tag.id)
                    WHERE tag.name = $1 AND tag.keyword = $2', array($tag, $keyword));
    }

    /**
     * Finds all tags for keyword
     *
     * @param string $keyword
     * @access public
     * @return array
     */
    public function getTagsList($keyword='glb') {
        return $this->db->selectValues('SELECT name FROM tag WHERE keyword = $1', array($keyword));
    }

    /**
     * Finds all tags for keyword
     *
     * @param string $keyword
     * @access public
     * @return array
     */
    public function getTagsListByIds($ids,$keyword='glb') {
        if (!empty($ids)) {
            $result = $this->db->selectValues('SELECT name FROM tag WHERE keyword = $1 and id in ('.implode(',',$ids).')', array($keyword));
            $result = implode(',',$result);
        } else {
            $result = '';
        }
        return $result;
    }

    /**
     * Finds all tags for keyword LIKE passed
     *
     * @param string $keyword
     * @access public
     * @return array
     */
    public function autocomplete($query=null,$keyword='glb') {
        if ($this->psql) {
            $tags = (!empty($query)) ? $this->db->selectValues("
                    SELECT name
                    FROM tag
                    WHERE keyword = $1 AND name LIKE $2
                    ORDER BY name !~ $3 ASC, name ASC", array($keyword, '%'.$query.'%', '^'.$query))
                    : array() ;
        } else {
            $tags = (!empty($query)) ? $this->db->selectValues("SELECT name
                FROM tag
                WHERE keyword = $1 AND name LIKE $2
                ORDER BY CASE WHEN LEFT(name, $4) = $3 THEN 1 ELSE 2 END ASC, name ASC", array($keyword, '%'.$query.'%', $query, strlen($query)))
            : array() ;
        }
        $result = array(
            'query' => $query,
            'suggestions' => array_unique($tags)
        );
        $this->JSONRespond($result);
    }



    /**
     * Saves tags for item
     *
     * @param int $id item's id
     * @param array|string $new new tag's string
     * @param string $keyword
     * @access public
     * @return bool
     */
    public function save($id, $new, $keyword='glb') {
        //preparing new tags
        if (!is_array($new)) {
            $new = explode(',', $new);
        }
        if (empty($new)) {
            return false;
        }

        $current = $this->get($id, $keyword);

        //array_walk($new, create_function('&$v,$k', '$v = trim($v);'));
        foreach ($new as $k=>$v) {
            $new[$k] = $this->seotitle(trim($v));
            if (empty($new[$k])) {
                unset($new[$k]);
            }
        }

        //getting new tags, which is needed to insert
        $new_tags = array_unique($new);

        //deleting old tags
        $this->db->delete('tag2item', array('item_id'=>$id));

        //checking if new tags already exists
        if (!empty($new_tags)) {
            $existing_tags = $this->db->wselect('tag', '*', array('keyword'=>$keyword, 'name'=>$new_tags));
            $new_tags = array_flip($new_tags);
            $tags_ids = array();
            foreach($existing_tags as $etag) {
                if (isset($new_tags[$etag['name']])) {
                    unset($new_tags[$etag['name']]);
                    $tags_ids[]['tag_id'] = $etag['id'];
                }
            }

            //inserting realy new tags
            $new_tags = array_flip($new_tags);
            foreach($new_tags as $ntag) {
                $tags_ids[]['tag_id'] = $this->db->insert('tag', array('keyword' => $keyword, 'name' => $ntag), 'id');
            }
        }

        //inserting tags into relations table
        if (!empty($tags_ids)) {
            array_walk($tags_ids, create_function('&$v,$k', 'array_push_assoc($v, "item_id", '.(int)$id.');'));
            $this->db->insertRows('tag2item', $tags_ids);
        }

        //getting old unneeded tags
        $del_tags = array_diff($current, $new);

        //getting unneeded tags ids
        if (!empty($del_tags)) {
            $del_tags_ids = $this->db->wselectValues('tag', 'id', array('keyword'=>$keyword, 'name'=>$del_tags));
        }

        //deleting from relations table unneeded
        if (isset($del_tags_ids) && !empty($del_tags_ids)) {
            //checking if tags are still needed
            $needed_tags = $this->db->wselectValues('tag2item', 'tag_id', array('tag_id'=>$del_tags_ids));

            //deleting unneeded from tags table
            $unneeded_tags = array_diff($del_tags_ids, $needed_tags);
            if (!empty($unneeded_tags)) {
                $this->db->delete('tag', array('id'=>$unneeded_tags));
            }
        }
    }

    /**
     * Delete tags for item
     *
     * @param int $id item's id
     * @param string $keyword
     * @access public
     * @return bool
     */
    public function delete($id, $keyword='glb') {

        //getting old unneeded tags
        $del_tags = $this->get($id, $keyword);

        //getting unneeded tags ids
        if (!empty($del_tags)) {
            $del_tags_ids = $this->db->wselectValues('tag', 'id', array('keyword'=>$keyword, 'name'=>$del_tags));
        }

        //deleting from relations table unneeded
        if (isset($del_tags_ids) && !empty($del_tags_ids)) {
            $this->db->delete('tag2item', array('item_id'=>$id, 'tag_id'=>$del_tags_ids));

            //checking if tags are still needed
            $needed_tags = $this->db->wselectValues('tag2item', 'tag_id', array('tag_id'=>$del_tags_ids));

            //deleting unneeded from tags table
            $unneeded_tags = array_diff($del_tags_ids, $needed_tags);
            if (!empty($unneeded_tags)) {
                $this->db->delete('tag', array('id' => $unneeded_tags));
            }
        }
    }

}
