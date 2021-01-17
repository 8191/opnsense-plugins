<?php

/**
 *    Copyright (C) 2021 Manuel Faux
 *
 *    All rights reserved.
 *
 *    Redistribution and use in source and binary forms, with or without
 *    modification, are permitted provided that the following conditions are met:
 *
 *    1. Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *
 *    2. Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 *    THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 *    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *    AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 *    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *    POSSIBILITY OF SUCH DAMAGE.
 *
 */

namespace OPNsense\AliasSync;

use OPNsense\AliasSync\FieldTypes\VirtualField;
use OPNsense\Base\BaseModel;
use ReflectionClass;

class AliasSync extends BaseModel
{
    /**
     * @var \SQLite3 database handle
     */
    private $dbHandle = null;

    /**
     * @var array contains all rows of the targets sqlite table
     */
    private $dbData = array();

    /**
     * @var array the database model specified by VirtualFields in AliasSync.xml
     */
    private $dbModel = array();

    /**
     * Updates or inserts a row in the database for each target of the XML model.
     *
     * @param string $uuid the uuid of the target to update
     * @param array $field values to update (attribute name as keys)
     */
    public function serializeToDatabase()
    {
        foreach ($this->targets->target->__items as $target) {
            $uuid = $target->getAttribute('uuid');
            $this->saveTargetToDatabase($uuid, $target);
        }
    }

    /**
     * Populate VirtualFields with data from sqlite database.
     */
    protected function init()
    {
        $this->openDatabase();
        $this->dbData = $this->queryDatabase();

        // For each target...
        foreach ($this->targets->target->__items as $target) {
            // ...iterate throught all fields...
            foreach ($target->__items as $attribute) {
                // ...and search for VirtualFields.
                if (get_class($attribute) == 'OPNsense\AliasSync\FieldTypes\VirtualField') {
                    $uuid = $target->getAttribute('uuid');
                    // Value already set in sqlite
                    if (!empty($this->dbData[$uuid][$attribute->getInternalXMLTagName()])) {
                        $attribute->setValue($this->dbData[$uuid][$attribute->getInternalXMLTagName()]);
                    }
                }
            }
        }
    }

    /**
     * Updates or inserts a row in the database.
     *
     * @param string $uuid the uuid of the target to update
     * @param Target $target target to save
     */
    private function saveTargetToDatabase($uuid, $target)
    {
        // Target not in database (insert)
        if (empty($this->dbData[$uuid])) {
            // Prepare columns separated by commas
            $fields = implode(",", array_keys($this->dbModel));
            // Prepate ? with amount of columns separated by commas
            $values = str_repeat(", ?", count($this->dbModel));
            $sql_insert = "
                insert into targets(uuid, $fields)
                values (? $values)
            ";
            $stmt = $this->dbHandle->prepare($sql_insert);
            $stmt->bindValue(1, $uuid);
            $col = 2; // Count parameters, as we use indexed positional placeholders
            foreach ($this->dbModel as $column => $type) {
                $stmt->bindValue($col++, $target->$column);
            }
            $stmt->execute();
        }
        // Target in database (update)
        else {
            // Prepare "column = ?" separated by commas
            $fields = implode(",", array_map(function($col){ return "$col = ?"; }, array_keys($this->dbModel)));
            // Update row
            $sql_update = "
                update targets
                set $fields
                where uuid = ?
            ";
            $stmt = $this->dbHandle->prepare($sql_update);
            $col = 1; // Count parameters, as we use indexed positional placeholders
            foreach ($this->dbModel as $column => $type) {
                $stmt->bindValue($col++, $target->$column);
            }
            $stmt->bindValue($col, $uuid);
            $stmt->execute();
        }
    }

    /**
     * Open sqlite database connection and create db structure if needed.
     */
    private function openDatabase()
    {
        $db_path = '/conf/aliassync.db';
        $this->dbModel = $this->getTargetDbModel();
        $this->dbHandle = new \SQLite3($db_path);
        $this->dbHandle->busyTimeout(30000);
        $results = $this->dbHandle->query("PRAGMA table_info('targets')");
        $known_fields = array();
        while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
            $known_fields[] = $row['name'];
        }

        // Check if number of columns matches (model fields + uuid)
        if (count($known_fields) != count($this->dbModel) + 1) {
            // If table exists, drop it
            if (count($known_fields) != 0) {
                $sql_drop = "
                    drop table targets
                ";
                $this->dbHandle->exec($sql_drop);
            }

            // Prepare "column type" separated by commas
            $columns = implode(",",
                array_map(function($c, $t) {
                    return "$c  $t";
                }, array_keys($this->dbModel), $this->dbModel)
            );
            // new database, setup
            $sql_create = "
                create table targets (
                      uuid, $columns
                    , primary key (uuid)
                );
            ";
            $this->dbHandle->exec($sql_create);
        }
    }

    /**
     * Retireve targets table from database and return as array.
     *
     * @return array targets table
     */
    private function queryDatabase()
    {
        $data = array();
        $stmt = $this->dbHandle->prepare('select * from targets');
        $result = $stmt->execute();
        while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
            $data[$row['uuid']] = $row;
        }

        return $data;
    }

    /**
     * Parses the model definition (AliasSync.xml) for all VirtualFields of
     * the target ArrayField.
     * @return array all VirtualFields of a Target with field name in key and type in value
     */
    private function getTargetDbModel()
    {
        $model = array();
        $class_info = new ReflectionClass($this);
        $model_filename = substr($class_info->getFileName(), 0, strlen($class_info->getFileName()) - 3) . "xml";
        $model_xml = simplexml_load_file($model_filename);
        
        foreach ($model_xml->items->targets->target->children() as $xmlNode) {
            $tagName = $xmlNode->getName();
            $xmlNodeType = $xmlNode->attributes()["type"];
            if ($xmlNodeType == ".\\VirtualField") {
                $model[$tagName] = 'varchar2';

                if ($xmlNode->count() > 0) {
                    // if fieldtype contains properties, try to call the setters
                    foreach ($xmlNode->children() as $fieldMethod) {
                        if ($fieldMethod->getName() == "Type" && $fieldMethod->count() == 0) {
                            $model[$tagName] = (string)$fieldMethod;
                        }
                    }
                }
            }
        }
        
        return $model;
    }
}
