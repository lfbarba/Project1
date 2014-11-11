package ants
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Ant
	{
		public var currentPixel:GridPixel;
		
		private static var _currentAnt:Ant;
		
		private var _hasFood:Boolean = false;
		
		private var _icon:Sprite;
			
		public function Ant()
		{
			super();
			_icon = new Sprite;
			_icon.graphics.beginFill(0);
			_icon.graphics.drawCircle(-2, 0, 2);
			_icon.graphics.drawCircle(2, 0, 2);
			_icon.graphics.endFill();
		}
		
		public static function get currentAnt():Ant {
			if(_currentAnt == null){
				throw new Error("Current Ant is undefined");
			}
			return _currentAnt;
		}
		
		public static function set currentAnt(a:Ant):void {
			_currentAnt = a;
		}
		
		public function pickFood():void {
			if(this.currentPixel.foodAmount > 0){
				this.currentPixel.removeFood();
				this._hasFood = true;
			}
		}
		
		public function dropFood():void {
			if(this.hasFood){
				this.currentPixel.addFood();
			}
			this._hasFood = false;
		}
		
		public function moveToPixel(pixel:GridPixel):void {
			currentPixel = pixel;
			currentPixel.addAnt(this.icon);
		}
		
		public function dropPherormone():void {
			this.currentPixel.dropPherormone();
		}
		
		public function moveToPherormone():void {
			//scan adjacent nodes and move to the one with the most pherormones
			var best:GridPixel;
			var max:Number = currentPixel.pherormoneIntensity;
			for(var i:int = -1; i <= 1; i++){
				for(var j:int = -1; j <= 1; j++){
					var pixel:GridPixel = currentPixel.simulator.getPixel(currentPixel.coorX + i, currentPixel.coorY + j);
					if(pixel.pherormoneIntensity > max){
						best = pixel;
						max = pixel.pherormoneIntensity;
					}
				}
			}
			if(best == null || best == currentPixel){
				this.moveRandomly();
			}else{
				moveToPixel(best);
			}
		}
		
		public function moveToNest():void {
			var nest:GridPixel = currentPixel.simulator.nest;
			if(currentPixel != nest){
				var xIncrement:int;
				var yIncrement:int;
				xIncrement = (nest.x < currentPixel.coorX) ? -1 : 1;
				yIncrement = (nest.y < currentPixel.coorY) ? -1 : 1;
				moveToPixel(currentPixel.simulator.getPixel(currentPixel.coorX + xIncrement, currentPixel.coorY + yIncrement));
			}
		}
		
		public function moveRandomly():void {
			var xIncrement:int = (Math.random() - .5 < 0) ? -1 : 1;
			var yIncrement:int = (Math.random() - .5 < 0) ? -1 : 1;
			moveToPixel(currentPixel.simulator.getPixel(currentPixel.coorX + xIncrement, currentPixel.coorY + yIncrement)); 
		}
		
		public function get isInNest():Boolean {
			return (currentPixel == currentPixel.simulator.nest);
		}
		
		public function get isThereFood():Boolean {
			return (currentPixel.foodAmount>0);
		}
		
		public function get hasFood():Boolean {
			return _hasFood;
		}
		
		public function get pherormoneIntensityInLocation():Number {
			return this.currentPixel.pherormoneIntensity;
		}
		
		public function get icon():Sprite {
			return this._icon;
		}
	}
}