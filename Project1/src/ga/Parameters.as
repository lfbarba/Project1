package ga
{
	import fl.data.DataProvider;
	import fl.events.SliderEvent;
	
	import flash.events.Event;
	
	import gp.FuncionEvaluable;
	import gp.FunctionTree;
	import gp.targetFunctions.CustomFunction;
	import gp.targetFunctions.FunctionA;
	import gp.targetFunctions.FunctionB;
	import gp.targetFunctions.FunctionC;

	public class Parameters extends ParametersBase
	{	
		public static var inst:Parameters;
		
		public static const TOURNAMENT_SELECTION:uint = 0;
		
		public static var SubtreeSwapCrossover:uint = 0;
		public static var FairSubtreeSwapCrossover:uint = 1;
		
		
		public static var SubTreeReplacementMutation:uint = 0;
		
		
		public function Parameters()
		{
			inst = this;
			this.addEventListener(Event.ADDED_TO_STAGE, addedStageHandler);
			super();
			populationSizeSlideBar.minimum = 10;
			populationSizeSlideBar.maximum = 2000;
			populationSizeSlideBar.snapInterval = 10;
			this.populationSizeSlideBar.addEventListener(SliderEvent.THUMB_DRAG, changeHappened);
			populationSizeSlideBar.value = 1000;
			
			
			this.mutationProbabilitySlideBar.minimum = .0;
			this.mutationProbabilitySlideBar.maximum = 1;
			this.mutationProbabilitySlideBar.snapInterval = .01
			mutationProbabilitySlideBar.addEventListener(SliderEvent.THUMB_DRAG, changeHappened);
			mutationProbabilitySlideBar.value = .28;
			
			crossoverProbabilitySlideBar.minimum = .0;
			crossoverProbabilitySlideBar.maximum = 1;
			crossoverProbabilitySlideBar.snapInterval = .01;
			crossoverProbabilitySlideBar.addEventListener(SliderEvent.THUMB_DRAG, changeHappened);
			this.crossoverProbabilitySlideBar.value = 1;
			
			
			tournamentSelectionParameters.tournamentRangeSlideBar.maximum = 30;
			tournamentSelectionParameters.tournamentRangeSlideBar.minimum = 1;
			tournamentSelectionParameters.tournamentRangeSlideBar.snapInterval = 1;
			tournamentSelectionParameters.tournamentRangeSlideBar.addEventListener(SliderEvent.THUMB_DRAG, changeHappened);
			tournamentSelectionParameters.tournamentRangeSlideBar.value = 12;
			
			tournamentSelectionParameters.tournamentProbabilitySlideBar.maximum = 1;
			tournamentSelectionParameters.tournamentProbabilitySlideBar.minimum = .05;
			tournamentSelectionParameters.tournamentProbabilitySlideBar.snapInterval = .01;
			tournamentSelectionParameters.tournamentProbabilitySlideBar.addEventListener(SliderEvent.THUMB_DRAG, changeHappened);
			tournamentSelectionParameters.tournamentProbabilitySlideBar.value = .54;
			
			var targetFunction:Array = new Array;
			targetFunction.push({label:"Select a function"});
			targetFunction.push(new FunctionA);
			targetFunction.push(new FunctionB);
			targetFunction.push(new CustomFunction);
			targetFunctionComboBox.addEventListener(Event.CHANGE, this.changeHappened);
			targetFunctionComboBox.dataProvider = new DataProvider(targetFunction);
			
			this.yourFunction.visible = false;
			this.yourFunction.yourFunctionText.addEventListener(Event.CHANGE, this.changeHappened);
			
			var crossoverOptions:Array = new Array;
			crossoverOptions.push({label:"Fair Subtree Swap Crossover", value: FairSubtreeSwapCrossover});
			crossoverOptions.push({label:"Subtree Swap Crossover", value: SubtreeSwapCrossover});
			crossoverComboBox.addEventListener(Event.CHANGE, this.changeHappened);
			this.crossoverComboBox.dataProvider = new DataProvider(crossoverOptions);
			
			var mutationOptions:Array = new Array;
			mutationOptions.push({label:"SubTree Replacement Mutation", value: SubTreeReplacementMutation});
			mutationComboBox.addEventListener(Event.CHANGE, this.changeHappened);
			this.mutationComboBox.dataProvider = new DataProvider(mutationOptions);
		}
		
		private function addedStageHandler(e:Event):void {
			this.changeHappened();
		}
		
		public function updateNumGenerations(round:uint):void {
			this.roundNumber.text = ""+round;
		}
		
		public function getSelectionType():uint {
			return TOURNAMENT_SELECTION;
		}
		
		public function getPopulationSize():uint {
			return this.populationSizeSlideBar.value;
		}
		
		public function getMutationProbability():Number {
			return this.mutationProbabilitySlideBar.value;
		}
		
		public function getCrossoverProbability():Number {
			return this.crossoverProbabilitySlideBar.value;
		}
		
		public function getTournamentSelecProbability():Number {
			return tournamentSelectionParameters.tournamentProbabilitySlideBar.value;
		}
		
		public function getTournamentSelectRange():Number {
			return tournamentSelectionParameters.tournamentRangeSlideBar.value;
		}
		
		public function getCrossoverType():uint {
			return this.crossoverComboBox.selectedItem.value;
		}
		
		public function getMutationType():uint {
			return this.mutationComboBox.selectedItem.value;
		}
		
		public function getTargetFunction():FuncionEvaluable {
			if(targetFunctionComboBox.selectedItem is FuncionEvaluable){
				if(targetFunctionComboBox.selectedItem is CustomFunction){
					var cf:CustomFunction = targetFunctionComboBox.selectedItem as CustomFunction;
					cf.setFunction(yourFunction.yourFunctionText.text);
					yourFunction.visible = true;
				}else{
					yourFunction.visible = false;
				}
				return this.targetFunctionComboBox.selectedItem as FuncionEvaluable;
			} else {
				return null;
			}
		}
		
		
		private function changeHappened(e:Event = null):void {
			this.populationSize.text = String(this.populationSizeSlideBar.value);
			this.mutationProbability.text = String(this.mutationProbabilitySlideBar.value);
			this.crossoverProbability.text = String(this.crossoverProbabilitySlideBar.value);
			this.tournamentSelectionParameters.tournamentSelecProbability.text = String(tournamentSelectionParameters.tournamentProbabilitySlideBar.value);
			this.tournamentSelectionParameters.tournamentSelecRange.text = String(tournamentSelectionParameters.tournamentRangeSlideBar.value);
			notifyChanges();
		}
		
		private function notifyChanges():void {
			var e:ParametersChangeEvent = new ParametersChangeEvent(ParametersChangeEvent.PARAMETERS_CHANGE, this);
			this.dispatchEvent(e);
		}
		
		public function updateStatistics(max:Number, min:Number, avg:Number, best:Number, current:Number, bestFunction:FunctionTree):void{
			this.maxFitness.text  = String(max);
			this.minFitness.text = String(min);
			this.avgFitness.text = String(avg);
			this.bestFitness.text = String(best);
			this.currentFitness.text = String(current);
			if(bestFunction != null){
				this.bestFunction.text = bestFunction.toString();
			}
		}
	}
}