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

<script src="{{ cache_safe('/ui/js/nginx/lib/lodash.min.js') }}"></script>
<script src="{{ cache_safe('/ui/js/nginx/lib/backbone-min.js') }}"></script>
<script src="{{ cache_safe('/ui/js/nginx/dist/configuration.min.js') }}"></script>


<ul class="nav nav-tabs" role="tablist" id="maintabs">
    {{ partial("layout_partials/base_tabs_header",['formData':settings]) }}
    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown"
           href="#"
           class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block"
           role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#subtab_item_nginx-access-request-limit').click();"
           class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block"
           style="border-right:0px;"><b>{{ lang._('Access')}}</b></a>
        <ul class="dropdown-menu" role="menu">
            <li>
                <a data-toggle="tab" id="subtab_item_nginx-access-request-limit" href="#subtab_nginx-access-request-limit">{{ lang._('Limit Zone')}}</a>
            </li>
            <li>
                <a data-toggle="tab" id="subtab_item_nginx-access-request-limit-connection" href="#subtab_nginx-access-request-limit-connection">{{ lang._('Connection Limits')}}</a>
            </li>
            <li>
                <a data-toggle="tab" id="subtab_item_nginx-acl-ip" href="#subtab_nginx-acl-ip">{{ lang._('IP ACLs')}}</a>
            </li>
        </ul>
    </li>
    <li role="presentation" class="dropdown">
        <a data-toggle="dropdown"
           href="#"
           class="dropdown-toggle pull-right visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block"
           role="button">
            <b><span class="caret"></span></b>
        </a>
        <a data-toggle="tab" onclick="$('#subtab_item_nginx-other-syslog-target').click();"
           class="visible-lg-inline-block visible-md-inline-block visible-xs-inline-block visible-sm-inline-block"
           style="border-right:0px;"><b>{{ lang._('Other')}}</b></a>
        <ul class="dropdown-menu" role="menu">
            <li>
                <a data-toggle="tab" id="subtab_item_nginx-other-syslog-target" href="#subtab_nginx-other-syslog-target">{{ lang._('SYSLOG Targets')}}</a>
            </li>
        </ul>
    </li>
</ul>

<div class="content-box tab-content">
    {{ partial("layout_partials/base_tabs_content",['formData':settings]) }}
    <div id="subtab_nginx-access-request-limit" class="tab-pane fade">
        <table id="grid-limit_zone" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="limit_zonedlg">
            <thead>
                <tr>
                    <th data-column-id="description" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="key" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Key') }}</th>
                    <th data-column-id="size" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Size') }}</th>
                    <th data-column-id="rate" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Rate') }}</th>
                    <th data-column-id="rate_unit" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Rate Unit') }}</th>
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
    <div id="subtab_nginx-access-request-limit-connection" class="tab-pane fade">
        <table id="grid-limit_request_connection" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="limit_request_connectiondlg">
            <thead>
                <tr>
                    <th data-column-id="description" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="limit_zone" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Limit Zone') }}</th>
                    <th data-column-id="connection_count" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Connection Count') }}</th>
                    <th data-column-id="burst" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Burst') }}</th>
                    <th data-column-id="nodelay" data-type="string" data-sortable="true" data-visible="true">{{ lang._('No Delay') }}</th>
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
    <div id="subtab_nginx-acl-ip" class="tab-pane fade">
        <table id="grid-ipacl" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="ipacl_dlg">
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
    <div id="subtab_nginx-other-syslog-target" class="tab-pane fade">
        <table id="grid-syslog_target" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="syslog_target_dlg">
            <thead>
                <tr>
                    <th data-column-id="description" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Description') }}</th>
                    <th data-column-id="host" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Host') }}</th>
                    <th data-column-id="facility" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Facility') }}</th>
                    <th data-column-id="severity" data-type="string" data-sortable="true" data-visible="true">{{ lang._('Severity') }}</th>
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


{{ partial("layout_partials/base_dialog",['fields': limit_request_connection,'id':'limit_request_connectiondlg', 'label':lang._('Edit Request Connection Limit')]) }}
{{ partial("layout_partials/base_dialog",['fields': limit_zone,'id':'limit_zonedlg', 'label':lang._('Edit Limit Zone')]) }}
{{ partial("layout_partials/base_dialog",['fields': ipacl,'id':'ipacl_dlg', 'label':lang._('Edit IP ACL')]) }}
{{ partial("layout_partials/base_dialog",['fields': syslog_target,'id':'syslog_target_dlg', 'label':lang._('Edit SYSLOG Target')]) }}
