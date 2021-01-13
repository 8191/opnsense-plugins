#!/usr/local/bin/php
<?php
/*
 *    Copyright (C) 2021 Manuel Faux
 *    Copyright (C) 2018-2021 Deciso B.V.
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
 */

require_once('plugins.inc');
require_once("legacy_bindings.inc");

use OPNsense\AliasSync\AliasSync;
use OPNsense\Firewall\Alias;
use OPNsense\Core\Config;

/**
 * variant on model.getNodes() returning actual field values
 * @param $parent_node BaseField node to reverse
 */
function getRawNodes($parent_node)
{
    $result = array();
    foreach ($parent_node->iterateItems() as $key => $node) {
        if ($node->isContainer()) {
            $result[$key] = getRawNodes($node);
        } else {
            $result[$key] = (string)$node;
        }
    }
    return $result;
}

$hostname = null;
if ($_SERVER['argc'] > 1) {
    $hostname = $_SERVER['argv'][1];
}

$mdlAS = new AliasSync();
$mdlAlias = new Alias();
#$configObj = Config::getInstance()->object();
$aliases = getRawNodes($mdlAlias);

$results = array();

foreach ($mdlAS->targets->target->__items as $target) {
    if ($hostname !== null && $target->hostname != $hostname) {
        continue;
    }

    $result = array('status' => "disabled");
    if (!empty((string)$target->enabled)) {
        $result['status'] = "failed";
        $this_uuid = $target->getAttributes()['uuid'];

        $port = (empty($target->port)) ? 443 : intval($target->port);
        $curl = curl_init();
        curl_setopt_array($curl, array(
            CURLOPT_URL => "https://{$target->hostname}:{$port}/api/firewall/alias/import",
            CURLOPT_POST => 1,
            CURLOPT_POSTFIELDS => json_encode(array("data" => $aliases)),
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
        $mdlAS->serializeToConfig();

    }

    if ($hostname !== null) {
        $results = $result;
    }
    else {
        $results[(string)$target->hostname] = $result;
    }
}
Config::getInstance()->save();

echo json_encode($results) . "\n";
