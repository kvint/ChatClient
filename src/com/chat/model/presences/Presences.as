/**
 * Created by AlexanderSla on 21.11.2014.
 */
package com.chat.model.presences {
	import flash.utils.Dictionary;

	import org.igniterealtime.xiff.data.IPresence;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.data.muc.MUCItem;
	import org.igniterealtime.xiff.data.muc.MUCUserExtension;

	public class Presences implements IPresences, IPresencesHandler {

		private var _statuses:Vector.<IPresenceStatus> = new <IPresenceStatus>[];
		private var _presences:Dictionary = new Dictionary();

		public function handlePresence(presence:IPresence):void {
			var allExtensionsByNS:Array = presence.getAllExtensionsByNS(MUCUserExtension.NS);

			if(allExtensionsByNS){
				//It's muc
				for(var i:int = 0; i < allExtensionsByNS.length; i++) {
					var userExtension:MUCUserExtension = allExtensionsByNS[i];
					for(var j:int = 0; j < userExtension.items.length; j++) {
						var mucItem:MUCItem = userExtension.items[j];
						storePresence(presence, mucItem.jid.bareJID);
					}
				}
			}else{
				if(presence.from){
					storePresence(presence, presence.from.bareJID);
				}
			}
		}
		public function subscribe(status:IPresenceStatus):void {
			if(_statuses.indexOf(status) == -1){
				_statuses.push(status);
				updatePresenceStatus(status);
			}
		}

		public function unsubscribe(status:IPresenceStatus):void {
			var index:Number = _statuses.indexOf(status);
			if(index != -1){
				_statuses.splice(index, 1);
			}
		}

		public function getByUID(uid:String):IPresence {
			return _presences[uid];
		}

		private function storePresence(presence:IPresence, uid:String):void {
			if(presence.type == Presence.TYPE_UNAVAILABLE || presence.type == Presence.TYPE_UNSUBSCRIBED){
				delete _presences[uid];
			}else{
				_presences[uid] = presence;
			}
			updateStatusesByUID(uid);
		}

		private function updateStatusesByUID(uid:String):void {
			var statuses:Vector.<IPresenceStatus> = _statuses.filter(function(obj:IPresenceStatus, index:int, arr:Vector.<IPresenceStatus>):Boolean{
				return obj.uid == uid;
			});

			for(var i:int = 0; i < statuses.length; i++) {
				var status:IPresenceStatus = statuses[i];
				updatePresenceStatus(status);
			}
		}

		private function updatePresenceStatus(presencable:IPresenceStatus):void {
			presencable.online = getByUID(presencable.uid) != null;
		}
	}
}
