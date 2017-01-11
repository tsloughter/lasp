%% -------------------------------------------------------------------
%%
%% Copyright (c) 2016 Christopher Meiklejohn.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

-module(lasp_config).
-author("Christopher Meiklejohn <christopher.meiklejohn@gmail.com>").

-include("lasp.hrl").

-export([init/0,
         dispatch/0,
         set/2,
         get/1,
         get/2,
         peer_service_manager/0,
         web_config/0]).

init() ->
    [env_or_default(Key, Default) ||
        {Key, Default} <- [{aae_interval, 10000},
                           {automatic_contraction, false},
                           {broadcast, false},
                           {client_number, 3},
                           {dag_enabled, false},
                           {delta_interval, 10000},
                           {distribution_backend, ?DEFAULT_DISTRIBUTION_BACKEND},
                           {evaluation_identifier, undefined},
                           {evaluation_timestamp, 0},
                           {extended_logging, false},
                           {heartbeat_interval, 10000},
                           {heavy_client, false},
                           {instrumentation, false},
                           {jitter, false},
                           {join_decompositions, false},
                           {lasp_server, undefined},
                           {mailbox_logging, false},
                           {max_players, ?MAX_PLAYERS_DEFAULT},
                           {memory_report, false},
                           {mode, state_based},
                           {partition_probability, 0},
                           {peer_refresh_interval, ?PEER_REFRESH_INTERVAL},
                           {reactive_server, false},
                           {simulation, undefined},
                           {storage_backend, lasp_ets_storage_backend},
                           {tutorial, false},
                           {web_port, random_port()},
                           {peer_port, random_port()}]],
    ok.

env_or_default(Key, Default) ->
    case application:get_env(lasp, Key) of
        undefined ->
            set(Key, Default);
        {ok, undefined} ->
            set(Key, Default);
        {ok, Value} ->
            set(Key, Value)
    end.

get(Key) ->
    lasp_mochiglobal:get(Key).

get(Key, Default) ->
    lasp_mochiglobal:get(Key, Default).

set(Key, Value) ->
    application:set_env(?APP, Key, Value),
    lasp_mochiglobal:put(Key, Value).

dispatch() ->
    lists:flatten([
        {["api", "kv", id, type],   lasp_kv_resource,           undefined},
        {["api", "plots"],          lasp_plots_resource,        undefined},
        {["api", "logs"],           lasp_logs_resource,         undefined},
        {["api", "health"],         lasp_health_check_resource, undefined},
        {["api", "status"],         lasp_status_resource,       undefined},
        {["api", "dag"],            lasp_dag_resource,          undefined},
        {[],                        lasp_gui_resource,          index},
        {['*'],                     lasp_gui_resource,          undefined}
    ]).

web_config() ->
    {ok, App} = application:get_application(?MODULE),
    {ok, Ip} = application:get_env(App, web_ip),
    Port = lasp_config:get(web_port, 8080),
    Config = [
        {ip, Ip},
        {port, Port},
        {log_dir, "priv/log"},
        {dispatch, dispatch()}
    ],
    Node = node(),
    lager:info("Node ~p enabling web configuration: ~p", [Node, Config]),
    Config.

%% @private
peer_service_manager() ->
    partisan_config:get(partisan_peer_service_manager,
                        partisan_default_peer_service_manager).

%% @private
random_port() ->
    {ok, Socket} = gen_tcp:listen(0, []),
    {ok, {_, Port}} = inet:sockname(Socket),
    ok = gen_tcp:close(Socket),
    Port.
