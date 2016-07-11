/**
 * 此类是对截屏相关事件进行监听和分发的自定义事件类
 * @author xiamingxing
 * @version 0.1 AS3 implementation
 */
package com.screenshot
{
	import flash.events.Event;
	
	public class ScreenshotEvent extends Event
	{
		// 上传文件完成事件
		public static const	UPLOAD_COMPLETE_ACTION:String = "upload_complete_action";	
		
		// 截图完成事件
		public static const CLIP_COMPLETE_ATION:String = "clip_complete_action";
		
		// GIF格式截图完成事件
		public static const CLIP_GIF_COMPLETE_ATION:String = "clip_gif_complete_action";
		
		// JPG格式截图完成事件
		public static const CLIP_JPG_COMPLETE_ATION:String = "clip_jpg_complete_action";
		
		// 普通截图完成事件
		public static const CLIP_IMG_COMPLETE_ATION:String = "clip_img_complete_action";
		
		// 自定义object变量，用来传递参数
		private var object:Object;
		
		/**
		 * 
		 * @param type
		 * @param _object
		 * @param bubbles
		 * @param cancelable
		 * 
		 */
		public function ScreenshotEvent(type:String, _object:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			object = _object;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get params():Object { 
			return object; 
		} 
	}
}