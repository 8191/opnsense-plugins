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
     * Updates or inserts a row in the database for each target of the XML model.
     *
     * @param string $uuid the uuid of the target to update
     * @param array $field values to update (attribute name as keys)
     */
    public function serializeToDatabase()
    {
        foreach ($this->targets->target->__items as $target) {
            $uuid = $target->getAttribute('uuid');
            $this->saveTargetToDatabase($uuid, array(
                'lastSync' => $target->lastSync,
                'statusLastSync' => $target->statusLastSync,
                'lastSuccessfulSync' => $target->lastSuccessfulSync
            ));
        }
    }

    /**
     * Populate VirtualFields with data from sqlite3 database
     */
    protected function init()
    {
        $this->openDatabase();
        $this->queryDatabase();

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
     * @param array $field values to update (attribute name as keys)
     */
    private function saveTargetToDatabase($uuid, $fields)
    {
        // Target not in database (insert)
        if (empty($this->dbData[$uuid])) {
            $stmt = $this->dbHandle->prepare('
                insert into targets(uuid, lastSync, statusLastSync, lastSuccessfulSync)
                values (:uuid, :lastSync, :statusLastSync, :lastSuccessfulSync)
            ');
            $stmt->bindValue(':uuid', $uuid);
            $stmt->bindValue(':lastSync', (empty($fields['lastSync'])) ? 0 : $fields['lastSync']);
            $stmt->bindValue(':statusLastSync', (empty($fields['statusLastSync'])) ? "" : $fields['statusLastSync']);
            $stmt->bindValue(':lastSuccessfulSync', (empty($fields['lastSuccessfulSync'])) ? 0 : $fields['lastSuccessfulSync']);
            $stmt->execute();
        }
        // Target in database (update)
        else {
            // Update row
            $stmt = $this->dbHandle->prepare('
                update targets
                set lastSync = :lastSync,
                    statusLastSync = :statusLastSync,
                    lastSuccessfulSync = :lastSuccessfulSync
                where uuid = :uuid
            ');
            $stmt->bindValue(':uuid', $uuid);
            $stmt->bindValue(':lastSync', (empty($fields['lastSync'])) ? $this->dbData[$uuid]['lastSync'] : $fields['lastSync']);
            $stmt->bindValue(':statusLastSync', (empty($fields['statusLastSync'])) ? $this->dbData[$uuid]['lastSync'] : $fields['statusLastSync']);
            $stmt->bindValue(':lastSuccessfulSync', (empty($fields['lastSuccessfulSync'])) ? $this->dbData[$uuid]['lastSuccessfulSync'] : $fields['lastSuccessfulSync']);
            $stmt->execute();
        }
    }

    private function openDatabase()
    {
        $db_path = '/conf/aliassync.db';
        $this->dbHandle = new \SQLite3($db_path);
        $this->dbHandle->busyTimeout(30000);
        $results = $this->dbHandle->query("PRAGMA table_info('targets')");
        $known_fields = array();
        while ($row = $results->fetchArray(SQLITE3_ASSOC)) {
            $known_fields[] = $row['name'];
        }
        if (count($known_fields) == 0) {
            // new database, setup
            $sql_create = "
                create table targets (
                      uuid               varchar2  -- target uui
                    , lastSync           integer   -- time of last sync attempt
                    , statusLastSync     varchar2  -- status of last sync attempt
                    , lastSuccessfulSync integer   -- time of last successful sync
                    , primary key (uuid)
                );
            ";
            $this->dbHandle->exec($sql_create);
        }
    }

    private function queryDatabase()
    {
        $this->dbData = array();
        $stmt = $this->dbHandle->prepare('select * from targets');
        $result = $stmt->execute();
        while ($row = $result->fetchArray(SQLITE3_ASSOC)) {
            $this->dbData[$row['uuid']] = $row;
        }
    }
}
