// SCENE

package com.ice.core.base {
	// Imports
	import com.ice.core.elements.Bullet;
	import com.ice.core.elements.Character;
	import com.ice.core.elements.EmptySprite;
	import com.ice.core.elements.OmniLight;
	import com.ice.core.events.MoveEvent;
	import com.ice.core.interfaces.IBulletRenderer;
	import com.ice.core.interfaces.IRenderEngine;
	import com.ice.core.interfaces.ISceneController;
	import com.ice.core.interfaces.ISceneRetriever;
	import com.ice.core.logic.visibility.VisibilitySolver;
	import com.ice.core.renderEngines.flash9RenderEngine.Flash9RenderEngine;
	import com.ice.core.scene.initialize.SceneInitializer;
	import com.ice.core.scene.initialize.SceneResourceManager;
	import com.ice.core.scene.logic.BulletSceneLogic;
	import com.ice.core.scene.logic.CharacterSceneLogic;
	import com.ice.core.scene.logic.EmptySpriteSceneLogic;
	import com.ice.core.scene.logic.LightSceneLogic;
	import com.ice.core.scene.logic.SceneRenderManager;
	import com.ice.helpers.SortArea;
	import com.ice.profiler.Profiler;
	import com.ice.util.ds.Cell;
	import com.ice.util.rtree.RTree;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	
	/**
	 * <p>The Scene class provides control over a scene in your application. The API for this object is used to add and remove 
	 * elements from the scene after it has been loaded, and managing cameras.</p>
	 *
	 * <p>Moreover, you can get information on topology, visibility from one point to another, search for paths and other useful
	 * methods that will help, for example, in programming AIs that move inside the scene.</p>
	 *
	 * <p>The data structures contained within this object are populated during initialization by the SceneInitializer class (which you don't need to understand).</p>
	 *
	 */
	public class Scene extends EventDispatcher {
		
		// This counter is used to generate unique scene Ids
		private static var count:Number = 0;
		
		// This flag is set by the editor so every object is created as a character and can be moved ( so ugly I know but It does work )
		/** @private */
		public static var allCharacters:Boolean = false;
		
		// Private properties
		
		// 1. References
		
		private var _controller:ISceneController = null;
		/** @private */
		public var prof:Profiler = null;										// Profiler
		private var initializer:SceneInitializer;						// This scene's initializer
		/** @private */
		public var renderEngine:IRenderEngine;					// The render engine
		/** @private */
		public var renderManager:SceneRenderManager;				// The render manager
		/** @private */
		public var engine:Engine;
		/** @private */
		public var _orig_container:Sprite;  		  						// Backup reference
		
		// 2. Geometry and sizes
		
		/** @private */
		public var viewWidth:Number;													// Viewport size
		/** @private */
		public var viewHeight:Number;												// Viewport size
		/** @private */
		public var top:Number;																// Highest Z in the scene
		/** @private */
		public var gridWidth:int;														// Grid size in cells
		/** @private */
		public var gridDepth:int;
		/** @private */
		public var gridHeight:int;
		/** @private */
		public var gridSize:int;		           								// Grid size ( in pixels )
		/** @private */
		public var levelSize:int;	          								// Vertical grid size ( along Z axis, in pixels )
		/** @private */
		public var sortCubeSize:int	= Engine.SORTCUBESIZE;	// Sorting cube size
		
		// 3. zSort
		
		/** @private */
		public var grid:Array;                 						  // The grid
		/** @private */
		public var allUsedCells:Array;                 			
		/** @private */
		public var sortAreas:Array;													// zSorting generates this. This array points to contiguous spaces sharing the same zIndex
		// It is used to find the proper zIndex for a cell
		/** @private */
		public var sortAreasRTree:RTree;										// This tree is used to search sortAreas efficiently
		
		/** @private */
		public var allStatic2D:Array;												// This provides fast 2D searches in the static elements
		/** @private */
		public var allStatic2DRTree:RTree;
		
		/** @private */
		public var allStatic3D:Array;												// This provides fast 3D searches in the static elements
		/** @private */
		public var allStatic3DRTree:RTree;
		
		
		
		
		// 4. Resources
		
		/** @private */
		public var resourceManager:SceneResourceManager;		// The resource manager stores all definitions loaded for this scene
		
		// 5.Status			
		
		/** @private */
		public var IAmBeingRendered:Boolean = false;					// If this scene is actually being rendered
		private var _enabled:Boolean;												// Is the scene enabled ?
		
		
		// Public properties
		
		/** 
		 * Every Scene is automatically assigned and ID
		 */
		public var id:String;															
		
		/**
		 * The camera currently in use, if any
		 */
		public var currentCamera:Camera;
		
		/** 
		 * Were this scene is drawn
		 */
		public var container:Sprite;          						
		
		/**
		 * An string indicating the scene's current status
		 */
		public var stat:String;    				 							
		
		/**
		 * Indicates if the scene is loaded and ready
		 */
		public var ready:Boolean;
		
		/**
		 * Scene width in pixels.
		 */														
		public var width:Number;
		
		/**
		 * Scene depth in pixels
		 */				
		public var depth:Number;
		
		/**
		 * Scene height in pixels
		 */				
		public var height:Number;
		
		/**
		 * An array of all floors for fast loop access. For "id" access use the .all array
		 */
		public var floors:Array;          						
		
		/**
		 * An array of all walls for fast loop access. For "id" access use the .all array
		 */
		public var walls:Array;                						
		
		/**
		 * An array of all objects for fast loop access. For "id" access use the .all array
		 */
		public var objects:Array;              						
		
		/**
		 * An array of all characters for fast loop access. For "id" access use the .all array
		 */
		public var characters:Array;                					
		
		/**
		 * An array of all empty sprites for fast loop access. For "id" access use the .all array
		 */
		public var emptySprites:Array;                					
		
		/**
		 * An array of all lights for fast loop access. For "id" access use the .all array
		 */
		public var lights:Array;                						
		
		/**
		 * An array of all elements for fast loop access. For "id" access use the .all array. Bullets are not here
		 */
		public var everything:Array;               						
		
		/**
		 * The global light for this scene. Use this property to change light properties such as intensity and color
		 */
		public var environmentLight:GlobalLight ; 					
		
		/**
		 * An array of all elements in this scene, use it with ID Strings. Bullets are not here
		 */
		public var all:Array;                    						
		
		/**
		 * The AI-related method are grouped inside this object, for easier access
		 */
		public var AI:AiContainer;
		
		/**
		 * All the bullets currently active in the scene are here
		 */
		public var bullets:Array;
		
		// Bullets go here instead of being deleted, so they can be reused
		private var bulletPool:Array
		
		// Al events
		/** @private */
		public var events:Array;
		
		
		// Events
		
		/**
		 * An string describing the process of loading and processing and scene XML definition file.
		 * Events dispatched by the scene while loading containg this String as a description of what is happening
		 */
		public static const LOADINGDESCRIPTION:String = "Creating scene";
		
		/**
		 * The Scene.LOADPROGRESS constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>scenecloadprogress</code> event.
		 * The event is dispatched when the status of the scene changes during scene loading and processing.
		 * A listener to this event can then check the scene's status property to update a progress dialog
		 *
		 */
		public static const LOADPROGRESS:String = "scenecloadprogress";
		
		/**
		 * The Scene.LOADCOMPLETE constant defines the value of the 
		 * <code>type</code> property of the event object for a <code>sceneloadcomplete</code> event.
		 * The event is dispatched when the scene finishes loading and processing and is ready to be used
		 *
		 */
		public static const LOADCOMPLETE:String = "sceneloadcomplete";
		
		/**
		 * Constructor. Don't call directly, use fEngine.createScene() instead
		 * @private
		 */
		function Scene(engine:Engine, container:Sprite, retriever:ISceneRetriever, width:Number, height:Number,
					   renderer:IRenderEngine = null, p:Profiler = null):void {
			
			// Properties
			this.id = "Scene_" + (Scene.count++);
			this.engine = engine;
			this._orig_container = container;           
			this.container = container;              
			this.environmentLight = null;     
			this.gridSize = 64;
			this.levelSize = 64;
			this.top = 0;
			this.stat = "Loading XML";  
			this.ready = false;
			this.viewWidth = width;
			this.viewHeight = height;
			
			// Internal arrays
			this.floors = new Array;          
			this.walls = new Array;           
			this.objects = new Array;         
			this.characters = new Array;         
			this.emptySprites = new Array;         
			this.events = new Array;        
			this.lights = new Array;         
			this.everything = new Array;          
			this.all = new Array; 
			this.bullets = new Array;       
			this.bulletPool = new Array;      
			
			// AI
			this.AI = new AiContainer(this);
			
			// Render engine
			this.renderEngine = renderer || (new Flash9RenderEngine(this,container));
			this.renderEngine.setViewportSize(width, height);
			
			// The render manager decides which elements are inside the viewport and which elements are not
			this.renderManager = new SceneRenderManager(this);
			this.renderManager.setViewportSize(width, height);
			
			// Start xml retrieve process
			this.initializer = new SceneInitializer(this, retriever);
			
			// Profiler ?
			this.prof = p;
		}
		
		/** 
		 * Starts initialization process
		 * @private
		 */
		public function initialize():void {
			this.initializer.start();
		}
		
		// Public methods
		
		/**
		 * This method changes the viewport's size. It is useful, for example, to adapt your scene to liquid layouts
		 *
		 * @param width New width for the viewport
		 * @param height New height for the viewport
		 */
		public function setViewportSize(width:int, height:int):void {
			
			this.renderManager.setViewportSize(width, height);
			this.renderEngine.setViewportSize(width, height);
			if(this.IAmBeingRendered && this.currentCamera) {
				this.renderManager.processNewCellCamera(this.currentCamera);
				this.renderEngine.setCameraPosition(this.currentCamera);
			}
		}
		
		/**
		 * This Method is called to enable/disable the scene. It will enable all controllers associated to the scene and its
		 * elements. The engine no longer calls this method when the scene is shown. Do it manually when needed.
		 *
		 * A typical use of manual enabling/disabling of scenes is pausing the game or showing a dialog box of any type.
		 *
		 * @see org.ffilmation.engine.core.fEngine#showScene
		 */
		public function set enabled(value:Boolean):void {
			
			// Enable scene controller
			this._enabled = value;
			if(this.controller) 
				this.controller.enabled = value;
			
			// Enable controllers for all elements in the scene
			var n:int = everything.length;
			for(var i:int = 0; i < n; i++) 
				if(this.everything[i].controller != null) 
					this.everything[i].controller.enabled = value;
			n = bullets.length;
			for(i=0; i< n; i++) 
				this.bullets[i].enabled = value;
			
		}
		
		/**
		 * Assigns a controller to this scene
		 * @param controller: any controller class that implements the ISceneController interface
		 */
		public function set controller(controller:ISceneController):void {
			if(this._controller!=null) 
				this._controller.enabled = false;
			this._controller = controller;
			this._controller.assignScene(this);
		}
		
		/**
		 * Retrieves controller from this scene
		 * @return controller: the class that is currently controlling the Scene
		 */
		public function get controller():ISceneController {
			return this._controller;
		}
		
		/** 
		 * This method sets the active camera for this scene. The camera position determines the viewable area of the scene
		 *
		 * @param camera The camera you want to be active
		 *
		 */
		public function setCamera(camera:Camera):void {
			
			// Stop following old camera
			if(this.currentCamera) {
				this.currentCamera.removeEventListener(MovingElement.MOVE, this.cameraMoveListener);
				this.currentCamera.removeEventListener(MovingElement.NEWCELL, this.cameraNewCellListener);
			}
			
			// Follow new camera
			this.currentCamera = camera;
			this.currentCamera.addEventListener(MovingElement.MOVE, this.cameraMoveListener, false, 0, true);
			this.currentCamera.addEventListener(MovingElement.NEWCELL, this.cameraNewCellListener, false, 0, true);
			if(this.IAmBeingRendered) 
				this.renderManager.processNewCellCamera(camera);
			this.followCamera(this.currentCamera);
		}
		
		/**
		 * Creates a new camera associated to the scene
		 *
		 * @return an fCamera object ready to move or make active using the setCamera() method
		 *
		 */
		public function createCamera():Camera {
			
			//Return
			return new Camera(this);
		}
		
		/**
		 * Creates a new light and adds it to the scene. You won't see the light until you call its
		 * render() or moveTo() methods
		 *
		 * @param idlight: The unique id that will identify the light
		 *
		 * @param x: Initial x coordinate for the light
		 *
		 * @param y: Initial x coordinate for the light
		 *
		 * @param z: Initial x coordinate for the light
		 *
		 * @param size: Radius of the sphere that identifies the light
		 *
		 * @param color: An string specifying the color of the light in HTML format, example: #ffeedd
		 *
		 * @param intensity: Intensity of the light goes from 0 to 100
		 *
		 * @param decay: From 0 to 100 marks the distance along the lights's radius from where intensity starrts to fade fades. A 0 decay defines a solid light
		 *
		 * @param bumpMapped: Determines if this light will be rendered with bumpmapping. Please note that for the bumpMapping to work in a given surface,
		 * the surface will need a bumpMap definition and bumpMapping must be enabled in the engine's global parameters
		 *
		 */
		public function createOmniLight(idlight:String, x:Number, y:Number, z:Number, size:Number, color:String, intensity:Number, decay:Number, bumpMapped:Boolean = false):OmniLight {
			
			// Create
			var definitionObject:XML = <light id={idlight} type="omni" size={size} x={x} y={y} z={z} color={color} intensity={intensity} decay={decay} bump={bumpMapped}/>;
			var nfLight:OmniLight = new OmniLight(definitionObject, this);
			
			// Events
			nfLight.addEventListener(MovingElement.NEWCELL, this.processNewCell, false, 0, true);		   
			nfLight.addEventListener(MovingElement.MOVE, this.renderElement, false, 0, true);			   
			nfLight.addEventListener(Light.RENDER, this.processNewCell, false, 0, true);			   
			nfLight.addEventListener(Light.RENDER, this.renderElement, false, 0, true);			   
			nfLight.addEventListener(Light.SIZECHANGE, this.processNewLightDimensions, false, 0, true);			   
			
			// Add to lists
			this.lights.push(nfLight);
			this.everything.push(nfLight);
			this.all[nfLight.id] = nfLight;
			
			//Return
			if(this.IAmBeingRendered) 
				nfLight.render();
			return nfLight;
		}
		
		/**
		 * Removes an omni light from the scene. This is not the same as hiding the light, this removes the element completely from the scene
		 *
		 * @param light The light to be removed
		 */
		public function removeOmniLight(light:OmniLight):void {
			
			// Remove from array
			if(this.lights && this.lights.indexOf(light)>=0) {
				this.lights.splice(this.lights.indexOf(light), 1);
				this.everything.splice(this.everything.indexOf(light), 1);
			}
			
			// Hide light from elements
			var cell:Cell = light.cell;
			var nEl:Number = light.nElements;
			for(var i2:Number = 0; i2 < nEl; i2++) 
				this.renderEngine.lightOut(light.elementsV[i2].obj, light);
			light.scene = null;
			
			nEl = this.characters.length;
			for(i2=0; i2 < nEl; i2++)
				this.renderEngine.lightOut(this.characters[i2], light);
			this.all[light.id] = null;
			
			// Events
			light.removeEventListener(MovingElement.NEWCELL, this.processNewCell);			   
			light.removeEventListener(MovingElement.MOVE, this.renderElement);			   
			light.removeEventListener(Light.RENDER, this.processNewCell);			   
			light.removeEventListener(Light.RENDER, this.renderElement);			   
			light.removeEventListener(Light.SIZECHANGE, this.processNewLightDimensions);			   
			
			// This light may be in some character cache
			light.removed = true;
			
		}
		
		/** 
		 *	Creates a new character an adds it to the scene
		 *
		 * @param idchar: The unique id that will identify the character
		 *
		 * @param def: Definition id. Must match a definition in some of the definition XMLs included in the scene
		 *
		 * @param x: Initial x coordinate for the character
		 *
		 * @param y: Initial x coordinate for the character
		 *
		 * @param z: Initial x coordinate for the character
		 *
		 * @returns The newly created character, or null if the coordinates not allowed (outside bounds)
		 *
		 **/
		public function createCharacter(idchar:String, def:String, x:Number, y:Number, z:Number):Character {
			
			// Ensure coordinates are inside the scene
			var c:Cell = this.translateToCell(x, y, z);
			if(c==null) {
				return null;
			}
			
			// Create
			var definitionObject:XML = <character id={idchar} definition={def} x={x} y={y} z={z} />;
			var nCharacter:Character = new Character(definitionObject, this);
			nCharacter.cell = c;
			nCharacter.setDepth(c.zIndex);
			
			// Events
			nCharacter.addEventListener(MovingElement.NEWCELL, this.processNewCell, false, 0, true);			   
			nCharacter.addEventListener(MovingElement.MOVE, this.renderElement, false, 0, true);			   
			
			// Add to lists
			this.characters.push(nCharacter);
			this.everything.push(nCharacter);
			this.all[nCharacter.id] = nCharacter;
			if(this.IAmBeingRendered) {
				this.addElementToRenderEngine(nCharacter);
				this.renderManager.processNewCellCharacter(nCharacter);
				this.render();
			}
			
			//Return
			return nCharacter;
		}
		
		/**
		 * Removes a character from the scene. This is not the same as hiding the character, this removes the element completely from the scene
		 *
		 * @param char The character to be removed
		 */
		public function removeCharacter(char:Character):void {
			
			// Remove from array
			if(this.characters && this.characters.indexOf(char) >= 0) {
				this.characters.splice(this.characters.indexOf(char), 1);
				this.everything.splice(this.everything.indexOf(char), 1);
				this.all[char.id] = null;
			}
			
			// Hide
			char.hide();
			
			// Events
			char.removeEventListener(MovingElement.NEWCELL, this.processNewCell);	   
			char.removeEventListener(MovingElement.MOVE, this.renderElement);   
			
			// Remove from render engine
			this.removeElementFromRenderEngine(char);
			char.dispose();
			
		}
		
		/** 
		 *	Creates a new empty sprite an adds it to the scene
		 *
		 * @param idchar: The unique id that will identify the character
		 *
		 * @param x: Initial x coordinate for the character
		 *
		 * @param y: Initial x coordinate for the character
		 *
		 * @param z: Initial x coordinate for the character
		 *
		 * @returns The newly created empty Sprite
		 *
		 **/
		public function createEmptySprite(idspr:String,x:Number,y:Number,z:Number):EmptySprite {
			
			// Create
			var definitionObject:XML = <emptySprite id={idspr} x={x} y={y} z={z} />;
			var nEmptySprite:EmptySprite = new EmptySprite(definitionObject, this);
			nEmptySprite.cell = this.translateToCell(x, y, z);
			nEmptySprite.updateDepth();
			
			// Events
			nEmptySprite.addEventListener(MovingElement.NEWCELL, this.processNewCell, false, 0, true);	   
			nEmptySprite.addEventListener(MovingElement.MOVE, this.renderElement, false, 0, true);	   
			
			// Add to lists
			this.emptySprites.push(nEmptySprite);
			this.everything.push(nEmptySprite);
			this.all[nEmptySprite.id] = nEmptySprite;
			if(this.IAmBeingRendered) {
				this.addElementToRenderEngine(nEmptySprite);
				this.renderManager.processNewCellEmptySprite(nEmptySprite);
			}
			
			//Return
			return nEmptySprite;
		}
		
		/**
		 * Removes an empty sprite from the scene. This is not the same as hiding it, this removes the element completely from the scene
		 *
		 * @param spr The emptySprite to be removed
		 */
		public function removeEmptySprite(sprite:EmptySprite):void {
			
			// Remove from arraya
			if(this.emptySprites && this.emptySprites.indexOf(sprite) >= 0) {
				this.emptySprites.splice(this.emptySprites.indexOf(sprite), 1);
				this.everything.splice(this.everything.indexOf(sprite), 1);
				this.all[sprite.id] = null;
			}
			
			// Hide
			sprite.hide();
			
			// Events
			sprite.removeEventListener(MovingElement.NEWCELL, this.processNewCell);		   
			sprite.removeEventListener(MovingElement.MOVE, this.renderElement);		   
			
			// Remove from render engine
			this.removeElementFromRenderEngine(sprite);
			sprite.dispose();
			
		}
		
		/**
		 * Creates a new bullet and adds it to the scene. Note that bullets use their own render system. The bulletRenderer interface allows
		 * you to have complex things such as trails. If it was integrated with the standard renderer, your bullets would have to be standard
		 * Sprites, and I dind't like that.
		 *
		 * <p><b>Note to developers:</b> bullets are reused. Creating new objects is slow, and depending on your game you could have a lot
		 * being created and destroyed. The engine uses an object pool to reuse "dead" bullets and minimize the amount of new() calls. This
		 * is transparent to you but I think this information can help tracking weird bugs</p>
		 *
		 * @param x Start position of the bullet
		 * @param y Start position of the bullet
		 * @param z Start position of the bullet
		 * @param speedx Speed of bullet
		 * @param speedy Speed of bullet
		 * @param speedz Speed of bullet
		 * @param renderer The renderer that will be drawing this bullet. In order to increase performace, you should't create a new
		 * renderer instance for each bullet: pass the same renderer to all bullets that look the same.
		 *
		 */
		public function createBullet(x:Number, y:Number, z:Number, speedx:Number, speedy:Number, speedz:Number, renderer:IBulletRenderer):Bullet {
			
			// Is there an available bullet or a new one is needed ?
			var bullet:Bullet;
			if(this.bulletPool.length > 0) {
				bullet = this.bulletPool.pop();
				bullet.moveTo(x, y, z);
				bullet.show();
			}
			else {
				bullet = new Bullet(this);
				bullet.moveTo(x, y, z);
				if(this.IAmBeingRendered)
					this.addElementToRenderEngine(bullet);
			}
			
			// Events
			bullet.addEventListener(MovingElement.NEWCELL, this.processNewCell, false, 0, true);			   
			bullet.addEventListener(MovingElement.MOVE, this.renderElement, false, 0, true);   
			bullet.addEventListener(Bullet.SHOT, BulletSceneLogic.processShot, false, 0, true);	   
			
			// Properties
			bullet.moveTo(x, y, z);
			bullet.speedx = speedx;
			bullet.speedy = speedy;
			bullet.speedz = speedz;
			
			// Init renderer
			bullet.customData.bulletRenderer = renderer;
			if(bullet.container) 
				bullet.customData.bulletRenderer.init(bullet);
			
			// Add to lists
			this.bullets.push(bullet);
			
			// Enable
			bullet.enabled = _enabled;
			
			// Return
			return bullet;
		}
		
		/**
		 * Removes a bullet from the scene. Bullets are automatically removed when they hit something, 
		 * but you If you can't wait for them to be delete, you can do it manually.
		 * @param bullet The Bullet to be removed. 
		 */
		public function removeBullet(bullet:Bullet):void {
			
			// Events
			bullet.removeEventListener(MovingElement.NEWCELL, this.processNewCell);			   
			bullet.removeEventListener(MovingElement.MOVE, this.renderElement);	   
			bullet.removeEventListener(Bullet.SHOT, BulletSceneLogic.processShot);
			
			// Hide
			bullet.enabled = false;
			bullet.customData.bulletRenderer.clear(bullet);
			bullet.hide();
			
			// Back to pool
			this.bullets.splice(this.bullets.indexOf(bullet), 1);
			this.bulletPool.push(bullet);
			
		}
		
		/**
		 * This method translates scene 3D coordinates to 2D coordinates relative to the Sprite containing the scene
		 * 
		 * @param x x-axis coordinate
		 * @param y y-axis coordinate
		 * @param z z-axis coordinate
		 *
		 * @return A Point in this scene's container Sprite
		 */
		public function translate3DCoordsTo2DCoords(x:Number, y:Number, z:Number):Point {
			return Scene.translateCoords(x, y, z);
		}
		
		/**
		 * This method translates scene 3D coordinates to 2D coordinates relative to the Stage
		 * 
		 * @param x x-axis coordinate
		 * @param y y-axis coordinate
		 * @param z z-axis coordinate
		 *
		 * @return A Coordinate in the Stage
		 */
		public function translate3DCoordsToStageCoords(x:Number, y:Number, z:Number):Point {
			
			//Get offset of camera
			var rect:Rectangle = this.container.scrollRect;
			
			// Get point
			var r:Point = Scene.translateCoords(x, y, z);
			
			// Translate
			r.x -= rect.x;
			r.y -= rect.y;
			
			return r;
		}
		
		/**
		 * This method translates Stage coordinates to scene coordinates. Useful to map mouse events into game events
		 *
		 * @example You can call it like
		 *
		 * <listing version="3.0">
		 *  function mouseClick(evt:MouseEvent) {
		 *    var coords:Point = this.scene.translateStageCoordsTo3DCoords(evt.stageX, evt.stageY)
		 *    this.hero.character.teleportTo(coords.x,coords.y, this.hero.character.z)
		 *   }
		 * </listing>
		 *
		 * @param x x-axis coordinate
		 * @param y y-axis coordinate
		 * 
		 * @return A Point in the scene's coordinate system. Please note that a Z value is not returned as It can't be calculated from a 2D input.
		 * The returned x and y correspond to z=0 in the game's coordinate system.
		 */
		public function translateStageCoordsTo3DCoords(x:Number, y:Number):Point {
			
			//get offset of camera
			var rect:Rectangle = this.container.scrollRect;
			var xx:Number = x + rect.x;
			var yy:Number = y + rect.y;
			
			return Scene.translateCoordsInverse(xx, yy);
		}
		
		
		/**
		 * This method returns the element under a Stage coordinate, and a 3D translation of the 2D coordinates passed as input.
		 * To achieve this it finds which visible elements are under the input pixel, ignoring the engine's internal coordinates.
		 * Now you can find out what did you click and which point of that element did you click.
		 *
		 * @param x Stage horizontal coordinate
		 * @param y Stage vertical coordinate
		 * 
		 * @return An array of objects storing both the element under that point and a 3d coordinate corresponding to the 2d Point. This method returns null
		 * if the coordinate is not occupied by any element.
		 * Why an Array an not a single element ? Because you may want to search the Array for the element that better suits your intentions: for
		 * example if you use it to walk around the scene, you will want to ignore trees to reach the floor behind. If you are shooting
		 * people, you will want to ignore floors and look for objects and characters to target at.
		 *
		 * @see org.ffilmation.engine.datatypes.fCoordinateOccupant
		 */
		public function translateStageCoordsToElements(x:Number, y:Number):Array {
			
			// This must be passed to the renderer because we have no idea how things are drawn
			if(this.IAmBeingRendered) 
				return this.renderEngine.translateStageCoordsToElements(x, y);
			else
				return null;
		}
		
		/**
		 * Use this method to completely rerender the scene. However, under normal circunstances there shouldn't be a need to call this manually
		 */
		public function render():void {
			
			// Render global light
			this.environmentLight.render();
			
			// Render dynamic lights
			var ll:int = this.lights.length;
			for(var i:int = 0; i < ll; i++) 
				this.lights[i].render();
			
		}
		
		/**
		 * Normally you don't need to call this method manually. When an scene is shown, this method is called to initialize the render engine
		 * for this scene ( this involves creating all the Sprites ). This may take a couple of seconds.<br>
		 * Under special circunstances, however, you may want to call this method manually at some point before showing the scene. This is useful is you want
		 * the graphic assets to exist before the scene is shown ( to attach Mouse Events for example ).
		 */
		public function startRendering():void {
			
			if(this.IAmBeingRendered)
				return;
			
			// Init render engine
			this.renderEngine.initialize();
			
			// Init render manager
			this.renderManager.initialize();
			
			// Init render for all elements
			var len:int = this.floors.length;
			for(var j:int = 0; j < len; j++)
				this.addElementToRenderEngine(this.floors[j]);
			len = this.walls.length;
			for(j = 0; j < len; j++) 
				this.addElementToRenderEngine(this.walls[j]);
			len = this.objects.length;
			for(j = 0; j < len; j++)
				this.addElementToRenderEngine(this.objects[j]);
			len = this.characters.length;
			for(j = 0; j < len; j++) 
				this.addElementToRenderEngine(this.characters[j]);
			len = this.emptySprites.length;
			for(j = 0; j < len; j++) 
				this.addElementToRenderEngine(this.emptySprites[j]);
			len = this.bullets.length;
			for(j = 0; j < len; j++) {
				this.addElementToRenderEngine(this.bullets[j]);
				this.bullets[j].customData.bulletRenderer.init();
			}
			
			// Set flag
			this.IAmBeingRendered = true;
			
			// Render scene
			this.render();
			
			// Update camera if any
			if(this.currentCamera)
				this.renderManager.processNewCellCamera(this.currentCamera);
		}
		
		// PRIVATE AND INTERNAL METHODS FOLLOW
		
		// INTERNAL METHODS RELATED TO RENDER
		
		/**
		 * This method adds an element to the renderEngine pool
		 */
		private function addElementToRenderEngine(element:RenderableElement) {
			
			// Init
			element.container = this.renderEngine.initRenderFor(element);
			
			// This happens only if the render Engine returns a container for every element. 
			if(element.container) {
				element.container.elementId = element.id;
				element.container.element = element;
			}
			
			// This can be null, depending on the render engine
			element.flashClip = this.renderEngine.getAssetFor(element);
			
			// Listen to show and hide events
			element.addEventListener(RenderableElement.SHOW, this.renderManager.showListener, false, 0, true);
			element.addEventListener(RenderableElement.HIDE, this.renderManager.hideListener, false, 0, true);
			element.addEventListener(RenderableElement.ENABLE, this.enableListener, false, 0, true);
			element.addEventListener(RenderableElement.DISABLE, this.disableListener, false, 0, true);
			
			// Add to render manager
			this.renderManager.addedItem(element);
			
			// Elements default to Mouse-disabled
			element.disableMouseEvents();
			
		}
		
		/**
		 * This method removes an element from the renderEngine pool
		 */
		private function removeElementFromRenderEngine(element:RenderableElement, destroyingScene:Boolean = false) {
			
			this.renderManager.removedItem(element, destroyingScene);
			this.renderEngine.stopRenderFor(element);
			if(element.container) {
				element.container.elementId = null;
				element.container.element = null;
			}
			element.container = null;
			element.flashClip = null;
			
			// Stop listening to show and hide events
			element.removeEventListener(RenderableElement.SHOW, this.renderManager.showListener);
			element.removeEventListener(RenderableElement.HIDE, this.renderManager.hideListener);
			element.removeEventListener(RenderableElement.ENABLE, this.enableListener);
			element.removeEventListener(RenderableElement.DISABLE, this.disableListener);
			
		}
		
		// Listens to elements made enabled
		private function enableListener(evt:Event):void {
			this.renderEngine.enableElement(evt.target as RenderableElement);
		}
		
		// Listens to elements made disabled
		private function disableListener(evt:Event):void {
			this.renderEngine.disableElement(evt.target as RenderableElement);
		}
		
		/**
		 * @private
		 * This method is called when the scene is no longer displayed.
		 */
		public function stopRendering():void {
			
			// Stop render for all elements
			var len:int = len
			for(var j:int = 0; j < len; j++) 
				this.removeElementFromRenderEngine(this.floors[j], true);
			len = this.walls.length;
			for(j = 0; j < len; j++) 
				this.removeElementFromRenderEngine(this.walls[j], true);
			len = this.objects.length;
			for(j = 0; j < len; j++) 
				this.removeElementFromRenderEngine(this.objects[j], true);
			len = this.characters.length;
			for(j = 0; j < len; j++) 
				this.removeElementFromRenderEngine(this.characters[j], true);
			len = this.emptySprites.length;
			for(j = 0; j < len; j++) 
				this.removeElementFromRenderEngine(this.emptySprites[j], true);
			len = this.bullets.length;
			for(j = 0; j < len; j++) {
				this.bullets[j].customData.bulletRenderer.clear();
				this.removeElementFromRenderEngine(this.bullets[j], true);
			}
			
			// Free bullet pool as the assets are no longer valid
			len = this.bulletPool.length
			for(j=0; j < len; j++) {
				this.bulletPool[j].dispose();
				delete this.bulletPool[j];
			}
			this.bulletPool = [];
			
			// Stop render engine
			this.renderEngine.dispose();
			
			// Stop render manager
			this.renderManager.dispose();
			
			// Set flag
			this.IAmBeingRendered = false;
			
		}
		
		
		// A light changes its size
		/** @private */
		public function processNewLightDimensions(evt:Event):void {
			
			if(this.IAmBeingRendered) {
				
				var light:OmniLight = evt.target as OmniLight;
				
				// Hide light from elements
				var cell:Cell = light.cell;
				var nEl:Number = light.nElements;
				for(var i2:Number = 0; i2 < nEl; i2++) 
					this.renderEngine.lightReset(light.elementsV[i2].obj, light);
				
				nEl = this.characters.length;
				for(i2 = 0; i2 < nEl; i2++) 
					this.renderEngine.lightReset(this.characters[i2], light);
				
				LightSceneLogic.processNewLightDimensions(this, evt.target as OmniLight);
			}
		}
		
		// Element enters new cell
		/** @private */
		public function processNewCell(evt:Event):void {
			
			if(this.IAmBeingRendered) {
				if(evt.target is OmniLight)
					LightSceneLogic.processNewCellOmniLight(this, evt.target as OmniLight);
				if(evt.target is Character) {
					var c:Character = evt.target as Character;
					this.renderManager.processNewCellCharacter(c);
					CharacterSceneLogic.processNewCellCharacter(this, c);
				}
				if(evt.target is EmptySprite) {
					var e:EmptySprite = evt.target as EmptySprite;
					this.renderManager.processNewCellEmptySprite(e);
					EmptySpriteSceneLogic.processNewCellEmptySprite(this, e);
				}
				if(evt.target is Bullet) {
					var b:Bullet = evt.target as Bullet;
					this.renderManager.processNewCellBullet(b);
				}
			}
			
		}
		
		// LIstens to render events
		/** @private */
		public function renderElement(evt:Event):void {
			
			// If the scene is not being displayed, we don't update the render engine
			// However, the element's properties are modified. When the scene is shown the result is consistent
			// to what has changed while the render was not being updated
			if(this.IAmBeingRendered) {
				if(evt.target is OmniLight) 
					LightSceneLogic.renderOmniLight(this,evt.target as OmniLight);
				if(evt.target is Character) 
					CharacterSceneLogic.renderCharacter(this,evt.target as Character);
				if(evt.target is EmptySprite) 
					EmptySpriteSceneLogic.renderEmptySprite(this,evt.target as EmptySprite);
				if(evt.target is Bullet) 
					BulletSceneLogic.renderBullet(this,evt.target as Bullet);
			}
		}
		
		// This method is called when the shadowQuality option changes
		/** @private */
		public function resetShadows():void {
			this.renderEngine.resetShadows();
			var cl:int = this.characters.length;
			for(i=0; i < cl; i++) 
				CharacterSceneLogic.processNewCellCharacter(this, this.characters[i], true);
			cl = this.lights.length;
			for(var i:int = 0; i < cl; i++) 
				LightSceneLogic.processNewCellOmniLight(this, this.lights[i], true);
		}
		
		// INTERNAL METHODS RELATED TO CAMERA MANAGEMENT
		
		
		// Listens cameras moving
		private function cameraMoveListener(evt:MoveEvent):void {
			this.followCamera(evt.target as Camera);
		}
		
		// Listens cameras changing cells.
		private function cameraNewCellListener(evt:Event):void {
			var camera:Camera = evt.target as Camera;
			this.renderEngine.setCameraPosition(camera);
			if(this.IAmBeingRendered) 
				this.renderManager.processNewCellCamera(camera);
		}
		
		// Adjusts visualization to camera position
		private function followCamera(camera:Camera):void {
			if(this.prof) {
				this.prof.begin( "Update camera");				
				this.renderEngine.setCameraPosition(camera);
				this.prof.end( "Update camera");				
			} else {
				this.renderEngine.setCameraPosition(camera);
			}
		}
		
		// INTERNAL METHODS RELATED TO DEPTHSORT
		
		// Returns a normalized zSort value for a cell in the grid. Bigger values display in front of lower values
		/** @private */
		public function computeZIndex(i:Number, j:Number, k:Number):Number {
			var ow:int = this.gridWidth;
			var od:int = this.gridDepth;
			var oh:int = this.gridHeight;
			return ((((((ow - i + 1)+(j * ow + 2))) * oh) + k)) / (ow * od * oh);
		}
		
		
		// INTERNAL METHODS RELATED TO GRID MANAGEMENT	
		
		
		// Reset cell. This is called if the engine's quality options change to a better quality
		// as all cell info will have to be recalculated
		/** @private */
		public function resetGrid():void {
			
			var l:int = this.allUsedCells.length;
			for(var i:int = 0; i < l; i++) {
				this.allUsedCells[i].characterShadowCache = [];
				delete this.allUsedCells[i].visibleObjs;
			}
			
		}
		
		
		// Returns the cell containing the given coordinates
		/** @private */
		public function translateToCell(x:Number, y:Number, z:Number):Cell {
			if(x < 0 || y < 0 || z < 0) 
				return null;
			return this.getCellAt(x / this.gridSize, y / this.gridSize, z / this.levelSize);
		}
		
		// Returns the cell at specific grid coordinates. If cell does not exist, it is created.
		/** @private */
		public function getCellAt(i:int, j:int, k:int):Cell {
			
			if(i < 0 || j < 0 || k < 0) 
				return null;
			if(i >= this.gridWidth || j >= this.gridDepth || k >= this.gridHeight) 
				return null;
			
			// Create new if necessary
			if(!this.grid[i] || !this.grid[i][j]) 
				return null;
			var arr:Array = this.grid[i][j];
			if(!arr[k]) {
				
				var cell:Cell = new Cell();
				
				// Z-Index
				
				// Original call
				//cell.zIndex = this.computeZIndex(i,j,k)
				
				// Inline for a bit of speedup
				var ow:int = this.gridWidth;
				var od:int = this.gridDepth;
				var oh:int = this.gridHeight;
				cell.zIndex =  ((((((ow - i + 1) + (j * ow + 2))) * oh) + k)) / (ow * od * oh);
				
				var s:Array = this.sortAreas[i];
				
				//var s:Array = this.sortAreasRTree.intersects(new fCube(i,j,k,i+1,j+1,k+1))
				
				var l:int = s.length;
				
				var found:Boolean = false;
				for(var n:int = 0; !found && n < l; n++) {
					
					/* Original call
					if(s[n].isPointInside(i,j,k)) {
					found = true
					cell.zIndex+=(s[n] as SortArea).zValue
					}*/
					
					/* Inline for a bit of speedup */
					var sA:SortArea = s[n];
					//var sA:SortArea = this.sortAreas[s[n]]
					if((i >= sA.i && i <= sA.i + sA.width) && (j >= sA.j && j <= sA.j + sA.depth) 
						&& (k >= sA.k && k <= sA.k + sA.height) ) {
						found = true
						cell.zIndex += sA.zValue;
					}
				}
				
				// Internal
				cell.i = i;
				cell.j = j;
				cell.k = k;
				cell.x = (this.gridSize >> 1)+(this.gridSize * i);
				cell.y = (this.gridSize >> 1)+(this.gridSize * j);
				cell.z = (this.levelSize >> 1)+(this.levelSize * k);
				arr[k] = cell;
				
				this.allUsedCells[this.allUsedCells.length] = cell;
			}
			// Return cell
			return this.grid[i][j][k];
		}
		
		
		/** @private */
		public static function translateCoords(x:Number, y:Number, z:Number):Point {
			
			var xx:Number = x * Engine.DEFORMATION;
			var yy:Number = y * Engine.DEFORMATION;
			var zz:Number = z * Engine.DEFORMATION;
			var xCart:Number = (xx + yy) * 0.8944271909999159;			//Math.cos(0.4636476090008061)
			var yCart:Number = zz + (xx - yy) * 0.4472135954999579;  	//Math.sin(0.4636476090008061)
			
			return new Point(xCart, -yCart); 
			
		}
		
		/** @private */   
		public static function translateCoordsInverse(x:Number, y:Number):Point {   
			
			//rotate the coordinates
			var yCart:Number = (x / 0.8944271909999159 + y / 0.4472135954999579) >> 1;
			var xCart:Number = (-1 * y / 0.4472135954999579 + x / 0.8944271909999159) >> 1;        
			
			//scale the coordinates
			xCart = xCart / Engine.DEFORMATION;
			yCart = yCart / Engine.DEFORMATION;
			
			return new Point(xCart, yCart);
		}         
		
		
		// Get elements affected by lights from given cell, sorted by distance
		/** @private */
		public function getAffectedByLight(cell:Cell, range:Number = Infinity):void {
			var r:Array = VisibilitySolver.calcAffectedByLight(this, cell.x, cell.y, cell.z, range);
			cell.lightAffectedElements = r;
			cell.lightRange = range;
		}
		
		// Get elements visible from given cell, sorted by distance
		/** @private */
		public function getVisibles(cell:Cell, range:Number = Infinity):void {
			var r:Array = VisibilitySolver.calcVisibles(this, cell.x, cell.y, cell.z, range);
			cell.visibleElements = r;
			cell.visibleRange = range;
		}
		
		
		/**
		 * @private
		 * This method frees all resources allocated by this scene. Always dispose unused scene objects:
		 * scenes generate lots of internal Arrays and BitmapDatas that will eat your RAM fast if they are not properly deleted
		 */
		public function dispose():void {
			
			// Free properties
			this.engine = null;
			var len:int = this.sortAreas.length;
			for(var i:int = 0; i < len; i++) 
				delete this.sortAreas[i];
			this.sortAreas = null;
			this.sortAreasRTree = null;
			
			this.allStatic2D = null;
			this.allStatic2DRTree = null;
			
			this.allStatic3D = null;
			this.allStatic3DRTree = null;
			
			if(this.currentCamera) 
				this.currentCamera.dispose();
			this.currentCamera = null;
			this._controller = null;
			
			// Stop current initialization, if any
			if(this.initializer) 
				this.initializer.dispose();
			this.resourceManager = null;
			
			// Free render engine
			this.renderEngine.dispose();
			
			// Free render manager
			this.renderManager.dispose();
			this.renderManager = null;
			
			if(this._orig_container.parent) 
				this._orig_container.parent.removeChild(this._orig_container);
			this._orig_container = null;
			this.container = null;
			
			// Free elements
			var il:int = this.floors.length;
			for(i = 0; i < il; i++) {
				this.floors[i].dispose();
				delete this.floors[i];
			}
			il = this.walls.length;
			for(i = 0; i < il; i++) {
				this.walls[i].dispose();
				delete this.walls[i];
			}
			il = this.objects.length;
			for(i = 0; i < il; i++) {
				this.objects[i].dispose();
				delete this.objects[i];
			}
			il = this.characters.length;
			for(i = 0; i < il; i++) {
				this.characters[i].dispose();
				delete this.characters[i];
			}
			il = this.emptySprites.length;
			for(i = 0; i < il; i++) {
				this.emptySprites[i].dispose();
				delete this.emptySprites[i];
			}
			il = this.lights.length
			for(i = 0; i < il; i++) {
				this.lights[i].dispose();
				delete this.lights[i];
			}
			il = this.bullets.length;
			for(i = 0; i < il; i++) {
				this.bullets[i].dispose();
				delete this.bullets[i];
			}
			for(var n in this.all)
				delete this.all[n];
			
			this.floors = null;       
			this.walls = null;      
			this.objects = null;     
			this.characters = null;    
			this.emptySprites = null;
			this.events = null;  
			this.lights = null; 
			this.everything = null;       
			this.all = null;
			this.bullets = null;   
			this.bulletPool = null;  
			
			// Free grid
			this.freeGrid();
			
			// Free materials
			Material.disposeMaterials(this);
		}
		
		/**
		 * This method frees memory used by the grid in this scene
		 */
		private function freeGrid():void {
			
			var l:int = this.allUsedCells.length;
			for(var i:int = 0; i < l; i++) 
				this.allUsedCells[i].dispose();
			this.grid = null;
			this.allUsedCells = null;
			
		}
	}
}

