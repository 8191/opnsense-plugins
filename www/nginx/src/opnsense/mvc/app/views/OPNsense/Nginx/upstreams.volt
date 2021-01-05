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
    <li class="active">
        <a data-toggle="tab" id="subtab_item_nginx-http-upstream-server" href="#subtab_nginx-http-upstream-server">{{ lang._('Upstream Server')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-http-upstream" href="#subtab_nginx-http-upstream">{{ lang._('Upstream')}}</a>
    </li>
</ul>

<div class="content-box tab-content">
    <div id="subtab_nginx-http-upstream-server" class="tab-pane fade in active">
        <table id="grid-upstreamserver" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="upstreamserverdlg">
            <thead>
            <tr>
                <th data-column-id="description" data-type="string" data-sortable="false"  data-visible="true">{{ lang._('Description') }}</th>
                <th data-column-id="server" data-type="string" data-sortable="true"  data-visible="true">{{ lang._('Server') }}</th>
                <th data-column-id="port" data-type="string" data-sortable="true"  data-visible="true">{{ lang._('Port') }}</th>
                <th data-column-id="priority" data-type="string" data-sortable="false"  data-visible="true">{{ lang._('Priority') }}</th>
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
    <div id="subtab_nginx-http-upstream" class="tab-pane fade">
        <table id="grid-upstream" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="upstreamdlg">
            <thead>
            <tr>
                <th data-column-id="description" data-type="string" data-sortable="false"  data-visible="true">{{ lang._('Description') }}</th>
                <th data-column-id="serverentries" data-type="string" data-sortable="false"  data-visible="true">{{ lang._('Servers') }}</th>
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


{{ partial("layout_partials/base_dialog",['fields': upstream,'id':'upstreamdlg', 'label':lang._('Edit Upstream')]) }}
{{ partial("layout_partials/base_dialog",['fields': upstream_server,'id':'upstreamserverdlg', 'label':lang._('Edit Upstream')]) }}
