<?php
/*
 * Copyright (C) 2021 Manuel Faux
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

namespace OPNsense\AliasSync;

use OPNsense\AliasSync\AliasSync;
use OPNsense\Core\Config;
use OPNsense\Firewall\Alias;

/**
 * Utility class to execute alias syncing.
 * @package OPNsense\AliasSync
 */
class Sync
{
    /**
     * @var \OPNsense\AliasSync\AliasSync model object
     */
    private $mdl;

    /**
     * @var \OPNsense\Firewall\Alias model object
     */
    private $mdlAlias;

    /**
     * @var null|array list of all defined aliases
     */
    private $aliases = null;

    /**
     * @var bool defines if AliasSync is enabled via config
     */
    private $enabled = false;

    public function __construct()
    {
        $this->mdl = new AliasSync();
        $this->mdlAlias = new Alias();

        $this->enabled = !empty((string)$this->mdl->settings->enabled);
    }

    /**
     * Retrieves a target object from the model.
     *
     * @param string $id uuid or hostname of the target to retrieve
     * @return \OPNsense\AliasSync\AliasSync target object
     */
    public function getTarget($id)
    {
        $result = $this->mdl->getNodeByReference("targets.target.$id");
        if ($result === null) {
            foreach ($this->mdl->targets->target->__items as $target) {
                if ($target->hostname == $id) {
                    return $target;
                }
            }
        }

        return $result;
    }

    /**
     * Attempts to sync a target regardless of its last sync status.
     *
     * @param \OPNsense\AliasSync\AliasSync $target target object to sync
     * @return array result of the sync attempt
     */
    public function sync($target)
    {
        if (!$this->enabled) {
            return array('status' => "failed", 'error' => "Alias synchronization globally disabled by configuration.");
        }

        $result = array();
        if (!empty((string)$target->enabled)) {
            $result['status'] = "failed";

            if ($this->aliases === null) {
                $this->aliases = $this->getRawNodes($this->mdlAlias);
            }

            $port = (empty($target->port)) ? 443 : intval((string)$target->port);
            $curl = curl_init();
            curl_setopt_array($curl, array(
                CURLOPT_URL => "https://{$target->hostname}:{$port}/api/firewall/alias/import",
                CURLOPT_POST => 1,
                CURLOPT_POSTFIELDS => json_encode(array("data" => $this->aliases)),
                CURLOPT_HTTPHEADER => array('Content-Type: application/json'),
                CURLOPT_SSL_VERIFYPEER => false,
                CURLOPT_USERPWD => "{$target->apiKey}:{$target->apiSecret}",
                CURLOPT_CONNECTTIMEOUT => intval((string)$target->timeout),
                CURLOPT_RETURNTRANSFER => true
            ));

            $response = json_decode(curl_exec($curl), true);
            $code = curl_getinfo($curl, CURLINFO_RESPONSE_CODE);
            $error = curl_error($curl);
            $errno = curl_errno($curl);
            curl_close($curl);

            $result['http'] = $code;
            if ($errno == 0 && $code == 200) {
                if (!empty($response['status'])) {
                    $result['status'] = $response['status'];

                    if ($result['status'] == "ok") {
                        $target->lastSuccessfulSync = time();
                    }
                }
            }
            else {
                $result['code'] = $errno;
                $result['error'] = $error;
            }

            $target->lastSync = time();
            $target->statusLastSync = $result['status'];
        }
        else {
            return array('status' => "failed", 'error' => "Target disabled by configuration.");
        }

        // TODO: move out (to prevent several savings when calling method in loop (e.g. in syncAll or syncFailed)
        $this->mdl->serializeToDatabase();
        return $result;
    }

    /**
     * Attempts to sync all defined targets regardless of their last sync status.
     *
     * @return array status of the sync attempts
     */
    public function syncAll()
    {
        $results = array();
        foreach ($this->mdl->targets->target->__items as $target) {
            $hostname = (string)$target->hostname;
            $results[$hostname] = $this->sync($target);
        }

        return $results;
    }

    /**
     * Attempts to sync all targets where the last sync attempt failed.
     *
     * @param bool $cron if true, retryInterval is observed
     * @return array status of the sync attempts
     */
    public function syncFailed($cron = false)
    {
        $retryInterval = intval((string)$this->mdl->settings->retryInterval) * 60;
        if ($cron) {
            if ($retryInterval <= 0) {
                return array('status' => "failed", 'error' => "Automatic retry disabled.");
            }
        }

        $results = array();
        foreach ($this->mdl->targets->target->__items as $target) {
            if ((string)$target->statusLastSync !== "ok") {
                if ($cron &&
                    time() - $target->lastSync < $retryInterval) {
                        continue;
                }

                $hostname = (string)$target->hostname;
                $results[$hostname] = $this->sync($target);
            }
        }

        return $results;
    }

    /**
     * @return bool true if AliasSync is enabled by configuration, false otherwise.
     */
    public function checkEnabled()
    {
        return $this->enabled;
    }

    /**
     * variant on model.getNodes() returning actual field values
     * @param $parent_node BaseField node to reverse
     */
    private function getRawNodes($parent_node)
    {
        $result = array();
        foreach ($parent_node->iterateItems() as $key => $node) {
            if ($node->isContainer()) {
                $result[$key] = $this->getRawNodes($node);
            } else {
                $result[$key] = (string)$node;
            }
        }
        return $result;
    }
}
