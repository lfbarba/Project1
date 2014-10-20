package ga
{
	import fl.data.DataProvider;
	import fl.events.SliderEvent;
	
	import flash.events.Event;

	public class Parameters extends ParametersBase
	{	
		public static var inst:Parameters;
		
		public static const TOURNAMENT_SELECTION:uint = 0;
		public static const ROULETTE_SELECTION:uint = 1;
		
		public static var ReversedPartiallyMappedCrossover:uint = 0;
		public static var OrderedPartiallyMappedCrossover:uint = 1;
		public static var ParallelPartiallyMappedCrossover:uint = 2;
		public static var OrderedPositionBasedCrossover:uint = 3;
		public static var ParallelPositionBasedCrossover:uint = 4;
		
		public static var InsertMutation:uint = 0;
		public static var ReverseMutation:uint = 1;
		public static var SwapMutation:uint = 2;
		public static var RandomMutation:uint = 3;
		
		
		public function Parameters()
		{
			inst = this;
			this.addEventListener(Event.ADDED_TO_STAGE, addedStageHandler);
			super();
			populationSizeSlideBar.minimum = 10;
			populationSizeSlideBar.maximum = 1000;
			populationSizeSlideBar.snapInterval = 10;
			this.populationSizeSlideBar.addEventListener(SliderEvent.THUMB_DRAG, changeHappened);
			populationSizeSlideBar.value = 150;
			
			
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
			
			var selectionOptions:Array = new Array;
			selectionOptions.push({label:"Tournament Selection", value: TOURNAMENT_SELECTION});
			selectionOptions.push({label:"Roulette Wheel Selection", value: ROULETTE_SELECTION});
			this.selectionComboBox.dataProvider = new DataProvider(selectionOptions);
			selectionComboBox.addEventListener(Event.CHANGE, changeHappened);
			selectionComboBox.selectedIndex = 0;
			
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
			
			rouletteParameters.roulettePreassureSliderBar.maximum = 1;
			rouletteParameters.roulettePreassureSliderBar.minimum = 0;
			rouletteParameters.roulettePreassureSliderBar.snapInterval = .05;
			rouletteParameters.roulettePreassureSliderBar.addEventListener(SliderEvent.THUMB_DRAG, changeHappened);
			rouletteParameters.roulettePreassureSliderBar.value = .5;
			
			var crossoverOptions:Array = new Array;
			crossoverOptions.push({label:"Reversed Partially Mapped Crossover", value: ReversedPartiallyMappedCrossover});
			crossoverOptions.push({label:"Ordered Partially Mapped Crossover", value: OrderedPartiallyMappedCrossover});
			crossoverOptions.push({label:"Parallel Partially Mapped Crossover", value: ParallelPartiallyMappedCrossover});
			crossoverOptions.push({label:"Ordered Position Based Crossover", value: OrderedPositionBasedCrossover});
			crossoverOptions.push({label:"Parallel Position Based Crossover", value: ParallelPositionBasedCrossover});
			crossoverComboBox.addEventListener(Event.CHANGE, this.changeHappened);
			this.crossoverComboBox.dataProvider = new DataProvider(crossoverOptions);
			
			var mutationOptions:Array = new Array;
			mutationOptions.push({label:"Random Mutation", value: RandomMutation});
			mutationOptions.push({label:"Insert Mutation", value: InsertMutation});
			mutationOptions.push({label:"Reverse Mutation", value: ReverseMutation});
			mutationOptions.push({label:"Swap Mutation", value: SwapMutation});
			mutationComboBox.addEventListener(Event.CHANGE, this.changeHappened);
			this.mutationComboBox.dataProvider = new DataProvider(mutationOptions);
				
			this.tournamentSelectionParameters.visible = true;
			this.rouletteParameters.visible = false;
		}
		
		private function addedStageHandler(e:Event):void {
			this.changeHappened();
		}
		
		public function updateNumGenerations(round:uint):void {
			this.roundNumber.text = ""+round;
		}
		
		public function getSelectionType():uint {
			return this.selectionComboBox.selectedItem.value as uint;
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
		
		public function getRouletteSelectionPressure():Number {
			return this.rouletteParameters.roulettePreassureSliderBar.value;
		}
		
		public function getCrossoverType():uint {
			return this.crossoverComboBox.selectedItem.value;
		}
		
		public function getMutationType():uint {
			return this.mutationComboBox.selectedItem.value;
		}
		
		
		private function changeHappened(e:Event = null):void {
			if(this.selectionComboBox.selectedItem.value == TOURNAMENT_SELECTION){
				this.tournamentSelectionParameters.visible = true;
				this.rouletteParameters.visible = false;
			}
			if(this.selectionComboBox.selectedItem.value == ROULETTE_SELECTION){
				this.tournamentSelectionParameters.visible = false;
				this.rouletteParameters.visible = true;
			}
			
			this.populationSize.text = String(this.populationSizeSlideBar.value);
			this.mutationProbability.text = String(this.mutationProbabilitySlideBar.value);
			this.crossoverProbability.text = String(this.crossoverProbabilitySlideBar.value);
			this.tournamentSelectionParameters.tournamentSelecProbability.text = String(tournamentSelectionParameters.tournamentProbabilitySlideBar.value);
			this.tournamentSelectionParameters.tournamentSelecRange.text = String(tournamentSelectionParameters.tournamentRangeSlideBar.value);
			this.rouletteParameters.roulettePreassue.text = String(this.rouletteParameters.roulettePreassureSliderBar.value);
			notifyChanges();
		}
		
		private function notifyChanges():void {
			var e:ParametersChangeEvent = new ParametersChangeEvent(ParametersChangeEvent.PARAMETERS_CHANGE, this);
			this.dispatchEvent(e);
		}
		
		public function updateStatistics(max:Number, min:Number, avg:Number, best:Number, current:Number){
			this.maxFitness.text  = String(max);
			this.minFitness.text = String(min);
			this.avgFitness.text = String(avg);
			this.bestFitness.text = String(best);
			this.currentFitness.text = String(current);
		}
	}
}