%%%-------------------------------------------------------------------
%%% @author c50 <joq62@c50>
%%% @copyright (C) 2023, c50
%%% @doc
%%%
%%% @end
%%% Created : 18 Apr 2023 by c50 <joq62@c50>
%%%-------------------------------------------------------------------
-module(sd).

%%--------------------------------------------------------------------
%% Include 
%%
%%--------------------------------------------------------------------

%-include("log.api").


%% API
-export([
	 get_node/1,
	 call/5,
	 cast/4,
	 all/0

	]).

%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
all()->
    Apps=[{Node,rpc:call(Node,net,gethostname,[],5*1000),
	   rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    Result=[{Node,HostName,AppList}||{Node,{ok,HostName},AppList}<-Apps,
				    AppList/={badrpc,nodedown}],
    Result.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
call(App,M,F,A,Timeout)->
    Result=case local_get_node(App) of
	       []->
		   {error,["No node available for app : ",App,?MODULE,?LINE]};
	       [Node|_]->
		   rpc:call(Node,M,F,A,Timeout)
	   end,
    Result.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
cast(App,M,F,A)->
    Result=case local_get_node(App) of
	       []->
		   {error,["No node available for app : ",App,?MODULE,?LINE]};
	       [Node|_]->
		   rpc:cast(Node,M,F,A)
	   end,
    Result.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
get_node(WantedApp)->
    Apps=[{Node,rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    Result=[Node||{Node,AppList}<-Apps,
		 AppList/={badrpc,nodedown},
		 AppList/={badrpc,timeout},
		 true==lists:keymember(WantedApp,1,AppList)],
    Result.


%%%===================================================================
%%% Internal functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------
local_get_node(WantedApp)->
    Apps=[{Node,rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    [Node||{Node,AppList}<-Apps,
	   AppList/={badrpc,nodedown},
	   AppList/={badrpc,timeout},
	   true==lists:keymember(WantedApp,1,AppList)].
