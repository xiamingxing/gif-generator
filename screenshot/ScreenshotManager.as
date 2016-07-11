/**
 * 此类截图功能的管理类
 * @author xiamingxing
 * @version 0.1 AS3 implementation
 */
package com.screenshot
{
	import com.Config;
	import com.demonsters.debugger.MonsterDebugger;
	import com.worker.*;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.media.Video;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	
	public class ScreenshotManager extends Sprite
	{
		// 上传到服务器的URL
		private static const uploadUrl:String = Config.uploadImgUrl+"?anchor_id="+Config.anchorId+"&relateid="+Config.liveId;
		
		private var gifGenerator:GifGenerator;
		private var gifPlayer:GifPlayer;
		private var uploader:Uploader;
		private var screenshoter:Screenshoter; 
		private var context:Sprite;
		private var video:Video;
		private var isAutoCliping:Boolean;
		private var isTimeCliping:Boolean;
		private var workerManager:WorkerManager;
		
		/**
		 * 
		 * @param _context
		 * @param _video
		 * 
		 */
		public function ScreenshotManager(_context:Sprite, _video:Video)
		{
			MonsterDebugger.initialize(this); 
			
			context = _context;
			video = _video;  
			context.addChild(this);
			gifGenerator = new GifGenerator({
				repeat: 0
			});
			gifPlayer = new GifPlayer;
			uploader = new Uploader;
			screenshoter = new Screenshoter(video.parent, video.width, video.height, getMartrix(context.stage, video), context.stage.frameRate, Config.uploadImgQuality);
			isAutoCliping = false;
			isTimeCliping = false;
			bindEvt();
			initWorker();
		}
		
		public function initWorker():void {
			var self:ScreenshotManager = this;
			
			ExternalWorkerLoader.initialize(this, {
				"http://s3.qhimg.com/static/a96856a332cc332c/bgWorker.swf": "bgWorker"
			});
			
			ExternalWorkerLoader.load("bgWorker", function (context:WorkerManager):void{
				MonsterDebugger.trace(this, workerManager, "load bgWorker ready");
				workerManager = context;
			});
		}
		
		private function bindEvt():void {
	
			screenshoter.addEventListener(ScreenshotEvent.CLIP_COMPLETE_ATION, function (evt:ScreenshotEvent):void {
			});
			
			uploader.addEventListener(ScreenshotEvent.UPLOAD_COMPLETE_ACTION, function (evt:ScreenshotEvent):void {
			});
		}
		
		/**
		 * 开始GIF动画的自动截屏
		 * @param frameRate
		 * 
		 */
		public function startClipGif(frameRate:int = Screenshoter.DEFAULT_CLIP_FRAME_RATE):void {
			
			if (isAutoCliping || isTimeCliping){
				return ;
			}
			
			isAutoCliping = true;
			screenshoter.startClip(frameRate, function (bitmapData:BitmapData):void{
				gifGenerator.generateGifFrame(bitmapData);
			});
		}
		
		/**
		 * 结束GIF动画的自动截屏，并将最终生成的GIF文件上传到服务器
		 * 
		 */
		public function stopClipGif():void {
			
			if (!isAutoCliping || isTimeCliping){
				return ;
			}
			
			var self:EventDispatcher = this;
			screenshoter.stopClip(function (bitmapDatas:Array):void{
				var gifStream:ByteArray = gifGenerator.getGeneratedGifStream();
				upload(gifStream, function (params:Object):void {
					self.dispatchEvent(new ScreenshotEvent(ScreenshotEvent.CLIP_GIF_COMPLETE_ATION, params));
					self.dispatchEvent(new ScreenshotEvent(ScreenshotEvent.CLIP_IMG_COMPLETE_ATION, params));
				});
				isAutoCliping = false;
			});
		}
		
		/**
		 * GIF动画的定时截屏方法，截屏完成之后将最终生成的GIF文件上传到服务器
		 * @param frameRate
		 * @param times
		 * 
		 */
		public function clipGif(frameRate:int = Screenshoter.DEFAULT_CLIP_FRAME_RATE, times:int = Screenshoter.DEFAULT_CLIP_TIMES):void {
			
			if (isAutoCliping || isTimeCliping || !(workerManager && workerManager.isReady())){
				return;	
			}
			
			MonsterDebugger.trace(this, 'clipGifStart frameRate:' + frameRate + " times:" + times, 'call');
			workerManager.call("clipGifStart");
			
			isTimeCliping = true;
			var self:EventDispatcher = this, 
				sn:int = 0, 
				startClipTime:int = (new Date).time,
				speedTime:int;
			screenshoter.mutiClipToGif(frameRate, times, function (bitmapDatas:Array):void{
				MonsterDebugger.trace(this, 'clipGifComplete', 'call');
				workerManager.call("clipGifComplete", null, function (byteArray:ByteArray):void{
					speedTime = new Date().time - startClipTime;
					MonsterDebugger.trace(this, 'run clipGifComplete Callback function, this clip operation speed time:' + speedTime, 'call');
					uploadStream(byteArray);
				});
				isTimeCliping = false;
				
			}, function (bitmapData:BitmapData):void{	
				MonsterDebugger.trace(this, 'clipGifAddFrame sn' + (sn++), 'call');
				workerManager.call("clipGifAddFrame", [ImageUtil.encodeByteArray(bitmapData), sn]);
			});
		}
		
		private function uploadStream(gifStream:ByteArray):void {
			upload(gifStream, function (params:Object):void {
				dispatchEvent(new ScreenshotEvent(ScreenshotEvent.CLIP_GIF_COMPLETE_ATION, params));
				dispatchEvent(new ScreenshotEvent(ScreenshotEvent.CLIP_IMG_COMPLETE_ATION, params));
				MonsterDebugger.trace(this, params, "uploadStream complete");
			});
		}
		
		/**
		 * 普通截屏
		 * 
		 */
		public function clipJPG():void {
			var jpgStream:ByteArray = screenshoter.singleClipToJPG();
			upload(jpgStream, function (params:Object):void {
				dispatchEvent(new ScreenshotEvent(ScreenshotEvent.CLIP_JPG_COMPLETE_ATION, params));
				dispatchEvent(new ScreenshotEvent(ScreenshotEvent.CLIP_IMG_COMPLETE_ATION, params));
			});
		}
		
		/**
		 * 销毁自己
		 * 
		 */
		public function destory():void {
			if (gifPlayer && gifPlayer.parent == this){
				removeChild(gifPlayer);
			}
			if (this.parent){
				this.parent.removeChild(this);
			}
		}
		
		/**
		 * 
		 * @param stage
		 * @param video
		 * @return 
		 * 
		 */
		private function getMartrix(stage:Stage, video:Video):Matrix{
			return new Matrix(1,0,0,1,-(stage.stageWidth - video.width)/2,-(stage.stageHeight - video.height)/2);
		}
		
		/**
		 * 
		 * @param frameDatas
		 * @return 
		 * 
		 */
		private function generateGifStream(frameDatas:Array):ByteArray{
			gifGenerator.addFrames(frameDatas);
			return gifGenerator.getStream();
		}
		
		/**
		 * 
		 * @param gifStream
		 * 
		 */
		private function play(gifStream:ByteArray):void {
			if (!gifPlayer || gifPlayer.parent != this){
				addChild(gifPlayer);
			}
			gifPlayer.play(gifStream);
		}
		
		/**
		 * 
		 * @param stream
		 * @param callback
		 * 
		 */
		private function upload(stream:ByteArray, callback:Function = null):void {
			uploader.uploadData(uploadUrl, stream, function (evt:ScreenshotEvent):void{
				if (callback != null){
					callback(evt.params);
				}
			});
		}
	}
}