package com.chat.model
{

	import flash.events.EventDispatcher;

import org.as3commons.logging.api.ILogger;

import org.as3commons.logging.api.getLogger;

import org.igniterealtime.xiff.collections.ArrayCollection;
	import org.igniterealtime.xiff.conference.IRoomOccupant;
	import org.igniterealtime.xiff.conference.Room;
	import org.igniterealtime.xiff.core.UnescapedJID;
	import org.igniterealtime.xiff.data.muc.MUCItem;
	import org.igniterealtime.xiff.events.RoomEvent;
	import org.igniterealtime.xiff.events.XIFFErrorEvent;

	public class ChatRoom extends EventDispatcher
	{
		private static const log			:ILogger 		= getLogger(ChatRoom);

		[Inject]
		public var model:IChatModel;

		private var _room:Room;
		private var _users:ArrayCollection;
		private var _owners:ArrayCollection;
		private var _admins:ArrayCollection;
		private var _moderators:ArrayCollection;
		private var _outcasts:ArrayCollection;
		
		public function ChatRoom(roomJID:UnescapedJID = null)
		{
			_room = new Room();
			_room.roomJID = roomJID; //TODO: Dirty

			addRoomListeners();
			
			_users = new ArrayCollection();
			_owners = new ArrayCollection();
			_admins = new ArrayCollection();
			_moderators = new ArrayCollection();
			_outcasts = new ArrayCollection();
		}

		public function get room():Room { return _room; }
		
		public function get users():ArrayCollection { return _users; }
		
		public function get owners():ArrayCollection { return _owners; }
		
		public function get admins():ArrayCollection { return _admins; }
		
		public function get moderators():ArrayCollection { return _moderators; }
		
		public function get outcasts():ArrayCollection { return _outcasts; }
		
		public function create( roomName:String ):void
		{
			_room.nickname = model.currentUser.displayName;
			_room.roomJID = new UnescapedJID( roomName + "@" + model.conferenceServer );
			_room.roomName = roomName;
			_room.connection = model.connection;
			
			_room.join( true );
		}
		
		public function join( roomJID:UnescapedJID, password:String = null ):void
		{
			if (model.currentUser.displayName == null || model.currentUser.displayName == "null")
				log.debug("CHAT ROOM JOIN, user nickname is NULL");

			_room.nickname = model.currentUser.displayName;
			_room.roomJID = roomJID;
			_room.connection = model.connection;
			_room.password = password;
			_room.join();
		}
		
		public function leave():void
		{
			_users.removeAll();
			_owners.removeAll();
			_admins.removeAll();
			_moderators.removeAll();
			_outcasts.removeAll();
			_room.leave();
			_room = new Room();
		}
		
		public function destroy( reason:String = null, alternateJID:UnescapedJID=null, callback:Function=null ):void
		{
			_users.removeAll();
			_owners.removeAll();
			_admins.removeAll();
			_moderators.removeAll();
			_outcasts.removeAll();
			if(reason){
				_room.destroy( reason, alternateJID, callback );
			}else{
				_room.removeAll();
				removeRoomListeners();
			}
		}
		
		public function sendMessage( body:String ):void
		{
			_room.sendMessage( body );
		}
		
		private function removeUserByNickname( nickname:String ):ChatUser
		{
			var chatUser:ChatUser = getUserByNickname(nickname);
			var removed:Boolean;
			if( chatUser )
			{
				removed = _users.removeItem( chatUser );
				if( removed ) return chatUser;
			}

			return null;
		}

		public function getUserByNickname(nickname:String):ChatUser {
			for each(var user:ChatUser in _users.source) {
				if (user.displayName == nickname) {
					return user;
				}
			}
			return null;
		}

		private function requestAffiliations( affiliation:String ):void
		{
			if( _room.role ==  Room.ROLE_MODERATOR )
			{
				if( affiliation == Room.AFFILIATION_OWNER ) _owners.removeAll();
				if( affiliation == Room.AFFILIATION_ADMIN ) _admins.removeAll();
				if( affiliation == Room.AFFILIATION_OUTCAST ) _outcasts.removeAll();
				_room.requestAffiliations( affiliation );
			}
		}
		
		private function addRoomListeners():void
		{
			_room.addEventListener( RoomEvent.GROUP_MESSAGE, onGroupMessage);
			_room.addEventListener( RoomEvent.ADMIN_ERROR, onAdminError);
			_room.addEventListener( RoomEvent.AFFILIATION_CHANGE_COMPLETE, onAffiliationChangeComplete);
			_room.addEventListener( RoomEvent.AFFILIATIONS, onAffiliations);
			_room.addEventListener( RoomEvent.CONFIGURE_ROOM, onConfigureRoom);
			_room.addEventListener( RoomEvent.CONFIGURE_ROOM_COMPLETE, onConfigureRoomComplete);
			_room.addEventListener( RoomEvent.DECLINED, onDeclined);
			_room.addEventListener( RoomEvent.NICK_CONFLICT, onNickConflict);
			_room.addEventListener( RoomEvent.PRIVATE_MESSAGE, onPrivateMessage);
			_room.addEventListener( RoomEvent.ROOM_DESTROYED, onRoomDestroyed);
			_room.addEventListener( RoomEvent.ROOM_JOIN, onRoomJoin);
			_room.addEventListener( RoomEvent.ROOM_LEAVE, onRoomLeave);
			_room.addEventListener( RoomEvent.SUBJECT_CHANGE, onSubjectChange);
			_room.addEventListener( RoomEvent.USER_DEPARTURE, onUserDeparture);
			_room.addEventListener( RoomEvent.USER_JOIN, onUserJoin);
			_room.addEventListener( RoomEvent.USER_KICKED, onUserKicked);
			_room.addEventListener( RoomEvent.USER_BANNED, onUserBanned);
		}
		
		private function removeRoomListeners():void
		{
			_room.removeEventListener( RoomEvent.GROUP_MESSAGE, onGroupMessage );
			_room.removeEventListener( RoomEvent.ADMIN_ERROR, onAdminError );
			_room.removeEventListener( RoomEvent.AFFILIATION_CHANGE_COMPLETE, onAffiliationChangeComplete );
			_room.removeEventListener( RoomEvent.AFFILIATIONS, onAffiliations );
			_room.removeEventListener( RoomEvent.CONFIGURE_ROOM, onConfigureRoom );
			_room.removeEventListener( RoomEvent.CONFIGURE_ROOM_COMPLETE, onConfigureRoomComplete );
			_room.removeEventListener( RoomEvent.DECLINED, onDeclined );
			_room.removeEventListener( RoomEvent.NICK_CONFLICT, onNickConflict );
			_room.removeEventListener( RoomEvent.PRIVATE_MESSAGE, onPrivateMessage );
			_room.removeEventListener( RoomEvent.ROOM_DESTROYED, onRoomDestroyed );
			_room.removeEventListener( RoomEvent.ROOM_JOIN, onRoomJoin );
			_room.removeEventListener( RoomEvent.ROOM_LEAVE, onRoomLeave );
			_room.removeEventListener( RoomEvent.SUBJECT_CHANGE, onSubjectChange );
			_room.removeEventListener( RoomEvent.USER_DEPARTURE, onUserDeparture );
			_room.removeEventListener( RoomEvent.USER_JOIN, onUserJoin );
			_room.removeEventListener( RoomEvent.USER_KICKED, onUserKicked );
			_room.removeEventListener( RoomEvent.USER_BANNED, onUserBanned );
		}
		
		
		private function onGroupMessage( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onAdminError( event:RoomEvent ):void
		{
			var xiffErrorEvent:XIFFErrorEvent = new XIFFErrorEvent();
			xiffErrorEvent.errorCode = event.errorCode;
			xiffErrorEvent.errorCondition = event.errorCondition;
			xiffErrorEvent.errorMessage = event.errorMessage;
			xiffErrorEvent.errorType = event.errorType;
			dispatchEvent( xiffErrorEvent );
		}
		
		private function onAffiliationChangeComplete( event:RoomEvent ):void
		{
			requestAffiliations( Room.AFFILIATION_ADMIN );
			requestAffiliations( Room.AFFILIATION_OUTCAST );
		}
		
		private function onAffiliations( event:RoomEvent ):void
		{
			var mucItems:Array = event.data as Array;
			
			for each( var muc:MUCItem in mucItems )
			{
				var chatUser:ChatUser = new ChatUser( muc.jid.unescaped );
				chatUser.displayName = muc.nick;
				chatUser.loadVCard( model.connection );
				
				if( muc.affiliation == Room.AFFILIATION_OWNER )
				{
					_owners.addItem( chatUser );
				}
				if( muc.affiliation == Room.AFFILIATION_ADMIN )
				{
					_admins.addItem( chatUser );
				}
				else if(  muc.affiliation == Room.AFFILIATION_OUTCAST )
				{
					_outcasts.addItem( chatUser );
				}
			}
			
			dispatchEvent( event );
		}
		
		private function onConfigureRoom( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onConfigureRoomComplete( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onDeclined( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onNickConflict( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onPrivateMessage( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onRoomDestroyed( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onRoomJoin( event:RoomEvent ):void
		{
			requestAffiliations( Room.AFFILIATION_ADMIN );
			requestAffiliations( Room.AFFILIATION_OUTCAST );
			
			dispatchEvent( event );
		}
		
		private function onRoomLeave( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onSubjectChange( event:RoomEvent ):void
		{
			dispatchEvent( event );
		}
		
		private function onUserDeparture( event:RoomEvent ):void
		{
			removeUserByNickname( event.nickname );
			dispatchEvent( event );
		}
		
		private function onUserJoin( event:RoomEvent ):void
		{
			var occupant:IRoomOccupant = room.getOccupantNamed( event.nickname );
			if( !occupant ) return;
			
			var chatUser:ChatUser = new ChatUser( occupant.jid );
			chatUser.displayName = event.nickname;

			for each( var user:ChatUser in _users.source )
			{
				if( user.displayName == event.nickname )
				{
					return;
				}
			}
			if(chatUser.jid){
				chatUser.loadVCard( model.connection );
			}
			_users.addItem( chatUser );
			
			dispatchEvent( event );
		}
		
		private function onUserKicked( event:RoomEvent ):void
		{
			removeUserByNickname( event.nickname );
			
			dispatchEvent( event );
		}
		
		private function onUserBanned( event:RoomEvent ):void
		{
			removeUserByNickname( event.nickname );
			
			requestAffiliations( Room.AFFILIATION_OUTCAST );
			
			dispatchEvent( event );
		}
		
	}
}