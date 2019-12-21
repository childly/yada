package {

import com.github.childly.yada.Application;

import flash.display.Sprite;
import flash.text.TextField;

public class YadaTablet extends Yada
{
    public function YadaTablet()
    {
        super();
    }

    override protected function getApplicationClass():Class
    {
        return Application;
    }
}
}
