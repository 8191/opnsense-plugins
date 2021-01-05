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
<style>
    #frm_sni_hostname_mapdlg .col-md-4,
    #frm_ipacl_dlg .col-md-4 {
        width: 50%;
    }
    #frm_sni_hostname_mapdlg td > input[type="text"],
    #frm_ipacl_dlg td > input[type="text"] {
        width: 100%;
        max-width: 100%;
    }
    #frm_sni_hostname_mapdlg .col-md-5,
    #frm_ipacl_dlg .col-md-5 {
        width: 25%;
    }
    #row_snihostname\.data .row div,
    #row_ipacl\.data .row div {
        padding: 0;
    }
    #sni_hostname_mapdlg .bootstrap-select,
    #frm_ipacl_dlg .bootstrap-select {
        width: 100% !important;
    }

</style>


<ul class="nav nav-tabs" role="tablist" id="maintabs">
    <li class="active">
        <a data-toggle="tab" id="subtab_item_nginx-streams-streamserver" href="#subtab_nginx-streams-streamserver">{{ lang._('Stream Servers')}}</a>
    </li>
    <li>
        <a data-toggle="tab" id="subtab_item_nginx-streams-snifwd" href="#subtab_nginx-streams-snifwd">{{ lang._('SNI Based Routing')}}</a>
    </li>
</ul>

<div class="content-box tab-content">
    <div id="subtab_nginx-streams-streamserver" class="tab-pane fade in active">
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
    <div id="subtab_nginx-streams-snifwd" class="tab-pane fade">
        <table id="grid-snifwd" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="sni_hostname_mapdlg">
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


{{ partial("layout_partials/base_dialog",['fields': streamserver,'id':'streamserverdlg', 'label':lang._('Edit Stream Server')]) }}
{{ partial("layout_partials/base_dialog",['fields': sni_hostname_map,'id':'sni_hostname_mapdlg', 'label':lang._('Edit SNI Hostname Mapping')]) }}
