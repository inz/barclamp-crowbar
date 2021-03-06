% Copyright 2011, Dell 
% 
% Licensed under the Apache License, Version 2.0 (the "License"); 
% you may not use this file except in compliance with the License. 
% You may obtain a copy of the License at 
% 
%  http://www.apache.org/licenses/LICENSE-2.0 
% 
% Unless required by applicable law or agreed to in writing, software 
% distributed under the License is distributed on an "AS IS" BASIS, 
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
% See the License for the specific language governing permissions and 
% limitations under the License. 
% 
-module(crowbar_rest).
-export([step/3, g/1, validate/1, inspector/2]).
-export([get_id/2, get_id/3, create/3, create/4, create/5, create/6, destroy/3]).
-import(bdd_utils).
-import(json).

g(Item) ->
  case Item of
    _ -> crowbar:g(Item)
  end.

% validates JSON in a generic way common to all objects
validate(JSON) ->
  R = [true, % placeholder for createdat
       true, % placgit eholder for updatedat
       bdd_utils:is_a(JSON, name, name), 
       bdd_utils:is_a(JSON, dbid, id)],
  bdd_utils:assert(R, debug). 

% Common Routine - returns a list of items from the system, used for house keeping
inspector(Config, Feature) ->
  Raw = eurl:get(Config, apply(Feature, g, [path])),
  JSON = json:parse(Raw),
  [{Feature, ID, Name} || {ID, Name} <- JSON].
  
% given a path + key, returns the ID of the object
get_id(Config, Path, Key) -> 
  bdd_utils:log(Config, depricate, "DEPRICATED crowbar_rest:get_id1 -> moved to bdd_restrat"),
  bdd_restrat:get_id(Config, Path, Key).

   
% given a path, returns the ID of the object
get_id(Config, Path) ->
  bdd_utils:log(Config, depricate, "DEPRICATED crowbar_rest:get_id2 -> moved to bdd_restrat"),
  bdd_restrat:get_id(Config, Path).

% helper common to all setups using REST
create(Config, Path, JSON)         -> 
  bdd_utils:log(Config, depricate, "DEPRICATED crowbar_rest:create1 -> moved to bdd_restrat"),
  bdd_restrat:create(Config, Path, JSON, post).
create(Config, Path, JSON, Action) -> 
  bdd_utils:log(Config, depricate, "DEPRICATED crowbar_rest:create2 -> moved to bdd_restrat"),
  bdd_restrat:create(Config, Path, JSON, Action).
  
create(Config, Path, Atom, Name, JSON) ->
  bdd_utils:log(Config, depricate, "DEPRICATED crowbar_rest:create3 -> moved to bdd_restrat"),
  bdd_restrat:create(Config, Path, Atom, Name, JSON, post).

create(Config, Path, Atom, Name, JSON, Action) ->
  bdd_utils:log(Config, depricate, "DEPRICATED crowbar_rest:create4 -> moved to bdd_restrat"),
  bdd_restrat:create(Config, Path, Atom, Name, JSON, Action).

% helper common to all setups using REST
destroy(Config, Path, Atom) when is_atom(Atom) ->
  bdd_utils:log(Config, depricate, "DEPRICATED crowbar_rest:destroy1 -> moved to bdd_restrat"),
  bdd_restrat:destroy(Config, Path, Atom);

% helper common to all setups using REST
destroy(Config, Path, Key) ->
  bdd_utils:log(Config, depricate, "DEPRICATED crowbar_rest:destroy2 -> moved to bdd_restrat"),
  bdd_restrat:destroy(Config, Path, Key).

% NODES 
step(Config, _Global, {step_given, _N, ["there is a node",Node]}) -> 
  JSON = nodes:json(Node, nodes:g(description), 200),
  create(Config, nodes:g(path), JSON);

% remove the node
step(Config, _Given, {step_finally, _N, ["throw away node",Node]}) -> 
  eurl:delete(Config, nodes:g(path), Node);

% GROUPS
step(Config, _Global, {step_given, _N, ["there is a",Category,"group",Group]}) -> 
  JSON = groups:json(Group, groups:g(description), 200, Category),
  create(Config, groups:g(path), JSON, post);

% remove the group
step(Config, _Given, {step_finally, _N, ["throw away group",Group]}) -> 
  destroy(Config, groups:g(path), Group);


% ============================  THEN STEPS =========================================

% validate object based on basic rules for Crowbar
step(_Config, Result, {step_then, _N, ["the object is properly formatted"]}) -> 
  {ajax, JSON, _} = lists:keyfind(ajax, 1, Result),     % ASSUME, only 1 ajax result per feature
  validate(JSON);
  
% validate object based on it the validate method in it's ERL file (if any)
% expects an ATOM for the file
step(_Config, Result, {step_then, _N, ["the", Feature, "object is properly formatted"]}) -> 
  {ajax, JSON, _} = lists:keyfind(ajax, 1, Result),     % ASSUME, only 1 ajax result per feature
  apply(Feature, validate, [JSON]);

% validates a list of object IDs
step(_Config, Result, {step_then, _N, ["the object id list is properly formatted"]}) ->
  {ajax, JSON, _} = lists:keyfind(ajax, 1, Result),     % ASSUME, only 1 ajax result per feature
  NumberTester = fun(Value) -> bdd_utils:is_a(integer, Value) end,
  lists:all(NumberTester, JSON);

% ============================  LAST RESORT =========================================
step(_Config, _Given, {step_when, _N, ["I have a test that is not in WebRat"]}) -> true;
                                    
step(_Config, _Result, {step_then, _N, ["I should use my special step file"]}) -> true.
