/**
 * 此类是对as3gif包中GIFPlayer类的封装，可以帮助用户实现gif动画的播放功能
 * @author xiamingxing
 * @version 0.1 AS3 implementation
 */
package com.screenshot
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import flash.net.URLRequest;
	import org.bytearray.gif.player.GIFPlayer;

	public class GifPlayer extends Sprite
	{
		private var player:GIFPlayer;

		/**
		 * 
		 * @param autoPlay
		 * 
		 */
		public function GifPlayer(autoPlay:Boolean = true)
		{
			player = new GIFPlayer(autoPlay);
			addChild(player);
		}
		
		/**
		 * 
		 * @param byteArray
		 * 
		 */
		public function play(byteArray:ByteArray):void {
			player.loadBytes(byteArray);
		}
		
		/**
		 * 
		 * @param url
		 * 
		 */
		public function playByUrl(url:String):void {
			var request:URLRequest = new URLRequest(url);
			player.load(request);
		}
		
		/**
		 * 
		 * 
		 */
		public function destory():void {
			removeChild(player);
		}
	}
}