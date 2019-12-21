package com.github.childly.yada
{
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.RenderTexture;
import starling.textures.Texture;
import flash.geom.Point;

public class AppStarlingRoot1 extends Sprite
{
//    [Embed(source="/assets/brush-1.png", mimeType="image/png")]
    [Embed(source="/assets/brush-circle.png", mimeType="image/png")]
    private var BrushBm : Class;

    private var _renderTexture : RenderTexture;
    private var _canvas : Image;
    private var _brush : Image;
    private var _extraDraws : Array = [];

    public function AppStarlingRoot1()
    {
        trace("AppStarlingRoot.as -> AppStarlingRoot");
        addEventListener(Event.ADDED_TO_STAGE, addedEvent);
    }

    private function addedEvent(event : Event) : void
    {
        removeEventListener(Event.ADDED_TO_STAGE, addedEvent);

        _renderTexture = new RenderTexture(512, 384);
        _canvas = new Image(_renderTexture);
        addChild(_canvas);

        _brush = new Image(Texture.fromBitmap(new BrushBm()));
        _brush.pivotX = _brush.width >> 1;
        _brush.pivotY = _brush.height >> 1;
        _brush.scaleX = 0.5;
        _brush.scaleY = 0.5;
        _brush.color = 0x9900ff;

        stage.addEventListener(TouchEvent.TOUCH, touchEvent);
        addEventListener(Event.ENTER_FRAME, entFrame);
    }

    private function touchEvent(event : TouchEvent) : void
    {
        var touches : Vector.<Touch> = event.getTouches(event.target as DisplayObject);
        for each (var touch : Touch in touches)
        {
            if (touch.phase == TouchPhase.HOVER)
                continue;

            var location : Point = touch.getLocation(_canvas);
            _brush.x = location.x;
            _brush.y = location.y;

            var prevLocation : Point = touch.getPreviousLocation(_canvas);
            var gapX : Number = location.x - prevLocation.x;
            var gapY : Number = location.y - prevLocation.y;
            var gap : Number = Math.sqrt((gapX * gapX) + (gapY * gapY));
            var fillGaps : int = Math.ceil(Math.round(gap) / (_brush.width * .05));

            for (var i : int = 1; i < fillGaps; i++)
            {
                _extraDraws.push(new Point(prevLocation.x + gapX * (i / fillGaps), prevLocation.y + gapY * (i / fillGaps)));
            }

            _renderTexture.draw(_brush);
        }
    }

    private function entFrame(event : Event) : void
    {
        _renderTexture.drawBundled(function() : void
                                   {
                                       for (var i : int = 0; i < 50; i++)
                                       {
                                           if (_extraDraws.length)
                                           {
                                               var p : Point = _extraDraws.shift();
                                               _brush.x = p.x;
                                               _brush.y = p.y;
                                               _renderTexture.draw(_brush);
                                           }
                                           else
                                               break;
                                       }
                                   });
    }
}
}