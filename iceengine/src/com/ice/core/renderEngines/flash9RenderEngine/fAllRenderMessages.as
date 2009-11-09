package com.ice.core.renderEngines.flash9RenderEngine {
	
		/**
		* This stores constants of render messages available for the ffilmation render engine
		* @private
		*/
		public class fAllRenderMessages {
		
			public static const LIGHT_IN:int = 0
			public static const LIGHT_OUT:int = 1
			public static const LIGHT_RESET:int = 2
			public static const RENDER_START:int = 3
			public static const RENDER_LIGHT:int = 4
			public static const RENDER_SHADOW:int = 5
			public static const RENDER_FINISH:int = 6
			public static const UPDATE_SHADOW:int = 7
			public static const REMOVE_SHADOW:int = 8
			public static const GLOBAL_INTESITY_CHANGE:int = 9
			public static const GLOBAL_COLOR_CHANGE:int = 10
			public static const START_OCCLUSION:int = 11
			public static const UPDATE_OCCLUSION:int = 12
			public static const STOP_OCCLUSION:int = 13
			
			/** The array of invalidations. Which message invalidates other messages */
			public static var invalidations0:Array = [fAllRenderMessages.LIGHT_IN,fAllRenderMessages.LIGHT_OUT]
			public static var invalidations1:Array = [fAllRenderMessages.LIGHT_IN,fAllRenderMessages.LIGHT_OUT]
			public static var invalidations2:Array = [fAllRenderMessages.LIGHT_RESET]
			public static var invalidations3:Array = [fAllRenderMessages.RENDER_START,fAllRenderMessages.RENDER_LIGHT,fAllRenderMessages.RENDER_SHADOW,fAllRenderMessages.RENDER_FINISH]
			public static var invalidations4:Array = [fAllRenderMessages.RENDER_LIGHT]
			public static var invalidations5:Array = [fAllRenderMessages.REMOVE_SHADOW,fAllRenderMessages.UPDATE_SHADOW,fAllRenderMessages.RENDER_SHADOW]
			public static var invalidations6:Array = [fAllRenderMessages.RENDER_FINISH]
			public static var invalidations7:Array = [fAllRenderMessages.REMOVE_SHADOW,fAllRenderMessages.UPDATE_SHADOW,fAllRenderMessages.RENDER_SHADOW]
			public static var invalidations8:Array = [fAllRenderMessages.REMOVE_SHADOW,fAllRenderMessages.UPDATE_SHADOW,fAllRenderMessages.RENDER_SHADOW]
			public static var invalidations9:Array = [fAllRenderMessages.GLOBAL_INTESITY_CHANGE]
			public static var invalidations10:Array = [fAllRenderMessages.GLOBAL_COLOR_CHANGE]
			public static var invalidations11:Array = [fAllRenderMessages.START_OCCLUSION,fAllRenderMessages.UPDATE_OCCLUSION,fAllRenderMessages.STOP_OCCLUSION]
			public static var invalidations12:Array = [fAllRenderMessages.UPDATE_OCCLUSION]
			public static var invalidations13:Array = [fAllRenderMessages.START_OCCLUSION,fAllRenderMessages.UPDATE_OCCLUSION,fAllRenderMessages.STOP_OCCLUSION]
			
			public static var invalidations:Array = [
																							 fAllRenderMessages.invalidations0,
																							 fAllRenderMessages.invalidations1,
																							 fAllRenderMessages.invalidations2,
																							 fAllRenderMessages.invalidations3,
																							 fAllRenderMessages.invalidations4,
																							 fAllRenderMessages.invalidations5,
																							 fAllRenderMessages.invalidations6,
																							 fAllRenderMessages.invalidations7,
																							 fAllRenderMessages.invalidations8,
																							 fAllRenderMessages.invalidations9,
																							 fAllRenderMessages.invalidations10,
																							 fAllRenderMessages.invalidations11,
																							 fAllRenderMessages.invalidations12,
																							 fAllRenderMessages.invalidations13
																							]
			
		}
			
}
