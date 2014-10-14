package ga
{
	import flash.display.Sprite;
	
	public class TspPoint extends Sprite
	{
		
		private var pointLayer:Sprite; 
		private var color:Number;
		private var radius:Number = 4;
		public var index:uint;
		
		public function TspPoint(xx:Number, yy:Number)
		{
			this.x = xx;
			this.y = yy;		
			this.draw();
		}
		
		private function draw():void {
			if(pointLayer != null && this.contains(pointLayer)){
				this.removeChild(pointLayer);
			}
			pointLayer = new Sprite;
			this.addChild(pointLayer);
			pointLayer.graphics.beginFill(color, 1);
			pointLayer.graphics.drawCircle(0, 0, this.radius);
			pointLayer.graphics.endFill();
		}
	}
}