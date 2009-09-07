/*
 * Clippy.fx
 *
 * Created on 13/07/2009, 00:22:34 
 */  
 
package twitterflow2;

import javafx.scene.layout.ClipView;
import javafx.scene.input.MouseEvent;
import javafx.scene.Cursor;
import javafx.scene.Group;
import javafx.scene.layout.VBox;
import javafx.scene.Node;
import javafx.scene.control.ScrollBar;
import java.lang.Math;
  
/** 
 * @author diogo
 */

public class Clippy extends ClipView {

    public var nodeSize: Number = 90;

    def whellWall = function(event: MouseEvent):Void {
        rollWall(event.wheelRotation * 10);
    }
 
    def rollWall = function(move: Float) {
        //clipY = clipY + move ;
        scroller.adjustValue(move);
    }

    def scroller: ScrollBar = ScrollBar {
        min: 0
        max: bind Math.max((sizeof inner.content * nodeSize), 0)
        vertical: true
        //height:  bind Math.max((sizeof inner.content * 90), scene.stage.height - 80)
        height:  bind height
        blockIncrement: 5
        focusTraversable: false
        blocksMouse: true
        translateY: bind clipY
        translateX: bind width - 22
    }

    override var clipY = bind scroller.value ;

    public-init var inner: VBox = VBox {} ;
    public var owner: String ;
    
    postinit {
        layoutY= 50;
        pannable= false;
        cursor= Cursor.DEFAULT;
        clipY= 0; 
        clipX= 0 ;
        node = Group {
            content: [
                inner,
                scroller,
                ]
        };
        onMouseWheelMoved= whellWall
    }


    public function update(nodes: Node[]): Void {
        FX.deferAction(function():Void {
                delete inner.content ;
                inner.content = nodes ;
            });
    }

}