package grapher
{
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import gp.FuncionEvaluable;
	import gp.FunctionTree;
	import gp.TFunction;
	import gp.targetFunctions.FunctionA;
	
	public class Grapher extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		
		private var _intervalMin:Number;
		private var _intervalMax:Number;

		private var _bkg:Sprite;
		private var _plottedPoints:Array;
		private var _plot:Sprite;
		private var _ySpread:Number;
		
		public function Grapher(w:Number, h:Number, min:Number, max:Number)
		{
			_width = w;
			_height = h;
			_intervalMin = min;
			_intervalMax = max;
			_plottedPoints = new Array;
			super();
			
			drawBackground(200, 20);
		}
		
		private function computeYSpread(f:FuncionEvaluable, resolution:Number):Number {
			var absMax:Number = 0;
			for(var x:Number = _intervalMin; x < _intervalMax; x = x + resolution){
				var y:Number = f.evaluate(x);
				absMax = Math.max(absMax, Math.abs(y));
			}
			if(absMax == 0 || isNaN(absMax)){
				return 200;
			}else{
				return absMax*2.1;
			}
		}
	
		
		public function plotFunction(f:FuncionEvaluable, color:Number = 0, resolution:Number = .1, baseFunction:Boolean = false):void {
			if(baseFunction){
				_ySpread = this.computeYSpread(f, resolution);
				this.drawBackground(_ySpread, _ySpread/10);
			}			
			for(var x:Number = _intervalMin; x < _intervalMax; x = x + resolution){
				var y:Number = f.evaluate(x);
				var xx:Number = x - resolution/2;
				var yy:Number = f.evaluate(xx);
				_plot.graphics.lineStyle(1, color, 1, true, LineScaleMode.NONE);
				//this.plotPoint(x, y, color);
				if(x == _intervalMin){
					_plot.graphics.moveTo(coordinates(x,y).x, coordinates(x,y).y);
				}else{
					_plot.graphics.curveTo(coordinates(xx,yy).x, coordinates(xx,yy).y, coordinates(x,y).x, coordinates(x,y).y);
				}
			}
		}
		
		public function plotPoint(x:Number, y:Number, color:Number = 0):void {
			var p:Sprite = new Sprite;
			p.graphics.beginFill(color);
			p.graphics.drawCircle(0, 0, 1);
			p.graphics.endFill();
			this._plottedPoints.push(p);
			_plot.addChild(p);
			p.x = coordinates(x,y).x;
			p.y = coordinates(x,y).y;
		}
		
		public function clearPlots():void {
			if(_plot != null && this.contains(_plot)){
				this.removeChild(_plot);
			}
			_plot = new Sprite;
			this.addChildAt(_plot, 1); 
		}
		
		private function coordinates(x:Number, y:Number):Point {
			var xFactor:Number = _width/ (_intervalMax - _intervalMin);
			var yFactor:Number = _height / _ySpread;
			
			var p:Point = new Point(xFactor* x, -yFactor* y);
			p = _bkg.localToGlobal(p);
			return p;
		}
		
		
		public function drawBackground(ySpread:Number = 200, hResolution:Number = 1):void {
			var xFactor:Number = _width/ (_intervalMax - _intervalMin);
			var yFactor:Number = _height / ySpread;
			
			if(_bkg != null && this.contains(_bkg)){
				this.removeChildAt(0);
			}
			_bkg = new Sprite;
			this.addChildAt(_bkg, 0);
			_bkg.graphics.beginFill(0xEEEEEE, .6);
			_bkg.graphics.drawRect(xFactor* _intervalMin, - yFactor*ySpread/2, xFactor * (_intervalMax - _intervalMin), yFactor*ySpread);
			_bkg.graphics.endFill();
			for(var i:int = Math.ceil(_intervalMin); i<= Math.floor(_intervalMax); i++){
				var x:Number = i;
				_bkg.graphics.lineStyle(1, 0xCCCCCC, .5, true, LineScaleMode.NONE);
				if(i == 0)
					_bkg.graphics.lineStyle(1, 0x333333, 1, true, LineScaleMode.NONE);
				_bkg.graphics.moveTo(xFactor* x, -yFactor* ySpread/2);
				_bkg.graphics.lineTo(xFactor* x, yFactor* ySpread);
			}
			
			for(i=  Math.floor(-1* ySpread/2); i< ySpread; i++){
				var y:Number = i;
				if(y % hResolution == 0){
					_bkg.graphics.lineStyle(1, 0xCCCCCC, .5, true, LineScaleMode.NONE);
					if(i == 0)
						_bkg.graphics.lineStyle(1, 0x333333, 1, true, LineScaleMode.NONE);
					_bkg.graphics.moveTo(xFactor*_intervalMin, yFactor*y);
					_bkg.graphics.lineTo(xFactor*_intervalMax, yFactor*y);
				}
			}
			//_bkg.scaleX = _width/ (_intervalMax - _intervalMin);
			//_bkg.scaleY = _height / ySpread;
			_bkg.y = _width/2 - (_width - _height)/2;
			_bkg.x = _width/2;
			//create plot layer
			if(_plot == null){
				clearPlots();
			}
			var rect:Sprite = new Sprite;
			rect.graphics.beginFill(0);
			rect.graphics.drawRect(0, 0, _width, _height);
			rect.graphics.endFill();
			this.addChild(rect);
			_bkg.mask = rect;
		}
	}
}