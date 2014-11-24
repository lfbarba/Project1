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
		
		public var _pixelSize:uint = 16;
		
		public var nest:GridPixel;
		
		private var _graphic:Boolean = false;
		
		private var t:Timer;
		
		private var _antFunction:FuncionEvaluable;
		
		private var _numAnts:uint;
		
		private var _totalFood:uint = 0;
		
		private var _foodRemaining:uint;
		
		private var _ants:Array;
		
		private var _numRounds:uint = 0;
		
		private var _maxNumRounds:int;
		
		private var _drawn:Boolean = false;
		
		private static var _mainSimulator:Simulator;
		
		public var pixelsWithFood:Array;
		public var hashPixelsWithFood:Array;
		
		private var _simulationAlreadySet:Boolean = false;
		
		public function Simulator( withGraphics:Boolean = true, maxNumRounds:int = -1)
		{
			super();
			this._graphic = withGraphics;
			_maxNumRounds = maxNumRounds;
			//
			pixelsWithFood = new Array;
			hashPixelsWithFood = new Array;
		}
		
		public static function getTrainingSimulator():Simulator {
			if(_mainSimulator == null){
				_mainSimulator = new Simulator(false, 40);
			}
			return _mainSimulator;
		}
		
		public function resetSimulation():void {
			for(var i:uint = 0; i< pixelsWithFood.length; i++){
				var p:GridPixel = pixelsWithFood[i] as GridPixel;
				p.reset();
			}
			var resetEvent:TickEvent = new TickEvent(TickEvent.TICK_EVENT);
			resetEvent.withReset = true;
			this.dispatchEvent(resetEvent);
			this.numAnts = 0;
			
			this._totalFood = 0;
			this._foodRemaining = 0;
			_paused = true;
			
			pixelsWithFood = new Array;
			hashPixelsWithFood = new Array;
		}
		
		
		public function setSimulation(w:uint, h:uint):void {
			if(!_simulationAlreadySet){
				_pixelWidth = w;
				_pixelHeight = h;
				setUpPlayGround();
				//
				t = new Timer(50, 0);
				t.addEventListener(TimerEvent.TIMER, runRoundOfSimulation);
				_simulationAlreadySet = true;
			}
		}
		
		public function setTrainingSimulation():void {
			setSimulation(10, 2);
			changeTickTime(200);
			setNest(8, 0);
			dropPileOfFood(0, 0, 10);
			//dropPileOfFood(8, 1, 3);
			dropPileOfFood(5, 1, 2);
			numAnts = 20;
			GridPixel.dropInPherormonePerTick = .05;
			draw();
		}
		
		public function get graphic():Boolean {
			return _graphic;
		}
		
		public function set numAnts(n:uint):void {
			_numAnts = n;
			if(_ants == null)
				return;
			var a:Ant;
			if(_numAnts > _ants.length){
				for(var i:uint = _ants.length; i < _numAnts; i++){
					a = new Ant;
					this._ants.push(a);
					a.moveToPixel(nest);
				}
			}else{
				var h:Sprite = new Sprite;
				h.visible = false;
				this.addChild(h);
				while(_numAnts < _ants.length){
					a = _ants.pop();
					a.icon.x = a.icon.y = -20;
					h.addChild(a.icon);
				}
			}
			this.refreshPixel();
		}
		
		public function changeTickTime(time:uint):void {
			t.delay = time;
		}
		
		public function get pixelWidth():uint {
			return _pixelWidth;
		}
		
		public function get pixelHeight():uint {
			return _pixelHeight;
		}
		
		public function startSimulation():Number {
			_paused = false;
			_numRounds = 0;
			_foodRemaining = _totalFood;
			_ants = new Array;
			for(var i:uint = 0; i < this._numAnts; i++){
				var a:Ant = new Ant;
				this._ants.push(a);
				a.moveToPixel(nest);
			}
			if(this._graphic){
				t.start();
				return -1;
			}else{
				runRoundOfSimulation();
				return (_totalFood - _foodRemaining) / this._totalFood;
			}
		}
		
		private var _paused:Boolean = true;
		
		public function pauseResumeSimulation():void {
			if(t!= null){
				if(_paused){
					t.start();
					_paused = false;
				}else{
					t.stop();
					_paused = true;
				}
			}
		}
		
		public function foodReturned():void {
			this._foodRemaining--;
		}
		
		public function setAntFunction(f:FuncionEvaluable):void {
			_antFunction = f;
		}
		
		public function runRoundOfSimulation(e:TimerEvent = null):void {
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
			if(this._graphic && _numRounds % 50 == 0)
				trace("_numRounds", _numRounds, "totalFood", _totalFood, "foodRemaining", _foodRemaining);
			if(_numRounds != _maxNumRounds){
				if(this.graphic){
					t.start();
				}else{
					runRoundOfSimulation();
				}
			}
			
		}
		
		public function get totalFood():uint {
			return _totalFood;
		}
		
		public function get foodRemaining():uint {
			return _foodRemaining;
		}
		
		
		
		public function setNest(x:uint, y:uint):void {
			nest = this.getPixel(x, y);
		}
		
		public function dropPileOfFood(x:uint, y:uint, amount:uint):void {
			var pixel:GridPixel = getPixel(x, y);
			if(pixel != null){
				pixel.addFood(amount);
				_totalFood += amount;
			}
			/*for(var i:int = -amount; i <= amount; i++){
			var j1:int = -(amount - Math.abs(i));
			var j2:int = amount - Math.abs(i);
			for(var j:int = j1; j <= j2; j++){
			var pixel:GridPixel = getPixel(x + i, y + j);
			if(pixel != null){
			pixel.addFood();
			_totalFood ++;
			}
			}
			}*/		
		}
		
		public function getPixel(x:int, y:int):GridPixel {
			if(x > pixelWidth -1 || x < 0 || y > pixelHeight -1 || y < 0)
				return null
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
		
		public function refreshPixel():void {
			if(this.graphic){
				for(var i:uint = 0; i < _pixelWidth; i++){
					for(var j:uint = 0; j < _pixelHeight; j++){
						var pixel:GridPixel = _pixels[i][j] as GridPixel;
						pixel.refresh();
					}
				}
			}
		}
		
		public function draw():void {
			if(this.graphic && !_drawn){
				_drawn = true;
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
}