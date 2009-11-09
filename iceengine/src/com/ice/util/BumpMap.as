package com.ice.util {

		// Imports

		/**
		* @private
		* BumpMap class
		* From Ralph Hauwert's at UnitZeroOne (ralph@unitzeroone.com)
		*/
		public class BumpMap {

			private var __inputData : BitmapData;
			private var __outputData: BitmapData;
		
			public static var COMPONENT_X:Number = 1;
			public static var COMPONENT_Y:Number = 2;
			
			// Constructor
			public function BumpMap(inputData:BitmapData)	{
				this.inputData = inputData;
			}
			
			private function updateOutputData():void	{

				//Generates a Normal Map out of a supplied BitmapData, using the convolution filter.
				var tempMap:BitmapData;
				var p:Point = new Point();
				var convolve:ConvolutionFilter = new ConvolutionFilter();
				convolve.matrixX = 3;
				convolve.matrixY = 3;
				convolve.divisor = 1;
				convolve.clamp = false
				convolve.bias = 127;
				
				if(__outputData != null){
					__outputData.dispose();	
				}
				//__outputData = inputData.clone();
				__outputData = new BitmapData(inputData.width,inputData.height,false,0x808080)
				
				//Calculate x normals, copy to outputData.
				convolve.matrix = new Array(0,0,0,-1,0,1,0,0,0);
				tempMap = inputData.clone();
				tempMap.applyFilter(inputData, inputData.rect, p, convolve);
				
				var p2:Point = new Point(1,1)
				var r:Rectangle = new Rectangle(1,1,inputData.width-2,inputData.height-2)
				//__outputData.copyPixels(tempMap, tempMap.rect, p)
				__outputData.copyChannel(tempMap, r, p2, COMPONENT_X, COMPONENT_X);
				
				//Calculate y normals, copy to outputData.
				convolve.matrix = new Array(0,-1,0,0,0,0,0,1,0);
				tempMap = inputData.clone();
				tempMap.applyFilter(inputData, inputData.rect, p, convolve);
				__outputData.copyChannel(tempMap, r, p2, COMPONENT_Y, COMPONENT_Y);
				
				tempMap.dispose();
			}
			
			public function get outputData():BitmapData 	{
				return __outputData;	
			}
			
			public function set inputData(ainputData:BitmapData):void {
				__inputData = ainputData;
				updateOutputData();
			}
				
			public function get inputData():BitmapData {
				return __inputData;
			}

		}

}
