package ga
{
	import flash.display.Sprite;
	
	public class PointSet extends Sprite
	{
		public var points:Array = new Array;
		
		private var pointLayer:Sprite;
		
		public function PointSet()
		{
			setUpPointLayer();
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
	}
}