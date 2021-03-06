open EzSession.TYPES

module type SessionStore = sig
  val create_session : login:string -> session
  val get_session : cookie:string -> session option
  val remove_session : login:string -> cookie:string -> unit
end

module Make(S: sig
                module SessionArg : EzSession.TYPES.SessionArg
                module SessionStore : SessionStore
                val find_user :
                  login:string ->
                  (string * (* pwhash *)
                     SessionArg.user_info) option
              end) : sig

  (* User `register_handlers` to declare the handlers for the authentification
     services *)
  val register_handlers :
    EzAPI.request EzAPIServer.directory ->
    EzAPI.request EzAPIServer.directory

 (* handlers that need authentification should use `get_request_session`
   to collect the user identity and session. *)
  val get_request_session : EzAPI.request -> session option

end





exception UserAlreadyDefined
exception NoPasswordProvided
module UserStoreInMemory(S : SessionArg) : sig

  val create_user :
    ?pwhash:Digest.t ->
    ?password:string -> login:string -> S.user_info -> unit
  val remove_user : login:string -> unit
  val find_user : login:string -> (string * S.user_info) option

  module SessionArg : EzSession.TYPES.SessionArg
         with type user_info = S.user_info
  module SessionStore : SessionStore

end

module SessionStoreInMemory : SessionStore
