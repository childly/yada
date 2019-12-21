package {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.Stage3D;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;

/*    import ore.orelib.commons.Key;
 import ore.orelib.commons.Labeler;
 */
[SWF(width = "465", height = "465", frameRate = "60", backgroundColor = "0x000000")]
public class Main extends Sprite {
    private var _stage3D:Stage3D;
    private var _ore2D:Ore2D;
    private var _particles:Vector.<Particle>;
    private var _particlePool:Vector.<Particle>;
    private var _image:BitmapData;
    private var _screen:BitmapData;
    private var _numParticlesLabel:TextField;
    private var _renderingMode:Boolean;

    public function Main() {
        _stage3D = stage.stage3Ds[0];
        _stage3D.addEventListener(Event.CONTEXT3D_CREATE, init);
        _stage3D.requestContext3D();
    }

    private function init(event:Event):void {
        event.currentTarget.removeEventListener(event.type, arguments.callee);

        _ore2D = new Ore2D(_stage3D, 233, 233);
        _particles = new Vector.<Particle>();
        _particlePool = new Vector.<Particle>();

        _image = createImage();
        _ore2D.upload(new <BitmapData>[_image]);

        addChild(new Bitmap(_screen = new BitmapData(465, 465, true, 0x00FFFFFF)));
        addChild(_numParticlesLabel = new Labeler()
                        .align(Labeler.BOTTOM_RIGHT).filters([new GlowFilter(0x000000, 1, 4, 4)])
                        .fontColor(0xFFFFFF).pos(365, 0).size(100, 20).build("")
        );
        new PlainButton(this, {width:320, height:20}, function(event:MouseEvent):void {
            _renderingMode = !_renderingMode;
        });
        _renderingMode = true;

        Key.init(this);
        addEventListener(Event.ENTER_FRAME, update);
    }

    private function createImage():BitmapData {
        var result:BitmapData = new BitmapData(16, 16, true, 0x00FFFFFF);
        var sp:Sprite = new Sprite();
        var g:Graphics = sp.graphics;
        g.beginFill(0xFFFFFF); g.drawCircle(8, 8, 4); g.endFill();
        sp.filters = [new GlowFilter(0xFFFF00, 1, 4, 4)];
        result.draw(sp);
        return result;
    }

    private function update(event:Event):void {
        if (Key.isDown(Key.MOUSE_LEFT)) { emitParticles(stage.mouseX, stage.mouseY); }

        _stage3D.context3D.clear();
        _screen.fillRect(_screen.rect, 0x00FFFFFF);
        for (var i:int = _particles.length - 1; i >= 0; i--) {
            var particle:Particle = _particles[i];
            particle.update();

            if (0 < particle.pos.x && particle.pos.x < 465 && 0 < particle.pos.y && particle.pos.y < 465) {
                (_renderingMode) ? _ore2D.draw(particle.image, particle.dest) : _screen.copyPixels(particle.image, particle.image.rect, particle.dest, null, null, true);
            } else {
                _particles.splice(i, 1);
                _particlePool.push(particle);
            }
        }
        _stage3D.context3D.present();

        _numParticlesLabel.text = ((_renderingMode) ? "GPU" : "CPU") + ": " + _particles.length.toString();
    }

    private function emitParticles(x:Number, y:Number):void {
        var a:Number = Math.PI / 60;
        for (var i:int = 0; i < 120; i++) {
            var particle:Particle = (_particlePool.length) ? _particlePool.pop() : new Particle();
            particle.init(x, y, 3 * Math.cos(a * i), 3 * Math.tan(a * i), _image);
            _particles.push(particle);
        }
    }
}
}
//package {
import com.adobe.utils.AGALMiniAssembler;
import flash.display.BitmapData;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.textures.Texture;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

//public
class Ore2D {
    private var _context3D:Context3D;
    private var _backBufferHalfSize:Point;
    private var _vertexData:Vector.<Number>;
    private var _vertexBuffer:VertexBuffer3D;
    private var _indexBuffer:IndexBuffer3D;
    private var _vertexProgram:ByteArray;
    private var _fragmentProgram:ByteArray;
    private var _bitmapDataToTexture:Dictionary;

    public function Ore2D(stage3D:Stage3D, backBufferHalfWidth:int, backBufferHalfHeight:int) {
        _context3D = stage3D.context3D;
        _backBufferHalfSize = new Point(backBufferHalfWidth, backBufferHalfHeight);
        _vertexData = new Vector.<Number>(8, true);
        var assembler:AGALMiniAssembler = new AGALMiniAssembler();
        _vertexProgram = assembler.assemble(Context3DProgramType.VERTEX, "mov v0, va0\n" + "mov op, va1");
        _fragmentProgram = assembler.assemble(Context3DProgramType.FRAGMENT, "tex oc, v0, fs0<2d, clamp, nearest, nomip>");
        _bitmapDataToTexture = new Dictionary();

        onContext3DCreated();
        stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated);
    }

    private function onContext3DCreated(event:Event = null):void {
        if (event) { _context3D = event.currentTarget.context3D; }
        _context3D.configureBackBuffer(_backBufferHalfSize.x * 2, _backBufferHalfSize.y * 2, 0, false);
        // uv
        var uvBuffer:VertexBuffer3D = _context3D.createVertexBuffer(4, 2);
        uvBuffer.uploadFromVector(new <Number>[0, 0, 1, 0, 0, 1, 1, 1], 0, 4);
        _context3D.setVertexBufferAt(0, uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        // vertex
        _vertexBuffer = _context3D.createVertexBuffer(4, 2);
        // index
        _indexBuffer = _context3D.createIndexBuffer(6);
        _indexBuffer.uploadFromVector(new <uint>[0, 1, 2, 1, 2, 3], 0, 6);
        // program
        var program3D:Program3D = _context3D.createProgram();
        program3D.upload(_vertexProgram, _fragmentProgram);
        _context3D.setProgram(program3D);
        // texture
        for (var bitmapData:Object in _bitmapDataToTexture) {
            uploadFromBitmapData(bitmapData as BitmapData);
        }
        // blend
        _context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
    }

    public function upload(bitmapDataList:Vector.<BitmapData>):void {
        for (var i:int = 0; i < bitmapDataList.length; i++) {
            uploadFromBitmapData(bitmapDataList[i]);
        }
    }

    private function uploadFromBitmapData(bitmapData:BitmapData):void {
        var texture:Texture = _context3D.createTexture(bitmapData.width, bitmapData.height, Context3DTextureFormat.BGRA, false);
        texture.uploadFromBitmapData(bitmapData);
        _bitmapDataToTexture[bitmapData] = texture;
    }

    public function draw(source:BitmapData, dest:Point):void {
        _vertexData[0] = _vertexData[4] = dest.x / _backBufferHalfSize.x - 1;
        _vertexData[1] = _vertexData[3] = -dest.y / _backBufferHalfSize.y + 1;
        _vertexData[2] = _vertexData[6] = (dest.x + source.width) / _backBufferHalfSize.x - 1;
        _vertexData[5] = _vertexData[7] = -(dest.y + source.height) / _backBufferHalfSize.y + 1;
        _vertexBuffer.uploadFromVector(_vertexData, 0, 4);
        _context3D.setVertexBufferAt(1, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
        _context3D.setTextureAt(0, _bitmapDataToTexture[source]);
        _context3D.drawTriangles(_indexBuffer);
    }
}
//}
//package {
import flash.display.BitmapData;
import flash.geom.Point;

//public
class Particle {
    private var _pos:Point;
    private var _velocity:Point;
    private var _image:BitmapData;
    private var _dest:Point;

    public function Particle() {
        _pos = new Point();
        _velocity = new Point();
        _dest = new Point();
    }

    public function init(x:Number, y:Number, vx:Number, vy:Number, image:BitmapData):void {
        _pos.setTo(x, y);
        _velocity.setTo(vx, vy);
        _image = image;
        _dest.setTo(x - (image.width >> 1), y - (image.height >> 1));
    }

    public function update():void {
        _pos.offset(_velocity.x, _velocity.y);
        _dest.offset(_velocity.x, _velocity.y);
    }

    public function get pos():Point { return _pos; }
    public function get image():BitmapData { return _image; }
    public function get dest():Point { return _dest; }
}
//}
//package ore.orelib.commons {
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.ContextMenu;

//public
class Key {
    private static var _stage:Stage;
    private static var _currentStates:Vector.<Boolean>;
    private static var _previousStates:Vector.<Boolean>;

    public static const MOUSE_LEFT:uint = 0;
    public static const MOUSE_RIGHT:uint = 255;

    public static function init(documentClass:Sprite):void {
        _stage = documentClass.stage;
        _currentStates = new Vector.<Boolean>(256, true);
        _previousStates = new Vector.<Boolean>(256, true);

        _stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        _stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
        _stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        _stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
        _stage.addEventListener(Event.EXIT_FRAME, update);
        _stage.addEventListener(Event.DEACTIVATE, clear);

        var contextMenu:ContextMenu = new ContextMenu();
        contextMenu.hideBuiltInItems();
        contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, clear);
        documentClass.contextMenu = contextMenu;
    }

    private static function keyDownHandler(event:KeyboardEvent):void { _currentStates[event.keyCode] = true; }
    private static function keyUpHandler(event:KeyboardEvent):void { _currentStates[event.keyCode] = false; }
    private static function mouseDownHandler(event:MouseEvent):void { _currentStates[Key.MOUSE_LEFT] = true; }
    private static function mouseUpHandler(event:MouseEvent):void { _currentStates[Key.MOUSE_LEFT] = false; }

    private static function update(event:Event):void {
        for (var i:int = 0; i < 256; i++) {
            _previousStates[i] = _currentStates[i];
        }
    }

    private static function clear(event:Event):void {
        for (var i:int = 0; i < 256; i++) {
            _currentStates[i] = false;
        }
    }

    public static function isDown(keyCode:uint):Boolean { return _stage.focus == null && _currentStates[keyCode]; }
    public static function pressed(keyCode:uint):Boolean { return Key.isDown(keyCode) && !_previousStates[keyCode]; }
}
//}
//package ore.orelib.commons {
import flash.geom.Point;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

//public
class Labeler {
    private var _hAlign:String;
    private var _autoSize:String;
    private var _vAlign:String;
    private var _background:Boolean;
    private var _backgroundColor:uint;
    private var _filters:Array;
    private var _fontName:String;
    private var _sharpness:Number;
    private var _thickness:Number;
    private var _fontColor:uint;
    private var _fontSize:int;
    private var _position:Point;
    private var _selectable:Boolean;
    private var _size:Point;
    private var _wordWrap:Boolean;

    public static const NONE:String = "none";
    public static const TOP_LEFT:String = "top_left";
    public static const MIDDLE_CENTER:String = "middle_center";
    public static const BOTTOM_RIGHT:String = "bottom_right";

    public function Labeler() {
        _hAlign = TextFormatAlign.LEFT;
        _autoSize = TextFieldAutoSize.NONE;
        _vAlign = Labeler.TOP_LEFT;
        _background = false;
        _backgroundColor = 0xFFFFFF;
        _filters = [];
        _fontName = "_sans";
        _sharpness = _thickness = 0;
        _fontColor = 0x000000;
        _fontSize = 12;
        _position = new Point(0, 0);
        _size = new Point(100, 100);
        _selectable = _wordWrap = false;
    }

    public function align(value:String = Labeler.TOP_LEFT):Labeler {
        switch(value) {
            case Labeler.MIDDLE_CENTER: { _hAlign = TextFormatAlign.CENTER; break; }
            case Labeler.BOTTOM_RIGHT: { _hAlign = TextFormatAlign.RIGHT; break; }
            case Labeler.TOP_LEFT: default: { _hAlign = TextFormatAlign.LEFT; break; }
        }
        return this;
    }

    public function autoSize(horizontal:String = Labeler.NONE, vertical:String = Labeler.TOP_LEFT):Labeler {
        switch(horizontal) {
            case Labeler.TOP_LEFT: { _autoSize = TextFieldAutoSize.LEFT; break; }
            case Labeler.MIDDLE_CENTER: { _autoSize = TextFieldAutoSize.CENTER; break; }
            case Labeler.BOTTOM_RIGHT: { _autoSize = TextFieldAutoSize.RIGHT; break; }
            case Labeler.NONE: default: { _autoSize = TextFieldAutoSize.NONE; break; }
        }
        _vAlign = vertical;
        return this;
    }

    public function background(enabled:Boolean = true, color:uint = 0xFF0000):Labeler { _background = enabled; _backgroundColor = color; return this; }
    public function filters(value:Array):Labeler { _filters = value; return this; }
    public function font(name:String, sharpness:Number = 0, thickness:Number = 0):Labeler { _fontName = name; _sharpness = sharpness; _thickness = thickness; return this; }
    public function fontColor(value:uint):Labeler { _fontColor = value; return this; }
    public function fontSize(value:int):Labeler { _fontSize = value; return this; }
    public function offset(x:Number, y:Number):Labeler { _position.offset(x, y); return this; }
    public function pos(x:Number, y:Number):Labeler { _position.setTo(x, y); return this; }
    public function selectable(enabled:Boolean = true):Labeler { _selectable = enabled; return this; }
    public function size(width:Number, height:Number):Labeler { _size.setTo(width, height); return this; }
    public function wordWrap(enabled:Boolean = true):Labeler { _wordWrap = enabled; return this; }

    public function build(text:String):TextField {
        var result:TextField = new TextField();
        result.x = _position.x; result.width = _size.x; result.height = _size.y;
        result.autoSize = _autoSize;
        result.background = _background; result.backgroundColor = _backgroundColor;
        result.filters = _filters;
        result.mouseEnabled = result.selectable = _selectable;
        result.wordWrap = _wordWrap;
        result.defaultTextFormat = new TextFormat(_fontName, _fontSize, _fontColor, null, null, null, null, null, _hAlign);
        if (_fontName != "_sans") {
            result.embedFonts = true;
            result.antiAliasType = AntiAliasType.ADVANCED;
            result.gridFitType = (_hAlign == TextFormatAlign.LEFT) ? GridFitType.PIXEL : GridFitType.SUBPIXEL;
            result.sharpness = _sharpness; result.thickness = _thickness;
        }
        result.text = text;
        switch(_vAlign) {
            case Labeler.MIDDLE_CENTER: { result.y = _position.y + (_size.y - result.height) / 2; break; }
            case Labeler.BOTTOM_RIGHT: { result.y = _position.y + (_size.y - result.height); break; }
            case Labeler.TOP_LEFT: default: { result.y = _position.y; break; }
        }
        return result;
    }
}
//}


import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

class PlainButton extends Sprite
{
    function PlainButton(parent:DisplayObjectContainer=null, properties:Object=null, clickHandler:Function=null)
    {
        super();

        _props = properties;
        _label = properties ? (properties.label || "") : "";
        _color = properties ? (properties.color || 0) : 0;

        var textColor:uint = properties ? (properties.textColor || 0xFFFFFF) : 0xFFFFFF;

        textDisplay = new TextField();
        textDisplay.defaultTextFormat = new TextFormat("_sans", 24, textColor, null, null, null, null, null, TextFormatAlign.CENTER);
        textDisplay.selectable = false;
        textDisplay.autoSize = "center";
        addChild(textDisplay);

        x = _props.x || 0;
        y = _props.y || 0;

        if (parent)
            parent.addChild(this);

        if (clickHandler != null)
            addEventListener(MouseEvent.CLICK, clickHandler);

        sizeInvalid = true;
        labelInvalid = true;

        addEventListener(Event.ENTER_FRAME, renderHandler);
    }

    private var sizeInvalid:Boolean;
    private var labelInvalid:Boolean;

    private var _label:String;
    private var _color:uint;
    private var _props:Object;

    private var textDisplay:TextField;

    private function renderHandler(event:Event):void
    {
        if (labelInvalid)
        {
            labelInvalid = false;

            textDisplay.text = _label;
        }

        if (sizeInvalid)
        {
            sizeInvalid = false;

            var w:Number = _props.width || _props.w || 100;
            var h:Number = _props.height || _props.h || 40;

            graphics.clear();
            graphics.beginFill(_color);
            graphics.drawRect(0, 0, w, h);
            graphics.endFill();

            textDisplay.x = 0;
            textDisplay.width = w;
            textDisplay.y = (h - textDisplay.height) / 2;
        }
    }
}