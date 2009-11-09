package com.ice.core.interfaces {

		// Imports

		/**
		* If you don't plan to write a custom renderer for the engine, you don't need to know any of these.<br>
		* This interface defines methods that any class that is to be used as a render engine need to implement.
		*/
		public interface fEngineRenderEngine {
		
				/**
				* Class constructor
				* @param scene The fScene rendered by this renderer
				* @param container The Sprite where this scene will be drawn
				*/
				function fEngineRenderEngine(scene:fScene,container:Sprite):void;
				
				/**
				* This method is called when the scene is to be displayed.
				*/
				function initialize():void;

				/**
				* This method initializes the render engine for an element in the scene.
				*
				* @param element The element we want to initialize
				* @return The container where the render for the element is displayed. This gets written as the "container" property of the element.
				*
				* @see org.ffilmation.engine.core.fRenderableElement#container
				*/
				function initRenderFor(element:fRenderableElement):fElementContainer;

				/**
				* This method removes an element from the render engine
				*
				* @param element The element we want to remove
				*
				* @see org.ffilmation.engine.core.fRenderableElement#container
				*/
				function stopRenderFor(element:fRenderableElement):void;


				/**
				* This method returns the asset from the library that was used to display the element.
				* It gets written as the "flashClip" property of the element.
				*
				* @param element The element for which we want the asset
				* @return The flashClip that represents the element. It is not the same as the container. The flashClip is nested somewhere inside the container
				*
				* @see org.ffilmation.engine.core.fRenderableElement#flashClip
				*/
				function getAssetFor(element:fRenderableElement):MovieClip;

				/**
				* This method updates the position of a character's sprite
				*
				* @param char The character that needs to be moved
				*/
				function updateCharacterPosition(char:fCharacter):void;

				/**
				* This method updates the position of an epmty Sprite's sprite
				*
				* @param spr The emptySprite that needs to be moved
				*/
				function updateEmptySpritePosition(spr:fEmptySprite):void;


				/**
				* This method updates the position of a bullet's sprite
				* @param bullet The bullet that needs to be moved
				*/
				function updateBulletPosition(bullet:fBullet):void;

			  /**
			  * This method renders an element visible
			  * @param element The element we want to show
			  **/
			  function showElement(element:fRenderableElement):void;

			  /**
			  * This method renders an element invisible
			  * @param element The element we want to hide
			  **/
			  function hideElement(element:fRenderableElement):void;

			  /**
			  * This method enables mouse events for an element
			  * @param element The element we want to show
			  **/
			  function enableElement(element:fRenderableElement):void;

			  /**
			  * This method disables mouse events for an element
			  * @param element The element we want to hide
			  **/
			  function disableElement(element:fRenderableElement):void;

				/**
				* When a moving light reaches an element, this method is executed
				*
				* @param element The element that has become affected by the light
				* @param light The light that we are rendering upon this element
				*/
				function lightIn(element:fRenderableElement,light:fOmniLight):void;

				/**
				* When a moving light moves out of an element, this method is executed
				*
				* @param element The element that is no longer affected by the light
				* @param light The light
				*/
				function lightOut(element:fRenderableElement,light:fOmniLight):void;


				/**
				* When a light is to be reset ( new size )
				*
				* @param element The element
				* @param light The light
				*/
				function lightReset(element:fRenderableElement,light:fOmniLight):void;


				/**
				* <p>Rendering occurs in two ways: a light changes or an element changes. When a light changes this happens:</p>
				* <ol>
				* <li>A renderStart call is issued for each affected element.</li>
				* <li>Each affected element receives a renderLight call, and if any is needed several renderShadow calls.</li>
				* <li>A renderFinish call is issued for each affected element.</li>
				* </ol>
				* <p>This is the renderStart call.</p>
				*
				* @param element The element in the scene we want to start rendering
				* @param light The light that we are rendering upon this element
				*/
				function renderStart(element:fRenderableElement,light:fOmniLight):void;
				
				/**
				* <p>Rendering occurs in two ways: a light changes or an element changes. When a light changes this happens:</p>
				* <ol>
				* <li>A renderStart call is issued for each affected element.</li>
				* <li>Each affected element receives a renderLight call, and if any is needed several renderShadow calls.</li>
				* <li>A renderFinish call is issued for each affected element.</li>
				* </ol>
				* <p>This is the renderLight call.</p>
				*
				* @param element The element we are rendering
				* @param light The light that we are rendering upon this element
				*/
				function renderLight(element:fRenderableElement,light:fOmniLight):void;

				/**
				* <p>Rendering occurs in two ways: a light changes or an element changes. When a light changes this happens:</p>
				* <ol>
				* <li>A renderStart call is issued for each affected element.</li>
				* <li>Each affected element receives a renderLight call, and if any is needed several renderShadow calls.</li>
				* <li>A renderFinish call is issued for each affected element.</li>
				* </ol>
				* <p>This is the renderShadow call.</p>
				*
				* @param element The element we are rendering
				* @param light The light that we are rendering upon this element
				* @param shadow The element whose shadow we are drawing
				*/
				function renderShadow(element:fRenderableElement,light:fOmniLight,shadow:fRenderableElement):void;

				/**
				* <p>Rendering occurs in two ways: a light changes or an element changes. When a light changes this happens:</p>
				* <ol>
				* <li>A renderStart call is issued for each affected element.</li>
				* <li>Each affected element receives a renderLight call, and if any is needed several renderShadow calls.</li>
				* <li>A renderFinish call is issued for each affected element.</li>
				* </ol>
				* <p>This is the renderFinish call.</p>
				*
				* @param element The element we are rendering
				* @param light The light that we are rendering upon this element
				*/
				function renderFinish(element:fRenderableElement,light:fOmniLight):void;
		
				/**
				* <p>Rendering occurs in two ways: a light changes or an element changes. When an element changes this happens:</p>
				* <ol>
				* <li>A renderStart call is issued for the updated element.</li>
				* <li>The element receives a renderLight call, and if any is needed several renderShadow calls.</li>
				* <li>A renderFinish call is issued for the affected element.</li>
				* <li>All elements that receive shadows from the moving element receive an updateShadow call.</li>
				* </ol>
				* <p>This is the updateShadow call.</p>
				*
				* @param element The element to be updated
				* @param light The light that we are rendering upon this element
				* @param element The element whose shadow is to be updated
				*/
				function updateShadow(element:fRenderableElement,light:fOmniLight,shadow:fRenderableElement):void;

				/**
				* When an element is removed or hidden, or moves out of another element's range, its shadows need to be removed too
				*
				* @param element The element to be updated
				* @param light The light that we are rendering upon this element
				* @param element The element whose shadow is to be removed
				*/
				function removeShadow(element:fRenderableElement,light:fOmniLight,shadow:fRenderableElement):void;


				/**
				* When the quality settings for the engine's shadows are changed, this method is called so old shadows are removed.
				* There is no need for the renderer to redraw all shadows in this method: The engine rerenders the whole scene after
				* this has been executed.
				*/
				function resetShadows():void;

				/**
				* Updates the render to show a given camera's position
				*/
				function setCameraPosition(camera:fCamera):void;
				
				/**
				* Updates the viewport size. This call will be immediately followed by a setCameraPosition call
				* @see org.ffilmation.engine.interfaces.fRenderEngine#setCameraPosition
				*/
				function setViewportSize(width:Number,height:Number):void;

				/**
				* Starts acclusion related to one character
				* @param element Element where occlusion is applied
				* @param character Character causing the occlusion
				*/
				function startOcclusion(element:fRenderableElement,character:fCharacter):void;
				
				/**
				* Updates acclusion related to one character
				* @param element Element where occlusion is applied
				* @param character Character causing the occlusion
				*/
				function updateOcclusion(element:fRenderableElement,character:fCharacter):void;
      	
				/**
				* Stops acclusion related to one character
				* @param element Element where occlusion is applied
				* @param character Character causing the occlusion
				*/
				function stopOcclusion(element:fRenderableElement,character:fCharacter):void;

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
				function translateStageCoordsToElements(x:Number,y:Number):Array;

				/** 
				* Frees all allocated resources. This is called when the scene is hidden or destroyed.
				*/
				function dispose():void;
				
				
		}
		
}