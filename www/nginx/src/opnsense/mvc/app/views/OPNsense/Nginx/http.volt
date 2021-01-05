{#
 # Copyright (C) 2017-2018 Fabian Franz
 # Copyright (C) 2014-2015 Deciso B.V.
 # All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without
 # modification, are permitted provided that the following conditions are met:
 #
 #  1. Redistributions of source code must retain the above copyright notice,
 #   this list of conditions and the following disclaimer.
 #
 #  2. Redistributions in binary form must reproduce the above copyright
 #    notice, this list of conditions and the following disclaimer in the
 #    documentation and/or other materials provided with the distribution.
 #
 # THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 # INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 # AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 # AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 # OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 # SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 # INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 # CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 # ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 # POSSIBILITY OF SUCH DAMAGE.
 #}

<script>
    function bind_naxsi_rule_dl_button() {
        let naxsi_rule_download_button = $('#naxsiruledownloadbtn');
        naxsi_rule_download_button.click(function () {
            BootstrapDialog.show({
                type: BootstrapDialog.TYPE_INFO,
                title: "{{ lang._('Download NAXSI Rules') }}",
                message: "{{ lang._('You are about to download the core rules from the Repository of NAXSI. You have to accept its %slicense%s to download the rules.')|format("<a href='https://github.com/nbs-system/naxsi/blob/master/LICENSE' target='_blank'>", "</a>") }}",
                buttons: [{
                    label: "{{ lang._('Accept And Download') }}",
                    cssClass: 'btn-primary',
                    icon: 'fa fa-download',
                    action: function (dlg) {
                        dlg.close();
                        ajaxCall(url = "/api/nginx/settings/downloadrules", sendData = {}, callback = function (data, status) {
                            $('#naxsiruledownloadalert').hide();
                            // reload view after installing rules
                            $('#grid-naxsirule').bootgrid('reload');
                            $('#grid-custompolicy').bootgrid('reload');
                        });
                    }
                }, {
                    label: '{{ lang._('Reject') }}',
                    action: function (dlg) {
                        dlg.close();
                    }
                }]
            });
        });
    }
</script>
<script src="{{ cache_safe('/ui/js/nginx/lib/lodash.min.js') }}"></script>
<script src="{{ cache_safe('/ui/js/nginx/lib/backbone-min.js') }}"></script>
<script src="{{ cache_safe('/ui/js/nginx/dist/configuration.min.js') }}"></script>


<ul class="nav nav-tabs" role="tablist" id="maintabs">
    <li class="active">
        <a data-toggle="tab" id="subtab_item_nginx-http-location" href="#subtab_nginx-http-location">{{ lang._('Location')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-credential" href="#subtab_nginx-http-credential">{{ lang._('Credential')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-userlist" href="#subtab_nginx-http-userlist">{{ lang._('User List')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-server" href="#subtab_nginx-http-httpserver">{{ lang._('HTTP Server')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-rewrite" href="#subtab_nginx-http-rewrite">{{ lang._('URL Rewriting')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-custompolicy" href="#subtab_nginx-http-custompolicy">{{ lang._('Naxsi WAF Policy')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-naxsirule" href="#subtab_nginx-http-naxsirule">{{ lang._('Naxsi WAF Rule')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-security_header" href="#subtab_nginx-http-security_header">{{ lang._('Security Headers')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-cache_path" href="#subtab_nginx-http-cache_path">{{ lang._('Cache Path')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-tls-fingerprint" href="#subtab_nginx-http-tls-fingerprint">{{ lang._('TLS Fingerprint (Advanced)')}}</a>
    </li>
</ul>

<div class="content-box tab-content">
    <div id="subtab_nginx-http-location" class="tab-pane fade in active">
        <table id="grid-location" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="locationdlg">
            <thead>
            <tr>
                <th data-column-id="description" data-type="string" data-sortable="true"  data-visible="true">{{ lang._('Description') }}</th>
                <th data-column-id="urlpattern" data-type="string" data-sortable="true"  data-visible="true">{{ lang._('URL Pattern') }}</th>
                <th data-column-id="path_prefix" data-type="string" data-sortable="true"  data-visible="true">{{ lang._('URL Path Prefix') }}</th>
                <th data-column-id="matchtype" data-type="string" data-sortable="true"  data-visible="true">{{ lang._('Match Type') }}</th>
                <th data-column-id="enable_secrules" data-type="boolean" data-sortable="true"  data-visible="true">{{ lang._('WAF Enabled') }}</th>
                <th data-column-id="force_https" data-type="boolean" data-sortable="true"  data-visible="true">{{ lang._('Force HTTPS') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>

    <div id="subtab_nginx-http-credential" class="tab-pane fade">
        <table id="grid-credential" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="credentialdlg">
            <thead>
            <tr>
                <th data-column-id="username" data-type="string" data-sortable="false"  data-visible="true">{{ lang._('Username') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-http-userlist" class="tab-pane fade">
        <table id="grid-userlist" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="userlistdlg">
            <thead>
            <tr>
                <th data-column-id="name" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Name') }}</th>
                <th data-column-id="users" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Users') }}</th>
                <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-http-httpserver" class="tab-pane fade">
        <table id="grid-httpserver" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="httpserverdlg">
            <thead>
                <tr>
                    <th data-column-id="servername" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Servername') }}</th>
                    <th data-column-id="https_only" data-type="boolean" data-sortable="true" data-visible="true">{{ lang._('HTTPS Only') }}</th>
                    <th data-column-id="certificate" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Certificate') }}</th>
                    <th data-column-id="listen_http_port" data-type="string" data-sortable="true" data-visible="true">{{ lang._('HTTP Port') }}</th>
                    <th data-column-id="listen_https_port" data-type="string" data-sortable="true" data-visible="true">{{ lang._('HTTPS Port') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-streams-streamserver" class="tab-pane fade">
        <table id="grid-streamserver" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="streamserverdlg">
            <thead>
                <tr>
                    <th data-column-id="certificate" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Certificate') }}</th>
                    <th data-column-id="udp" data-type="string" data-sortable="true" data-visible="true">{{ lang._('UDP') }}</th>
                    <th data-column-id="listen_port" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Port') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-http-rewrite" class="tab-pane fade">
        <table id="grid-httprewrite" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="httprewritedlg">
            <thead>
                <tr>
                    <th data-column-id="description" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="source" data-type="boolean" data-sortable="true" data-visible="true">{{ lang._('Source URL') }}</th>
                    <th data-column-id="destination" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Destination URL') }}</th>
                    <th data-column-id="flag" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Flag') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-http-custompolicy" class="tab-pane fade">
        {% if (show_naxsi_download_button) %}
        <div class="alert alert-info" id="naxsiruledownloadalert" role="alert" style="vertical-align: middle;display: table;width: 100%;">
            <div style="display: table-cell;vertical-align: middle;">{{ lang._('It looks like you are not having any rules installed. You may want to download the NAXSI core rules.') }}</div>
            <div class="pull-right" style="vertical-align: middle;display: table-cell;">
                <button id="naxsiruledownloadbtn" class="btn btn-primary">
                    <i class="fa fa-download" aria-hidden="true"></i> {{ lang._('Download') }}
                </button>
            </div>
        </div>
        {% endif %}
        <table id="grid-custompolicy" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="custompolicydlg">
            <thead>
                <tr>
                    <th data-column-id="name" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Name') }}</th>
                    <th data-column-id="operator" data-type="boolean" data-sortable="true" data-visible="true">{{ lang._('Operator') }}</th>
                    <th data-column-id="value" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Value') }}</th>
                    <th data-column-id="action" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Action') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-http-naxsirule" class="tab-pane fade">
        <table id="grid-naxsirule" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="naxsiruledlg">
            <thead>
                <tr>
                    <th data-column-id="description" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="ruletype" data-type="boolean" data-sortable="true" data-visible="true">{{ lang._('Rule Type') }}</th>
                    <th data-column-id="identifier" data-type="string" data-sortable="true" data-visible="true">{{ lang._('ID') }}</th>
                    <th data-column-id="message" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Message') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-http-security_header" class="tab-pane fade">
        <table id="grid-security_header" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="security_headersdlg">
            <thead>
                <tr>
                    <th data-column-id="description" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-http-cache_path" class="tab-pane fade">
        <table id="grid-cache_path" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="cache_pathdlg">
            <thead>
                <tr>
                    <th data-column-id="path" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Path') }}</th>
                    <th data-column-id="size" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="inactive" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="max_size" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div id="subtab_nginx-http-tls-fingerprint" class="tab-pane fade">
        <table id="grid-tls_fingerprint" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="tls_fingerprint_dlg">
            <thead>
                <tr>
                    <th data-column-id="description" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default"><span class="fa fa-plus"></span></button>
                    <button type="button" class="btn btn-xs reload_btn btn-primary"><span class="fa fa-refresh reloadAct_progress"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
</div>


{{ partial("layout_partials/base_dialog",['fields': location,'id':'locationdlg', 'label':lang._('Edit Location')]) }}
{{ partial("layout_partials/base_dialog",['fields': credential,'id':'credentialdlg', 'label':lang._('Edit Credential')]) }}
{{ partial("layout_partials/base_dialog",['fields': userlist,'id':'userlistdlg', 'label':lang._('Edit User List')]) }}
{{ partial("layout_partials/base_dialog",['fields': httpserver,'id':'httpserverdlg', 'label':lang._('Edit HTTP Server')]) }}
{{ partial("layout_partials/base_dialog",['fields': httprewrite,'id':'httprewritedlg', 'label':lang._('Edit URL Rewrite')]) }}
{{ partial("layout_partials/base_dialog",['fields': naxsi_custom_policy,'id':'custompolicydlg', 'label':lang._('Edit WAF Policy')]) }}
{{ partial("layout_partials/base_dialog",['fields': naxsi_rule,'id':'naxsiruledlg', 'label':lang._('Edit Naxsi Rule')]) }}
{{ partial("layout_partials/base_dialog",['fields': security_headers,'id':'security_headersdlg', 'label':lang._('Edit Security Headers')]) }}
{{ partial("layout_partials/base_dialog",['fields': cache_path,'id':'cache_pathdlg', 'label':lang._('Edit Cache Path')]) }}
{{ partial("layout_partials/base_dialog",['fields': tls_fingerprint,'id':'tls_fingerprint_dlg', 'label':lang._('Edit TLS Fingerprint')]) }}
