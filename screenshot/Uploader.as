/**
 * 此类是对文件上传方法的简单封装
 * @author xiamingxing
 * @version 0.1 AS3 implementation
 */
package com.screenshot
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	public class Uploader extends EventDispatcher
	{

		public static const CONTENTTYPE_STREAM:String = "application/octet-stream";
		
		private var urlLoader:URLLoader;
		
		public function Uploader()
		{
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onComplete);
		}
		
		/**
		 * 上传文件方法
		 * @param params
		 * 
		 */
		public function upload(params:Object = null):void {
			params = params || {};
			
			var urlRequest:URLRequest = new URLRequest(params.url);
			urlRequest = new URLRequest(params.url);
			urlRequest.contentType = params.contentType || Uploader.CONTENTTYPE_STREAM;
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = params.data;
			
			if (params.callback && params.callback is Function){

				var handle:Function = function (evt:Event):void{
					params.callback(new ScreenshotEvent(ScreenshotEvent.UPLOAD_COMPLETE_ACTION, evt.target.data));
					urlLoader.removeEventListener(Event.COMPLETE, handle);
				};
				
				urlLoader.addEventListener(Event.COMPLETE, handle);
				
			}
			urlLoader.load(urlRequest);
		}
		
		/**
		 *  上传文件方法
		 * @param url
		 * @param data
		 * @param callback
		 * 
		 */
		public function uploadData(url:String, data:ByteArray, callback:Function):void {
			upload({
				data: data,
				url: url,
				callback: callback
			});
		}
		
		
		/**
		 * 上传完成的回调，并会进行ScreenshotEvent自定义UPLOAD_COMPLETE_ACTION事件分发
		 * @param evt
		 * 
		 */
		private function onComplete(evt:Event):void {
			this.dispatchEvent(new ScreenshotEvent(ScreenshotEvent.UPLOAD_COMPLETE_ACTION, evt.target.data));
		}
	}
}