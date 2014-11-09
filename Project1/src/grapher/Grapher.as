package grapher
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Grapher extends Sprite
	{
		private var _width:uint;
		private var _height:uint;
		
		private var _intervalMin:Number;
		private var _intervalMax:Number;

		private var _bkg:Sprite;
		private var _plottedPoints:Array;
		private var _plot:Sprite;
		
		public function Grapher(w:uint, h:uint, min:Number, max:Number)
		{
			_width = w;
			_height = h;
			_intervalMin = min;
			_intervalMax = max;
			_plottedPoints = new Array;
			super();
			drawBackground();
			plotPoint(-2, -1);
		}
		
		public function plotPoint(x:Number, y:Number, color:Number = 0):void {
			if(_plot == null){
				_plot = new Sprite;
				this.addChildAt(_plot, 1);
			}
			var p:Sprite = new Sprite;
			p.graphics.beginFill(color);
			p.graphics.drawCircle(0, 0, 2);
			p.graphics.endFill();
			this._plottedPoints.push(p);
			_plot.addChild(p);
			p.x = this.coordinates(x, y).x;
			p.y = this.coordinates(x, y).y;
		}
		
		private function coordinates(x:Number, y:Number):Point {			
			var unit:Number = _width/(_intervalMax - _intervalMin);
			var heightInUnits:Number = Math.floor(_height/unit);
			return new Point((x - _intervalMin) * unit, unit * (heightInUnits/2 - y));
		}
		
		private function drawBackground():void {
			if(_bkg != null && this.contains(_bkg)){
				this.removeChildAt(0);
			}
			_bkg = new Sprite;
			this.addChildAt(_bkg, 0);
			_bkg.graphics.beginFill(0xEEEEEE, .6);
			_bkg.graphics.drawRect(0, 0, _width, _height);
			_bkg.graphics.endFill();
			var unit:Number = _width/(_intervalMax - _intervalMin);
			for(var i:int = Math.ceil(_intervalMin); i<= Math.floor(_intervalMax); i++){
				var x:Number = (i- _intervalMin) * unit;
				_bkg.graphics.lineStyle(1, 0xCCCCCC, .5);
				if(i == 0)
					_bkg.graphics.lineStyle(1, 0x333333, 1);
				_bkg.graphics.moveTo(x, this._height);
				_bkg.graphics.lineTo(x, 0);
			}
			
			var heightInUnits:Number = Math.floor(_height/unit);
			for( i= 1; i<= Math.floor(_height/unit); i++){
				var y:Number =  i * unit;
				_bkg.graphics.lineStyle(1, 0xCCCCCC, .5);
				if(i == Math.floor(heightInUnits/2))
					_bkg.graphics.lineStyle(1, 0x333333, 1);
				_bkg.graphics.moveTo(0, y);
				_bkg.graphics.lineTo(_width, y);
			}
		}
	}
}