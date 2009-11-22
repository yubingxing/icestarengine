package com.ice.core.base {
	
	/**
	 * The fclass provides a list of all available material types in the engine,
	 * as well as examples of how to create them.
	 *
	 */
	public class {
		
		
		/**
		 * <p>Creates a material by "Tiling" an image in the imported libraries.</p>
		 *
		 * @example Here's an example of how to define a material of type fTILE
		 *
		 * <listing version="3.0">
		 * &lt;materialDefinition name="Ground" type="tile"&gt;
		 *    &lt;diffuse&gt;Ground&lt;/diffuse&gt;
		 *    &lt;bump&gt;Ground_bump&lt;/bump&gt;
		 * &lt;/materialDefinition&gt;<br>
		 * </listing>
		 *
		 * <b>diffuse</b>:  export name of the symbol to use as diffuse map, an image for "tile" materials and a movieClip for "clip" materials<br>
		 * <b>bump</b>: (optional) export name of the symbol to use as bumpmap. If none, this material is not bumpmapped<br>
		 *
		 */
		public static const TILE:String = "tile";
		
		/**
		 * <p>Creates a material from a MovieClip or image exported in any SWF you import into the scene.
		 * The clip/image is scaled to fit the requested dimensions. If you want it to tile, use the fTileMaterial instead.</p>
		 *
		 * <p>If you use a movieClip, place your "hole" definition clips only in the first frame. After reading the holes
		 * the class will gotoAndStop(2) the clip. In frame 2 you should have what you want to be visible as well as clips
		 * for doors and windows. See examples and tutorials for further info on holes, doors and windows</p>
		 *
		 * @example Here's an example of how to define a material of type fCLIP
		 *
		 * <listing version="3.0">
		 * &lt;materialDefinition name="Ground" type="clip"&gt;
		 *   &lt;diffuse&gt;Ground&lt;/diffuse&gt;
		 *   &lt;bump&gt;Ground_bump&lt;/bump&gt;
		 * &lt;/materialDefinition&gt;
		 * </listing>
		 *
		 * <b>diffuse</b>:  export name of the symbol to use as diffuse map, an image for "tile" materials and a movieClip for "clip" materials<br>
		 * <b>bump</b>: (optional) export name of the symbol to use as bumpmap. If none, this material is not bumpmapped<br>
		 *
		 */
		public static const CLIP:String = "clip";
		
		/**
		 * <p>Creates a material by stacking several layers of "tile" materials, using a perlin noise funcion as alpha mask for each layer.</p>
		 *
		 * <p>Perlin materials are procedural materials formed by a base material and unlimited layers of other materials,
		 * each one rendered from a perlin noise definition.</p>
		 *
		 * <p>The perlin noise for each layer is used as the alpha-mask for that layer.</p>
		 *
		 * <p>Both the base material and the layer materials must be "tile" materials and their definitions must
		 * be included for the perlin material to work.</p>
		 * <p>With perlin materials, you can create more natural-looking environments without extra effort</p>
		 *
		 * @example Here's an example of how to define a material of type fPERLIN
		 *
		 * <listing version="3.0">
		 * &lt;noiseDefinition name="Ground_noise_2"&gt;
		 *   &lt;seed&gt;0&lt;/seed&gt;     
		 *   &lt;baseX&gt;200&lt;/baseX&gt;
		 *   &lt;baseY&gt;200&lt;/baseY&gt;
		 *   &lt;octaves&gt;2&lt;/octaves&gt;
		 *   &lt;fractal&gt;true&lt;/fractal&gt;
		 * &lt;/noiseDefinition&gt;
		 * <br>
		 * &lt;materialDefinition name="MNIP_VillageMaterials_Ground" type="perlin"&gt;
		 *   &lt;base&gt;FFMaterials_ground_Ground1&lt;/base&gt;
		 *   &lt;layer&gt;
		 *     &lt;noise&gt;Ground_noise_2&lt;/noise&gt;
		 *     &lt;material&gt;FFMaterials_ground_Ground7&lt;/material&gt;
		 *   &lt;/layer&gt;
		 * &lt;/materialDefinition&gt;
		 * </listing>
		 *
		 * <b>seed</b>:  The random seed number to use. If you keep all other parameters the same, you can generate different pseudo-random results by varying the random seed value. The Perlin noise function creates the same results each time from the same random seed. Use 0 if you want the engine to pick a random seed each time<br>
		 * <b>baseX</b>: Frequency to use in the x direction.<br>
		 * <b>baseY</b>: Frequency to use in the y direction.<br>
		 * <b>octaves</b>: Number of octaves or individual noise functions to combine to create this noise. Larger numbers of octaves create noise with greater detail. Larger numbers of octaves also require more processing time.<br>
		 * <b>fractal</b>: If the value is true, the method generates fractal noise; otherwise, it generates turbulence. An image with turbulence has visible discontinuities in the gradient that can make it better approximate sharper visual effects like flames and ocean waves.<br>
		 *
		 */
		public static const PERLIN:String = "perlin";
		
		/**
		 * <p>Creates a door in any wall. The Door material allows users to build doors fast.</p>
		 *
		 * @example Here's an example of how to define a material of type fDOOR
		 *
		 * <listing version="3.0">
		 * &lt;materialDefinition name="MNIP_VillageMaterials_Door13" type="door"&gt;
		 *     &lt;base&gt;FFMaterials_woods2_Wood2_13&lt;/base&gt;
		 *     &lt;frame&gt;FFMaterials_woods2_Wood2_11&lt;/frame&gt;
		 *     &lt;door&gt;FFMaterials_woods2_Wood2_14&lt;/door&gt;
		 *     &lt;position&gt;0&lt;/position&gt;
		 *     &lt;width&gt;90&lt;/width&gt;
		 *     &lt;height&gt;150&lt;/height&gt;
		 *     &lt;framesize&gt;10&lt;/framesize&gt;
		 * &lt;/materialDefinition&gt;   
		 * </listing>
		 *
		 * <b>base</b>: Base "tile" material for the wall<br>
		 * <b>frame</b>: Frame material<br>
		 * <b>door</b>: Door material<br>
		 * <b>position</b>: Door position, as percent of wall size, from -100 to 100. The default 0 value centers the door in the wall<br>
		 * <b>width</b>: Door size, without frame<br>
		 * <b>height</b>: Door size, without frame<br>
		 * <b>framesize</b>: Frame size<br>
		 *
		 */
		public static const DOOR:String = "door";
		
		/**
		 * <p>Adds windows to any wall. This is a fast way of creating nicer buildings with little effort. Keep in mind that holes have
		 * an impact in performace of the collision an light algorythms and therefore, this material has to be used with moderation.</p>
		 *
		 * @example Here's an example of how to define a material of type fWINDOW
		 *
		 * <listing version="3.0">
		 * &lt;materialDefinition name="MNIP_VillageMaterials_Windows13" type="window"&gt;
		 *     &lt;base&gt;FFMaterials_woods2_Wood2_13&lt;/base&gt;
		 *     &lt;frame&gt;FFMaterials_woods2_Wood2_11&lt;/frame&gt;
		 *     &lt;position&gt;0&lt;/position&gt;
		 *     &lt;width&gt;60&lt;/width&gt;
		 *     &lt;height&gt;90&lt;/height&gt;
		 *     &lt;framesize&gt;5&lt;/framesize&gt;
		 *     &lt;separation&gt;80&lt;/separation&gt;
		 *     &lt;geometry&gt;2x2&lt;/geometry&gt;
		 * &lt;/materialDefinition&gt;   
		 * </listing>
		 *
		 * <b>base</b>: Base "tile" material for the wall<br>
		 * <b>frame</b>: Frame material<br>
		 * <b>position</b>: Windows' vertical position, as percent of wall height, from -100 to 100.The default 0 value centers the windows vertically in the wall<br>
		 * <b>width</b>: Window size, without frame<br>
		 * <b>height</b>: Window size, without frame<br>
		 * <b>framesize</b>: Frame size<br>
		 * <b>separation</b>: Horizontal gap between windows. The engine will fit as many windows as possible depending on this value, the windows' width and the size of the plane where this material is applied<br>
		 * <b>geometry</b>: Window geometry, like 3x2 or 2x4. Its default value will draw one single window without subdivisions<br>
		 *
		 */
		public static const WINDOW:String = "window";
		
		/**
		 * <p>Creates a Fence material. Keep in mind that holes have an impact in performace of the collision an light algorythms
		 * and therefore, this material has to be used with moderation.</p>
		 * @example Here's an example of how to define a material of type fFENCE
		 *
		 * <listing version="3.0">
		 * &lt;materialDefinition name="MNIP_VillageMaterials_Fence" type="fence"&gt;
		 * 		&lt;base&gt;FFMaterials_woods1_Wood1_9&lt;/base&gt;
		 * 		&lt;width&gt;20&lt;/width&gt;
		 * 		&lt;gap&gt;10&lt;/gap&gt;
		 * 		&lt;irregular&gt;20&lt;/irregular&gt;
		 * &lt;/materialDefinition&gt;   
		 * </listing>
		 *
		 * <b>base</b>: Base "tile" material for the wall<br>
		 * <b>width</b>: Size of every post<br>
		 * <b>gap</b>: Space between posts<br>
		 * <b>irregular</b>: Between 0 and 100. Randomly alters height of every post to generate a more natural look<br>
		 */
		public static const FENCE:String = "fence";
		
		/**
		 * <p>Creates a material using a custom class. The class must implement the fEngineMaterial interface</p>
		 *
		 * @see org.ffilmation.engine.interfaces.fEngineMaterial
		 * @example Here's an example of how to define a material of type fPROCEDURAL
		 *
		 * <listing version="3.0">
		 * &lt;materialDefinition name="Ground" type="procedural"&gt;
		 *    &lt;classname&gt;com.domain.game.materials.myMaterial&lt;/classname&gt;
		 * &lt;/materialDefinition&gt;<br>
		 * </listing>
		 *
		 * <b>classname</b>: class to be used. Make sure it is included when you compile your application<br>
		 *
		 */
		public static const PROCEDURAL:String = "procedural";
		
		/**
		 * An array of strings with all available material types
		 */
		public static const all:Array = [TILE, CLIP, PERLIN, DOOR, WINDOW, FENCE, PROCEDURAL];
	}
}