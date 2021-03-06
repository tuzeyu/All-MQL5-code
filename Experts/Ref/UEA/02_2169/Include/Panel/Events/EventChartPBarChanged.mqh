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
class CEventChartPBarChanged : public CEvent
  {
private:
   int               m_progress_bar_id;      //
   double            m_percent;              //
public:
                     CEventChartPBarChanged(int progress_bar_id,double percent);
   int               ProgresBarID(void);
   double            Percent(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEventChartPBarChanged::CEventChartPBarChanged(int progress_bar_id,double percent) : CEvent(EVENT_CHART_PBAR_CHANGED)
  {
   m_progress_bar_id=progress_bar_id;
   m_percent=percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CEventChartPBarChanged::ProgresBarID(void)
  {
   return m_progress_bar_id;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CEventChartPBarChanged::Percent(void)
  {
   return m_percent;
  }
//+------------------------------------------------------------------+
