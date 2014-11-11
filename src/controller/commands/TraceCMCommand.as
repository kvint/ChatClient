/**
 * Created by AlexanderSla on 11.11.2014.
 */
package controller.commands {
	public class TraceCMCommand extends CMCommand {

		override protected function _execute():void {
			print("trace:");
			for(var i:int = 0; i < params.length; i++) {
				var string:String = params[i];
				print(string);
			}
		}
	}
}