package ants
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Point;
	
	public class Ant
	{
		public var currentPixel:GridPixel;
		private var _previousPixel:GridPixel;
		
		private static var _currentAnt:Ant;
		
		private var _hasFood:Boolean = false;
		
		private var _icon:Sprite;
		private var _carryingIcon:Sprite;
		private var _seinsingIcon:Sprite;
			
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
			
			_seinsingIcon = new Sprite;
			_seinsingIcon.graphics.beginFill(0x00FF00);
			_seinsingIcon.graphics.drawCircle(-2, 0, 2);
			_seinsingIcon.graphics.drawCircle(2, 0, 2);
			_seinsingIcon.graphics.endFill();
		}
		
		public function get previousPixel():GridPixel {
			return _previousPixel;
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
			if(this.currentPixel.foodAmount > 0 && _hasFood == false ){
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
		
		private function moveTowardsPixel(pixel:GridPixel):void {
			if(currentPixel != pixel){
				var xIncrement:int;
				var yIncrement:int;
				xIncrement = (pixel.coorX < currentPixel.coorX) ? -1 : 1;
				xIncrement = (pixel.coorX == currentPixel.coorX) ? 0 : xIncrement;
				
				yIncrement = (pixel.coorY < currentPixel.coorY) ? -1 : 1;
				yIncrement = (pixel.coorY == currentPixel.coorY) ? 0 : yIncrement;
				moveToPixel(currentPixel.simulator.getPixel(currentPixel.coorX + xIncrement, currentPixel.coorY + yIncrement));
			}
		}
		
		private function moveRandomlyAwayFromNestPixel():void {
			var candidates:Array = new Array;
			var nest:GridPixel = currentPixel.simulator.nest;
			var L1toNest:uint = Math.pow(nest.coorX - currentPixel.coorX, 2) + Math.pow(nest.coorY - currentPixel.coorY, 2);
			for(var i:int = -1; i <= 1; i++){
				for(var j:int = -1; j <= 1; j++){
					var distToNest:uint = Math.pow(nest.coorX - currentPixel.coorX - i, 2) + Math.pow(nest.coorY - currentPixel.coorY - j, 2);
					var pixel:GridPixel = currentPixel.simulator.getPixel(currentPixel.coorX + i, currentPixel.coorY + j);
					if(i != 0 && j != 0 && distToNest > L1toNest && pixel != null){
						candidates.push(pixel);
					}
				}
			}
			if(candidates.length  != 0){
				this.moveToPixel(candidates[Math.floor(Math.random() * candidates.length)]);
			}else{
				this.moveRandomly();
			}
		}
		
		public function moveToPixel(pixel:GridPixel):void {
			if(pixel != null){
				_previousPixel = currentPixel;
				currentPixel = pixel;
				currentPixel.addAnt(this.icon);
			}
		}
		
		public function dropPherormone():void {
			this.currentPixel.dropPherormone(this);
		}
		
		public function moveToPherormone():void {
			if(currentPixel.pherormoneIntensity > 0){
				//move to the highest pherormone node that is farther than you from the nest
				if(currentPixel.gradient != null){
					if(Math.random() < .7){
						moveToPixel(currentPixel.gradient);
					}else{
						this.moveRandomlyAwayFromNestPixel();
					}
				}else{
					this.moveRandomlyAwayFromNestPixel();
				}
			}else{
				this.moveRandomly();
			}
		}
		
		public function moveToNest():void {
			var nest:GridPixel = currentPixel.simulator.nest;
			var x:uint = currentPixel.coorX;
			var y:uint = currentPixel.coorY;
			moveTowardsPixel(nest);
			if(currentPixel.coorX != x || currentPixel.coorY != y)
				this.dropPherormone();
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
			h.addChild(_seinsingIcon);
			h.x = h.y = -20;
			h.visible = false;
			this.currentPixel.simulator.addChild(h);
			//
			if(this.hasFood){
				return _carryingIcon;
			}else if(this.pherormoneIntensityInLocation > 0){
				return _seinsingIcon;
			}else {
				return this._icon;
			}
		}
	}
}