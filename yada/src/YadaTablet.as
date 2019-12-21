/**
 * Created with IntelliJ IDEA.
 * User: mobitile
 * Date: 10/28/13
 * Time: 4:01 PM
 * To change this template use File | Settings | File Templates.
 */
package {
import com.github.childly.yada.AppStarlingRoot2;

[SWF(width="1024",height="768",frameRate="60",backgroundColor="#4a4137")]
public class YadaTablet extends Yada
{
    public function YadaTablet()
    {
        super();
    }

    override protected function getApplicationClass():Class
    {
//        return RenderTextureScene;
//        return AppStarlingRoot;
//        return AppStarlingRoot1;
        return AppStarlingRoot2;
    }
}
}
