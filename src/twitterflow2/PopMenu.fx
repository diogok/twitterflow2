/*
 * PopMenu.fx
 *
 * Created on 06/11/2009, 22:50:45
 */

package twitterflow2;

import javafx.scene.layout.VBox;
import javafx.scene.Group;
import javafx.scene.shape.Rectangle;
import javafx.scene.text.Text;
import javafx.scene.paint.Color;
import javafx.scene.input.MouseEvent;
import javafx.scene.Scene;
import java.lang.System;

import javafx.scene.Cursor;

/**
 * @author diogo
 */

public class PopMenu {

    public var itens: String[] ;
    public var action: function(item: String): Void ;

    public var lightColor: Color = Color.WHITE ;
    public var darkColor: Color = Color.WHITESMOKE ;
    public var fontColor: Color = Color.DARKGRAY ;

    public var width: Number = 175 ;

    public var scene: Scene ;

    public function create(): VBox {
        def vbox: VBox = VBox {
            content:[]
            spacing: 0
        }
        var i = 0;
        for(str in itens) {
            insert Group {
                content: [
                        Rectangle {
                            width: width
                            height: 25
                            translateY: 2
                            translateX: 2
                            cursor: Cursor.HAND
                            fill: if (i mod 2 == 0 ) { lightColor } else {darkColor }
                            onMouseClicked: function(e: MouseEvent) {
                                if(FX.isInitialized(action)) {
                                    action(str)
                                }
                            }
                        }
                        Text {
                            content: str
                            translateX: 15
                            translateY: 18
                            fill: fontColor
                        }
                ]
            } into vbox.content ;
            i++ ;
        }
        return vbox;
    }

    var box: VBox;
    var rect: Rectangle;

    public function show(e: MouseEvent): Void {
        box = create();
        box.translateX = e.sceneX;
        box.translateY = e.sceneY;
        rect = Rectangle {
            fill: Color.BLACK
            opacity: 0.7
            width: bind scene.width
            height: bind scene.height
            onMouseClicked: dissmiss
        } ;
        insert rect into scene.content;
        insert box into scene.content;
    }

    public function dissmiss(): Void {
         delete box from scene.content;
         delete rect from scene.content;
         rect = null;
         box = null;
         System.gc();
    }

    public function dissmiss(e: MouseEvent): Void {
          dissmiss();
    }

}
