package ants
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class GridPixel extends Sprite
	{
		
		private var _bkg:Sprite;
		private var _bkgColor:Number = 0;
		private var _size:uint;
		
		private var _pherormoneIntensity:Number = 0;
		
		private var _pherormoneColor:Number = 0x0000FF;
		
		private var _pherormoneRadius:uint = 4;
		
		public static var dropInPherormonePerTick:Number = .02;
		
		public static var dropFoodRadiusOnDoubleClick:uint = 5;
		
		public var simulator:Simulator;
		
		private var _food:uint = 0;
		
		private var _foodIndicator:Sprite;
		
		private var _pherormoneIndicator:Sprite;
		
		private var _antLayer:Sprite;
		
		private var _i:uint;
		private var _j:uint;
		
		private var _gradientPixel:GridPixel;
		
		
		public function GridPixel(s:uint, color:Number, sim:Simulator)
		{
			super();
			simulator = sim;
			this._size = s;
			_bkgColor = color;
			sim.addEventListener(TickEvent.TICK_EVENT, tickHandler);
			this.doubleClickEnabled = true;
			this.addEventListener(MouseEvent.CLICK, doubleClickHandler);
		}
		
		private function doubleClickHandler(e:MouseEvent):void {
			simulator.dropPileOfFood(coorX, coorY, dropFoodRadiusOnDoubleClick);
			simulator.refreshPixel();
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
			_pherormoneIntensity  += intensity;
			_pherormoneIntensity = Math.min(1, _pherormoneIntensity);
			
		}
		
		public function get foodAmount():int {
			return _food;
		}
		
		public function removeFood():void {
			_food--;
		}
		
		public function addFood():void {
			//if the food is drop in the nest it dissapears
			if(simulator.nest != this){
				_food++;
			}else{
				simulator.foodReturned();
			}
		}
		
		//indicates that one unit of time has passed
		public function tickHandler(e:TickEvent):void {
			_pherormoneIntensity = Math.max(0, _pherormoneIntensity - dropInPherormonePerTick);
			if(_pherormoneIntensity  < .2)
				this._gradientPixel = null;
			if(this.simulator.graphic){
				this.refresh();
			}
		}
		
		public function get gradient():GridPixel {
			if(this.pherormoneIntensity > 0 && _gradientPixel!= null){
				return _gradientPixel;
			}else{
				return null;
			}
		}
		
		public function dropPherormone(ant:Ant = null):void {
			if(ant != null){
				_gradientPixel = ant.previousPixel;
			}
			for(var i:uint = 0; i < simulator.pixelWidth; i++){
				for(var j:uint = 0; j < simulator.pixelHeight; j++){
					var L1Dist:uint = Math.abs(i - coorX) + Math.abs(j - coorY);
					if(L1Dist <= _pherormoneRadius){
						var pixel:GridPixel = simulator.getPixel(i, j);
						if(i ==0 && j ==0){	
							pixel.pherormoneChange(1);
						}else{
							pixel.pherormoneChange(Math.pow((_pherormoneRadius -L1Dist)/_pherormoneRadius, 3));
						}
					}
				}
			}
		}
		
		public function get pherormoneIntensity():Number {
			return _pherormoneIntensity;
		}
		
		public function refresh():void {
			_foodIndicator.alpha = Math.min(1, foodAmount / 3);
			if(this.simulator.nest == this){
				_bkg.graphics.beginFill(0x444444);
				_bkg.graphics.drawRect(0, 0, _size, _size);
				_bkg.graphics.endFill();
			}
			_pherormoneIndicator.alpha = Math.min(.8, this.pherormoneIntensity);
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
		
		public function removeAnt(a:Sprite):void {
			if(_antLayer.contains(a))
				this._antLayer.removeChild(a);
		}
	}
}