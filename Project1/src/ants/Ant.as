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
		private var _carryingIcon:Sprite;
			
		public function Ant()
		{
			super();
			_icon = new Sprite;
			_icon.graphics.beginFill(0);
			_icon.graphics.drawCircle(-2, 0, 2);
			_icon.graphics.drawCircle(2, 0, 2);
			_icon.graphics.endFill();
			
			_carryingIcon = new Sprite;
			_carryingIcon.graphics.beginFill(0xFFFF00);
			_carryingIcon.graphics.drawCircle(-2, 0, 2);
			_carryingIcon.graphics.drawCircle(2, 0, 2);
			_carryingIcon.graphics.endFill();
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
			var somePixelWithPherormone:GridPixel;
			var min:Number = Number.POSITIVE_INFINITY;
			var posibilities:Array = new Array;
			for(var i:int = -1; i <= 1; i++){
				for(var j:int = -1; j <= 1; j++){
					if((i == 0 || j == 0) && (i != 0 && j != 0)){
						var pixel:GridPixel = currentPixel.simulator.getPixel(currentPixel.coorX + i, currentPixel.coorY + j);
						if(pixel.pherormoneIntensity > .3){
							best = pixel;
							min = pixel.pherormoneIntensity;
							posibilities.push(pixel);
						}
					}
				}
			}
			if(posibilities.length > 0){
				var target:GridPixel = posibilities[Math.floor(Math.random() * posibilities.length)];
				moveToPixel(target);
			}else{
				moveRandomly();
			}
		}
		
		public function moveToNest():void {
			var nest:GridPixel = currentPixel.simulator.nest;
			if(currentPixel != nest){
				var xIncrement:int;
				var yIncrement:int;
				xIncrement = (nest.coorX < currentPixel.coorX) ? -1 : 1;
				xIncrement = (nest.coorX == currentPixel.coorX) ? 0 : xIncrement;
				
				yIncrement = (nest.coorY < currentPixel.coorY) ? -1 : 1;
				yIncrement = (nest.coorY == currentPixel.coorY) ? 0 : yIncrement;
				moveToPixel(currentPixel.simulator.getPixel(currentPixel.coorX + xIncrement, currentPixel.coorY + yIncrement));
			}
		}
		
		public function moveRandomly():void {
			var rand:uint = Math.floor(Math.random() * 8);
			var xIncrement:int;
			var yIncrement:int;
			switch(rand) {
				case 0: xIncrement = 1; yIncrement = -1; break;
				case 1: xIncrement = 1; yIncrement = 0; break;
				case 2: xIncrement = 1; yIncrement = 1; break;
				case 3: xIncrement = 0; yIncrement = -1; break;
				case 4: xIncrement = 0; yIncrement = 1; break;
				case 5: xIncrement = -1; yIncrement = -1; break;
				case 6: xIncrement = -1; yIncrement = 0; break;
				case 7: xIncrement = -1; yIncrement = 1; break;
			}
			
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
			//steal the icons
			var h:Sprite = new Sprite;
			h.addChild(_icon);
			h.addChild(_carryingIcon);
			//
			if(this.hasFood){
				return _carryingIcon;
			}else{
				return this._icon;
			}
		}
	}
}