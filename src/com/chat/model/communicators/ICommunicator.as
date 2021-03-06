/**
 * Created by kvint on 18.11.14.
 */
package com.chat.model.communicators {
	import com.chat.model.history.IHistoryProvider;

	public interface ICommunicator extends ICommunicatorBase {

		function get history():IHistoryProvider;

		function set unreadCount(value:int):void;
		function get unreadCount():int;

		function set active(value:Boolean):void;
		function get active():Boolean;

		function get uid():String;
		function set uid(value:String):void;

		function get type():int;

		function get name():String;
	}
}
