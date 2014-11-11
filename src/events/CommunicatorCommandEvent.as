/**
 * Created by AlexanderSla on 11.11.2014.
 */
package events {
	import flash.events.Event;

	import model.communicators.ICommunicator;

	public class CommunicatorCommandEvent extends Event {

		public static const HELP:String = "help";
		public static const PRIVATE_MESSAGE:String = "privateMessage";
		public static const TRACE:String = "trace";
		public static const CLEAR:String = "clear";
		public static const CREATE_ROOM:String = "roomCreate";
		public static const JOIN_ROOM:String = "joinRoom";

		private var _communicator:ICommunicator;
		private var _params:Array;

		public function CommunicatorCommandEvent(type:String, communicator:ICommunicator, params:Array) {
			super(type, false, false);
			_params = params;
			_communicator = communicator;
		}

		public function get communicator():ICommunicator {
			return _communicator;
		}

		public function get params():Array {
			return _params;
		}
	}
}
