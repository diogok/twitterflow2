/*
 * Copyright (c) 2009, Mauricio Aguilar O.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - Neither the name of Mauricio Aguilar O. nor the names of its contributors
 *   may be used to endorse or promote products derived from this software
 *   without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * @author: Mauricio Aguilar O.
 * Website: http://aprendiendo-javafx.blogspot.com
 * email  : maguilar2k@yahoo.com
 * Date   : April 17 , 2009
 *
 */

package twitterflow2;

import javafx.scene.CustomNode;
import javafx.scene.paint.Color;
import javafx.scene.Node;
import javafx.scene.Group;
import javafx.scene.shape.*;
import javafx.scene.text.*;
import javafx.scene.Cursor;
import java.lang.Math;

/** tag: </p> */
def P:Integer=1;
/** tag: <br> */
def BR:Integer=2;
/** tag: <p align=left> */
def LEFT:Integer=3;
/** tag: <p align=right> */
def RIGHT:Integer=4;
/** tag: <p align=center> */
def CENTER:Integer=5;
/** tag: <p align=justify> */
def JUSTIFY:Integer=6;


/** cache font size -> text line height */
var lineHeights:fontsizePixels[];
/** cache fonts */
var fonts:fontCache[];
/** global function for click on links */
public var mainOnLinkPressed:function(String);
/** global function for mouseover link */
public var mainOnLinkEntered:function(String);
/** global function for mouseover link */
public var mainOnLinkExited:function(String);
/** global link normal background */
public var mainOnLinkEnteredColor:Color=Color.TRANSPARENT;
/** global link highligthed background */
public var mainOnLinkExitedColor:Color=Color.TRANSPARENT;


/** HTML text component */
public class TextHTML extends CustomNode {

    /** function triggered by click on a link */
    public var onLinkPressed:function(String);
    /** function for mouseover link */
    public var onLinkEntered:function(String);
    /** function for mouseover link */
    public var onLinkExited:function(String);
    /** link normal background */
    public var onLinkEnteredColor:Color;
    /** link highligthed background */
    public var onLinkExitedColor:Color;
    /** component location x */
    public var x:Number=0 on replace { this.translateX = x };
    /** component location y */
    public var y:Number=0 on replace { this.translateY = y };
    /** Over link mouse cursor */
    public var linkCursor:Cursor=Cursor.HAND;
    /** interline space */
    public var lineSpacing:Number=0.0;
    /** interparagraph space (current line height = 1.0) */
    public var paragraphSpacing:Number=0.745;
    /** current font attributes */
    public var basicTextAttrib:TextAttributes = TextAttributes {
        name:"Arial"
        size:12.0
        color:Color.BLACK
        bold:false
        italic:false
        link:""
    };
    /** Text component width */
    public var wrappingWidth:Number=200.0 on replace {
        // minimum width
        //wrappingWidth=Math.max(8, wrappingWidth);
        // generates the graphical content for the component
        paint();
    };
    /** Text HTML content */
    public var content:String on replace {
        // if initial text attributes are not initialized
        if (sizeof attributes==0) {
            // insert the initial text attributes into the log
            insertAttrib(basicTextAttrib.color,
                basicTextAttrib.size, basicTextAttrib.name);
        }
        // pre-process the HTML code
        processText(content);
        // generates the graphical content for the component
        paint();
    };


    /** font attributes changes */
    var attributes:StoredAttributes[];
    /** preprocess text pieces */
    var pieces:Object[];
    /** pieces to paint */
    var objs:Node[];
    /** temporary pieces (to paint) */
    var tmp:Node[];


    /** Store font attributes changes.
     * @param color Font color
     * @param size Font size
     * @param name Font name
     */
    function insertAttrib(color:Color, size:Number, name:String) {
        insert StoredAttributes {
            color:color
            size:size
            name:name
        } into attributes;
    };


    /** Preprocess HTML text
     * @param text HTML text to parse
    */
    function processText(text:String):Void {

        // clean previous preprocess pieces
        delete pieces;
        // clear previous graphics
        delete objs;
        // unique id for links
        var linkId:Integer=0;

        // processed text length
        var len = text.length();
        // temporary string (text segment)
        var sg = "";
        // text pointer
        var i = 0;

        // scan text
        while ( i < len ) {

            // get character
            var ch = "{text.charAt(i)}";

            // it is a special char
            if (ch=='&') {

                // get following text (next 8 chars or last chars in the text)
                var nxTx = (if ( i + 8 < len ) text.substring(i, i + 8)
                           else text.substring(i)).toLowerCase();

                // if next char is "
                if (nxTx.startsWith("&quot;")) {
                    // char = "
                    sg+="\"";
                    // skip char
                    i+=5;
                }
                // if next char is <
                else if (nxTx.startsWith("&lt;")) {
                    // char = <
                    sg+="<";
                    // skip char
                    i+=3;
                }
                // if next char is >
                else if (nxTx.startsWith("&gt;")) {
                    // char = >
                    sg+=">";
                    // skip char
                    i+=3;
                }
                // if next char is &
                else if (nxTx.startsWith("&amp;")) {
                    // char = &
                    sg+="&";
                    // skip char
                    i+=4;
                }
                // if next char is ' ' (non-breaking space)
                else if (nxTx.startsWith("&nbsp;")) {
                    // char = ' '
                    sg+=" ";
                    // skip char
                    i+=5;
                }
                // if next char is '€'
                else if (nxTx.startsWith("&euro;")) {
                    // char = ' '
                    sg+="€";
                    // skip char
                    i+=5;
                };
            }
            // start of HTML tag
            else if (ch=='<') {

                // previous content in the text segment
                if (sg.length() != 0) {
                    // insert text element, with the content previous to the tag
                    createText(sg, basicTextAttrib, false, linkId);
                    // reset text segment content
                    sg="";
                }
                // find the end of the HTML tag
                var j = text.indexOf('>', i);
                // get the content insize de HTML tag
                var segment = text.substring(++i, j).trim();
                // HTML tag contento in lower case
                var lSegment = segment.toLowerCase();
                // skip pointer to the end of the HTML tag
                i = j;

                // is a <font ...> tag
                if (lSegment.startsWith("font ")) {

                    // color: <font color=#...>
                    var pnt = lSegment.indexOf("color");
                    if ( pnt >= 0 ) {
                        // parse color=#Color.rrggbb
                        var red:Number = Integer.parseInt(lSegment.substring(pnt+7, pnt+9), 16);
                        var green:Number = Integer.parseInt(lSegment.substring(pnt+9, pnt+11), 16);
                        var blue:Number = Integer.parseInt(lSegment.substring(pnt+11, pnt+13), 16);
                        // update current color
                        basicTextAttrib.color = Color.color(
                            if (red == 0) 0 else red/255,
                            if (green == 0) 0 else green/255,
                            if (blue == 0) 0 else blue/255);
                    }
                    // size: <font size=...>
                    pnt = lSegment.indexOf("size");
                    if ( pnt >= 0 ) {
                        // check for a space after the size data
                        var pnt2 = lSegment.indexOf(" ", pnt + 5 );
                        // obtains all the text after size=...
                        var fSize = segment.substring(pnt + 5);
                        // if contains a space after the size data
                        if (pnt2 >= 0)
                            // get size data substring
                            fSize = segment.substring(pnt+5, pnt2);
                        // update current font size
                        basicTextAttrib.size = Number.parseFloat(fSize);
                    }
                    // face: <font face=...>
                    pnt = lSegment.indexOf("face");
                    if ( pnt >= 0 ){
                        // check for a space after the font face data
                        var pnt2 = lSegment.indexOf(" ", pnt + 5 );
                        // obtain all the text after face=...
                        var fName=segment.substring(pnt + 5);
                        // if contains a space after the font face data
                        if (pnt2 >= 0)
                            // get font face substring
                            fName=segment.substring(pnt+5, pnt2);
                        // update current font face
                        basicTextAttrib.name=fName;
                    }
                    // store font attributes changes
                    insertAttrib(basicTextAttrib.color,
                        basicTextAttrib.size, basicTextAttrib.name);
                }
                // if <br> tag (break-line)
                else if (lSegment.equals("br")) {
                    // insert BR command into the sequence
//                    insert BR into pieces;
                }
                // if <b> tag
                else if (lSegment.equals("b")) {
                    // bold font active
                    basicTextAttrib.bold=true;
                }
                // if <i>
                else if (lSegment.equals("i")) {
                    // italic font active
                    basicTextAttrib.italic=true;
                }
                // if <a href=...>
                else if (lSegment.startsWith("a ")) {
                    // following texts linked to... URL, id, etc.
                    basicTextAttrib.link=segment.substring(7);
                    // link Id
                    linkId++;
                }
                // if tag starts with </....>
                else if (lSegment.startsWith("/")) {

                    // if </b>
                    if (lSegment.startsWith("/b")) {
                        // bold font inactive
                        basicTextAttrib.bold=false;
                    }
                    // if </i>
                    else if (lSegment.startsWith("/i")) {
                        // italic font inactive
                        basicTextAttrib.italic=false;
                    }
                    // if </font>
                    else if (lSegment.equals("/font")) {
                        // recover font attributes to previous configuration
                        var lastElement = sizeof attributes - 2;
                        var attrib = attributes[lastElement];
                        basicTextAttrib.size = attrib.size;
                        basicTextAttrib.color = attrib.color;
                        basicTextAttrib.name = attrib.name;
                        // remove previous attributes from sequence
                        delete attributes[lastElement + 1];
                    }
                    // if </a>
                    else if (lSegment.equals("/a")) {
                        // following texts not liked...
                        basicTextAttrib.link="";
                    }
                    // if </p>
                    else if (lSegment.equals("/p")) {
                        // insert P command into the sequence
//                        insert P into pieces;
                    }
                }
                // if <p align=...>
                else if (lSegment.startsWith("p align=")) {

                    // if LEFT
                    if (lSegment.contains("left")) {
                        // insert LEFT command into the sequence
//                        insert LEFT into pieces;
                    }
                    // if JUSTIFY
                    else if (lSegment.contains("justify")) {
                        // insert JUSTIFY command into the sequence
//                        insert JUSTIFY into pieces;
                    }
                    // if CENTER
                    else if (lSegment.contains("center")) {
                        // insert CENTER command into the sequence
//                        insert CENTER into pieces;
                    }
                    // if RIGHT
                    else if (lSegment.contains("right")) {
                        // insert RIGHT command into the sequence
//                        insert RIGHT into pieces;
                    };
                };
            }
            // if space
            else if (ch == ' ') {
                // add space to segment
                sg += " ";
                // add text piece to sequence (including the space separator)
                createText(sg, basicTextAttrib, true, linkId);
                // reset segment
                sg="";
            }
            // any other character
            else {
                // add char to segment
                sg += "{ch}";
            };
            // next char in the text
            i++;
        };

        // text left into the segment at the end of the process
        if (sg.length() != 0) {
            // add piece of text to the sequence
            createText(sg, basicTextAttrib, false, linkId);
        }

        // transfer temporary sequence of nodes to the component
        objs=tmp;
        delete tmp;
    };


    /** create text or linked text with related attributes
     * @param text Text content of the node
     * @param curr Text attributes for the text node
     * @param breakable The piece of text can be separated from the next one.
     *        Used to separate the text into lines.
     */
    function createText(text:String, curr:TextAttributes, breakable:Boolean, linkId:Integer):Void {

        // font to apply to the text
        var font:Font = null;
        // look for a previously used font
        for (storedFont in fonts) {
            // looks for font required id
            if (storedFont.id == "{curr.size},{curr.bold},{curr.italic},{curr.name}") {
                // recover font from cache
                font = storedFont.font;
            }
        }
        // this is the first time this font was used
        if (font == null) {
            // creates the font
            font = Font {
                name: basicTextAttrib.name
                embolden: basicTextAttrib.bold
                oblique: basicTextAttrib.italic
                size: basicTextAttrib.size
            };
            // store font with and id
            insert fontCache {
                id:   "{basicTextAttrib.size},{basicTextAttrib.bold},"
                      "{basicTextAttrib.italic},{basicTextAttrib.name}",
                font: font
            } into fonts;
        }

        // workaround to get maximum height of the font
        var fHeight:Number = 0;
        // look for a previously used font height
        for (fontToLines in lineHeights) {
            if (fontToLines.size == basicTextAttrib.size)
                // recover line height
                fHeight = fontToLines.height;
        }
        // this is the first time this font size was used
        if (fHeight == 0) {
            // obtains line height for the font
            var tmpTxt = Text { content: "Aj,", font:font };
            fHeight = tmpTxt.boundsInLocal.height;
            // store font size to line height measures
            insert fontsizePixels
                {size:basicTextAttrib.size, height: fHeight} into lineHeights;
        }

        // Text node
        var txt = Text {
            content: text
            fill: basicTextAttrib.color
            underline: curr.link.length() != 0
            font: font
        };

        // there's no link associated to the text
        if (basicTextAttrib.link.equals("")) {
            // add text node
            insert txt into tmp;
        // there's a link associted to the text
        } else {
            // add group, linked text (text + background rectangle)
            var link = basicTextAttrib.link;
            var pos = sizeof pieces - 1;
            var color = if (onLinkExitedColor==null) mainOnLinkExitedColor else onLinkExitedColor;
            insert Group {
                cursor: linkCursor
                content: [
                    Rectangle {
                        // workaround width (-4)
                        width: txt.boundsInLocal.width - 4
                        height: fHeight
                        fill: color
                        translateY: -fHeight + 4
                    },
                    txt
                ]
                onMousePressed: function(e) {
                    // no custom function
                    if (onLinkPressed == null) {
                        // call common function
                        mainOnLinkPressed(link);
                    // custom instance function
                    } else {
                        // call custom function
                        onLinkPressed(link);
                    };
                },
                onMouseEntered: function(e) {
                    HLLink(linkId, true);
                    if (onLinkEntered==null) {
                        mainOnLinkEntered(link);
                    } else {
                        onLinkEntered(link);
                    };
                },
                onMouseExited: function(e) {
                    HLLink(linkId, false);
                    if (onLinkExited==null) {
                        mainOnLinkExited(link);
                    } else {
                        onLinkExited(link);
                    };
                }

            } into tmp;

        };

        // insert breakable text object
        insert BreakableText {
            position: sizeof tmp - 1
            linkId: linkId
            breakable: breakable
            isLinked: basicTextAttrib.link.length() != 0
            width: txt.boundsInLocal.width
            height: fHeight
        } into pieces;

    };


    /** Highlight links on mouseOver
     * @param linkId Unique Id for same link on different pieces
     * @param status Normal/highlighted link
     */
    function HLLink(linkId:Integer, status:Boolean) {
        // entered background color
        var enterColor=if (onLinkEnteredColor==null) mainOnLinkEnteredColor else onLinkEnteredColor;
        // exited background color
        var exitColor=if (onLinkExitedColor==null) mainOnLinkExitedColor else onLinkExitedColor;
        // scan pieces
        for (piece in pieces) {
            // is a pieces of text (not a command)
            if (piece instanceof BreakableText) {
                // cast the piece as BreakableText
                var brkTxt = piece as BreakableText;
                // the piece of text is linked and the link match
                // the requested link to highlight
                if (brkTxt.isLinked and linkId == (brkTxt).linkId) {
                    // obtains node associated to the pieces of text
                    var linkedPiece = objs[brkTxt.position] as Group;
                    // obtains the background rectangle for the "link"
                    var rect = linkedPiece.content[0] as Rectangle;
                    // switch the background color
                    rect.fill = if (status) enterColor else exitColor;
                }
            }
        }
    }


    /** Generate graphic nodes */
    function paint():Void {

        // max width was set
        if (isInitialized(wrappingWidth)) {

            // horizontal position
            var hor:Number = 0.0;
            // vertical position
            var ver:Number = 0.0;
            // piece width
            var w:Number = 0.0;
            // piece height
            var h:Number = 0.0;
            // pieces pointer
            var p:Integer = 0;
            // secondary pieces pointer
            var p2:Integer = 0;
            // last breakable piece pointer
            var lastP:Integer = 0;
            // last breakable piece width
            var lastHor:Number = 0;
            // maximum line height
            var maxY:Number = 0.0;
            // last height used in the line
            var lastMaxY:Number;
            // flag paragraph jump </P>
            var PL:Boolean = false;
            // flag break-line jump <BR>
            var BRL:Boolean = false;
            // current paragraph alignment
            var align:Integer = LEFT;
            // current line width
            var currWidth:Number;
            // inter-word space (justify alignment)
            var interWordSpace:Number=0.0;
            // word counter
            var wordCnt:Integer=0;

            // scan pieces
            while (p < sizeof pieces) {

                // get piece
                var piece = pieces[p];
                var breakable:Boolean=false;

                // is a text or linked text
                if (piece instanceof BreakableText) {

                    // cast node as text
                    var text = piece as BreakableText;
                    // piece width - workaround group width
                    w = text.width - (if (text.isLinked) 4 else 0);
                    // piece height
                    h = text.height;
                    // breakable/non-breakable text
                    breakable = text.breakable;
                    // if breakable text
                    if (breakable) {
                        // word counter
                        wordCnt++;
                    }
                }
                // is a command (/p, br, left, right, center, etc)
                else {

                    // get the command code
                    var cmd:Integer = piece as Integer;
                    // reset piece width
                    w=0;

                    // is a </p>
                    if (cmd == P) {
                        // flag P
                        PL = true;
                    // is a <br>
                    } else if (cmd == BR) {
                        // flag BR
                        BRL = true;
                    // is an alignment LEFT, CENTER, RIGHT o JUSTIFY
                    } else if (cmd == LEFT or cmd == CENTER or
                    cmd == RIGHT or cmd == JUSTIFY) {
                        // get alignment code
                        align = cmd;
                    };
                };

                // acummulate piece width
                hor += w;

                // if accumulated widths exceed the maximum width of the component
                // or the pointer reached the last piece in the sequence or
                // it detects a paragraph end </p> or a break-line <BR>
                if (hor >= wrappingWidth or p == sizeof pieces - 1 or PL or BRL) {

                    // if it exceeded the component's width
                    if (hor >= wrappingWidth and wordCnt>1) {
                        // recover the pointer and line width to the last piece
                        // that fits in the current line that can end the line
                        p = lastP;
                        currWidth = lastHor;
                    }
                    // it reached the last piece in the sequence or a </p> or <br>
                    else {
                        // get maximum height for the text line
                        maxY = Math.max(h, maxY);
                        // get the current width for the text line
                        currWidth = hor;
                    }

                    // if aligned to the right
                    if (align == RIGHT) {
                        // initial position for the line to reach the right edge
                        hor = wrappingWidth - currWidth;
                    // if centered
                    } else if (align == CENTER) {
                        // initial position for the line to keep centered
                        hor = (wrappingWidth - currWidth) / 2;
                    // if justified
                    } else if (align == JUSTIFY) {
                        // calculate inter-word spacing
                        interWordSpace=0;
                        // if the line exceeded the maximum width
                        // (the paragraph continues after this line)
                        if (hor >= wrappingWidth and wordCnt > 1) {
                            // reset breakable-pieces counter
                            var cntBrkWord = 0;
                            // scan text pieces and commands
                            for (piece2 in pieces[p2..p]) {
                                // if piece is a text or linked text (group)
                                if (piece2 instanceof BreakableText) {
                                    // if the piece is breakable (can end the line)
                                    if ((piece2 as BreakableText).breakable)
                                        // count it
                                        cntBrkWord++;
                                };
                            };
                            // inter-word space is the fraction of the spare space in the line
                            interWordSpace = (wrappingWidth - currWidth) / (cntBrkWord - 1);
                        };
                        // left margin
                        hor = 0;
                    } else {
                        // left margin
                        hor = 0;
                    };

                    // increase vertical position (line height) + interline spacing
                    ver += maxY + lineSpacing;
                    // keeps line height (in case of a </p> or <br>)
                    lastMaxY = maxY;
                    // reset maximum line height
                    maxY=0;

                    // scan the pieces of text and commands
                    // and rearrange the graphic nodes in the component
                    for (piece2 in pieces[p2..p]) {
                        // if piece is a text or linked text
                        if (piece2 instanceof BreakableText) {
                            // cast pieces as BreakableText
                            var text = piece2 as BreakableText;
                            // reposition the associated node
                            objs[text.position].translateX = hor;
                            objs[text.position].translateY = ver;
                            // text width
                            w = text.width - (if (text.isLinked) 4 else 0);
                            // next horizontal position for text
                            // piece width + interword space if justified
                            // (space only between words, not pieces of words)
                            hor += w + (if (text.breakable) interWordSpace else 0);
                        };
                    };

                    // if reached the end of a paragraph </p>
                    if (PL) {
                        // skip line to next paragraph
                        ver += lastMaxY * paragraphSpacing;
                        // remove paragraph jump flag </p>
                        PL = false;
                        // default alignment (LEFT)
                        align = LEFT;
                    }
                    // remove break-like jump flag <br>
                    BRL = false;
                    // reset horizontal position
                    hor = 0;
                    // next starting pointer
                    p2 = p + 1;
                    // reset word counter
                    wordCnt=0;
                }
                // if the text piece can be included in the current line
                else {
                    // check if the piece of text is breakable (can break the line)
                    if (breakable) {
                        // store the last pointer to a piece of text
                        // that can end the line.
                        lastP = p;
                        // store the width to the last piece of text
                        // that can end the line.
                        lastHor = hor;
                    }
                    // check for maximum line height
                    maxY = Math.max(h, maxY);
                };
                // next piece
                p++;
            };
        };
    };


    /** create component */
    public override function create(): Node {
        return Group {
            // sequence containing the graphics
            content: bind objs
        };
    };


};

/** used to store font size -> text like info */
class fontsizePixels {
    public var size:Number;
    public var height:Number;
}

/** used to store fonts */
class fontCache {
    public var id:String;
    public var font:Font;
}

/** stores basic information about the font attribute changes */
class StoredAttributes {

    /** font color */
    public var color:Color;
    /** font name */
    public var name:String;
    /** font size */
    public var size:Number;

}

/** Breakable text component */
class BreakableText  {

    /** node position */
    public var position:Integer;
    /** text can be broken into pieces */
    public var breakable:Boolean;
    /** font height */
    public var height:Number;
    /** text width */
    public var width:Number;
    /** is a linked text */
    public var isLinked:Boolean;
    /** link id */
    public var linkId:Integer;
}


/** Stores current font attributes */
public class TextAttributes {

    /** font color */
    public var color:Color;
    /** font name */
    public var name:String;
    /** font size */
    public var size:Number;
    /** embolded font */
    public var bold:Boolean;
    /** oblique font */
    public var italic:Boolean;
    /** current link */
    public var link:String;

}