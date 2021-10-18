-module(ros_node_sup).

-behaviour(supervisor).

-export([start_link/1]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link(NodeName) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, NodeName).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional

init(NodeName) ->
    %io:format("~p.erl STARTED!\n",[?MODULE]),
    SupFlags =
        #{strategy => one_for_all,
          intensity => 0,
          period => 1},

    SUBSCRIPTIONS_SUP =
        #{id => ros_subscriptions_sup,
          start => {ros_subscriptions_sup, start_link, []},
          restart => permanent,
          shutdown => 5000,
          type => supervisor},

    PUBLICATIONS_SUP =
        #{id => ros_publishers_sup,
          start => {ros_publishers_sup, start_link, []},
          restart => permanent,
          shutdown => 5000,
          type => supervisor},

    CLIENTS_SUP =
        #{id => ros_clients_sup,
          start => {ros_clients_sup, start_link, []},
          restart => permanent,
          shutdown => 5000,
          type => supervisor},

    SERVICES_SUP =
        #{id => ros_services_sup,
          start => {ros_services_sup, start_link, []},
          restart => permanent,
          shutdown => 5000,
          type => supervisor},

    NODE =
        #{id => ros_node,
          start => {ros_node, start_link, [NodeName]},
          restart => permanent,
          shutdown => 5000,
          type => worker},

    ChildSpecs = [SUBSCRIPTIONS_SUP, PUBLICATIONS_SUP, CLIENTS_SUP, SERVICES_SUP, NODE],

    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
