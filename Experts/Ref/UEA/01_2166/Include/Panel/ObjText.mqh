//+------------------------------------------------------------------+
//|                                                  LabelButton.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| Container class. Defines text on a button                        |
//+------------------------------------------------------------------+
class CObjText
  {
private:
   string            m_text;           // The text
   int               m_text_size;      // Text font size
   string            m_text_font;      // Font name
   color             m_text_color;     // Font color
public:
/* Set methods */
   void              Text(string text);
   void              Size(int size);
   void              Font(string font);
   void              Color(color clr);

/* Get methods */
   string            Text(void);
   int               Size(void);
   string            Font(void);
   color             Color(void);

   CObjText         *Clone(void);
   bool              operator=(CObjText &text);
  };
//+------------------------------------------------------------------+
//| Sets the text of the element                                     |
//+------------------------------------------------------------------+
void CObjText::Text(string text)
  {
   m_text=text;
  }
//+------------------------------------------------------------------+
//| Returns the text of the element                                  |
//+------------------------------------------------------------------+
string CObjText::Text(void)
  {
   return m_text;
  }
//+------------------------------------------------------------------+
//| Sets the font size of the element text                           |
//+------------------------------------------------------------------+
void CObjText::Size(int text_size)
  {
   m_text_size=text_size;
  }
//+------------------------------------------------------------------+
//| Returns the font size of the element text                        |
//+------------------------------------------------------------------+
int CObjText::Size(void)
  {
   return m_text_size;
  }
//+------------------------------------------------------------------+
//| Sets the color of the text on the element                        |
//+------------------------------------------------------------------+
void CObjText::Color(color clr)
  {
   m_text_color=clr;
  }
//+------------------------------------------------------------------+
//| Returns the color of the text on the element                     |
//+------------------------------------------------------------------+
color CObjText::Color(void)
  {
   return m_text_color;
  }
//+------------------------------------------------------------------+
//| Sets the text of the element                                     |
//+------------------------------------------------------------------+
void CObjText::Font(string text_font)
  {
   m_text_font=text_font;
  }
//+------------------------------------------------------------------+
//| Returns the font name.                                           |
//+------------------------------------------------------------------+
string CObjText::Font(void)
  {
   return m_text_font;
  }
//+------------------------------------------------------------------+
//| Clones text settings and returns a new object with them          |
//+------------------------------------------------------------------+
CObjText *CObjText::Clone(void)
  {
   CObjText *clone=new CObjText();
   clone.m_text=m_text;
   clone.m_text_font=m_text_font;
   clone.m_text_color= m_text_color;
   clone.m_text_size = m_text_size;
   return clone;
  }
//+------------------------------------------------------------------+
//| The Copy operator                                                |
//+------------------------------------------------------------------+
bool CObjText::operator=(CObjText &objText)
  {
   m_text=objText.Text();
   m_text_font=objText.Font();
   m_text_color= objText.Color();
   m_text_size = objText.Size();
   return true;
  }
//+------------------------------------------------------------------+
