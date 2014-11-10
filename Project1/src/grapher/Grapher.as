package grapher
{
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import gp.FuncionEvaluable;
	import gp.FunctionA;
	import gp.FunctionTree;
	import gp.TFunction;
	
	public class Grapher extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		
		private var _intervalMin:Number;
		private var _intervalMax:Number;

		private var _bkg:Sprite;
		private var _plottedPoints:Array;
		private var _plot:Sprite;
		
		public function Grapher(w:Number, h:Number, min:Number, max:Number)
		{
			_width = w;
			_height = h;
			_intervalMin = min;
			_intervalMax = max;
			_plottedPoints = new Array;
			super();
			drawBackground(200, 20);
			//
			var f:FunctionA = new FunctionA;
			this.plotFunction(f);
		}
		
		public function plotFunction(f:FuncionEvaluable, resolution:Number = .05):void {
			for(var x:Number = _intervalMin; x < _intervalMax; x = x + resolution){
				var y:Number = f.evaluate(x);
				this.plotPoint(x, y);
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
		
		private function coordinates(x:Number, y:Number):Point {			
			var p:Point = new Point(x, -y);
			 p = _bkg.localToGlobal(p);
			return p;
		}
		
		private function drawBackground(ySpread:Number = 200, hResolution:uint = 1):void {
			if(_bkg != null && this.contains(_bkg)){
				this.removeChildAt(0);
			}
			_bkg = new Sprite;
			this.addChildAt(_bkg, 0);
			_bkg.graphics.beginFill(0xEEEEEE, .6);
			_bkg.graphics.drawRect(_intervalMin, -1*ySpread/2, _intervalMax - _intervalMin, ySpread);
			_bkg.graphics.endFill();
			for(var i:int = Math.ceil(_intervalMin); i<= Math.floor(_intervalMax); i++){
				var x:Number = i;
				_bkg.graphics.lineStyle(1, 0xCCCCCC, .5, true, LineScaleMode.NONE);
				if(i == 0)
					_bkg.graphics.lineStyle(1, 0x333333, 1, true, LineScaleMode.NONE);
				_bkg.graphics.moveTo(x, -1* ySpread/2);
				_bkg.graphics.lineTo(x, ySpread);
			}
			
			for(i=  Math.floor(-1* ySpread/2); i< ySpread; i++){
				var y:Number = i;
				if(y % hResolution == 0){
					_bkg.graphics.lineStyle(1, 0xCCCCCC, .5, true, LineScaleMode.NONE);
					if(i == 0)
						_bkg.graphics.lineStyle(1, 0x333333, 1, true, LineScaleMode.NONE);
					_bkg.graphics.moveTo(_intervalMin, y);
					_bkg.graphics.lineTo(_intervalMax, y);
				}
			}
			_bkg.scaleX = _width/ (_intervalMax - _intervalMin);
			_bkg.scaleY = _height / ySpread;
			_bkg.y = _width/2 - (_width - _height)/2;
			_bkg.x = _width/2;
			//create plot layer
			if(_plot == null){
				_plot = new Sprite;
				this.addChildAt(_plot, 1);
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