{#
Copyright (C) 2021 Manuel Faux
OPNsense® is Copyright © 2014-2015 by Deciso B.V.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
#}
<script src="{{ cache_safe('/ui/js/moment-with-locales.min.js') }}"></script>

<script>
    $( document ).ready(function() {
        let targets_grid = $("#grid-targets").UIBootgrid(
            {   search:'/api/aliassync/settings/searchTarget/',
                get:'/api/aliassync/settings/getTarget/',
                set:'/api/aliassync/settings/setTarget/',
                add:'/api/aliassync/settings/addTarget/',
                del:'/api/aliassync/settings/delTarget/',
                toggle:'/api/aliassync/settings/toggleTarget/',
                options: {
                    formatters: {
                        "commands": function (column, row) {
                            return "<button type=\"button\" class=\"btn btn-xs btn-default command-sync\" data-row-id=\"" + row.uuid + "\" title=\"{{ lang._('Sync') }}\"><span class=\"fa fa-refresh\"></span></button> " +
                                "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.uuid + "\" title=\"{{ lang._('Edit') }}\"><span class=\"fa fa-pencil\"></span></button> " +
                                "<button type=\"button\" class=\"btn btn-xs btn-default command-copy\" data-row-id=\"" + row.uuid + "\" title=\"{{ lang._('Copy') }}\"><span class=\"fa fa-clone\"></span></button>" +
                                "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.uuid + "\" title=\"{{ lang._('Delete') }}\"><span class=\"fa fa-trash-o\"></span></button>";
                        },
                        "rowtoggle": function (column, row) {
                            if (parseInt(row[column.id], 2) === 1) {
                                return "<span style=\"cursor: pointer;\" class=\"fa fa-check-square-o command-toggle\" data-value=\"1\" data-row-id=\"" + row.uuid + "\"></span>";
                            } else {
                                return "<span style=\"cursor: pointer;\" class=\"fa fa-square-o command-toggle\" data-value=\"0\" data-row-id=\"" + row.uuid + "\"></span>";
                            }
                        },
                        "boolean": function (column, row) {
                            if (parseInt(row[column.id], 2) === 1) {
                                return "<span class=\"fa fa-check\" data-value=\"1\" data-row-id=\"" + row.uuid + "\"></span>";
                            } else {
                                return "<span class=\"fa fa-times\" data-value=\"0\" data-row-id=\"" + row.uuid + "\"></span>";
                            }
                        },
                        "datetime": function (column, row) {
                            let value = parseInt(row[column.id]);
                            if (value > 0) {
                                return moment(value * 1000).format("lll");
                            } else {
                                return "{{ lang._('never') }}";
                            }
                        }
                    }
                }
            }
        );
        // Sync command (per row in table)
        targets_grid.on('loaded.rs.jquery.bootgrid', function() {
            targets_grid.find('.command-sync').on('click', function(e) {
                icon = $("span", this);
                icon.addClass("fa-spin");
                ajaxCall(
                    url="/api/aliassync/service/sync/" + $(this).data('row-id'),
                    sendData={},
                    callback=function(data,status,elem=icon) {
                        elem.removeClass("fa-spin");
                        targets_grid.bootgrid("reload");
                        // TODO: switch to previously selected page
                    }
                );
            });
        });

        // Populate configuration form
        var data_get_map = {'frm_settings':"/api/aliassync/settings/get"};
        mapDataToFormUI(data_get_map).done(function(data){
            formatTokenizersUI();
            $('.selectpicker').selectpicker('refresh');
        });

        let disable_save_animation = function(){
                // disable progress animation
                $('#saveAct_progress').removeClass("fa fa-spinner fa-pulse");
            };

        // link save button to API set action
        $("#saveAct").click(function(){
            // set progress animation
            $('#saveAct_progress').addClass("fa fa-spinner fa-pulse");
            // save configuration
            saveFormToEndpoint(url="/api/aliassync/settings/set",formid='frm_settings',
                callback_ok=disable_save_animation,
                disable_dialog=true,
                callback_fail=disable_save_animation);
        });

        $("#testAct").click(function(){
            $("#responseMsg").removeClass("hidden");
            ajaxCall(url="/api/aliassync/service/test", sendData={},callback=function(data,status) {
                // action to run after reload
                $("#responseMsg").html(data['message']);
            });
        });

        // update history on tab state and implement navigation
        if(window.location.hash != "") {
            $('a[href="' + window.location.hash + '"]').click()
        }
        $('.nav-tabs a').on('shown.bs.tab', function (e) {
            history.pushState(null, null, e.target.hash);
        });
        $(window).on('hashchange', function(e) {
            $('a[href="' + window.location.hash + '"]').click()
        });
    });
</script>

<div class="alert alert-info hidden" role="alert" id="responseMsg">
</div>

<ul class="nav nav-tabs" data-tabs="tabs" id="maintabs">
    <li class="active"><a data-toggle="tab" href="#settings">{{ lang._('Configuration') }}</a></li>
    <li><a data-toggle="tab" href="#targets">{{ lang._('Targets') }}</a></li>
</ul>

<div class="tab-content content-box">
    <div id="settings" class="tab-pane fade in active">
        <!-- tab page "settings" -->
        {{ partial("layout_partials/base_form",['fields':formGeneral,'id':'frm_settings'])}}
    </div>
    <div id="targets" class="tab-pane">
        <!-- tab page "targets" -->
        <table id="grid-targets" class="table table-condensed table-hover table-striped table-responsive" data-editDialog="dlg_target">
            <thead>
            <tr>
                <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}</th>
                <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">{{ lang._('Enabled') }}</th>
                <th data-column-id="hostname" data-type="string">{{ lang._('Hostname') }}</th>
                <th data-column-id="apiKey" data-type="string" data-visible="false">{{ lang._('API Key') }}</th>
                <th data-column-id="description" data-type="string">{{ lang._('Description') }}</th>
                <th data-column-id="lastSync" data-formatter="datetime">{{ lang._('Last Sync') }}</th>
                <th data-column-id="statusLastSync" data-type="string">{{ lang._('Last Sync Status') }}</th>
                <th data-column-id="detailsLastSync" data-type="string" data-visible="false">{{ lang._('Last Sync Status') }}</th>
                <th data-column-id="lastSuccessfulSync" data-formatter="datetime">{{ lang._('Last Successful Sync') }}</th>
                <th data-column-id="commands" data-width="9em" data-formatter="commands" data-sortable="false">{{ lang._('Commands') }}</th>
            </tr>
            </thead>
            <tbody>
            </tbody>
            <tfoot>
            <tr>
                <td></td>
                <td>
                    <button data-action="add" type="button" class="btn btn-xs btn-default" title="{{ lang._('Add') }}"><span class="fa fa-plus"></span></button>
                    <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default" title="{{ lang._('Delete selected') }}"><span class="fa fa-trash-o"></span></button>
                </td>
            </tr>
            </tfoot>
        </table>
    </div>
    <div class="col-md-12">
        <hr/>
        <button class="btn btn-primary" id="saveAct" type="button"><b>{{ lang._('Apply') }}</b><i id="saveAct_progress" class=""></i></button>
        <br/><br/>
    </div>
</div>

{{ partial("layout_partials/base_dialog",['fields':formDialogTarget,'id':'dlg_target','label':lang._('Edit Target')])}}
