package ants
{
	import flash.display.Sprite;
	
	public class GridPixel extends Sprite
	{
		
		private var _bkg:Sprite;
		private var _bkgColor:Number = 0;
		private var _size:uint;
		
		private var _pherormoneIntensity:Number = 0;
		
		private var _pherormoneColor:Number = 0x0000FF;
		
		public static var dropInPherormonePerTick:Number = .1;
		
		public var simulator:Simulator;
		
		private var _food:uint = 0;
		
		private var _foodIndicator:Sprite;
		
		private var _pherormoneIndicator:Sprite;
		
		private var _antLayer:Sprite;
		
		private var _i:uint;
		private var _j:uint;
		
		public function GridPixel(s:uint, color:Number, sim:Simulator)
		{
			super();
			simulator = sim;
			this._size = s;
			_bkgColor = color;
			sim.addEventListener(TickEvent.TICK_EVENT, tickHandler);
		}
		
		public function setCoordinates(i:uint, j:uint):void {
			_i = i;
			_j = j;
		}
		
		public function get coorX():uint {
			return _i;
		}
		
		public function get coorY():uint {
			return _j;
		}
		
		
		public function pherormoneChange(intensity:Number):void {
			_pherormoneIntensity += intensity;
		}
		
		public function get foodAmount():int {
			return _food;
		}
		
		public function removeFood():void {
			_food--;
		}
		
		public function addFood():void {
			_food++;
		}
		
		//indicates that one unit of time has passed
		public function tickHandler(e:TickEvent):void {
			_pherormoneIntensity = Math.max(0, _pherormoneIntensity - dropInPherormonePerTick);
			if(this.simulator.graphic){
				this.refresh();
			}
		}
		
		public function dropPherormone():void {
			var radius:uint = 5;
			for(var i:uint = 0; i < simulator.pixelWidth; i++){
				for(var j:uint = 0; j < simulator.pixelHeight; j++){
					var L1Dist:uint = Math.abs(i - coorX) + Math.abs(j - coorY);
					if(L1Dist <= radius){
						var pixel:GridPixel = simulator.getPixel(i, j);
						pixel.pherormoneChange(1 - L1Dist/radius);
					}
				}
			}
		}
		
		public function get pherormoneIntensity():Number {
			return _pherormoneIntensity;
		}
		
		private function refresh():void {
			_foodIndicator.alpha = Math.min(1, foodAmount / 3);
			if(this.simulator.nest == this){
				_bkg.graphics.beginFill(0x444444);
				_bkg.graphics.drawRect(0, 0, _size, _size);
				_bkg.graphics.endFill();
			}
			_pherormoneIndicator.alpha = Math.min(1, this.pherormoneIntensity);
		}
		
		public function draw():void {
			if(_bkg != null && this.contains(_bkg)){
				this.removeChild(_bkg);
			}
			_bkg = new Sprite;
			this.addChildAt(_bkg, 0);
			_bkg.graphics.lineStyle(1, 0xCCCCCC);
			_bkg.graphics.beginFill(this._bkgColor);
			_bkg.graphics.drawRect(0, 0, _size, _size);
			_bkg.graphics.endFill();
			//
			_pherormoneIndicator = new Sprite;
			addChildAt(_pherormoneIndicator, 1);
			_pherormoneIndicator.graphics.beginFill(_pherormoneColor);
			_pherormoneIndicator.graphics.drawRect(1, 1, _size-2, _size-2);
			_pherormoneIndicator.graphics.endFill();
			//
			_foodIndicator = new Sprite;
			addChildAt(_foodIndicator, 2);
			_foodIndicator.graphics.beginFill(0xFF0000);
			_foodIndicator.graphics.drawCircle(_size/2, _size/2, _size/4);
			_foodIndicator.graphics.endFill();
			
			_antLayer = new Sprite;
			addChildAt(_antLayer, 3);
			
			
			//
			this.refresh();
		}
		
		public function addAnt(a:Sprite):void {
			a.x =  a.y = _size/2;
			this._antLayer.addChild(a);
		}
	}
}