%% @doc Test that streaming bind of an insertion sort works.

-module(derflow_get_minimum_test).
-author("Christopher Meiklejohn <cmeiklejohn@basho.com>").

-export([test/1,
         insort/2,
         insert/3]).

-define(TABLE, minimum).

-ifdef(TEST).

-export([confirm/0]).

-define(HARNESS, (rt_config:get(rt_harness))).

-include_lib("eunit/include/eunit.hrl").

confirm() ->
    [Nodes] = rt:build_clusters([3]),
    lager:info("Nodes: ~p", [Nodes]),
    Node = hd(Nodes),

    lager:info("Remotely loading code on node ~p", [Node]),
    ok = derflow_test_helpers:load(Nodes),
    lager:info("Remote code loading complete."),

    lager:info("Remotely executing the get minimum test."),
    Result = rpc:call(Node, derflow_get_minimum_test, test, [[1,2,3,4,5]]),
    ?assertEqual(1, Result),
    pass.

-endif.

test(List) ->
    {ok, S1} = derflow:declare(),
    ?TABLE = ets:new(?TABLE, [set, named_table, public, {write_concurrency, true}]),
    true = ets:insert(?TABLE, {count, 0}),
    derflow:thread(derflow_get_minimum_test, insort, [List, S1]),
    {ok, V, _} = derflow:read(S1),
    V.

insort(List, S) ->
    case List of
        [H|T] ->
            {ok, OutS} = derflow:declare(),
            insort(T, OutS),
            derflow:thread(derflow_get_minimum_test, insert, [H, OutS, S]);
        [] ->
            derflow:bind(S, nil)
    end.

insert(X, In, Out) ->
    [{Id, C}] = ets:lookup(?TABLE, count),
    true = ets:insert(?TABLE, {Id, C+1}),
    ok = derflow:wait_needed(Out),
    case derflow:read(In) of
        {ok, nil, _} ->
            {ok, Next} = derflow:bind(Out, X),
            derflow:bind(Next, nil);
        {ok, V, SNext} ->
            if
                X < V ->
                    {ok, Next} = derflow:bind(Out, X),
                    derflow:bind(Next, In);
                true ->
                    {ok, Next} = derflow:bind(Out, V),
                    insert(X, SNext, Next)
            end
    end.