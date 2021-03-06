//+------------------------------------------------------------------+
//|                                         EventChartConsoleAdd.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//|                                        EventChartPBarChanged.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include "Event.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEventCharConsoleAdd : public CEvent
  {
private:
   int               m_console_id;           //
   string            m_message;              //
public:
                     CEventCharConsoleAdd(int progress_bar_id,string message);
   int               ConsoleID(void);
   string            Message(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEventCharConsoleAdd::CEventCharConsoleAdd(int console_id,string message) : CEvent(EVENT_CHART_CONSOLE_ADD)
  {
   m_console_id=console_id;
   m_message=message;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CEventCharConsoleAdd::ConsoleID(void)
  {
   return m_console_id;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CEventCharConsoleAdd::Message(void)
  {
   return m_message;
  }
//+------------------------------------------------------------------+
