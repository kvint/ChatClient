/**
 * Created by kvint on 13.11.14.
 */
package com.chat.model.data.citems {
	public class CItemString implements ICItem {

		private var _data:String;

		public function CItemString(data:String) {
			super(data);
			_data = data;
		}

		public function get data():* {
			return _data;
		}

		public function toString():String {
			return _data;
		}
	}
}
