package com.ice.core {

		// Imports
		
		
		/**
		* <p>The fEngine class is the main class in the game engine.</p>
		*
		* <p>Use the fEngine class to create and attach game scenes to your game.</p>
		*
		* <p>You can also use it to load external swfs containing media you want to add to you scenes.</p>
		*
		* <p>Once the scenes are created you can go from one to another using the methods in
		* the fEngine class. The class handles all the drawing and screen refreshing.</p>
		*
		* @example The following code sets a basic isometric application with one scene
		*
		* <listing version="3.0">
		* // Create container
		* var filmationTest:Sprite = new Sprite()
		* addChild(filmationTest)
		* filmationTest.x = 0
		* filmationTest.y = 100
		* 
		* // Create engine
		* var film = new fEngine(filmationTest)
		* 
		* // Create scene and listen to load events
		* var scenel = film.createScene(new fSceneLoader("western.xml"),800,400)
		* scenel.addEventListener(fScene.CHANGESTAT, actionHandler)
		* scenel.addEventListener(fScene.LOAD, loadHandler)

		* function actionHandler(evt:Event) {
		*   trace("EVENT "+evt.target.stat)
		* }
		*
		* function loadHandler(evt:Event) {
		* 	// Scene is loaded and ready
		* 
		* 	// Create a camera and make it active
		* 	var cam = scenel.createCamera()
		* 	scenel.setCamera(cam)
		* 
		* 	// Render
		* 	scenel.render()
		* 	film.showScene(scenel)
		* }		
		*
		* </listing>
		*
		*/
		public class Engine extends EventDispatcher {
		
			 // Constants
			 
			 /**
		   * Just in case you want to display it
			 */
			 public static const VERSION:String = "1.3.3"

			 /**
		   * This constant is used everywhere to apply perspective correction to all heights
		   * @private
			 */
			 public static const DEFORMATION:Number = 0.7906
		   
			 /**
			 * To simplify sorting huge scenes, the scene is split into cubes of a given size. Elements are sorted only within the cubes and the cubes are
			 * sorted withinm themselves. Planes should't extend across cubes. The engine will split planes that cross cube bounds.
			 * This is the default cube size ( in pixels ) you can change it in a per Scene basis using the <b>cubeSize</b> attribute of your main <scene> node.
			 * <p>Also in future versions these self-containing cubes will be used to implement dynamic streaming of scene geometry.</p>
			 */
			 public static const SORTCUBESIZE:int = 2000

			 /**
		   * Use these constants to fine Tune projections until you see no seams between textures. Unfortunately as these seams are a result
		   * of pixel-rounding imperfections of the flash render engine, it will depend on your's scene's plane sizes and can't be solved generically.
		   * So it will be a matter of tryind different values until it looks good for you.
		   * <p>Range from 0.999 to 1.001. Set as 1 for default settings</p>
			 */
			 public static const RENDER_FINETUNE_1:Number = 1

			 /**
		   * Use these constants to fine Tune projections until you see no seams between textures. Unfortunately as these seams are a result
		   * of pixel-rounding imperfections of the flash render engine, it will depend on your's scene's plane sizes and can't be solved generically.
		   * So it will be a matter of tryind different values until it looks good for you
		   * <p>Range from -0.1 to 0.1. Set as 0 for default settings</p>
			 */
			 public static const RENDER_FINETUNE_2:Number = 0

			 /**
		   * Use these constants to fine Tune projections until you see no seams between textures. Unfortunately as these seams are a result
		   * of pixel-rounding imperfections of the flash render engine, it will depend on your's scene's plane sizes and can't be solved generically.
		   * So it will be a matter of tryind different values until it looks good for you
		   * <p>Range from -1 to 1. Set as 0 for default settings</p>
			 */
			 public static const RENDER_FINETUNE_3:Number = 0.0

		   /** @private */
		   public static var stage:Stage

			 /**
 			 * The fEngine.MEDIALOADPROGRESS constant defines the value of the 
 			 * <code>type</code> property of the event object for a <code>enginemedialoadprogress</code> event.
 			 * The event is dispatched when there is a progress in loading an external media file, allowing to update a progress bar, for example.
 			 * 
 			 */
 		   public static const MEDIALOADPROGRESS:String = "enginemedialoadprogress"
       
			 /**
 			 * The fEngine.MEDIALOADCOMPLETE constant defines the value of the 
 			 * <code>type</code> property of the event object for a <code>enginemedialoadcomplete</code> event.
 			 * The event is dispatched when the external media file finishes loading.
 			 * 
 			 */
 		   public static const MEDIALOADCOMPLETE:String = "enginemedialoadcomplete"

			 /**
 			 * The fEngine.MEDIALOADERROR constant defines the value of the 
 			 * <code>type</code> property of the event object for a <code>enginemedialoaderror</code> event.
 			 * The event is dispatched when the external media file is not loaded.
 			 * 
 			 */
 		   public static const MEDIALOADERROR:String = "enginemedialoaderror"



			 // Static properties that define graphic options
			 
			 /**
			 * This property defines the amount of blurring applied to the any plane shadow's edges. Has some performance cost
			 */
			 public static var softShadows:int = 2

			 /**
			 * When this flag in activated, the engine minimizes memory usage at the cost of some performance. You can
			 * change it on the fly, for example if you are swithcing between small scenes and big ones.
			 * Still WIP. Don't use yet !!
			 * @private
			 */
			 public static var conserveMemory:Boolean = false

			 /**
			 * This property enables/disables shadow projection of objects
			 */
			 private static var _objectShadows:Boolean = true

			 /**
			 * This property enables/disables shadow projection of characters
			 */
			 private static var _characterShadows:Boolean = true
			 
			 /**
			 * This property defines the quality at which object and character shadows are rendered
			 */
			 private static var _shadowQuality:int = ShadowQuality.BEST
			 

			 /**
			 * This property enables/disables bumpmapping globally. Please note that for the bumpMapping to work in a given surface and light, the surface
			 * will need a bumpMap definition and the light must be defined as bumpmapped. Beware that only fast computers will be able to handle this
			 * in realtime
			 */
			 private static var _bumpMapping:Boolean = false

			 // Static private
		   private static var engines:Array = new Array
		   																	  // All engines
		   																	  

		   private static var media:Array = new Array
		   																		// List of media files that have already been loaded
		   																		// Static so it wotks with several engines ( eventhought I can't think of an scenario where you
		   																		// would want more than one engine

			 // Private
		   public var container:Sprite    		// Main moviecontainer
		   private var scenes:Array           // List of scenes
		   
		   /** Scene being currently displayed */
		   public var current: Scene				
		   
		   /** @private */
		   public static var context:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain)

		
			 // Constructor

			 /**
		   * Constructor for the fEngine class.
		   *
		   * @param container An sprite object where the engine will draw your game
			 */
			 function Engine(container:Sprite):void {
		
					this.container = container
					this.scenes	= new Array
					this.current = null
					
					// Arrg dirty trick !! So I have access to onenterframe events from anywhere in the engine
					if(!Engine.stage) {
						if(container.stage)	Engine.stage = container.stage
						else container.addEventListener(Event.ADDED_TO_STAGE,this.getStage)
					}
					
					
					// Add engine to list of all engines
					Engine.engines[Engine.engines.length] = this
					
			 }
			 
			 // Retrieves stage
			 private function getStage(e:Event):void {
			 		var s:Sprite = e.target as Sprite
			 		Engine.stage = s.stage
			 		s.removeEventListener(Event.ADDED_TO_STAGE,this.getStage)
			 }
			
			 /**
			 * This method loads an external media file. Once the media file is loaded, the symbols in that file can
			 * be used in you scene definitions. Listen to the engine's MEDIALOADPROGRESS and MEDIALOADCOMPLETE to
			 * control the process. The class checks if the media is already loaded to avoid duplicate loads.
			 *
			 * <p><b>WARNING !</b> If you want to use the engine from within an Adobe AIR application, make sure to execute this
			 * line: <b>fEngine.context.allowLoadBytesCodeExecution = true</b> before creating an scene. Otherwise assets won't load
			 * into the application security domain and won't work.</p>
			 *
			 * @param src Path to the swf file you want to load
			 *
			 */
			 public function loadMedia(src:String) {
			 	
				 	if(Engine.media[src]==null) {
				 	
				 		// This file is not loaded
				 		Engine.media[src] = true
				 		
						// Using loadBytes allows the adobe AIR editor to import loaded swfs into its security domain
						if(Capabilities.playerType=="Desktop") {
							
							var ByteLoader:URLLoader = new URLLoader()
							ByteLoader.dataFormat = URLLoaderDataFormat.BINARY
							ByteLoader.addEventListener(Event.COMPLETE, this.loadBytesComplete,false,0,true)
							ByteLoader.addEventListener(ProgressEvent.PROGRESS, this.loadBytesProgress,false,0,true)
							ByteLoader.addEventListener(IOErrorEvent.IO_ERROR, this.loadBytesError,false,0,true)
							ByteLoader.load(new URLRequest(src))
							
					  } else {

				 			var cLoader:Loader = new Loader()
				  		cLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete,false,0,true)
				  		cLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.loadProgress,false,0,true)
				  		cLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.loadError,false,0,true)
				  		cLoader.load(new URLRequest(src),Engine.context)
				  	
				  	}
				  
					} else {
						
						// Already loaded
						this.dispatchEvent(new Event(Engine.MEDIALOADCOMPLETE))
					
					}
			 	
			 }

			 // Using loadBytes allows the adobe AIR editor to import loaed swfs into its security domain
			 private function loadBytesError(event:IOErrorEvent):void {

			  	event.target.removeEventListener(Event.COMPLETE,this.loadBytesComplete)
				  event.target.removeEventListener(ProgressEvent.PROGRESS,this.loadBytesProgress)
				  event.target.removeEventListener(IOErrorEvent.IO_ERROR ,this.loadBytesError)
			   	this.dispatchEvent(new Event(Engine.MEDIALOADERROR))

			 }

			 private function loadBytesComplete(event:Event):void {

			  	event.target.removeEventListener(Event.COMPLETE,this.loadBytesComplete)
				  event.target.removeEventListener(ProgressEvent.PROGRESS,this.loadBytesProgress)
				  event.target.removeEventListener(IOErrorEvent.IO_ERROR ,this.loadBytesError)
				  
				 	var cLoader:Loader = new Loader()
				  cLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete,false,0,true)
				  cLoader.loadBytes(event.target.data,Engine.context)
				  
			 }
			
			 private function loadBytesProgress(event:ProgressEvent):void {
			 	
			 	  var ret:ProgressEvent = new ProgressEvent(Engine.MEDIALOADPROGRESS)
			 	  ret.bytesLoaded = event.bytesLoaded
			 	  ret.bytesTotal = event.bytesTotal
			    dispatchEvent(ret)
			   
			 }


			 // This is the standard non-Air media load process
			 private function loadError(event:IOErrorEvent):void {

			  	event.target.removeEventListener(Event.COMPLETE,this.loadComplete)
				  event.target.removeEventListener(ProgressEvent.PROGRESS,this.loadProgress)
				  event.target.removeEventListener(IOErrorEvent.IO_ERROR ,this.loadError)
			   	this.dispatchEvent(new Event(Engine.MEDIALOADERROR))

			 }

			 private function loadComplete(event:Event):void {

			  	event.target.removeEventListener(Event.COMPLETE,this.loadComplete)
				  event.target.removeEventListener(ProgressEvent.PROGRESS,this.loadProgress)
				  event.target.removeEventListener(IOErrorEvent.IO_ERROR ,this.loadError)
			   	this.dispatchEvent(new Event(Engine.MEDIALOADCOMPLETE))
			 }
			
			 private function loadProgress(event:ProgressEvent):void {
			 	
			 	  var ret:ProgressEvent = new ProgressEvent(Engine.MEDIALOADPROGRESS)
			 	  ret.bytesLoaded = event.bytesLoaded
			 	  ret.bytesTotal = event.bytesTotal
			    dispatchEvent(ret)
			   
			 }

			 /**
		   * This method creates an scene from an XML definition file. The scene starts loading and
		   * compiling at this moment, but will not be ready to use yet. You should wait for the scene's LOAD
		   * event before making it active
		   *
		   * @param retriever Any class that implements the fEngineSceneRetriever interface
			 *
			 * @param width Width of the viewport, in pixels. This avoids the need of masking the whole sprite		   
		   *
			 * @param height Height of the viewport, in pixels. This avoids the need of masking the whole sprite		   
			 *
			 * @param renderer A renderer class for this scene. If none is specified, a default flash 9 renderer will be used
			 *
			 * @param prof If a profiler is passed, the scene will update the profiler with some info that I hope becomes useful to tune the performance of your application
			 *
		   * @return A fScene Object.
			 */
			 public function createScene(retriever:fEngineSceneRetriever,width:Number,height:Number,renderer:fEngineRenderEngine=null,prof:fProfiler=null):Scene {
		
		   		// Create container for scene
		   		var nSprite:Sprite = new Sprite()

		   		// Create scene
		   		var nfScene:Scene = new Scene(this,nSprite,retriever,width,height,renderer,prof)
					nfScene.initialize()
					
		   		// Add to list and return
		   		this.scenes[this.scenes.length] = nfScene
		   		return nfScene
		   		
		   }

			 /**
			 * This method frees all resources allocated by an scene. Use this as often as possible and always clean unused scene objects:
			 * scenes generate lots of internal Arrays and BitmapDatas that will eat your RAM fast if they are not properly deleted
			 *
		   * @param sc The fScene you want to destroy
			 */
			 public function destroyScene(sc:Scene):void {
			 		this.hideScene(sc)
			 		sc.dispose()
			 		this.scenes.splice(this.scenes.indexOf(sc),1)
 					objectPool.flush()
			 }

			 /**
		   * Makes visible one scene in the Engine. Only one scene can be visible at the same time.
		   * The current visible scene, if any, will me moved to the invisible scene list.<br>
		   * Showing an scene does not enable it
		   *
		   * @param sc The fScene you want to activate
		   */
			 public function showScene(sc:Scene):void {
			 	
			 	  if(this.current==sc) return
			 	  
			 	  if(this.current!=null) {
			 	  	this.current.stopRendering()
			 	  	this.container.removeChild(this.current.container)
			 	  }

			 	  this.current = sc
		 	  	this.current.startRendering()
		 	  	this.current.enable()
			 	  this.container.addChild(sc.container)

			 }

			 /**
		   * Hides an scene.<br>
		   * Hiding an scene does not disable it.<br>
		   * If you hide an scene all the Sprites and graphic resources are destroyed, and so are Mouse Events attached to them. You will need
		   * to reset the events if the scene is shown again.
		   *
		   * <p><b>IMPORTANT!</b>: Hidden scenes still consume memory. If you want to free all resources allocated by scenes that will no longer be used, use the fEngine.destroy() method.</p>
		   *
		   * @param sc The fScene you want to hide
		   * @param destroyRender Pass false if you don't want the rendering to be destroyed when you hide the scene. By doing this, the graphics are already available when the scene is shown again
		   */
			 public function hideScene(sc:Scene,destroyRender:Boolean=true):void {
			 	
			 	  if(this.current==sc) {
			 	  	if(destroyRender) this.current.stopRendering()
			 	  	this.container.removeChild(this.current.container)
			 	    this.current = null
			 	  }

			 }
			 
			 
			 // SET AND GET METHODS

			 /**
			 * This property enables/disables bumpmapping globally. Please note that for the bumpMapping to work in a given surface and light, the surface
			 * will need a bumpMap definition and the light must be defined as bumpmapped. Beware that only fast computers will be able to handle this
			 * in realtime
			 */			 
			 public static function get bumpMapping():Boolean {
         return Engine._bumpMapping
       }

       public static function set bumpMapping(bmp:Boolean):void {
         Engine._bumpMapping = bmp
         
         // Update scenes
         for(var i:Number=0;i<Engine.engines.length;i++) {
         	
         		var e:Engine = Engine.engines[i]
         		if(e.current) e.current.render()
         }
       
       }			 

			 /**
			 * This property enables/disables shadow projection of objects
			 */
			 public static function get objectShadows():Boolean {
         return Engine._objectShadows
       }

       public static function set objectShadows(shd:Boolean):void {
       	
         Engine._objectShadows = shd

         // Update scenes
         for(var i:Number=0;i<Engine.engines.length;i++) {
         	
         		var e:Engine = Engine.engines[i]
         		if(e.current) {
         			e.current.resetGrid()
         			e.current.resetShadows()
         			e.current.render()
         		}

         }

       }			 

			 /**
			 * This property enables/disables shadow projection of characters
			 */
			 public static function get characterShadows():Boolean {
         return Engine._characterShadows
       }

       public static function set characterShadows(shd:Boolean):void {

         Engine._characterShadows = shd

         // Update scenes
         for(var i:Number=0;i<Engine.engines.length;i++) {
         	
         		var e:Engine = Engine.engines[i]
         		if(e.current) {
         			e.current.resetShadows()
         			e.current.render()
         		}
         }

       }			 


			 /**
			 * This property defines the quality at which object and character shadows are rendered
			 *
			 * @see org.ffilmation.engine.core.fShadowQuality
			 */
			 public static function get shadowQuality():int {
         return Engine._shadowQuality
       }

       public static function set shadowQuality(shd:int):void {

         Engine._shadowQuality = shd

         // Update scenes
         for(var i:Number=0;i<Engine.engines.length;i++) {
         	
         		var e:Engine = Engine.engines[i]
         		if(e.current) {
         			e.current.resetShadows()
         			e.current.render()
         		}
         }

       }			 


		}

}



