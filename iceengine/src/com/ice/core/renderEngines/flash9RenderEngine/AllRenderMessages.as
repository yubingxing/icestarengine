package com.ice.core.renderEngines.flash9RenderEngine {
	
		/**
		* This stores constants of render messages available for the ffilmation render engine
		* @private
		*/
		public class AllRenderMessages {
		
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
			public static var invalidations0:Array = [AllRenderMessages.LIGHT_IN,AllRenderMessages.LIGHT_OUT]
			public static var invalidations1:Array = [AllRenderMessages.LIGHT_IN,AllRenderMessages.LIGHT_OUT]
			public static var invalidations2:Array = [AllRenderMessages.LIGHT_RESET]
			public static var invalidations3:Array = [AllRenderMessages.RENDER_START,AllRenderMessages.RENDER_LIGHT,AllRenderMessages.RENDER_SHADOW,AllRenderMessages.RENDER_FINISH]
			public static var invalidations4:Array = [AllRenderMessages.RENDER_LIGHT]
			public static var invalidations5:Array = [AllRenderMessages.REMOVE_SHADOW,AllRenderMessages.UPDATE_SHADOW,AllRenderMessages.RENDER_SHADOW]
			public static var invalidations6:Array = [AllRenderMessages.RENDER_FINISH]
			public static var invalidations7:Array = [AllRenderMessages.REMOVE_SHADOW,AllRenderMessages.UPDATE_SHADOW,AllRenderMessages.RENDER_SHADOW]
			public static var invalidations8:Array = [AllRenderMessages.REMOVE_SHADOW,AllRenderMessages.UPDATE_SHADOW,AllRenderMessages.RENDER_SHADOW]
			public static var invalidations9:Array = [AllRenderMessages.GLOBAL_INTESITY_CHANGE]
			public static var invalidations10:Array = [AllRenderMessages.GLOBAL_COLOR_CHANGE]
			public static var invalidations11:Array = [AllRenderMessages.START_OCCLUSION,AllRenderMessages.UPDATE_OCCLUSION,AllRenderMessages.STOP_OCCLUSION]
			public static var invalidations12:Array = [AllRenderMessages.UPDATE_OCCLUSION]
			public static var invalidations13:Array = [AllRenderMessages.START_OCCLUSION,AllRenderMessages.UPDATE_OCCLUSION,AllRenderMessages.STOP_OCCLUSION]
			
			public static var invalidations:Array = [
																							 AllRenderMessages.invalidations0,
																							 AllRenderMessages.invalidations1,
																							 AllRenderMessages.invalidations2,
																							 AllRenderMessages.invalidations3,
																							 AllRenderMessages.invalidations4,
																							 AllRenderMessages.invalidations5,
																							 AllRenderMessages.invalidations6,
																							 AllRenderMessages.invalidations7,
																							 AllRenderMessages.invalidations8,
																							 AllRenderMessages.invalidations9,
																							 AllRenderMessages.invalidations10,
																							 AllRenderMessages.invalidations11,
																							 AllRenderMessages.invalidations12,
																							 AllRenderMessages.invalidations13
																							]
			
		}
			
}
