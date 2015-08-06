-module(cth_readable_shell).

-define(OK(Suite,Str,Args), io:format(user, colorize(green, "%%% ~p ==> "++Str++"~n"), [Suite|Args])).
-define(FAIL(Suite,Str,Args), io:format(user, colorize(red, "%%% ~p ==> "++Str++"~n"), [Suite|Args])).
-define(SKIP(Suite,Str,Args), io:format(user, colorize(magenta, "%%% ~p ==> "++Str++"~n"), [Suite|Args])).

%% Callbacks
-export([id/1]).
-export([init/2]).

-export([pre_init_per_suite/3]).
-export([post_init_per_suite/4]).
-export([pre_end_per_suite/3]).
-export([post_end_per_suite/4]).

-export([pre_init_per_group/3]).
-export([post_init_per_group/4]).
-export([pre_end_per_group/3]).
-export([post_end_per_group/4]).

-export([pre_init_per_testcase/3]).
-export([post_end_per_testcase/4]).

-export([on_tc_fail/3]).
-export([on_tc_skip/3]).

-export([terminate/1]).

-record(state, {id, suite}).

%% @doc Return a unique id for this CTH.
id(_Opts) ->
    {?MODULE, make_ref()}.

%% @doc Always called before any other callback function. Use this to initiate
%% any common state. 
init(Id, _Opts) ->
    {ok, #state{id=Id}}.

%% @doc Called before init_per_suite is called. 
pre_init_per_suite(Suite,Config,State) ->
    {Config, State#state{suite=Suite}}.

%% @doc Called after init_per_suite.
post_init_per_suite(_Suite,_Config,Return,State) ->
    {Return, State}.

%% @doc Called before end_per_suite.
pre_end_per_suite(_Suite,Config,State) ->
    {Config, State}.

%% @doc Called after end_per_suite.
post_end_per_suite(_Suite,_Config,Return,State) ->
    {Return, State}.

%% @doc Called before each init_per_group.
pre_init_per_group(_Group,Config,State) ->
    {Config, State}.

%% @doc Called after each init_per_group.
post_init_per_group(_Group,_Config,Return,State) ->
    {Return, State}.

%% @doc Called after each end_per_group.
pre_end_per_group(_Group,Config,State) ->
    {Config, State}.

%% @doc Called after each end_per_group.
post_end_per_group(_Group,_Config,Return,State) ->
    {Return, State}.

%% @doc Called before each test case.
pre_init_per_testcase(_TC,Config,State) ->
    {Config, State}.

%% @doc Called after each test case.
post_end_per_testcase(TC,_Config,ok,State=#state{suite=Suite}) ->
    ?OK(Suite, "~p: OK", [TC]),
    {ok, State};
post_end_per_testcase(_TC,_Config,Error,State) ->
    {Error, State}.

%% @doc Called after post_init_per_suite, post_end_per_suite, post_init_per_group,
%% post_end_per_group and post_end_per_testcase if the suite, group or test case failed.
on_tc_fail({TC,Group}, Reason, State=#state{suite=Suite}) ->
    ?FAIL(Suite, "~p (group ~p): FAILED", [TC, Group]),
    ?FAIL(Suite, "\t~p", [Reason]),
    State;
on_tc_fail(TC, Reason, State=#state{suite=Suite}) ->
    ?FAIL(Suite, "~p: FAILED", [TC]),
    ?FAIL(Suite, "\t~p", [Reason]),
    State.

%% @doc Called when a test case is skipped by either user action
%% or due to an init function failing.
on_tc_skip({TC,Group}, Reason, State=#state{suite=Suite}) ->
    ?SKIP(Suite, "~p (group ~p): SKIPPED", [TC, Group]),
    ?SKIP(Suite, "\t~p", [Reason]),
    State;
on_tc_skip(TC, Reason, State=#state{suite=Suite}) ->
    ?SKIP(Suite, "~p: SKIPPED", [TC]),
    ?SKIP(Suite, "\t~p", [Reason]),
    State.

%% @doc Called when the scope of the CTH is done
terminate(_State) ->
    ok.

%%% Helpers
colorize(red, Txt) -> colorize(31, Txt);
colorize(green, Txt) -> colorize(32, Txt);
colorize(magenta, Txt) -> colorize(35, Txt);
colorize(Code, Txt) when is_integer(Code) ->
    lists:flatten([
        io_lib:format("\033[0;~Bm",[Code]),
        Txt,
        "\033[0m"
    ]).