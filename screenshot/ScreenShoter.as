/**
 * 此类是视频截屏的主类，实现了视频截屏的各种基础方法
 * @author xiamingxing
 * @version 0.1 AS3 implementation
 */
package com.screenshot
{
	import com.adobe.images.JPGEncoder;
	import com.demonsters.debugger.MonsterDebugger;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import org.osmf.events.TimeEvent;
	
	public class Screenshoter extends EventDispatcher
	{	
		// 自动截屏时，默认截图频率
		public static const DEFAULT_CLIP_FRAME_RATE:int = 5;
		
		// 自动截屏时，默认的截图次数
		public static const DEFAULT_CLIP_TIMES:int = 3;
		
		// 供截屏的数据源
		private var source:IBitmapDrawable;
		
		// 截屏的属性
		private var width:int;
		private var height:int;
		private var martrix:Matrix;
		private var frameRate:int;
		private var quality:int;
		
		// 动画帧的缓存列表
		private var bitmapDatas:Array;
		
		// 判定当前截屏是否已经结束
		private var isStop:Boolean;
		
		// 自动截屏的定时器
		private var clipTimerId:int; 
		
		/**
		 * 构造函数，初始化时，需要传入截屏所需要的参数
		 * @param _source
		 * @param _width
		 * @param _height
		 * @param _martrix
		 * @param _frameRate
		 * @param _quality
		 * 
		 */
		public function Screenshoter(_source:IBitmapDrawable, _width:int, _height:int, _martrix:Matrix, _frameRate:int, _quality:Number = 50){
			source = _source;
			width = _width;
			height = _height;
			martrix = _martrix;
			frameRate = _frameRate;
			quality = _quality; 
			isStop = true;
		}
		
		/**
		 * 开启自动截屏
		 * @param frameRate为自动截屏的频率
		 * 
		 */
		public function startClip(frameRate:int = Screenshoter.DEFAULT_CLIP_FRAME_RATE, everyCallback:Function = null):void{
			
			if (!(source && isStop)){
				return ;
			}
			
			isStop = false;
			bitmapDatas = new Array;
			
			var clipTimerId:int = setInterval(function ():void{
				
				if (isStop){
					clearInterval(clipTimerId);
					onClipComplete(bitmapDatas);
				}
				
				var bitmapData:BitmapData = clip(source, width, height, martrix);
				if (everyCallback != null){
					everyCallback(bitmapData);
				}
				bitmapDatas.push(bitmapData);
				
			}, 1000 / frameRate);
		}
		
		/**
		 * 自动截屏完成
		 * @param callback
		 * 
		 */
		public function stopClip(completeCallback:Function = null):void {
			if (isStop){
				return ;
			}
			
			var self:EventDispatcher = this,
				handle:Function = function(evt:ScreenshotEvent):void{
					if (completeCallback != null){
						completeCallback(evt.params.bitmapDatas);
					}
					self.removeEventListener(ScreenshotEvent.CLIP_COMPLETE_ATION, handle);
				}
			this.addEventListener(ScreenshotEvent.CLIP_COMPLETE_ATION, handle);
			isStop = true;
		}
		
		/**
		 * 单次截屏
		 * @return 动画帧的数据流 
		 * 
		 */
		public function singleClip():BitmapData {
			return clip(source, width, height, martrix);
		}
		
		/**
		 * 单次截屏，病将其转换为JGP格式
		 * @return JGP格式图片的数据流
		 * 
		 */
		public function singleClipToJPG():ByteArray {
			return clipToJPG(source, width, height, martrix);
		}
		
		/**
		 * 定时截屏，并在截屏结束时，将结果传入callback方法并执行
		 * @param frameRate
		 * @param times
		 * @param callback
		 * 
		 */
		public function mutiClipToGif(frameRate:int = Screenshoter.DEFAULT_CLIP_FRAME_RATE, times:int = Screenshoter.DEFAULT_CLIP_TIMES, completeCallback:Function = null, everyCallback:Function = null):void {
			asyncMutiClip(source, width, height, martrix, frameRate, times, completeCallback, everyCallback);
		}
		
		/**
		 * 
		 * 截屏完成时的回调
		 * @param bitmapDatas
		 * 
		 */
		private function onClipComplete(bitmapDatas:Array):void {
			this.dispatchEvent(new ScreenshotEvent(ScreenshotEvent.CLIP_COMPLETE_ATION, {
				bitmapDatas: bitmapDatas		
			}));
		}
		
		/**
		 * 
		 * 静态截屏方法，返回bitmapdata格式的动画帧
		 * @param source
		 * @param width
		 * @param height
		 * @param martrix
		 * @return 
		 * 
		 */
		public static function clip(source:IBitmapDrawable, width:int, height:int, martrix:Matrix):BitmapData {
			var bitmapData:BitmapData = new BitmapData(width, height);
			bitmapData.draw(source, martrix); 
			return bitmapData;
		}
		
		/**
		 * 静态截屏方法，返回JGP格式的二进制流
		 * @param source
		 * @param width
		 * @param height
		 * @param martrix
		 * @param quality
		 * @return 
		 * 
		 */
		public static function clipToJPG(source:IBitmapDrawable, width:int, height:int, martrix:Matrix, quality:Number = 50):ByteArray {
			var jpgEncoder:JPGEncoder = new JPGEncoder(quality),
				bitmapData:BitmapData = clip(source, width, height, martrix);
			return jpgEncoder.encode(bitmapData);
		}
		
		/**
		 * 静态定时截屏方法，生成一组动画帧列表，将其传入callback函数并执行
		 * @param source
		 * @param width
		 * @param height
		 * @param martrix
		 * @param frameRate
		 * @param times
		 * @param callback
		 * 
		 */
		public static function asyncMutiClip(source:IBitmapDrawable, width:int, height:int, martrix:Matrix, frameRate:int, times:int, completeCallback:Function, everyCallback:Function = null):void{
			var bitmapDatas:Array = new Array(),
				timer:Timer = new Timer(1000 / frameRate, times * frameRate);
			
			timer.addEventListener(TimerEvent.TIMER, function (event:TimerEvent):void {
				var bitmapData:BitmapData = clip(source, width, height, martrix);
				if (everyCallback != null){
					everyCallback(bitmapData);
				}
				bitmapDatas.push(bitmapData);
			});
			
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function (event:TimerEvent):void {
				if (completeCallback != null){
					completeCallback(bitmapDatas);
				}
			});
			
			timer.start();
		}
	}
}