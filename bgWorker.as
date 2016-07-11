package
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.screenshot.GifGenerator;
	import com.screenshot.ImageUtil;
	import com.worker.*;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.system.Security;
	import flash.utils.ByteArray;
	
	[SWF(width="0", height="0", backgroundColor="#000000")]
	public class bgWorker extends Sprite
	{
		private var bgWorkerManager:BackgroundWorker;
		
		public function bgWorker()
		{
			super();
			MonsterDebugger.initialize(this);
			MonsterDebugger.trace(this, 'initBgWorker');
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			stage.frameRate = 2;
			initWorker();
		}
		
		private function initWorker():void{
			
			var gifGenerator:GifGenerator;
			
			bgWorkerManager = new BackgroundWorker({
				add: function(...args):int {
					var total:int = 0;
					for (var i:int = 0, l:int = args.length; i < l; i++){
						total += args[i];
					}
					MonsterDebugger.trace(this, total, 'add');
					return total;
				},
				clipGifStart: function ():void{
					MonsterDebugger.trace(this, "clipGifStart");
					gifGenerator = new GifGenerator({
						repeat: 0
					});
				},
				clipGifAddFrame: function (byteArray:ByteArray, sn:int):void {
					MonsterDebugger.trace(this, "clipGifAddFrame sn:" + sn);
					if (byteArray && byteArray is ByteArray){
						var bitmapData:BitmapData = ImageUtil.decodeByteArray(byteArray);
						gifGenerator.generateGifFrame(bitmapData);
					}
				},
				clipGifComplete: function ():ByteArray{
					MonsterDebugger.trace(this, "clipGifComplete");
					return gifGenerator.getGeneratedGifStream();
				}
			});
			
			bgWorkerManager.ready();
		}
	}
}