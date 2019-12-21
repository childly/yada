/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 10/28/13
 * Time: 4:02 PM
 * To change this template use File | Settings | File Templates.
 */
package com.github.childly.yada
{
import feathers.themes.MetalWorksMobileTheme;

import flash.geom.Matrix;

import flash.geom.Point;

import org.spicefactory.parsley.view.StarlingConfigure;

import starling.display.DisplayObject;

import starling.display.Image;

import starling.display.Quad;
import starling.display.Shape;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.RenderTexture;
import starling.textures.Texture;

public class Application extends Sprite
{
    [Embed("/assets/brush-circle.png")]
    public static const BRUSH:Class;

    public function Application()
    {
        super();

        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);

        StarlingConfigure.view(this).execute();

        var q:Quad = new Quad(512, 512, 0x324242);
        addChild(q);



//        addEventListener(TouchEvent.TOUCH, touchHandler);
        useHandCursor = true;
    }

    private var shape:Shape;

    private var _renderTexture:RenderTexture;

    private var _brush:Image;

    private var _canvas:Image;

    protected function onAdded():void
    {
        new MetalWorksMobileTheme();

//        _renderTexture = new RenderTexture(512, 512);
//        _canvas = new Image(_renderTexture);
//        addChild(_canvas);

        _brush = new Image(Texture.fromBitmap(new BRUSH()));
        _brush.pivotX = _brush.width >> 1;
        _brush.pivotY = _brush.height >> 1;
        _brush.color = 0x9900ff;
        addChild(_brush);
    }

    protected function onRemoved():void
    {

    }

    protected function onResize():void
    {

    }

    //--------------------------------------------------------------------------
    //
    //  Handlers
    //
    //--------------------------------------------------------------------------

    private function addedToStageHandler(event:Event):void
    {
        stage.addEventListener(ResizeEvent.RESIZE, stage_resizeHandler);

        onAdded();
    }

    private function removedFromStageHandler(event:Event):void
    {
        stage.removeEventListener(ResizeEvent.RESIZE, stage_resizeHandler);

        onRemoved();
    }

    //-------------------------------------
    //  Handlers: stage
    //-------------------------------------

    private function stage_resizeHandler(event:ResizeEvent):void
    {
        onResize();
    }

    private function touchHandler(event:TouchEvent):void
    {
        var touches : Vector.<Touch> = event.getTouches(event.target as DisplayObject);
        for each (var touch : Touch in touches)
        {
            var location : Point = touch.getLocation(_canvas);

            if (touch.phase == TouchPhase.HOVER)
            {
                _brush.x = _canvas.localToGlobal(location).x;
                _brush.y = _canvas.localToGlobal(location).y;
                _brush.visible = true;

                continue;
            }

            //var location : Point = touch.getLocation(_canvas);

            var prevLocation : Point = touch.getPreviousLocation(_canvas);

            var startx:int = prevLocation.x;
            var starty:int = prevLocation.y;
            var endx:int = location.x;
            var endy:int = location.y;
            var delta_x:int;
            var delta_y:int;

            var t:int;
            var distance:int;
            var xerr:int = 0;
            var yerr:int = 0;

            var incx:int;
            var incy:int;

            delta_x=endx-startx;
            delta_y=endy-starty;

//				var gap : Number = Math.sqrt((gapX * gapX) + (gapY * gapY));
//				var fillGaps : int = Math.ceil(Math.round(gap) / (_brush.width * .05));
//
//				for (var i : int = 1; i < fillGaps; i++)
//				{
//					_extraDraws.push(new Point(prevLocation.x + gapX * (i / fillGaps), prevLocation.y + gapY * (i / fillGaps)));
//				}
            if(delta_x>0) incx=1;
            else if(delta_x==0) incx=0;
            else incx=-1;

            if(delta_y>0) incy=1;
            else if(delta_y==0) incy=0;
            else incy=-1;

            /* determine which distance is greater */
            delta_x=Math.abs(delta_x);
            delta_y=Math.abs(delta_y);
            if(delta_x>delta_y) distance=delta_x;
            else distance=delta_y;

            /* draw the line */
            for(t=0; t<=distance+1; t++) {
                wp(startx, starty);

                xerr+=delta_x;
                yerr+=delta_y;
                if(xerr>distance) {
                    xerr-=distance;
                    startx+=incx;
                }
                if(yerr>distance) {
                    yerr-=distance;
                    starty+=incy;
                }
            }

            //if(spacebar)
            //_renderTexture.draw(_brush);

        }
    }

    private function wp(startx:int, starty:int):void
    {
        var matrix:Matrix = new Matrix();
        matrix.scale(1,1);
        matrix.tx = _brush.x;
        matrix.ty = _brush.y;

        _renderTexture.draw(_brush, matrix);

    }
}
}
