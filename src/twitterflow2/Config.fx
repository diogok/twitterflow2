/*
 * Config.fx
 *
 * Created on 08/11/2009, 12:10:20
 */

package twitterflow2;

import twitter4j.http.RequestToken;
import javafx.scene.control.Button;
import twitter4j.Twitter;
import java.lang.System;
import twitter4j.http.AccessToken;
import javafx.scene.control.TextBox;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.paint.Color;
import javafx.scene.layout.VBox;
import javafx.geometry.HPos;
import java.io.InputStream;
import java.lang.StringBuffer;
import java.io.OutputStream;
import javafx.io.Resource;
import javafx.io.Storage;

/**
 * @author diogo
 */


public def consumerKey :String = "tSYh5dVobnKTnxjKSqPhEQ";
public def consumerSecret: String = "zoJcXbD0xUKBrKYTQ5QOFPS0PmR8SrOzjh7rJtRdEQU";
def resource: Resource = Storage { source: "/extras/downloads/flow-oauth-pim.txt" }.resource ;
//def resource: Resource = Storage { source: "flow-oauth-pim.txt" }.resource ;

public function openConfig(twitter: Twitter, start: function()): Void {
    def requestToken: RequestToken = twitter.getOAuthRequestToken();

    def requestAuth: Button = Button {
                                    text: "Request Authorization"
                                    action: function() {
                                        Main.openURL(requestToken.getAuthorizationURL());
                                    }
                     };

    def pimRegister: Button = Button { text:" Enter and Save PIN  ",
                        action: function() {
                                    def accessToken: AccessToken =
                                        twitter.getOAuthAccessToken(requestToken, pimField.text);
                                    saveToken(accessToken.getToken(), accessToken.getTokenSecret());
                                    twitter.setOAuthAccessToken(accessToken);
                                    start();
                                    cStage.close();
                                    System.gc();
                                }
                     };
    def pimNoRegister: Button = Button { text:"Enter and Discard PIN",
                        action: function() {
                                    def accessToken: AccessToken =
                                        twitter.getOAuthAccessToken(requestToken, pimField.text);
                                    //saveToken(accessToken.getToken(), accessToken.getTokenSecret());
                                    twitter.setOAuthAccessToken(accessToken);
                                    start();
                                    cStage.close();
                                    System.gc();
                                }
                     };

    def pimField: TextBox = TextBox {action: pimRegister.action, promptText: "PIN", columns: 18} ;
    def cStage:Stage = Stage {
        title: "TwitterFlow - Configure"
        width : 200
        height: 170
        scene: Scene {
            fill: Color.BLACK
            content: [VBox {
                        translateX: 20
                        translateY: 20
                        hpos: HPos.CENTER
                        spacing: 5
                        content: [ requestAuth, pimField,pimRegister, pimNoRegister ]
                    }]
        }

    }

}

public function getToken(): AccessToken {
       def is: InputStream = resource.openInputStream();
       def sb:StringBuffer = StringBuffer{};
       var c= is.read();
       while(c != -1) {
           sb.append(c as Character);
           c = is.read();
       }
       is.close();
       def arg: String[] = sb.toString().split("\n");
       new AccessToken(arg[0],arg[1])
}

public function saveToken( token: String,secret: String): Void {
    def os: OutputStream = resource.openOutputStream(true);
    os.write("{token}\n{secret}".getBytes());
    os.close();
}



public class Config {

}
