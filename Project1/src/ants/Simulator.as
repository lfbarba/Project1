package ants
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import gp.FuncionEvaluable;
	
	public class Simulator extends Sprite
	{
		private var _playGround:Sprite
		private var _pixels:Array;
		private var _pixelWidth:uint;
		private var _pixelHeight:uint;
		
		private var _pixelSize:uint = 16;
		
		public var nest:GridPixel;
		
		public var graphic:Boolean = false;
		
		private var t:Timer;
		
		private var _antFunction:FuncionEvaluable;
		
		private var _numAnts:uint;
		
		private var _totalFood:uint = 0;
		
		private var _foodRemaining:uint;
		
		private var _ants:Array;
		
		private var _numRounds:uint = 0;
		
		public function Simulator(w:uint, h:uint, numAnts:uint, withGraphics:Boolean = false)
		{
			super();
			_pixelWidth = w;
			_pixelHeight = h;
			_numAnts = numAnts;
			setUpPlayGround();
			//
			this.graphic = withGraphics;
			if(graphic){
				t = new Timer(10, 0);
			}else{
				t = new Timer(0, 0);
			}
			t.addEventListener(TimerEvent.TIMER, runRoundOfSimulation);
		}
		
		public function get pixelWidth():uint {
			return _pixelWidth;
		}
		
		public function get pixelHeight():uint {
			return _pixelHeight;
		}
		
		public function startSimulation():void {
			_numRounds = 0;
			_foodRemaining = _totalFood;
			_ants = new Array;
			for(var i:uint = i; i < this._numAnts; i++){
				var a:Ant = new Ant;
				this._ants.push(a);
				a.moveToPixel(nest);
			}
			t.start();
		}
		
		public function pauseSimulation():void {
			if(t!= null){
				t.stop();
			}
		}
		
		public function resumeSimulation():void {
			if(t!= null){
				t.start();
			}
		}
		
		public function foodReturned():void {
			this._foodRemaining--;
		}
		
		public function setAntFunction(f:FuncionEvaluable):void {
			_antFunction = f;
		}
		
		public function runRoundOfSimulation(e:TimerEvent):void {
			if(_antFunction == null)
				throw new Error("No Ant Function defined");
			t.stop();
			for(var i:uint = 0; i< this._ants.length; i++){
				var a:Ant = _ants[i] as Ant;
				Ant.currentAnt = a;
				_antFunction.evaluate();
			}
			
			this.dispatchEvent(new TickEvent(TickEvent.TICK_EVENT));
			_numRounds ++;
			if(_numRounds % 100 == 0)
				trace("_numRounds", _numRounds, "totalFood", _totalFood, "foodRemaining", _foodRemaining);
			t.start();
		}
		
		public function setNest(x:uint, y:uint):void {
			nest = this.getPixel(x, y);
		}
		
		public function dropPileOfFood(x:uint, y:uint, radius:uint):void {
			for(var i:uint = 0; i < _pixelWidth; i++){
				for(var j:uint = 0; j < _pixelHeight; j++){
					if(Math.abs(i - x) + Math.abs(j - y) <= radius){
						var pixel:GridPixel = this.getPixel(i, j);
						pixel.addFood();
						_totalFood ++;
					}
				}
			}
		}
		
		public function getPixel(x:int, y:int):GridPixel {
			/*x = Math.max(0, x);
			x = Math.min(x, this._pixelWidth-1);
			y = Math.max(0, y);
			y = Math.min(y, this.pixelHeight-1);*/
			x = (x + _pixelWidth) % _pixelWidth;
			y = (y + pixelHeight) % pixelHeight;
			return this._pixels[x][y];
		}
		
		private function setUpPlayGround():void {
			_playGround = new Sprite;
			_pixels = new Array();
			for(var i:uint = 0; i < _pixelWidth; i++){
				for(var j:uint = 0; j < _pixelHeight; j++){
					if(_pixels[i] == undefined)
						_pixels[i] = new Array();
					var pixel:GridPixel = new GridPixel(_pixelSize, 0xEEEEEE, this);
					pixel.setCoordinates(i, j);
					pixel.x = i* _pixelSize;
					pixel.y = j * _pixelSize;
					_pixels[i][j] = pixel;
				}
			}
		}
		
		public function draw():void {
			this.addChild(_playGround);
			for(var i:uint = 0; i < _pixelWidth; i++){
				for(var j:uint = 0; j < _pixelHeight; j++){
					var pixel:GridPixel = _pixels[i][j] as GridPixel;
					pixel.draw();
					_playGround.addChild(pixel);
				}
			}
		}
	}
}