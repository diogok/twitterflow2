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

import javafx.scene.Cursor;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;

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
    var t: Timeline ;

    public function show(x: Number, y:Number): Void {
        box = create();
        box.translateX = x;
        box.translateY =y;
        box.opacity = 0.0;
        rect = Rectangle {
            fill: Color.BLACK
            opacity: 0.0
            width: bind scene.width
            height: bind scene.height
            onMouseClicked: dissmiss
        } ;
        t = Timeline {
            repeatCount: 1
            keyFrames: [
                    for(i in [0..5]) {
                        KeyFrame {
                            canSkip: true
                            time: (0.2s * i )+ 0.1s
                            action: function() {
                                FX.deferAction(function() : Void{
                                    rect.opacity = 0.15 * i;
                                    box.opacity = 0.2 * i;
                                });
                            }
                        }
                    }
                ]
        }
        t.play();
        FX.deferAction(function():Void {
            insert rect into scene.content;
            insert box into scene.content;
        });
    }

    public function getShow(): function(): Void {
        return show ;
    }

    public function show(): Void {
        show((scene.width/2) - (width/2),(scene.height/2) - ((sizeof itens*25)/2));
    }
    
    public function show(e: MouseEvent): Void {
        show(e.sceneX,e.sceneY);
    }

    public function dissmiss(): Void {
         t.stop();
         delete box from scene.content;
         delete rect from scene.content;
         rect = null;
         box = null;
         t = null;
    }

    public function dissmiss(e: MouseEvent): Void {
          dissmiss();
    }

}
