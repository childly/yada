/**
 * Created by Max Rozdobudko on 1/23/15.
 */
package
{
import flash.display.Bitmap;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;

[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "0x000000")]
public class YadaBitmapData extends Sprite
{
    [Embed(source="/assets/brush-circle-small.png", mimeType="image/png")]
    private var BrushBm : Class;

    public function YadaBitmapData()
    {
        super();

        Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

        var mySprite:Sprite = new Sprite();

        trace(Multitouch.supportsTouchEvents);

        mySprite.graphics.beginFill(0x336699);
        mySprite.graphics.drawRect(0,0,400,400);
        addChild(mySprite);

        mySprite.addEventListener(TouchEvent.TOUCH_TAP, touchMoveHandler);
        stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchMoveHandler);
        stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
        stage.addEventListener(TouchEvent.PROXIMITY_BEGIN, touchMoveHandler);

        stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

        bmd = new BitmapData(465, 465, true, 0x00FFFFFF);

        brush = Bitmap(new BrushBm()).bitmapData;

        addChild(new Bitmap(bmd));
    }

    private var brush:BitmapData;

    private var bmd:BitmapData;

    private function touchMoveHandler(event:TouchEvent):void
    {
        trace(event.touchPointID);

//        bmd.copyPixels(brush, brush.rect, new Point(event.stageX, event.stageY), null, null, true);
    }

    private var point:Point = new Point();

    private function mouseMoveHandler(event:MouseEvent):void
    {
        var prev:Point = new Point(event.stageX, event.stageY);

        var gapX : Number = prev.x - point.x;
        var gapY : Number = prev.y - point.y;
        var gap : Number = Math.sqrt((gapX * gapX) + (gapY * gapY));

        var fillGaps : int = Math.ceil(Math.round(gap) / (brush.width * .05));

        for (var i : int = 1; i < fillGaps; i++)
        {
            bmd.copyPixels(brush, brush.rect, new Point(prev.x + gapX * (i / fillGaps), prev.y + gapY * (i / fillGaps)), null, null, true);
        }

        point = prev;
    }
}
}
