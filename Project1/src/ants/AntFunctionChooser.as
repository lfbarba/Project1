package ants
{
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	import ga.Parameters;
	
	import gp.FunctionTree;

	public class AntFunctionChooser extends FunctionChooser
	{
		
		private var antFunctions:Array;
		public var bestFunction:FunctionTree;
		private var _currentIndex:uint = 0;
		private var _parameters:Parameters;
		
		public function AntFunctionChooser(p:Parameters)
		{
			super();
			_parameters = p;
			var saveDataObject:SharedObject = SharedObject.getLocal("savedFunctions");
			
			antFunctions = new Array;
			antFunctions.push(null);
			if(saveDataObject != null && saveDataObject.data.functions != undefined){
				var tmp:Array = String(saveDataObject.data.functions).split("*");
				for(var i:uint; i< tmp.length; i++){
					var f:FunctionTree = new FunctionTree;
					f.decodeFromData(tmp[i]);
					this.antFunctions.push(f);
				}
			}
			this.display();
			
			this.selectButton.addEventListener(MouseEvent.CLICK, selectFunction);
			this.previousButton.addEventListener(MouseEvent.CLICK, gotoPrevious);
			this.nextButton.addEventListener(MouseEvent.CLICK, gotoNext);
			this.closeButton.addEventListener(MouseEvent.CLICK, close);
			this.deleteButton.addEventListener(MouseEvent.CLICK, deleteFunction);
		}
		private function close(e:MouseEvent = null):void {
			this.visible = false;
		}
		
		private function deleteFunction(e:MouseEvent):void {
			if(_currentIndex!= 0)
				antFunctions.splice(_currentIndex, 1);
			_currentIndex = 0;
			this.selectFunction();
			this.display();
			this.saveFunction();
		}
		
		private function selectFunction(e:MouseEvent = null):void {
			this._parameters.notifyChanges();
			this.close();
		}
		
		public function get selectedFunction():FunctionTree {
			return this.antFunctions[this._currentIndex] as FunctionTree;
		}
		
		private function gotoPrevious(e:MouseEvent):void {
			_currentIndex = Math.max(0, _currentIndex - 1);
			this.display();
		}
		
		private function gotoNext(e:MouseEvent):void {
			_currentIndex = Math.min(_currentIndex+1, this.antFunctions.length-1);
			this.display();
		}
		
		private function display():void {
			var f:FunctionTree = this.antFunctions[_currentIndex] as FunctionTree;
			if(f == null){
				this.selectedFunctionText.text = "No function in the GP";
			}else{
				this.selectedFunctionText.text = f.toString();
			}
		}
		
		public function setBestFunction(f:FunctionTree):void {
			bestFunction = f;
			this.antFunctions[0] = bestFunction;
			this.display();
		}
		
		public function saveFunction():void {
			var encodings:Array = new Array;
			for(var i:uint = 1; i<antFunctions.length; i++){
				var f:FunctionTree = antFunctions[i] as FunctionTree;
				encodings.push(f.encode());
			}
			var saveDataObject:SharedObject = SharedObject.getLocal("savedFunctions");
			saveDataObject.data.functions = encodings.join("*");
			saveDataObject.flush();
		}
		
		public function saveCurrentBestFunction():void {
			this.antFunctions.push(bestFunction);
			this.saveFunction();
		}
	}
}