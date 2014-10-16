package ga
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class PointSet extends Sprite
	{
		public var points:Array = new Array;
		
		private var pointLayer:Sprite;
		
		
		public function PointSet()
		{
			setUpPointLayer();
		}
		
		
		public function createPointInCricle():void {
			var n:uint = 70;
			for(var i:uint = 0; i < n; i++){
				var alpha:Number = i* 2*Math.PI / n;
				var p:TspPoint = new TspPoint(600 + 500*Math.cos(alpha), 500 + 500*Math.sin(alpha));
				this.addPoint(p);
			}
		}
		
		public function readFromFile(url:String):void {
			var myTextLoader:URLLoader = new URLLoader();
			myTextLoader.addEventListener(Event.COMPLETE, onFileLoaded);
			
			myTextLoader.load(new URLRequest(url));
		}
		
		private function onFileLoaded(e:Event):void {
			var text:String = e.target.data as String;
			var a:Array = text.split("\n");
			for(var i:uint = 0; i < a.length; i++){
				var temp:Array = a[i].split(" ");
				if(temp.length > 1){
					var p:TspPoint = new TspPoint(temp[1], temp[2]);
					this.addPoint(p);
				}
			}
		}
		
		public function addPoint(p:TspPoint):void {
			this.points.push(p);
			pointLayer.addChild(p);
		}
		
		public function removePoint(p:TspPoint):void {
			this.points.splice(points.indexOf(p), 1);
		}
		
		private function setUpPointLayer():void {
			if(pointLayer != null && this.contains(pointLayer)){
				this.removeChild(pointLayer);
			}
			pointLayer = new Sprite;
			this.addChild(pointLayer);
		}
		
		
		
		override public function toString():String {
			var str:String = "";
			for(var i:uint = 0; i< points.length; i++){
				str+= points[i].toString();
			}
			return str;
		}
	}
}