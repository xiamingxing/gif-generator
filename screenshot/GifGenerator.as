/**
 * 此类是对as3gif包中GIFEncoder类的封装，可以帮助用户实现插入、添加动画帧，并最终生成gif二进制流的需求
 * @author xiamingxing
 * @version 0.1 AS3 implementation
 */
package com.screenshot
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	import org.bytearray.gif.encoder.GIFEncoder;

	public class GifGenerator
	{
		// GIFEncoder类的引用
		private var gifEncoder:GIFEncoder;
		
		// 动画帧缓存列表
		private var frameList:Array;
		
		// 生成gif的属性缓存对象
		private var props:Object;
		
		private var isGenerating:Boolean;
		
		// 插入帧数上限
		public static const MAX_FRAME_LIMIT:int = 300;
		
		
		/**
		 * 
		 * @param _props
		 * 
		 */
		public function GifGenerator(_props:Object = null)
		{
			props = new Object;
			frameList = new Array;
			props = new Object;
			gifEncoder = new GIFEncoder;
			setProps(_props || {});
			isGenerating = false;
		}
		
		/**
		 * 
		 * @param _props
		 * 
		 */
		public function setProps(_props:Object):void {
			for (var key:String in _props){
				setProp(key, _props[key]);
			}
		}
		
		/**
		 * 
		 * @param key
		 * @param value
		 * 
		 */
		public function setProp(key:String, value:Number):void {
			props[key] = value;
		}
		
		/**
		 * 
		 * 将缓存的gif对象的属性写入到GIFEncoder中 
		 * @param key
		 * @param value
		 * 
		 */
		private function updateGifEncoderProp(key:String, value:Number):void {
			switch (key){
				case 'dispose':
					gifEncoder.setDispose(value);
					break;
				case 'repeat':
					gifEncoder.setRepeat(value);
					break;
				case 'transparent':
					gifEncoder.setTransparent(value);
					break;
				case 'frameRate':
					gifEncoder.setFrameRate(value);
					break;
				case 'quality':
					gifEncoder.setQuality(value);
					break;
				case 'delay':
					gifEncoder.setDelay(value);
					break;
			}	
		}
		
		/**
		 *	将缓存的gif对象的所有属性写入到GIFEncoder中 
		 * 
		 */
		private function updateGifEncoderAllProps():void {
			for (var key:String in props){
				updateGifEncoderProp(key, props[key]);
			}
		}
		
		/**
		 * 
		 * @param index
		 * @param frameData
		 * 
		 */
		public function setFrame(index:int, frameData:BitmapData):void {
			if (index > GifGenerator.MAX_FRAME_LIMIT){
				throw new Error ("插入的帧数不能超过MAX_FRAME_LIMIT");
			}
			frameList[index] = frameData;
		}
		
		/**
		 * 
		 * @param frameData
		 * 
		 */
		public function addFrame(frameData:BitmapData):void {
			if (frameList.length > GifGenerator.MAX_FRAME_LIMIT){
				throw new Error ("插入的帧数不能超过MAX_FRAME_LIMIT");
			}
			frameList.push(frameData);
		}
		
		/**
		 * 
		 * @param frameDatas
		 * @param isAppend
		 * 
		 */
		public function addFrames(frameDatas:Array, isAppend:Boolean = false):void{
			if (frameList.length + frameDatas.length > GifGenerator.MAX_FRAME_LIMIT){
				throw new Error ("插入的帧数不能超过MAX_FRAME_LIMIT");
			}
			if (isAppend){
				frameList = frameList.concat(frameDatas);
			}
			else {
				frameList = frameDatas;
			}
		}
		
		/**
		 * 
		 * 将缓存的帧动画通过依次添加到GIFEncoder中
		 * 
		 */
		private function dumpFramesToGifEncoder():void {
			for (var i:int = 0, l:int=frameList.length; i < l; i++){
				var item:BitmapData = frameList[i];
				if (!gifEncoder.addFrame(item)){
					throw new Error ("帧插入错误");
				}
			}
		}
		
		/**
		 * 
		 * 将缓存的帧动画通过GIFEncoder生成GIF流
		 * 
		 */
		private function generateStream():void {
			updateGifEncoderAllProps();
			gifEncoder.start();
			dumpFramesToGifEncoder();
			gifEncoder.finish();
		}
		
		/**
		 * 
		 * @return gif的二进制流
		 * 
		 */
		public function getStream():ByteArray {
			generateStream();
			return gifEncoder.stream;
		}
		
		/**
		 * 
		 * @param bitmapData
		 * 
		 */
		public function generateGifFrame(bitmapData:BitmapData):void {
			if (!isGenerating){
				isGenerating = true;
				updateGifEncoderAllProps();
				gifEncoder.start();
			}
			gifEncoder.addFrame(bitmapData);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getGeneratedGifStream():ByteArray {
			if (isGenerating){
				isGenerating = false;
				gifEncoder.finish();
				return gifEncoder.stream;
			}
			return null;
		}
	}
}